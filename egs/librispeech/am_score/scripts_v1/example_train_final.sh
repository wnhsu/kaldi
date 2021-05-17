#!/bin/bash

set -eu


# train on real transcripts
dir=./output/w2v_pca128_0412
w2v_dir=/checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_full_pca128/
label=phnc
arpa_lm=/private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data_phn_mfcc/local/lm_phn/lm_phone_bg.arpa
train_name="train"
valid_name="dev_other"

# local/prepare_lang.sh $(dirname $w2v_dir)/dict.${label}.txt $dir/data
# local/prepare_lm.sh $arpa_lm $dir/data
# for split in $train_name $valid_name; do
#   python local/prepare_data_from_w2v.py $w2v_dir $dir/data $split --label $label
#   steps/compute_cmvn_stats.sh $dir/data/$split $dir/make_feat/$split $dir/feats/$split
# done

# # Use 2k->5k->full->full
# local/train_subset.sh --out_root exp_train --out_name gt_960_2k_5k_-1_-1_new \
#   --train $train_name --valid $valid_name \
#   --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 2 $dir/data $dir/data/lang $dir/data/lang_test
# %WER 16.32 [ 29342 / 179809, 3783 ins, 11648 del, 13911 sub ] exp_train/gt_960_2k_5k_-1_-1_new/mono/decode_dev_other/wer_8_0.0
# %WER 10.50 [ 18872 / 179809, 4143 ins, 4821 del, 9908 sub ] exp_train/gt_960_2k_5k_-1_-1_new/tri1/decode_dev_other/wer_17_1.0


# # --------------------------------------------------------------------------------
# # train on 10.5% PER pseudo transcripts
# new_label_dir=/checkpoint/abaevski/asr/unsup/data/segmented/transcriptions/final_phncs0.25_19.3/gan_to_phnc
# new_dir=./output/w2v_pca128_10.5uer
# label=txt
# # for split in $valid_name $train_name; do
# #   mkdir -p $new_dir/data/$split
# #   python local/copy_text.py --last_n=1 \
# #     $w2v_dir/$split.tsv $new_label_dir/$split.tsv \
# #     $new_label_dir/$split.$label $new_dir/data/$split/raw_text
# # 
# #   cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
# #   cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
# #   paste -d' ' $new_dir/data/$split/uids $new_dir/data/$split/raw_text > $new_dir/data/$split/text
# # 
# #   echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
# # done
# 
# 
# exp_root=exp_train
# exp_name=10.5uer_960_2k_5k_-1_-1
# # local/train_subset.sh --out_root $exp_root --out_name $exp_name \
# #   --train $train_name --valid $valid_name \
# #   --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
# #   --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
# # local/show_wer.sh --ref_data $dir/data $exp_root/$exp_name
# # # ==== WER w.r.t. pseudo transcript
# # # %WER 20.32 [ 37274 / 183426, 6005 ins, 18731 del, 12538 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/mono/decode_dev_other/wer_8_0.0
# # # %WER 14.78 [ 27107 / 183426, 7860 ins, 10521 del, 8726 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri1/decode_dev_other/wer_17_1.0
# # # %WER 10.52 [ 19294 / 183426, 5110 ins, 9826 del, 4358 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/wer_7_0.0
# # # %WER 10.70 [ 19629 / 183426, 5243 ins, 9929 del, 4457 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/wer_7_0.0
# # # %WER 10.50 [ 19252 / 183426, 5193 ins, 9688 del, 4371 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/wer_7_0.0
# # # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # # %WER 17.84 [ 32077 / 179809, 4431 ins, 13540 del, 14106 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/8.0.0.tra
# # # %WER 12.48 [ 22445 / 179809, 6438 ins, 5482 del, 10525 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.1.0.tra
# # # %WER 7.52 [ 13518 / 179809, 3088 ins, 4187 del, 6243 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/7.0.0.tra
# # # %WER 7.90 [ 14213 / 179809, 3397 ins, 4466 del, 6350 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/7.0.0.tra
# # # %WER 7.59 [ 13640 / 179809, 3229 ins, 4107 del, 6304 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/7.0.0.tra
# # # ==== WER w.r.t. real transcript (select based on true WER)
# # # %WER 17.84 [ 32077 / 179809, 4431 ins, 13540 del, 14106 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/mono/decode_dev_other/scoring/8.0.0.tra
# # # %WER 12.48 [ 22445 / 179809, 6438 ins, 5482 del, 10525 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri1/decode_dev_other/scoring/17.1.0.tra
# # # %WER 7.49 [ 13466 / 179809, 2578 ins, 4725 del, 6163 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decode_dev_other/scoring/7.0.5.tra
# # # %WER 7.87 [ 14153 / 179809, 2835 ins, 5041 del, 6277 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode_dev_other/scoring/7.0.5.tra
# # # %WER 7.50 [ 13491 / 179809, 2668 ins, 4608 del, 6215 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode_dev_other.si/scoring/7.0.5.tra
# 
# 
# lm_4gram=/checkpoint/abaevski/data/speech/libri/librispeech_lm_novox.phnc_o4.arpa
# exp_dir=$exp_root/$exp_name/tri3b
# decode_suffix=4g
# # local/prepare_lm.sh --lmdir $dir/data/lang_test_4gram $lm_4gram $dir/data
# # local/decode.sh --decode_suffix $decode_suffix --graph_name graph_4g --val_sets "train dev_other" $exp_dir $new_dir/data $dir/data/lang_test_4gram
# # local/show_wer.sh --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# # local/unsup_select_decode.sh --ref_data $dir/data --psd_data $new_dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# # # ==== WER w.r.t. pseudo transcript
# # # %WER 9.91 [ 18181 / 183426, 4867 ins, 9125 del, 4189 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/wer_7_0.5
# # # %WER 9.78 [ 17931 / 183426, 4793 ins, 8971 del, 4167 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/wer_7_0.5
# # # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # # %WER 6.66 [ 11982 / 179809, 2858 ins, 3499 del, 5625 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/scoring/7.0.5.tra
# # # %WER 6.40 [ 11504 / 179809, 2669 ins, 3230 del, 5605 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/scoring/7.0.5.tra
# # # ==== WER w.r.t. real transcript (select based on true WER)
# # # %WER 6.65 [ 11953 / 179809, 2559 ins, 3856 del, 5538 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/scoring/8.0.5.tra
# # # %WER 6.36 [ 11427 / 179809, 2264 ins, 3623 del, 5540 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/scoring/7.1.0.tra
# # # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # # INFO:root:exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other/scoring/9.0.0.tra.txt: score 0.1876 wer 9.96% lm_ppl 6.5765 gt_wer 6.68%
# # # INFO:root:exp_train/10.5uer_960_2k_5k_-1_-1/tri3b/decode4g_dev_other.si/scoring/9.0.0.tra.txt: score 0.1840 wer 9.81% lm_ppl 6.5337 gt_wer 6.41%
# 
# 
# # Align pseudo transcript decoded from the HMM system
# # for speaker-adapted systems, set si=true for speaker independent decoding
# lmparam=9.0.0
# si=true
# new_dir=./output/w2v_pca128_10.5uer_decode_$(basename $exp_dir)_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
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
# # WER on train is 4.66 [ 1561976 / 33540234, 542304 ins, 330434 del, 689238 sub ] 94.51 [ 265789 / 281241 ] 281241 sentences, 0 not present in hyp.
# # WER on dev_other is 6.41 [ 11529 / 179809, 2631 ins, 3332 del, 5566 sub ] 82.82 [ 2372 / 2864 ] 2864 sentences, 0 not present in hyp.
# 
# # ali_dir=exp_align/w2v_pca128_11uer/tri3b/decodetext_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
# # local/write_ali_int.sh --splits "dev_other train" $exp_root/$exp_name/tri3b $new_dir/data $dir/data/lang_test $ali_dir
# 
# 
# # --------------------------------------------------------------------------------
# new_dir=./output/w2v_pca128_10.5uer_decode_tri3b_4g_9_0_0
# # for split in $valid_name $train_name; do
# #   echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
# #   utils/fix_data_dir.sh $new_dir/data/$split
# # done
# 
# 
# exp_root=exp_train
# exp_name=10.5uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1
# # # local/train_subset.sh --out_root $exp_root --out_name $exp_name \
# # #   --train $train_name --valid $valid_name \
# # #   --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
# # #   --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
# # # local/show_wer.sh --ref_data $dir/data $exp_root/$exp_name
# # # local/unsup_select_decode.sh --ref_data $dir/data --psd_data $new_dir/data --dec_name decode $exp_root/$exp_name
# 
# 
# # lm_4gram=/checkpoint/abaevski/data/speech/libri/librispeech_lm_novox.phnc_o4.arpa
# # exp_dir=$exp_root/$exp_name/tri2b
# # decode_suffix=4g
# # local/prepare_lm.sh --lmdir $dir/data/lang_test_4gram $lm_4gram $dir/data
# # local/decode.sh --decode_suffix $decode_suffix --decode_script "steps/decode.sh" --graph_name graph_4g --val_sets "dev_other" $exp_dir $new_dir/data $dir/data/lang_test_4gram
# # local/show_wer.sh --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# # local/unsup_select_decode.sh --ref_data $dir/data --psd_data $new_dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name




# --------------------------------------------------------------------------------
# TODO: *.tsv and dev_other.* are missing, using 10.5% PER pseudo transcript for missing ones
# train on 8.1% PER pseudo transcripts
new_label_dir=/checkpoint/abaevski/asr/unsup/data/segmented/transcriptions/final_phncs0.25_16.9/gan/phones/
new_dir=./output/w2v_pca128_8.1uer
label=txt
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
# WER on dev_other is 8.12 [ 14602 / 179809, 4246 ins, 4862 del, 5494 sub ] 84.92 [ 2432 / 2864 ] 2864 sentences, 0 not present in hyp.
# WER on train is 6.69 [ 2244831 / 33540234, 838442 ins, 716865 del, 689524 sub ] 96.28 [ 270777 / 281241 ] 281241 sentences, 0 not present in hyp.



exp_root=exp_train
exp_name=8.1uer_960_2k_5k_-1_-1
# local/train_subset.sh --out_root $exp_root --out_name $exp_name \
#   --train $train_name --valid $valid_name \
#   --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
# local/show_wer.sh --ref_data $dir/data $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 9.99 [ 18328 / 183426, 4479 ins, 9472 del, 4377 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode4g_dev_other/wer_8_0.0
# # %WER 9.85 [ 18076 / 183426, 4616 ins, 9103 del, 4357 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode4g_dev_other.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 6.11 [ 10992 / 179809, 2035 ins, 3411 del, 5546 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode4g_dev_other/scoring/8.0.0.tra
# # %WER 5.97 [ 10731 / 179809, 2128 ins, 2998 del, 5605 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode4g_dev_other.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 6.11 [ 10992 / 179809, 2035 ins, 3411 del, 5546 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode4g_dev_other/scoring/8.0.0.tra
# # %WER 5.95 [ 10702 / 179809, 1970 ins, 3195 del, 5537 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode4g_dev_other.si/scoring/8.0.0.tra
# # wnhsu@devfair0416:am_score$ local/show_wer.sh --ref_data output/w2v_pca128_0412/data exp_train/8.1uer_960_2k_5k_-1_-1/
# # ==== WER w.r.t. pseudo transcript
# # %WER 20.60 [ 37784 / 183426, 6095 ins, 18895 del, 12794 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//mono/decode_dev_other/wer_8_0.0
# # %WER 14.80 [ 27154 / 183426, 7054 ins, 11101 del, 8999 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri1/decode_dev_other/wer_17_1.0
# # %WER 10.74 [ 19694 / 183426, 4701 ins, 10207 del, 4786 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri2b/decode_dev_other/wer_7_0.0
# # %WER 10.94 [ 20060 / 183426, 4662 ins, 10502 del, 4896 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode_dev_other/wer_7_0.0
# # %WER 10.72 [ 19662 / 183426, 4630 ins, 10166 del, 4866 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode_dev_other.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 17.96 [ 32299 / 179809, 4533 ins, 13716 del, 14050 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//mono/decode_dev_other/scoring/8.0.0.tra
# # %WER 11.56 [ 20793 / 179809, 4962 ins, 5392 del, 10439 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri1/decode_dev_other/scoring/17.1.0.tra
# # %WER 7.16 [ 12867 / 179809, 2293 ins, 4182 del, 6392 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri2b/decode_dev_other/scoring/7.0.0.tra
# # %WER 7.40 [ 13304 / 179809, 2288 ins, 4511 del, 6505 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode_dev_other/scoring/7.0.0.tra
# # %WER 7.15 [ 12851 / 179809, 2215 ins, 4134 del, 6502 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode_dev_other.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 17.96 [ 32299 / 179809, 4533 ins, 13716 del, 14050 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//mono/decode_dev_other/scoring/8.0.0.tra
# # %WER 11.56 [ 20793 / 179809, 4962 ins, 5392 del, 10439 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri1/decode_dev_other/scoring/17.1.0.tra
# # %WER 7.16 [ 12867 / 179809, 2293 ins, 4182 del, 6392 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri2b/decode_dev_other/scoring/7.0.0.tra
# # %WER 7.40 [ 13304 / 179809, 2288 ins, 4511 del, 6505 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode_dev_other/scoring/7.0.0.tra
# # %WER 7.15 [ 12851 / 179809, 2215 ins, 4134 del, 6502 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode_dev_other.si/scoring/7.0.0.tra

# lm_4gram=/checkpoint/abaevski/data/speech/libri/librispeech_lm_novox.phnc_o4.arpa
# exp_dir=$exp_root/$exp_name/tri3b
# decode_suffix=4g
# local/prepare_lm.sh --lmdir $dir/data/lang_test_4gram $lm_4gram $dir/data
# local/decode.sh --decode_suffix $decode_suffix --graph_name graph_4g --val_sets "train dev_other" $exp_dir $new_dir/data $dir/data/lang_test_4gram
# local/show_wer.sh --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# local/unsup_select_decode.sh --ref_data $dir/data --psd_data $new_dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 9.99 [ 18328 / 183426, 4479 ins, 9472 del, 4377 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode4g_dev_other/wer_8_0.0
# # %WER 9.85 [ 18076 / 183426, 4616 ins, 9103 del, 4357 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode4g_dev_other.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 6.11 [ 10992 / 179809, 2035 ins, 3411 del, 5546 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode4g_dev_other/scoring/8.0.0.tra
# # %WER 5.97 [ 10731 / 179809, 2128 ins, 2998 del, 5605 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode4g_dev_other.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 6.11 [ 10992 / 179809, 2035 ins, 3411 del, 5546 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode4g_dev_other/scoring/8.0.0.tra
# # %WER 5.95 [ 10702 / 179809, 1970 ins, 3195 del, 5537 sub ] exp_train/8.1uer_960_2k_5k_-1_-1//tri3b/decode4g_dev_other.si/scoring/8.0.0.tra


# # Align pseudo transcript decoded from the HMM system
# # for speaker-adapted systems, set si=true for speaker independent decoding
# lmparam=9.0.0
# si=true
# new_dir=./output/w2v_pca128_8.1uer_decode_$(basename $exp_dir)_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
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
# # ali_dir=exp_align/w2v_pca128_11uer/tri3b/decodetext_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
# # local/write_ali_int.sh --splits "dev_other train" $exp_root/$exp_name/tri3b $new_dir/data $dir/data/lang_test $ali_dir
# 

