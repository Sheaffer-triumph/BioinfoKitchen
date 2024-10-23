version 1.0

workflow bacteria_assemble_annotation
{
  input
  {
    File FQ1
    File FQ2
    String SampleID
  }
  call bacx
  {
    input:
        Fastq1 = FQ1,
        Fastq2 = FQ2,
        ID = SampleID
  }
  output
  {
    File FA = bacx.FA
    File REPORT = bacx.REPORT
    Array[File] ANNO = bacx.ANNO
  }
}

task bacx
{
    input
    {
        File Fastq1
        File Fastq2
        String ID
        String result_dir = ID
        String FASTP = "/home/stereonote/software/miniforge3/envs/amita/bin/fastp"
        String SPADES = "/home/stereonote/software/miniforge3/envs/amita/bin/spades.py"
        String QUAST = "/home/stereonote/software/quast-5.2.0/quast.py"
        String QUAST_PYTHON = "/home/stereonote/software/miniforge3/envs/amita/bin/python"
        String PERL = "/home/stereonote/software/miniforge3/envs/amita/bin/perl"
        String PROKKA = "/home/stereonote/software/miniforge3/envs/amita/bin/prokka"
    }
    command
    {
        source ~/.bashrc
        mamba activate amita
        mkdir -p ${result_dir}

        mkdir -p ${result_dir}/01_fastp
        ${FASTP} -i ${Fastq1} -o ${result_dir}/01_fastp/${ID}_1.fq -I ${Fastq2} -O ${result_dir}/01_fastp/${ID}_2.fq -5 -3 -w 8 -q 20 -c -j ${result_dir}/01_fastp/fastp.json -h ${result_dir}/01_fastp/fastp.html -R ${result_dir}01_fastp/out.prefix -l 30
        
        mkdir -p ${result_dir}/02_spades
        ${SPADES} --careful -1 ${result_dir}/01_fastp/${ID}_1.fq -2 01_fastp/${ID}_2.fq -o ${result_dir}/02_spades 2>${result_dir}/02_spades/r2.spades.sh.err

        mkdir -p ${result_dir}/03_annotation
        ${PERL} ${PROKKA} --prefix ${ID} --locustag ${ID} --addgenes --addmrna --plasmid Plasmid --gcode 11 --outdir ${result_dir}/03_annotation --mincontiglen 100 ${result_dir}/02_spades/scaffolds.fasta  2>${result_dir}/03_annotation/r3.prokka.sh.err
    
        mkdir -p ${result_dir}/04_quast
        ${QUAST_PYTHON} ${QUAST} -o ${result_dir}/04_quast ${result_dir}/02_spades/scaffolds.fasta 2>${result_dir}/04_quast/r4.quast.sh.err

        cp ${result_dir}/02_spades/scaffolds.fasta ${result_dir}/${ID}.fasta
        cp ${result_dir}/04_quast/report.tsv ${result_dir}/${ID}_quast_report.tsv
    }
    output
    {
        File FA = "${result_dir}/${ID}.fasta"
        File REPORT = "${result_dir}/${ID}_quast_report.tsv"
        Array[File] ANNO = glob("${result_dir}/03_annotation/*")
    }
    runtime
    {
        docker_url: "stereonote_hpc/lizhuoran1_048da0b2cf824d69843702386fa780d1_private:latest"
        req_cpu: 16
        req_memory: "64Gi"
    }
}