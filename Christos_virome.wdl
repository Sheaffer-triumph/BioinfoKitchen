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
            SampleID = SampleID,
            Sra4Fq = srafile
    }
    call Qc_Assemble
    {
        input:
            SampleID = SampleID,
            Fq1 = Sra2Fastq.Fastq1,
            Fq2 = Sra2Fastq.Fastq2
    }
    call VirIdentify_Dvf
    {
        input:
            Fa4VirIdentify = Qc_Assemble.AssembleFasta,
            SampleID = SampleID
    }
    call VirIdentify_Vs2
    {
        input:
            Fa4VirIdentify = Qc_Assemble.AssembleFasta,
            SampleID = SampleID
    }
    call VirIdentify_Genomad
    {
        input:
            Fa4VirIdentify = Qc_Assemble.AssembleFasta,
            SampleID = SampleID
    }
    call VirIdentify_Virbrant
    {
        input:
            Fa4VirIdentify = Qc_Assemble.AssembleFasta,
            SampleID = SampleID
    }
    call CheckComplete
    {
        input:
            Dvf4CheckComplete = VirIdentify_Dvf.IdentifyVirus,
            Vs24CheckComplete = VirIdentify_Vs2.IdentifyVirus,
            Genomad4CheckComplete = VirIdentify_Genomad.IdentifyVirus,
            Virbrant4CheckComplete = VirIdentify_Virbrant.IdentifyVirus,
            SampleID = SampleID
    }
    output
    {
        File IdentifyVirus = CheckComplete.IdentifyVirus
        File Checkv50Virus = CheckComplete.Checkv50Virus
    }
}

task Sra2Fastq
{
    input
    {
        String Sra4Fq
        String SampleID
    }
    command
    {
        source ~/.bashrc
        mamba activate amita
        mkdir -p ${SampleID}/01_fastp
        parallel-fastq-dump --sra-id ${Sra4Fq} --threads 16 -T ${SampleID}/01_fastp --split-3 --gzip -O ${SampleID}/01_fastp
    }
    output
    {
        File Fastq1 = "${SampleID}/01_fastp/${SampleID}_1.fastq.gz"
        File Fastq2 = "${SampleID}/01_fastp/${SampleID}_2.fastq.gz"
    }
    runtime
    {
        docker_url: "stereonote_hpc/lizhuoran1_939ad19c58c4427f9b64d04d7d547c62_private:latest"
        req_cpu: 16
        req_memory: "32Gi"
    }
}

task Qc_Assemble
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
        megahit --presets meta-large -t 32 -1 ${SampleID}/01_fastp/${SampleID}_qc_1.fq -2 ${SampleID}/01_fastp/${SampleID}_qc_2.fq -o ${SampleID}/02_megahit
        seqkit -m 10000 ${SampleID}/02_megahit/*fa > ${SampleID}/${SampleID}_megahit_filter10k.fa
        awkRename.sh ${SampleID}/${SampleID}_megahit_filter10k.fa ${SampleID}/${SampleID}_megahit_filter10k_rename.fa
    }
    output
    {
        File MegahitFasta = "${SampleID}/${SampleID}_megahit_filter10k_rename.fa"
        File Qc_Fq1 = "${SampleID}/01_fastp/${SampleID}_qc_1.fq"
        File Qc_Fq2 = "${SampleID}/01_fastp/${SampleID}_qc_2.fq"
    }
    runtime
    {
        docker_url: "stereonote_hpc/lizhuoran1_939ad19c58c4427f9b64d04d7d547c62_private:latest"
        req_cpu: 32
        req_memory: "64Gi"
    }
}

task VirIdentify_Dvf
{
    input
    {
        File Fa4VirIdentify
        String SampleID
        String DvfModel = "/home/stereonote/DeepVirFinder/models"
    }
    command
    {
        source ~/.bashrc
        mamba activate dvf
        mkdir -p ${SampleID}/03_viralIdentify/dvf
        cd ${SampleID}/03_viralIdentify/dvf
        dvf ${Fa4VirIdentify} ${SampleID}/03_viralIdentify/dvf ${DvfModel}
        dvf.extract ${SampleID}/03_viralIdentify/dvf/*gt1500bp_dvfpred.txt ${SampleID}/03_viralIdentify/dvf/dvfpred.id
        seqkit grep -n -f ${SampleID}/03_viralIdentify/dvf/dvfpred.id ${Fa4VirIdentify} > ${SampleID}/03_viralIdentify/dvf/${SampleID}_dvf.fa
    }
    output
    {
        File IdentifyVirus = "${SampleID}/03_viralIdentify/dvf/${SampleID}_dvf.fa"
    }
    runtime
    {
        docker_url: "stereonote_hpc/lizhuoran1_139df5ce450a4e18926c2f1c4dcbf0f2_private:latest"
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
        String Vs2DB = "/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/virsorter2/db"
    }
    command
    {
        source ~/.bashrc
        mamba activate vs2
        mkdir -p ${SampleID}/03_viralIdentify/vs2
        virsorter run -w ${SampleID}/03_viralIdentify/vs2 -i ${Fa4VirIdentify} --min-length 1500 -j 24 all --db-dir ${Vs2DB}
        mv ${SampleID}/03_viralIdentify/vs2/final-viral-combined.fa ${SampleID}/03_viralIdentify/vs2/${SampleID}_vs2.fa
    }
    output
    {
        File IdentifyVirus = "${SampleID}/03_viralIdentify/vs2/${SampleID}_vs2.fa"
    }
    runtime
    {
        docker_url: "stereonote_hpc/lizhuoran1_5767ecc0ef97499890cccfcc35048b83_private:latest"
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
    }
    command
    {
        source ~/.bashrc
        mamba activate genomad
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
        docker_url: "stereonote_hpc/lizhuoran1_1dcbbb41f98e4affbcdaaf1bb959199d_private:latest"
        req_cpu: 24
        req_memory: "64Gi"
    }
}

task VirIdentify_Virbrant
{
    input
    {
        File Fa4VirIdentify
        String SampleID
        String VibrantDB = "/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/vibrant/database"
        String VibrantModel = "/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/vibrant/modelfile"
    }
    command
    {
        source ~/.bashrc
        mamba activate vibrant
        mkdir -p ${SampleID}/03_viralIdentify/vibrant
        cd ${SampleID}/03_viralIdentify/vibrant
        VIBRANT_run.py -i ${Fa4VirIdentify} -t 16 -d ${VibrantDB} -m ${VibrantModel} 
        mv ${SampleID}/03_viralIdentify/vibrant/*phages*/*_combined.fna ${SampleID}/03_viralIdentify/vibrant/${SampleID}_vibrant.fa
    }
    output
    {
        File IdentifyVirus = "${SampleID}/03_viralIdentify/vibrant/${SampleID}_vibrant.fa"
    }
    runtime
    {
        docker_url: "stereonote_hpc/lizhuoran1_588ba0ee6fb2405c81ffd960c8503da3_private:latest"
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
    }
    command
    {
        source ~/.bashrc
        mamba activate checkv
        mkdir -p ${SampleID}/04_checkComplete
        cat ${Dvf4CheckComplete} ${Vs24CheckComplete} ${Genomad4CheckComplete} ${Virbrant4CheckComplete} > ${SampleID}/04_checkComplete/${SampleID}_all.fa
        seqkit rmdup -i ${SampleID}/04_checkComplete/${SampleID}_all.fa > ${SampleID}/04_checkComplete/${SampleID}_checkv.fa
        checkv end_to_end ${SampleID}/04_checkvComplete/${SampleID}_checkv.fa ${SampleID}/04_checkvComplete -d /ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/checkv/checkv-db-v1.5 -t 16 1>checkv.std 2>checkv.err
        checkv_filter 50 ${SampleID}/04_checkvComplete/quality_summary ${SampleID}/04_checkComplete/${SampleID}_checkv.fa ${SampleID}/04_checkComplete/${SampleID}_virus_checkv50.fa
    }
    output
    {
        File IdentifyVirus = "${SampleID}/04_checkComplete/${SampleID}_all.fa"
        File Checkv50Virus = "${SampleID}/04_checkComplete/${SampleID}_virus_checkv50.fa"
    }
    runtime
    {
        docker_url: "stereonote_hpc/lizhuoran1_1cdca4ba205f45dca41d8d22b3c0f8d8_private:latest"
        req_cpu: 16
        req_memory: "64Gi"
    }
}
