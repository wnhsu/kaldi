#!/usr/bin/env bash

# Assume having finished stage 2 of run_w2v_sup.sh

suffix=phn_w2v_pca512_topo_3_1_unsup_22uer_hmm_it2
val_sets="dev_other"
num_nonsil_states=1

# pseudo label info
ref_root=data_phn_w2v_pca512_topo_3_1_unsup_22uer_it1
hmm_dir=exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri3b
graph=exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri3b/graph
decode_prefix="decode"
score_option="7.0.0"


stage=1
train_stage=7

. ./cmd.sh
. ./path.sh
. parse_options.sh

data_root=data_$suffix
exp_root=exp_$suffix

# you might not want to do this for interactive shells.
set -e


if [ $stage -le 1 ]; then
  mkdir -p $data_root/local
  ln -sf $(realpath $ref_root/lang_nosp) $data_root
  ln -sf $(realpath $ref_root/lang_nosp_test_bg) $data_root
fi

if [ $stage -le 2 ]; then
  files="spk2gender spk2utt utt2spk wav.scp cmvn.scp feats.scp"
  for part in $val_sets train_clean_100 train_clean_360 train_other_500; do
    mkdir -p $data_root/$part
    for file in $files; do
      cp $ref_root/$part/$file $data_root/$part/$file
    done
    
    tra=$hmm_dir/${decode_prefix}_${part}/scoring/${score_option}.tra
    cat $tra | sort | utils/int2sym.pl -f 2- $graph/words.txt | \
      sed 's:\<UNK\>::g' > $data_root/$part/text

    utils/validate_data_dir.sh $data_root/$part || exit 1;
  done
fi

if [ $stage -le 3 ]; then
  bash run_train.sh $data_root $exp_root $train_stage $val_sets $num_nonsil_states
fi
