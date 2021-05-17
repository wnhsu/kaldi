import csv
import kaldi_io
import numpy as np
import os
import os.path as op
import subprocess


def get_parser():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("root", help="audio root")
    parser.add_argument("tsv_path", help="s2t data directory")
    parser.add_argument("tar_root", help="output data directory in kaldi's format")
    parser.add_argument("split", help="name of the subset")
    parser.add_argument("--label", default="", help="if specified, copy labels too")
    return parser

def load_s2t_manifest(tsv, root):
    with open(tsv) as f:
        reader = csv.DictReader(
            f,
            delimiter="\t",
            quotechar=None,
            doublequote=False,
            lineterminator="\n",
            quoting=csv.QUOTE_NONE,
        )
        data = [dict(d) for d in reader]
    for i in range(len(data)):
        data[i]["audio"] = op.join(root, data[i]["audio"])
    return data


def main():
    parser = get_parser()
    args = parser.parse_args()

    data = load_s2t_manifest(args.tsv_path, args.root)
    tar_dir = op.join(args.tar_root, args.split)
    os.makedirs(tar_dir, exist_ok=True)

    with open(op.join(tar_dir, "text"), "w") as f:
        for i, d in enumerate(data):
            f.write(f"{d['speaker']}_{d['id']} {d['src_text']}\n")

    with open(op.join(tar_dir, "wav.scp"), "w") as f:
        for i, d in enumerate(data):
            f.write(f"{d['speaker']}_{d['id']} python local/pipe_s2t_wav.py {d['audio']} |\n")

    with open(op.join(tar_dir, "utt2spk"), "w") as f:
        for i, d in enumerate(data):
            f.write(f"{d['speaker']}_{d['id']} {d['speaker']}\n")

    with open(op.join(tar_dir, "spk2utt"), "w") as f:
        subprocess.run([
            "utt2spk_to_spk2utt.pl",
            op.join(tar_dir, "utt2spk"),
        ], stdout=f)


if __name__ == "__main__":
    main()
