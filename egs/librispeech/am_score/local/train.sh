#!/usr/bin/env bash

out_root=/tmp
out_name=train_${RANDOM}
num_nonsil_states=1

valid="dev_other"
mono_train=train_2kshort
tri1_train=train_5k
tri2b_train=train_10k
tri3b_train=train_10k

stage=1
max_stage=1

. ./cmd.sh
. ./path.sh
. parse_options.sh

data=$1
lang=$2
lang_test=$3

exp_root=$out_root/$out_name

# you might not want to do this for interactive shells.
set -e


if [ $stage -le 1 ] && [ $max_stage -ge 1 ]; then
  # train a monophone system
  steps/train_mono.sh --boost-silence 1.25 --nj 20 --cmd "$train_cmd" \
    $data/$mono_train $lang $exp_root/mono

  utils/mkgraph.sh $lang_test $exp_root/mono $exp_root/mono/graph
  steps/decode.sh --nj 20 --cmd "$decode_cmd" \
    $exp_root/mono/graph $data/$valid $exp_root/mono/decode_$valid &
fi


if [ $stage -le 2 ] && [ $max_stage -ge 2 ]; then
  steps/align_si.sh --boost-silence 1.25 --nj 10 --cmd "$train_cmd" \
    $data/$tri1_train $lang \
    $exp_root/mono $exp_root/mono_ali_${tri1_train}

  # train a first delta + delta-delta triphone system on a subset of 5000 utterances
  steps_gan/train_deltas.sh --boost-silence 1.25 --cmd "$train_cmd" \
      --num_nonsil_states $num_nonsil_states 2000 10000 \
      $data/$tri1_train $lang \
      $exp_root/mono_ali_${tri1_train} $exp_root/tri1

  utils/mkgraph.sh $lang_test $exp_root/tri1 $exp_root/tri1/graph
  steps/decode.sh --nj 20 --cmd "$decode_cmd" \
    $exp_root/tri1/graph $data/$valid $exp_root/tri1/decode_$valid &
fi


if [ $stage -le 3 ] && [ $max_stage -ge 3 ]; then
  steps/align_si.sh --nj 10 --cmd "$train_cmd" \
    $data/$tri2b_train $lang \
    $exp_root/tri1 $exp_root/tri1_ali_${tri2b_train}

  # train an LDA+MLLT system.
  steps_gan/train_lda_mllt.sh --cmd "$train_cmd" \
      --num_nonsil_states $num_nonsil_states \
      --splice-opts "--left-context=3 --right-context=3" 2500 15000 \
      $data/$tri2b_train $lang \
      $exp_root/tri1_ali_${tri2b_train} $exp_root/tri2b

  utils/mkgraph.sh $lang_test $exp_root/tri2b $exp_root/tri2b/graph
  steps/decode.sh --nj 20 --cmd "$decode_cmd" \
    $exp_root/tri2b/graph $data/$valid $exp_root/tri2b/decode_$valid &
fi


if [ $stage -le 4 ] && [ $max_stage -ge 4 ]; then
  steps/align_si.sh  --nj 10 --cmd "$train_cmd" --use-graphs true \
    $data/$tri3b_train $lang \
    $exp_root/tri2b $exp_root/tri2b_ali_${tri2b_train}

  # Train tri3b, which is LDA+MLLT+SAT on 10k utts
  steps_gan/train_sat.sh --cmd "$train_cmd" \
    --num_nonsil_states $num_nonsil_states 2500 15000 \
    $data/$tri3b_train $lang \
    $exp_root/tri2b_ali_${tri2b_train} $exp_root/tri3b

  utils/mkgraph.sh $lang_test $exp_root/tri3b $exp_root/tri3b/graph
  steps/decode_fmllr.sh --nj 20 --cmd "$decode_cmd" \
    $exp_root/tri3b/graph $data/$valid $exp_root/tri3b/decode_$valid &
fi
