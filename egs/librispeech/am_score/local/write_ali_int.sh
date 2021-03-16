#!/bin/bash
# simplied version of write_ali which outputs phone indices

nj=40
cmd=run.pl
splits="dev_other train"
ali_script=steps/align_fmllr.sh

. ./path.sh
. ./cmd.sh
. parse_options.sh

exp_dir=$1
data_root=$2
lang=$3
ali_dir=$4

set -eu

for split in $splits; do
  data=$data_root/$split
  alidir=$ali_dir/$split

  # compute alignment
  if [ ! -f $alidir/ali.1.gz ]; then
    $ali_script --nj $nj --cmd "$train_cmd" $data $lang $exp_dir $alidir
  fi

  # dump phone alignment to $alidir/ali_phones.int
  if [ ! -f $alidir/ali_phones.int ]; then
    nj=$(cat $alidir/num_jobs)
    for j in $(seq $nj); do gunzip -c $alidir/ali.$j.gz; done | \
      ali-to-phones --per-frame=true $alidir/final.mdl ark:- ark,t:- > $alidir/ali_phones.int
  fi

  echo "showing forced-alignment for the first two utterances" && \
    head -n2 $alidir/ali_phones.int | ./utils/int2sym.pl -f 2- $lang/phones.txt
done
