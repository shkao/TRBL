#!/bin/bash
set -euo pipefail

mkdir -p FullSSR && cd FullSSR

# 1. Download FullSSR
wget -nc -O FullSSR.tar.gz https://sourceforge.net/projects/fullssr/files/latest/download \
  && tar -zxvf FullSSR.tar.gz

# 2. Download and compile Primer3, then update FullSSR config
wget -nc -O primer3-2.3.7.tar.gz https://sourceforge.net/projects/primer3/files/primer3/2.3.7/primer3-2.3.7.tar.gz/download \
  && tar -zxvf primer3-2.3.7.tar.gz \
  && cd primer3-2.3.7/src \
  && make \
  && cd -
mv config.txt config.txt.bak
cat config.txt.bak \
  | perl -pe "s|/home/../primer3-2.3.6|$(pwd)/primer3-2.3.7|g" \
  > config.txt

# 3. Download BioPerl
wget -nc https://cpan.metacpan.org/authors/id/C/CJ/CJFIELDS/BioPerl-1.007001.tar.gz \
  && tar -zxvf BioPerl-1.007001.tar.gz

# 4. Copy missing library
cp Primer3.pm BioPerl-1.007001/Bio/Tools/Run

# 5. Force FullSSR script to use local BioPerl
cat FullSSR\(ver-1.1\).pl \
  | perl -pe "s|use strict;|use strict;\nuse lib \"$(pwd)/BioPerl-1.007001\";|" \
  | perl -pe "s|use strict;|use strict;\nuse lib \"$(pwd)/\";|" \
  > FullSSR_ver-1.1_re.pl

# 6. Test with example sequence
echo "Now testing with example sequence: $(pwd)/Example/sequences.fasta"
perl FullSSR_ver-1.1_re.pl --i Example/sequences.fasta \
  && echo "Finish testing, resultls are in $(dirname $(pwd)/Example_*/Report.html)"
