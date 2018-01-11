#!/bin/bash
set -euo pipefail

# 下載CDS
wget -nc https://www.arabidopsis.org/download_files/Sequences/TAIR10_blastsets/TAIR10_cds_20101214_updated

# 下載script
wget -nc https://raw.githubusercontent.com/shkao/TRBL/master/MY/extract_sequence/fastaqual_select.pl

# 把要取出的ID存成HKG_list.txt
# (https://github.com/shkao/TRBL/blob/master/MY/extract_sequence/HKG_list.txt)

# 用script取出HKG_list.txt中的序列，並存成HKG_Arabidopsis.fasta
perl fastaqual_select.pl -fastafile TAIR10_cds_20101214_updated -include HKG_list.txt > HKG_Arabidopsis.fasta
