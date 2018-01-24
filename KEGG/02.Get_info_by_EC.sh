#!/bin/bash
set -euo pipefail


# Get all information of KEGG pathways
perl Parse_pathways.pl > KEGG_info.txt

# Extract uniq EC numbers
grep '^EC' test.txt | cut -f1 | sed 's/EC://g' | sort -g -u > test_uniq_ec.txt

# Extract pathway information from list of EC numbers
grep -Ff test_uniq_ec.txt KEGG_info.txt > test_uniq_ec_info.txt
