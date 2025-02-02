#!/bin/bash
module load RSEM/1.3.1

rsem-calculate-expression --bam --no-bam-output -p 20 --paired-end  /liulab/jjyu/DB_bulkRNAseq/STAR_result/HC1Aligned.toTranscriptome.out.bam /liulab/jjyu/Reference/RSEM_ref/hg38_gencode_rsem /liulab/jjyu/DB_bulkRNAseq/RSEM_result/HC1 

rsem-calculate-expression --bam --no-bam-output -p 20 --paired-end  /liulab/jjyu/DB_bulkRNAseq/STAR_result/HC2Aligned.toTranscriptome.out.bam /liulab/jjyu/Reference/RSEM_ref/hg38_gencode_rsem /liulab/jjyu/DB_bulkRNAseq/RSEM_result/HC2

rsem-calculate-expression --bam --no-bam-output -p 20 --paired-end  /liulab/jjyu/DB_bulkRNAseq/STAR_result/HC3Aligned.toTranscriptome.out.bam /liulab/jjyu/Reference/RSEM_ref/hg38_gencode_rsem /liulab/jjyu/DB_bulkRNAseq/RSEM_result/HC3

rsem-calculate-expression --bam --no-bam-output -p 20 --paired-end  /liulab/jjyu/DB_bulkRNAseq/STAR_result/HC4Aligned.toTranscriptome.out.bam /liulab/jjyu/Reference/RSEM_ref/hg38_gencode_rsem /liulab/jjyu/DB_bulkRNAseq/RSEM_result/HC4

rsem-calculate-expression --bam --no-bam-output -p 20 --paired-end  /liulab/jjyu/DB_bulkRNAseq/STAR_result/HC5Aligned.toTranscriptome.out.bam /liulab/jjyu/Reference/RSEM_ref/hg38_gencode_rsem /liulab/jjyu/DB_bulkRNAseq/RSEM_result/HC5

rsem-calculate-expression --bam --no-bam-output -p 20 --paired-end  /liulab/jjyu/DB_bulkRNAseq/STAR_result/HC6Aligned.toTranscriptome.out.bam /liulab/jjyu/Reference/RSEM_ref/hg38_gencode_rsem /liulab/jjyu/DB_bulkRNAseq/RSEM_result/HC6 

rsem-calculate-expression --bam --no-bam-output -p 20 --paired-end  /liulab/jjyu/DB_bulkRNAseq/STAR_result/HC7Aligned.toTranscriptome.out.bam /liulab/jjyu/Reference/RSEM_ref/hg38_gencode_rsem /liulab/jjyu/DB_bulkRNAseq/RSEM_result/HC7
 
 rsem-calculate-expression --bam --no-bam-output -p 20 --paired-end  /liulab/jjyu/DB_bulkRNAseq/STAR_result/HC8Aligned.toTranscriptome.out.bam /liulab/jjyu/Reference/RSEM_ref/hg38_gencode_rsem /liulab/jjyu/DB_bulkRNAseq/RSEM_result/HC8
 
 rsem-calculate-expression --bam --no-bam-output -p 20 --paired-end  /liulab/jjyu/DB_bulkRNAseq/STAR_result/HC9Aligned.toTranscriptome.out.bam /liulab/jjyu/Reference/RSEM_ref/hg38_gencode_rsem /liulab/jjyu/DB_bulkRNAseq/RSEM_result/HC9
 
 
 rsem-calculate-expression --bam --no-bam-output -p 20 --paired-end  /liulab/jjyu/DB_bulkRNAseq/STAR_result/HC10Aligned.toTranscriptome.out.bam /liulab/jjyu/Reference/RSEM_ref/hg38_gencode_rsem /liulab/jjyu/DB_bulkRNAseq/RSEM_result/HC10