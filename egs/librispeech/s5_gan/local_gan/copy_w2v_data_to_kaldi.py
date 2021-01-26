import kaldi_io
import os
import re
import shutil
from w2v_kaldi_utils import KaldiData, W2VFeat

def main(ref_dir, w2v_dir, w2v_split, out_dir, lab_name, pred_lab_path, use_w2v_feat, use_pred_lab, rm_sil):
    ref_data = KaldiData(ref_dir)
    out_data = KaldiData(out_dir)
    w2v_feat = W2VFeat(w2v_dir, w2v_split, lab_name, pred_lab_path=pred_lab_path)
    assert(not (set(ref_data.utts) - set(w2v_feat.utt2idx.keys())))
    print(f"reference dir: {ref_dir} has {len(ref_data.utts)} utts")

    os.makedirs(out_dir, exist_ok=True)
    for name in KaldiData.fixed_names:
        src = ref_data.get_path(name)
        dst = out_data.get_path(name)
        if os.path.exists(src):
            shutil.copy(src, dst)
            print(f"...copied {src} to {dst}")
        else:
            print(f"...{src} not found")

    def preprocess(lab):
        if rm_sil:
            lab = re.sub(r"([^A-Z0-9]*)SIL([^A-Z0-9]*)", r"\1 \2", lab)
            lab = re.sub(r"^ *", "", lab)
            lab = re.sub(r" *$", "", lab)
            lab = re.sub(r"  *", " ", lab)
        return lab

    with open(out_data.text_path, "w") as f:
        for utt in ref_data.utts:
            if use_pred_lab:
                lab = w2v_feat.get_pred_lab(utt)
            else:
                lab = w2v_feat.get_lab(utt)
            lab = preprocess(lab)
            f.write(f"{utt} {lab}\n")
        print(f"...wrote transcript to {out_data.text_path}")

    
    if use_w2v_feat:
        ark_scp_spec = f"ark:| copy-feats --compress=true ark:- ark,scp:{out_data.ark_path},{out_data.scp_path}"
        with kaldi_io.open_or_fd(ark_scp_spec, "wb") as f:
            for utt in ref_data.utts:
                feat = w2v_feat.get_feat(utt)
                kaldi_io.write_mat(f, feat, key=utt)
            print(f"...wrote features to {ark_scp_spec}")
    else:
        src = ref_data.scp_path
        dst = out_data.scp_path
        shutil.copy(src, dst)
        print(f"...copied {src} to {dst}")

if __name__ == "__main__":
    """
    1. supervised training: set ref_root the kaldi directory
    python local_gan/copy_w2v_data_to_kaldi.py \
        --w2v_dir /checkpoint/abaevski/asr/unsup/data/ctc_filtered/precompute_unfiltered_pca128 \
        --out_root /private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data_gan_sup \
        --ref_root /private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data \
        --use_w2v_feat

    2. unsupervised iterative training: set ref_root to the out_root of step 1
    python local_gan/copy_w2v_data_to_kaldi.py \
        --w2v_dir <w2v_dir_with_tsv_and_new_lab> \
        --out_root /private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data_gan_unsup_it1 \
        --ref_root /private/home/wnhsu/libs/kaldi/egs/librispeech/s5_gan/data_gan_sup \
        --lab_name <new_lab_suffix>
    """
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--w2v_dir", required=True)
    parser.add_argument("--w2v_split", required=True)
    parser.add_argument("--out_root", required=True)
    parser.add_argument("--out_split", required=True)
    parser.add_argument("--ref_root", required=True)
    parser.add_argument("--lab_name", default="phnc")
    parser.add_argument("--pred_lab_path", default=None)
    parser.add_argument("--use_w2v_feat", action="store_true", help="If false, copy feat.scp from ref_root")
    parser.add_argument("--use_pred_lab", action="store_true", help="If true, use pred_lab as text")
    parser.add_argument("--rm_sil", action="store_true", help="If true, remove SIL from w2v transcript")
    args = parser.parse_args()
    print(args)

    ref_dir = f"{args.ref_root}/{args.out_split}"
    out_dir = f"{args.out_root}/{args.out_split}"
    main(
        ref_dir,
        args.w2v_dir,
        args.w2v_split,
        out_dir,
        args.lab_name,
        args.pred_lab_path,
        args.use_w2v_feat,
        args.use_pred_lab,
        args.rm_sil
    )
