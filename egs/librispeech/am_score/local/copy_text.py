import argparse

def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("ref_tsv")
    parser.add_argument("tsv")
    parser.add_argument("lab")
    parser.add_argument("new_lab")
    parser.add_argument("--last_n", type=int, default=-1, help="compare last n subdirs; -1 for all")
    return parser

def load_uids(tsv, last_n):
    with open(tsv, "r") as f:
        f.readline()
        uids = []
        for line in f:
            uid = line.rstrip().split("\t")[0]
            if last_n != -1:
                uid = "/".join(uid.split("/")[-last_n:])
            uids.append(uid)
    return uids

def main():
    args = get_parser().parse_args()
    uids = load_uids(args.tsv, args.last_n)
    with open(args.lab, "r") as f:
        labs = [line for line in f]
    assert len(uids) == len(labs), f"{len(uids)} != {len(labs)}"
    uid_to_lab = dict(zip(uids, labs))
    
    ref_uids = load_uids(args.ref_tsv, args.last_n)
    with open(args.new_lab, "w") as f:
        for uid in ref_uids:
            f.write(uid_to_lab[uid])
    print(f"finished writing new labels to {args.new_lab}")

if __name__ == "__main__":
    main()
