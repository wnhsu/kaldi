#!/bin/bash

set -eu


# train on real transcripts
dir=./output/w2v_pca128
w2v_dir=/checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_unfiltered_pca128
label=phnc
label_word=wrd
arpa_lm=/private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data/local/lm/3-gram.pruned.3e-7.arpa.gz
lexicon=/checkpoint/abaevski/data/speech/libri/lexicon_phones_compact.lst
train_name="train"
valid_name="dev_other"

local/prepare_lang_word.sh $w2v_dir/dict.${label}.txt $dir/data $lexicon
local/prepare_lm.sh --langdir $dir/data/lang_word --lmdir $dir/data/lang_test_word $arpa_lm $dir/data

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
