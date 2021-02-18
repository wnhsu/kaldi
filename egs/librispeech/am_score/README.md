# Compute AM score

Suppose features and ground truth phonetic labels are stored in `<w2v_dir>`,
pseudo labels are stored in `<new_label_dir>`, the training set and validation
set used for HMM training are `train` and `valid`, and the label name is `phnc`.


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
# OUTPUT: ${out_root}/${out_name}/{exp,am_score.txt}

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

