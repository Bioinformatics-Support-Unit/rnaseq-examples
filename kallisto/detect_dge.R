# install_github("mikelove/tximport")

library(devtools)
library(tximport)
library(readr)
library(DESeq2)

library(biomaRt)

## Until it's in the release version of DESeq2, this provides
## DESeqDataSetFromTximport()
source_gist("adf345af5897e69e0bee")
## An example sample table
## In this example, we have two pairs of conditions - we want to find the
## difference between 'high' and 'low', while controlling for the effect of
## 'disease' (A or B). The sample table descibes the conditions, and allows
## us to build a model for the test in DESeq2
sample_name=c("A1", "A2", "A3", "A4", "A5", "A6", "B1", "B2", "B3", "B4", "B5", "B6")
sample_table = data.frame(sample_name,
    path=file.path('counts', sample_name),
    bg_condition=factor(rep(c('diseaseA', 'diseaseB'), each=6), levels=c('diseaseA', 'diseaseB')),
    test_condition=factor(rep(rep(c('high', 'low'), each=3), 2), levels=c('low', 'high')),
    stringsAsFactors=FALSE)
## This is the gene map file created by fix_reference.py
tx2gene <- read_tsv("ext_data/gencode_genemap.txt", col_names = c('txid', 'geneid'))
## Full paths to the abundance files produced by Kallisto
files <- file.path(sample_table$path, "abundance.tsv")
## import the quantification tables (gene level)
txi <- tximport(files, type = "kallisto", tx2gene = tx2gene, reader = read_tsv)
## txi is a list with 4 slots:
## $counts is the count table
## $abundance is gene-level TPM
## $length is the gene length (average transcript length per gene)
## $countsFromAbundance holds the string value of this argument to the
## tximport() function call - 'no' by default.

## make DESeq2 dataset from gene counts
## DESeqDataSetFromTximport is provided by the Gist sourced above, but will
## be included in the next release version of DESeq2.
## model looks for changes in test_condition, accounting for background of bg_condition
dds <- DESeqDataSetFromTximport(txi, sample_table, ~bg_condition + test_condition)

## proceed with DESeq2 analysis as per usual.
dds <- DESeq(dds)
res <- results(dds)
## etc etc.

## Since genes are identified by ENSG ids, we can use biomaRt to retrieve
## annotation.

library(biomaRt)
ensembl <- useMart("ensembl")
ensembl <- useDataset("hsapiens_gene_ensembl", mart=ensembl)

annotation = getBM(attributes=c('ensembl_gene_id',
    'hgnc_symbol', 'description',
    'chromosome_name', 'start_position',
    'end_position', 'strand',
    'gene_biotype', 'percentage_gc_content'),
    filters = 'ensembl_gene_id',
    values = rownames(dds),
    mart = ensembl)
