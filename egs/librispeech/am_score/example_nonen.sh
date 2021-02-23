#!/bin/bash

set -eu


# off-line preparation. LL for ground truth = -2451.39
dir=./output/w2v_pca512_de
w2v_dir=/checkpoint/aconneau/asr/unsup_feat/de/unfiltered/precompute_unfiltered_pca512
label=phnc
train_name="valid"
valid_name="test"

local/prepare_lang.sh $w2v_dir/dict.${label}.txt $dir/data
for split in $train_name $valid_name; do
  python local/prepare_data_from_w2v.py $w2v_dir $dir/data $split --label $label
  steps/compute_cmvn_stats.sh $dir/data/$split $dir/make_feat/$split $dir/feats/$split
done
local/compute_am_score.sh --out_root am_res_de --out_name gt \
  --mono_train $train_name --valid $valid_name --max_stage 1 $dir/data $dir/data/lang


# sanity check 1: shufft order. LL = -2530.35
new_label_dir=/checkpoint/aconneau/asr/unsup_feat/de/unfiltered/precompute_unfiltered_pca512
new_dir=./output/w2v_pca512_de_shuf

for split in $train_name $valid_name; do
  mkdir -p $new_dir/data/$split
  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
  cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
  shuf $new_label_dir/$split.$label > $new_dir/data/$split/text_nouids
  paste -d' ' $new_dir/data/$split/uids $new_dir/data/$split/text_nouids > $new_dir/data/$split/text

  echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-) 
done
local/compute_am_score.sh --out_root am_res_de --out_name gt_shuf \
  --mono_train $train_name --valid $valid_name --max_stage 1 $new_dir/data $dir/data/lang


# sanity check 2: drop words: LL = -2509.13
new_label_dir=/checkpoint/aconneau/asr/unsup_feat/de/unfiltered/precompute_unfiltered_pca512
new_dir=./output/w2v_pca512_de_subsamp3x

for split in $train_name $valid_name; do
  mkdir -p $new_dir/data/$split
  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
  cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
  awk '{for(i=1; i<=NF; i=i+3) {printf $i" "} printf "\n"}' $new_label_dir/$split.$label > $new_dir/data/$split/text_nouids
  paste -d' ' $new_dir/data/$split/uids $new_dir/data/$split/text_nouids > $new_dir/data/$split/text

  echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-) 
done
local/compute_am_score.sh --out_root am_res_de --out_name gt_subsamp3x \
  --mono_train $train_name --valid $valid_name --max_stage 1 $new_dir/data $dir/data/lang
