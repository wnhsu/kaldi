#!/usr/bin/env bash

# Assume having finished stage 2 of run_w2v_sup.sh

out_root=/tmp
out_name=amscore_${RANDOM}
num_nonsil_states=1

valid="dev_other"
mono_train=train_2kshort
tri1_train=train_5k
tri2b_train=train_10k

stage=1
max_stage=1

. ./cmd.sh
. ./path.sh
. parse_options.sh

data=$1
lang=$2

exp_root=$out_root/$out_name/exp
am_score=$out_root/$out_name/am_score.txt

# you might not want to do this for interactive shells.
set -e


echo "================== $(date)"

if [ $stage -le 1 ] && [ $max_stage -ge 1 ]; then
  echo "================== $(date)"
  # train a monophone system
  steps/train_mono.sh --boost-silence 1.25 --nj 20 --cmd "$train_cmd" \
    $data/$mono_train $lang $exp_root/mono

  echo "================== $(date)"
  if [ $max_stage -eq 1 ]; then
    steps/align_si.sh --boost-silence 1.25 --nj 10 --cmd "$train_cmd" \
      $data/$valid $lang $exp_root/mono $exp_root/mono_ali_$valid
    local/agg_am_score.sh $exp_root/mono_ali_$valid > $am_score
  fi
fi


if [ $stage -le 2 ] && [ $max_stage -ge 2 ]; then
  echo "================== $(date)"
  steps/align_si.sh --boost-silence 1.25 --nj 10 --cmd "$train_cmd" \
    $data/$tri1_train $data/lang_nosp \
    $exp_root/mono $exp_root/mono_ali_${tri1_train}

  # train a first delta + delta-delta triphone system on a subset of 5000 utterances
  steps_gan/train_deltas.sh --boost-silence 1.25 --cmd "$train_cmd" \
      --num_nonsil_states $num_nonsil_states 2000 10000 \
      $data/$tri1_train $data/lang_nosp \
      $exp_root/mono_ali_${tri1_train} $exp_root/tri1

  echo "================== $(date)"
  if [ $max_stage -eq 2 ]; then
    steps/align_si.sh --nj 10 --cmd "$train_cmd" \
      $data/$valid $data/lang_nosp \
      $exp_root/tri1 $exp_root/tri1_ali_$valid
    ali_scripts/agg_am_score.sh $exp_root/tri1_ali_$valid > $am_score
  fi
fi


if [ $stage -le 3 ] && [ $max_stage -ge 3 ]; then
  echo "================== $(date)"
  steps/align_si.sh --nj 10 --cmd "$train_cmd" \
    $data/$tri2b_train $data/lang_nosp \
    $exp_root/tri1 $exp_root/tri1_ali_${tri2b_train}

  # train an LDA+MLLT system.
  steps_gan/train_lda_mllt.sh --cmd "$train_cmd" \
      --num_nonsil_states $num_nonsil_states \
      --splice-opts "--left-context=3 --right-context=3" 2500 15000 \
      $data/$tri2b_train $data/lang_nosp \
      $exp_root/tri1_ali_${tri2b_train} $exp_root/tri2b

  echo "================== $(date)"
  if [ $max_stage -eq 3 ]; then
    steps/align_si.sh  --nj 10 --cmd "$train_cmd" \
      $data/$valid $data/lang_nosp \
      $exp_root/tri2b $exp_root/tri2b_ali_$valid
    ali_scripts/agg_am_score.sh $exp_root/tri1_ali_$valid > $am_score
  fi
fi

echo "================== $(date)"
cat $am_score
