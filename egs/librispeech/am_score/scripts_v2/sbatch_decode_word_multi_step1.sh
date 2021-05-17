#!/bin/bash
#SBATCH --time=72:00:00
#SBATCH --partition=devlab,learnlab
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=80
#SBATCH --mem=380G
#SBATCH --exclusive
#SBATCH --output=./log/decode_word_multi-step1-%j.out

set -eu


# ===== INPUT
w2v_dir=/checkpoint/michaelauli/aconneau/unsupasr/unsup_feat/$lg/silence/precompute_pca512
label=phnc
wrd_label=wrd

lexicon=/checkpoint/michaelauli/aconneau/unsupasr/data/lm/$lg/filtered/lexicon_filtered.lst
arpa_lm=/checkpoint/michaelauli/aconneau/unsupasr/data/lm/$lg/filtered/kenlm.wrd.o40003.arpa
arpa_lm_bin=/checkpoint/michaelauli/aconneau/unsupasr/data/lm/$lg/filtered/kenlm.wrd.o40003.bin

train_name="train"
valid_name="valid"
valid_ref_name="valid_ref"

dec_exp="tri3b"
dec_script="steps/decode_fmllr.sh"
dec_suffix=word

out_root=/checkpoint/abaevski/asr/unsup/kaldi_hmm/multi/$lg/$suffix
exp_root=$out_root/out
exp_name=${lg}_hmm
data_dir=$out_root/data
wrd_data_dir=$out_root/data_word

# ===== OUTPUT
dec_data_dir=$out_root/hmm_dec_data_word


# ===== MAIN

lexicon_clean=$(mktemp)
cat $lexicon | sort | uniq > $lexicon_clean
local/prepare_lang_word.sh $(dirname $w2v_dir)/dict.${label}.txt $data_dir $lexicon_clean
rm $lexicon_clean

local/prepare_lm.sh --langdir $data_dir/lang_word \
  --lmdir $data_dir/lang_test_word $arpa_lm $data_dir

for split in $valid_name; do
  mkdir -p $wrd_data_dir/$split
  cp $data_dir/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $wrd_data_dir/$split
  cut -d' ' -f1 $data_dir/$split/text > $wrd_data_dir/$split/uids
  paste -d' ' $wrd_data_dir/$split/uids $w2v_dir/$split.$wrd_label > $wrd_data_dir/$split/text
done

local/decode.sh --nj 80 --graph_name graph${dec_suffix} --decode_suffix $dec_suffix \
  --val_sets "$valid_name" --decode_script $dec_script \
  $exp_root/$exp_name/$dec_exp $data_dir $data_dir/lang_test_word
wait

local/show_wer.sh --split $valid_name --ref_data $wrd_data_dir \
  --dec_name decode${dec_suffix} --graph_name graph${dec_suffix} \
  $exp_root/$exp_name

local/unsup_select_decode_word.sh \
  --split $valid_name --ref_data $wrd_data_dir \
  --psd_data $data_dir --psd_split ${valid_name}_psd \
  --kenlm_path $arpa_lm_bin --dec_name decode${dec_suffix} \
  --graph_name graph${dec_suffix} \
  --phonemize_lexicon $data_dir/local/dict_word/lexicon.txt \
  $exp_root/$exp_name
