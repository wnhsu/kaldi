#!/bin/bash
#SBATCH --time=72:00:00
#SBATCH --partition=devlab,learnlab
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=80
#SBATCH --mem=380G
#SBATCH --exclusive
#SBATCH --output=./log/decode_phones_multi-%j.out

set -eu


# ===== INPUT
train_name="train"
valid_name="valid"
valid_ref_name="valid_ref"

dec_exp="tri3b"
dec_script="steps/decode_fmllr.sh"
dec_lmparam=$lmparam

out_root=/checkpoint/abaevski/asr/unsup/kaldi_hmm/multi/$lg/$suffix
exp_root=$out_root/out
exp_name=${lg}_hmm
data_dir=$out_root/data

# ===== OUTPUT
dec_data_dir=$out_root/hmm_dec_data


# ===== MAIN
# NOTE: this assume that validation set has been decoded, which was used to
# determine lmparam

# local/show_wer.sh --split $valid_name --ref_data $data_dir $exp_root/$exp_name

local/decode.sh --nj 80 --graph_name graph \
  --val_sets "$train_name" --decode_script $dec_script \
  $exp_root/$exp_name/$dec_exp $data_dir $data_dir/lang_test

for split in $train_name $valid_name; do
  mkdir -p $dec_data_dir/$split
  cp $data_dir/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $dec_data_dir/$split

  tra=$exp_root/$exp_name/$dec_exp/decode_${split}/scoring/${lmparam}.tra
  cat $tra | utils/int2sym.pl -f 2- $data_dir/lang/words.txt | sed 's:\<UNK\>::g' > $dec_data_dir/$split/text
  utils/fix_data_dir.sh $dec_data_dir/$split
  echo "WER on $split is" $(compute-wer ark:$data_dir/$split/text ark:$dec_data_dir/$split/text | cut -d" " -f2-)
done

