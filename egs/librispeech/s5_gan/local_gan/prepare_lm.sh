#!/usr/bin/env bash

# Adapted from TIMIT local/timit_prepare_dict.sh and local/timit_format_data.sh

order=2

. utils/parse_options.sh || exit 1;
. ./path.sh || exit 1

text=$1
tmpdir=$2
langdir=$3
lmdir=$4

if [ -z $IRSTLM ] ; then
  export IRSTLM=$KALDI_ROOT/tools/irstlm/
fi
export PATH=${PATH}:$IRSTLM/bin
if ! command -v prune-lm >/dev/null 2>&1 ; then
  echo "$0: Error: the IRSTLM is not available or compiled" >&2
  echo "$0: Error: We used to install it by default, but." >&2
  echo "$0: Error: this is no longer the case." >&2
  echo "$0: Error: To install it, go to $KALDI_ROOT/tools" >&2
  echo "$0: Error: and run extras/install_irstlm.sh" >&2
  exit 1
fi

mkdir -p $tmpdir
cut -d' ' -f2- $text | sed -e 's:^:<s> :' -e 's:$: </s>:' \
  > $tmpdir/lm_train.text

build-lm.sh -i $tmpdir/lm_train.text -n $order \
  -o $tmpdir/lm_phone.ilm.gz

compile-lm $tmpdir/lm_phone.ilm.gz -t=yes /dev/stdout | \
  grep -v unk | gzip -c > $tmpdir/lm_phone.arpa.gz


# compilte into WFST
mkdir -p $lmdir
cp -r $langdir/* $lmdir

gunzip -c $tmpdir/lm_phone.arpa.gz | \
  arpa2fst --disambig-symbol=#0 \
           --read-symbol-table=$lmdir/words.txt - $lmdir/G.fst
fstisstochastic $lmdir/G.fst

# The output is like:
# 9.14233e-05 -0.259833
# we do expect the first of these 2 numbers to be close to zero (the second is
# nonzero because the backoff weights make the states sum to >1).
# Because of the <s> fiasco for these particular LMs, the first number is not
# as close to zero as it could be.

# # Everything below is only for diagnostic.
# # Checking that G has no cycles with empty words on them (e.g. <s>, </s>);
# # this might cause determinization failure of CLG.
# # #0 is treated as an empty word.
# mkdir -p $tmpdir/g
# awk '{if(NF==1){ printf("0 0 %s %s\n", $1,$1); }} END{print "0 0 #0 #0"; print "0";}' \
#   < "$lexicon"  >$tmpdir/g/select_empty.fst.txt
# fstcompile --isymbols=$lmdir/words.txt --osymbols=$lmdir/words.txt $tmpdir/g/select_empty.fst.txt | \
#  fstarcsort --sort_type=olabel | fstcompose - $lmdir/G.fst > $tmpdir/g/empty_words.fst
# fstinfo $tmpdir/g/empty_words.fst | grep cyclic | grep -w 'y' &&
#   echo "Language model has cycles with empty words" && exit 1
# rm -r $tmpdir/g

utils/validate_lang.pl $lmdir || exit 1


