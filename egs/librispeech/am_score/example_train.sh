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

# Use 5k for all stages
# %WER 17.94 [ 32262 / 179810, 3709 ins, 14632 del, 13921 sub ] exp_train/gt/mono/decode_dev_other/wer_7_0.0
# %WER 11.65 [ 20948 / 179810, 3817 ins, 6865 del, 10266 sub ] exp_train/gt/tri1/decode_dev_other/wer_16_1.0
# %WER 7.51 [ 13495 / 179810, 1779 ins, 5379 del, 6337 sub ] exp_train/gt/tri2b/decode_dev_other/wer_7_0.0
# %WER 8.03 [ 14445 / 179810, 1838 ins, 5842 del, 6765 sub ] exp_train/gt/tri3b/decode_dev_other/wer_7_0.0
# %WER 7.42 [ 13346 / 179810, 1727 ins, 5127 del, 6492 sub ] exp_train/gt/tri3b/decode_dev_other.si/wer_7_0.0
local/train_subset.sh --out_root exp_train --out_name gt_960_2k_5k_-1_-1 \
  --train $train_name --valid $valid_name \
  --mono_size 5000 --tri1_size 5000 --tri2b_size 5000 --tri3b_size 5000 \
  --stage 1 --max_stage 4 $dir/data $dir/data/lang $dir/data/lang_test

# Use full 960h for all stages
# %WER 17.30 [ 31116 / 179810, 3555 ins, 14052 del, 13509 sub ] exp_train/gt_960/mono/decode_dev_other/wer_7_0.0
# %WER 10.71 [ 19250 / 179810, 3162 ins, 6828 del, 9260 sub ] exp_train/gt_960/tri1/decode_dev_other/wer_17_1.0
# %WER 6.59 [ 11852 / 179810, 1531 ins, 4632 del, 5689 sub ] exp_train/gt_960/tri2b/decode_dev_other/wer_7_0.0
# %WER 6.68 [ 12011 / 179810, 1407 ins, 4859 del, 5745 sub ] exp_train/gt_960/tri3b/decode_dev_other/wer_7_0.0
# %WER 6.50 [ 11691 / 179810, 1420 ins, 4562 del, 5709 sub ] exp_train/gt_960/tri3b/decode_dev_other.si/wer_7_0.0
local/train_subset.sh --out_root exp_train --out_name gt_960_2k_5k_-1_-1 \
  --train $train_name --valid $valid_name \
  --mono_size -1 --tri1_size -1 --tri2b_size -1 --tri3b_size -1 \
  --stage 1 --max_stage 4 $dir/data $dir/data/lang $dir/data/lang_test

# Use 2k->5k->full->full
# %WER 17.35 [ 31191 / 179810, 3857 ins, 14100 del, 13234 sub ] exp_train/gt_960_2k_5k_-1_-1//mono/decode_dev_other/wer_7_0.0
# %WER 11.12 [ 20003 / 179810, 3654 ins, 6636 del, 9713 sub ] exp_train/gt_960_2k_5k_-1_-1//tri1/decode_dev_other/wer_17_0.5
# %WER 6.58 [ 11835 / 179810, 1510 ins, 4627 del, 5698 sub ] exp_train/gt_960_2k_5k_-1_-1//tri2b/decode_dev_other/wer_7_0.0
# %WER 6.79 [ 12209 / 179810, 1472 ins, 4943 del, 5794 sub ] exp_train/gt_960_2k_5k_-1_-1//tri3b/decode_dev_other/wer_7_0.0
# %WER 6.59 [ 11855 / 179810, 1490 ins, 4635 del, 5730 sub ] exp_train/gt_960_2k_5k_-1_-1//tri3b/decode_dev_other.si/wer_7_0.0
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
local/show_wer.sh --ref_data output/w2v_pca128/data exp_train/22uer_960_2k_5k_-1_-1
# ==== WER w.r.t. pseudo transcript
# %WER 21.48 [ 36604 / 170441, 11734 ins, 14152 del, 10718 sub ] exp_train/22uer_960_2k_5k_-1_-1/mono/decode_dev_other/wer_7_0.0
# %WER 18.43 [ 31414 / 170441, 14729 ins, 8766 del, 7919 sub ] exp_train/22uer_960_2k_5k_-1_-1/tri1/decode_dev_other/wer_17_0.5
# %WER 15.94 [ 27160 / 170441, 12925 ins, 9901 del, 4334 sub ] exp_train/22uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/wer_7_0.0
# %WER 16.39 [ 27941 / 170441, 12796 ins, 10627 del, 4518 sub ] exp_train/22uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/wer_7_0.0
# %WER 16.17 [ 27562 / 170441, 13139 ins, 9839 del, 4584 sub ] exp_train/22uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/wer_7_0.0
# ==== WER w.r.t. real transcript (select based on pseudo WER)
# %WER 24.26 [ 43618 / 179810, 8556 ins, 20343 del, 14719 sub ] exp_train/22uer_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/7.0.0.tra
# %WER 19.77 [ 35544 / 179810, 9941 ins, 13347 del, 12256 sub ] exp_train/22uer_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.0.5.tra
# %WER 16.17 [ 29074 / 179810, 7362 ins, 13707 del, 8005 sub ] exp_train/22uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/7.0.0.tra
# %WER 16.53 [ 29724 / 179810, 7149 ins, 14349 del, 8226 sub ] exp_train/22uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/7.0.0.tra
# %WER 15.79 [ 28395 / 179810, 7055 ins, 13124 del, 8216 sub ] exp_train/22uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/7.0.0.tra
# ==== WER w.r.t. real transcript (select based on true WER)
# %WER 24.26 [ 43618 / 179810, 8556 ins, 20343 del, 14719 sub ] exp_train/22uer_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/7.0.0.tra
# %WER 19.67 [ 35362 / 179810, 10615 ins, 12413 del, 12334 sub ] exp_train/22uer_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.0.0.tra
# %WER 16.17 [ 29074 / 179810, 7362 ins, 13707 del, 8005 sub ] exp_train/22uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/7.0.0.tra
# %WER 16.53 [ 29724 / 179810, 7149 ins, 14349 del, 8226 sub ] exp_train/22uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/7.0.0.tra
# %WER 15.79 [ 28395 / 179810, 7055 ins, 13124 del, 8216 sub ] exp_train/22uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/7.0.0.tra
