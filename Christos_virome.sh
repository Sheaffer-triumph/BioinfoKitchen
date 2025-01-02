#MOHA宏基因组分析流程
set -e

#处理sra文件，fastp组装
/usr/bin/rm -rf 01_fastp
mkdir -p 01_fastp
/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/hamburger/bin/parallel-fastq-dump --sra-id ERR1620272.sra --threads 8 -T 01_fastp --split-3 --gzip -O 01_fastp
/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/amita/bin/fastp -i 01_fastp/ERR1620272_1.fastq.gz -o 01_fastp/ERR1620272_qc_1.fq.gz -I 01_fastp/ERR1620272_2.fastq.gz -O 01_fastp/ERR1620272_qc_2.fq.gz -5 -3 -z 9 -q 20 -c -j 01_fastp/fastp.json -h 01_fastp/fastp.html -R out.prefix -l 30
/usr/bin/rm -rf ERR1620272_1.fastq.gz ERR1620272_2.fastq.gz

#组装
/usr/bin/rm -rf 02_megahit
/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/amita/bin/megahit --presets meta-large -t 8 -1 01_fastp/ERR1620272_qc_1.fq.gz -2 01_fastp/ERR1620272_qc_2.fq.gz -o 02_megahit
/usr/bin/rm -rf 02_megahit/tmp 02_megahit/intermediate_contigs


export THEANO_FLAGS='base_compiledir=/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/gutvirome/ERP017091/ERR1620272,cxx=/usr/bin/g++'   #针对dvf所使用的theano环境变量
source ~/.mamba_init.sh

#DeepVirFinder病毒序列鉴定
mamba activate dvf
/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/dvf/bin/dvf -i /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/...fa -o /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/dvf_result -m /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/DeepVirFinder/models -l 1500 1>dvf.std 2>dvf.err
/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/dvf/bin/dvf.extract /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/dvf_result/*gt1500bp_dvfpred.txt /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/dvf_result/dvfpred.id
/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/hamburger/bin/seqkit grep -n -f /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/dvf_result/dvfpred.id /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/...fa > /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/dvf_result/...dvfpred.fa

#VirSorter2病毒序列鉴定
mamba activate virsorter2
/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/virsorter2/bin/virsorter run -w /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/vs2 -i /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/...fa --min-length 1500 -j 4 all 1>vs2.std 2>vs2.err

#GenoMAD病毒序列鉴定
mamba activate Genomad
genomad end-to-end --cleanup --splits 8 ERR1620272_filter10k.fa /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/gutvirome/ERP017091/ERR1620272/03_viralIdentify/genomad /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/Genomad/database/genomad_db

#vibrant
#mamba activate vibrant
#VIBRANT_run.py -i /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/...fa -t 8 -d /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/envs/vibrant/db -m /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/envs/vibrant/model

#dvf+vs2+vibrant去冗余
#cat vs2/final-viral-combined.fa dvf_result/dvfpred.fa VIBRANT/VIBRANT_phages/...phages_combined.fna >> /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/cat_dvf_vs2_vib.fa
#sed 's/||/ /g' /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/cat_dvf_vs2_vib.fa | awk '{print $1}' > comb_dvf_vs2_vib.awk.fa
#/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/hamburger/bin/seqkit rmdup -i /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/comb_dvf_vs2.fa > /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/comb_dvf_vs2_vib.awk.rmdup.fa

#CheckV
mamba activate checkv
/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/checkv/bin/checkv end_to_end /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/comb_dvf_vs2_vib.awk.rmdup.fa /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/MOHA/checkv -d /hwfssz5/ST_HEALTH/P17Z10200N0246/USER/xingbo/software/miniconda_20211218/miniconda/envs/checkv/checkv-db-v1.4 -t 8 1>checkv.std 2>checkv.err
cat checkv/quality* | grep -v 'no viral' | cut -f1 | sed '1d'
seqkit grep -n -f ./viral.id comb_dvf_vs2_vib.awk.rmdup.fa > comb_dvf_vs2_vib_awk_rmdup_checkv.fa

#去重复
cd-hit-est -i A.fa -o B.fa -c 0.95 -aL 0.9 -M 16000 -T 8

#vRhyme


#vcontact2
#mamba activate vContact2
#prodigal -i A.fa -a A.faa
#vcontact2_gene2genome -s Prodigal-FAA -p A.faa -o A.csv
#vcontact2 --rel-mode 'Diamond' --pcs-mode MCL --vcs-mode ClusterONE --c1-bin /hwfssz5/ST_HEALTH/P17Z10200N0246/USER/xingbo/software/cluster_one-1.0.jar --db 'ProkaryoticViralRefSeq211-Merged' --verbose --threads 4 --raw-proteins A.faa --proteins-fp A.csv --output-dir result
#sh cluster.sh

#iphop预测宿主
mamba activate iphop
iphop predict --fa_file all_sample_checkv_rmdup95.part_098.fa --db_dir /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/iphop/database/Sept_2021_pub --out_dir part_098 -t 8   #iphop预测宿主，如果输入文件过大，运行时间会很长，可以分片处理，然后合并结果