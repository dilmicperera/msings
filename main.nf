#!/usr/bin/env nextflow
import java.nio.file.Paths

// Folder with *.bam and *.bai files
bam_folder="$params.input_bucket/$params.run_folder_id"
output_folder="$params.output_bucket/$params.output_folder"

// Read in genome files
genome_fa = file(params.genome_fa)
genome_fa_fai = file(params.genome_fa_fai)


// Read in bam/bai files
tumour_bam = file("$bam_folder/$params.tumour_bam/results/$params.tumour_bam*.sam_filtered-sorted.bam")[0]
tumour_bai = file("$bam_folder/$params.tumour_bam/results/$params.tumour_bam*.sam_filtered-sorted.bam.bai")[0]



/**************
** mSINGS **
***************/


process run_msings{
    publishDir output_folder, mode: 'copy'
    
    container '677424885543.dkr.ecr.ca-central-1.amazonaws.com/samtools:latest'
    disk '50 GB'
    memory = 30.GB
    cpus = 8
    input:
        file tumour_bam
        file tumour_bai
        file genome_fa
        file genome_fa_fai
    output:
        file "*.tar.gz"

    """
    echo $tumour_bam > path_to_bams
    scripts/run_msings2.sh path_to_bams msings/doc/mSINGS_TCGA.bed msings/doc/mSINGS_TCGA.baseline ${genome_fa}
    mkdir ${params.sample}
    mv *.txt > ${params.sample}
    tar cvzf ${params.sample}.tar.gz ${params.sample}
    """
}
