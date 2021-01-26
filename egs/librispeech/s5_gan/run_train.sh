set -e

data_root=$1
exp_root=$2
stage=$3
val_sets=$4
num_nonsil_states=$5

if [ $stage -le 7 ]; then
  # Make some small data subsets for early system-build stages.  Note, there are 29k
  # utterances in the train_clean_100 directory which has 100 hours of data.
  # For the monophone stages we select the shortest utterances, which should make it
  # easier to align the data from a flat start.

  utils/subset_data_dir.sh --shortest $data_root/train_clean_100 2000 $data_root/train_2kshort
  utils/subset_data_dir.sh $data_root/train_clean_100 5000 $data_root/train_5k
  utils/subset_data_dir.sh $data_root/train_clean_100 10000 $data_root/train_10k
fi


if [ $stage -le 8 ]; then
  # train a monophone system
  steps_gan/train_mono.sh --boost-silence 1.25 --nj 20 --cmd "$train_cmd" \
    $data_root/train_2kshort $data_root/lang_nosp $exp_root/mono

  utils/mkgraph.sh $data_root/lang_nosp_test_bg $exp_root/mono $exp_root/mono/graph
  for part in $val_sets; do
    steps/decode.sh --nj 20 --cmd "$decode_cmd" \
      $exp_root/mono/graph $data_root/$part $exp_root/mono/decode_${part} &
  done
fi


if [ $stage -le 9 ]; then
  steps/align_si.sh --boost-silence 1.25 --nj 10 --cmd "$train_cmd" \
    $data_root/train_5k $data_root/lang_nosp \
    $exp_root/mono $exp_root/mono_ali_5k

  # train a first delta + delta-delta triphone system on a subset of 5000 utterances
  steps_gan/train_deltas.sh --boost-silence 1.25 --cmd "$train_cmd" \
      --num_nonsil_states $num_nonsil_states 2000 10000 \
      $data_root/train_5k $data_root/lang_nosp \
      $exp_root/mono_ali_5k $exp_root/tri1

  utils/mkgraph.sh $data_root/lang_nosp_test_bg $exp_root/tri1 $exp_root/tri1/graph
  for part in $val_sets; do
    steps/decode.sh --nj 20 --cmd "$decode_cmd" \
      $exp_root/tri1/graph $data_root/$part $exp_root/tri1/decode_${part} &
  done
fi


if [ $stage -le 10 ]; then
  steps/align_si.sh --nj 10 --cmd "$train_cmd" \
    $data_root/train_10k $data_root/lang_nosp \
    $exp_root/tri1 $exp_root/tri1_ali_10k

  # train an LDA+MLLT system.
  steps_gan/train_lda_mllt.sh --cmd "$train_cmd" \
      --num_nonsil_states $num_nonsil_states \
      --splice-opts "--left-context=3 --right-context=3" 2500 15000 \
      $data_root/train_10k $data_root/lang_nosp \
      $exp_root/tri1_ali_10k $exp_root/tri2b

  utils/mkgraph.sh $data_root/lang_nosp_test_bg $exp_root/tri2b $exp_root/tri2b/graph
  for part in $val_sets; do
    steps/decode.sh --nj 20 --cmd "$decode_cmd" \
      $exp_root/tri2b/graph $data_root/$part $exp_root/tri2b/decode_${part} &
  done
fi


if [ $stage -le 11 ]; then
  # Align a 10k utts subset using the tri2b model
  steps/align_si.sh  --nj 10 --cmd "$train_cmd" --use-graphs true \
    $data_root/train_10k $data_root/lang_nosp \
    $exp_root/tri2b $exp_root/tri2b_ali_10k

  # Train tri3b, which is LDA+MLLT+SAT on 10k utts
  steps_gan/train_sat.sh --cmd "$train_cmd" \
    --num_nonsil_states $num_nonsil_states 2500 15000 \
    $data_root/train_10k $data_root/lang_nosp \
    $exp_root/tri2b_ali_10k $exp_root/tri3b

  utils/mkgraph.sh $data_root/lang_nosp_test_bg $exp_root/tri3b $exp_root/tri3b/graph
  for part in $val_sets; do
    steps/decode_fmllr.sh --nj 20 --cmd "$decode_cmd" \
      $exp_root/tri3b/graph $data_root/$part $exp_root/tri3b/decode_${part} &
  done
fi


if [ $stage -le 12 ]; then
  # align the entire train_clean_100 subset using the tri3b model
  steps/align_fmllr.sh --nj 20 --cmd "$train_cmd" \
    $data_root/train_clean_100 $data_root/lang_nosp \
    $exp_root/tri3b $exp_root/tri3b_ali_clean_100

  # train another LDA+MLLT+SAT system on the entire 100 hour subset
  steps_gan/train_sat.sh --cmd "$train_cmd" \
    --num_nonsil_states $num_nonsil_states 4200 40000 \
    $data_root/train_clean_100 $data_root/lang_nosp \
    $exp_root/tri3b_ali_clean_100 $exp_root/tri4b

  utils/mkgraph.sh $data_root/lang_nosp_test_bg $exp_root/tri4b $exp_root/tri4b/graph
  for part in $val_sets; do
    steps/decode_fmllr.sh --nj 20 --cmd "$decode_cmd" \
      $exp_root/tri4b/graph $data_root/$part $exp_root/tri4b/decode_${part} &
  done
fi

if [ $stage -le 15 ]; then
  # ... and then combine the two sets into a 460 hour one
  utils/combine_data.sh \
    $data_root/train_clean_460 $data_root/train_clean_100 $data_root/train_clean_360
fi

if [ $stage -le 16 ]; then
  # align the new, combined set, using the tri4b model
  steps/align_fmllr.sh --nj 40 --cmd "$train_cmd" \
    $data_root/train_clean_460 $data_root/lang_nosp \
    $exp_root/tri4b $exp_root/tri4b_ali_clean_460

  # create a larger SAT model, trained on the 460 hours of data.
  steps_gan/train_sat.sh --cmd "$train_cmd" \
    --num_nonsil_states $num_nonsil_states 5000 100000 \
    $data_root/train_clean_460 $data_root/lang_nosp \
    $exp_root/tri4b_ali_clean_460 $exp_root/tri5b

  utils/mkgraph.sh $data_root/lang_nosp_test_bg $exp_root/tri5b $exp_root/tri5b/graph
  for part in $val_sets; do
    steps/decode_fmllr.sh --nj 20 --cmd "$decode_cmd" \
      $exp_root/tri5b/graph $data_root/$part $exp_root/tri5b/decode_${part} &
  done
fi

if [ $stage -le 17 ]; then
  # combine all the data
  utils/combine_data.sh \
    $data_root/train_960 $data_root/train_clean_460 $data_root/train_other_500
fi

if [ $stage -le 18 ]; then
  steps/align_fmllr.sh --nj 40 --cmd "$train_cmd" \
    $data_root/train_960 $data_root/lang_nosp \
    $exp_root/tri5b $exp_root/tri5b_ali_960

  # train a SAT model on the 960 hour mixed data. Use the train_quick.sh
  # script as it is faster.
  steps_gan/train_quick.sh --cmd "$train_cmd" \
    --num_nonsil_states $num_nonsil_states 7000 150000 \
    $data_root/train_960 $data_root/lang_nosp \
    $exp_root/tri5b_ali_960 $exp_root/tri6b

  utils/mkgraph.sh $data_root/lang_nosp_test_bg $exp_root/tri6b $exp_root/tri6b/graph
  for part in $val_sets; do
    steps/decode_fmllr.sh --nj 20 --cmd "$decode_cmd" \
      $exp_root/tri6b/graph $data_root/$part $exp_root/tri6b/decode_${part} &
  done
fi


wait

for x in $exp_root/{mono,tri,sgmm,dnn,combine}*/decode*; do
  # [ -d $x ] && echo $x | grep "${1:-.*}" >/dev/null && \
  # echo $x | grep "${1:-.*}" >/dev/null && \
    grep WER $x/wer_* 2>/dev/null | utils/best_wer.sh;
done
