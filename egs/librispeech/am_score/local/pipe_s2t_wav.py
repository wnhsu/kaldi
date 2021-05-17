import io
import sys
from pathlib import Path
from typing import BinaryIO, Optional, Tuple, Union

import numpy as np
import soundfile as sf


SF_AUDIO_FILE_EXTENSIONS = {".wav", ".flac", ".ogg"}


def get_waveform(
        path_or_fp: Union[str, BinaryIO], normalization=True, mono=True,
        frames=-1, start=0, always_2d=True
) -> Tuple[np.ndarray, int]:
    """Get the waveform and sample rate of a 16-bit WAV/FLAC/OGG Vorbis audio.

    Args:
        path_or_fp (str or BinaryIO): the path or file-like object
        normalization (bool): Normalize values to [-1, 1] (Default: True)
        mono (bool): convert multi-channel audio to mono-channel one
        frames (int): the number of frames to read. (-1 for reading all)
        start (int): Where to start reading. A negative value counts from the end.
        always_2d (bool): always return 2D array even for mono-channel audios
    Returns:
        waveform (numpy.ndarray): 1D or 2D waveform (channels x length)
        sample_rate (float): sample rate
    """
    if isinstance(path_or_fp, str):
        ext = Path(path_or_fp).suffix
        if ext not in SF_AUDIO_FILE_EXTENSIONS:
            raise ValueError(f"Unsupported audio format: {ext}")

    try:
        import soundfile as sf
    except ImportError:
        raise ImportError(
            "Please install soundfile to load WAV/FLAC/OGG Vorbis audios"
        )

    waveform, sample_rate = sf.read(
        path_or_fp, dtype="float32", always_2d=True, frames=frames, start=start
    )
    waveform = waveform.T  # T x C -> C x T
    if mono and waveform.shape[0] > 1:
        waveform = waveform[:1]
    if not normalization:
        waveform *= 2 ** 15  # denormalized to 16-bit signed integers
    if not always_2d:
        waveform = waveform.squeeze(axis=0)
    return waveform, sample_rate


def read_from_uncompressed_zip(file_path, offset, file_size) -> bytes:
    with open(file_path, "rb") as f:
        f.seek(offset)
        data = f.read(file_size)
    return data


def read_audio(path, tgt_sr=16000):
    path, *extra = path.split(":")
    assert len(extra) == 2
    assert path.endswith(".zip")

    data = read_from_uncompressed_zip(path, int(extra[0]), int(extra[1]))
    f = io.BytesIO(data)
    wav, sr = get_waveform(f, mono=True, always_2d=False)
    assert sr == tgt_sr, f"{sr} != {tgt_sr}"
    assert wav.ndim == 1, wav.ndim

    f = io.BytesIO()
    sf.write(f, wav, tgt_sr, format="WAV")
    sys.stdout.buffer.write(f.getvalue())


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("path", help="file:offset:size")
    parser.add_argument("--tgt_sr", type=int, default=16000)
    args = parser.parse_args()
    read_audio(**vars(args))
