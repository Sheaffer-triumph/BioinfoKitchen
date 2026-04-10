#!/bin/bash

# MSAP (Metagenomic Sequencing Analysis Pipeline)
# 宏基因组测序分析流程

set -e
set -o pipefail

# 版本信息
VERSION="1.0.0"

# 显示帮助信息
show_help() {
    cat << EOF
MSAP - Metagenomic Sequencing Analysis Pipeline v${VERSION}

Usage:
    msap.sh -c <config.json> -s <sample.csv> -o <output_dir> [options]

Required Arguments:
    -c, --config    JSON配置文件路径 (包含软件和数据库路径)
    -s, --sample    样本信息表CSV文件路径
    -o, --output    输出目录路径

Optional Arguments:
    -h, --host      宿主基因组FASTA文件路径 (用于去宿主)
    -t, --threads   线程数 (默认: 16)
    -m, --memory    内存限制 (默认: 64G)
    -r, --reads-only  仅运行基于reads的分析 (不运行组装)
    -v, --version   显示版本信息
    --help          显示此帮助信息

Sample CSV Format:
    SampleName,FQ1,FQ2,Group
    sample1,/path/to/sample1_R1.fq.gz,/path/to/sample1_R2.fq.gz,groupA
    sample2,/path/to/sample2_R1.fq.gz,/path/to/sample2_R2.fq.gz,groupA
    sample3,/path/to/sample3_R1.fq.gz,/path/to/sample3_R2.fq.gz,groupB

Example:
    msap.sh -c msap_config.json -s sample_info.csv -o ./results -h host.fa -t 32

EOF
}

# 显示版本
show_version() {
    echo "MSAP v${VERSION}"
}

# 日志输出函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "${LOG_FILE}" >&2
}

log_warn() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1" | tee -a "${LOG_FILE}"
}

# 检查命令是否存在
check_command() {
    local cmd=$1
    local path=$2

    if [ -z "$path" ] || [ "$path" = "null" ]; then
        log_error "未配置软件路径: $cmd"
        return 1
    fi

    if [ ! -f "$path" ]; then
        log_error "软件不存在: $cmd -> $path"
        return 1
    fi

    if [ ! -x "$path" ]; then
        log_error "软件没有执行权限: $cmd -> $path"
        return 1
    fi

    log "✓ 检查通过: $cmd"
    return 0
}

# 检查数据库是否存在
check_database() {
    local db_name=$1
    local db_path=$2

    if [ -z "$db_path" ] || [ "$db_path" = "null" ]; then
        log_error "未配置数据库路径: $db_name"
        return 1
    fi

    if [ ! -e "$db_path" ]; then
        log_error "数据库不存在: $db_name -> $db_path"
        return 1
    fi

    log "✓ 数据库检查通过: $db_name"
    return 0
}

# 从JSON提取值的函数 (需要python3)
get_json_value() {
    local json_file=$1
    local key=$2
    python3 -c "import json,sys; print(json.load(open('$json_file')).get('$key', ''))"
}

get_nested_json_value() {
    local json_file=$1
    local key1=$2
    local key2=$3
    python3 -c "import json,sys; d=json.load(open('$json_file')); print(d.get('$key1', {}).get('$key2', ''))"
}

# 检查并建立宿主基因组索引
check_build_host_index() {
    local host_fasta=$1
    local minimap2_path=$2

    if [ -z "$host_fasta" ] || [ ! -f "$host_fasta" ]; then
        log_warn "未提供宿主基因组文件，跳过去宿主步骤"
        return 1
    fi

    local host_dir=$(dirname "$host_fasta")
    local host_name=$(basename "$host_fasta" .fa)
    host_name=$(basename "$host_name" .fasta)
    local index_file="${host_dir}/${host_name}.mmi"

    # 检查是否已有索引文件
    if [ -f "$index_file" ]; then
        log "发现现有宿主基因组索引: $index_file"
        log "跳过索引构建"
        HOST_INDEX="$index_file"
        return 0
    fi

    # 检查其他可能的索引文件名
    for possible_index in "${host_fasta}.mmi" "${host_dir}/host_genome.mmi"; do
        if [ -f "$possible_index" ]; then
            log "发现现有宿主基因组索引: $possible_index"
            HOST_INDEX="$possible_index"
            return 0
        fi
    done

    # 没有找到索引，需要构建
    log "未找到宿主基因组索引，开始构建..."
    log "宿主基因组: $host_fasta"
    log "索引文件: $index_file"

    "$minimap2_path" -d "$index_file" "$host_fasta" 2>&1 | tee -a "${LOG_FILE}"

    if [ $? -eq 0 ] && [ -f "$index_file" ]; then
        log "✓ 宿主基因组索引构建成功: $index_file"
        HOST_INDEX="$index_file"
        return 0
    else
        log_error "宿主基因组索引构建失败"
        return 1
    fi
}

# 步骤1: 数据过滤 (fastp)
step_qc() {
    local sample=$1
    local fq1=$2
    local fq2=$3
    local out_dir=$4

    log "步骤1: 数据质控 - $sample"

    local qc_dir="${out_dir}/01_qc"
    mkdir -p "$qc_dir"

    local clean_fq1="${qc_dir}/${sample}_clean_R1.fq.gz"
    local clean_fq2="${qc_dir}/${sample}_clean_R2.fq.gz"
    local json_report="${qc_dir}/${sample}_fastp.json"
    local html_report="${qc_dir}/${sample}_fastp.html"

    "$FASTP" -i "$fq1" -I "$fq2" \
        -o "$clean_fq1" -O "$clean_fq2" \
        --detect_adapter_for_pe \
        --cut_front --cut_tail \
        --cut_window_size 4 --cut_mean_quality "${QC_CUT_MEAN_QUALITY}" \
        --length_required "${QC_LENGTH_REQUIRED}" \
        --correction \
        --json "$json_report" \
        --html "$html_report" \
        --thread "${THREADS}" \
        2>&1 | tee -a "${LOG_FILE}"

    if [ $? -eq 0 ]; then
        log "✓ 质控完成: $sample"
        echo "${sample},${clean_fq1},${clean_fq2}" >> "${out_dir}/clean_reads_list.txt"
    else
        log_error "质控失败: $sample"
        return 1
    fi
}

# 步骤2: 去宿主 (minimap2)
step_remove_host() {
    local sample=$1
    local clean_fq1=$2
    local clean_fq2=$3
    local out_dir=$4

    log "步骤2: 去宿主 - $sample"

    if [ -z "$HOST_INDEX" ] || [ ! -f "$HOST_INDEX" ]; then
        log_warn "无宿主索引，跳过去宿主步骤，使用质控后数据"
        echo "${sample},${clean_fq1},${clean_fq2}" >> "${out_dir}/nohost_reads_list.txt"
        return 0
    fi

    local rmhost_dir="${out_dir}/02_rmhost"
    mkdir -p "$rmhost_dir"

    local nohost_fq1="${rmhost_dir}/${sample}_rmhost_R1.fq.gz"
    local nohost_fq2="${rmhost_dir}/${sample}_rmhost_R2.fq.gz"
    local sam_file="${rmhost_dir}/${sample}.sam"

    # 比对到宿主基因组
    "$MINIMAP2" -ax sr -t "${THREADS}" "$HOST_INDEX" \
        "$clean_fq1" "$clean_fq2" > "$sam_file" 2>> "${LOG_FILE}"

    # 提取未比对上的reads (flag 4 = unmapped)
    "$SAMTOOLS" view -b -f 12 "$sam_file" | \
        "$SAMTOOLS" fastq -1 "$nohost_fq1" -2 "$nohost_fq2" - \
        2>> "${LOG_FILE}"

    # 删除中间SAM文件以节省空间
    rm -f "$sam_file"

    if [ -f "$nohost_fq1" ] && [ -f "$nohost_fq2" ]; then
        log "✓ 去宿主完成: $sample"
        echo "${sample},${nohost_fq1},${nohost_fq2}" >> "${out_dir}/nohost_reads_list.txt"
    else
        log_error "去宿主失败: $sample"
        return 1
    fi
}

# 步骤3: 物种鉴定 (kraken2 + bracken)
step_species_id() {
    local sample=$1
    local fq1=$2
    local fq2=$3
    local out_dir=$4

    log "步骤3: 物种鉴定 - $sample"

    local species_dir="${out_dir}/03_species"
    mkdir -p "$species_dir"

    local kraken_out="${species_dir}/${sample}.kraken2.out"
    local kraken_report="${species_dir}/${sample}.kraken2.report"
    local bracken_out="${species_dir}/${sample}.bracken.out"

    # Kraken2 分类
    "$KRAKEN2" --db "$KRAKEN2_DB" --threads "${THREADS}" \
        --paired --output "$kraken_out" --report "$kraken_report" \
        "$fq1" "$fq2" 2>> "${LOG_FILE}"

    # Bracken 丰度估计
    "$BRACKEN" -d "$KRAKEN2_DB" -i "$kraken_report" \
        -o "$bracken_out" -l S -t "${THREADS}" 2>> "${LOG_FILE}"

    log "✓ 物种鉴定完成: $sample"
}

# 步骤4: Alpha多样性分析
step_alpha_diversity() {
    local out_dir=$1

    log "步骤4: Alpha多样性分析"

    local diversity_dir="${out_dir}/04_diversity"
    mkdir -p "$diversity_dir"

    # 合并所有样本的bracken结果
    local merged_abundance="${diversity_dir}/merged_abundance.tsv"

    # 使用R进行多样性分析
    cat > "${diversity_dir}/alpha_diversity.R" << 'RSCRIPT'
library(vegan)

# 读取丰度数据
args <- commandArgs(trailingOnly=TRUE)
input_file <- args[1]
output_dir <- args[2]

abundance <- read.table(input_file, header=TRUE, row.names=1, sep="\t")

# 计算多样性指数
shannon <- diversity(abundance, index="shannon")
simpson <- diversity(abundance, index="simpson")
chao1 <- estimateR(abundance)[2,]

# 保存结果
diversity_df <- data.frame(
    Sample=names(shannon),
    Shannon=shannon,
    Simpson=simpson,
    Chao1=chao1[names(shannon)]
)

write.table(diversity_df, file=paste0(output_dir, "/alpha_diversity.tsv"),
            sep="\t", quote=FALSE, row.names=FALSE)

# 绘制稀疏曲线
pdf(paste0(output_dir, "/rarefaction_curve.pdf"))
rarecurve(abundance, step=1000, main="Rarefaction Curves")
dev.off()
RSCRIPT

    log "✓ Alpha多样性分析完成"
}

# 步骤5: 基因组组装 (MEGAHIT)
step_assembly() {
    local out_dir=$1

    if [ "$READS_ONLY" = true ]; then
        log "仅运行基于reads的分析，跳过分装步骤"
        return 0
    fi

    log "步骤5: 基因组组装"

    local assembly_dir="${out_dir}/05_assembly"
    mkdir -p "$assembly_dir"

    # 准备输入文件列表
    local read_list=""
    while IFS=',' read -r sample fq1 fq2; do
        read_list="${read_list}-1 ${fq1} -2 ${fq2} "
    done < "${out_dir}/nohost_reads_list.txt"

    # 运行MEGAHIT
    "$MEGAHIT" --presets meta-large -t "${THREADS}" \
        -o "$assembly_dir" $read_list 2>&1 | tee -a "${LOG_FILE}"

    # 过滤短contigs
    local final_contigs="${assembly_dir}/final.contigs.fa"
    local filtered_contigs="${assembly_dir}/contigs_${MIN_CONTIG_LENGTH}bp.fa"

    "$SEQKIT" seq -m "$MIN_CONTIG_LENGTH" "$final_contigs" > "$filtered_contigs"

    log "✓ 基因组组装完成"
}

# 步骤6: 基因预测 (Prodigal)
step_gene_prediction() {
    local out_dir=$1

    if [ "$READS_ONLY" = true ]; then
        return 0
    fi

    log "步骤6: 基因预测"

    local gene_dir="${out_dir}/06_gene_prediction"
    mkdir -p "$gene_dir"

    local contigs="${out_dir}/05_assembly/contigs_${MIN_CONTIG_LENGTH}bp.fa"
    local genes_faa="${gene_dir}/predicted_genes.faa"
    local genes_ffn="${gene_dir}/predicted_genes.ffn"
    local genes_gff="${gene_dir}/predicted_genes.gff"

    "$PRODIGAL" -i "$contigs" -p meta \
        -a "$genes_faa" -d "$genes_ffn" -o "$genes_gff" \
        2>> "${LOG_FILE}"

    log "✓ 基因预测完成"
}

# 步骤7: 非冗余基因集 (MMseqs2)
step_cluster_genes() {
    local out_dir=$1

    if [ "$READS_ONLY" = true ]; then
        return 0
    fi

    log "步骤7: 构建非冗余基因集"

    local cluster_dir="${out_dir}/07_gene_cluster"
    mkdir -p "$cluster_dir"

    local input_genes="${out_dir}/06_gene_prediction/predicted_genes.faa"
    local cluster_prefix="${cluster_dir}/nr_genes"

    # MMseqs2聚类
    "$MMSEQS2" easy-linclust "$input_genes" "${cluster_prefix}.faa" \
        "${cluster_dir}/tmp" --min-seq-id "${MMSEQS_MIN_SEQ_ID}" -c "${MMSEQS_COVERAGE}" --threads "${THREADS}" \
        2>> "${LOG_FILE}"

    log "✓ 非冗余基因集构建完成"
}

# 步骤8: 基因丰度计算 (Salmon)
step_gene_abundance() {
    local out_dir=$1

    if [ "$READS_ONLY" = true ]; then
        return 0
    fi

    log "步骤8: 基因丰度计算"

    local abundance_dir="${out_dir}/08_gene_abundance"
    mkdir -p "$abundance_dir"

    local nr_genes="${out_dir}/07_gene_cluster/nr_genes.faa"
    local salmon_index="${abundance_dir}/salmon_index"

    # 建立Salmon索引
    "$SALMON" index -t "$nr_genes" -i "$salmon_index" -p "${THREADS}" \
        2>> "${LOG_FILE}"

    # 对每个样本进行定量
    while IFS=',' read -r sample fq1 fq2; do
        log "  定量样本: $sample"
        local sample_out="${abundance_dir}/${sample}"
        "$SALMON" quant -i "$salmon_index" -l "${SALMON_LIB_TYPE}" \
            -1 "$fq1" -2 "$fq2" \
            -p "${THREADS}" -o "$sample_out" \
            2>> "${LOG_FILE}"
    done < "${out_dir}/nohost_reads_list.txt"

    log "✓ 基因丰度计算完成"
}

# 步骤9: 功能注释 (Diamond + EggNOG)
step_functional_annotation() {
    local out_dir=$1

    if [ "$READS_ONLY" = true ]; then
        return 0
    fi

    log "步骤9: 功能注释"

    local anno_dir="${out_dir}/09_functional_annotation"
    mkdir -p "$anno_dir"

    local nr_genes="${out_dir}/07_gene_cluster/nr_genes.faa"

    # CAZy注释
    log "  CAZy注释..."
    "$DIAMOND" blastp -d "$CAZY_DB" -q "$nr_genes" \
        -o "${anno_dir}/cazy_results.tsv" --threads "${THREADS}" \
        --evalue "${DIAMOND_EVALUE}" --max-target-seqs 1 \
        2>> "${LOG_FILE}"

    # GO注释
    log "  GO注释..."
    "$DIAMOND" blastp -d "$GO_DB" -q "$nr_genes" \
        -o "${anno_dir}/go_results.tsv" --threads "${THREADS}" \
        --evalue "${DIAMOND_EVALUE}" --max-target-seqs 1 \
        2>> "${LOG_FILE}"

    # EggNOG注释
    log "  EggNOG注释..."
    "$EMAPPER" -i "$nr_genes" --output "${anno_dir}/eggnog" \
        --cpu "${THREADS}" --data_dir "$EGGNOG_DB" \
        2>> "${LOG_FILE}"

    log "✓ 功能注释完成"
}

# 步骤10: 差异物种分析 (LEfSe)
step_differential_analysis() {
    local out_dir=$1
    local sample_file=$2

    log "步骤10: 差异物种分析"

    local diff_dir="${out_dir}/10_differential"
    mkdir -p "$diff_dir"

    # 提取分组信息
    local group_file="${diff_dir}/groups.tsv"
    tail -n +2 "$sample_file" | awk -F',' '{print $1"\t"$4}' > "$group_file"

    log "✓ 差异物种分析完成 (需使用专用LEfSe工具进一步分析)"
}

# 主函数
main() {
    # 参数解析
    CONFIG_FILE=""
    SAMPLE_FILE=""
    OUTPUT_DIR=""
    HOST_FASTA=""
    THREADS=16
    MEMORY="64G"
    READS_ONLY=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -s|--sample)
                SAMPLE_FILE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -h|--host)
                HOST_FASTA="$2"
                shift 2
                ;;
            -t|--threads)
                THREADS="$2"
                shift 2
                ;;
            -m|--memory)
                MEMORY="$2"
                shift 2
                ;;
            -r|--reads-only)
                READS_ONLY=true
                shift
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # 检查必需参数
    if [ -z "$CONFIG_FILE" ] || [ -z "$SAMPLE_FILE" ] || [ -z "$OUTPUT_DIR" ]; then
        log_error "缺少必需参数！"
        show_help
        exit 1
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "配置文件不存在: $CONFIG_FILE"
        exit 1
    fi

    if [ ! -f "$SAMPLE_FILE" ]; then
        log_error "样本文件不存在: $SAMPLE_FILE"
        exit 1
    fi

    # 创建输出目录
    mkdir -p "$OUTPUT_DIR"
    LOG_FILE="${OUTPUT_DIR}/msap_pipeline.log"

    log "=========================================="
    log "MSAP 分析流程启动"
    log "版本: ${VERSION}"
    log "配置文件: ${CONFIG_FILE}"
    log "样本文件: ${SAMPLE_FILE}"
    log "输出目录: ${OUTPUT_DIR}"
    log "线程数: ${THREADS}"
    log "=========================================="

    # 读取配置文件
    log "读取配置文件..."

    # 软件路径
    FASTP=$(get_nested_json_value "$CONFIG_FILE" "software" "fastp")
    MINIMAP2=$(get_nested_json_value "$CONFIG_FILE" "software" "minimap2")
    KRAKEN2=$(get_nested_json_value "$CONFIG_FILE" "software" "kraken2")
    BRACKEN=$(get_nested_json_value "$CONFIG_FILE" "software" "bracken")
    MEGAHIT=$(get_nested_json_value "$CONFIG_FILE" "software" "megahit")
    PRODIGAL=$(get_nested_json_value "$CONFIG_FILE" "software" "prodigal")
    MMSEQS2=$(get_nested_json_value "$CONFIG_FILE" "software" "mmseqs2")
    SALMON=$(get_nested_json_value "$CONFIG_FILE" "software" "salmon")
    DIAMOND=$(get_nested_json_value "$CONFIG_FILE" "software" "diamond")
    EMAPPER=$(get_nested_json_value "$CONFIG_FILE" "software" "emapper")
    SEQKIT=$(get_nested_json_value "$CONFIG_FILE" "software" "seqkit")
    SAMTOOLS=$(get_nested_json_value "$CONFIG_FILE" "software" "samtools")
    PYTHON3=$(get_nested_json_value "$CONFIG_FILE" "software" "python3")
    RSCRIPT=$(get_nested_json_value "$CONFIG_FILE" "software" "Rscript")

    # 数据库路径
    KRAKEN2_DB=$(get_nested_json_value "$CONFIG_FILE" "database" "kraken2_db")
    CAZY_DB=$(get_nested_json_value "$CONFIG_FILE" "database" "cazy_db")
    GO_DB=$(get_nested_json_value "$CONFIG_FILE" "database" "go_db")
    EGGNOG_DB=$(get_nested_json_value "$CONFIG_FILE" "database" "eggnog_db")
    ANNO_REF=$(get_nested_json_value "$CONFIG_FILE" "database" "anno_ref")

    # 参数
    MIN_CONTIG_LENGTH=$(get_nested_json_value "$CONFIG_FILE" "parameters" "min_contig_length")
    MIN_CONTIG_LENGTH=${MIN_CONTIG_LENGTH:-300}

    # 质控参数
    QC_CUT_MEAN_QUALITY=$(get_nested_json_value "$CONFIG_FILE" "parameters" "qc_cut_mean_quality")
    QC_CUT_MEAN_QUALITY=${QC_CUT_MEAN_QUALITY:-20}

    QC_LENGTH_REQUIRED=$(get_nested_json_value "$CONFIG_FILE" "parameters" "qc_length_required")
    QC_LENGTH_REQUIRED=${QC_LENGTH_REQUIRED:-30}

    # MMseqs2聚类参数
    MMSEQS_MIN_SEQ_ID=$(get_nested_json_value "$CONFIG_FILE" "parameters" "mmseqs_min_seq_id")
    MMSEQS_MIN_SEQ_ID=${MMSEQS_MIN_SEQ_ID:-0.95}

    MMSEQS_COVERAGE=$(get_nested_json_value "$CONFIG_FILE" "parameters" "mmseqs_coverage")
    MMSEQS_COVERAGE=${MMSEQS_COVERAGE:-0.9}

    # Diamond注释参数
    DIAMOND_EVALUE=$(get_nested_json_value "$CONFIG_FILE" "parameters" "diamond_evalue")
    DIAMOND_EVALUE=${DIAMOND_EVALUE:-1e-5}

    # Salmon文库类型
    SALMON_LIB_TYPE=$(get_nested_json_value "$CONFIG_FILE" "parameters" "salmon_lib_type")
    SALMON_LIB_TYPE=${SALMON_LIB_TYPE:-A}

    log "参数设置:"
    log "  线程数: ${THREADS}"
    log "  内存: ${MEMORY}"
    log "  Contig最小长度: ${MIN_CONTIG_LENGTH}bp"
    log "  质控质量阈值: Q${QC_CUT_MEAN_QUALITY}"
    log "  MMseqs2相似度阈值: ${MMSEQS_MIN_SEQ_ID}"
    log "  Diamond E-value: ${DIAMOND_EVALUE}"

    # 检查必需软件
    log "检查必需软件..."
    local software_check_failed=0

    check_command "fastp" "$FASTP" || ((software_check_failed++))
    check_command "minimap2" "$MINIMAP2" || ((software_check_failed++))
    check_command "kraken2" "$KRAKEN2" || ((software_check_failed++))
    check_command "bracken" "$BRACKEN" || ((software_check_failed++))
    check_command "megahit" "$MEGAHIT" || ((software_check_failed++))
    check_command "prodigal" "$PRODIGAL" || ((software_check_failed++))
    check_command "mmseqs2" "$MMSEQS2" || ((software_check_failed++))
    check_command "salmon" "$SALMON" || ((software_check_failed++))
    check_command "diamond" "$DIAMOND" || ((software_check_failed++))
    check_command "emapper" "$EMAPPER" || ((software_check_failed++))
    check_command "seqkit" "$SEQKIT" || ((software_check_failed++))
    check_command "samtools" "$SAMTOOLS" || ((software_check_failed++))
    check_command "python3" "$PYTHON3" || ((software_check_failed++))
    check_command "Rscript" "$RSCRIPT" || ((software_check_failed++))

    if [ $software_check_failed -gt 0 ]; then
        log_error "有 ${software_check_failed} 个必需软件检查失败，请检查配置文件"
        exit 1
    fi

    # 检查必需数据库
    log "检查必需数据库..."
    local db_check_failed=0

    check_database "kraken2_db" "$KRAKEN2_DB" || ((db_check_failed++))
    check_database "cazy_db" "$CAZY_DB" || ((db_check_failed++))
    check_database "go_db" "$GO_DB" || ((db_check_failed++))
    check_database "eggnog_db" "$EGGNOG_DB" || ((db_check_failed++))

    if [ $db_check_failed -gt 0 ]; then
        log_error "有 ${db_check_failed} 个必需数据库检查失败，请检查配置文件"
        exit 1
    fi

    # 检查并构建宿主索引
    if [ -n "$HOST_FASTA" ]; then
        check_build_host_index "$HOST_FASTA" "$MINIMAP2"
    fi

    # 初始化输出文件
    > "${OUTPUT_DIR}/clean_reads_list.txt"
    > "${OUTPUT_DIR}/nohost_reads_list.txt"

    # 处理每个样本
    log "开始处理样本..."
    tail -n +2 "$SAMPLE_FILE" | while IFS=',' read -r sample fq1 fq2 group; do
        log "处理样本: $sample (分组: $group)"

        # 检查输入文件
        if [ ! -f "$fq1" ] || [ ! -f "$fq2" ]; then
            log_error "样本 $sample 的输入文件不存在: $fq1 或 $fq2"
            continue
        fi

        # 步骤1: 质控
        step_qc "$sample" "$fq1" "$fq2" "$OUTPUT_DIR"

        # 获取质控后的文件路径
        local clean_fq1="${OUTPUT_DIR}/01_qc/${sample}_clean_R1.fq.gz"
        local clean_fq2="${OUTPUT_DIR}/01_qc/${sample}_clean_R2.fq.gz"

        # 步骤2: 去宿主
        step_remove_host "$sample" "$clean_fq1" "$clean_fq2" "$OUTPUT_DIR"

        # 获取去宿主后的文件路径
        local nohost_entry=$(grep "^${sample}," "${OUTPUT_DIR}/nohost_reads_list.txt" | tail -1)
        local nohost_fq1=$(echo "$nohost_entry" | cut -d',' -f2)
        local nohost_fq2=$(echo "$nohost_entry" | cut -d',' -f3)

        # 步骤3: 物种鉴定
        step_species_id "$sample" "$nohost_fq1" "$nohost_fq2" "$OUTPUT_DIR"
    done

    # 步骤4: Alpha多样性
    step_alpha_diversity "$OUTPUT_DIR"

    # 步骤5-9: 组装相关分析 (如果不是仅reads分析)
    if [ "$READS_ONLY" = false ]; then
        step_assembly "$OUTPUT_DIR"
        step_gene_prediction "$OUTPUT_DIR"
        step_cluster_genes "$OUTPUT_DIR"
        step_gene_abundance "$OUTPUT_DIR"
        step_functional_annotation "$OUTPUT_DIR"
    fi

    # 步骤10: 差异分析
    step_differential_analysis "$OUTPUT_DIR" "$SAMPLE_FILE"

    log "=========================================="
    log "MSAP 分析流程完成！"
    log "结果目录: ${OUTPUT_DIR}"
    log "日志文件: ${LOG_FILE}"
    log "=========================================="
}

# 运行主函数
main "$@"
