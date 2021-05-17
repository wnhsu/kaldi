#!/bin/bash

set -eu


dir=./output/w2v_pca512_de
w2v_dir=/checkpoint/aconneau/asr/unsup_feat/de/unfiltered/precompute_unfiltered_pca512
label=phnc
arpa_lm=/private/home/aconneau/projects/XLSR/MLS/language_models/German.phn.o4.arpa
train_name="train"
valid_name="valid"

local/prepare_lang.sh $w2v_dir/dict.${label}.txt $dir/data
local/prepare_lm.sh $arpa_lm $dir/data
for split in $train_name $valid_name; do
  python local/prepare_data_from_w2v.py $w2v_dir $dir/data $split --label $label
  steps/compute_cmvn_stats.sh $dir/data/$split $dir/make_feat/$split $dir/feats/$split
done
local/train_subset.sh --out_root exp_train --out_name de_gt_960_2k_5k_-1_-1 \
  --train $train_name --valid $valid_name \
  --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
  --stage 1 --max_stage 4 $dir/data $dir/data/lang $dir/data/lang_test


