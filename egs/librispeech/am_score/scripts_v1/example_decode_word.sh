#!/bin/bash

set -eu

. ./cmd.sh

dir=./output/w2v_pca128_0412
wrd_dir=./output/w2v_pca128_0412_word
w2v_dir=/checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_full_pca128/
label=phnc
label_word=wrd
arpa_lm=/private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data/local/lm/3-gram.pruned.3e-7.arpa.gz

other_arpa_lms=("/private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data/local/lm/lm_tgmed.arpa.gz")
other_arpa_lm_names=("tgmed")

other_const_lms=(
  "/private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data/local/lm/lm_tglarge.arpa.gz"
  "/private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data/local/lm/lm_fglarge.arpa.gz"
)
other_const_lm_names=("tglarge" "fglarge")

lexicon=/checkpoint/abaevski/data/speech/libri/lexicon_phones_compact.lst
train_name="train"
valid_name="dev_other"


# lexicon_clean=$(mktemp)
# cat $lexicon | sort | uniq > $lexicon_clean
# local/prepare_lang_word.sh $(dirname $w2v_dir)/dict.${label}.txt $dir/data $lexicon_clean
# rm $lexicon_clean
# 
# local/prepare_lm.sh --langdir $dir/data/lang_word --lmdir $dir/data/lang_test_word $arpa_lm $dir/data
# for idx in ${!other_arpa_lms[@]}; do
#   local/prepare_lm.sh --langdir $dir/data/lang_word \
#     --lmdir $dir/data/lang_test_word_${other_arpa_lm_names[idx]} \
#     ${other_arpa_lms[idx]} $dir/data
# done
# for idx in ${!other_const_lms[@]}; do
#   utils/build_const_arpa_lm.sh ${other_const_lms[idx]} \
#     $dir/data/lang_word $dir/data/lang_test_word_${other_const_lm_names[idx]}
# done


# for split in $train_name $valid_name; do
#   mkdir -p $wrd_dir/data/$split
# 
#   cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $wrd_dir/data/$split
#   cut -d' ' -f1 $dir/data/$split/text > $wrd_dir/data/$split/uids
#   paste -d' ' $wrd_dir/data/$split/uids $w2v_dir/$split.$label_word > $wrd_dir/data/$split/text
# done

# ========================================
# # decode a trained model into words
# new_dir=./output/w2v_pca128_13uer
# exp_root=exp_train
# exp_name=13uer_960_2k_5k_-1_-1
# exp_dir=$exp_root/$exp_name/tri3b
# decode_suffix=word3sm
# local/decode.sh --decode_suffix $decode_suffix --graph_name graph_${decode_suffix} \
#   --val_sets "dev_other" $exp_dir $new_dir/data $dir/data/lang_test_word
# local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 99.97 [ 185753 / 185811, 0 ins, 133327 del, 52426 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other/wer_7_0.0
# # %WER 99.97 [ 185758 / 185811, 0 ins, 133347 del, 52411 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 13.03 [ 6641 / 50948, 1891 ins, 354 del, 4396 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other/scoring/7.0.0.tra
# # %WER 12.71 [ 6474 / 50948, 1843 ins, 326 del, 4305 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 10.44 [ 5320 / 50948, 805 ins, 855 del, 3660 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other/scoring/17.0.0.tra
# # %WER 10.12 [ 5158 / 50948, 817 ins, 714 del, 3627 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other.si/scoring/16.0.0.tra
# 
# 
# ========================================
# # decode a trained model into words
# new_dir=./output/w2v_pca128_11uer
# exp_root=exp_train
# exp_name=11uer_960_2k_5k_-1_-1
# exp_dir=$exp_root/$exp_name/tri3b
# decode_suffix=word3sm
# local/decode.sh --decode_suffix $decode_suffix --graph_name graph_${decode_suffix} \
#   --val_sets "dev_other" $exp_dir $new_dir/data $dir/data/lang_test_word
# local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 99.96 [ 184499 / 184574, 0 ins, 132329 del, 52170 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other/wer_7_0.0
# # %WER 99.97 [ 184518 / 184574, 0 ins, 132800 del, 51718 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other.si/wer_10_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 12.01 [ 6118 / 50948, 1639 ins, 339 del, 4140 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other/scoring/7.0.0.tra
# # %WER 10.77 [ 5486 / 50948, 1228 ins, 400 del, 3858 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other.si/scoring/10.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 10.14 [ 5166 / 50948, 795 ins, 735 del, 3636 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other/scoring/16.0.0.tra
# # %WER 9.98 [ 5085 / 50948, 759 ins, 749 del, 3577 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other.si/scoring/17.0.0.tra
# 
# for name in ${other_arpa_lm_names[@]}; do
#   steps/lmrescore.sh --cmd "$decode_cmd" \
#     $dir/data/lang_test_word $dir/data/lang_test_word_${name} $new_dir/data/dev_other \
#     $exp_dir/decode${decode_suffix}_dev_other.si $exp_dir/decode${decode_suffix}_${name}_dev_other.si
#   local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix}_${name} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# done
# for name in ${other_const_lm_names[@]}; do
#   steps/lmrescore_const_arpa.sh --cmd "$decode_cmd" \
#     $dir/data/lang_test_word $dir/data/lang_test_word_${name} $new_dir/data/dev_other \
#     $exp_dir/decode${decode_suffix}_dev_other.si $exp_dir/decode${decode_suffix}_${name}_dev_other.si
#   local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix}_${name} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# done
# # ==== WER w.r.t. pseudo transcript
# # %WER 99.96 [ 184501 / 184574, 0 ins, 132349 del, 52152 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_tgmed_dev_other.si/wer_7_0.0
# # %WER 99.97 [ 184517 / 184574, 0 ins, 132750 del, 51767 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_tglarge_dev_other.si/wer_10_0.0
# # %WER 99.96 [ 184507 / 184574, 0 ins, 132368 del, 52139 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_fglarge_dev_other.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 11.36 [ 5790 / 50948, 1570 ins, 286 del, 3934 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_tgmed_dev_other.si/scoring/7.0.0.tra
# # %WER 9.30 [ 4740 / 50948, 1153 ins, 270 del, 3317 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_tglarge_dev_other.si/scoring/10.0.0.tra
# # %WER 10.29 [ 5242 / 50948, 1489 ins, 220 del, 3533 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_fglarge_dev_other.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 9.47 [ 4826 / 50948, 676 ins, 754 del, 3396 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_tgmed_dev_other.si/scoring/17.0.5.tra
# # %WER 8.60 [ 4379 / 50948, 725 ins, 563 del, 3091 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_tglarge_dev_other.si/scoring/17.0.5.tra
# # %WER 8.46 [ 4310 / 50948, 778 ins, 443 del, 3089 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_fglarge_dev_other.si/scoring/17.0.0.tra



# ========================================
# # decode a trained model into words
# new_dir=./output/w2v_pca128_11uer_decode_tri3b_4g_9_0_0
# exp_root=exp_train
# exp_name=11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1
# exp_dir=$exp_root/$exp_name/tri2b
# decode_suffix=word3sm
# # local/decode.sh --decode_suffix $decode_suffix --decode_script "steps/decode.sh" --graph_name graph_${decode_suffix} \
# #   --val_sets "dev_other" $exp_dir $new_dir/data $dir/data/lang_test_word
# # local/score.sh --min-lmwt 18 --max-lmwt 30 --cmd 'run.pl --mem 4G' $new_dir/data/dev_other $exp_dir/graph_${decode_suffix} $exp_dir/decode${decode_suffix}_dev_other
# # local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 99.95 [ 179828 / 179910, 1 ins, 127437 del, 52390 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decodeword3sm_dev_other/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 12.27 [ 6253 / 50948, 1794 ins, 262 del, 4197 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decodeword3sm_dev_other/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 9.69 [ 4937 / 50948, 831 ins, 545 del, 3561 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decodeword3sm_dev_other/scoring/20.0.0.tra
# 
# for name in ${other_arpa_lm_names[@]}; do
#   steps/lmrescore.sh --cmd "$decode_cmd" \
#     $dir/data/lang_test_word $dir/data/lang_test_word_${name} $new_dir/data/dev_other \
#     $exp_dir/decode${decode_suffix}_dev_other $exp_dir/decode${decode_suffix}_${name}_dev_other
#   local/score.sh --min-lmwt 18 --max-lmwt 30 --cmd 'run.pl --mem 4G' \
#     $new_dir/data/dev_other $exp_dir/graph_${decode_suffix} $exp_dir/decode${decode_suffix}_${name}_dev_other
#   local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix}_${name} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# done
# for name in ${other_const_lm_names[@]}; do
#   steps/lmrescore_const_arpa.sh --cmd "$decode_cmd" \
#     $dir/data/lang_test_word $dir/data/lang_test_word_${name} $new_dir/data/dev_other \
#     $exp_dir/decode${decode_suffix}_dev_other $exp_dir/decode${decode_suffix}_${name}_dev_other
#   local/score.sh --min-lmwt 18 --max-lmwt 30 --cmd 'run.pl --mem 4G' \
#     $new_dir/data/dev_other $exp_dir/graph_${decode_suffix} $exp_dir/decode${decode_suffix}_${name}_dev_other
#   local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix}_${name} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# done
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 11.86 [ 6040 / 50948, 1777 ins, 238 del, 4025 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decodeword3sm_tgmed_dev_other/scoring/7.0.0.tra
# # %WER 11.05 [ 5630 / 50948, 1706 ins, 200 del, 3724 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decodeword3sm_tglarge_dev_other/scoring/7.0.0.tra
# # %WER 10.91 [ 5558 / 50948, 1701 ins, 195 del, 3662 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decodeword3sm_fglarge_dev_other/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 9.21 [ 4692 / 50948, 779 ins, 544 del, 3369 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decodeword3sm_tgmed_dev_other/scoring/21.0.5.tra
# # %WER 8.50 [ 4333 / 50948, 845 ins, 375 del, 3113 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decodeword3sm_tglarge_dev_other/scoring/19.0.5.tra
# # %WER 8.44 [ 4299 / 50948, 859 ins, 366 del, 3074 sub ] exp_train/11uer_decode_tri3b_4g_9_0_0_960_2k_5k_-1_-1/tri2b/decodeword3sm_fglarge_dev_other/scoring/19.0.5.tra



# ========================================
# # decode a trained model into words
# new_dir=./output/w2v_pca128_10.5uer
# exp_root=exp_train
# exp_name=10.5uer_960_2k_5k_-1_-1
# exp_dir=$exp_root/$exp_name/tri2b
# decode_suffix=word3sm
# local/decode.sh --decode_suffix $decode_suffix --decode_script "steps/decode.sh" --graph_name graph_${decode_suffix} \
#   --val_sets "dev_other" $exp_dir $new_dir/data $dir/data/lang_test_word
# local/score.sh --min-lmwt 18 --max-lmwt 30 --cmd 'run.pl --mem 4G' $new_dir/data/dev_other $exp_dir/graph_${decode_suffix} $exp_dir/decode${decode_suffix}_dev_other
# local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# local/unsup_select_decode_word.sh --ref_data $wrd_dir/data --psd_data $new_dir/data \
#   --kenlm_path /checkpoint/abaevski/data/speech/libri/librispeech_lm_novox_o4.bin \
#   --dec_name decode${decode_suffix} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 13.53 [ 6892 / 50948, 1786 ins, 312 del, 4794 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_dev_other/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 11.12 [ 5667 / 50948, 827 ins, 828 del, 4012 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_dev_other/scoring/18.0.0.tra
# ==== WER w.r.t. real transcript (select based on unsupervised metric)
# INFO:root:exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_dev_other/scoring/12.0.0.tra.txt: score 0.5162 wer 9.68% lm_ppl 207.3741 gt_wer 11.68%

# for name in ${other_arpa_lm_names[@]}; do
#   steps/lmrescore.sh --cmd "$decode_cmd" \
#     $dir/data/lang_test_word $dir/data/lang_test_word_${name} $new_dir/data/dev_other \
#     $exp_dir/decode${decode_suffix}_dev_other $exp_dir/decode${decode_suffix}_${name}_dev_other
#   local/score.sh --min-lmwt 18 --max-lmwt 30 --cmd 'run.pl --mem 4G' \
#     $new_dir/data/dev_other $exp_dir/graph_${decode_suffix} $exp_dir/decode${decode_suffix}_${name}_dev_other
#   local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix}_${name} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# done
# for name in ${other_const_lm_names[@]}; do
#   steps/lmrescore_const_arpa.sh --cmd "$decode_cmd" \
#     $dir/data/lang_test_word $dir/data/lang_test_word_${name} $new_dir/data/dev_other \
#     $exp_dir/decode${decode_suffix}_dev_other $exp_dir/decode${decode_suffix}_${name}_dev_other
#   local/score.sh --min-lmwt 18 --max-lmwt 30 --cmd 'run.pl --mem 4G' \
#     $new_dir/data/dev_other $exp_dir/graph_${decode_suffix} $exp_dir/decode${decode_suffix}_${name}_dev_other
#   local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix}_${name} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# done
# local/unsup_select_decode_word.sh --ref_data $wrd_dir/data --psd_data $new_dir/data \
#   --kenlm_path /checkpoint/abaevski/data/speech/libri/librispeech_lm_novox_o4.bin \
#   --dec_name decode${decode_suffix}_fglarge --graph_name graph_${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 13.06 [ 6653 / 50948, 1728 ins, 290 del, 4635 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_tgmed_dev_other/scoring/7.0.0.tra
# # %WER 12.04 [ 6136 / 50948, 1662 ins, 238 del, 4236 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_tglarge_dev_other/scoring/7.0.0.tra
# # %WER 11.95 [ 6086 / 50948, 1663 ins, 224 del, 4199 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_fglarge_dev_other/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 10.76 [ 5484 / 50948, 812 ins, 737 del, 3935 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_tgmed_dev_other/scoring/16.0.5.tra
# # %WER 9.89 [ 5041 / 50948, 829 ins, 564 del, 3648 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_tglarge_dev_other/scoring/17.0.5.tra
# # %WER 9.74 [ 4964 / 50948, 833 ins, 531 del, 3600 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_fglarge_dev_other/scoring/17.0.5.tra
# # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # INFO:root:exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_fglarge_dev_other/scoring/11.0.0.tra.txt: score 0.4974 wer 9.56% lm_ppl 182.1740 gt_wer 10.45%

# local/decode.sh --decode_suffix $decode_suffix --decode_script "steps/decode.sh" --graph_name graph_${decode_suffix} \
#   --val_sets "train" $exp_dir $new_dir/data $dir/data/lang_test_word
# local/score.sh --min-lmwt 18 --max-lmwt 30 --cmd 'run.pl --mem 4G' $new_dir/data/train $exp_dir/graph_${decode_suffix} $exp_dir/decode${decode_suffix}_train
# local/show_wer.sh --split "train" --ref_data $wrd_dir/data --dec_name decode${decode_suffix} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 10.04 [ 944101 / 9403555, 267247 ins, 43767 del, 633087 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_train/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 8.01 [ 753085 / 9403555, 128044 ins, 89299 del, 535742 sub ] exp_train/10.5uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_train/scoring/18.0.0.tra

# steps/lmrescore_const_arpa.sh --cmd "$decode_cmd" \
#   $dir/data/lang_test_word $dir/data/lang_test_word_fglarge $new_dir/data/train \
#   $exp_dir/decode${decode_suffix}_train $exp_dir/decode${decode_suffix}_fglarge_train
# local/score.sh --min-lmwt 18 --max-lmwt 30 --cmd 'run.pl --mem 4G' \
#   $new_dir/data/train $exp_dir/graph_${decode_suffix} $exp_dir/decode${decode_suffix}_fglarge_train
# local/show_wer.sh --split "train" --ref_data $wrd_dir/data --dec_name decode${decode_suffix}_fglarge --graph_name graph_${decode_suffix} $exp_root/$exp_name

# decode_suffix=word3sm_fglarge
# lmparam=11.0.0
# si=false
# new_dir=./output/w2v_pca128_10.5uer_decode_$(basename $exp_dir)_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
# for split in train dev_other; do
#   mkdir -p $new_dir/data/$split
#   cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
# 
#   if $si; then
#     tra=$exp_dir/decode${decode_suffix}_${split}.si/scoring/${lmparam}.tra
#   else
#     tra=$exp_dir/decode${decode_suffix}_${split}/scoring/${lmparam}.tra
#   fi
#   cat $tra | utils/int2sym.pl -f 2- $dir/data/lang_word/words.txt | sed 's:\<UNK\>::g' > $new_dir/data/$split/text
#   utils/fix_data_dir.sh $new_dir/data/$split
#   echo "WER on $split is" $(compute-wer ark:$wrd_dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
# done
# # WER on train is 6.94 [ 652418 / 9403555, 173949 ins, 29049 del, 449420 sub ] 75.45 [ 212210 / 281241 ] 281241 sentences, 0 not present in hyp.
# # WER on dev_other is 10.45 [ 5324 / 50948, 1215 ins, 272 del, 3837 sub ] 66.10 [ 1893 / 2864 ] 2864 sentences, 0 not present in hyp.




# ========================================
# # decode a trained model into words
# new_dir=./output/w2v_pca128_8.1uer
# exp_root=exp_train
# exp_name=8.1uer_960_2k_5k_-1_-1
# exp_dir=$exp_root/$exp_name/tri2b
# decode_suffix=word3sm
# local/decode.sh --decode_suffix $decode_suffix --decode_script "steps/decode.sh" --graph_name graph_${decode_suffix} \
#   --val_sets "dev_other" $exp_dir $new_dir/data $dir/data/lang_test_word
# local/score.sh --min-lmwt 18 --max-lmwt 30 --cmd 'run.pl --mem 4G' $new_dir/data/dev_other $exp_dir/graph_${decode_suffix} $exp_dir/decode${decode_suffix}_dev_other
# local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# local/unsup_select_decode_word.sh --ref_data $wrd_dir/data --psd_data $new_dir/data \
#   --kenlm_path /checkpoint/abaevski/data/speech/libri/librispeech_lm_novox_o4.bin \
#   --dec_name decode${decode_suffix} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# ==== WER w.r.t. real transcript (select based on pseudo WER)
# %WER 13.17 [ 6712 / 50948, 1605 ins, 326 del, 4781 sub ] exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_dev_other/scoring/7.0.0.tra
# ==== WER w.r.t. real transcript (select based on true WER)
# %WER 10.81 [ 5509 / 50948, 726 ins, 773 del, 4010 sub ] exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_dev_other/scoring/18.0.0.tra
# ==== WER w.r.t. real transcript (select based on unsupervised metric)
# INFO:root:exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_dev_other/scoring/12.0.0.tra.txt: score 0.5180 wer 9.72% lm_ppl 206.7816 gt_wer 11.26%


# for name in ${other_arpa_lm_names[@]}; do
#   steps/lmrescore.sh --cmd "$decode_cmd" \
#     $dir/data/lang_test_word $dir/data/lang_test_word_${name} $new_dir/data/dev_other \
#     $exp_dir/decode${decode_suffix}_dev_other $exp_dir/decode${decode_suffix}_${name}_dev_other
#   local/score.sh --min-lmwt 18 --max-lmwt 30 --cmd 'run.pl --mem 4G' \
#     $new_dir/data/dev_other $exp_dir/graph_${decode_suffix} $exp_dir/decode${decode_suffix}_${name}_dev_other
#   local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix}_${name} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# done
# for name in ${other_const_lm_names[@]}; do
#   steps/lmrescore_const_arpa.sh --cmd "$decode_cmd" \
#     $dir/data/lang_test_word $dir/data/lang_test_word_${name} $new_dir/data/dev_other \
#     $exp_dir/decode${decode_suffix}_dev_other $exp_dir/decode${decode_suffix}_${name}_dev_other
#   local/score.sh --min-lmwt 18 --max-lmwt 30 --cmd 'run.pl --mem 4G' \
#     $new_dir/data/dev_other $exp_dir/graph_${decode_suffix} $exp_dir/decode${decode_suffix}_${name}_dev_other
#   local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix}_${name} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# done
# local/unsup_select_decode_word.sh --ref_data $wrd_dir/data --psd_data $new_dir/data \
#   --kenlm_path /checkpoint/abaevski/data/speech/libri/librispeech_lm_novox_o4.bin \
#   --dec_name decode${decode_suffix}_fglarge --graph_name graph_${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 12.74 [ 6493 / 50948, 1592 ins, 289 del, 4612 sub ] exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_tgmed_dev_other/scoring/7.0.0.tra
# # %WER 11.62 [ 5919 / 50948, 1490 ins, 239 del, 4190 sub ] exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_tglarge_dev_other/scoring/7.0.0.tra
# # %WER 11.52 [ 5868 / 50948, 1507 ins, 225 del, 4136 sub ] exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_fglarge_dev_other/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 10.37 [ 5281 / 50948, 708 ins, 674 del, 3899 sub ] exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_tgmed_dev_other/scoring/16.0.5.tra
# # %WER 9.50 [ 4842 / 50948, 713 ins, 560 del, 3569 sub ] exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_tglarge_dev_other/scoring/18.0.5.tra
# # %WER 9.40 [ 4789 / 50948, 747 ins, 501 del, 3541 sub ] exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_fglarge_dev_other/scoring/17.0.5.tra
# # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # INFO:root:exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_fglarge_dev_other/scoring/12.0.0.tra.txt: score 0.4999 wer 9.66% lm_ppl 176.8658 gt_wer 9.87%
# # INFO:root:exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_fglarge_dev_other/scoring/10.0.0.tra.txt: score 0.3806 wer 7.29% lm_ppl 185.0226 gt_wer 10.35%


# local/decode.sh --decode_suffix $decode_suffix --decode_script "steps/decode.sh" --graph_name graph_${decode_suffix} \
#   --val_sets "train" $exp_dir $new_dir/data $dir/data/lang_test_word
# local/score.sh --min-lmwt 18 --max-lmwt 30 --cmd 'run.pl --mem 4G' $new_dir/data/train $exp_dir/graph_${decode_suffix} $exp_dir/decode${decode_suffix}_train
# local/show_wer.sh --split "train" --ref_data $wrd_dir/data --dec_name decode${decode_suffix} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 9.67 [ 909106 / 9403555, 237593 ins, 43933 del, 627580 sub ] exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_train/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 7.74 [ 727466 / 9403555, 116740 ins, 85791 del, 524935 sub ] exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_train/scoring/18.0.0.tra
# 
# steps/lmrescore_const_arpa.sh --cmd "$decode_cmd" \
#   $dir/data/lang_test_word $dir/data/lang_test_word_fglarge $new_dir/data/train \
#   $exp_dir/decode${decode_suffix}_train $exp_dir/decode${decode_suffix}_fglarge_train
# local/show_wer.sh --split "train" --ref_data $wrd_dir/data --dec_name decode${decode_suffix}_fglarge --graph_name graph_${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 7.78 [ 731673 / 9403555, 210874 ins, 25283 del, 495516 sub ] exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_fglarge_train/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 6.20 [ 583202 / 9403555, 107446 ins, 55506 del, 420250 sub ] exp_train/8.1uer_960_2k_5k_-1_-1/tri2b/decodeword3sm_fglarge_train/scoring/17.1.0.tra


# decode_suffix=word3sm_fglarge
# lmparam=10.0.0
# si=false
# new_dir=./output/w2v_pca128_8.1uer_decode_$(basename $exp_dir)_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
# for split in train dev_other; do
#   mkdir -p $new_dir/data/$split
#   cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
# 
#   if $si; then
#     tra=$exp_dir/decode${decode_suffix}_${split}.si/scoring/${lmparam}.tra
#   else
#     tra=$exp_dir/decode${decode_suffix}_${split}/scoring/${lmparam}.tra
#   fi
#   cat $tra | utils/int2sym.pl -f 2- $dir/data/lang_word/words.txt | sed 's:\<UNK\>::g' > $new_dir/data/$split/text
#   utils/fix_data_dir.sh $new_dir/data/$split
#   echo "WER on $split is" $(compute-wer ark:$wrd_dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
# done
# # WER on train is 6.56 [ 616541 / 9403555, 149423 ins, 31344 del, 435774 sub ] 73.48 [ 206646 / 281241 ] 281241 sentences, 0 not present in hyp.
# # WER on dev_other is 9.87 [ 5028 / 50948, 1038 ins, 291 del, 3699 sub ] 64.35 [ 1843 / 2864 ] 2864 sentences, 0 not present in hyp.
# WER on train is 6.87 [ 645979 / 9403555, 166617 ins, 28277 del, 451085 sub ] 74.59 [ 209769 / 281241 ] 281241 sentences, 0 not present in hyp.
# WER on dev_other is 10.35 [ 5273 / 50948, 1177 ins, 259 del, 3837 sub ] 64.91 [ 1859 / 2864 ] 2864 sentences, 0 not present in hyp.
