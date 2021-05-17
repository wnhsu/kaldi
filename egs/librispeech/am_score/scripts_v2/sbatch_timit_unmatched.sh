#!/bin/bash
#SBATCH --time=12:00:00
#SBATCH --partition=devlab,learnlab
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --output=./log/train_timit_unmatched-%j.out

set -eu


# ===== INPUT
# ---------- real data
w2v_dir=/checkpoint/wnhsu/data/timit/data/w2v_vox_lyr14/precompute_unfiltered_pca128
label=phnc
arpa_lm=/checkpoint/wnhsu/data/timit/lm/timit_train_cmp_1000.phnc.o4.arpa
train_name="train_cmp_3000"
valid_name="train_cmp_620"
test_names="test test_cmp"

train_real=true

# ---------- pseudo data
w2v_pseudo_dir=/checkpoint/wnhsu/data/timit/gan_hyp/27uer_transcripts_ntu_nonmatched/ngram
w2v_pseudo_lab=txt

# ---------- decode models trained on pseudo data
dec_exps=("tri1" "tri2b" "tri3b")
dec_scripts=("steps/decode.sh" "steps/decode.sh" "steps/decode_fmllr.sh")

other_lms=(
  "/checkpoint/wnhsu/data/timit/lm/timit_train_cmp_1000.phnc.o2.arpa"
  "/checkpoint/wnhsu/data/timit/lm/timit_train_cmp_1000.phnc.o3.arpa"
)
other_lm_suffixs=("2g" "3g")

# ---------- dump labels for next round of self-training
it2_model_name=tri1
it2_decode_script="steps/decode.sh"
it2_decode_suffix=""
it2_decode_si_suffix=""  # for SI decoding of SAT models, add `.si`
it2_lmparam=17.1.0

# ===== OUTPUT
exp_root=./output_v2/w2v_timit_pca128_unmatched/exp

data_dir=./output_v2/w2v_timit_pca128_unmatched
exp_name=timit_gt_nosil_unmatched_gmm-200-6000

pseudo_data_dir=./output_v2/w2v_timit_pca128_unmatched_21uer
pseudo_exp_name=timit_21uer_nosil_unmatched_gmm-200-6000


# # ===== Training on Real Transcripts
# local/prepare_lang.sh --sil_prob 0.0 $w2v_dir/dict.${label}.txt $data_dir/data
# local/prepare_lm.sh $arpa_lm $data_dir/data
# for split in $train_name $valid_name $test_names; do
#   python local/prepare_data_from_w2v.py $w2v_dir $data_dir/data $split --label $label
#   steps/compute_cmvn_stats.sh $data_dir/data/$split $data_dir/make_feat/$split $data_dir/feats/$split
# done
# 
# if $train_real; then
#   local/train_subset.sh \
#     --numLeavesTri1 200 --numGaussTri1 6000 --numLeavesMLLT 200 --numGaussMLLT 6000 \
#     --numLeavesSAT 200 --numGaussSAT 6000 --out_root $exp_root --out_name $exp_name \
#     --train $train_name --valid $valid_name \
#     --mono_size -1 --tri1_size -1 --tri2b_size -1 --tri3b_size -1 \
#     --stage 1 --max_stage 4 $data_dir/data $data_dir/data/lang $data_dir/data/lang_test
#   local/show_wer.sh --split $valid_name --ref_data $data_dir/data $exp_root/$exp_name
# fi
# 
# 
# # ===== Training on 21% PER pseudo transcripts
# for split in $valid_name $train_name $test_names; do
#   mkdir -p $pseudo_data_dir/data/$split
#   python local/copy_text.py --last_n=1 \
#     $w2v_dir/$split.tsv $w2v_pseudo_dir/$split.tsv \
#     $w2v_pseudo_dir/$split.$w2v_pseudo_lab $pseudo_data_dir/data/$split/raw_text
# 
#   cp $data_dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $pseudo_data_dir/data/$split
#   cut -d' ' -f1 $data_dir/data/$split/text > $pseudo_data_dir/data/$split/uids
#   paste -d' ' $pseudo_data_dir/data/$split/uids $pseudo_data_dir/data/$split/raw_text > $pseudo_data_dir/data/$split/text
# 
#   echo "WER on $split is" $(compute-wer ark:$data_dir/data/$split/text ark:$pseudo_data_dir/data/$split/text | cut -d" " -f2-)
# done
# # WER on train_cmp_620 is 22.59 [ 7641 / 33831, 1498 ins, 3612 del, 2531 sub ] 100.00 [ 620 / 620 ] 620 sentences, 0 not present in hyp.
# # WER on train_cmp_3000 is 23.34 [ 24401 / 104568, 3527 ins, 12162 del, 8712 sub ] 99.60 [ 2988 / 3000 ] 3000 sentences, 0 not present in hyp.
# # WER on test is 22.27 [ 1607 / 7215, 301 ins, 759 del, 547 sub ] 100.00 [ 192 / 192 ] 192 sentences, 0 not present in hyp.
# # WER on test_cmp is 24.45 [ 15378 / 62901, 2312 ins, 7925 del, 5141 sub ] 99.94 [ 1679 / 1680 ] 1680 sentences, 0 not present in hyp.
# 
# 
# local/train_subset.sh \
#   --numLeavesTri1 200 --numGaussTri1 6000 --numLeavesMLLT 200 --numGaussMLLT 6000 \
#   --numLeavesSAT 200 --numGaussSAT 6000 --out_root $exp_root --out_name $pseudo_exp_name \
#   --train $train_name --valid $valid_name \
#   --mono_size -1 --tri1_size -1 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 4 $pseudo_data_dir/data $data_dir/data/lang $data_dir/data/lang_test
# local/show_wer.sh --split $valid_name --ref_data $data_dir/data $exp_root/$pseudo_exp_name
# local/unsup_select_decode.sh --split $valid_name \
#   --ref_data $data_dir/data --psd_data $pseudo_data_dir/data \
#   --dec_name decode $exp_root/$pseudo_exp_name "--uppercase --skipwords sil"
# 
# 
# # ===== Decoding 4gram
# for i in ${!dec_exps[@]}; do
#   local/decode.sh --graph_name graph --val_sets "$train_name" --decode_script ${dec_scripts[i]} \
#     $exp_root/$pseudo_exp_name/${dec_exps[i]} $pseudo_data_dir/data $data_dir/data/lang_test
# done
# # ==== WER w.r.t. pseudo transcript
# # %WER 20.41 [ 6475 / 31717, 2571 ins, 1820 del, 2084 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/mono/decode_train_cmp_620/wer_16_0.0
# # %WER 20.51 [ 6504 / 31717, 3008 ins, 1642 del, 1854 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode_train_cmp_620/wer_17_1.0
# # %WER 20.78 [ 6590 / 31717, 1961 ins, 2712 del, 1917 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode_train_cmp_620/wer_7_0.0
# # %WER 20.56 [ 6521 / 31717, 1966 ins, 2652 del, 1903 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_620/wer_7_0.0
# # %WER 20.55 [ 6519 / 31717, 1971 ins, 2649 del, 1899 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_620.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 20.60 [ 6968 / 33831, 1451 ins, 2814 del, 2703 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/mono/decode_train_cmp_620/scoring/16.0.0.tra
# # %WER 20.92 [ 7077 / 33831, 1841 ins, 2589 del, 2647 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode_train_cmp_620/scoring/17.1.0.tra
# # %WER 23.06 [ 7803 / 33831, 1162 ins, 4027 del, 2614 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode_train_cmp_620/scoring/7.0.0.tra
# # %WER 22.80 [ 7715 / 33831, 1144 ins, 3944 del, 2627 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_620/scoring/7.0.0.tra
# # %WER 22.77 [ 7702 / 33831, 1151 ins, 3943 del, 2608 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_620.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 20.53 [ 6944 / 33831, 1654 ins, 2606 del, 2684 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/mono/decode_train_cmp_620/scoring/12.0.0.tra
# # %WER 20.80 [ 7036 / 33831, 2088 ins, 2260 del, 2688 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode_train_cmp_620/scoring/16.0.5.tra
# # %WER 23.06 [ 7803 / 33831, 1162 ins, 4027 del, 2614 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode_train_cmp_620/scoring/7.0.0.tra
# # %WER 22.80 [ 7715 / 33831, 1144 ins, 3944 del, 2627 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_620/scoring/7.0.0.tra
# # %WER 22.77 [ 7702 / 33831, 1151 ins, 3943 del, 2608 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_620.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/mono/decode_train_cmp_620/scoring/17.0.0.tra.txt: score 0.6510 wer 20.45% lm_ppl 24.1192 gt_wer 20.76%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode_train_cmp_620/scoring/17.1.0.tra.txt: score 0.6445 wer 20.51% lm_ppl 23.1702 gt_wer 20.92%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode_train_cmp_620/scoring/7.0.0.tra.txt: score 0.6502 wer 20.78% lm_ppl 22.8622 gt_wer 23.06%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_620/scoring/7.0.0.tra.txt: score 0.6432 wer 20.56% lm_ppl 22.8347 gt_wer 22.80%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_620.si/scoring/7.0.0.tra.txt: score 0.6419 wer 20.55% lm_ppl 22.7187 gt_wer 22.77%
# # ==== WER w.r.t. real transcript (select based on unsupervised metric, TIMIT 4gram LM)
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/mono/decode_train_cmp_620/scoring/17.0.0.tra.txt: score 0.4490 wer 20.45% lm_ppl 8.9822 gt_wer 20.76%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode_train_cmp_620/scoring/17.1.0.tra.txt: score 0.4695 wer 20.51% lm_ppl 9.8713 gt_wer 20.92%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode_train_cmp_620/scoring/7.0.0.tra.txt: score 0.4342 wer 20.78% lm_ppl 8.0816 gt_wer 23.06%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_620/scoring/7.0.0.tra.txt: score 0.4311 wer 20.56% lm_ppl 8.1398 gt_wer 22.80%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_620.si/scoring/7.0.0.tra.txt: score 0.4307 wer 20.55% lm_ppl 8.1275 gt_wer 22.77%
# 
# 
# # ===== Decoding other ngram
# for j in ${!other_lms[@]}; do
#   arpa_lm=${other_lms[j]}
#   suffix=${other_lm_suffixs[j]}
# 
#   for i in ${!dec_exps[@]}; do  
#     local/prepare_lm.sh --lmdir $data_dir/data/lang_test_${suffix} $arpa_lm $data_dir/data
#     local/decode.sh --decode_suffix $suffix --graph_name graph${suffix} \
#       --val_sets "$train_name $valid_name" --decode_script ${dec_scripts[i]} \
#       $exp_root/$pseudo_exp_name/${dec_exps[i]} $pseudo_data_dir/data $data_dir/data/lang_test_${suffix}
#   done
# done
# 
# wait
# 
# for j in ${!other_lms[@]}; do
#   suffix=${other_lm_suffixs[j]}
#   local/unsup_select_decode.sh --split $valid_name \
#     --ref_data $data_dir/data --psd_data $pseudo_data_dir/data \
#     --dec_name decode${suffix} $exp_root/$pseudo_exp_name "--uppercase --skipwords sil"
# done
# # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode2g_train_cmp_620/scoring/17.0.5.tra.txt: score 0.6781 wer 21.44% lm_ppl 23.6372 gt_wer 21.25%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode2g_train_cmp_620/scoring/7.0.0.tra.txt: score 0.6919 wer 21.65% lm_ppl 24.4307 gt_wer 23.65%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode2g_train_cmp_620/scoring/7.0.0.tra.txt: score 0.6735 wer 21.17% lm_ppl 24.0842 gt_wer 23.14%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode2g_train_cmp_620.si/scoring/7.0.0.tra.txt: score 0.6747 wer 21.22% lm_ppl 24.0319 gt_wer 23.15%
# # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode3g_train_cmp_620/scoring/17.1.0.tra.txt: score 0.6549 wer 20.72% lm_ppl 23.5942 gt_wer 20.93%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode3g_train_cmp_620/scoring/7.0.0.tra.txt: score 0.6521 wer 20.80% lm_ppl 22.9960 gt_wer 22.84%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode3g_train_cmp_620/scoring/7.0.0.tra.txt: score 0.6523 wer 20.78% lm_ppl 23.0645 gt_wer 22.85%
# # INFO:root:./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode3g_train_cmp_620.si/scoring/7.0.0.tra.txt: score 0.6516 wer 20.77% lm_ppl 23.0384 gt_wer 22.87%
# 
# 
# 
# # ===== (Diagnosis) Show train WER
# for suffix in ${other_lm_suffixs[@]}; do
#   local/show_wer.sh --split $train_name --ref_data $data_dir/data --get_best_wer false \
#     --dec_name decode${suffix} --graph_name graph${suffix} $exp_root/$pseudo_exp_name
# done
# local/show_wer.sh --split $train_name --ref_data $data_dir/data --get_best_wer false $exp_root/$pseudo_exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 12.13 [ 11641 / 95933, 4920 ins, 4030 del, 2691 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode2g_train_cmp_3000/wer_16_0.5
# # %WER 13.14 [ 12602 / 95933, 2066 ins, 8135 del, 2401 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode2g_train_cmp_3000/wer_7_0.0
# # %WER 13.48 [ 12936 / 95933, 2147 ins, 8322 del, 2467 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode2g_train_cmp_3000/wer_7_0.0
# # %WER 13.48 [ 12936 / 95933, 2151 ins, 8329 del, 2456 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode2g_train_cmp_3000.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 22.19 [ 23208 / 104568, 3661 ins, 11406 del, 8141 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode2g_train_cmp_3000/scoring/16.0.5.tra
# # %WER 25.12 [ 26265 / 104568, 2130 ins, 16834 del, 7301 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode2g_train_cmp_3000/scoring/7.0.0.tra
# # %WER 24.89 [ 26029 / 104568, 1944 ins, 16754 del, 7331 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode2g_train_cmp_3000/scoring/7.0.0.tra
# # %WER 24.89 [ 26022 / 104568, 1946 ins, 16759 del, 7317 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode2g_train_cmp_3000.si/scoring/7.0.0.tra
# # ==== WER w.r.t. pseudo transcript
# # %WER 11.94 [ 11451 / 95933, 4927 ins, 3898 del, 2626 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode3g_train_cmp_3000/wer_16_1.0
# # %WER 12.19 [ 11692 / 95933, 2625 ins, 6509 del, 2558 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode3g_train_cmp_3000/wer_7_0.0
# # %WER 12.34 [ 11841 / 95933, 2681 ins, 6537 del, 2623 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode3g_train_cmp_3000/wer_7_0.0
# # %WER 12.33 [ 11832 / 95933, 2679 ins, 6521 del, 2632 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode3g_train_cmp_3000.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 21.57 [ 22554 / 104568, 3495 ins, 11101 del, 7958 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode3g_train_cmp_3000/scoring/16.1.0.tra
# # %WER 23.74 [ 24823 / 104568, 2358 ins, 14877 del, 7588 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode3g_train_cmp_3000/scoring/7.0.0.tra
# # %WER 23.33 [ 24399 / 104568, 2160 ins, 14651 del, 7588 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode3g_train_cmp_3000/scoring/7.0.0.tra
# # %WER 23.34 [ 24407 / 104568, 2166 ins, 14643 del, 7598 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode3g_train_cmp_3000.si/scoring/7.0.0.tra
# # ==== WER w.r.t. pseudo transcript
# # %WER 11.59 [ 11114 / 95933, 4913 ins, 3560 del, 2641 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode_train_cmp_3000/wer_17_1.0
# # %WER 11.70 [ 11226 / 95933, 3192 ins, 5317 del, 2717 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode_train_cmp_3000/wer_7_0.0
# # %WER 11.98 [ 11489 / 95933, 3234 ins, 5482 del, 2773 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_3000/wer_7_0.0
# # %WER 11.96 [ 11469 / 95933, 3228 ins, 5467 del, 2774 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_3000.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 21.29 [ 22267 / 104568, 3486 ins, 10768 del, 8013 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri1/decode_train_cmp_3000/scoring/17.1.0.tra
# # %WER 22.91 [ 23959 / 104568, 2666 ins, 13426 del, 7867 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri2b/decode_train_cmp_3000/scoring/7.0.0.tra
# # %WER 22.56 [ 23590 / 104568, 2442 ins, 13325 del, 7823 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_3000/scoring/7.0.0.tra
# # %WER 22.55 [ 23584 / 104568, 2450 ins, 13324 del, 7810 sub ] ./output_v2/w2v_timit_pca128_unmatched/exp/timit_21uer_nosil_unmatched_gmm-200-6000/tri3b/decode_train_cmp_3000.si/scoring/7.0.0.tra


# ===== Prepare W2V ST data

lang_test=$data_dir/data/lang_test
if [ ! -z $it2_decode_suffix ]; then
  lang_test=$data_dir/data/lang_test_${it2_decode_suffix}
fi

local/decode.sh --decode_suffix "$it2_decode_suffix" --graph_name graph${it2_decode_suffix} \
  --val_sets "$test_names" --decode_script $it2_decode_script \
  $exp_root/$pseudo_exp_name/$it2_model_name $pseudo_data_dir/data $lang_test


pseudo_it2_data_dir=./output_v2/w2v_timit_pca128_unmatched_21uer_${it2_model_name}_decode${it2_decode_suffix}${it2_decode_si_suffix}_$(echo $it2_lmparam | sed 's:\.:_:g')

for split in $train_name $valid_name $test_names; do
  mkdir -p $pseudo_it2_data_dir/data/$split
  cp $data_dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $pseudo_it2_data_dir/data/$split

  tra=$exp_root/$pseudo_exp_name/$it2_model_name/decode${it2_decode_suffix}_${split}${it2_decode_si_suffix}/scoring/${it2_lmparam}.tra
  cat $tra | utils/int2sym.pl -f 2- $data_dir/data/lang/words.txt | sed 's:\<UNK\>::g' > $pseudo_it2_data_dir/data/$split/text
  utils/fix_data_dir.sh $pseudo_it2_data_dir/data/$split
  echo "WER on $split is" $(compute-wer ark:$data_dir/data/$split/text ark:$pseudo_it2_data_dir/data/$split/text | cut -d" " -f2-)
done

