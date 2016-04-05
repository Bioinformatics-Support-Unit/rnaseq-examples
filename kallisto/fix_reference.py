from Bio import SeqIO
import sys

def main():
    ## FIXME Hacky script depends on correct ordering of 3 file-based arguments
    gene_map = open(sys.argv[3], 'w')
    fixed_ref = open(sys.argv[2], 'w')
    records = SeqIO.parse(sys.argv[1], 'fasta')
    for record in records:
        identifier = record.id
        # ignore ENSTR ids (redundant identifiers for pseudoautosomal
        # region of Y chromosome). Annotation does not differ from "same" genes on X
        if identifier.startswith('ENSTR'):
            pass
        else:
            sequence = str(record.seq)
            # for debug/progress check
            print identifier
            tokens = identifier.split('|')
            try:
                enst = tokens[0].split('.')[0]
                ensg = tokens[1].split('.')[0]
            except:
                enst = tokens[0].split('.')[0]
                ensg = tokens[0].split('.')[0]
            ## write out gene map file (useful for analysis later)
            gene_map.write(enst+"\t"+ensg+"\n")
            ## write out FASTA with simplified identifiers
            fixed_ref.write(">"+enst+"\n"+sequence+"\n")

if __name__ == "__main__":
    ## FIXME put argparse code here...
    main()
