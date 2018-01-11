#!/bin/bash
set -euo pipefail

wget -nc https://www.arabidopsis.org/download_files/Sequences/TAIR10_blastsets/TAIR10_cds_20101214_updated

wget -nc https://raw.githubusercontent.com/shkao/TRBL/master/MY/extract_sequence/fastaqual_select.pl

perl fastaqual_select.pl -fastafile TAIR10_cds_20101214_updated -include HKG_list.txt > HKG_Arabidopsis.fasta
