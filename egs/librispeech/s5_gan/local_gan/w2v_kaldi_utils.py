import os
import numpy as np

class KaldiData:
    fixed_names = ["spk2gender", "spk2utt", "utt2spk", "wav.scp", "cmvn.scp"]

    def __init__(self, datadir):
        self.datadir = datadir
        self._utts = None

    def get_path(self, filename):
        return os.path.join(self.datadir, filename)

    @property
    def text_path(self):
        return os.path.join(self.datadir, "text")

    @property
    def scp_path(self):
        return os.path.join(self.datadir, "feats.scp")

    @property
    def ark_path(self):
        return os.path.join(self.datadir, "feats.ark")

    @property
    def utts(self):
        if self._utts is None:
            with open(self.text_path, "r") as f:
                self._utts = [line.rstrip().split()[0] for line in f]
        return self._utts


class W2VFeat:
    def __init__(self, datadir, split, lab_name="phnc", mmap_mode="r", pred_lab_path=None):
        self.datadir = datadir
        self.split = split
        self.lab_name = lab_name
        self.mmap_mode = mmap_mode
        self.utt2idx = self.load_utt2idx()
        self.pred_lab_path = pred_lab_path

        self._labs = None
        self._lengths = None
        self._offsets = None
        self._feats = None
        self._pred_labs = None

    def load_utt2idx(self):
        def path_to_utt(path):
            return os.path.splitext(os.path.basename(path))[0]

        with open(os.path.join(self.datadir, self.split + ".tsv"), "r") as f:
            f.readline() # root
            utt2idx = {}
            for idx, line in enumerate(f):
                path = line.split()[0]
                utt2idx[path_to_utt(path)] = idx
        return utt2idx

    @property
    def lengths(self):
        if self._lengths is None:
            with open(os.path.join(self.datadir, self.split + ".lengths"), "r") as f:
                self._lengths = [int(line.rstrip()) for line in f]
            assert(len(self._lengths) == len(self.utt2idx))
        return self._lengths

    @property
    def offsets(self):
        if self._offsets is None:
            self._offsets = [0] + list(np.cumsum(self.lengths)[:-1])
        return self._offsets

    @property
    def feats(self):
        if self._feats is None:
            self._feats = np.load(
                os.path.join(self.datadir, self.split + ".npy"),
                mmap_mode=self.mmap_mode
            )
            assert(self._feats.shape[0] == sum(self.lengths))
        return self._feats

    @property
    def labs(self):
        if self._labs is None:
            lab_path = os.path.join(self.datadir, f"{self.split}.{self.lab_name}")
            with open(lab_path, "r") as f:
                self._labs = [line.rstrip() for line in f]
            assert(len(self._labs) == len(self.utt2idx))
        return self._labs

    @property
    def pred_labs(self):
        # NOTE: assume pred_labs aligns with tsv's order and follows sclite
        # format ("<text> (<spk>-<uid>)")
        if self._pred_labs is None:
            assert(self.pred_lab_path is not None)
            with open(self.pred_lab_path, "r") as f:
                self._pred_labs = [
                    " ".join(line.rstrip().split()[:-1]) for line in f
                ]
            assert(len(self._pred_labs) == len(self.utt2idx))
        return self._pred_labs

    def get_feat(self, utt):
        idx = self.utt2idx[utt]
        length, offset = self.lengths[idx], self.offsets[idx]
        return self.feats[offset:offset+length]

    def get_lab(self, utt):
        idx = self.utt2idx[utt]
        return self.labs[idx]

    def get_pred_lab(self, utt):
        idx = self.utt2idx[utt]
        return self.pred_labs[idx]

