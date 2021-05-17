#!/bin/bash
#SBATCH --time=72:00:00
#SBATCH --partition=devlab,learnlab
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --output=./log/train_ls960_v2-%j.out

set -eu


# ===== INPUT
w2v_dir=/checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_full_pca128/
label=phnc
arpa_lm=/private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data_phn_mfcc/local/lm_phn/lm_phone_bg.arpa
train_name="train"
valid_name="dev_other"

w2v_pseudo_dir=/checkpoint/abaevski/asr/unsup/data/segmented/transcriptions/final_phncs0.25_16.9/gan/phones
w2v_pseudo_lab=txt

train_real=true

dec_exps=(
  "tri3b"
  "tri4b"
  "tri5b"
)
dec_scripts=(
  "steps/decode_fmllr.sh"
  "steps/decode_fmllr.sh"
  "steps/decode_fmllr.sh"
)

other_lms=(
  "/checkpoint/abaevski/data/speech/libri/librispeech_lm_novox.phnc_o4.arpa"
)
other_lm_suffixs=(
  "4g"
)


# ===== OUTPUT
exp_root=./output_v2/w2v_librispeech_pca128_v2/exp

data_dir=./output_v2/w2v_librispeech_pca128_v2
exp_name=librispeech_gt_full

pseudo_data_dir=./output_v2/w2v_librispeech_pca128_8.1uer_v2
pseudo_exp_name=librispeech_8.1uer_full


# ===== RESULT


# ===== Training on Real Transcripts
local/prepare_lang.sh $(dirname $w2v_dir)/dict.${label}.txt $data_dir/data
local/prepare_lm.sh $arpa_lm $data_dir/data
for split in $train_name $valid_name; do
  python local/prepare_data_from_w2v.py $w2v_dir $data_dir/data $split --label $label
  steps/compute_cmvn_stats.sh $data_dir/data/$split $data_dir/make_feat/$split $data_dir/feats/$split
done

if $train_real; then
  local/train_subset_librispeech.sh --out_root $exp_root --out_name $exp_name \
    --train $train_name --valid $valid_name \
    --stage 1 --max_stage 7 $data_dir/data $data_dir/data/lang $data_dir/data/lang_test
  local/show_wer.sh --split $valid_name --ref_data $data_dir/data $exp_root/$exp_name
  # ==== WER w.r.t. real transcript (select based on true WER)
  # %WER 16.58 [ 29805 / 179809, 3758 ins, 11972 del, 14075 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_gt_full/mono/decode_dev_other/scoring/8.0.0.tra
  # %WER 10.53 [ 18938 / 179809, 3983 ins, 4986 del, 9969 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_gt_full/tri1/decode_dev_other/scoring/17.1.0.tra
  # %WER 6.04 [ 10858 / 179809, 1732 ins, 3293 del, 5833 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_gt_full/tri2b/decode_dev_other/scoring/7.0.0.tra
  # %WER 6.24 [ 11215 / 179809, 1746 ins, 3522 del, 5947 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_gt_full/tri3b/decode_dev_other/scoring/7.0.0.tra
  # %WER 6.02 [ 10831 / 179809, 1665 ins, 3365 del, 5801 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_gt_full/tri3b/decode_dev_other.si/scoring/7.0.0.tra
  # %WER 5.56 [ 9993 / 179809, 1514 ins, 3198 del, 5281 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_gt_full/tri4b/decode_dev_other/scoring/7.0.0.tra
  # %WER 5.38 [ 9679 / 179809, 1427 ins, 3019 del, 5233 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_gt_full/tri4b/decode_dev_other.si/scoring/7.0.0.tra
  # %WER 5.13 [ 9223 / 179809, 1254 ins, 3062 del, 4907 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_gt_full/tri5b/decode_dev_other/scoring/7.0.0.tra
  # %WER 5.02 [ 9018 / 179809, 1221 ins, 2926 del, 4871 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_gt_full/tri5b/decode_dev_other.si/scoring/7.0.0.tra
  # %WER 5.13 [ 9230 / 179809, 1235 ins, 3093 del, 4902 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_gt_full/tri6b/decode_dev_other/scoring/7.0.0.tra
  # %WER 5.02 [ 9018 / 179809, 1219 ins, 2944 del, 4855 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_gt_full/tri6b/decode_dev_other.si/scoring/7.0.0.tra
fi


# ===== Training on 8.1% PER pseudo transcripts
# /private/home/wnhsu/libs/kaldi/egs/librispeech/am_score/./log/train_ls960_v2-41228194.out
for split in $valid_name $train_name; do
  mkdir -p $pseudo_data_dir/data/$split
  python local/copy_text.py --last_n=1 \
    $w2v_dir/$split.tsv $w2v_pseudo_dir/$split.tsv \
    $w2v_pseudo_dir/$split.$w2v_pseudo_lab $pseudo_data_dir/data/$split/raw_text

  cp $data_dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $pseudo_data_dir/data/$split
  cut -d' ' -f1 $data_dir/data/$split/text > $pseudo_data_dir/data/$split/uids
  paste -d' ' $pseudo_data_dir/data/$split/uids $pseudo_data_dir/data/$split/raw_text > $pseudo_data_dir/data/$split/text

  echo "WER on $split is" $(compute-wer ark:$data_dir/data/$split/text ark:$pseudo_data_dir/data/$split/text | cut -d" " -f2-)
done

local/train_subset_librispeech.sh --out_root $exp_root --out_name $pseudo_exp_name \
  --train $train_name --valid $valid_name \
  --stage 1 --max_stage 6 $pseudo_data_dir/data $data_dir/data/lang $data_dir/data/lang_test
local/show_wer.sh --split $valid_name --ref_data $data_dir/data $exp_root/$pseudo_exp_name
local/unsup_select_decode.sh --split $valid_name \
  --ref_data $data_dir/data --psd_data $pseudo_data_dir/data \
  --dec_name decode $exp_root/$pseudo_exp_name
# ==== WER w.r.t. pseudo transcript
# %WER 18.04 [ 32324 / 179193, 5360 ins, 15187 del, 11777 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//mono/decode_dev_other/wer_9_0.0
# %WER 12.26 [ 21968 / 179193, 6994 ins, 6984 del, 7990 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri1/decode_dev_other/wer_17_1.0
# %WER 8.24 [ 14769 / 179193, 4857 ins, 5927 del, 3985 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri2b/decode_dev_other/wer_7_0.0
# %WER 8.45 [ 15144 / 179193, 4692 ins, 6348 del, 4104 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri3b/decode_dev_other/wer_7_0.0
# %WER 8.14 [ 14590 / 179193, 4626 ins, 5989 del, 3975 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri3b/decode_dev_other.si/wer_7_0.0
# %WER 7.92 [ 14185 / 179193, 4410 ins, 6206 del, 3569 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri4b/decode_dev_other/wer_7_0.0
# %WER 7.71 [ 13819 / 179193, 4385 ins, 5887 del, 3547 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri4b/decode_dev_other.si/wer_7_0.0
# %WER 7.78 [ 13935 / 179193, 4274 ins, 6274 del, 3387 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri5b/decode_dev_other/wer_7_0.0
# %WER 7.61 [ 13632 / 179193, 4292 ins, 5996 del, 3344 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri5b/decode_dev_other.si/wer_7_0.0
# ==== WER w.r.t. real transcript (select based on pseudo WER)
# %WER 17.74 [ 31902 / 179809, 3732 ins, 14175 del, 13995 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//mono/decode_dev_other/scoring/9.0.0.tra
# %WER 11.49 [ 20652 / 179809, 4775 ins, 5381 del, 10496 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri1/decode_dev_other/scoring/17.1.0.tra
# %WER 7.30 [ 13126 / 179809, 2494 ins, 4180 del, 6452 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri2b/decode_dev_other/scoring/7.0.0.tra
# %WER 7.51 [ 13502 / 179809, 2390 ins, 4662 del, 6450 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri3b/decode_dev_other/scoring/7.0.0.tra
# %WER 7.23 [ 12996 / 179809, 2278 ins, 4257 del, 6461 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri3b/decode_dev_other.si/scoring/7.0.0.tra
# %WER 6.96 [ 12511 / 179809, 2047 ins, 4459 del, 6005 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri4b/decode_dev_other/scoring/7.0.0.tra
# %WER 6.70 [ 12048 / 179809, 1976 ins, 4094 del, 5978 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri4b/decode_dev_other.si/scoring/7.0.0.tra
# %WER 6.76 [ 12150 / 179809, 1903 ins, 4519 del, 5728 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri5b/decode_dev_other/scoring/7.0.0.tra
# %WER 6.55 [ 11784 / 179809, 1869 ins, 4189 del, 5726 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri5b/decode_dev_other.si/scoring/7.0.0.tra
# ==== WER w.r.t. real transcript (select based on true WER)
# %WER 17.73 [ 31880 / 179809, 4354 ins, 13414 del, 14112 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//mono/decode_dev_other/scoring/8.0.0.tra
# %WER 11.49 [ 20652 / 179809, 4775 ins, 5381 del, 10496 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri1/decode_dev_other/scoring/17.1.0.tra
# %WER 7.30 [ 13126 / 179809, 2494 ins, 4180 del, 6452 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri2b/decode_dev_other/scoring/7.0.0.tra
# %WER 7.51 [ 13502 / 179809, 2390 ins, 4662 del, 6450 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri3b/decode_dev_other/scoring/7.0.0.tra
# %WER 7.23 [ 12996 / 179809, 2278 ins, 4257 del, 6461 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri3b/decode_dev_other.si/scoring/7.0.0.tra
# %WER 6.96 [ 12511 / 179809, 2047 ins, 4459 del, 6005 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri4b/decode_dev_other/scoring/7.0.0.tra
# %WER 6.70 [ 12048 / 179809, 1976 ins, 4094 del, 5978 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri4b/decode_dev_other.si/scoring/7.0.0.tra
# %WER 6.76 [ 12150 / 179809, 1903 ins, 4519 del, 5728 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri5b/decode_dev_other/scoring/7.0.0.tra
# %WER 6.55 [ 11784 / 179809, 1869 ins, 4189 del, 5726 sub ] ./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full//tri5b/decode_dev_other.si/scoring/7.0.0.tra


# ===== Decoding other ngram
for j in ${!other_lms[@]}; do
  arpa_lm=${other_lms[j]}
  suffix=${other_lm_suffixs[j]}

  for i in ${!dec_exps[@]}; do  
    local/prepare_lm.sh --lmdir $data_dir/data/lang_test_${suffix} $arpa_lm $data_dir/data
    local/decode.sh --decode_suffix $suffix --graph_name graph${suffix} \
      --val_sets "$valid_name" --decode_script ${dec_scripts[i]} \
      $exp_root/$pseudo_exp_name/${dec_exps[i]} $pseudo_data_dir/data $data_dir/data/lang_test_${suffix}
  done
done

wait

for j in ${!other_lms[@]}; do
  suffix=${other_lm_suffixs[j]}
  local/unsup_select_decode.sh --split $valid_name \
    --ref_data $data_dir/data --psd_data $pseudo_data_dir/data \
    --dec_name decode${suffix} $exp_root/$pseudo_exp_name
done
# ==== WER w.r.t. real transcript (select based on unsupervised metric)
# INFO:root:./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full/tri3b/decode4g_dev_other/scoring/8.0.0.tra.txt: score 0.1436 wer 7.59% lm_ppl 6.6374 gt_wer 6.25%
# INFO:root:./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full/tri3b/decode4g_dev_other.si/scoring/8.0.0.tra.txt: score 0.1391 wer 7.37% lm_ppl 6.6025 gt_wer 6.04%
# INFO:root:./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full/tri4b/decode4g_dev_other/scoring/8.0.0.tra.txt: score 0.1366 wer 7.30% lm_ppl 6.5004 gt_wer 5.92%
# INFO:root:./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full/tri4b/decode4g_dev_other.si/scoring/7.0.5.tra.txt: score 0.1347 wer 7.18% lm_ppl 6.5281 gt_wer 5.77%
# INFO:root:./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full/tri5b/decode4g_dev_other/scoring/7.0.0.tra.txt: score 0.1321 wer 7.09% lm_ppl 6.4378 gt_wer 5.67%
# INFO:root:./output_v2/w2v_librispeech_pca128_v2/exp/librispeech_8.1uer_full/tri5b/decode4g_dev_other.si/scoring/7.0.5.tra.txt: score 0.1307 wer 7.03% lm_ppl 6.4239 gt_wer 5.57%
