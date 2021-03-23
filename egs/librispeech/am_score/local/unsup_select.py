"""
Implement unsupervised metric for decoding hyperparameter selection:
    $$ alpha * LM_PPL + ViterbitUER(%) * 100 $$
"""
import argparse
import logging
import math
import sys

import kenlm
import editdistance

logging.root.setLevel(logging.INFO)
logging.basicConfig(stream=sys.stdout, level=logging.INFO)
logger = logging.getLogger(__name__)

def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("ref_tra", help="reference pseudo labels")
    parser.add_argument("hyp_tra", help="decoded pseudo labels to be assess")
    parser.add_argument("--kenlm_path", default="/checkpoint/abaevski/data/speech/libri/librispeech_lm_novox.phnc_o5.bin", help="")
    parser.add_argument("--uppercase", action="store_true", help="")
    parser.add_argument("--skipwords", default="", help="")
    parser.add_argument("--gt_tra", default="", help="ground truth pseudo labels for computing oracle WER")
    parser.add_argument("--lm_ppl_weight", default=1.0)
    return parser

def load_tra(tra_path):
    with open(tra_path, "r") as f:
        uid_to_tra = {}
        for line in f:
            uid, tra = line.split(None, 1)
            uid_to_tra[uid] = tra
    logger.debug(f"loaded {len(uid_to_tra)} utterances from {tra_path}")
    return uid_to_tra

def compute_wer(ref_uid_to_tra, hyp_uid_to_tra):
    d_cnt = 0
    w_cnt = 0
    w_cnt_h = 0
    for uid in hyp_uid_to_tra:
        ref = ref_uid_to_tra[uid].split()
        hyp = hyp_uid_to_tra[uid].split()
        d_cnt += editdistance.eval(ref, hyp)
        w_cnt += len(ref)
        w_cnt_h += len(hyp)
    wer = float(d_cnt) / w_cnt
    logger.debug((
        f"wer = {wer*100:.2f}%; num. of ref words = {w_cnt}; "
        f"num. of hyp words = {w_cnt_h}; num. of sentences = {len(ref_uid_to_tra)}"
    ))
    return wer

def compute_lm_ppl(hyp_uid_to_tra, score_fn):
    lm_score = 0.
    w_cnt = 0
    for hyp in hyp_uid_to_tra.values():
        lm_score += score_fn(hyp)
        w_cnt += len(hyp.split()) + 1  # plus one for </s>
    lm_ppl = math.pow(10, -lm_score / w_cnt)
    logger.debug(f"lm ppl = {lm_ppl:.2f}; num. of words = {w_cnt}")
    return lm_ppl

def main():
    args = get_parser().parse_args()
    logger.debug(f"Args: {args}")
    
    ref_uid_to_tra = load_tra(args.ref_tra)
    hyp_uid_to_tra = load_tra(args.hyp_tra)
    assert not bool(set(hyp_uid_to_tra.keys()) - set(ref_uid_to_tra.keys()))

    lm = kenlm.Model(args.kenlm_path)
    skipwords = set(args.skipwords.split(","))
    def compute_lm_score(s):
        s = " ".join(w for w in s.split() if w not in skipwords)
        s = s.upper() if args.uppercase else s
        return lm.score(s)

    wer = compute_wer(ref_uid_to_tra, hyp_uid_to_tra)
    lm_ppl = compute_lm_ppl(hyp_uid_to_tra, compute_lm_score)
    
    gt_wer = -math.inf
    if args.gt_tra:
        gt_uid_to_tra = load_tra(args.gt_tra)
        gt_wer = compute_wer(gt_uid_to_tra, hyp_uid_to_tra)

    score = lm_ppl * args.lm_ppl_weight + wer * 100
    logging.info(f"{args.hyp_tra}: score={score:.4f}; wer={wer*100:.2f}%; lm_ppl={lm_ppl:.4f}; gt_wer={gt_wer*100:.2f}%")

if __name__ == "__main__":
    main()
