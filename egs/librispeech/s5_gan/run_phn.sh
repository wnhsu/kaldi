#!/usr/bin/env bash

# Assume data preparation part has been done by running run.sh

data_root=data_phn_mfcc
ref_root=data_bak
exp_root=exp_phn_mfcc
feat_dir=mfcc

stage=1
train_stage=7

. ./cmd.sh
. ./path.sh
. parse_options.sh

# you might not want to do this for interactive shells.
set -e


if [ $stage -le 1 ]; then
  # format the data as Kaldi data directories
  for part in train_clean_100 train_clean_360 train_other_500; do
    python local_gan/copy_w2v_data_to_kaldi.py \
      --w2v_dir /checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_unfiltered_pca128 \
      --w2v_split train \
      --out_root $data_root \
      --out_split $part \
      --ref_root $ref_root

    steps/compute_cmvn_stats.sh $data_root/$part $exp_root/make_feat/$part $feat_dir
  done

  for part in dev_clean dev_other; do
    python local_gan/copy_w2v_data_to_kaldi.py \
      --w2v_dir /checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_unfiltered_pca128 \
      --w2v_split $part \
      --out_root $data_root \
      --out_split $part \
      --ref_root $ref_root

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
    $data_root/local/dict_nosp \
   "<UNK>" $data_root/local/lang_tmp_nosp $data_root/lang_nosp

  # build phone bigram model (following TIMIT)
  local_gan/prepare_lm.sh $data_root/train_clean_100/text \
    $data_root/local/lm_phn $data_root/lang_nosp $data_root/lang_nosp_test_bg
fi

if [ $stage -le 3 ]; then
  bash run_train.sh $data_root $exp_root $train_stage
fi
