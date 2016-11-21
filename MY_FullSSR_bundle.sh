#!/bin/bash
set -euo pipefail

# 0. Download FullSSR bundle
curl -o FullSSR.zip "http://www.psb.ugent.be/~shkao/shared/FullSSR.zip" \
  && unzip FullSSR.zip \
  && cd FullSSR

# 1. Open FullSSR
tar -zxvf FullSSR.tar.gz

# 2. Update FullSSR config
mv config.txt config.txt.bak
cat config.txt.bak \
  | perl -pe "s|/home/../primer3-2.3.6|$(pwd)/primer3-2.3.7|g" \
  > config.txt

# 3. Open BioPerl
tar -zxvf BioPerl-1.007001.tar.gz

# 4. Copy missing library
cp Primer3.pm BioPerl-1.007001/Bio/Tools/Run

# 5. Modify script to use local BioPerl
cat FullSSR\(ver-1.1\).pl \
  | perl -pe "s|use strict;|use strict;\nuse lib \"$(pwd)/BioPerl-1.007001\";|" \
  | perl -pe "s|use strict;|use strict;\nuse lib \"$(pwd)/\";|" \
  > FullSSR_ver-1.1_re.pl

# 6. Test with example sequence
echo "Now testing with example sequence: $(pwd)/Example/sequences.fasta"
perl FullSSR_ver-1.1_re.pl --i Example/sequences.fasta \
  && echo "Finish testing, resultls are in $(dirname $(pwd)/Example_*/Report.html)"
