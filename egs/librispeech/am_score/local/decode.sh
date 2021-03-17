#!/bin/bash

set -u

val_sets="dev_other"
graph_name=graph
decode_suffix=""
decode_script="steps/decode_fmllr.sh"

. ./cmd.sh
. ./path.sh
. parse_options.sh

set -x
exp_dir=$1
data_root=$2
lang_test=$3

graph=$exp_dir/$graph_name

if [ ! -d $graph ]; then
  utils/mkgraph.sh $lang_test $exp_dir $graph
fi

for part in $val_sets; do
  echo "decoding $part for $exp_dir"
  $decode_script --nj 60 --cmd "$decode_cmd" \
    $graph $data_root/$part $exp_dir/decode${decode_suffix}_${part} &
done

wait
