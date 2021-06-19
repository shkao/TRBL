#!/bin/bash


for i in P50750 P24941 Q00535 P50613 P11802; do
  curl -s "https://www.uniprot.org/uniprot/${i}.fasta" \
    | seqkit fx2tab -i \
    >> 20210528_Extract_Uniprot.tsv
done
