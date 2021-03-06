#!/bin/bash

set -eu


# train on real transcripts
dir=./output/w2v_pca128
w2v_dir=/checkpoint/abaevski/asr/unsup/data/segmented/precompute_unfiltered_pca128_seg
label=phnc
arpa_lm=/private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data_phn_mfcc/local/lm_phn/lm_phone_bg.arpa
train_name="train"
valid_name="dev_other"

local/prepare_lang.sh $w2v_dir/dict.${label}.txt $dir/data
local/prepare_lm.sh $arpa_lm $dir/data
for split in $train_name $valid_name; do
  python local/prepare_data_from_w2v.py $w2v_dir $dir/data $split --label $label
  steps/compute_cmvn_stats.sh $dir/data/$split $dir/make_feat/$split $dir/feats/$split
done
local/train_subset.sh --out_root exp_train --out_name gt_960_2k_5k_-1_-1 \
  --train $train_name --valid $valid_name \
  --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
  --stage 1 --max_stage 4 $dir/data $dir/data/lang $dir/data/lang_test


# train on 22% PER pseudo transcripts
new_label_dir=/checkpoint/abaevski/asr/unsup/data/segmented/22_uer_transcriptions
new_dir=./output/w2v_pca128_22uer
for split in $train_name $valid_name; do
  mkdir -p $new_dir/data/$split
  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
  cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
  paste -d' ' $new_dir/data/$split/uids $new_label_dir/$split.$label > $new_dir/data/$split/text

  echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
done
local/train_subset.sh --out_root exp_train --out_name 22uer_960_2k_5k_-1_-1 \
  --train $train_name --valid $valid_name \
  --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
  --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
