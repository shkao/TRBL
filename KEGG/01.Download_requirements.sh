#!/bin/bash
set -euo pipefail


mkdir -p data

wget -P data -nc http://www.genome.jp/kegg/pathway.html
wget -nc -O "data/KO.keg" "http://www.genome.jp/kegg-bin/download_htext?htext=ko00001.keg&format=htext&filedir="
