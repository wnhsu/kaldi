#!/usr/bin/env bash

# Assume having finished stage 2 of run_w2v_sup.sh

suffix=phn_w2v_topo_3_1_unsup_22uer_it1
w2v_dir=/checkpoint/abaevski/asr/unsup/data/segmented/precompute_unfiltered_pca128_seg
pred_lab_dir=/checkpoint/abaevski/asr/unsup/data/segmented/22_uer_transcriptions
val_sets="dev_other"
ref_root=data_phn_w2v_topo_3_1
num_nonsil_states=1
ckpt_name=checkpoint_best.pt

stage=1
train_stage=7

. ./cmd.sh
. ./path.sh
. parse_options.sh

data_root=data_$suffix
exp_root=exp_$suffix

# you might not want to do this for interactive shells.
set -e


if [ $stage -le 1 ]; then
  mkdir -p $data_root/local
  ln -sf $(realpath $ref_root/lang_nosp) $data_root
  ln -sf $(realpath $ref_root/lang_nosp_test_bg) $data_root
fi

if [ $stage -le 2 ]; then
  # format the data as Kaldi data directories
  for part in train_clean_100 train_clean_360 train_other_500; do
    python local_gan/copy_w2v_data_to_kaldi.py \
      --w2v_dir $w2v_dir \
      --w2v_split train \
      --out_root $data_root \
      --out_split $part \
      --ref_root $ref_root \
      --pred_lab_path $pred_lab_dir/hypo.units-${ckpt_name}-train.txt \
      --use_pred_lab

    # steps/compute_cmvn_stats.sh $data_root/$part $exp_root/make_feat/$part $feat_dir
  done

  for part in $val_sets; do
    python local_gan/copy_w2v_data_to_kaldi.py \
      --w2v_dir $w2v_dir \
      --w2v_split $part \
      --out_root $data_root \
      --out_split $part \
      --ref_root $ref_root \
      --pred_lab_path $pred_lab_dir/hypo.units-${ckpt_name}-$part.txt \
      --use_pred_lab

    # steps/compute_cmvn_stats.sh $data_root/$part $exp_root/make_feat/$part $feat_dir
  done
fi

if [ $stage -le 3 ]; then
  bash run_train.sh $data_root $exp_root $train_stage $val_sets $num_nonsil_states
fi
