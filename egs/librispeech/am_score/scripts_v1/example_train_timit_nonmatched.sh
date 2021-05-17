#!/bin/bash

set -eu


# train on real transcripts
dir=./output/w2v_timit_pca128_nosil_nonmatched
w2v_dir=/checkpoint/wnhsu/data/timit/data/w2v_vox_lyr14/precompute_unfiltered_pca128
label=phnc
arpa_lm=/checkpoint/wnhsu/data/timit/lm/timit_train_cmp_1000.phnc.o4.arpa
train_name="train_cmp_3000"
valid_name="train_cmp_620"
test_names="test test_cmp"

# local/prepare_lang.sh --sil_prob 0.0 $w2v_dir/dict.${label}.txt $dir/data
# local/prepare_lm.sh $arpa_lm $dir/data
# for split in $train_name $valid_name $test_names; do
#   python local/prepare_data_from_w2v.py $w2v_dir $dir/data $split --label $label
#   steps/compute_cmvn_stats.sh $dir/data/$split $dir/make_feat/$split $dir/feats/$split
# done
# 

exp_root=exp_train
exp_name=timit_gt_nosil_nonmatched_gmm-200-6000
# local/train_subset.sh \
#   --numLeavesTri1 200 --numGaussTri1 6000 --numLeavesMLLT 200 --numGaussMLLT 6000 \
#   --numLeavesSAT 200 --numGaussSAT 6000 --out_root $exp_root --out_name $exp_name \
#   --train $train_name --valid $valid_name \
#   --mono_size -1 --tri1_size -1 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 4 $dir/data $dir/data/lang $dir/data/lang_test
# local/show_wer.sh --split $valid_name $exp_root/$exp_name
# ==== WER w.r.t. pseudo transcript
# %WER 15.05 [ 5092 / 33831, 1117 ins, 1487 del, 2488 sub ] exp_train/timit_gt_nosil_nonmatched_gmm-200-6000/mono/decode_train_cmp_620/wer_12_0.0
# %WER 13.93 [ 4714 / 33831, 1397 ins, 1026 del, 2291 sub ] exp_train/timit_gt_nosil_nonmatched_gmm-200-6000/tri1/decode_train_cmp_620/wer_17_0.5
# %WER 14.91 [ 5045 / 33831, 1001 ins, 1610 del, 2434 sub ] exp_train/timit_gt_nosil_nonmatched_gmm-200-6000/tri2b/decode_train_cmp_620/wer_7_0.0
# %WER 14.80 [ 5007 / 33831, 1007 ins, 1574 del, 2426 sub ] exp_train/timit_gt_nosil_nonmatched_gmm-200-6000/tri3b/decode_train_cmp_620/wer_7_0.0
# %WER 14.78 [ 5001 / 33831, 1003 ins, 1574 del, 2424 sub ] exp_train/timit_gt_nosil_nonmatched_gmm-200-6000/tri3b/decode_train_cmp_620.si/wer_7_0.0


# --------------------------------------------------------------------------------
# train on 21.3% PER pseudo transcripts
new_label_dir=/checkpoint/wnhsu/data/timit/gan_hyp/27uer_transcripts_ntu_nonmatched/ngram
new_dir=./output/w2v_timit_pca128_nonmatched_21uer
label=txt
# for split in $valid_name $train_name $test_names; do
#   mkdir -p $new_dir/data/$split
#   python local/copy_text.py --last_n=1 \
#     $w2v_dir/$split.tsv $w2v_dir/$split.tsv \
#     $new_label_dir/$split.$label $new_dir/data/$split/raw_text
# 
#   cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
#   cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
#   paste -d' ' $new_dir/data/$split/uids $new_dir/data/$split/raw_text > $new_dir/data/$split/text
# 
#   echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
# done


exp_root=exp_train
exp_name=timit_21uer_nosil_nonmatched_gmm-200-6000
# local/train_subset.sh \
#   --numLeavesTri1 200 --numGaussTri1 6000 --numLeavesMLLT 200 --numGaussMLLT 6000 \
#   --numLeavesSAT 200 --numGaussSAT 6000 --out_root $exp_root --out_name $exp_name \
#   --train $train_name --valid $valid_name \
#   --mono_size -1 --tri1_size -1 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
# local/show_wer.sh --split $valid_name --ref_data $dir/data $exp_root/$exp_name
# local/unsup_select_decode.sh --split $valid_name --ref_data $dir/data --psd_data $new_dir/data --dec_name decode $exp_root/$exp_name "--uppercase --skipwords sil"
# # ==== WER w.r.t. pseudo transcript
# # %WER 20.74 [ 6577 / 31717, 2408 ins, 2148 del, 2021 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/mono/decode_train_cmp_620/wer_14_0.5
# # %WER 20.59 [ 6531 / 31717, 3123 ins, 1563 del, 1845 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri1/decode_train_cmp_620/wer_17_1.0
# # %WER 20.30 [ 6438 / 31717, 1908 ins, 2656 del, 1874 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri2b/decode_train_cmp_620/wer_7_0.0
# # %WER 20.81 [ 6601 / 31717, 2056 ins, 2637 del, 1908 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri3b/decode_train_cmp_620/wer_7_0.0
# # %WER 20.80 [ 6597 / 31717, 2049 ins, 2636 del, 1912 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri3b/decode_train_cmp_620.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 20.87 [ 7059 / 33831, 1287 ins, 3141 del, 2631 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/mono/decode_train_cmp_620/scoring/14.0.5.tra
# # %WER 20.71 [ 7007 / 33831, 1897 ins, 2451 del, 2659 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri1/decode_train_cmp_620/scoring/17.1.0.tra
# # %WER 22.83 [ 7725 / 33831, 1150 ins, 4012 del, 2563 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri2b/decode_train_cmp_620/scoring/7.0.0.tra
# # %WER 22.90 [ 7748 / 33831, 1201 ins, 3896 del, 2651 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri3b/decode_train_cmp_620/scoring/7.0.0.tra
# # %WER 22.89 [ 7744 / 33831, 1197 ins, 3898 del, 2649 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri3b/decode_train_cmp_620.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 20.49 [ 6933 / 33831, 1593 ins, 2625 del, 2715 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/mono/decode_train_cmp_620/scoring/13.0.0.tra
# # %WER 20.64 [ 6982 / 33831, 2113 ins, 2151 del, 2718 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri1/decode_train_cmp_620/scoring/16.0.5.tra
# # %WER 22.83 [ 7725 / 33831, 1150 ins, 4012 del, 2563 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri2b/decode_train_cmp_620/scoring/7.0.0.tra
# # %WER 22.90 [ 7748 / 33831, 1201 ins, 3896 del, 2651 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri3b/decode_train_cmp_620/scoring/7.0.0.tra
# # %WER 22.89 [ 7744 / 33831, 1197 ins, 3898 del, 2649 sub ] exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri3b/decode_train_cmp_620.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # INFO:root:exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/mono/decode_train_cmp_620/scoring/16.0.0.tra.txt: score 0.6628 wer 20.81% lm_ppl 24.1839 gt_wer 20.63%
# # INFO:root:exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri1/decode_train_cmp_620/scoring/17.1.0.tra.txt: score 0.6468 wer 20.59% lm_ppl 23.1260 gt_wer 20.71%
# # INFO:root:exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri2b/decode_train_cmp_620/scoring/7.0.0.tra.txt: score 0.6362 wer 20.30% lm_ppl 22.9671 gt_wer 22.83%
# # INFO:root:exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri3b/decode_train_cmp_620/scoring/7.0.0.tra.txt: score 0.6496 wer 20.81% lm_ppl 22.6724 gt_wer 22.90%
# # INFO:root:exp_train/timit_21uer_nosil_nonmatched_gmm-200-6000/tri3b/decode_train_cmp_620.si/scoring/7.0.0.tra.txt: score 0.6490 wer 20.80% lm_ppl 22.6519 gt_wer 22.89%

# for exp in tri1; do
#   lm_2gram=/checkpoint/wnhsu/data/timit/lm/timit_train_cmp_1000.phnc.o2.arpa
#   exp_dir=$exp_root/$exp_name/$exp
#   decode_suffix=2g
#   dec_sets=$valid_name
#   local/prepare_lm.sh --lmdir $dir/data/lang_test_2gram $lm_2gram $dir/data
#   local/decode.sh --decode_suffix $decode_suffix --graph_name graph_2g --val_sets "$dec_sets" $exp_dir $new_dir/data $dir/data/lang_test_2gram
#   local/show_wer.sh --split $valid_name --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
#   # local/unsup_select_decode.sh --split $valid_name --ref_data $dir/data --psd_data $new_dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
#   
#   
#   lm_3gram=/checkpoint/wnhsu/data/timit/lm/timit_train_cmp_1000.phnc.o3.arpa
#   exp_dir=$exp_root/$exp_name/$exp
#   decode_suffix=3g
#   dec_sets=$valid_name
#   local/prepare_lm.sh --lmdir $dir/data/lang_test_3gram $lm_3gram $dir/data
#   local/decode.sh --decode_suffix $decode_suffix --graph_name graph_3g --val_sets "$dec_sets" $exp_dir $new_dir/data $dir/data/lang_test_3gram
#   local/show_wer.sh --split $valid_name --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
#   # local/unsup_select_decode.sh --split $valid_name --ref_data $dir/data --psd_data $new_dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# done

# local/decode.sh --decode_script "steps/decode.sh" --val_sets "$train_name" $exp_root/$exp_name/tri1 $new_dir/data $dir/data/lang_test


# Align pseudo transcript decoded from the HMM system
# for speaker-adapted systems, set si=true for speaker independent decoding
exp_dir=$exp_root/$exp_name/tri1
decode_suffix=""
lmparam=17.1.0
si=false
new_dir=./output/w2v_timit_pca128_nonmatched_21uer_decode_$(basename $exp_dir)_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
for split in $train_name $valid_name; do
  mkdir -p $new_dir/data/$split
  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split

  if $si; then
    tra=$exp_dir/decode${decode_suffix}_${split}.si/scoring/${lmparam}.tra
  else
    tra=$exp_dir/decode${decode_suffix}_${split}/scoring/${lmparam}.tra
  fi
  cat $tra | utils/int2sym.pl -f 2- $dir/data/lang/words.txt | sed 's:\<UNK\>::g' > $new_dir/data/$split/text
  utils/fix_data_dir.sh $new_dir/data/$split
  echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
done
# WER on train_cmp_3000 is 20.97 [ 21925 / 104568, 3391 ins, 10458 del, 8076 sub ] 99.40 [ 2982 / 3000 ] 3000 sentences, 0 not present in hyp.
# WER on train_cmp_620 is 20.71 [ 7007 / 33831, 1897 ins, 2451 del, 2659 sub ] 100.00 [ 620 / 620 ] 620 sentences, 0 not present in hyp.
