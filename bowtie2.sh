#用于病毒序列比对，在宏基因组中的流行性分析
mkdir 01_fastp
#
/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/hamburger/bin/parallel-fastq-dump --sra-id /zfssz7/pub/database/ftp.ncbi.nih.gov/sra/sra-instant/reads/ByStudy/sra/ERP/ERP013/ERP013562/ERR1190587/ERR1190587.sra --threads 4 -T 01_fastp --split-3 --gzip -O 01_fastp     #parallel-fastq-dump是fastq-dump的并行版本，速度更快
/hwfssz5/ST_HEALTH/P17Z10200N0246/USER/xingbo/software/miniconda_20211218/miniconda/bin/fastp -i 01_fastp/*_1.fastq.gz -o 01_fastp/ERR1190587_1.fq -I 01_fastp/*_2.fastq.gz -O 01_fastp/ERR1190587_2.fq -5 -3 -q 20 -c -j 01_fastp/fastp.json -h 01_fastp/fastp.html -R 01_fastp/out.prefix -l 30 1>01_fastp/fastp.result 2>r1.fastp.sh.err
/usr/bin/rm -rf 01_fastp/*_1.fastq.gz 01_fastp/*_2.fastq.gz     #删除原始数据，只保留清洗后的数据

mkdir 02_host
/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/hamburger/bin/bwa mem -t 4 /hwfssz5/ST_HEALTH/P17Z10200N0246/USER/xingbo/database_20221216/hg38/hg38.fa 01_fastp/ERR1190587_1.fq 01_fastp/ERR1190587_2.fq > 02_host/bwa.sam        #bwa mem是bwa的主要功能，用于比对, -t 4表示使用4个线程
/ldfssz1/ST_HEALTH/P17Z10200N0246/songwenchen/software/anconda2/bin/samtools view -b -f 4 02_host/bwa.sam > 02_host/bwa.bam     #samtools view是samtools的主要功能，用于格式转换，-b表示输出bam格式，-f 4表示过滤掉比对上的序列
/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/hamburger/bin/bamToFastq -i 02_host/bwa.bam -fq 02_host/rmhost_1.fastq -fq2 02_host/rmhost_2.fastq
rm 02_host/bwa.sam 01_fastp/ERR1190587_1.fq  01_fastp/ERR1190587_2.fq       #删除原始数据，只保留清洗后的数据

mkdir 03_bowtie2
/hwfssz5/ST_HEALTH/P17Z10200N0246/USER/xingbo/software/miniconda_20211218/miniconda/bin/bowtie2 -p 20 -x /ldfssz1/ST_HEALTH/P17Z10200N0246/xingbo/05.meta_phage/gutphage_abundance/gutphage_20230921_102/ref/ref.fa -1 02_host/rmhost_1.fastq -2 02_host/rmhost_2.fastq --very-sensitive | /ldfssz1/ST_HEALTH/P17Z10200N0246/songwenchen/software/anconda2/bin/samtools view -bS | /ldfssz1/ST_HEALTH/P17Z10200N0246/songwenchen/software/anconda2/bin/samtools sort -@ 20 -o 03_bowtie2/sorted_bowtie2.bam    #bowtie2是bowtie的主要功能，用于比对，-p 20表示使用20个线程，--very-sensitive表示使用最敏感的模式
tar -cvf - 02_host/rmhost_1.fastq | /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/hamburger/bin/pigz -p 4 > 02_host/rmhost_1.fastq.tar.gz    #tar -cvf - 表示将文件打包成tar格式，- 表示输出到标准输出，| 表示管道，将标准输出的内容传递给下一个命令，pigz -p 4表示使用4个线程进行压缩
/usr/bin/rm -rf 02_host/rmhost_1.fastq  
tar -cvf - 02_host/rmhost_2.fastq | /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/hamburger/bin/pigz -p 4 > 02_host/rmhost_2.fastq.tar.gz
/usr/bin/rm -rf 02_host/rmhost_2.fastq
/ldfssz1/ST_HEALTH/P17Z10200N0246/songwenchen/software/anconda2/bin/samtools view -b -F 4 03_bowtie2/sorted_bowtie2.bam > 03_bowtie2/mapped_bowtie2.bam    #-F 4表示过滤掉比对上的序列  
/ldfssz1/ST_HEALTH/P17Z10200N0246/songwenchen/software/anconda2/bin/samtools view -h 03_bowtie2/mapped_bowtie2.bam > 03_bowtie2/mapped_bowtie2.sam  #samtools view是samtools的主要功能，用于格式转换，-h表示输出sam格式
/hwfssz5/ST_HEALTH/P17Z10200N0246/USER/xingbo/software/miniconda_20211218/miniconda/envs/soapcoverage/bin/soap.coverage -cvg -sam -p 5 -i 03_bowtie2/mapped_bowtie2.sam -refsingle /ldfssz1/ST_HEALTH/P17Z10200N0246/xingbo/05.meta_phage/gutphage_abundance/gutphage_20230921_102/ref/ref.fa -o 03_bowtie2/coverage.txt #soap.coverage是soap的主要功能，用于计算覆盖度，-cvg表示计算覆盖度，-sam表示输入文件为sam格式，-p 5表示使用5个线程
/ldfssz1/ST_HEALTH/P17Z10200N0246/songwenchen/software/anconda2/bin/samtools index 03_bowtie2/mapped_bowtie2.bam    #samtools index是samtools的主要功能，用于索引，即生成bai文件
/ldfssz1/ST_HEALTH/P17Z10200N0246/songwenchen/software/anconda2/bin/samtools idxstats 03_bowtie2/mapped_bowtie2.bam > 03_bowtie2/mapped_bowtie2.bam.idxstats #samtools idxstats是samtools的主要功能，用于统计比对上的序列的信息





/ldfssz1/ST_META/share/User/zhujie/.conda/envs/bioenv/bin/fastq-dump /hwfssz1/pub/database/ftp.ncbi.nih.gov/sra/sra-instant/reads/ByStudy/sra/ERP/ERP016/ERP016813//ERR1578619/ERR1578619.sra --split-3 --gzip -O ERR1578619
/ldfssz1/ST_META/share/User/zhujie/.conda/envs/bioenv/bin/bowtie2 -p 20 -x /ldfssz1/ST_INFECTION/P17Z10200N0246_Phage_XMF/USER/xingbo/03.phage_anno/gut_phage/fa_20220916/fa/fa_20220916_89.fa -1 ERR1578619/*1.f*q.gz -2 ERR1578619/*2.f*q.gz --very-sensitive-local | /ldfssz1/ST_META/share/User/zhujie/.conda/envs/bioenv/bin/samtools view -bS -F 4 | /ldfssz1/ST_META/share/User/zhujie/.conda/envs/bioenv/bin/samtools sort -@ 20 -o ERR1578619/bowtie2.bam
/ldfssz1/ST_META/share/User/zhujie/.conda/envs/bioenv/bin/samtools view -h ERR1578619/bowtie2.bam > ERR1578619/bowtie2.sam
/jdfssz1/ST_HEALTH/P20Z10200N0206/fengqikai/software/Anaconda3-2021.05/envs/soapcoverage/2.7.7/bin/soap.coverage -cvg -sam -p 5 -i ERR1578619/bowtie2.sam -refsingle /ldfssz1/ST_INFECTION/P17Z10200N0246_Phage_XMF/USER/xingbo/03.phage_anno/gut_phage/fa_20220916/fa/fa_20220916_89.fa -o ERR1578619/coverage.txt
/ldfssz1/ST_META/share/User/zhujie/.conda/envs/bioenv/bin/samtools index ERR1578619/bowtie2.bam
/ldfssz1/ST_META/share/User/zhujie/.conda/envs/bioenv/bin/samtools stats ERR1578619/bowtie2.bam > ERR1578619/bowtie2.bam.stats
/ldfssz1/ST_META/share/User/zhujie/.conda/envs/bioenv/bin/samtools idxstats ERR1578619/bowtie2.bam > ERR1578619/bowtie2.bam.idxstats