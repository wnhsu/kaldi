#!/bin/bash

. ./path.sh
. ./cmd.sh
cmd=run.pl

set -eu

nj=40
datalist="data/train_960 data/dev_clean data/dev_other data/test_clean data/test_other"
gmmdir=exp/tri6b
lang=data/lang

for data in $datalist; do
  alidir=./exp/tri6b_ali_$(basename $data)
  
  # compute alignment
  if [ ! -f $alidir/ali.1.gz ]; then
    steps/align_fmllr.sh --nj $nj --cmd "$train_cmd" \
      $data $lang $gmmdir $alidir
  fi
  
  # dump phone alignment to $alidir/ali_phones.gz. To view it, run 
  # `gunzip -c $alidir/ali_phones.gz`
  if [ ! -f $alidir/ali_phones.gz ]; then
    nj=$(cat $alidir/num_jobs)
    for j in $(seq $nj); do gunzip -c $alidir/ali.$j.gz; done | \
      ali-to-phones --per-frame=true $alidir/final.mdl ark:- ark,t:- | \
      ./utils/int2sym.pl -f 2- $lang/phones.txt | gzip -c > $alidir/ali_phones.gz
  fi
  gunzip -c $alidir/ali_phones.gz | head -n2
  
  # dump word alignment
  if [ ! -f $alidir/ctm/ctm ]; then
    steps/get_train_ctm.sh --use-segments false --print-silence true \
      --cmd "$cmd" --frame-shift 1.0 $data $lang $alidir $alidir/ctm
  fi
  if [ ! -f $alidir/ali_words.gz ]; then
    cat $alidir/ctm/ctm | \
      awk 'BEGIN{utt_id="";} { if (utt_id != $1) { if (utt_id != "") printf("\n"); utt_id=$1; printf("%s ", utt_id); } t_start=int($3); t_end=t_start + int($4); word=$5; for (t=t_start; t<t_end; t++) printf("%s ", word); } END{printf("\n")}' | \
      gzip -c >$alidir/ali_words.gz
  fi
  gunzip -c $alidir/ali_words.gz | head -n2
done
