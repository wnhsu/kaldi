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
# train on 17% PER pseudo transcripts
new_label_dir=/checkpoint/wnhsu/data/timit/gan_hyp/20uer_transcripts/ngram
new_dir=./output/w2v_timit_pca128_17uer
label=txt
# for split in $valid_name $train_name $test_names; do
#   # mkdir -p $new_dir/data/$split
#   # python local/copy_text.py --last_n=1 \
#   #   $w2v_dir/$split.tsv $w2v_dir/$split.tsv \
#   #   $new_label_dir/$split.$label $new_dir/data/$split/raw_text
# 
#   # cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
#   # cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
#   # paste -d' ' $new_dir/data/$split/uids $new_dir/data/$split/raw_text > $new_dir/data/$split/text
# 
#   echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
# done
# # WER on dev is 17.02 [ 2563 / 15057, 749 ins, 927 del, 887 sub ] 98.75 [ 395 / 400 ] 400 sentences, 0 not present in hyp.
# # WER on train is 14.03 [ 19668 / 140225, 6159 ins, 5813 del, 7696 sub ] 96.78 [ 3577 / 3696 ] 3696 sentences, 0 not present in hyp.
# # WER on test is 17.84 [ 1287 / 7215, 393 ins, 415 del, 479 sub ] 98.96 [ 190 / 192 ] 192 sentences, 0 not present in hyp.
# # WER on test_cmp is 16.57 [ 10420 / 62901, 3204 ins, 3516 del, 3700 sub ] 99.35 [ 1669 / 1680 ] 1680 sentences, 0 not present in hyp.

exp_root=exp_train
exp_name=timit_17uer_nosil_gmm-200-6000
# local/train_subset.sh \
#   --numLeavesTri1 200 --numGaussTri1 6000 --numLeavesMLLT 200 --numGaussMLLT 6000 \
#   --numLeavesSAT 200 --numGaussSAT 6000 --out_root $exp_root --out_name $exp_name \
#   --train $train_name --valid $valid_name \
#   --mono_size -1 --tri1_size -1 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
# local/show_wer.sh --split dev --ref_data $dir/data $exp_root/$exp_name
local/unsup_select_decode.sh --split dev --ref_data $dir/data --psd_data $new_dir/data --dec_name decode $exp_root/$exp_name "--uppercase --skipwords sil"
exit

# # ==== WER w.r.t. pseudo transcript
# # %WER 15.58 [ 2318 / 14879, 899 ins, 686 del, 733 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/mono/decode_dev/wer_11_0.5
# # %WER 14.54 [ 2163 / 14879, 1034 ins, 466 del, 663 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri1/decode_dev/wer_17_1.0
# # %WER 13.62 [ 2027 / 14879, 870 ins, 559 del, 598 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri2b/decode_dev/wer_7_0.0
# # %WER 13.64 [ 2030 / 14879, 767 ins, 691 del, 572 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev/wer_7_0.5
# # %WER 13.66 [ 2033 / 14879, 766 ins, 696 del, 571 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev.si/wer_7_0.5
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 15.28 [ 2301 / 15057, 662 ins, 627 del, 1012 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/mono/decode_dev/scoring/11.0.5.tra
# # %WER 14.68 [ 2210 / 15057, 797 ins, 407 del, 1006 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri1/decode_dev/scoring/17.1.0.tra
# # %WER 14.41 [ 2169 / 15057, 688 ins, 555 del, 926 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri2b/decode_dev/scoring/7.0.0.tra
# # %WER 14.39 [ 2166 / 15057, 587 ins, 689 del, 890 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev/scoring/7.0.5.tra
# # %WER 14.40 [ 2168 / 15057, 586 ins, 694 del, 888 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev.si/scoring/7.0.5.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 15.28 [ 2301 / 15057, 644 ins, 646 del, 1011 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/mono/decode_dev/scoring/12.0.5.tra
# # %WER 14.68 [ 2210 / 15057, 797 ins, 407 del, 1006 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri1/decode_dev/scoring/17.1.0.tra
# # %WER 14.41 [ 2169 / 15057, 688 ins, 555 del, 926 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri2b/decode_dev/scoring/7.0.0.tra
# # %WER 14.39 [ 2166 / 15057, 587 ins, 689 del, 890 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev/scoring/7.0.5.tra
# # %WER 14.36 [ 2162 / 15057, 698 ins, 547 del, 917 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on unsupervised metric: lm_ppl * args.lm_ppl_weight + wer * 100)
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/mono/decode_dev/scoring/7.0.0.tra.txt: score 1401.8038 wer 16.85% lm_ppl 1384.9546 gt_wer 16.28%
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri1/decode_dev/scoring/7.0.0.tra.txt: score 1386.8235 wer 17.20% lm_ppl 1369.6248 gt_wer 17.46%
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri2b/decode_dev/scoring/7.0.0.tra.txt: score 1404.9776 wer 13.62% lm_ppl 1391.3544 gt_wer 14.41%
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev/scoring/7.0.0.tra.txt: score 1404.8398 wer 13.85% lm_ppl 1390.9881 gt_wer 14.40%
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev.si/scoring/7.0.0.tra.txt: score 1404.7874 wer 13.85% lm_ppl 1390.9424 gt_wer 14.36%
# # ==== WER w.r.t. real transcript (select based on unsupervised metric: math.log(lm_ppl) * wer)
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/mono/decode_dev/scoring/11.0.5.tra.txt: score 1.1279 wer 15.58% lm_ppl 1393.6164 gt_wer 15.28%
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri1/decode_dev/scoring/17.1.0.tra.txt: score 1.0516 wer 14.54% lm_ppl 1385.5719 gt_wer 14.68%
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri2b/decode_dev/scoring/7.0.0.tra.txt: score 0.9861 wer 13.62% lm_ppl 1391.3544 gt_wer 14.41%
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev/scoring/7.0.5.tra.txt: score 0.9880 wer 13.64% lm_ppl 1396.8334 gt_wer 14.39%
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode_dev.si/scoring/7.0.5.tra.txt: score 0.9895 wer 13.66% lm_ppl 1396.9758 gt_wer 14.40%


lm_2gram=/checkpoint/wnhsu/data/timit/lm/timit_train.phnc.o2.arpa
exp_dir=$exp_root/$exp_name/tri3b
decode_suffix=2g
dec_sets="train dev"
# local/prepare_lm.sh --lmdir $dir/data/lang_test_2gram $lm_2gram $dir/data
# local/decode.sh --decode_suffix $decode_suffix --graph_name graph_2g --val_sets "$dec_sets" $exp_dir $new_dir/data $dir/data/lang_test_2gram
# local/show_wer.sh --split dev --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# local/unsup_select_decode.sh --split dev --ref_data $dir/data --psd_data $new_dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 13.78 [ 2050 / 14879, 749 ins, 770 del, 531 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode2g_dev/wer_7_0.0
# # %WER 13.80 [ 2053 / 14879, 750 ins, 770 del, 533 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode2g_dev.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 14.18 [ 2135 / 15057, 536 ins, 735 del, 864 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode2g_dev/scoring/7.0.0.tra
# # %WER 14.19 [ 2137 / 15057, 535 ins, 733 del, 869 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode2g_dev.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 14.18 [ 2135 / 15057, 536 ins, 735 del, 864 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode2g_dev/scoring/7.0.0.tra
# # %WER 14.19 [ 2137 / 15057, 535 ins, 733 del, 869 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode2g_dev.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode2g_dev/scoring/7.0.0.tra.txt: score 1412.9285 wer 13.78% lm_ppl 1399.1506 gt_wer 14.18%
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode2g_dev.si/scoring/7.0.0.tra.txt: score 1412.9246 wer 13.80% lm_ppl 1399.1266 gt_wer 14.19%
# # ==== WER w.r.t. real transcript (select based on unsupervised metric: math.log(lm_ppl) * wer)
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode2g_dev/scoring/7.0.0.tra.txt: score 0.9980 wer 13.78% lm_ppl 1399.1506 gt_wer 14.18%
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode2g_dev.si/scoring/7.0.0.tra.txt: score 0.9995 wer 13.80% lm_ppl 1399.1266 gt_wer 14.19%


lm_3gram=/checkpoint/wnhsu/data/timit/lm/timit_train.phnc.o3.arpa
exp_dir=$exp_root/$exp_name/tri3b
decode_suffix=3g
# dec_sets="train dev"
# local/prepare_lm.sh --lmdir $dir/data/lang_test_3gram $lm_3gram $dir/data
# local/decode.sh --decode_suffix $decode_suffix --graph_name graph_3g --val_sets "$dec_sets" $exp_dir $new_dir/data $dir/data/lang_test_3gram
# local/show_wer.sh --split dev --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# local/unsup_select_decode.sh --split dev --ref_data $dir/data --psd_data $new_dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# # ==== WER w.r.t. pseudo transcript
# # %WER 13.60 [ 2024 / 14879, 839 ins, 630 del, 555 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_dev/wer_7_0.0
# # %WER 13.64 [ 2030 / 14879, 843 ins, 637 del, 550 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_dev.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 13.70 [ 2063 / 15057, 615 ins, 584 del, 864 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_dev/scoring/7.0.0.tra
# # %WER 13.70 [ 2063 / 15057, 618 ins, 590 del, 855 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_dev.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 13.70 [ 2063 / 15057, 615 ins, 584 del, 864 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_dev/scoring/7.0.0.tra
# # %WER 13.70 [ 2063 / 15057, 618 ins, 590 del, 855 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_dev.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on unsupervised metric)
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_dev/scoring/7.0.0.tra.txt: score 1407.3125 wer 13.60% lm_ppl 1393.7094 gt_wer 13.70%
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_dev.si/scoring/7.0.0.tra.txt: score 1407.4226 wer 13.64% lm_ppl 1393.7792 gt_wer 13.70%
# # ==== WER w.r.t. real transcript (select based on unsupervised metric: math.log(lm_ppl) * wer)
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_dev/scoring/7.0.0.tra.txt: score 0.9848 wer 13.60% lm_ppl 1393.7094 gt_wer 13.70%
# # INFO:root:exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_dev.si/scoring/7.0.0.tra.txt: score 0.9878 wer 13.64% lm_ppl 1393.7792 gt_wer 13.70%

# local/decode.sh --decode_suffix $decode_suffix --graph_name graph_3g --val_sets "$test_names" $exp_dir $new_dir/data $dir/data/lang_test_3gram
# for x in $test_names; do
#   local/show_wer.sh --split "$x" --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# done
# # ==== WER w.r.t. pseudo transcript
# # %WER 13.72 [ 987 / 7193, 365 ins, 323 del, 299 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_test/wer_7_0.0
# # %WER 13.67 [ 983 / 7193, 363 ins, 326 del, 294 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_test.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 14.66 [ 1058 / 7215, 299 ins, 279 del, 480 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_test/scoring/7.0.0.tra
# # %WER 14.61 [ 1054 / 7215, 294 ins, 279 del, 481 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_test.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 14.66 [ 1058 / 7215, 299 ins, 279 del, 480 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_test/scoring/7.0.0.tra
# # %WER 14.61 [ 1054 / 7215, 294 ins, 279 del, 481 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_test.si/scoring/7.0.0.tra
# 
# # ==== WER w.r.t. pseudo transcript
# # %WER 12.69 [ 7940 / 62589, 3035 ins, 2690 del, 2215 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_test_cmp/wer_7_0.0
# # %WER 12.68 [ 7936 / 62589, 3025 ins, 2707 del, 2204 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_test_cmp.si/wer_7_0.0
# # ==== WER w.r.t. real transcript (select based on pseudo WER)
# # %WER 13.54 [ 8517 / 62901, 2464 ins, 2431 del, 3622 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_test_cmp/scoring/7.0.0.tra
# # %WER 13.52 [ 8507 / 62901, 2450 ins, 2444 del, 3613 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_test_cmp.si/scoring/7.0.0.tra
# # ==== WER w.r.t. real transcript (select based on true WER)
# # %WER 13.54 [ 8517 / 62901, 2464 ins, 2431 del, 3622 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_test_cmp/scoring/7.0.0.tra
# # %WER 13.52 [ 8507 / 62901, 2450 ins, 2444 del, 3613 sub ] exp_train/timit_17uer_nosil_gmm-200-6000/tri3b/decode3g_test_cmp.si/scoring/7.0.0.tra


# Align pseudo transcript decoded from the HMM system
# for speaker-adapted systems, set si=true for speaker independent decoding
lmparam=7.0.0
si=true
new_dir=./output/w2v_timit_pca128_17uer_decode_$(basename $exp_dir)_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
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
# 
# ali_dir=exp_align/w2v_timit_pca128_17uer/tri3b/decodetext_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')
# local/write_ali_int.sh --splits "dev train test test_cmp" $exp_root/$exp_name/tri3b $new_dir/data $dir/data/lang_test $ali_dir


exp_root=exp_train
exp_name=timit_17uer_nosil_gmm-200-6000_decode_$(basename $exp_dir)_${decode_suffix}_$(echo $lmparam | sed 's:\.:_:g')_gmm-200-6000
# local/train_subset.sh \
#   --numLeavesTri1 200 --numGaussTri1 6000 --numLeavesMLLT 200 --numGaussMLLT 6000 \
#   --numLeavesSAT 200 --numGaussSAT 6000 --out_root $exp_root --out_name $exp_name \
#   --train $train_name --valid $valid_name \
#   --mono_size -1 --tri1_size -1 --tri2b_size -1 --tri3b_size -1 \
#   --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
# local/show_wer.sh --split dev --ref_data $dir/data $exp_root/$exp_name
# local/unsup_select_decode.sh --split dev --ref_data $dir/data --psd_data $new_dir/data --dec_name decode $exp_root/$exp_name
# ==== WER w.r.t. pseudo transcript
# %WER 11.90 [ 1795 / 15085, 534 ins, 594 del, 667 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/mono/decode_dev/wer_14_0.0
# %WER 9.69 [ 1461 / 15085, 586 ins, 315 del, 560 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/tri1/decode_dev/wer_17_1.0
# %WER 7.59 [ 1145 / 15085, 391 ins, 351 del, 403 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/tri2b/decode_dev/wer_7_0.0
# %WER 7.13 [ 1075 / 15085, 361 ins, 307 del, 407 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/tri3b/decode_dev/wer_7_0.0
# %WER 7.11 [ 1073 / 15085, 362 ins, 305 del, 406 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/tri3b/decode_dev.si/wer_7_0.0
# ==== WER w.r.t. real transcript (select based on pseudo WER)
# %WER 14.86 [ 2238 / 15057, 594 ins, 626 del, 1018 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/mono/decode_dev/scoring/14.0.0.tra
# %WER 14.25 [ 2145 / 15057, 728 ins, 429 del, 988 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/tri1/decode_dev/scoring/17.1.0.tra
# %WER 13.72 [ 2066 / 15057, 615 ins, 547 del, 904 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/tri2b/decode_dev/scoring/7.0.0.tra
# %WER 13.55 [ 2040 / 15057, 599 ins, 517 del, 924 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/tri3b/decode_dev/scoring/7.0.0.tra
# %WER 13.57 [ 2043 / 15057, 601 ins, 516 del, 926 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/tri3b/decode_dev.si/scoring/7.0.0.tra
# ==== WER w.r.t. real transcript (select based on true WER)
# %WER 14.74 [ 2220 / 15057, 523 ins, 691 del, 1006 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/mono/decode_dev/scoring/13.0.5.tra
# %WER 14.25 [ 2145 / 15057, 728 ins, 429 del, 988 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/tri1/decode_dev/scoring/17.1.0.tra
# %WER 13.72 [ 2066 / 15057, 615 ins, 547 del, 904 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/tri2b/decode_dev/scoring/7.0.0.tra
# %WER 13.55 [ 2040 / 15057, 599 ins, 517 del, 924 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/tri3b/decode_dev/scoring/7.0.0.tra
# %WER 13.57 [ 2043 / 15057, 601 ins, 516 del, 926 sub ] exp_train/timit_17uer_nosil_gmm-200-6000_decode_tri3b_3g_7_0_0_gmm-200-6000/tri3b/decode_dev.si/scoring/7.0.0.tra


lm_3gram=/checkpoint/wnhsu/data/timit/lm/timit_train.phnc.o3.arpa
exp_dir=$exp_root/$exp_name/tri3b
decode_suffix=3g
dec_sets="dev"
# local/prepare_lm.sh --lmdir $dir/data/lang_test_3gram $lm_3gram $dir/data
# local/decode.sh --decode_suffix $decode_suffix --graph_name graph_3g --val_sets "$dec_sets $test_names" $exp_dir $new_dir/data $dir/data/lang_test_3gram
# for x in $dec_sets $test_names; do
#   local/show_wer.sh --split "$x" --ref_data $dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
#   local/unsup_select_decode.sh --split $x --ref_data $dir/data --psd_data $new_dir/data --dec_name decode${decode_suffix} $exp_root/$exp_name
# done
