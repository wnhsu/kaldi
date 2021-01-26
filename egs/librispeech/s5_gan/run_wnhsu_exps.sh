#!/bin/bash

# for x in exp/{mono,tri,sgmm,dnn,combine}*/decode*; do grep WER $x/wer_* 2>/dev/null | utils/best_wer.sh; done

# bash run_phn.sh
# %WER 59.27 [ 106577 / 179810, 2948 ins, 50424 del, 53205 sub ] exp_phn_mfcc/mono/decode_dev_other/wer_7_0.0
# %WER 50.33 [ 90499 / 179810, 7174 ins, 28698 del, 54627 sub ] exp_phn_mfcc/tri1/decode_dev_other/wer_7_0.0
# %WER 47.24 [ 84948 / 179810, 6779 ins, 27184 del, 50985 sub ] exp_phn_mfcc/tri2b/decode_dev_other/wer_7_0.0
# %WER 41.04 [ 73802 / 179810, 6674 ins, 21348 del, 45780 sub ] exp_phn_mfcc/tri3b/decode_dev_other/wer_7_0.0
# %WER 48.65 [ 87482 / 179810, 6499 ins, 27121 del, 53862 sub ] exp_phn_mfcc/tri3b/decode_dev_other.si/wer_7_0.0
# %WER 39.19 [ 70473 / 179810, 5785 ins, 21238 del, 43450 sub ] exp_phn_mfcc/tri4b/decode_dev_other/wer_8_0.0
# %WER 46.91 [ 84351 / 179810, 6699 ins, 25408 del, 52244 sub ] exp_phn_mfcc/tri4b/decode_dev_other.si/wer_7_0.0

# bash run_phn_w2v.sh --w2v_dir /checkpoint/abaevski/asr/unsup/data/segmented/precompute_unfiltered_pca128_seg --num_sil_states 1 --num_nonsil_states 1 --suffix phn_w2v_rmsil_pca128_topo_1_1 --stage 3 --train_stage 8
# %WER 17.78 [ 31967 / 179810, 3476 ins, 15233 del, 13258 sub ] exp_phn_w2v_rmsil_pca128_topo_1_1/mono/decode_dev_other/wer_8_0.0
# %WER 11.85 [ 21300 / 179810, 3756 ins, 7354 del, 10190 sub ] exp_phn_w2v_rmsil_pca128_topo_1_1/tri1/decode_dev_other/wer_17_1.0
# %WER 7.37 [ 13259 / 179810, 1651 ins, 5312 del, 6296 sub ] exp_phn_w2v_rmsil_pca128_topo_1_1/tri2b/decode_dev_other/wer_7_0.0
# %WER 6.95 [ 12500 / 179810, 1601 ins, 4807 del, 6092 sub ] exp_phn_w2v_rmsil_pca128_topo_1_1/tri3b/decode_dev_other/wer_7_0.0
# %WER 7.38 [ 13261 / 179810, 1594 ins, 5228 del, 6439 sub ] exp_phn_w2v_rmsil_pca128_topo_1_1/tri3b/decode_dev_other.si/wer_7_0.0

# bash run_phn_w2v.sh --w2v_dir /checkpoint/abaevski/asr/unsup/data/segmented/precompute_unfiltered_pca128_seg --num_sil_states 3 --num_nonsil_states 1 --suffix phn_w2v_rmsil_pca128_topo_3_1 --stage 3 --train_stage 8
# %WER 17.89 [ 32176 / 179810, 4122 ins, 13823 del, 14231 sub ] exp_phn_w2v_rmsil_pca128_topo_3_1/mono/decode_dev_other/wer_8_0.0
# %WER 11.64 [ 20922 / 179810, 3808 ins, 7230 del, 9884 sub ] exp_phn_w2v_rmsil_pca128_topo_3_1/tri1/decode_dev_other/wer_17_1.0
# %WER 7.18 [ 12913 / 179810, 1781 ins, 4986 del, 6146 sub ] exp_phn_w2v_rmsil_pca128_topo_3_1/tri2b/decode_dev_other/wer_7_0.0
# %WER 6.80 [ 12234 / 179810, 1677 ins, 4507 del, 6050 sub ] exp_phn_w2v_rmsil_pca128_topo_3_1/tri3b/decode_dev_other/wer_7_0.0
# %WER 7.18 [ 12916 / 179810, 1705 ins, 4819 del, 6392 sub ] exp_phn_w2v_rmsil_pca128_topo_3_1/tri3b/decode_dev_other.si/wer_7_0.0

# bash run_phn_w2v.sh --w2v_dir /checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_unfiltered_pca128 --num_sil_states 5 --num_nonsil_states 3 --suffix phn_w2v_topo_5_3 --stage 1 --train_stage 7
# %WER 21.63 [ 38892 / 179810, 1517 ins, 20609 del, 16766 sub ] exp_phn_w2v_topo_5_3/mono/decode_dev_other/wer_7_0.0
# %WER 13.67 [ 24586 / 179810, 1891 ins, 10617 del, 12078 sub ] exp_phn_w2v_topo_5_3/tri1/decode_dev_other/wer_7_0.0
# %WER 9.30 [ 16719 / 179810, 1022 ins, 8436 del, 7261 sub ] exp_phn_w2v_topo_5_3/tri2b/decode_dev_other/wer_7_0.0
# %WER 9.03 [ 16236 / 179810, 1092 ins, 8171 del, 6973 sub ] exp_phn_w2v_topo_5_3/tri3b/decode_dev_other/wer_7_0.0
# %WER 9.27 [ 16667 / 179810, 1114 ins, 8246 del, 7307 sub ] exp_phn_w2v_topo_5_3/tri3b/decode_dev_other.si/wer_7_0.0

# bash run_phn_w2v.sh --w2v_dir /checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_unfiltered_pca128 --num_sil_states 3 --num_nonsil_states 1 --suffix phn_w2v_topo_3_1 --stage 1 --train_stage 7
# %WER 16.96 [ 30489 / 179810, 4036 ins, 11588 del, 14865 sub ] exp_phn_w2v_topo_3_1/mono/decode_dev_other/wer_10_0.0
# %WER 11.07 [ 19902 / 179810, 4336 ins, 5147 del, 10419 sub ] exp_phn_w2v_topo_3_1/tri1/decode_dev_other/wer_17_1.0
# %WER 6.63 [ 11923 / 179810, 2021 ins, 3749 del, 6153 sub ] exp_phn_w2v_topo_3_1/tri2b/decode_dev_other/wer_7_0.0
# %WER 6.19 [ 11131 / 179810, 1838 ins, 3368 del, 5925 sub ] exp_phn_w2v_topo_3_1/tri3b/decode_dev_other/wer_7_0.0
# %WER 6.60 [ 11876 / 179810, 1885 ins, 3683 del, 6308 sub ] exp_phn_w2v_topo_3_1/tri3b/decode_dev_other.si/wer_7_0.0
# %WER 5.61 [ 10080 / 179810, 1630 ins, 3075 del, 5375 sub ] exp_phn_w2v_topo_3_1/tri4b/decode_dev_other/wer_7_0.0
# %WER 6.11 [ 10994 / 179810, 1640 ins, 3556 del, 5798 sub ] exp_phn_w2v_topo_3_1/tri4b/decode_dev_other.si/wer_7_0.0
# %WER 5.18 [ 9311 / 179810, 1434 ins, 2928 del, 4949 sub ] exp_phn_w2v_topo_3_1/tri5b/decode_dev_other/wer_7_0.0
# %WER 5.55 [ 9976 / 179810, 1411 ins, 3317 del, 5248 sub ] exp_phn_w2v_topo_3_1/tri5b/decode_dev_other.si/wer_7_0.0
# %WER 4.74 [ 8521 / 179810, 1318 ins, 2640 del, 4563 sub ] exp_phn_w2v_topo_3_1/tri6b/decode_dev_other/wer_7_0.0
# %WER 4.87 [ 8749 / 179810, 1244 ins, 2834 del, 4671 sub ] exp_phn_w2v_topo_3_1/tri6b/decode_dev_other.si/wer_7_0.0

# bash run_phn_w2v.sh --w2v_dir /checkpoint/abaevski/asr/unsup/data/segmented/precompute_unfiltered_pca256 --num_sil_states 3 --num_nonsil_states 1 --suffix phn_w2v_rmsil_pca256_topo_3_1 --stage 1 --train_stage 7
# %WER 15.34 [ 27586 / 179810, 3263 ins, 13751 del, 10572 sub ] exp_phn_w2v_rmsil_pca256_topo_3_1/mono/decode_dev_other/wer_12_0.0
# %WER 10.07 [ 18101 / 179810, 4868 ins, 5621 del, 7612 sub ] exp_phn_w2v_rmsil_pca256_topo_3_1/tri1/decode_dev_other/wer_17_1.0
# %WER 7.02 [ 12615 / 179810, 1699 ins, 5268 del, 5648 sub ] exp_phn_w2v_rmsil_pca256_topo_3_1/tri2b/decode_dev_other/wer_7_0.0
# %WER 6.52 [ 11727 / 179810, 1705 ins, 4599 del, 5423 sub ] exp_phn_w2v_rmsil_pca256_topo_3_1/tri3b/decode_dev_other/wer_7_0.0
# %WER 7.00 [ 12585 / 179810, 1740 ins, 5165 del, 5680 sub ] exp_phn_w2v_rmsil_pca256_topo_3_1/tri3b/decode_dev_other.si/wer_7_0.0
# %WER 5.94 [ 10688 / 179810, 1465 ins, 4274 del, 4949 sub ] exp_phn_w2v_rmsil_pca256_topo_3_1/tri4b/decode_dev_other/wer_7_0.0
# %WER 6.49 [ 11666 / 179810, 1439 ins, 4951 del, 5276 sub ] exp_phn_w2v_rmsil_pca256_topo_3_1/tri4b/decode_dev_other.si/wer_7_0.0
# %WER 5.55 [ 9983 / 179810, 1250 ins, 4123 del, 4610 sub ] exp_phn_w2v_rmsil_pca256_topo_3_1/tri5b/decode_dev_other/wer_7_0.0
# %WER 5.90 [ 10614 / 179810, 1168 ins, 4689 del, 4757 sub ] exp_phn_w2v_rmsil_pca256_topo_3_1/tri5b/decode_dev_other.si/wer_7_0.0
# %WER 5.08 [ 9141 / 179810, 1200 ins, 3623 del, 4318 sub ] exp_phn_w2v_rmsil_pca256_topo_3_1/tri6b/decode_dev_other/wer_7_0.0
# %WER 5.19 [ 9338 / 179810, 1159 ins, 3785 del, 4394 sub ] exp_phn_w2v_rmsil_pca256_topo_3_1/tri6b/decode_dev_other.si/wer_7_0.0

# bash run_phn_w2v.sh --w2v_dir /checkpoint/abaevski/asr/unsup/data/segmented/precompute_unfiltered_pca512 --num_sil_states 3 --num_nonsil_states 1 --suffix phn_w2v_rmsil_pca512_topo_3_1 --stage 1 --train_stage 7
# %WER 15.76 [ 28337 / 179810, 3518 ins, 14336 del, 10483 sub ] exp_phn_w2v_rmsil_pca512_topo_3_1/mono/decode_dev_other/wer_17_0.0
# %WER 10.76 [ 19343 / 179810, 6830 ins, 5660 del, 6853 sub ] exp_phn_w2v_rmsil_pca512_topo_3_1/tri1/decode_dev_other/wer_17_1.0
# %WER 7.10 [ 12770 / 179810, 1713 ins, 5927 del, 5130 sub ] exp_phn_w2v_rmsil_pca512_topo_3_1/tri2b/decode_dev_other/wer_7_0.0
# %WER 6.52 [ 11717 / 179810, 1716 ins, 4901 del, 5100 sub ] exp_phn_w2v_rmsil_pca512_topo_3_1/tri3b/decode_dev_other/wer_7_0.0
# %WER 7.01 [ 12598 / 179810, 1723 ins, 5568 del, 5307 sub ] exp_phn_w2v_rmsil_pca512_topo_3_1/tri3b/decode_dev_other.si/wer_7_0.0

# bash run_phn_w2v.sh --w2v_dir /checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_unfiltered_pca512 --num_sil_states 3 --num_nonsil_states 1 --suffix phn_w2v_pca512_topo_3_1 --stage 1 --train_stage 7
# %WER 14.18 [ 25501 / 179810, 4176 ins, 11318 del, 10007 sub ] exp_phn_w2v_pca512_topo_3_1/mono/decode_dev_other/wer_16_0.0
# %WER 9.94 [ 17871 / 179810, 7390 ins, 3629 del, 6852 sub ] exp_phn_w2v_pca512_topo_3_1/tri1/decode_dev_other/wer_17_1.0
# %WER 6.42 [ 11546 / 179810, 2150 ins, 4164 del, 5232 sub ] exp_phn_w2v_pca512_topo_3_1/tri2b/decode_dev_other/wer_7_0.0
# %WER 5.86 [ 10535 / 179810, 2025 ins, 3298 del, 5212 sub ] exp_phn_w2v_pca512_topo_3_1/tri3b/decode_dev_other/wer_7_0.0
# %WER 6.34 [ 11393 / 179810, 2092 ins, 3814 del, 5487 sub ] exp_phn_w2v_pca512_topo_3_1/tri3b/decode_dev_other.si/wer_7_0.0
# %WER 5.40 [ 9702 / 179810, 1831 ins, 3072 del, 4799 sub ] exp_phn_w2v_pca512_topo_3_1/tri4b/decode_dev_other/wer_7_0.0
# %WER 6.00 [ 10789 / 179810, 1906 ins, 3794 del, 5089 sub ] exp_phn_w2v_pca512_topo_3_1/tri4b/decode_dev_other.si/wer_7_0.0
# %WER 4.92 [ 8848 / 179810, 1479 ins, 2915 del, 4454 sub ] exp_phn_w2v_pca512_topo_3_1/tri5b/decode_dev_other/wer_7_0.0
# %WER 5.30 [ 9527 / 179810, 1449 ins, 3469 del, 4609 sub ] exp_phn_w2v_pca512_topo_3_1/tri5b/decode_dev_other.si/wer_7_0.0
# %WER 4.49 [ 8069 / 179810, 1396 ins, 2576 del, 4097 sub ] exp_phn_w2v_pca512_topo_3_1/tri6b/decode_dev_other/wer_7_0.0
# %WER 4.59 [ 8255 / 179810, 1333 ins, 2766 del, 4156 sub ] exp_phn_w2v_pca512_topo_3_1/tri6b/decode_dev_other.si/wer_7_0.0

# ===========================
# Train on Pseudo Transcripts
# ===========================

bash run_phn_w2v_unsup.sh
# ==== WER w.r.t. pseudo transcript
# %WER 23.28 [ 39671 / 170441, 12100 ins, 15586 del, 11985 sub ] exp_phn_w2v_topo_3_1_unsup_22uer_it1/mono/decode_dev_other/wer_9_0.0
# %WER 20.87 [ 35563 / 170441, 16906 ins, 8842 del, 9815 sub ] exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri1/decode_dev_other/wer_17_1.0
# %WER 18.56 [ 31641 / 170441, 14705 ins, 10908 del, 6028 sub ] exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri2b/decode_dev_other/wer_7_0.0
# %WER 18.20 [ 31028 / 170441, 15333 ins, 10162 del, 5533 sub ] exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri3b/decode_dev_other/wer_7_0.0
# %WER 18.61 [ 31715 / 170441, 14917 ins, 10993 del, 5805 sub ] exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri3b/decode_dev_other.si/wer_7_0.0
# %WER 17.96 [ 30609 / 170441, 14568 ins, 10815 del, 5226 sub ] exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri4b/decode_dev_other/wer_7_0.0
# %WER 18.52 [ 31558 / 170441, 13940 ins, 12219 del, 5399 sub ] exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri4b/decode_dev_other.si/wer_7_0.0
# %WER 17.69 [ 30147 / 170441, 13261 ins, 12036 del, 4850 sub ] exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri5b/decode_dev_other/wer_7_0.0
# %WER 18.34 [ 31261 / 170441, 12753 ins, 13350 del, 5158 sub ] exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri5b/decode_dev_other.si/wer_7_0.0
# %WER 17.20 [ 29309 / 170441, 13375 ins, 11043 del, 4891 sub ] exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri6b/decode_dev_other/wer_7_0.0
# %WER 17.38 [ 29615 / 170441, 13019 ins, 11564 del, 5032 sub ] exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri6b/decode_dev_other.si/wer_7_0.0
# ==== WER w.r.t. real transcript
# %WER 24.75 [ 44499 / 179810, 9718 ins, 18585 del, 16196 sub ]  exp_phn_w2v_topo_3_1_unsup_22uer_it1/mono/decode_dev_other
# %WER 19.21 [ 34536 / 179810, 10353 ins, 11658 del, 12525 sub ]  exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri1/decode_dev_other
# %WER 14.95 [ 26886 / 179810, 6704 ins, 12276 del, 7906 sub ]  exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri2b/decode_dev_other
# %WER 14.51 [ 26098 / 179810, 7072 ins, 11270 del, 7756 sub ]  exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri3b/decode_dev_other
# %WER 15.02 [ 27007 / 179810, 6804 ins, 12249 del, 7954 sub ]  exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri3b/decode_dev_other.si
# %WER 14.80 [ 26606 / 179810, 6722 ins, 12338 del, 7546 sub ]  exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri4b/decode_dev_other
# %WER 15.29 [ 27484 / 179810, 6061 ins, 13709 del, 7714 sub ]  exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri4b/decode_dev_other.si
# %WER 15.26 [ 27437 / 179810, 6068 ins, 14212 del, 7157 sub ]  exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri5b/decode_dev_other
# %WER 15.69 [ 28215 / 179810, 5481 ins, 15447 del, 7287 sub ]  exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri5b/decode_dev_other.si
# %WER 15.25 [ 27422 / 179810, 6500 ins, 13537 del, 7385 sub ]  exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri6b/decode_dev_other
# %WER 15.11 [ 27177 / 179810, 5915 ins, 13829 del, 7433 sub ]  exp_phn_w2v_topo_3_1_unsup_22uer_it1/tri6b/decode_dev_other.si

# TODO: w2v_dir and label does not align, need to manually copy text from data_phn_w2v_topo_3_1_unsup_22uer_it1
# #bash run_phn_w2v_unsup.sh --w2v_dir /checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_unfiltered_pca512 --suffix phn_w2v_pca512_topo_3_1_unsup_22uer_it1 --ref_root data_phn_w2v_pca512_topo_3_1 --stage 1 --train_stage 7
# ==== WER w.r.t. pseudo transcript
# %WER 21.80 [ 37156 / 170441, 13194 ins, 15752 del, 8210 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/mono/decode_dev_other/wer_16_0.0
# %WER 22.09 [ 37642 / 170441, 24277 ins, 7108 del, 6257 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri1/decode_dev_other/wer_17_1.0
# %WER 19.32 [ 32935 / 170441, 14246 ins, 13556 del, 5133 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri2b/decode_dev_other/wer_7_0.0
# %WER 18.51 [ 31547 / 170441, 14678 ins, 12019 del, 4850 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri3b/decode_dev_other/wer_7_0.0
# %WER 19.34 [ 32961 / 170441, 14233 ins, 13687 del, 5041 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri3b/decode_dev_other.si/wer_7_0.0
# %WER 18.31 [ 31200 / 170441, 13871 ins, 12473 del, 4856 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri4b/decode_dev_other/wer_7_0.0
# %WER 19.10 [ 32560 / 170441, 13377 ins, 14183 del, 5000 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri4b/decode_dev_other.si/wer_7_0.0
# %WER 18.13 [ 30909 / 170441, 12740 ins, 13467 del, 4702 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri5b/decode_dev_other/wer_7_0.0
# %WER 18.69 [ 31856 / 170441, 12402 ins, 14638 del, 4816 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri5b/decode_dev_other.si/wer_7_0.0
# %WER 17.51 [ 29849 / 170441, 12750 ins, 12358 del, 4741 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri6b/decode_dev_other/wer_7_0.0
# %WER 17.58 [ 29961 / 170441, 12665 ins, 12521 del, 4775 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri6b/decode_dev_other.si/wer_7_0.0
# ==== WER w.r.t. real transcript
# %WER 22.23 [ 39976 / 179810, 9050 ins, 18989 del, 11937 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/mono/decode_dev_other
# %WER 19.11 [ 34356 / 179810, 16474 ins, 8674 del, 9208 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri1/decode_dev_other
# %WER 15.27 [ 27451 / 179810, 5852 ins, 14531 del, 7068 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri2b/decode_dev_other
# %WER 14.44 [ 25972 / 179810, 6181 ins, 12891 del, 6900 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri3b/decode_dev_other
# %WER 15.28 [ 27481 / 179810, 5814 ins, 14637 del, 7030 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri3b/decode_dev_other.si
# %WER 14.97 [ 26914 / 179810, 5971 ins, 13942 del, 7001 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri4b/decode_dev_other
# %WER 15.75 [ 28315 / 179810, 5516 ins, 15691 del, 7108 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri4b/decode_dev_other.si
# %WER 15.50 [ 27875 / 179810, 5452 ins, 15548 del, 6875 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri5b/decode_dev_other
# %WER 16.01 [ 28793 / 179810, 5141 ins, 16746 del, 6906 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri5b/decode_dev_other.si
# %WER 15.27 [ 27462 / 179810, 5670 ins, 14647 del, 7145 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri6b/decode_dev_other
# %WER 15.16 [ 27252 / 179810, 5477 ins, 14702 del, 7073 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri6b/decode_dev_other.si

# bash ali_scripts/decode.sh exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1 data_phn_w2v_pca512_topo_3_1_unsup_22uer_it1
# ==== WER w.r.t. real transcript
# %WER 10.29 [ 365762 / 3555817, 99516 ins, 164645 del, 101601 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri3b/decode_train_clean_100/scoring/7.0.0.tra
# %WER 10.28 [ 365672 / 3555817, 94970 ins, 168664 del, 102038 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri3b/decode_train_clean_100.si/scoring/7.0.0.tra
# %WER 10.39 [ 1341907 / 12909596, 363229 ins, 608659 del, 370019 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri3b/decode_train_clean_360/scoring/7.0.0.tra
# %WER 10.44 [ 1347892 / 12909596, 344443 ins, 631239 del, 372210 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri3b/decode_train_clean_360.si/scoring/7.0.0.tra
# %WER 11.83 [ 2020729 / 17075020, 506014 ins, 959901 del, 554814 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri3b/decode_train_other_500/scoring/7.0.0.tra
# %WER 13.02 [ 2223334 / 17075020, 468929 ins, 1178142 del, 576263 sub ] exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1/tri3b/decode_train_other_500.si/scoring/7.0.0.tra

# bash ali_scripts/align.sh exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1 data_phn_w2v_pca512_topo_3_1_unsup_22uer_it1

# data_root=data_phn_w2v_topo_3_1
# local_gan/prepare_lm.sh $data_root/train_960/text \
#   $data_root/local/lm_phn_960 $data_root/lang_nosp $data_root/lang_nosp_960_test_bg
# bash ali_scripts/decode.sh --graph_name graph_960 \
#   --lang data_phn_w2v_topo_3_1/lang_nosp_960_test_bg --decode_suffix 960 \
#   exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1 data_phn_w2v_pca512_topo_3_1_unsup_22uer_it1

# data_root=data_phn_w2v_topo_3_1
# local_gan/prepare_lm.sh --order 4 $data_root/train_960/text \
#   $data_root/local/lm_phn_960_4g $data_root/lang_nosp $data_root/lang_nosp_960_test_4g
# bash ali_scripts/decode.sh --exp_name tri3b --graph_name graph_960_4g \
#   --lang data_phn_w2v_topo_3_1/lang_nosp_960_test_4g --decode_suffix 960-4g \
#   exp_phn_w2v_pca512_topo_3_1_unsup_22uer_it1 data_phn_w2v_pca512_topo_3_1_unsup_22uer_it1


# bash run_phn_ipl.sh

# bash ali_scripts/decode.sh exp_phn_w2v_pca512_topo_3_1_unsup_22uer_hmm_it2 data_phn_w2v_pca512_topo_3_1_unsup_22uer_hmm_it2

# bash ali_scripts/decode.sh --exp_name tri3b --graph_name graph_960_4g \
#   --lang data_phn_w2v_topo_3_1/lang_nosp_960_test_4g --decode_suffix 960-4g \
#   exp_phn_w2v_pca512_topo_3_1_unsup_22uer_hmm_it2 data_phn_w2v_pca512_topo_3_1_unsup_22uer_hmm_it2


# ===========================
# Train on Pseudo Transcripts (from a failed GAN model) for probing how indicative AM score is
# ===========================

bash run_phn_w2v_unsup.sh --pred_lab_dir /checkpoint/abaevski/asr/unsup/data/segmented/87_uer_transcriptions --ckpt_name checkpoint_last.pt --suffix phn_w2v_topo_3_1_unsup_87uer_it1 --stage 1 --train_stage 7

