version 1.0

workflow phagex_assemble_annotation_workflow  #定义工作流
{
  input                                       #定义工作流的输入
  {
    File fastq1                               #定义输入的文件类型和名称
    File fastq2
    String phageID
    Array[File] Anno_db
  }
  call phage_assemble_annotation              #在工作流中调用一个任务
  {
    input:                                    #定义所任务的输入
      Input_fq1 = fastq1,                     #将工作流的输入fastq1映射到任务的输入Input_fq1
      Input_fq2 = fastq2,
      Input_ID = phageID,
      Input_db = Anno_db
  }
  output                                                #定义工作流的输出        
  {
    File Assemble = phage_assemble_annotation.Assemble  #定义输出的文件类型和名称，phage_assemble_annotation.Assemble是上面定义的任务的输出，Assemble是该任务的输出
    File FAA = phage_assemble_annotation.FAA
    File FNA = phage_assemble_annotation.FNA
    File Annotation = phage_assemble_annotation.Annotation
    File GBK = phage_assemble_annotation.GBK
    File GFF = phage_assemble_annotation.GFF
  }
}

task phage_assemble_annotation                #定义一个任务
{
  input                                       #定义任务的输入
  {
    File Input_fq1                             #定义输入的文件类型和名称，Input_fq1是任务的输入
    File Input_fq2
    Array[File] Input_db
    String Input_ID
    String result_dir = Input_ID
    String FASTP = "/home/stereonote/software/miniforge3/envs/amita/bin/fastp"
    String SEQTK = "/home/stereonote/software/seqtk/bin/seqtk"
    String SEQKIT = "/home/stereonote/software/miniforge3/envs/amita/bin/seqkit"
    String SPADES = "/home/stereonote/software/miniforge3/envs/amita/bin/spades.py"
    String SELECT_6K = "/home/stereonote/script/select_up_6k.py"
    String QUAST = "/home/stereonote/software/quast-5.2.0/quast.py"
    String QUAST_PYTHON = "/home/stereonote/software/miniforge3/envs/amita/bin/python"
    String PRODIGAL = "/home/stereonote/software/miniforge3/envs/amita/bin/prodigal"
    String BLASTP = "/home/stereonote/software/miniforge3/envs/amita/bin/blastp"
    String PHMMER = "/home/stereonote/software/hmmer-3.4/bin/phmmer"
    String UNIREF_DB = "/jdfssz2/ST_BIGDATA/Stomics/warehouse/prd/ods/STOmics/ShenZhen_projectData/UserUpload/P17Z10200N0246/VIRP17Z10200N0246/1834243318442299394/lizhuoran1/1726153938709/uniref_phage.fasta"
    String UNIPROTKB_DB = "/jdfssz2/ST_BIGDATA/Stomics/warehouse/prd/ods/STOmics/ShenZhen_projectData/UserUpload/P17Z10200N0246/VIRP17Z10200N0246/1834243318442299394/lizhuoran1/1726153938709/uniprotkb_phage.fasta"
    String HMMSCAN = "/home/stereonote/software/hmmer-3.4/bin/hmmscan"
    String PFAM_PATH = "/jdfssz2/ST_BIGDATA/Stomics/warehouse/prd/ods/STOmics/ShenZhen_projectData/UserUpload/P17Z10200N0246/VIRP17Z10200N0246/1834243223496212481/lizhuoran1/1726192311575/Pfam-A.hmm"
    String HMMER_UNIQ = "/home/stereonote/script/hmmer_hit_uniq.py"
    String GET_RESULT_PY = "/home/stereonote/script/get_result.py"
    String RESULT2GFF = "/home/stereonote/script/result2gff_1.py"
    String SEQRET = "/home/stereonote/software/miniforge3/envs/amita/bin/seqret"
    String NR_PHAGE_DB = "/jdfssz2/ST_BIGDATA/Stomics/warehouse/prd/ods/STOmics/ShenZhen_projectData/UserUpload/P17Z10200N0246/VIRP17Z10200N0246/1834243318442299394/lizhuoran1/1726153204014/nr_phage.fasta"
    String TOOK_LONGEST = "/home/stereonote/script/took_longest.pl"
  }
  command                                     #定义任务的命令
  {
    mkdir -p ${result_dir}/01_fastp           #所有在任务的输入中定义的变量都需要用${}引用
    ${FASTP} -i ${Input_fq1} -o ${result_dir}/01_fastp/${Input_ID}_1.fq -I ${Input_fq2} -O ${result_dir}/01_fastp/${Input_ID}_2.fq -5 -3 -w 8 -q 20 -c -j ${result_dir}/01_fastp/fastp.json -h ${result_dir}/01_fastp/fastp.html -R ${result_dir}01_fastp/out.prefix -l 30

    mkdir -p ${result_dir}/02_sampling50x
    ${SEQTK}  sample -s 25   ${result_dir}/01_fastp/${phageID}_1.fq    25000 > ${result_dir}/02_sampling50x/seqtk_50xdata_v1_1.fq
    ${SEQTK}  sample -s 75   ${result_dir}/01_fastp/${phageID}_1.fq    25000 > ${result_dir}/02_sampling50x/seqtk_50xdata_v2_1.fq
    ${SEQTK}  sample -s 100  ${result_dir}/01_fastp/${phageID}_1.fq    25000 > ${result_dir}/02_sampling50x/seqtk_50xdata_v3_1.fq
    ${SEQTK}  sample -s 25   ${result_dir}/01_fastp/${phageID}_2.fq    25000 > ${result_dir}/02_sampling50x/seqtk_50xdata_v1_2.fq
    ${SEQTK}  sample -s 75   ${result_dir}/01_fastp/${phageID}_2.fq    25000 > ${result_dir}/02_sampling50x/seqtk_50xdata_v2_2.fq
    ${SEQTK}  sample -s 100  ${result_dir}/01_fastp/${phageID}_2.fq    25000 > ${result_dir}/02_sampling50x/seqtk_50xdata_v3_2.fq
    ${SEQKIT} sample -s 25   ${result_dir}/01_fastp/${phageID}_1.fq -n 25000 > ${result_dir}/02_sampling50x/seqkit_50xdata_v1_1.fq
    ${SEQKIT} sample -s 75   ${result_dir}/01_fastp/${phageID}_1.fq -n 25000 > ${result_dir}/02_sampling50x/seqkit_50xdata_v2_1.fq
    ${SEQKIT} sample -s 100  ${result_dir}/01_fastp/${phageID}_1.fq -n 25000 > ${result_dir}/02_sampling50x/seqkit_50xdata_v3_1.fq
    ${SEQKIT} sample -s 25   ${result_dir}/01_fastp/${phageID}_2.fq -n 25000 > ${result_dir}/02_sampling50x/seqkit_50xdata_v1_2.fq
    ${SEQKIT} sample -s 75   ${result_dir}/01_fastp/${phageID}_2.fq -n 25000 > ${result_dir}/02_sampling50x/seqkit_50xdata_v2_2.fq
    ${SEQKIT} sample -s 100  ${result_dir}/01_fastp/${phageID}_2.fq -n 25000 > ${result_dir}/02_sampling50x/seqkit_50xdata_v3_2.fq

    mkdir -p ${result_dir}/03_spades
    ${SPADES} -k 21,45,63 --careful -1 ${result_dir}/02_sampling50x/seqtk_50xdata_v1_1.fq -2 ${result_dir}/02_sampling50x/seqtk_50xdata_v1_2.fq -o ${result_dir}/03_spades/kmer_21_45_63/seqtk_v1 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} -k 21,45,63 --careful -1 ${result_dir}/02_sampling50x/seqtk_50xdata_v2_1.fq -2 ${result_dir}/02_sampling50x/seqtk_50xdata_v2_2.fq -o ${result_dir}/03_spades/kmer_21_45_63/seqtk_v2 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} -k 21,45,63 --careful -1 ${result_dir}/02_sampling50x/seqtk_50xdata_v3_1.fq -2 ${result_dir}/02_sampling50x/seqtk_50xdata_v3_2.fq -o ${result_dir}/03_spades/kmer_21_45_63/seqtk_v3 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} -k 21,45,63 --careful -1 ${result_dir}/02_sampling50x/seqkit_50xdata_v1_1.fq -2 ${result_dir}/02_sampling50x/seqkit_50xdata_v1_2.fq -o ${result_dir}/03_spades/kmer_21_45_63/seqkit_v1 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} -k 21,45,63 --careful -1 ${result_dir}/02_sampling50x/seqkit_50xdata_v2_1.fq -2 ${result_dir}/02_sampling50x/seqkit_50xdata_v2_2.fq -o ${result_dir}/03_spades/kmer_21_45_63/seqkit_v2 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} -k 21,45,63 --careful -1 ${result_dir}/02_sampling50x/seqkit_50xdata_v3_1.fq -2 ${result_dir}/02_sampling50x/seqkit_50xdata_v3_2.fq -o ${result_dir}/03_spades/kmer_21_45_63/seqkit_v3 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} -k 17,21 --careful -1 ${result_dir}/02_sampling50x/seqtk_50xdata_v1_1.fq -2 ${result_dir}/02_sampling50x/seqtk_50xdata_v1_2.fq -o ${result_dir}/03_spades/kmer_17_21/seqtk_v1 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} -k 17,21 --careful -1 ${result_dir}/02_sampling50x/seqtk_50xdata_v2_1.fq -2 ${result_dir}/02_sampling50x/seqtk_50xdata_v2_2.fq -o ${result_dir}/03_spades/kmer_17_21/seqtk_v2 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} -k 17,21 --careful -1 ${result_dir}/02_sampling50x/seqtk_50xdata_v3_1.fq -2 ${result_dir}/02_sampling50x/seqtk_50xdata_v3_2.fq -o ${result_dir}/03_spades/kmer_17_21/seqtk_v3 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} -k 17,21 --careful -1 ${result_dir}/02_sampling50x/seqkit_50xdata_v1_1.fq -2 ${result_dir}/02_sampling50x/seqkit_50xdata_v1_2.fq -o ${result_dir}/03_spades/kmer_17_21/seqkit_v1 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} -k 17,21 --careful -1 ${result_dir}/02_sampling50x/seqkit_50xdata_v2_1.fq -2 ${result_dir}/02_sampling50x/seqkit_50xdata_v2_2.fq -o ${result_dir}/03_spades/kmer_17_21/seqkit_v2 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} -k 17,21 --careful -1 ${result_dir}/02_sampling50x/seqkit_50xdata_v3_1.fq -2 ${result_dir}/02_sampling50x/seqkit_50xdata_v3_2.fq -o ${result_dir}/03_spades/kmer_17_21/seqkit_v3 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} --careful -1 ${result_dir}/02_sampling50x/seqtk_50xdata_v1_1.fq -2 ${result_dir}/02_sampling50x/seqtk_50xdata_v1_2.fq -o ${result_dir}/03_spades/auto/seqtk_v1 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} --careful -1 ${result_dir}/02_sampling50x/seqtk_50xdata_v2_1.fq -2 ${result_dir}/02_sampling50x/seqtk_50xdata_v2_2.fq -o ${result_dir}/03_spades/auto/seqtk_v2 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} --careful -1 ${result_dir}/02_sampling50x/seqtk_50xdata_v3_1.fq -2 ${result_dir}/02_sampling50x/seqtk_50xdata_v3_2.fq -o ${result_dir}/03_spades/auto/seqtk_v3 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} --careful -1 ${result_dir}/02_sampling50x/seqkit_50xdata_v1_1.fq -2 ${result_dir}/02_sampling50x/seqkit_50xdata_v1_2.fq -o ${result_dir}/03_spades/auto/seqkit_v1 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} --careful -1 ${result_dir}/02_sampling50x/seqkit_50xdata_v2_1.fq -2 ${result_dir}/02_sampling50x/seqkit_50xdata_v2_2.fq -o ${result_dir}/03_spades/auto/seqkit_v2 2>>${result_dir}/03_spades/r3.spades.err
    ${SPADES} --careful -1 ${result_dir}/02_sampling50x/seqkit_50xdata_v3_1.fq -2 ${result_dir}/02_sampling50x/seqkit_50xdata_v3_2.fq -o ${result_dir}/03_spades/auto/seqkit_v3 2>>${result_dir}/03_spades/r3.spades.err

    mkdir -p ${result_dir}/04_select_6k
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/kmer_21_45_63/seqtk_v1/scaffolds.fasta > ${result_dir}/04_select_6k/spades_21_45_63_seqtk_v1.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/kmer_21_45_63/seqtk_v2/scaffolds.fasta > ${result_dir}/04_select_6k/spades_21_45_63_seqtk_v2.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/kmer_21_45_63/seqtk_v3/scaffolds.fasta > ${result_dir}/04_select_6k/spades_21_45_63_seqtk_v3.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/kmer_21_45_63/seqkit_v1/scaffolds.fasta > ${result_dir}/04_select_6k/spades_21_45_63_seqkit_v1.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/kmer_21_45_63/seqkit_v2/scaffolds.fasta > ${result_dir}/04_select_6k/spades_21_45_63_seqkit_v2.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/kmer_21_45_63/seqkit_v3/scaffolds.fasta > ${result_dir}/04_select_6k/spades_21_45_63_seqkit_v3.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/kmer_17_21/seqtk_v1/scaffolds.fasta > ${result_dir}/04_select_6k/spades_17_21_seqtk_v1.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/kmer_17_21/seqtk_v2/scaffolds.fasta > ${result_dir}/04_select_6k/spades_17_21_seqtk_v2.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/kmer_17_21/seqtk_v3/scaffolds.fasta > ${result_dir}/04_select_6k/spades_17_21_seqtk_v3.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/kmer_17_21/seqkit_v1/scaffolds.fasta > ${result_dir}/04_select_6k/spades_17_21_seqkit_v1.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/kmer_17_21/seqkit_v2/scaffolds.fasta > ${result_dir}/04_select_6k/spades_17_21_seqkit_v2.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/kmer_17_21/seqkit_v3/scaffolds.fasta > ${result_dir}/04_select_6k/spades_17_21_seqkit_v3.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/auto/seqtk_v1/scaffolds.fasta > ${result_dir}/04_select_6k/spades_auto_seqtk_v1.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/auto/seqtk_v2/scaffolds.fasta > ${result_dir}/04_select_6k/spades_auto_seqtk_v2.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/auto/seqtk_v3/scaffolds.fasta > ${result_dir}/04_select_6k/spades_auto_seqtk_v3.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/auto/seqkit_v1/scaffolds.fasta > ${result_dir}/04_select_6k/spades_auto_seqkit_v1.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/auto/seqkit_v2/scaffolds.fasta > ${result_dir}/04_select_6k/spades_auto_seqkit_v2.fasta
    python ${SELECT_6K} -c 6000 -f ${result_dir}/03_spades/auto/seqkit_v3/scaffolds.fasta > ${result_dir}/04_select_6k/spades_auto_seqkit_v3.fasta
    cat ${result_dir}/04_select_6k/*fasta > ${result_dir}/04_select_6k/all_6k.fa
    perl ${TOOK_LONGEST} ${result_dir}/04_select_6k/all_6k.fa ${result_dir}/04_select_6k/final.fa 2>${result_dir}/04_select_6k/took_longest.err

    mkdir -p ${result_dir}/05_quast
    ${QUAST_PYTHON} ${QUAST} -o ${result_dir}/05_quast ${result_dir}/04_select_6k/final.fa 2>${result_dir}/05_quast/r5.quast.err

    mkdir -p ${result_dir}/06_prodigal
    ${PRODIGAL} -i ${result_dir}/04_select_6k/final.fa -o ${result_dir}/06_prodigal/${phageID}.gff -a ${result_dir}/06_prodigal/${phageID}.faa -d ${result_dir}/06_prodigal/${phageID}.fna -p meta -f gff -c 2>${result_dir}/06_prodigal/r6.prodigal.err

    mkdir -p ${result_dir}/07_blastp
    ${BLASTP} -query ${result_dir}/06_prodigal/${phageID}.faa -db ${NR_PHAGE_DB} -evalue 1e-5 -max_target_seqs 1 -num_threads 8 -out ${result_dir}/07_blastp/${phageID}.blastp.txt -outfmt "6 qseqid sseqid stitle pident length mismatch gapopen qstart qend sstart send evalue bitscore" 2>${result_dir}/07_blastp/r7.blastp.err
    
    mkdir -p ${result_dir}/08_phmmer
    ${PHMMER} -E 1e-5 -o ${result_dir}/08_phmmer/uniref.output.txt --cpu 8 --tblout ${result_dir}/08_phmmer/uniref.tblout.txt ${result_dir}/06_prodigal/${phageID}.faa ${UNIREF_DB}
    ${PHMMER} -E 1e-5 -o ${result_dir}/08_phmmer/uniprotkb.output.txt --cpu 8 --tblout ${result_dir}/08_phmmer/uniprotkb.tblout.txt ${result_dir}/06_prodigal/${phageID}.faa ${UNIPROTKB_DB}
    grep '#' -v ${result_dir}/08_phmmer/uniref.tblout.txt > ${result_dir}/08_phmmer/uniref.tblout.txt.hit
    grep '#' -v ${result_dir}/08_phmmer/uniprotkb.tblout.txt > ${result_dir}/08_phmmer/uniprotkb.tblout.txt.hit

    mkdir -p ${result_dir}/09_hmmscan
    ${HMMSCAN} -E 1e-5 -o ${result_dir}/09_hmmscan/pfam.output.txt --cpu 8 --tblout ${result_dir}/09_hmmscan/pfam.tblout.txt ${PFAM_PATH} ${result_dir}/06_prodigal/${phageID}.faa
    grep '#' -v ${result_dir}/09_hmmscan/pfam.tblout.txt > ${result_dir}/09_hmmscan/pfam.tblout.txt.hit

    mkdir -p ${result_dir}/10_annotation_result
    cat ${result_dir}/09_hmmscan/pfam.tblout.txt.hit ${result_dir}/08_phmmer/uniref.tblout.txt.hit ${result_dir}/08_phmmer/uniprotkb.tblout.txt.hit > ${result_dir}/10_annotation_result/hmm.hit
    ${HMMER_UNIQ} ${result_dir}/10_annotation_result/hmm.hit ${result_dir}/10_annotation_result/hmm.hit.uniq
    ${GET_RESULT_PY} ${result_dir}/07_blastp/${phageID}.blastp.txt ${result_dir}/10_annotation_result/hmm.hit.uniq ${result_dir}/10_annotation_result/${phageID}_annotation.txt

    source ~/.bashrc
    mamba activate amita
    mkdir -p ${result_dir}/11_gff2gbk
    ${RESULT2GFF} ${result_dir}/10_annotation_result/${phageID}_annotation.txt ${result_dir}/06_prodigal/${phageID}.gff ${result_dir}/11_gff2gbk/${phageID}_genome.annotation.gff
    ${SEQRET} -sequence ${result_dir}/04_select_6k/final.fa -feature -fformat gff -fopenfile ${result_dir}/11_gff2gbk/${phageID}_genome.annotation.gff -osformat genbank -outseq ${result_dir}/11_gff2gbk/${phageID}.gbk

    cp ${result_dir}/04_select_6k/final.fa ${result_dir}/${phageID}.fa
    cp ${result_dir}/11_gff2gbk/${phageID}.gbk ${result_dir}/${phageID}.gbk
    cp ${result_dir}/11_gff2gbk/${phageID}_genome.annotation.gff ${result_dir}/${phageID}.gff
    cp ${result_dir}/10_annotation_result/${phageID}_annotation.txt ${result_dir}/${phageID}_annotation.txt
    cp ${result_dir}/06_prodigal/${phageID}.faa ${result_dir}/${phageID}.faa
    cp ${result_dir}/06_prodigal/${phageID}.fna ${result_dir}/${phageID}.fna
  }
  output    #定义任务的输出
  {
    File Assemble = "${result_dir}/${phageID}.fa" 
    File FAA = "${result_dir}/${phageID}.faa"
    File FNA = "${result_dir}/${phageID}.fna"
    File Annotation = "${result_dir}/${phageID}_annotation.txt"
    File GBK = "${result_dir}/${phageID}.gbk"
    File GFF = "${result_dir}/${phageID}.gff"
  }
  runtime #定义任务的运行环境与参数
  {
    docker_url: "stereonote_hpc/lizhuoran1_048da0b2cf824d69843702386fa780d1_private:latest"
    req_cpu: 8
    req_memory: "20Gi"  #任务所需的内存，单位为Gi，书写时要注意
  }
}
