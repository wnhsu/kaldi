#!/bin/bash

set -u
exp_root=$1


echo "==== WER w.r.t. pseudo transcript"
for x in $exp_root/{mono,tri,sgmm,dnn,combine}*/decode*; do grep WER $x/wer_* 2>/dev/null | utils/best_wer.sh; done


# echo "==== WER w.r.t. real transcript"
# split=dev_other
# txt=data_phn_mfcc/$split/text
# for decode_dir in $exp_root/{mono,tri,sgmm,dnn,combine}*/decode_${split}*; do
#   lang=$(dirname $decode_dir)/graph
#   
#   echo $(
#     for tra in $decode_dir/scoring/*.tra; do
#       cat $tra | utils/int2sym.pl -f 2- $lang/words.txt | sed 's:\<UNK\>::g' | \
#         compute-wer --text --mode=present \
#         ark:$txt  ark,p:- 2> /dev/null | grep WER
#     done | sort -k2n | head -n1
#   ) "$decode_dir"
# done


echo "==== WER w.r.t. real transcript"
exp="tri3b"
dec_param="7.0.0"
dec_prefix="decode960-4g"

for split in dev_other train_clean_100 train_clean_360 train_other_500; do
  echo ""
  txt=data_phn_mfcc/$split/text
  for decode_dir in $exp_root/${exp}*/${dec_prefix}_${split}*; do
    lang=$(dirname $decode_dir)/graph
    
    # for tra in $decode_dir/scoring/*.tra; do
      tra=$decode_dir/scoring/$dec_param.tra
      echo $(
        cat $tra | utils/int2sym.pl -f 2- $lang/words.txt | sed 's:\<UNK\>::g' | \
          compute-wer --text --mode=present \
          ark:$txt  ark,p:- 2> /dev/null | grep WER
      ) "$tra"
    # done
  done
done


exit 0;
