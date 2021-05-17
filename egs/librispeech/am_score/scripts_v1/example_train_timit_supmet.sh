#!/bin/bash

set -eu


# train on real transcripts
dir=./output/w2v_timit_pca128_nosil
w2v_dir=/checkpoint/wnhsu/data/timit/data/w2v_vox_lyr14/precompute_unfiltered_pca128
label=phnc
arpa_lm=/checkpoint/wnhsu/data/timit/lm/timit_train.phnc.o4.arpa
train_name="train"
valid_name="dev"
test_names="test test_cmp"

# local/prepare_lang.sh --sil_prob 0.0 $w2v_dir/dict.${label}.txt $dir/data
# local/prepare_lm.sh $arpa_lm $dir/data
# for split in $train_name $valid_name $test_names; do
#   python local/prepare_data_from_w2v.py $w2v_dir $dir/data $split --label $label
#   steps/compute_cmvn_stats.sh $dir/data/$split $dir/make_feat/$split $dir/feats/$split
# done

# local/train_subset.sh \
#   --numLeavesTri1 200 --numGaussTri1 6000 --numLeavesMLLT 200 --numGaussMLLT 6000 \
#   --numLeavesSAT 200 --numGaussSAT 6000 --out_root exp_train --out_name timit_gt_nosil_gmm-200-6000 \
#   --train $train_name --valid $valid_name \
#   --mono_size -1 --tri1_size -1 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 4 $dir/data $dir/data/lang $dir/data/lang_test
# # ==== WER w.r.t. pseudo transcript
# # %WER 13.68 [ 2060 / 15057, 446 ins, 671 del, 943 sub ] exp_train/timit_gt_nosil_gmm-200-6000//mono/decode_dev/wer_10_0.5
# # %WER 12.35 [ 1860 / 15057, 573 ins, 337 del, 950 sub ] exp_train/timit_gt_nosil_gmm-200-6000//tri1/decode_dev/wer_17_1.0
# # %WER 12.11 [ 1824 / 15057, 362 ins, 531 del, 931 sub ] exp_train/timit_gt_nosil_gmm-200-6000//tri2b/decode_dev/wer_7_0.5
# # %WER 11.88 [ 1789 / 15057, 366 ins, 511 del, 912 sub ] exp_train/timit_gt_nosil_gmm-200-6000//tri3b/decode_dev/wer_7_0.5
# # %WER 11.90 [ 1792 / 15057, 365 ins, 517 del, 910 sub ] exp_train/timit_gt_nosil_gmm-200-6000//tri3b/decode_dev.si/wer_7_0.5

# --------------------------------------------------------------------------------
# train on 16% PER pseudo transcripts
new_label_dir=/checkpoint/wnhsu/data/timit/gan_hyp/19uer_transcripts_supmet/ngram/
new_dir=./output/w2v_timit_pca128_16uer
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
exp_name=timit_16uer_nosil_gmm-200-6000
# local/train_subset.sh \
#   --numLeavesTri1 200 --numGaussTri1 6000 --numLeavesMLLT 200 --numGaussMLLT 6000 \
#   --numLeavesSAT 200 --numGaussSAT 6000 --out_root $exp_root --out_name $exp_name \
#   --train $train_name --valid $valid_name \
#   --mono_size -1 --tri1_size -1 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
# local/show_wer.sh --split dev --ref_data $dir/data $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 15.92 [ 2386 / 14991, 859 ins, 775 del, 752 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/mono/decode_dev/wer_13_0.0
# # %WER 14.44 [ 2165 / 14991, 953 ins, 550 del, 662 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri1/decode_dev/wer_17_1.0
# # %WER 14.04 [ 2104 / 14991, 807 ins, 672 del, 625 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri2b/decode_dev/wer_7_0.0
# # %WER 13.42 [ 2012 / 14991, 707 ins, 713 del, 592 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode_dev/wer_7_0.5
# # %WER 13.45 [ 2016 / 14991, 705 ins, 720 del, 591 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode_dev.si/wer_7_0.5
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 15.04 [ 2264 / 15057, 621 ins, 603 del, 1040 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/mono/decode_dev/scoring/13.0.0.tra
# # %WER 14.33 [ 2158 / 15057, 741 ins, 404 del, 1013 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri1/decode_dev/scoring/17.1.0.tra
# # %WER 14.37 [ 2164 / 15057, 649 ins, 580 del, 935 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri2b/decode_dev/scoring/7.0.0.tra
# # %WER 13.68 [ 2060 / 15057, 529 ins, 601 del, 930 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode_dev/scoring/7.0.5.tra
# # %WER 13.69 [ 2061 / 15057, 523 ins, 604 del, 934 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode_dev.si/scoring/7.0.5.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 14.90 [ 2243 / 15057, 448 ins, 800 del, 995 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/mono/decode_dev/scoring/12.1.0.tra
# # %WER 14.33 [ 2158 / 15057, 741 ins, 404 del, 1013 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri1/decode_dev/scoring/17.1.0.tra
# # %WER 14.33 [ 2158 / 15057, 515 ins, 726 del, 917 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri2b/decode_dev/scoring/7.0.5.tra
# # %WER 13.68 [ 2060 / 15057, 529 ins, 601 del, 930 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode_dev/scoring/7.0.5.tra
# # %WER 13.69 [ 2061 / 15057, 523 ins, 604 del, 934 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode_dev.si/scoring/7.0.5.tra

lm_3gram=/checkpoint/wnhsu/data/timit/lm/timit_train.phnc.o3.arpa
exp_dir=$exp_root/$exp_name/tri3b
decode_suffix=3g
dec_sets="train dev"
# local/prepare_lm.sh --lmdir $dir/data/lang_test_3gram $lm_3gram $dir/data
# local/decode.sh --decode_suffix $decode_suffix --graph_name graph_3g --val_sets "$dec_sets $test_names" $exp_dir $new_dir/data $dir/data/lang_test_3gram
# for x in $dec_sets $test_names; do
#   local/show_wer.sh --split "$x" --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# done
# # ==== WER w.r.t. pseudo transcript
# # %WER 13.05 [ 1956 / 14991, 752 ins, 651 del, 553 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_dev/wer_7_0.0
# # %WER 13.06 [ 1958 / 14991, 750 ins, 655 del, 553 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_dev.si/wer_7_0.0
# # %WER 14.03 [ 1012 / 7214, 378 ins, 322 del, 312 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_test/wer_7_0.0
# # %WER 13.97 [ 1008 / 7214, 376 ins, 319 del, 313 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_test.si/wer_7_0.0
# # %WER 13.15 [ 8221 / 62512, 3137 ins, 2717 del, 2367 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_test_cmp/wer_7_0.0
# # %WER 13.12 [ 8202 / 62512, 3134 ins, 2709 del, 2359 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_test_cmp.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 13.05 [ 1965 / 15057, 552 ins, 517 del, 896 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_dev/scoring/7.0.0.tra
# # %WER 13.10 [ 1973 / 15057, 551 ins, 522 del, 900 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_dev.si/scoring/7.0.0.tra
# # %WER 14.23 [ 1027 / 7215, 291 ins, 236 del, 500 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_test/scoring/7.0.0.tra
# # %WER 14.16 [ 1022 / 7215, 289 ins, 233 del, 500 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_test.si/scoring/7.0.0.tra
# # %WER 13.13 [ 8262 / 62901, 2232 ins, 2201 del, 3829 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_test_cmp/scoring/7.0.0.tra
# # %WER 13.12 [ 8254 / 62901, 2228 ins, 2192 del, 3834 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_test_cmp.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 13.05 [ 1965 / 15057, 552 ins, 517 del, 896 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_dev/scoring/7.0.0.tra
# # %WER 13.10 [ 1973 / 15057, 551 ins, 522 del, 900 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_dev.si/scoring/7.0.0.tra
# # %WER 14.23 [ 1027 / 7215, 291 ins, 236 del, 500 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_test/scoring/7.0.0.tra
# # %WER 14.16 [ 1022 / 7215, 289 ins, 233 del, 500 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_test.si/scoring/7.0.0.tra
# # %WER 13.13 [ 8262 / 62901, 2232 ins, 2201 del, 3829 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_test_cmp/scoring/7.0.0.tra
# # %WER 13.12 [ 8254 / 62901, 2228 ins, 2192 del, 3834 sub ] exp_train/timit_16uer_nosil_gmm-200-6000/tri3b/decode3g_test_cmp.si/scoring/7.0.0.tra


# Align pseudo transcript decoded from the HMM system
# for speaker-adapted systems, set si=true for speaker independent decoding
lmparam=7.0.0
si=true
new_dir=./output/w2v_timit_pca128_16uer_decode_$(basename $exp_dir)_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
# for split in $train_name $valid_name $test_names; do
#   mkdir -p $new_dir/data/$split
#   cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
# 
#   if $si; then
#     tra=$exp_dir/decode${decode_suffix}_${split}.si/scoring/${lmparam}.tra
#   else
#     tra=$exp_dir/decode${decode_suffix}_${split}/scoring/${lmparam}.tra
#   fi
#   cat $tra | utils/int2sym.pl -f 2- $dir/data/lang/words.txt | sed 's:\<UNK\>::g' > $new_dir/data/$split/text
#   utils/fix_data_dir.sh $new_dir/data/$split
#   echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
# done
# ali_dir=exp_align/w2v_timit_pca128_17uer/tri3b/decodetext_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
# local/write_ali_int.sh --splits "dev train test test_cmp" $exp_root/$exp_name/tri3b $new_dir/data $dir/data/lang_test $ali_dir

# WER on train is 12.15 [ 17042 / 140225, 4315 ins, 4972 del, 7755 sub ] 96.35 [ 3561 / 3696 ] 3696 sentences, 0 not present in hyp.
# WER on dev is 13.10 [ 1973 / 15057, 551 ins, 522 del, 900 sub ] 97.75 [ 391 / 400 ] 400 sentences, 0 not present in hyp.
# WER on test is 14.16 [ 1022 / 7215, 289 ins, 233 del, 500 sub ] 95.83 [ 184 / 192 ] 192 sentences, 0 not present in hyp.
# WER on test_cmp is 13.12 [ 8254 / 62901, 2228 ins, 2192 del, 3834 sub ] 98.27 [ 1651 / 1680 ] 1680 sentences, 0 not present in hyp.
