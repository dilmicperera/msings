#!/usr/bin/env nextflow
import java.nio.file.Paths

// Folder with *.bam and *.bai files
bam_folder="$params.input_bucket/$params.run_folder_id"
output_folder="$params.output_bucket/$params.output_folder"

// Read in genome files
genome_fa = file("s3://ngi-igenomes/igenomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa")
genome_fa_fai = file("s3://ngi-igenomes/igenomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa.fai")


// Read in bam/bai files
tumour_bam = file("$bam_folder/$params.tumour_bam/$params.tumour_bam*.bam")[0]
tumour_bai = file("$bam_folder/$params.tumour_bam/$params.tumour_bam*.bam.bai")[0]



/**************
** mSINGS **
***************/


process run_msings{
    publishDir output_folder, mode: 'copy'
    
    disk '50 GB'
    memory = 30.GB
    cpus = 8
    input:
        file tumour_bam
        file tumour_bai
        file genome_fa
        file genome_fa_fai
    output:
        file "*"

    """
    #!/bin/bash
    export PATH="$PATH:/usr/bin/samtools-1.9"
    echo $tumour_bam > path_to_bams
    /tmp/msings/scripts/run_msings2.sh path_to_bams /tmp/msings/doc/mSINGS_TCGA.bed /tmp/msings/doc/mSINGS_TCGA.baseline ${genome_fa}
    mkdir ${params.sample}
    mv *.txt ${params.sample}/.
    tar cvzf ${params.sample}.tar.gz ${params.sample}
    """
}
