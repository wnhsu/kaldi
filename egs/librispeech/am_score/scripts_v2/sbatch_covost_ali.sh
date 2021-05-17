#!/bin/bash
#SBATCH --time=72:00:00
#SBATCH --partition=devlab,learnlab
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=100G
#SBATCH --output=./log/train_covost_ipa-%j.out

set -eu


# ===== INPUT
aud_root=/private/home/changhan/data/datasets/speech/common_voice_20191210
tsv_root=/private/home/yuntang/2021/joint_pretraining/data/covost/x_to_en
train_names=(
  "train_ca_en_covost"
  "train_cy_en_covost"
  "train_de_en_covost"
  "train_es_en_covost"
  "train_et_en_covost"
  "train_fa_en_covost"
  "train_fr_en_covost"
  "train_id_en_covost"
  "train_it_en_covost"
  "train_lv_en_covost"
  "train_nl_en_covost"
  "train_pt_en_covost"
  "train_ru_en_covost"
  "train_sv_en_covost"
  "train_ta_en_covost"
  "train_tr_en_covost"
  "train_zh_en_covost"
)
valid_names=(
  "dev_ca_en_cv" 
  "dev_cy_en_cv"
  "dev_de_en_cv"
  "dev_es_en_cv"
  "dev_et_en_cv"
  "dev_fa_en_cv"
  "dev_fr_en_cv"
  "dev_id_en_cv"
  "dev_it_en_cv"
  "dev_lv_en_cv"
  "dev_nl_en_cv"
  "dev_pt_en_cv"
  "dev_ru_en_cv"
  "dev_ta_en_cv"
  "dev_tr_en_cv"
  "dev_zh_en_cv"
  "test_ca_en_cv"
  "test_cy_en_cv"
  "test_de_en_cv"
  "test_es_en_cv"
  "test_et_en_cv"
  "test_fa_en_cv"
  "test_fr_en_cv"
  "test_id_en_cv"
  "test_it_en_cv"
  "test_lv_en_cv"
  "test_nl_en_cv"
  "test_pt_en_cv"
  "test_ru_en_cv"
  "test_ta_en_cv"
  "test_tr_en_cv"
)

# ===== OUTPUT
exp_root=./output_v2/mfcc_covost_ali/exp
exp_name=covost_ali

data_dir=./output_v2/mfcc_covost_ali

ali_dir=./output_v2/mfcc_covost_ali/ali
ali_exps="mono tri1"


# ===== TRAIN

. ./cmd.sh
. ./path.sh


for split in ${train_names[@]} ${valid_names[@]}; do
  python local/prepare_data_from_s2t.py $aud_root $tsv_root/$split.tsv $data_dir/data $split
  utils/fix_data_dir.sh $data_dir/data/$split
done


dict=$data_dir/data/dict.ipa.txt
for split in ${train_names[@]}; do
  cut -f2- -d' ' $data_dir/data/$split/text
done | python local/prepare_dict_from_text.py > $dict
local/prepare_lang.sh --num_sil_states 5 --num_nonsil_states 3 $dict $data_dir/data


for split in ${train_names[@]} ${valid_names[@]}; do
  mfccexp=$data_dir/make_feat/$split
  mfccdir=$data_dir/mfcc/$split

  steps/make_mfcc.sh --cmd "$train_cmd" --nj 40 $data_dir/data/$split $mfccexp $mfccdir
  steps/compute_cmvn_stats.sh $data_dir/data/$split $mfccexp $mfccdir
done


xs=""
for split in ${train_names[@]}; do
  xs="$xs $data_dir/data/$split"
done
utils/combine_data.sh $data_dir/data/train_all $xs


steps/train_mono.sh --boost-silence 1.25 --nj 40 --cmd "$train_cmd" \
  $data_dir/data/train_all $data_dir/data/lang $exp_root/$exp_name/mono

steps/align_si.sh --boost-silence 1.25 --nj 40 --cmd "$train_cmd" \
  $data_dir/data/train_all $data_dir/data/lang $exp_root/$exp_name/mono $exp_root/$exp_name/mono_ali

# train a first delta + delta-delta triphone system on a subset of 5000 utterances
steps/train_deltas.sh --boost-silence 1.25 --cmd "$train_cmd" 2000 10000 \
  $data_dir/data/train_all $data_dir/data/lang $exp_root/$exp_name/mono_ali $exp_root/$exp_name/tri1

# ===== ALIGN
for ali_exp in $ali_exps; do
  for split in ${valid_names[@]} ${train_names[@]}; do
    local/write_ali_int.sh --splits "$split" --ali_script steps/align_si.sh \
      $exp_root/$exp_name/$ali_exp \
      $data_dir/data $data_dir/data/lang $ali_dir/$ali_exp &
  done
done
wait
