#!/bin/bash

# Step-through Kallisto quantification of RNA-Seq experiments
## Set up some environment
## Assumes everything will work from present working dir (oof)
WORKING_DIR=$(pwd)
mkdir ${WORKING_DIR}/ext_data
mkdir ${WORKING_DIR}/counts
mkdir ${WORKING_DIR}/index

## Download latest Gencode reference gene models
## release 24 - update version numbers as required
cd ${WORKING_DIR}/ext_data
curl -O ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_24/gencode.v24.transcripts.fa.gz
gunzip gencode.v24.transcripts.fa.gz
mv gencode.v24.transcripts.fa.gz gencode_transcripts.fa
cd ${WORKING_DIR}

## Process gene models to simplify identifiers (good for downstream processing)
## Also makes ENST - ENSG tables for mapping transcripts to genes
python fix_reference.py ${WORKING_DIR}/ext_data/gencode_transcripts.fa \
    ${WORKING_DIR}/ext_data/gencode_transcripts_fixed.fa \ ${WORKING_DIR}/ext_data/gencode_genemap.txt

## Make transcriptome index
## We use SoGE on our cluster, so my scripts are written with that in mind. YMMV.
qsub make_index.sh

## Quantify RNA-Seq reads
## Works as an array job, for the number of samples we're quantifying.
## Again, this is with SoGE in mind. Should be trivial to adapt.
qsub -t 1-12 quantify_reads.sh

## Now consider detect_dge.R for example analysis
