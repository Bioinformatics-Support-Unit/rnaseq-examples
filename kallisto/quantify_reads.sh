#!/bin/bash
#$ -cwd -V
#$ -l h_vmem=5G
#$ -pe smp 1-20
#$ -N kallisto-quant
#$ -hold_jid kallisto-prep
#$ -o logs/quant.$JOB_ID.$TASK_ID.out
#$ -e logs/quant.$JOB_ID.$TASK_ID.err

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
WORK=$(pwd)

## Find FASTQ pair
FASTQ1=$(ls -1 ${WORK}/fastq/*_1.fq.gz | tail -n +${SGE_TASK_ID} | head -n 1)
FASTQ2=${FASTQ1%_1.fq.gz}_2.fq.gz
## processing of file name to sample name here is experiment dependent
## Here I had A1 -> A20, B1 -> B20, C1 -> C20 and D1 -> D20.
## Helpful that it's encoded in the FASTQ file name, but this is often the case

SAMPLE=$(echo ${FASTQ1} | grep -Po '[A-D]\d{1,2}-')
OUTDIR=${WORK}/counts/${SAMPLE%-}
## Should already exist, but for safety
mkdir ${OUTDIR}

## Quantify sample with bootstraps (-b, set higher for more robust transcriptome analysis later)
kallisto quant -b 10 \
    -t ${NSLOTS} \
    -i ${WORK}/index/gencode_transcripts.kallisto \
    -o ${OUTDIR} \
    ${FASTQ1} ${FASTQ2}

## DONE

end_time=$(date)
end_secs=$(date +%s)
time_elapsed=$(echo "${end_secs} - ${start_secs}" | bc)
echo
echo "### Ended at: ${end_time} ###"
echo "### Time Elapsed: ${time_elapsed} ###"
