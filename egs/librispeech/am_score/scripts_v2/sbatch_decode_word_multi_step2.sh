#!/bin/bash
#SBATCH --time=72:00:00
#SBATCH --partition=devlab,learnlab
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=80
#SBATCH --mem=380G
#SBATCH --exclusive
#SBATCH --output=./log/decode_word_multi-step2-%j.out

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
dec_lmparam=$lmparam
dec_suffix=word

out_root=/checkpoint/abaevski/asr/unsup/kaldi_hmm/multi/$lg/$suffix
exp_root=$out_root/out
exp_name=${lg}_hmm
data_dir=$out_root/data
wrd_data_dir=$out_root/data_word

# ===== OUTPUT
dec_data_dir=$out_root/hmm_dec_data_word


# ===== MAIN

local/decode.sh --nj 80 --graph_name graph${dec_suffix} --decode_suffix $dec_suffix \
  --val_sets "$train_name" --decode_script $dec_script \
  $exp_root/$exp_name/$dec_exp $data_dir $data_dir/lang_test_word
wait

for split in $train_name $valid_name; do
  mkdir -p $dec_data_dir/$split
  cp $data_dir/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $dec_data_dir/$split

  tra=$exp_root/$exp_name/$dec_exp/decode${dec_suffix}_${split}/scoring/${dec_lmparam}.tra
  cat $tra | utils/int2sym.pl -f 2- $data_dir/lang_word/words.txt | sed 's:\<UNK\>::g' > $dec_data_dir/$split/text
  utils/fix_data_dir.sh $dec_data_dir/$split
done

