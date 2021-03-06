#!/usr/bin/env bash

arpa_lm=$1
data=$2

langdir=$data/lang
lmdir=$data/lang_test

if [ ! -d $langdir ]; then
  echo "$langdir not found. run local/prepare_lang.sh first" && exit 1
fi

mkdir -p $lmdir
cp -r $langdir/* $lmdir

arpa2fst --disambig-symbol=#0 --read-symbol-table=$lmdir/words.txt $arpa_lm $lmdir/G.fst
fstisstochastic $lmdir/G.fst
utils/validate_lang.pl $lmdir || exit 1
