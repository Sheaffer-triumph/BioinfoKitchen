#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import subprocess
import argparse
import json
import logging
from datetime import datetime

# 设置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

def run_command(command, env=None, checkpoint_file=None):
    """运行命令并记录，如果命令失败则终止程序
    
    Args:
        command: 要执行的命令
        env: conda环境名称
        checkpoint_file: 执行成功后创建的检查点文件
    """
    logger.info(f"Execute command: {command}")
    
    if env:
        full_command = f"mamba run -n {env} {command}"
        process = subprocess.Popen(full_command, shell=True, executable="/bin/bash")
    else:
        process = subprocess.Popen(command, shell=True)
    
    process.wait()
    
    if process.returncode != 0:
        logger.error(f"Command execution failed: {command}")
        logger.error(f"Exit code: {process.returncode}")
        sys.exit(1)
    
    # 命令成功执行后创建检查点文件
    if checkpoint_file:
        with open(checkpoint_file, 'w') as f:
            f.write(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
        logger.info(f"Create a checkpoint: {checkpoint_file}")

def check_done(checkpoint_file, force_rerun=False):
    """检查步骤是否已完成
    
    Args:
        checkpoint_file: 检查点文件路径
        force_rerun: 是否强制重新运行
        
    Returns:
        bool: 如果步骤已完成且不需要重新运行则返回True，否则返回False
    """
    if force_rerun:
        return False
    
    if os.path.exists(checkpoint_file):
        with open(checkpoint_file, 'r') as f:
            timestamp = f.read().strip()
        logger.info(f"Skip completed steps (completed at {timestamp})")
        return True
    return False

def parse_args():
    """解析命令行参数"""
    parser = argparse.ArgumentParser(description='Phage assembly and annotation pipeline')
    parser.add_argument('-1', '--fq1', required=True, help='The first input fastq file')
    parser.add_argument('-2', '--fq2', required=True, help='The second input fastq file')
    parser.add_argument('-o', '--output', required=True, help='Output directory')
    parser.add_argument('-i', '--phage_id', required=True, help='Phage ID')
    parser.add_argument('-t', '--threads', type=int, default=16, help='Threads')
    #parser.add_argument('-c', '--config', required=True, help='Configuration file path')
    parser.add_argument('-c', '--config', required=False, help='Configuration file path, if not specified, the default configuration will be used')
    parser.add_argument('-f', '--force', action='store_true', help='Force rerun all steps')
    
    return parser.parse_args()

def load_config(config_file=None):
    """加载配置文件，如果未指定，则加载默认的phagex.json文件"""
    try:
        # 如果未提供配置文件，使用默认的phagex.json
        if config_file is None:
            # 首先查找当前目录
            if os.path.exists("phagex.json"):
                config_file = "phagex.json"
            # 然后查找脚本所在目录
            else:
                script_dir = os.path.dirname(os.path.abspath(__file__))
                config_file = os.path.join(script_dir, "phagex.json")
                
            logger.info(f"Using the default configuration file: {config_file}")
        
        # 检查配置文件是否存在
        if not os.path.exists(config_file):
            logger.error(f"Configuration file does not exist: {config_file}")
            sys.exit(1)
            
        with open(config_file, 'r') as f:
            return json.load(f)
    except Exception as e:
        logger.error(f"Failed to load configuration file: {e}")
        sys.exit(1)



def main():
    """主函数"""
    try:
        args = parse_args()
        config = load_config(args.config)
        
        # 输入参数
        Input_fq1 = args.fq1
        Input_fq2 = args.fq2
        result_dir = args.output
        phageID = args.phage_id
        threads = args.threads
        force_rerun = args.force
        
        # 检查点目录
        checkpoint_dir = os.path.join(result_dir, "checkpoints")
        os.makedirs(checkpoint_dir, exist_ok=True)
        
        # 检查输入文件是否存在
        if not os.path.exists(Input_fq1):
            logger.error(f"The input file does not exist: {Input_fq1}")
            sys.exit(1)
        if not os.path.exists(Input_fq2):
            logger.error(f"The input file does not exist: {Input_fq2}")
            sys.exit(1)
        
        # 确保结果目录存在
        os.makedirs(result_dir, exist_ok=True)
        
        # 步骤1: 使用fastp进行质控
        step1_done = os.path.join(checkpoint_dir, "01_fastp.done")
        if not check_done(step1_done, force_rerun):
            logger.info("Step 1: Perform quality control using fastp")
            os.makedirs(f"{result_dir}/01_fastp", exist_ok=True)
            
            fastp_cmd = (
                f"{config['FASTP']} -i {Input_fq1} -o {result_dir}/01_fastp/{phageID}_1.fq "
                f"-I {Input_fq2} -O {result_dir}/01_fastp/{phageID}_2.fq -5 -3 -w {threads} "
                f"-q 20 -c -j {result_dir}/01_fastp/fastp.json -h {result_dir}/01_fastp/fastp.html "
                f"-R {result_dir}/01_fastp/out.prefix -l 30"
            )
            run_command(fastp_cmd, checkpoint_file=step1_done)
        
        # 步骤2: 数据采样
        step2_done = os.path.join(checkpoint_dir, "02_sampling.done")
        if not check_done(step2_done, force_rerun):
            logger.info("Step 2: Data Sampling")
            os.makedirs(f"{result_dir}/02_sampling50x", exist_ok=True)
            
            # SEQTK采样
            for seed, ver in [(25, 'v1'), (75, 'v2'), (100, 'v3')]:
                for read_num in [1, 2]:
                    seqtk_cmd = (
                        f"{config['SEQTK']} sample -s {seed} {result_dir}/01_fastp/{phageID}_{read_num}.fq 25000 > {result_dir}/02_sampling50x/seqtk_50xdata_{ver}_{read_num}.fq"
                    )
                    run_command(seqtk_cmd)
            
            # SEQKIT采样
            for seed, ver in [(25, 'v1'), (75, 'v2'), (100, 'v3')]:
                for read_num in [1, 2]:
                    seqkit_cmd = (
                        f"{config['SEQKIT']} sample -s {seed} {result_dir}/01_fastp/{phageID}_{read_num}.fq -n 25000 -j {threads} > {result_dir}/02_sampling50x/seqkit_50xdata_{ver}_{read_num}.fq"
                    )
                    run_command(seqkit_cmd)
            
            run_command("echo 'Sampling completed'", checkpoint_file=step2_done)
        
        # 步骤3：SPAdes组装 (修改部分 - 同时运行--careful和--isolate)
        step3_done = os.path.join(checkpoint_dir, "03_spades.done")
        if not check_done(step3_done, force_rerun):
            logger.info("Step 3: SPAdes assembly (running both --careful and --isolate modes)")
            os.makedirs(f"{result_dir}/03_spades", exist_ok=True)
            os.makedirs(f"{result_dir}/03_spades/kmer_21_45_63", exist_ok=True)
            os.makedirs(f"{result_dir}/03_spades/kmer_17_21", exist_ok=True)
            os.makedirs(f"{result_dir}/03_spades/auto", exist_ok=True)
            
            # 使用不同kmer参数组装
            spades_configs = [
                {"kmer": "-k 21,45,63", "outdir": "kmer_21_45_63"},
                {"kmer": "-k 17,21", "outdir": "kmer_17_21"},
                {"kmer": "", "outdir": "auto"}
            ]
            
            # SPAdes运行模式：both careful and isolate
            spades_modes = ["careful", "isolate"]
            
            for s_config in spades_configs:
                for tool in ["seqtk", "seqkit"]:
                    for ver in ["v1", "v2", "v3"]:
                        for mode in spades_modes:
                            # 检查每个SPAdes组装任务是否已完成
                            spades_output = f"{result_dir}/03_spades/{s_config['outdir']}/{tool}_{ver}_{mode}/scaffolds.fasta"
                            
                            if not os.path.exists(spades_output) or force_rerun:
                                logger.info(f"Running SPAdes with --{mode} mode for {tool}_{ver}")
                                spades_cmd = (
                                    f"{config['SPADES']} {s_config['kmer']} --{mode} "
                                    f"-1 {result_dir}/02_sampling50x/{tool}_50xdata_{ver}_1.fq "
                                    f"-2 {result_dir}/02_sampling50x/{tool}_50xdata_{ver}_2.fq "
                                    f"-o {result_dir}/03_spades/{s_config['outdir']}/{tool}_{ver}_{mode} "
                                    f"2>>{result_dir}/03_spades/r3.spades.{mode}.err"
                                )
                                run_command(spades_cmd, env="amita")
                            else:
                                logger.info(f"Skip completed SPAdes assembly: {spades_output}")
            
            run_command("echo 'SPAdes assembly completed'", checkpoint_file=step3_done)
        
        # 步骤4：选择长度≥6kb的序列 (需要修改以适应新的目录结构)
        step4_done = os.path.join(checkpoint_dir, "04_select_6k.done")
        if not check_done(step4_done, force_rerun):
            logger.info("Step 4: Select sequences with a length ≥6 kb")
            os.makedirs(f"{result_dir}/04_select_6k", exist_ok=True)
            
            all_fasta_files = []
            
            for kmer in ["21_45_63", "17_21", "auto"]:
                for tool in ["seqtk", "seqkit"]:
                    for ver in ["v1", "v2", "v3"]:
                        for mode in ["careful", "isolate"]:
                            outfile = f"{result_dir}/04_select_6k/spades_{kmer}_{tool}_{ver}_{mode}.fasta"
                            all_fasta_files.append(outfile)
                            kmer_dir = f"kmer_{kmer}" if kmer != "auto" else "auto"
                            seqkit_cmd = (
                                f"{config['SEQKIT']} seq -m 6000 "
                                f"{result_dir}/03_spades/{kmer_dir}/{tool}_{ver}_{mode}/scaffolds.fasta > {outfile}"
                            )
                            run_command(seqkit_cmd)
            
            # 合并所有≥6kb的序列
            cat_cmd = f"cat {' '.join(all_fasta_files)} > {result_dir}/04_select_6k/all_6k.fa"
            run_command(cat_cmd)
            
            # 按长度排序
            sort_cmd = f"{config['SEQKIT']} sort -lr {result_dir}/04_select_6k/all_6k.fa > {result_dir}/04_select_6k/all_6k_sort.fa"
            run_command(sort_cmd, checkpoint_file=step4_done)
        
        # 步骤5：使用CheckV评估序列质量
        step5_done = os.path.join(checkpoint_dir, "05_checkv.done")
        if not check_done(step5_done, force_rerun):
            logger.info("Step 5: Use CheckV to evaluate sequence quality")
            os.makedirs(f"{result_dir}/05_checkv", exist_ok=True)
            
            checkv_cmd = (
                f"{config['CHECKV']} end_to_end {result_dir}/04_select_6k/all_6k_sort.fa "
                f"{result_dir}/05_checkv -t {threads} -d {config['CHECKVDB']}"
            )
            run_command(checkv_cmd, env="checkv")
            
            # 选择最佳结果
            best_id_cmd = (
                f"cat {result_dir}/05_checkv/quality_summary.tsv | sed '1d' | "
                f"grep -v \"high kmer_freq may indicate large duplication\" | "
                f"sort -k10,10nr -k2,2nr | head -n 1 | cut -f1 > {result_dir}/05_checkv/checkvid.txt"
            )
            run_command(best_id_cmd)
            
            # 提取最佳序列
            seqkit_grep_cmd = (
                f"{config['SEQKIT']} grep -n -f {result_dir}/05_checkv/checkvid.txt "
                f"{result_dir}/04_select_6k/all_6k_sort.fa > {result_dir}/final.fa"
            )
            run_command(seqkit_grep_cmd)
            
            # 复制结果文件
            run_command(f"cp {result_dir}/05_checkv/checkvid.txt {result_dir}/checkvid.txt")
            run_command(f"cp {result_dir}/05_checkv/quality_summary.tsv {result_dir}/all_quality_summary.tsv")
            
            # 替换序列ID
            rename_cmd = (
                f"cat {result_dir}/final.fa | head -n 1 | sed 's/>//g' | xargs -I @ "
                f"{config['SEQKIT']} replace -p \"@\" -r {phageID} {result_dir}/final.fa > {result_dir}/{phageID}.fa"
            )
            run_command(rename_cmd, checkpoint_file=step5_done)
        
        # 步骤6：重新运行CheckV
        step6_done = os.path.join(checkpoint_dir, "06_checkv_final.done")
        if not check_done(step6_done, force_rerun):
            logger.info("Step 6: Rerun CheckV on the final sequence")
            run_command(f"rm -rf {result_dir}/05_checkv")
            os.makedirs(f"{result_dir}/05_checkv", exist_ok=True)
            
            checkv_final_cmd = (
                f"{config['CHECKV']} end_to_end {result_dir}/{phageID}.fa {result_dir}/05_checkv "
                f"-t {threads} -d {config['CHECKVDB']}"
            )
            run_command(checkv_final_cmd, env="checkv")
            
            run_command(f"cp {result_dir}/05_checkv/quality_summary.tsv {result_dir}/{phageID}_quality_summary.tsv", 
                       checkpoint_file=step6_done)
        
        # 步骤7: QUAST评估
        step7_done = os.path.join(checkpoint_dir, "07_quast.done")
        if not check_done(step7_done, force_rerun):
            logger.info("Step 7: QUAST evaluates the assembly quality")
            os.makedirs(f"{result_dir}/06_quast", exist_ok=True)
            
            quast_cmd = (
                f"{config['QUAST_PYTHON']} {config['QUAST']} -o {result_dir}/06_quast "
                f"{result_dir}/{phageID}.fa 2>{result_dir}/06_quast/r5.quast.err"
            )
            run_command(quast_cmd, env="quast", checkpoint_file=step7_done)
        
        # 步骤8: Prodigal基因预测
        step8_done = os.path.join(checkpoint_dir, "08_prodigal.done")
        if not check_done(step8_done, force_rerun):
            logger.info("Step 8: Prodigal gene prediction")
            os.makedirs(f"{result_dir}/07_prodigal", exist_ok=True)
            
            prodigal_cmd = (
                f"{config['PRODIGAL']} -i {result_dir}/{phageID}.fa -o {result_dir}/07_prodigal/{phageID}.gff "
                f"-a {result_dir}/07_prodigal/{phageID}.faa -d {result_dir}/07_prodigal/{phageID}.fna "
                f"-p meta -f gff -c 2>{result_dir}/07_prodigal/r6.prodigal.err"
            )
            run_command(prodigal_cmd, checkpoint_file=step8_done)
        
        # 步骤9：BLASTP搜索
        step9_done = os.path.join(checkpoint_dir, "09_blastp.done")
        if not check_done(step9_done, force_rerun):
            logger.info("Step 9: BLASTP alignment annotation")
            os.makedirs(f"{result_dir}/08_blastp", exist_ok=True)
            
            blastp_cmd = (
                f"{config['BLASTP']} -query {result_dir}/07_prodigal/{phageID}.faa "
                f"-db {config['NR_PHAGE_DB']} -evalue 1e-5 -max_target_seqs 1 -num_threads {threads} "
                f"-out {result_dir}/08_blastp/{phageID}.blastp.txt "
                f"-outfmt \"6 qseqid sseqid stitle pident length mismatch gapopen qstart qend sstart send evalue bitscore\" "
                f"2>{result_dir}/08_blastp/r7.blastp.err"
            )
            run_command(blastp_cmd, env="checkv", checkpoint_file=step9_done)
        
        # 步骤10：PHMMER搜索
        step10_done = os.path.join(checkpoint_dir, "10_phmmer.done")
        if not check_done(step10_done, force_rerun):
            logger.info("Step 10: PHMMER alginment search")
            os.makedirs(f"{result_dir}/09_phmmer", exist_ok=True)
            
            # UniRef搜索
            phmmer_uniref_cmd = (
                f"{config['PHMMER']} -E 1e-5 -o {result_dir}/09_phmmer/uniref.output.txt "
                f"--cpu {threads} --tblout {result_dir}/09_phmmer/uniref.tblout.txt "
                f"{result_dir}/07_prodigal/{phageID}.faa {config['UNIREF_DB']}"
            )
            run_command(phmmer_uniref_cmd, env="checkv")
            
            # UniProtKB搜索
            phmmer_uniprotkb_cmd = (
                f"{config['PHMMER']} -E 1e-5 -o {result_dir}/09_phmmer/uniprotkb.output.txt "
                f"--cpu {threads} --tblout {result_dir}/09_phmmer/uniprotkb.tblout.txt "
                f"{result_dir}/07_prodigal/{phageID}.faa {config['UNIPROTKB_DB']}"
            )
            run_command(phmmer_uniprotkb_cmd, env="checkv")
            
            # 提取结果
            run_command(f"grep '#' -v {result_dir}/09_phmmer/uniref.tblout.txt > {result_dir}/09_phmmer/uniref.tblout.txt.hit")
            run_command(f"grep '#' -v {result_dir}/09_phmmer/uniprotkb.tblout.txt > {result_dir}/09_phmmer/uniprotkb.tblout.txt.hit", 
                      checkpoint_file=step10_done)
        
        # 步骤11：HMMSCAN搜索
        step11_done = os.path.join(checkpoint_dir, "11_hmmscan.done")
        if not check_done(step11_done, force_rerun):
            logger.info("Step 11: HMMSCAN alginment search")
            os.makedirs(f"{result_dir}/10_hmmscan", exist_ok=True)
            
            hmmscan_cmd = (
                f"{config['HMMSCAN']} -E 1e-5 -o {result_dir}/10_hmmscan/pfam.output.txt "
                f"--cpu {threads} --tblout {result_dir}/10_hmmscan/pfam.tblout.txt "
                f"{config['PFAM_PATH']} {result_dir}/07_prodigal/{phageID}.faa"
            )
            run_command(hmmscan_cmd, env="checkv")
            
            run_command(f"grep '#' -v {result_dir}/10_hmmscan/pfam.tblout.txt > {result_dir}/10_hmmscan/pfam.tblout.txt.hit", 
                      checkpoint_file=step11_done)
        
        # 步骤12：整合注释结果
        step12_done = os.path.join(checkpoint_dir, "12_annotation.done")
        if not check_done(step12_done, force_rerun):
            logger.info("Step 12: Integrate annotation results")
            os.makedirs(f"{result_dir}/11_annotation_result", exist_ok=True)
            
            # 合并hmm结果
            run_command(
                f"cat {result_dir}/10_hmmscan/pfam.tblout.txt.hit "
                f"{result_dir}/09_phmmer/uniref.tblout.txt.hit "
                f"{result_dir}/09_phmmer/uniprotkb.tblout.txt.hit > {result_dir}/11_annotation_result/hmm.hit"
            )
            
            # 去重
            run_command(f"{config['HMMER_UNIQ']} {result_dir}/11_annotation_result/hmm.hit {result_dir}/11_annotation_result/hmm.hit.uniq")
            
            # 获取最终注释结果
            run_command(
                f"{config['GET_RESULT_PY']} {result_dir}/08_blastp/{phageID}.blastp.txt "
                f"{result_dir}/11_annotation_result/hmm.hit.uniq {result_dir}/11_annotation_result/{phageID}_annotation.txt",
                checkpoint_file=step12_done
            )
        
        # 步骤13：GFF到GenBank转换
        step13_done = os.path.join(checkpoint_dir, "13_gff2gbk.done")
        if not check_done(step13_done, force_rerun):
            logger.info("Step 13: GFF to GenBank Conversion")
            os.makedirs(f"{result_dir}/12_gff2gbk", exist_ok=True)
            
            # 生成注释GFF
            run_command(
                f"{config['RESULT2GFF']} {result_dir}/11_annotation_result/{phageID}_annotation.txt "
                f"{result_dir}/07_prodigal/{phageID}.gff {result_dir}/12_gff2gbk/{phageID}_genome.annotation.gff"
            )
            
            # 转换为GenBank格式
            seqret_cmd = (
                f"{config['SEQRET']} -sequence {result_dir}/{phageID}.fa -feature -fformat gff "
                f"-fopenfile {result_dir}/12_gff2gbk/{phageID}_genome.annotation.gff "
                f"-osformat genbank -outseq {result_dir}/12_gff2gbk/{phageID}.gbk"
            )
            run_command(seqret_cmd, env="amita", checkpoint_file=step13_done)
        
        # 步骤14：复制最终结果
        step14_done = os.path.join(checkpoint_dir, "14_final_copy.done")
        if not check_done(step14_done, force_rerun):
            logger.info("Step 14: Copy the final result file")
            result_files = [
                (f"{result_dir}/12_gff2gbk/{phageID}.gbk", f"{result_dir}/{phageID}.gbk"),
                (f"{result_dir}/12_gff2gbk/{phageID}_genome.annotation.gff", f"{result_dir}/{phageID}.gff"),
                (f"{result_dir}/11_annotation_result/{phageID}_annotation.txt", f"{result_dir}/{phageID}_annotation.txt"),
                (f"{result_dir}/07_prodigal/{phageID}.faa", f"{result_dir}/{phageID}.faa"),
                (f"{result_dir}/07_prodigal/{phageID}.fna", f"{result_dir}/{phageID}.fna"),
                (f"{result_dir}/06_quast/report.tsv", f"{result_dir}/{phageID}_quast.tsv")
            ]
            
            for src, dst in result_files:
                run_command(f"cp {src} {dst}")
            
            run_command("echo 'Final file copying completed'", checkpoint_file=step14_done)
        
        logger.info("Phage assembly and annotation process completed!")
        
    except Exception as e:
        logger.error(f"An error occurred during program execution: {e}")
        sys.exit(1)

if __name__ == "__main__":
    start_time = datetime.now()
    logger.info(f"Start running: {start_time}")
    main()
    end_time = datetime.now()
    logger.info(f"Execution completed: {end_time}")
    logger.info(f"Total runtime: {end_time - start_time}")
