#!/bin/bash

set -eu


# off-line preparation. LL for ground truth = -1159.62
dir=./output/w2v_pca128
w2v_dir=/checkpoint/abaevski/asr/unsup/data/segmented/precompute_unfiltered_pca128_seg
label=phnc
train_name="5k"
valid_name="dev_other"

local/prepare_lang.sh $w2v_dir/dict.${label}.txt $dir/data
for split in $train_name $valid_name; do
  python local/prepare_data_from_w2v.py $w2v_dir $dir/data $split --label $label
  steps/compute_cmvn_stats.sh $dir/data/$split $dir/make_feat/$split $dir/feats/$split
done
local/compute_am_score.sh --out_root am_res --out_name gt \
  --mono_train $train_name --tri1_train $train_name --tri2b_train $train_name \
  --valid $valid_name --max_stage 3 $dir/data $dir/data/lang


# on-line part (pseudo transcript with 22% uer). LL = -1160.11
new_label_dir=/checkpoint/abaevski/asr/unsup/data/segmented/22_uer_transcriptions
new_dir=./output/w2v_pca128_22uer

for split in $train_name $valid_name; do
  mkdir -p $new_dir/data/$split
  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
  cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
  paste -d' ' $new_dir/data/$split/uids $new_label_dir/$split.$label > $new_dir/data/$split/text

  echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-) 
done
local/compute_am_score.sh --out_root am_res --out_name 22uer \
  --mono_train $train_name --valid $valid_name --max_stage 1 $new_dir/data $dir/data/lang


# sanity check 1: shuffle order. LL = -1184.9
new_label_dir=/checkpoint/abaevski/asr/unsup/data/segmented/22_uer_transcriptions
new_dir=./output/w2v_pca128_22uer_shuf

for split in $train_name $valid_name; do
  mkdir -p $new_dir/data/$split
  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
  cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
  shuf $new_label_dir/$split.$label > $new_dir/data/$split/text_nouids
  paste -d' ' $new_dir/data/$split/uids $new_dir/data/$split/text_nouids > $new_dir/data/$split/text

  echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-) 
done
local/compute_am_score.sh --out_root am_res --out_name 22uer_shuf \
  --mono_train $train_name --valid $valid_name --max_stage 1 $new_dir/data $dir/data/lang


# sanity check 2: drop words: LL = -1174.94
new_label_dir=/checkpoint/abaevski/asr/unsup/data/segmented/22_uer_transcriptions
new_dir=./output/w2v_pca128_22uer_subsamp3x

for split in $train_name $valid_name; do
  mkdir -p $new_dir/data/$split
  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
  cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
  awk '{for(i=1; i<=NF; i=i+3) {printf $i" "} printf "\n"}' $new_label_dir/$split.$label > $new_dir/data/$split/text_nouids
  paste -d' ' $new_dir/data/$split/uids $new_dir/data/$split/text_nouids > $new_dir/data/$split/text

  echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-) 
done
local/compute_am_score.sh --out_root am_res --out_name 22uer_subsamp3x \
  --mono_train $train_name --valid $valid_name --max_stage 1 $new_dir/data $dir/data/lang


# on-line part (pseudo transcript with 57% uer). LL = -1175.86
new_label_dir=/checkpoint/wnhsu/experiments/unsup_asr/tmp_57_uer_transcriptions
new_dir=./output/w2v_pca128_57uer

for split in $train_name $valid_name; do
  mkdir -p $new_dir/data/$split
  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
  cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
  paste -d' ' $new_dir/data/$split/uids $new_label_dir/$split.$label > $new_dir/data/$split/text

  echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-) 
done
local/compute_am_score.sh --out_root am_res --out_name 57uer \
  --mono_train $train_name --valid $valid_name --max_stage 1 $new_dir/data $dir/data/lang


