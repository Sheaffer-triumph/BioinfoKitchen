version 1.0

workflow phagex_assemble_annotation_workflow
{
  input
  {
    File fastq1
    File fastq2
    String phageID
  }
  call Assemble
  {
    input:
      phageID = phageID,
      Input_fq1 = fastq1,
      Input_fq2 = fastq2
  }
  call Checkv
  {
    input:
      phageID = phageID,
      FASTA = Assemble.FASTA
  }
  call Annotation
  {
    input:
      phageID = phageID,
      PhageFasta = Checkv.PhageFasta
  }
  output
  {
    File PhageFasta = Checkv.PhageFasta
    File PhageQuality = Checkv.PhageQualitySummary
    File AssembleQuality = Checkv.AllQualitySummary
    File GenomeFAA = Annotation.FAA
    File GenomeFNA = Annotation.FNA
    File GenmoeAnnotation = Annotation.Annotation
    File GBK = Annotation.GBK
    File GFF = Annotation.GFF
    File GenomeQuast = Annotation.QuastReport
  }
}

task Assemble
{
  input
  {
    File Input_fq1
    File Input_fq2
    String phageID
    String result_dir = phageID
    String FASTP = "/home/stereonote/software/miniforge3/envs/amita/bin/fastp"
    String SEQTK = "/home/stereonote/software/seqtk/bin/seqtk"
    String SEQKIT = "/home/stereonote/software/miniforge3/envs/amita/bin/seqkit"
    String SPADES = "/home/stereonote/software/miniforge3/envs/amita/bin/spades.py"
  }
  command
  {
    mkdir -p ${result_dir}/01_fastp
    ${FASTP} -i ${Input_fq1} -o ${result_dir}/01_fastp/${phageID}_1.fq -I ${Input_fq2} -O ${result_dir}/01_fastp/${phageID}_2.fq -5 -3 -w 16 -q 20 -c -j ${result_dir}/01_fastp/fastp.json -h ${result_dir}/01_fastp/fastp.html -R ${result_dir}01_fastp/out.prefix -l 30

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
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/kmer_21_45_63/seqtk_v1/scaffolds.fasta > ${result_dir}/04_select_6k/spades_21_45_63_seqtk_v1.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/kmer_21_45_63/seqtk_v2/scaffolds.fasta > ${result_dir}/04_select_6k/spades_21_45_63_seqtk_v2.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/kmer_21_45_63/seqtk_v3/scaffolds.fasta > ${result_dir}/04_select_6k/spades_21_45_63_seqtk_v3.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/kmer_21_45_63/seqkit_v1/scaffolds.fasta > ${result_dir}/04_select_6k/spades_21_45_63_seqkit_v1.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/kmer_21_45_63/seqkit_v2/scaffolds.fasta > ${result_dir}/04_select_6k/spades_21_45_63_seqkit_v2.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/kmer_21_45_63/seqkit_v3/scaffolds.fasta > ${result_dir}/04_select_6k/spades_21_45_63_seqkit_v3.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/kmer_17_21/seqtk_v1/scaffolds.fasta > ${result_dir}/04_select_6k/spades_17_21_seqtk_v1.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/kmer_17_21/seqtk_v2/scaffolds.fasta > ${result_dir}/04_select_6k/spades_17_21_seqtk_v2.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/kmer_17_21/seqtk_v3/scaffolds.fasta > ${result_dir}/04_select_6k/spades_17_21_seqtk_v3.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/kmer_17_21/seqkit_v1/scaffolds.fasta > ${result_dir}/04_select_6k/spades_17_21_seqkit_v1.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/kmer_17_21/seqkit_v2/scaffolds.fasta > ${result_dir}/04_select_6k/spades_17_21_seqkit_v2.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/kmer_17_21/seqkit_v3/scaffolds.fasta > ${result_dir}/04_select_6k/spades_17_21_seqkit_v3.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/auto/seqtk_v1/scaffolds.fasta > ${result_dir}/04_select_6k/spades_auto_seqtk_v1.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/auto/seqtk_v2/scaffolds.fasta > ${result_dir}/04_select_6k/spades_auto_seqtk_v2.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/auto/seqtk_v3/scaffolds.fasta > ${result_dir}/04_select_6k/spades_auto_seqtk_v3.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/auto/seqkit_v1/scaffolds.fasta > ${result_dir}/04_select_6k/spades_auto_seqkit_v1.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/auto/seqkit_v2/scaffolds.fasta > ${result_dir}/04_select_6k/spades_auto_seqkit_v2.fasta
    ${SEQKIT} seq -m 6000 ${result_dir}/03_spades/auto/seqkit_v3/scaffolds.fasta > ${result_dir}/04_select_6k/spades_auto_seqkit_v3.fasta
    cat ${result_dir}/04_select_6k/*fasta > ${result_dir}/04_select_6k/all_6k.fa

    ${SEQKIT} sort -lr ${result_dir}/04_select_6k/all_6k.fa > ${result_dir}/04_select_6k/all_6k_sort.fa
  }
  output    
  {
    File FASTA = "${result_dir}/04_select_6k/all_6k_sort.fa"
  }
  runtime 
  {
    docker_url: "stereonote_hpc/lizhuoran1_e8ac494ae0bd47a4b7b618bc24d7a70c_private:latest"
    req_cpu: 16
    req_memory: "20Gi"  
  }
}

task Checkv
{
  input
  {
    String phageID
    File FASTA
    String result_dir = phageID
    String CheckvDB = "/ldfssz1/ST_HEALTH/P17Z10200N0246/lizhuoran1/software/miniconda/envs/checkv/checkv-db-v1.5"
    String CHECKV = "/home/stereonote/software/miniforge3/envs/checkv/bin/checkv"
    String SEQKIT = "/home/stereonote/software/miniforge3/envs/checkv/bin/seqkit"
  }
  command
  {
    source ~/.bashrc
    mamba activate checkv
    mkdir -p ${result_dir}/05_checkv
    ${CHECKV} end_to_end ${FA} ${result_dir}/05_checkv -t 16 -d ${CHECKV_DB}
    cat ${result_dir}/05_checkv/quality_summary.tsv | sed '1d' | grep -v "high kmer_freq may indicate large duplication" | sort -k10,10nr -k2,2nr | head -n 1 | cut -f1  > ${result_dir}/05_checkv/checkvid.txt
    ${SEQKIT} grep -n -f ${result_dir}/05_checkv/checkvid.txt ${FA} > final.fa
    cp ${result_dir}/05_checkv/checkvid.txt checkvid.txt
    cp ${result_dir}/05_checkv/quality_summary.tsv all_quality_summary.tsv
    cat final.fa | head -n 1 | sed 's/>//g' | xargs -I @ ${SEQKIT} replace -p "@" -r ${phageID} final.fa > ${phageID}.fa
    rm -rf ${result_dir}/05_checkv
    mkdir -p ${result_dir}/05_checkv
    ${CHECKV} end_to_end ${phageID}.fa ${result_dir}/05_checkv -t 16 -d ${CHECKV_DB}
    cp ${result_dir}/05_checkv/quality_summary.tsv ${phageID}_quality_summary.tsv
  }
  output
  {
    File AllQualitySummary = "all_quality_summary.tsv"
    File PhageFasta = "${phageID.fa}"
    File PhageQualitySummary = "${phageID}_quality_summary.tsv"
  }
  runtime
  {
    docker_url: "stereonote_hpc/lizhuoran1_2ec9c04904f44c998400536f107c6f32_private:latest"
    req_cpu: 16
    req_memory: "20Gi"
  }
}

task Annotation
{
  input
  {
    String phageID
    File PhageFasta
    String result_dir = phageID
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
  }
}
  command
  {
    source ~/.bashrc
    mkdir -p ${result_dir}/06_quast
    ${QUAST_PYTHON} ${QUAST} -o ${result_dir}/06_quast ${result_dir}/04_select_6k/${phageID}.fa 2>${result_dir}/06_quast/r5.quast.err

    mkdir -p ${result_dir}/07_prodigal
    ${PRODIGAL} -i ${result_dir}/04_select_6k/${phageID}.fa -o ${result_dir}/07_prodigal/${phageID}.gff -a ${result_dir}/07_prodigal/${phageID}.faa -d ${result_dir}/07_prodigal/${phageID}.fna -p meta -f gff -c 2>${result_dir}/07_prodigal/r6.prodigal.err

    mkdir -p ${result_dir}/08_blastp
    ${BLASTP} -query ${result_dir}/07_prodigal/${phageID}.faa -db ${NR_PHAGE_DB} -evalue 1e-5 -max_target_seqs 1 -num_threads 16 -out ${result_dir}/08_blastp/${phageID}.blastp.txt -outfmt "6 qseqid sseqid stitle pident length mismatch gapopen qstart qend sstart send evalue bitscore" 2>${result_dir}/08_blastp/r7.blastp.err
    
    mkdir -p ${result_dir}/09_phmmer
    ${PHMMER} -E 1e-5 -o ${result_dir}/09_phmmer/uniref.output.txt --cpu 16 --tblout ${result_dir}/09_phmmer/uniref.tblout.txt ${result_dir}/07_prodigal/${phageID}.faa ${UNIREF_DB}
    ${PHMMER} -E 1e-5 -o ${result_dir}/09_phmmer/uniprotkb.output.txt --cpu 16 --tblout ${result_dir}/09_phmmer/uniprotkb.tblout.txt ${result_dir}/07_prodigal/${phageID}.faa ${UNIPROTKB_DB}
    grep '#' -v ${result_dir}/09_phmmer/uniref.tblout.txt > ${result_dir}/09_phmmer/uniref.tblout.txt.hit
    grep '#' -v ${result_dir}/09_phmmer/uniprotkb.tblout.txt > ${result_dir}/09_phmmer/uniprotkb.tblout.txt.hit

    mkdir -p ${result_dir}/10_hmmscan
    ${HMMSCAN} -E 1e-5 -o ${result_dir}/10_hmmscan/pfam.output.txt --cpu 16 --tblout ${result_dir}/10_hmmscan/pfam.tblout.txt ${PFAM_PATH} ${result_dir}/07_prodigal/${phageID}.faa
    grep '#' -v ${result_dir}/10_hmmscan/pfam.tblout.txt > ${result_dir}/10_hmmscan/pfam.tblout.txt.hit

    mkdir -p ${result_dir}/11_annotation_result
    cat ${result_dir}/10_hmmscan/pfam.tblout.txt.hit ${result_dir}/09_phmmer/uniref.tblout.txt.hit ${result_dir}/09_phmmer/uniprotkb.tblout.txt.hit > ${result_dir}/11_annotation_result/hmm.hit
    ${HMMER_UNIQ} ${result_dir}/11_annotation_result/hmm.hit ${result_dir}/11_annotation_result/hmm.hit.uniq
    ${GET_RESULT_PY} ${result_dir}/08_blastp/${phageID}.blastp.txt ${result_dir}/11_annotation_result/hmm.hit.uniq ${result_dir}/11_annotation_result/${phageID}_annotation.txt

    source ~/.bashrc
    mamba activate amita
    mkdir -p ${result_dir}/12_gff2gbk
    ${RESULT2GFF} ${result_dir}/11_annotation_result/${phageID}_annotation.txt ${result_dir}/07_prodigal/${phageID}.gff ${result_dir}/12_gff2gbk/${phageID}_genome.annotation.gff
    ${SEQRET} -sequence ${result_dir}/04_select_6k/${phageID}.fa -feature -fformat gff -fopenfile ${result_dir}/12_gff2gbk/${phageID}_genome.annotation.gff -osformat genbank -outseq ${result_dir}/12_gff2gbk/${phageID}.gbk

    
    cp ${result_dir}/04_select_6k/${phageID}.fa ${phageID}.fa
    cp ${result_dir}/12_gff2gbk/${phageID}.gbk ${phageID}.gbk
    cp ${result_dir}/12_gff2gbk/${phageID}_genome.annotation.gff ${phageID}.gff
    cp ${result_dir}/11_annotation_result/${phageID}_annotation.txt ${phageID}_annotation.txt
    cp ${result_dir}/07_prodigal/${phageID}.faa ${phageID}.faa
    cp ${result_dir}/07_prodigal/${phageID}.fna ${phageID}.fna
    cp ${result_dir}/06_quast/report.tsv ${phageID}_quast.tsv
  }
  output    
  {
    File FAA = "${phageID}.faa"
    File FNA = "${phageID}.fna"
    File Annotation = "${phageID}_annotation.txt"
    File GBK = "${phageID}.gbk"
    File GFF = "${phageID}.gff"
    File QuastReport = "${phageID}_quast.tsv"
  }
  runtime 
  {
    docker_url: "stereonote_hpc/lizhuoran1_e8ac494ae0bd47a4b7b618bc24d7a70c_private:latest"
    req_cpu: 16
    req_memory: "20Gi"  
  }
}
