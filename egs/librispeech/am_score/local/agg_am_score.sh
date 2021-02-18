#!/bin/bash

ali_dir=$1
grep "log-likelihood" $ali_dir/log/align.*.log \
  | sed 's/.*per frame is \([0-9\.\-]*\) over \([0-9]*\) frames/\1 \2/g' \
  | awk 'BEGIN {s=0; n=0} {s+=($1*$2); n+=$2;} END {print s/n}'
