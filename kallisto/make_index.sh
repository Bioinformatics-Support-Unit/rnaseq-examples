#!/bin/bash
#$ -cwd -V
#$ -l h_vmem=5G
#$ -pe smp 1
#$ -N kallisto-prep
#$ -o logs/transcriptome_build.$JOB_ID.$TASK_ID.out
#$ -e logs/transcriptome_build.$JOB_ID.$TASK_ID.err

start_time=$(date)
start_secs=$(date +%s)
echo "### Logging Info ###"
echo "### Job: ${JOB_ID}: ${JOB_NAME} ###"
echo "### Array ID: ${SGE_TASK_ID} ###"
echo "### Job Occupying ${NSLOTS} slots ###"
echo "### Job running on ${HOSTNAME} ###"
echo "### Started at: ${start_time} ###"
echo

module add apps/kallisto/0.42.4_linux

## Build Kallisto index of transcriptome FASTA

kallisto index -i index/gencode_transcripts.kallisto \
    ext_data/gencode_transcripts_fixed.fa

## DONE

end_time=$(date)
end_secs=$(date +%s)
time_elapsed=$(echo "${end_secs} - ${start_secs}" | bc)
echo
echo "### Ended at: ${end_time} ###"
echo "### Time Elapsed: ${time_elapsed} ###"
