"""
Take tagged and tokenized tweets and build
arff file from them containing 20 required features.
"""

import os
import sys

__author__ = 'Tal Friedman (talf301@gmail.com)'

def main(args=sys.argv[1:]):
    # Get if we need to use the first X tweets
    num_tweets = 0
    if args[0].startswith('-'):
        num_tweets = int(args[0][1:])
        args = args[1:]
    classes = []
    # Compile a list of lists for classes, first entry is name,
    # the rest are file names to draw from
    for raw_class in args[:-1]:
        split_class = raw_class.split(':')
        if len(split_class) == 1:
            files = raw_class.split('+')
            class_name = ''
            for file in files:
                class_name += file.split('.')[0]
            classes.append([class_name] + files)
        else:
            classes.append([split_class[0]] + split_class[1].split('+'))

    print classes
if __name__ == '__main__':
    sys.exit(main())
