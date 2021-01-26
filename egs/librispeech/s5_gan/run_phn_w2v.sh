#!/usr/bin/env bash

# Assume having finished stage 3 of run_phn.sh

suffix=phn_w2v_rmsil_pca128_topo_3_1
w2v_dir=/checkpoint/abaevski/asr/unsup/data/segmented/precompute_unfiltered_pca128_seg
val_sets="dev_other"
ref_root=data_phn_mfcc
num_sil_states=3
num_nonsil_states=1

stage=1
train_stage=7

. ./cmd.sh
. ./path.sh
. parse_options.sh

data_root=data_$suffix
exp_root=exp_$suffix
feat_dir=w2v_feat_$suffix

echo "$data_root $exp_root $feat_dir $w2v_dir $val_sets $num_sil_states $num_nonsil_states"

# you might not want to do this for interactive shells.
set -e


if [ $stage -le 1 ]; then
  # format the data as Kaldi data directories
  for part in train_clean_100 train_clean_360 train_other_500; do
    python local_gan/copy_w2v_data_to_kaldi.py \
      --w2v_dir $w2v_dir \
      --w2v_split train \
      --out_root $data_root \
      --out_split $part \
      --ref_root $ref_root \
      --use_w2v_feat

    steps/compute_cmvn_stats.sh $data_root/$part $exp_root/make_feat/$part $feat_dir
  done

  for part in $val_sets; do
    python local_gan/copy_w2v_data_to_kaldi.py \
      --w2v_dir $w2v_dir \
      --w2v_split $part \
      --out_root $data_root \
      --out_split $part \
      --ref_root $ref_root \
      --use_w2v_feat

    steps/compute_cmvn_stats.sh $data_root/$part $exp_root/make_feat/$part $feat_dir
  done

  utils/combine_data.sh \
    $data_root/train_clean_460 $data_root/train_clean_100 $data_root/train_clean_360
  utils/combine_data.sh \
    $data_root/train_960 $data_root/train_clean_460 $data_root/train_other_500
fi

if [ $stage -le 2 ]; then
  mkdir -p $data_root/local && ln -s $(realpath $ref_root/local/lm) $data_root/local/lm

  # when the "--stage 3" option is used below we skip the G2P steps, and use the
  # lexicon we have already downloaded from openslr.org/11/
  local_gan/prepare_dict.sh --stage 3 --nj 30 --cmd "$train_cmd" \
    $data_root/local/lm $data_root/local/lm $data_root/local/dict_nosp

  utils/prepare_lang.sh --position-dependent-phones false \
    --num_sil_states $num_sil_states --num_nonsil_states $num_nonsil_states \
    $data_root/local/dict_nosp \
   "<UNK>" $data_root/local/lang_tmp_nosp $data_root/lang_nosp

  # build phone bigram model (following TIMIT)
  local_gan/prepare_lm.sh $data_root/train_clean_100/text \
    $data_root/local/lm_phn $data_root/lang_nosp $data_root/lang_nosp_test_bg
fi

if [ $stage -le 3 ]; then
  bash run_train.sh $data_root $exp_root $train_stage $val_sets $num_nonsil_states
fi
