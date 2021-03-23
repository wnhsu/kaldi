#!/bin/bash

set -eu

. ./cmd.sh

# train on real transcripts
dir=./output/w2v_pca128
w2v_dir=/checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_unfiltered_pca128
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


local/prepare_lang_word.sh $w2v_dir/dict.${label}.txt $dir/data $lexicon
local/prepare_lm.sh --langdir $dir/data/lang_word --lmdir $dir/data/lang_test_word $arpa_lm $dir/data
for idx in ${!other_arpa_lms[@]}; do
  local/prepare_lm.sh --langdir $dir/data/lang_word \
    --lmdir $dir/data/lang_test_word_${other_arpa_lm_names[idx]} \
    ${other_arpa_lms[idx]} $dir/data
done
for idx in ${!other_const_lms[@]}; do
  utils/build_const_arpa_lm.sh ${other_const_lms[idx]} \
    $dir/data/lang_word $dir/data/lang_test_word_${other_const_lm_names[idx]}
done


wrd_dir=./output/w2v_pca128_word
for split in $train_name $valid_name; do
  mkdir -p $wrd_dir/data/$split

  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $wrd_dir/data/$split
  cut -d' ' -f1 $dir/data/$split/text > $wrd_dir/data/$split/uids
  paste -d' ' $wrd_dir/data/$split/uids $w2v_dir/$split.$label_word > $wrd_dir/data/$split/text
done


# decode a trained model into words
new_dir=./output/w2v_pca128_13uer
exp_root=exp_train
exp_name=13uer_960_2k_5k_-1_-1
exp_dir=$exp_root/$exp_name/tri3b
decode_suffix=word3sm
local/decode.sh --decode_suffix $decode_suffix --graph_name graph_${decode_suffix} \
  --val_sets "dev_other" $exp_dir $new_dir/data $dir/data/lang_test_word
local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# ==== WER w.r.t. pseudo transcript
# %WER 99.97 [ 185753 / 185811, 0 ins, 133327 del, 52426 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other/wer_7_0.0
# %WER 99.97 [ 185758 / 185811, 0 ins, 133347 del, 52411 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other.si/wer_7_0.0
# ==== WER w.r.t. real transcript (select based on pseudo WER)
# %WER 13.03 [ 6641 / 50948, 1891 ins, 354 del, 4396 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other/scoring/7.0.0.tra
# %WER 12.71 [ 6474 / 50948, 1843 ins, 326 del, 4305 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other.si/scoring/7.0.0.tra
# ==== WER w.r.t. real transcript (select based on true WER)
# %WER 10.44 [ 5320 / 50948, 805 ins, 855 del, 3660 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other/scoring/17.0.0.tra
# %WER 10.12 [ 5158 / 50948, 817 ins, 714 del, 3627 sub ] exp_train/13uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other.si/scoring/16.0.0.tra


# decode a trained model into words
new_dir=./output/w2v_pca128_11uer
exp_root=exp_train
exp_name=11uer_960_2k_5k_-1_-1
exp_dir=$exp_root/$exp_name/tri3b
decode_suffix=word3sm
local/decode.sh --decode_suffix $decode_suffix --graph_name graph_${decode_suffix} \
  --val_sets "dev_other" $exp_dir $new_dir/data $dir/data/lang_test_word
local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix} --graph_name graph_${decode_suffix} $exp_root/$exp_name
# ==== WER w.r.t. pseudo transcript
# %WER 99.96 [ 184499 / 184574, 0 ins, 132329 del, 52170 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other/wer_7_0.0
# %WER 99.97 [ 184518 / 184574, 0 ins, 132800 del, 51718 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other.si/wer_10_0.0
# ==== WER w.r.t. real transcript (select based on pseudo WER)
# %WER 12.01 [ 6118 / 50948, 1639 ins, 339 del, 4140 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other/scoring/7.0.0.tra
# %WER 10.77 [ 5486 / 50948, 1228 ins, 400 del, 3858 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other.si/scoring/10.0.0.tra
# ==== WER w.r.t. real transcript (select based on true WER)
# %WER 10.14 [ 5166 / 50948, 795 ins, 735 del, 3636 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other/scoring/16.0.0.tra
# %WER 9.98 [ 5085 / 50948, 759 ins, 749 del, 3577 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_dev_other.si/scoring/17.0.0.tra

for name in ${other_arpa_lm_names[@]}; do
  steps/lmrescore.sh --cmd "$decode_cmd" \
    $dir/data/lang_test_word $dir/data/lang_test_word_${name} $new_dir/data/dev_other \
    $exp_dir/decode${decode_suffix}_dev_other.si $exp_dir/decode${decode_suffix}_${name}_dev_other.si
  local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix}_${name} --graph_name graph_${decode_suffix} $exp_root/$exp_name
done
for name in ${other_const_lm_names[@]}; do
  steps/lmrescore_const_arpa.sh --cmd "$decode_cmd" \
    $dir/data/lang_test_word $dir/data/lang_test_word_${name} $new_dir/data/dev_other \
    $exp_dir/decode${decode_suffix}_dev_other.si $exp_dir/decode${decode_suffix}_${name}_dev_other.si
  local/show_wer.sh --ref_data $wrd_dir/data --dec_name decode${decode_suffix}_${name} --graph_name graph_${decode_suffix} $exp_root/$exp_name
done
# ==== WER w.r.t. pseudo transcript
# %WER 99.96 [ 184501 / 184574, 0 ins, 132349 del, 52152 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_tgmed_dev_other.si/wer_7_0.0
# %WER 99.97 [ 184517 / 184574, 0 ins, 132750 del, 51767 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_tglarge_dev_other.si/wer_10_0.0
# %WER 99.96 [ 184507 / 184574, 0 ins, 132368 del, 52139 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_fglarge_dev_other.si/wer_7_0.0
# ==== WER w.r.t. real transcript (select based on pseudo WER)
# %WER 11.36 [ 5790 / 50948, 1570 ins, 286 del, 3934 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_tgmed_dev_other.si/scoring/7.0.0.tra
# %WER 9.30 [ 4740 / 50948, 1153 ins, 270 del, 3317 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_tglarge_dev_other.si/scoring/10.0.0.tra
# %WER 10.29 [ 5242 / 50948, 1489 ins, 220 del, 3533 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_fglarge_dev_other.si/scoring/7.0.0.tra
# ==== WER w.r.t. real transcript (select based on true WER)
# %WER 9.47 [ 4826 / 50948, 676 ins, 754 del, 3396 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_tgmed_dev_other.si/scoring/17.0.5.tra
# %WER 8.60 [ 4379 / 50948, 725 ins, 563 del, 3091 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_tglarge_dev_other.si/scoring/17.0.5.tra
# %WER 8.46 [ 4310 / 50948, 778 ins, 443 del, 3089 sub ] exp_train/11uer_960_2k_5k_-1_-1/tri3b/decodeword3sm_fglarge_dev_other.si/scoring/17.0.0.tra
