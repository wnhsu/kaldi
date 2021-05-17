#!/bin/bash

set -eu


# train on real transcripts
dir=./output/w2v_pca128
w2v_dir=/checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_unfiltered_pca128
label=phnc
arpa_lm=/private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data_phn_mfcc/local/lm_phn/lm_phone_bg.arpa
train_name="train"
valid_name="dev_other"

# local/prepare_lang.sh $w2v_dir/dict.${label}.txt $dir/data
# local/prepare_lm.sh $arpa_lm $dir/data
# for split in $train_name $valid_name; do
#   python local/prepare_data_from_w2v.py $w2v_dir $dir/data $split --label $label
#   steps/compute_cmvn_stats.sh $dir/data/$split $dir/make_feat/$split $dir/feats/$split
# done
# 
# # Use 5k for all stages
# local/train_subset.sh --out_root exp_train --out_name gt_960_2k_5k_-1_-1 \
#   --train $train_name --valid $valid_name \
#   --mono_size 5000 --tri1_size 5000 --tri2b_size 5000 --tri3b_size 5000 \
#   --stage 1 --max_stage 4 $dir/data $dir/data/lang $dir/data/lang_test
# 
# # Use full 960h for all stages
# local/train_subset.sh --out_root exp_train --out_name gt_960_2k_5k_-1_-1 \
#   --train $train_name --valid $valid_name \
#   --mono_size -1 --tri1_size -1 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 4 $dir/data $dir/data/lang $dir/data/lang_test
# 
# Use 2k->5k->full->full
local/train_subset.sh --out_root exp_train --out_name gt_960_2k_5k_-1_-1 \
  --train $train_name --valid $valid_name \
  --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
  --stage 1 --max_stage 1 $dir/data $dir/data/lang $dir/data/lang_test
# # %WER 16.52 [ 29708 / 179810, 3724 ins, 11834 del, 14150 sub ] exp_train/gt_960_2k_5k_-1_-1//mono/decode_dev_other/wer_8_0.0
# # %WER 10.49 [ 18857 / 179810, 4049 ins, 4874 del, 9934 sub ] exp_train/gt_960_2k_5k_-1_-1//tri1/decode_dev_other/wer_17_1.0
# # %WER 5.97 [ 10739 / 179810, 1705 ins, 3315 del, 5719 sub ] exp_train/gt_960_2k_5k_-1_-1//tri2b/decode_dev_other/wer_7_0.0
# # %WER 6.11 [ 10981 / 179810, 1595 ins, 3536 del, 5850 sub ] exp_train/gt_960_2k_5k_-1_-1//tri3b/decode_dev_other/wer_7_0.0
# # %WER 5.95 [ 10701 / 179810, 1565 ins, 3359 del, 5777 sub ] exp_train/gt_960_2k_5k_-1_-1//tri3b/decode_dev_other.si/wer_7_0.0
# 
# # --------------------------------------------------------------------------------
# # train on 22% PER pseudo transcripts
# new_label_dir=/checkpoint/abaevski/asr/unsup/data/segmented/22_uer_transcriptions
# new_dir=./output/w2v_pca128_22uer
# for split in $train_name $valid_name; do
#   mkdir -p $new_dir/data/$split
#   python local/copy_text.py --last_n=1 \
#     $w2v_dir/$split.tsv $new_label_dir/$split.tsv \
#     $new_label_dir/$split.$label $new_dir/data/$split/raw_text
# 
#   cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
#   cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
#   paste -d' ' $new_dir/data/$split/uids $new_dir/data/$split/raw_text > $new_dir/data/$split/text
# 
#   echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
# done
# 
# local/train_subset.sh --out_root exp_train --out_name 22uer_960_2k_5k_-1_-1 \
#   --train $train_name --valid $valid_name \
#   --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
# local/show_wer.sh --ref_data output/w2v_pca128/data exp_train/22uer_960_2k_5k_-1_-1
# 
# 
# # --------------------------------------------------------------------------------
# # train on 13% PER pseudo transcripts
# new_label_dir=/checkpoint/abaevski/asr/unsup/data/segmented/transcriptions/phncs_23.3/kaldi
# new_dir=./output/w2v_pca128_13uer
# label=txt
# for split in $valid_name $train_name; do
#   mkdir -p $new_dir/data/$split
#   python local/copy_text.py --last_n=1 \
#     $w2v_dir/$split.tsv $new_label_dir/$split.tsv \
#     $new_label_dir/$split.$label $new_dir/data/$split/raw_text
# 
#   cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
#   cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
#   paste -d' ' $new_dir/data/$split/uids $new_dir/data/$split/raw_text > $new_dir/data/$split/text
# 
#   echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
# done
# 
# 
# exp_root=exp_train
# exp_name=13uer_960_2k_5k_-1_-1
# local/train_subset.sh --out_root $exp_root --out_name $exp_name \
#   --train $train_name --valid $valid_name \
#   --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
# local/show_wer.sh --ref_data $dir/data $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 21.80 [ 40506 / 185811, 8223 ins, 18991 del, 13292 sub ] exp_train/13uer_960_2k_5k_-1_-1/mono/decode_dev_other/wer_7_0.0
# # %WER 16.81 [ 31237 / 185811, 9506 ins, 11902 del, 9829 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri1/decode_dev_other/wer_17_1.0
# # %WER 12.85 [ 23884 / 185811, 6006 ins, 12185 del, 5693 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/wer_7_0.0
# # %WER 13.23 [ 24578 / 185811, 6545 ins, 12110 del, 5923 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/wer_7_0.0
# # %WER 12.87 [ 23912 / 185811, 6326 ins, 11767 del, 5819 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 19.72 [ 35454 / 179810, 8168 ins, 12935 del, 14351 sub ] exp_train/13uer_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/7.0.0.tra
# # %WER 14.34 [ 25791 / 179810, 9427 ins, 5822 del, 10542 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.1.0.tra
# # %WER 8.57 [ 15407 / 179810, 4495 ins, 4673 del, 6239 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/7.0.0.tra
# # %WER 9.53 [ 17139 / 179810, 5575 ins, 5139 del, 6425 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/7.0.0.tra
# # %WER 9.03 [ 16238 / 179810, 5206 ins, 4646 del, 6386 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 19.68 [ 35381 / 179810, 7258 ins, 13839 del, 14284 sub ] exp_train/13uer_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/8.0.0.tra
# # %WER 14.34 [ 25791 / 179810, 9427 ins, 5822 del, 10542 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.1.0.tra
# # %WER 8.35 [ 15020 / 179810, 2881 ins, 6172 del, 5967 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/7.1.0.tra
# # %WER 9.24 [ 16617 / 179810, 3690 ins, 6761 del, 6166 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/7.1.0.tra
# # %WER 8.63 [ 15517 / 179810, 3295 ins, 6083 del, 6139 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/7.1.0.tra
# 
# 
# lm_4gram=/checkpoint/abaevski/data/speech/libri/librispeech_lm_novox.phnc_o4.arpa
# exp_dir=$exp_root/$exp_name/tri3b
# decode_suffix=4g
# local/prepare_lm.sh --lmdir $dir/data/lang_test_4gram $lm_4gram $dir/data
# local/decode.sh --decode_suffix $decode_suffix --graph_name graph_4g --val_sets "train dev_other" $exp_dir $new_dir/data $dir/data/lang_test_4gram
# local/show_wer.sh --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 12.04 [ 22380 / 185811, 6508 ins, 10300 del, 5572 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/wer_7_0.0
# # %WER 11.81 [ 21936 / 185811, 6366 ins, 10156 del, 5414 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 8.28 [ 14889 / 179810, 5679 ins, 3470 del, 5740 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/scoring/7.0.0.tra
# # %WER 7.99 [ 14367 / 179810, 5451 ins, 3240 del, 5676 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 7.69 [ 13830 / 179810, 3247 ins, 5223 del, 5360 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/scoring/8.1.0.tra
# # %WER 7.23 [ 12992 / 179810, 2899 ins, 4731 del, 5362 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/scoring/8.1.0.tra
# 
# 
# # Align pseudo transcript used for training
# ali_dir=exp_align/w2v_pca128_13uer/tri3b/traintext
# local/write_ali_int.sh --splits "dev_other train" $exp_root/$exp_name/tri3b $new_dir/data $dir/data/lang_test $ali_dir
# 
# 
# # Align pseudo transcript decoded from the HMM system
# # for speaker-adapted systems, set si=true for speaker independent decoding
# lmparam=7.0.0
# si=true
# new_dir=./output/w2v_pca128_13uer_decode_$(basename $exp_dir)_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
# for split in $train_name $valid_name; do
#   mkdir -p $new_dir/data/$split
#   cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
# 
#   if $si; then
#     tra=$exp_dir/decode${decode_suffix}_${split}.si/scoring/${lmparam}.tra
#   else
#     tra=$exp_dir/decode${decode_suffix}_${split}/scoring/${lmparam}.tra
#   fi
#   cat $tra | utils/int2sym.pl -f 2- $dir/data/lang/words.txt | sed 's:\<UNK\>::g' > $new_dir/data/$split/text
#   utils/fix_data_dir.sh $new_dir/data/$split
#   echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
# done
# # WER on train is 6.31 [ 2115415 / 33540433, 1136150 ins, 310515 del, 668750 sub ] 96.74 [ 272060 / 281241 ] 281241 sentences, 0 not present in hyp.
# # WER on dev_other is 7.99 [ 14367 / 179810, 5451 ins, 3240 del, 5676 sub ] 87.29 [ 2500 / 2864 ] 2864 sentences, 0 not present in hyp.
# 
# ali_dir=exp_align/w2v_pca128_13uer/tri3b/decodetext_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
# local/write_ali_int.sh --splits "dev_other train" $exp_root/$exp_name/tri3b $new_dir/data $dir/data/lang_test $ali_dir
# 
# 
# # --------------------------------------------------------------------------------
# # train on 11.7% PER pseudo transcripts
# new_label_dir=/checkpoint/abaevski/asr/unsup/data/segmented/transcriptions/phncs0.25_20.0/gan_phnc_to_phnc
# new_dir=./output/w2v_pca128_11uer
# label=txt
# for split in $valid_name $train_name; do
#   mkdir -p $new_dir/data/$split
#   python local/copy_text.py --last_n=1 \
#     $w2v_dir/$split.tsv $new_label_dir/$split.tsv \
#     $new_label_dir/$split.$label $new_dir/data/$split/raw_text
# 
#   cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
#   cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
#   paste -d' ' $new_dir/data/$split/uids $new_dir/data/$split/raw_text > $new_dir/data/$split/text
# 
#   echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
# done
# # WER on dev_other is 11.74 [ 21116 / 179810, 9955 ins, 5191 del, 5970 sub ] 89.53 [ 2564 / 2864 ] 2864 sentences, 0 not present in hyp.
# # WER on train is 10.78 [ 3614817 / 33540433, 2064017 ins, 796928 del, 753872 sub ] 97.93 [ 275418 / 281241 ] 281241 sentences, 0 not present in hyp.
# 
# 
# exp_root=exp_train
# exp_name=11uer_960_2k_5k_-1_-1
# local/train_subset.sh --out_root $exp_root --out_name $exp_name \
#   --train $train_name --valid $valid_name \
#   --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
# local/show_wer.sh --ref_data $dir/data $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 21.72 [ 40096 / 184574, 7093 ins, 19814 del, 13189 sub ] exp_train/11uer_960_2k_5k_-1_-1/mono/decode_dev_other/wer_8_0.0
# # %WER 16.14 [ 29796 / 184574, 9651 ins, 10809 del, 9336 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri1/decode_dev_other/wer_17_1.0
# # %WER 12.01 [ 22162 / 184574, 6010 ins, 10913 del, 5239 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/wer_7_0.0
# # %WER 12.33 [ 22760 / 184574, 6134 ins, 11282 del, 5344 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/wer_7_0.0
# # %WER 12.05 [ 22243 / 184574, 6157 ins, 10845 del, 5241 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 19.91 [ 35794 / 179810, 6777 ins, 14734 del, 14283 sub ] exp_train/11uer_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/8.0.0.tra
# # %WER 14.29 [ 25696 / 179810, 9476 ins, 5870 del, 10350 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.1.0.tra
# # %WER 8.35 [ 15022 / 179810, 4386 ins, 4525 del, 6111 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/7.0.0.tra
# # %WER 8.72 [ 15674 / 179810, 4569 ins, 4953 del, 6152 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/7.0.0.tra
# # %WER 8.43 [ 15156 / 179810, 4558 ins, 4482 del, 6116 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 19.91 [ 35794 / 179810, 6777 ins, 14734 del, 14283 sub ] exp_train/11uer_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/8.0.0.tra
# # %WER 14.29 [ 25696 / 179810, 9476 ins, 5870 del, 10350 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.1.0.tra
# # %WER 8.11 [ 14585 / 179810, 2658 ins, 6051 del, 5876 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/7.1.0.tra
# # %WER 8.57 [ 15405 / 179810, 3725 ins, 5614 del, 6066 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/7.0.5.tra
# # %WER 8.11 [ 14586 / 179810, 2874 ins, 5800 del, 5912 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/7.1.0.tra
# # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # INFO:root:exp_train/11uer_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/8.0.0.tra.txt: score 42.2776 wer 21.72% lm_ppl 20.5541 gt_wer 19.91%
# # INFO:root:exp_train/11uer_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.1.0.tra.txt: score 27.5411 wer 16.14% lm_ppl 11.3980 gt_wer 14.29%
# # INFO:root:exp_train/11uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/8.0.0.tra.txt: score 19.9105 wer 12.07% lm_ppl 7.8357 gt_wer 8.21%
# # INFO:root:exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/8.0.0.tra.txt: score 20.3953 wer 12.38% lm_ppl 8.0128 gt_wer 8.64%
# # INFO:root:exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/8.0.0.tra.txt: score 19.9458 wer 12.10% lm_ppl 7.8487 gt_wer 8.26%
# 
# 
# lm_4gram=/checkpoint/abaevski/data/speech/libri/librispeech_lm_novox.phnc_o4.arpa
# exp_dir=$exp_root/$exp_name/tri3b
# decode_suffix=4g
# local/prepare_lm.sh --lmdir $dir/data/lang_test_4gram $lm_4gram $dir/data
# local/decode.sh --decode_suffix $decode_suffix --graph_name graph_4g --val_sets "train dev_other" $exp_dir $new_dir/data $dir/data/lang_test_4gram
# local/show_wer.sh --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# local/unsup_select_decode.sh --ref_data $dir/data --psd_data $new_dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 11.18 [ 20638 / 184574, 5829 ins, 9878 del, 4931 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/wer_8_0.0
# # %WER 10.97 [ 20250 / 184574, 5390 ins, 10054 del, 4806 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/wer_9_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 7.50 [ 13478 / 179810, 4360 ins, 3645 del, 5473 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/scoring/8.0.0.tra
# # %WER 7.11 [ 12792 / 179810, 3770 ins, 3670 del, 5352 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/scoring/9.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 7.19 [ 12922 / 179810, 2771 ins, 4938 del, 5213 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/scoring/8.1.0.tra
# # %WER 6.82 [ 12264 / 179810, 2500 ins, 4550 del, 5214 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/scoring/8.1.0.tra
# # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # INFO:root:exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/scoring/8.0.0.tra.txt: score 17.6810 wer 11.18% lm_ppl 6.4996 gt_wer 7.50%
# # INFO:root:exp_train/11uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/scoring/9.0.0.tra.txt: score 17.3748 wer 10.97% lm_ppl 6.4036 gt_wer 7.11%
# 
# 
# # Align pseudo transcript used for training
# ali_dir=exp_align/w2v_pca128_11uer/tri3b/traintext
# local/write_ali_int.sh --splits "dev_other train" $exp_root/$exp_name/tri3b $new_dir/data $dir/data/lang_test $ali_dir
# 
# 
# # Align pseudo transcript decoded from the HMM system
# # for speaker-adapted systems, set si=true for speaker independent decoding
# lmparam=9.0.0
# si=true
# new_dir=./output/w2v_pca128_11uer_decode_$(basename $exp_dir)_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
# for split in $train_name $valid_name; do
#   mkdir -p $new_dir/data/$split
#   cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
# 
#   if $si; then
#     tra=$exp_dir/decode${decode_suffix}_${split}.si/scoring/${lmparam}.tra
#   else
#     tra=$exp_dir/decode${decode_suffix}_${split}/scoring/${lmparam}.tra
#   fi
#   cat $tra | utils/int2sym.pl -f 2- $dir/data/lang/words.txt | sed 's:\<UNK\>::g' > $new_dir/data/$split/text
#   utils/fix_data_dir.sh $new_dir/data/$split
#   echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
# done
# 
# ali_dir=exp_align/w2v_pca128_11uer/tri3b/decodetext_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
# local/write_ali_int.sh --splits "dev_other train" $exp_root/$exp_name/tri3b $new_dir/data $dir/data/lang_test $ali_dir


# --------------------------------------------------------------------------------
new_dir=./output/w2v_pca128_11uer_decode_tri3b_4g_9_0_0
# for split in $valid_name $train_name; do
#   echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
#   utils/fix_data_dir.sh $new_dir/data/$split
# done
# # WER on dev_other is 7.11 [ 12792 / 179810, 3770 ins, 3670 del, 5352 sub ] 82.58 [ 2365 / 2864 ] 2864 sentences, 0 not present in hyp.
# # WER on train is 5.63 [ 1888548 / 33540433, 913130 ins, 350310 del, 625108 sub ] 95.11 [ 267479 / 281241 ] 281241 sentences, 0 not present in hyp.


exp_root=exp_train
exp_name=11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1
# # local/train_subset.sh --out_root $exp_root --out_name $exp_name \
# #   --train $train_name --valid $valid_name \
# #   --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
# #   --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
# # local/show_wer.sh --ref_data $dir/data $exp_root/$exp_name
# # local/unsup_select_decode.sh --ref_data $dir/data --psd_data $new_dir/data --dec_name decode $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 16.30 [ 29323 / 179910, 4906 ins, 12803 del, 11614 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/mono/decode_dev_other/wer_8_0.0
# # %WER 10.33 [ 18583 / 179910, 6000 ins, 5339 del, 7244 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri1/decode_dev_other/wer_17_1.0
# # %WER 4.97 [ 8937 / 179910, 2352 ins, 4059 del, 2526 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decode_dev_other/wer_8_0.0
# # %WER 5.17 [ 9298 / 179910, 2534 ins, 4081 del, 2683 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri3b/decode_dev_other/wer_8_0.0
# # %WER 4.98 [ 8964 / 179910, 2254 ins, 4120 del, 2590 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/wer_9_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 17.13 [ 30801 / 179810, 4386 ins, 12183 del, 14232 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/8.0.0.tra
# # %WER 11.73 [ 21090 / 179810, 5809 ins, 5048 del, 10233 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.1.0.tra
# # %WER 7.01 [ 12601 / 179810, 2431 ins, 4038 del, 6132 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/8.0.0.tra
# # %WER 7.50 [ 13478 / 179810, 2905 ins, 4352 del, 6221 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/8.0.0.tra
# # %WER 7.24 [ 13021 / 179810, 2535 ins, 4301 del, 6185 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/9.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 17.13 [ 30801 / 179810, 4386 ins, 12183 del, 14232 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/8.0.0.tra
# # %WER 11.73 [ 21090 / 179810, 5809 ins, 5048 del, 10233 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.1.0.tra
# # %WER 7.01 [ 12601 / 179810, 2431 ins, 4038 del, 6132 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/8.0.0.tra
# # %WER 7.50 [ 13478 / 179810, 2905 ins, 4352 del, 6221 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/8.0.0.tra
# # %WER 7.24 [ 13021 / 179810, 2535 ins, 4301 del, 6185 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/9.0.0.tra
# # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # INFO:root:exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/10.0.0.tra.txt: score 34.1633 wer 16.36% lm_ppl 17.8035 gt_wer 17.21%
# # INFO:root:exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.1.0.tra.txt: score 20.9020 wer 10.33% lm_ppl 10.5730 gt_wer 11.73%
# # INFO:root:exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/8.0.0.tra.txt: score 12.6685 wer 4.97% lm_ppl 7.7010 gt_wer 7.01%
# # INFO:root:exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/8.0.0.tra.txt: score 13.0795 wer 5.17% lm_ppl 7.9114 gt_wer 7.50%
# # INFO:root:exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/9.0.0.tra.txt: score 12.7602 wer 4.98% lm_ppl 7.7777 gt_wer 7.24%

# lm_4gram=/checkpoint/abaevski/data/speech/libri/librispeech_lm_novox.phnc_o4.arpa
# exp_dir=$exp_root/$exp_name/tri2b
# decode_suffix=4g
# local/prepare_lm.sh --lmdir $dir/data/lang_test_4gram $lm_4gram $dir/data
# local/decode.sh --decode_suffix $decode_suffix --decode_script "steps/decode.sh" --graph_name graph_4g --val_sets "dev_other" $exp_dir $new_dir/data $dir/data/lang_test_4gram
# local/show_wer.sh --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# local/unsup_select_decode.sh --ref_data $dir/data --psd_data $new_dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 3.46 [ 6226 / 179910, 1692 ins, 2812 del, 1722 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decode4g_dev_other/wer_11_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 5.97 [ 10739 / 179810, 2167 ins, 3187 del, 5385 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decode4g_dev_other/scoring/11.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 5.95 [ 10690 / 179810, 2079 ins, 3215 del, 5396 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decode4g_dev_other/scoring/9.0.5.tra
# # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # INFO:root:exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decode4g_dev_other/scoring/12.0.0.tra.txt: score 9.9076 wer 3.47% lm_ppl 6.4397 gt_wer 6.02%
