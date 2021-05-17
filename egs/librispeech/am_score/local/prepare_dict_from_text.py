import argparse
import fileinput

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('files', nargs="*")
    args = parser.parse_args()

    words = set()
    for line in fileinput.input(files=args.files):
        words = words.union(line.rstrip().split())
    for word in sorted(words):
        print(f"{word} 1")
