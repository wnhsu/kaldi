#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --partition=devlab,learnlab
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --output=./log/train_timit-%j.out

set -eu


# ===== INPUT
w2v_dir=/checkpoint/wnhsu/data/timit/data/w2v_vox_lyr14/precompute_unfiltered_pca128
label=phnc
arpa_lm=/checkpoint/wnhsu/data/timit/lm/timit_train.phnc.o4.arpa
train_name="train"
valid_name="dev"
test_names="test test_cmp"

w2v_pseudo_dir=/checkpoint/wnhsu/data/timit/gan_hyp/20uer_transcripts/ngram
w2v_pseudo_lab=txt

train_real=true

dec_exps=("tri1" "tri2b" "tri3b")
dec_scripts=("steps/decode.sh" "steps/decode.sh" "steps/decode_fmllr.sh")

other_lms=(
  "/checkpoint/wnhsu/data/timit/lm/timit_train.phnc.o2.arpa"
  "/checkpoint/wnhsu/data/timit/lm/timit_train.phnc.o3.arpa"
)
other_lm_suffixs=("2g" "3g")


# ===== OUTPUT
exp_root=./output_v2/w2v_timit_pca128/exp

data_dir=./output_v2/w2v_timit_pca128
exp_name=timit_gt_nosil_gmm-200-6000

pseudo_data_dir=./output_v2/w2v_timit_pca128_17uer
pseudo_exp_name=timit_17uer_nosil_gmm-200-6000


# ===== RESULT
# ./log/sandbox_train_timit-41191238.out


# ===== Training on Real Transcripts
local/prepare_lang.sh --sil_prob 0.0 $w2v_dir/dict.${label}.txt $data_dir/data
local/prepare_lm.sh $arpa_lm $data_dir/data
for split in $train_name $valid_name $test_names; do
  python local/prepare_data_from_w2v.py $w2v_dir $data_dir/data $split --label $label
  steps/compute_cmvn_stats.sh $data_dir/data/$split $data_dir/make_feat/$split $data_dir/feats/$split
done

if $train_real; then
  local/train_subset.sh \
    --numLeavesTri1 200 --numGaussTri1 6000 --numLeavesMLLT 200 --numGaussMLLT 6000 \
    --numLeavesSAT 200 --numGaussSAT 6000 --out_root $exp_root --out_name $exp_name \
    --train $train_name --valid $valid_name \
    --mono_size -1 --tri1_size -1 --tri2b_size -1 --tri3b_size -1 \
    --stage 1 --max_stage 4 $data_dir/data $data_dir/data/lang $data_dir/data/lang_test
  local/show_wer.sh --split $valid_name --ref_data $data_dir/data $exp_root/$exp_name
  # ==== WER w.r.t. real transcript (select based on true WER)
  # %WER 13.52 [ 2036 / 15057, 439 ins, 625 del, 972 sub ] ./output_v2/w2v_timit_pca128_nosil/exp/timit_gt_nosil_gmm-200-6000/mono/decode_dev/scoring/14.0.0.tra
  # %WER 11.87 [ 1787 / 15057, 545 ins, 334 del, 908 sub ] ./output_v2/w2v_timit_pca128_nosil/exp/timit_gt_nosil_gmm-200-6000/tri1/decode_dev/scoring/17.1.0.tra
  # %WER 12.17 [ 1833 / 15057, 360 ins, 545 del, 928 sub ] ./output_v2/w2v_timit_pca128_nosil/exp/timit_gt_nosil_gmm-200-6000/tri2b/decode_dev/scoring/7.0.5.tra
  # %WER 12.03 [ 1811 / 15057, 291 ins, 609 del, 911 sub ] ./output_v2/w2v_timit_pca128_nosil/exp/timit_gt_nosil_gmm-200-6000/tri3b/decode_dev/scoring/7.1.0.tra
  # %WER 11.99 [ 1806 / 15057, 287 ins, 610 del, 909 sub ] ./output_v2/w2v_timit_pca128_nosil/exp/timit_gt_nosil_gmm-200-6000/tri3b/decode_dev.si/scoring/7.1.0.tra
fi


# ===== Training on 17% PER pseudo transcripts
for split in $valid_name $train_name $test_names; do
  mkdir -p $pseudo_data_dir/data/$split
  python local/copy_text.py --last_n=1 \
    $w2v_dir/$split.tsv $w2v_pseudo_dir/$split.tsv \
    $w2v_pseudo_dir/$split.$w2v_pseudo_lab $pseudo_data_dir/data/$split/raw_text

  cp $data_dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $pseudo_data_dir/data/$split
  cut -d' ' -f1 $data_dir/data/$split/text > $pseudo_data_dir/data/$split/uids
  paste -d' ' $pseudo_data_dir/data/$split/uids $pseudo_data_dir/data/$split/raw_text > $pseudo_data_dir/data/$split/text

  echo "WER on $split is" $(compute-wer ark:$data_dir/data/$split/text ark:$pseudo_data_dir/data/$split/text | cut -d" " -f2-)
done
# WER on train is 14.03 [ 19668 / 140225, 6159 ins, 5813 del, 7696 sub ] 96.78 [ 3577 / 3696 ] 3696 sentences, 0 not present in hyp.
# WER on dev is 17.02 [ 2563 / 15057, 749 ins, 927 del, 887 sub ] 98.75 [ 395 / 400 ] 400 sentences, 0 not present in hyp.
# WER on test is 17.84 [ 1287 / 7215, 393 ins, 415 del, 479 sub ] 98.96 [ 190 / 192 ] 192 sentences, 0 not present in hyp.

local/train_subset.sh \
  --numLeavesTri1 200 --numGaussTri1 6000 --numLeavesMLLT 200 --numGaussMLLT 6000 \
  --numLeavesSAT 200 --numGaussSAT 6000 --out_root $exp_root --out_name $pseudo_exp_name \
  --train $train_name --valid $valid_name \
  --mono_size -1 --tri1_size -1 --tri2b_size -1 --tri3b_size -1 \
  --stage 1 --max_stage 4 $pseudo_data_dir/data $data_dir/data/lang $data_dir/data/lang_test
local/show_wer.sh --split $valid_name --ref_data $data_dir/data $exp_root/$pseudo_exp_name
local/unsup_select_decode.sh --split $valid_name \
  --ref_data $data_dir/data --psd_data $pseudo_data_dir/data \
  --dec_name decode $exp_root/$pseudo_exp_name "--uppercase --skipwords sil"
# ==== WER w.r.t. pseudo transcript
# %WER 15.42 [ 2295 / 14879, 811 ins, 730 del, 754 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/mono/decode_dev/wer_13_0.5
# %WER 14.50 [ 2158 / 14879, 1078 ins, 455 del, 625 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri1/decode_dev/wer_16_1.0
# %WER 13.95 [ 2075 / 14879, 879 ins, 600 del, 596 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri2b/decode_dev/wer_7_0.0
# %WER 14.23 [ 2117 / 14879, 911 ins, 593 del, 613 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev/wer_7_0.0
# %WER 14.21 [ 2114 / 14879, 779 ins, 737 del, 598 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev.si/wer_7_0.5
# ==== WER w.r.t. real transcript (select based on pseudo WER)
# %WER 15.35 [ 2311 / 15057, 617 ins, 714 del, 980 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/mono/decode_dev/scoring/13.0.5.tra
# %WER 15.16 [ 2283 / 15057, 856 ins, 411 del, 1016 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri1/decode_dev/scoring/16.1.0.tra
# %WER 14.81 [ 2230 / 15057, 693 ins, 592 del, 945 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri2b/decode_dev/scoring/7.0.0.tra
# %WER 14.74 [ 2220 / 15057, 698 ins, 558 del, 964 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev/scoring/7.0.0.tra
# %WER 14.71 [ 2215 / 15057, 569 ins, 705 del, 941 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev.si/scoring/7.0.5.tra
# ==== WER w.r.t. real transcript (select based on true WER)
# %WER 15.28 [ 2300 / 15057, 661 ins, 671 del, 968 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/mono/decode_dev/scoring/11.0.5.tra
# %WER 15.12 [ 2277 / 15057, 831 ins, 427 del, 1019 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri1/decode_dev/scoring/17.1.0.tra
# %WER 14.81 [ 2230 / 15057, 693 ins, 592 del, 945 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri2b/decode_dev/scoring/7.0.0.tra
# %WER 14.70 [ 2213 / 15057, 566 ins, 704 del, 943 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev/scoring/7.0.5.tra
# %WER 14.71 [ 2215 / 15057, 569 ins, 705 del, 941 sub ] ./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev.si/scoring/7.0.5.tra
# ==== WER w.r.t. real transcript (select based on unsupervised metric)
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/mono/decode_dev/scoring/14.0.0.tra.txt: score 0.4734 wer 15.48% lm_ppl 21.3003 gt_wer 15.46%
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri1/decode_dev/scoring/17.1.0.tra.txt: score 0.4327 wer 14.50% lm_ppl 19.7801 gt_wer 15.12%
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri2b/decode_dev/scoring/7.0.0.tra.txt: score 0.4103 wer 13.95% lm_ppl 18.9567 gt_wer 14.81%
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev/scoring/7.0.0.tra.txt: score 0.4200 wer 14.23% lm_ppl 19.1407 gt_wer 14.74%
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev.si/scoring/7.0.0.tra.txt: score 0.4200 wer 14.26% lm_ppl 19.0067 gt_wer 14.80%


# ===== Decoding 4gram
for i in ${!dec_exps[@]}; do
  local/decode.sh --graph_name graph --val_sets "$train_name" --decode_script ${dec_scripts[i]} \
    $exp_root/$pseudo_exp_name/${dec_exps[i]} $pseudo_data_dir/data $data_dir/data/lang_test
done


# ===== Decoding other ngram
for j in ${!other_lms[@]}; do
  arpa_lm=${other_lms[j]}
  suffix=${other_lm_suffixs[j]}

  for i in ${!dec_exps[@]}; do  
    local/prepare_lm.sh --lmdir $data_dir/data/lang_test_${suffix} $arpa_lm $data_dir/data
    local/decode.sh --decode_suffix $suffix --graph_name graph${suffix} \
      --val_sets "$train_name $valid_name" --decode_script ${dec_scripts[i]} \
      $exp_root/$pseudo_exp_name/${dec_exps[i]} $pseudo_data_dir/data $data_dir/data/lang_test_${suffix}
  done
done

wait

for j in ${!other_lms[@]}; do
  suffix=${other_lm_suffixs[j]}
  local/unsup_select_decode.sh --split $valid_name \
    --ref_data $data_dir/data --psd_data $pseudo_data_dir/data \
    --dec_name decode${suffix} $exp_root/$pseudo_exp_name "--uppercase --skipwords sil"
done
# ==== WER w.r.t. real transcript (select based on unsupervised metric)
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri1/decode2g_dev/scoring/17.0.5.tra.txt: score 0.4449 wer 14.82% lm_ppl 20.1291 gt_wer 15.30%
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri2b/decode2g_dev/scoring/7.0.0.tra.txt: score 0.4190 wer 13.94% lm_ppl 20.2063 gt_wer 14.55%
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri3b/decode2g_dev/scoring/7.0.0.tra.txt: score 0.4200 wer 13.97% lm_ppl 20.2334 gt_wer 14.34%
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri3b/decode2g_dev.si/scoring/7.0.0.tra.txt: score 0.4198 wer 13.95% lm_ppl 20.2892 gt_wer 14.36%
# ==== WER w.r.t. real transcript (select based on unsupervised metric)
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri1/decode3g_dev/scoring/17.1.0.tra.txt: score 0.4308 wer 14.43% lm_ppl 19.8002 gt_wer 14.78%
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri2b/decode3g_dev/scoring/7.0.0.tra.txt: score 0.4054 wer 13.75% lm_ppl 19.0728 gt_wer 14.28%
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_dev/scoring/7.0.0.tra.txt: score 0.4054 wer 13.72% lm_ppl 19.2064 gt_wer 14.17%
# INFO:root:./output_v2/w2v_timit_pca128/exp/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_dev.si/scoring/7.0.0.tra.txt: score 0.4058 wer 13.72% lm_ppl 19.2369 gt_wer 14.15%
