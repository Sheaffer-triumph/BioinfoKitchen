version 1.0

workflow meta_virome_analysis
{
    input
    {
        String srafile
        String SampleID
    }
    call Sra2Fastq
    {
        input:
            SampleID = SampleID
            Sra4Fq = srafile
    }
    call Qc_Assemble
    {
        input:
            SampleID = SampleID
            Fq1 = Sra2Fastq.Fastq1
            Fq2 = Sra2Fastq.Fastq2
    }
    call VirIdentify_Dvf
    {
        input:
            Fa4VirIdentify = Qc_Assemble.AssembleFasta
            SampleID = SampleID
    }
    call VirIdentify_Vs2
    {
        input:
            Fa4VirIdentify = Qc_Assemble.AssembleFasta
            SampleID = SampleID
    }
    call VirIdentify_Genomad
    {
        input:
            Fa4VirIdentify = Qc_Assemble.AssembleFasta
            SampleID = SampleID
    }
    call VirIdentify_Virbrant
    {
        input:
            Fa4VirIdentify = Qc_Assemble.AssembleFasta
            SampleID = SampleID
    }
    call CheckComplete
    {
        input:
            Dvf4CheckComplete = VirIdentify_Dvf.IdentifyVirus,
            Vs24CheckComplete = VirIdentify_Vs2.IdentifyVirus,
            Genomad4CheckComplete = VirIdentify_Genomad.IdentifyVirus,
            Virbrant4CheckComplete = VirIdentify_Virbrant.IdentifyVirus
            SampleID = SampleID
    }
    call VirusAbundance
    {
        input:
            CompleteVirus4Abundance = CheckComplete.CompleteVirus
            FQ14Abundance = QC_Assemble.QC_FQ1
            FQ24Abundance = QC_Assemble.QC_FQ2
            SampleID = SampleID
    }
    call VirusTaxonomy
    {
        input:
            Virus4Tax = CheckComplete.CompleteVirus
            SampleID = SampleID
    }
    output
    {
        Meta_assemble
    }
}

task Sra2Fastq
{
    input
    {
        String SRA4FQ
        String SampleID
    }
    command
    {
        source ~/.bashrc
        mamba activate amita
        mkdir -p ${SampleID}/01_fastp
        parallel-fastq-dump --sra-id ${sra4fq} --threads 16 -T ${SampleID}/01_fastp --split-3 --gzip -O ${SampleID}/01_fastp
    }
    output
    {
        File Fastq1 = "${SampleID}/01_fastp/${SampleID}_1.fastq.gz"
        File Fastq2 = "${SampleID}/01_fastp/${SampleID}_2.fastq.gz"
    }
    runtime
    {
        docker_url: ""
        req_cpu: 16
        req_memory: "32Gi"
    }
}

task QC_Assemble_filter10k
{
    input
    {
        String SampleID
        File Fq1
        File Fq2
    }
    command
    {
        source ~/.bashrc
        mamba activate amita
        fastp -i ${Fq1} -o ${SampleID}/01_fastp/${SampleID}_qc_1.fq -I ${Fq2} -O 01_fastp/${SampleID}_qc_2.fq -5 -3 -w 8 -q 20 -c -j 01_fastp/fastp.json -h 01_fastp/fastp.html -R out.prefix -l 30
        megahit --presets meta-large -t 32 -1 ${SampleID}/01_fastp/ERR1620272_qc_1.fq -2 ${SampleID}/01_fastp/ERR1620272_qc_2.fq -o ${SampleID}/02_megahit
        seqkit -m 10000 ${SampleID}/02_megahit/*fa > ${SampleID}/${SampleID}_megahit.fa
    }
    output
    {
        File AssembleFasta = "${SampleID}/${SampleID}_megahit.fa"
        File Qc_Fq1 = "${SampleID}/01_fastp/${SampleID}_qc_1.fq"
        File Qc_Fq2 = "${SampleID}/01_fastp/${SampleID}_qc_2.fq"
    }
    runtime
    {
        docker_url: ""
        req_cpu: 32
        req_memory: "64Gi"
    }
}

task VirIdentify_Dvf
{
    input
    {
        File FA4VirIdentify
        String SampleID
        String DvfModel = "/home/stereonote/DeepVirFinder/models"
    }
    command
    {
        source ~/.bashrc
        mamba activate dvf
        mkdir -p ${SampleID}/03_viralIdentify/dvf
        dvf -i ${Fa4VirIdentify} -o ${SampleID}/03_viralIdentify/dvf -m ${DvfModel} -l 1500 1>dvf.std 2>dvf.err
        dvf.extract ${SampleID}/03_viralIdentify/dvf/*gt1500bp_dvfpred.txt ${SampleID}/03_viralIdentify/dvf/dvfpred.id
        seqkit grep -n -f ${SampleID}/03_viralIdentify/dvf/dvfpred.id ${FA4VirIdentify} > ${SampleID}/03_viralIdentify/dvf/${SampleID}_dvf.fa
    }
    output
    {
        File IdentifyVirus = "${SampleID}/03_viralIdentify/dvf/${SampleID}_dvf.fa"
    }
    runtime
    {
        docker_url: ""
        req_cpu: 16
        req_memory: "64Gi"
    }
}

task VirIdentify_Vs2
{
    input
    {
        File Fa4VirIdentify
        String SampleID
        String Vs2DB
    }
    command
    {
        source ~/.bashrc
        mkdir -p ${SampleID}/03_viralIdentify/vs2
        virsorter run -w ${SampleID}/03_viralIdentify/vs2 -i ${FA4VirIdentify} --min-length 1500 -j 24 all --db-dir ${Vs2DB} 1>vs2.std 2>vs2.err
        mv ${SampleID}/03_viralIdentify/vs2/final-viral-combined.fa ${SampleID}/03_viralIdentify/vs2/${SampleID}_vs2.fa
    }
    output
    {
        File IdentifyVirus = "${SampleID}/03_viralIdentify/vs2/${SampleID}_vs2.fa"
    }
    runtime
    {
        docker_url: ""
        req_cpu: 24
        req_memory: "64Gi"
    }
}

task VirIdentify_Genomad
{
    input
    {
        File Fa4VirIdentify
        String SampleID
        String GenomadDB
    }
    command
    {
        source ~/.bashrc
        mkdir -p ${SampleID}/03_viralIdentify/genomad
        genomad end-to-end --cleanup --splits 8 ${Fa4VirIdentify} ${SampleID}/03_viralIdentify/genomad /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/Genomad/database/genomad_db
        mv ${SampleID}/03_viralIdentify/genomad/*summary/*virus.fna ${SampleID}/03_viralIdentify/genomad/${SampleID}_genomad.fa
    }
    output
    {
        File IdentifyVirus = "${SampleID}/03_viralIdentify/genomad/${SampleID}_genomad.fa"
    }
    runtime
    {
        docker_url: ""
        req_cpu: 24
        req_memory: "64Gi"
    }
}

task VirIdentify_Virbrant
{
    input
    {
        File FA4VirIdentify
        String SampleID
        String VirbrantDB
        String VirbrantModel
    }
    command
    {
        source ~/.bashrc
        mkdir -p ${SampleID}/03_viralIdentify/virbrant
        cd ${SampleID}/03_viralIdentify/virbrant
        python VIBRANT_run.py -i ${FA4VirIdentify} -t 16 -d ${VirbrantDB} -m ${VirbrantModel} 
        mv ${SampleID}/03_viralIdentify/virbrant/*phages*/*_combined.fna ${SampleID}/03_viralIdentify/virbrant/${SampleID}_virbrant.fa
    }
    output
    {
        File IdentifyVirus = "${SampleID}/03_viralIdentify/virbrant/${SampleID}_virbrant.fa"
    }
    runtime
    {
        docker_url: ""
        req_cpu: 16
        req_memory: "64Gi"
    }
}

task CheckComplete
{
    input
    {
        File Dvf4CheckComplete
        File Vs24CheckComplete
        File Genomad4CheckComplete
        File Virbrant4CheckComplete
        String SampleID
        String CheckvDB
    }
    command
    {
        source ~/.bashrc
        mamba activate amita
        mkdir -p ${SampleID}/04_checkComplete
        cat ${Dvf4CheckComplete} ${Vs24CheckComplete} ${Genomad4CheckComplete} ${Virbrant4CheckComplete} > ${SampleID}/04_checkComplete/${SampleID}_all.fa
        seqkit rmdup -i ${SampleID}/04_checkComplete/${SampleID}_all.fa > ${SampleID}/04_checkComplete/${SampleID}_completeVirus.fa
        checkv end_to_end ${SampleID}/04_checkvComplete/${SampleID}_completeVirus.fa ${SampleID}/04_checkvComplete -d ${CheckvDB} -t 16 1>checkv.std 2>checkv.err
        cat checkv/quality* | grep '' | cut -f1 | sed '1d' > 
        cd-hit-est -i A.fa -o B.fa -c 0.95 -aL 0.9 -M 16000 -T 8
    }
    output
    {
        File CompleteVirus = "${SampleID}/04_checkComplete/${SampleID}_completeVirus.fa"
    }
    runtime
    {
        docker_url: ""
        req_cpu: 16
        req_memory: "64Gi"
    }
}

task VirusAbundance
{
    input
    {
        File CompleteVirus4Abundance
        File FQ14Abundance
        File FQ24Abundance
        String SampleID
    }
    command
    {
        source ~/.bashrc
        mamba activate amita
        mkdir -p ${SampleID}/05_virusAbundance
        bwa index ${CompleteVirus4Abundance}
        bwa mem -t 16 ${CompleteVirus4Abundance} ${FQ14Abundance} ${FQ24Abundance} | samtools view -bS - | samtools sort -@ 16 -o ${SampleID}/05_virusAbundance/${SampleID}_virus.bam
        samtools index ${SampleID}/05_virusAbundance/${SampleID}_virus.bam
        samtools idxstats ${SampleID}/05_virusAbundance/${SampleID}_virus.bam > ${SampleID}/05_virusAbundance/${SampleID}_virus.idxstats
    }
    output
    {
        File VirusBAM = "${SampleID}/05_virusAbundance/${SampleID}_virus.bam"
        File VirusIDXSTATS = "${SampleID}/05_virusAbundance/${SampleID}_virus.idxstats"
    }
    runtime
    {
        docker_url: ""
        req_cpu: 16
        req_memory: "64Gi"
    }
}
