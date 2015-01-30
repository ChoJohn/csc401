"""
Take a raw input tweet file and output a tokenized
and tagged tweet file
"""


import os
import sys

from argparse import ArgumentParser

import NLPlib

__author__ = 'Tal Friedman (talf301@gmail.com)'

"""
Overall pipeline, preprocesses tokenizes and 
tags a single line and returns a list of lines
to be printed.
"""
def parse(line):
    # Preprocess
    line = remove_html(line)

"""
Remove all html tags (i.e. anyting between < and >)
"""
def remove_html(line):
    last = len(line)
    while True:
        # Scan for open brace from left
        a = line.rfind('<',0,last)
        # Try to find corresponding close brace
        b = line.find('>',a)
        # If we don't find tags, adjust accordingly
        if a < 0:
            return line
        if b < 0:
            last -= 1
            continue
        # Otherwise cut the part in the middle
        line = line[:a] + line[b+1:]

def script(input, output):
    with open(input) as file:
        for line in file:
            out_line = parse(line)

def parse_args(args):
    parser = ArgumentParser(description=__doc__.strip())
    
    parser.add_argument('INPUT', help='Raw tweet input file')
    parser.add_argument('OUTPUT', help='Output tokenized & tagged file')
    return parser.parse_args(args)

def main(args=sys.argv[1:]):
    args = parse_args(args)
    script(**vars(args))

if __name__ == '__main__':
    sys.exit(main())
