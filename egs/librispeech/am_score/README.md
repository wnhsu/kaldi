# Compute AM score

Suppose features and ground truth phonetic labels are stored in `<w2v_dir>`,
pseudo labels are stored in `<new_label_dir>`, the training set and validation
set used for HMM training are `train` and `valid`, and the label name is
`phnc`. See `example_compute_am.sh` and `example_compute_am_nonen.sh` for
examples.


Step 1: prepare lang and features

```bash
# INPUT: dict.phnc.txt, {train,valid}.{npy,lengths,phnc} from $w2v_dir
# OUTPUT: ${dir}/{data,feats,make_feat}

local/prepare_lang.sh $w2v_dir/dict.phnc.txt $dir/data
for split in train valid; do
  python local/prepare_data_from_w2v.py $w2v_dir $dir/data $split --label phnc
  steps/compute_cmvn_stats.sh $dir/data/$split $dir/make_feat/$split $dir/feats/$split
done
```


Step 2: prepare pseudo text and train HMM. this assumes the order of the pseudo
transcripts are aligned with that in `${split}.${label}` in step 1, and features
from the step 1 will be used.

stage
- 1: mono phone
- 2: first triphone with delta + delta-delta
- 3: second triphone with additional LDA + MLLT transform
```bash
# INPUT: $dir from step 1, {train,valid}.phnc from $new_label_dir
# OUTPUT: $new_dir, ${out_root}/${out_name}/{exp,am_score.txt}

for split in train valid; do
  mkdir -p $new_dir/data/$split
  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
  cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
  paste -d' ' $new_dir/data/$split/uids $new_label_dir/$split.phnc > $new_dir/data/$split/text

  echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-) 
done
local/compute_am_score.sh --out_root $out_root --out_name $out_name \
  --mono_train train --tri1_train train --tri2b_train train --valid valid --max_stage 1 \
  $new_dir/data $dir/data/lang
```


# Train an ASR model

In addition to the data required for computing acoustic model score, it
requires an Arpa-format language model for decoding. See `example_train.sh` and
`example_train_nonen.sh` for examples.


Step 1: prepare lang, features, and LM

```bash
# INPUT: dict.phnc.txt, {train,valid}.{npy,lengths,phnc} from $w2v_dir, $arpa_lm
# OUTPUT: ${dir}/{data,feats,make_feat}

local/prepare_lang.sh $w2v_dir/dict.phnc.txt $dir/data
local/prepare_lm.sh $arpa_lm $dir/data
for split in train valid; do
  python local/prepare_data_from_w2v.py $w2v_dir $dir/data $split --label $label
  steps/compute_cmvn_stats.sh $dir/data/$split $dir/make_feat/$split $dir/feats/$split
done
```

Step 2a: train HMM models on real transcripts (and automatically decode with each of those)

Options:
- `{mono,tri1,tri2b,tri3b}_size`: number of traing utterances to use for that stage. -1 uses all
- `stage`: running scripts from this stage
- `max_stage`: how many HMM stages to run, ranges from 1 to 4.

```bash
# INPUT: $dir from step 1
# OUTPUT: ${out_root}/${out_name}

local/train_subset.sh --out_root $out_root --out_name $out_name \
  --train train --valid valid \
  --mono_size 2000 --tri1_size 5000 --tri2b_size -1 --tri3b_size -1 \
  --stage 1 --max_stage 4 $dir/data $dir/data/lang $dir/data/lang_test
```

Step 2b: train HMM models on pseudo transcripts (and automatically decode with each of those)

```bash
# INPUT: $dir from step 1, {train,valid}.phnc from $new_label_dir
# OUTPUT: $new_dir, ${out_root}/${out_name}

for split in train valid; do
  mkdir -p $new_dir/data/$split
  cp $dir/data/$split/{feats.scp,cmvn.scp,utt2spk,spk2utt} $new_dir/data/$split
  cut -d' ' -f1 $dir/data/$split/text > $new_dir/data/$split/uids
  paste -d' ' $new_dir/data/$split/uids $new_label_dir/$split.$label > $new_dir/data/$split/text

  echo "WER on $split is" $(compute-wer ark:$dir/data/$split/text ark:$new_dir/data/$split/text | cut -d" " -f2-)
done

local/train_subset.sh --out_root $out_root --out_name $out_name \
  --train train --valid valid \
  --mono_size 5000 --tri1_size 5000 --tri2b_size 5000 --tri3b_size 5000 \
  --stage 1 --max_stage 4 $new_dir/data $dir/data/lang $dir/data/lang_test
local/show_wer.sh --ref_data output/w2v_pca128/data $out_root/$out_name
```

Step 3: show WER with respect to training transcripts (can be real or pseudo) and to reference transcripts

If `ref_data` is provided, it shows the WER with respect to the text found in
`$ref_data/$split`. This is useful when an HMM system is trained on pseudo
transcripts. Decoding hyperparameter selection is based on the WER on the
pseudo transcript. 

If `get_best_wer` is set to true, then this script would
also prints the best WER with respect to the reference data where the
hyperparameter is selected using the reference data.
```
local/show_wer.sh --split valid --ref_data $dir --get_best_wer true $out_root/$out_name
```
