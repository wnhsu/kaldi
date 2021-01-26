#!/bin/bash

. ./path.sh
cmd=run.pl

set -eu

# compare alignment
lang=data/lang_nosp
data=data/train_10k

ali1=./exp/tri1_ali_10k
ali2=./exp/tri2b_ali_10k
dir=./exp/compare_ali/tri1_tri2b
steps/compare_alignments.sh --cleanup false $lang $data $ali1 $ali2 $dir
