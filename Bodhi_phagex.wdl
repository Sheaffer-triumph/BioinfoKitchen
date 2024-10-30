version 1.0

workflow phagex_assemble_annotation_workflow  
{
  input                                       
  {
    File fastq1                               
    File fastq2
    String phageID
  }
  call phage_assemble_annotation              
  {
    input:                                    
      Input_fq1 = fastq1,                     
      Input_fq2 = fastq2,
      phageID = phageID
  }
  output                                                 
  {
    File Assemble = phage_assemble_annotation.Assemble  
    File FAA = phage_assemble_annotation.FAA
    File FNA = phage_assemble_annotation.FNA
    File Annotation = phage_assemble_annotation.Annotation
    File GBK = phage_assemble_annotation.GBK
    File GFF = phage_assemble_annotation.GFF
    File QUAST = phage_assemble_annotation.QUAST_REPORT
    File CHECKV = phage_assemble_annotation.CHECKV_REPORT
  }
}

task phage_assemble_annotation                
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
    String CHECKV = "/home/stereonote/software/miniforge3/envs/checkv/bin/checkv"
    String CHECKV_DB = "/data/input/Files/ReferenceData/checkv-db-v1.5"
  }
  command                                     
  <<<
    mkdir -p ${result_dir}/01_fastp           
    ${FASTP} -i ${Input_fq1} -o ${result_dir}/01_fastp/${Input_ID}_1.fq -I ${Input_fq2} -O ${result_dir}/01_fastp/${Input_ID}_2.fq -5 -3 -w 16 -q 20 -c -j ${result_dir}/01_fastp/fastp.json -h ${result_dir}/01_fastp/fastp.html -R ${result_dir}01_fastp/out.prefix -l 30

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

    ${SEQKIT} sort -lr ${result_dir}/04_select_6k/all_6k.fa > ${result_dir}/04_select_6k/all_6k_sort.fa

    source ~/.bashrc
    mamba activate checkv
    mkdir -p ${result_dir}/05_checkv
    ${CHECKV} ${result_dir}/04_select_6k/all_6k_sort.fa -t 16 -d ${CHECKV_DB} -o ${result_dir}/05_checkv 2>${result_dir}/05_checkv/r5.checkv.err
    cat ${result_dir}/05_checkv/quality_summary.tsv | grep -v "high kmer_freq may indicate large duplication" | head -n 2 > ${result_dir}/05_checkv/checkv.tsv
    cat ${result_dir}/05_checkv/quality_summary.tsv | sed '1d' | grep -v "high kmer_freq may indicate large duplication" | awk '{print $1}' > ${result_dir}/05_checkv/checkvid.txt
    ${SEQKIT} grep -n -f ${result_dir}/05_checkv/checkvid.txt ${result_dir}/04_select_6k/all_6k_sort.fa > ${result_dir}/04_select_6k/final.fa

    source ~/.bashrc
    mkdir -p ${result_dir}/06_quast
    ${QUAST_PYTHON} ${QUAST} -o ${result_dir}/06_quast ${result_dir}/04_select_6k/final.fa 2>${result_dir}/06_quast/r5.quast.err

    mkdir -p ${result_dir}/07_prodigal
    ${PRODIGAL} -i ${result_dir}/04_select_6k/final.fa -o ${result_dir}/07_prodigal/${phageID}.gff -a ${result_dir}/07_prodigal/${phageID}.faa -d ${result_dir}/07_prodigal/${phageID}.fna -p meta -f gff -c 2>${result_dir}/07_prodigal/r6.prodigal.err

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
    ${SEQRET} -sequence ${result_dir}/04_select_6k/final.fa -feature -fformat gff -fopenfile ${result_dir}/12_gff2gbk/${phageID}_genome.annotation.gff -osformat genbank -outseq ${result_dir}/12_gff2gbk/${phageID}.gbk

    cp ${result_dir}/04_select_6k/final.fa ${phageID}.fa
    cp ${result_dir}/12_gff2gbk/${phageID}.gbk ${phageID}.gbk
    cp ${result_dir}/12_gff2gbk/${phageID}_genome.annotation.gff ${phageID}.gff
    cp ${result_dir}/11_annotation_result/${phageID}_annotation.txt ${phageID}_annotation.txt
    cp ${result_dir}/07_prodigal/${phageID}.faa ${phageID}.faa
    cp ${result_dir}/07_prodigal/${phageID}.fna ${phageID}.fna
    cp ${result_dir}/06_quast/report.tsv ${phageID}_quast.tsv
    cp ${result_dir}/05_checkv/checkv.tsv ${phageID}_checkv.tsv
  >>>
  output    
  {
    File Assemble = "${phageID}.fa" 
    File FAA = "${phageID}.faa"
    File FNA = "${phageID}.fna"
    File Annotation = "${phageID}_annotation.txt"
    File GBK = "${phageID}.gbk"
    File GFF = "${phageID}.gff"
    File QUAST_REPORT = "${phageID}_quast.tsv"
    File CHECKV_REPORT = "${phageID}_checkv.tsv"
  }
  runtime 
  {
    docker_url: "stereonote_hpc/lizhuoran1_e8ac494ae0bd47a4b7b618bc24d7a70c_private:latest"
    req_cpu: 16
    req_memory: "20Gi"  
  }
}
