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


# train on 13% PER pseudo transcripts
new_label_dir=/checkpoint/abaevski/asr/unsup/data/segmented/transcriptions/phncs_23.3/kaldi
new_dir=./output/w2v_pca128_13uer
label=txt
for split in $train_name $valid_name; do
  mkdir -p $new_dir/data/$split
  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
  cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
  paste -d' ' $new_dir/data/$split/uids $new_label_dir/$split.$label > $new_dir/data/$split/text

  echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
done


exp_root=exp_train
exp_name=13uer_960_2k_5k_-1_-1
local/train_subset.sh --out_root $exp_root --out_name $exp_name \
  --train $train_name --valid $valid_name \
  --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
  --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
local/show_wer.sh --ref_data $dir/data $exp_root/$exp_name
# ==== WER w.r.t. pseudo transcript
# %WER 20.75 [ 38551 / 185811, 7033 ins, 19065 del, 12453 sub ] exp_train/13uer_960_2k_5k_-1_-1/mono/decode_dev_other/wer_7_0.0
# %WER 15.44 [ 28696 / 185811, 8182 ins, 11284 del, 9230 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri1/decode_dev_other/wer_17_0.5
# %WER 12.17 [ 22619 / 185811, 5135 ins, 12330 del, 5154 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/wer_7_0.0
# %WER 12.44 [ 23106 / 185811, 4888 ins, 13049 del, 5169 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/wer_7_0.0
# %WER 12.06 [ 22415 / 185811, 4955 ins, 12320 del, 5140 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/wer_7_0.0
# ==== WER w.r.t. real transcript (select based on pseudo WER)
# %WER 21.92 [ 39421 / 179810, 9664 ins, 15695 del, 14062 sub ] exp_train/13uer_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/7.0.0.tra
# %WER 15.68 [ 28201 / 179810, 10317 ins, 7418 del, 10466 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.0.5.tra
# %WER 9.87 [ 17756 / 179810, 5218 ins, 6412 del, 6126 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/7.0.0.tra
# %WER 10.03 [ 18036 / 179810, 4894 ins, 7054 del, 6088 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/7.0.0.tra
# %WER 9.76 [ 17543 / 179810, 5037 ins, 6401 del, 6105 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/7.0.0.tra
# ==== WER w.r.t. real transcript (select based on true WER)
# %WER 21.85 [ 39287 / 179810, 8677 ins, 16687 del, 13923 sub ] exp_train/13uer_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/8.0.0.tra
# %WER 15.43 [ 27744 / 179810, 9377 ins, 7947 del, 10420 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.1.0.tra
# %WER 9.75 [ 17537 / 179810, 4198 ins, 7374 del, 5965 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/7.0.5.tra
# %WER 10.01 [ 17998 / 179810, 4030 ins, 8072 del, 5896 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/7.0.5.tra
# %WER 9.62 [ 17297 / 179810, 4105 ins, 7272 del, 5920 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/7.0.5.tra


lm_4gram=/checkpoint/abaevski/data/speech/libri/librispeech_lm_novox.phnc_o4.arpa
exp_dir=$exp_root/$exp_name/tri3b
decode_suffix=4g
local/prepare_lm.sh --lmdir $dir/data/lang_test_4gram $lm_4gram $dir/data
local/decode.sh --decode_suffix $decode_suffix --graph_name graph_4g --val_sets "train dev_other" $exp_dir $new_dir/data $dir/data/lang_test_4gram
local/show_wer.sh --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# ==== WER w.r.t. pseudo transcript
# %WER 11.27 [ 20948 / 185811, 5034 ins, 10988 del, 4926 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/wer_7_0.0
# %WER 11.06 [ 20554 / 185811, 5039 ins, 10623 del, 4892 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/wer_7_0.0
# ==== WER w.r.t. real transcript (select based on pseudo WER)
# %WER 8.70 [ 15642 / 179810, 5069 ins, 5022 del, 5551 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/scoring/7.0.0.tra
# %WER 8.61 [ 15480 / 179810, 5181 ins, 4764 del, 5535 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/scoring/7.0.0.tra
# ==== WER w.r.t. real transcript (select based on true WER)
# %WER 8.42 [ 15146 / 179810, 3349 ins, 6511 del, 5286 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/scoring/7.1.0.tra
# %WER 8.15 [ 14653 / 179810, 3337 ins, 6014 del, 5302 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/scoring/7.1.0.tra


# Align pseudo transcript used for training
ali_dir=exp_align/w2v_pca128_13uer/tri3b/traintext
local/write_ali_int.sh --splits "dev_other train" $exp_root/$exp_name/tri3b $new_dir/data $dir/data/lang_test $ali_dir


# Align pseudo transcript decoded from the HMM system
# for speaker-adapted systems, set si=true for speaker independent decoding
lmparam=7.0.0
si=true
new_dir=./output/w2v_pca128_13uer_decode_$(basename $exp_dir)_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
for split in $train_name $valid_name; do
  mkdir -p $new_dir/data/$split
  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
  
  if $si; then
    tra=$exp_dir/decode${decode_suffix}_${split}.si/scoring/${lmparam}.tra
  else
    tra=$exp_dir/decode${decode_suffix}_${split}/scoring/${lmparam}.tra
  fi
  cat $tra | utils/int2sym.pl -f 2- $dir/data/lang/words.txt | sed 's:\<UNK\>::g' > $new_dir/data/$split/text
  echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
done

ali_dir=exp_align/w2v_pca128_13uer/tri3b/decodetext_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
local/write_ali_int.sh --splits "dev_other train" $exp_root/$exp_name/tri3b $new_dir/data $dir/data/lang_test $ali_dir
