"""
Take a raw input tweet file and output a tokenized
and tagged tweet file
"""


import os
import sys
import re

from argparse import ArgumentParser

import NLPlib

__author__ = 'Tal Friedman (talf301@gmail.com)'

"""
Overall pipeline, preprocesses tokenizes and 
tags a single tweet and returns a list of lines
to be printed.
"""
def parse(line, abbrevs, tagger):
    # Preprocess
    line = remove_html(line)
    line = to_ascii(line)
    # Tokenize
    tokens = line.strip().split()
    tokens = remove_hash_url(tokens)
    sens = to_sentences(tokens, abbrevs)
    print sens
    sens = sep_punc(sens)
    sens = split_clitic(sens)
    lines = []
    for sen in sens:
        tags = tagger.tag(sen)
        new_line = ' '.join(['/'.join([w,t]) for w,t in zip(sen, tags)])
        lines.append(new_line)
    return lines

def split_clitic(sens):
    """
    Simple heuristic for splitting up apostrophes:
    -If last character, split it on its own
    -If its second last and last is 's', take those 2
    -If its the first character, leave it in the word
    -If its third last and ending is "'ll", take that
    -Otherwise take 1 character before to end
    """
    new_sens = []
    curr_sen = []
    for sen in sens:
        for token in sen:
            if token.find("'") > -1:
                ind = token.find("'")
                if ind == 0:
                    curr_sen.append(token)
                elif ind == len(token) - 1:
                    curr_sen.append(token[:-1])
                    curr_sen.append("'")
                elif ind == len(token) - 2 and token.lower()[-1] == 's':
                    curr_sen.append(token[:-2])
                    curr_sen.append(token[-2:])
                elif ind == len(token) - 3 and token.lower()[-2:] == 'll':
                    curr_sen.append(token[:-3])
                    curr_sen.append(token[-3:])
                else:
                    curr_sen.append(token[:ind-1])
                    curr_sen.append(token[ind-1:])
            else:
                curr_sen.append(token)
        new_sens.append(curr_sen)
        curr_sen = []
    return new_sens

def sep_punc(sens):
    """
    Separates non-quotation punctuation out into
    separate tokens, and splits up clitics.
    """
    new_sens = []
    curr_sen = []
    for sen in sens:
        for token in sen:
            if token.endswith(':') or token.endswith(';') or token.endswith(','):
                curr_sen.append(token[:-1])
                curr_sen.append(token[-1])
            else:
                curr_sen.append(token)
        new_sens.append(curr_sen)
        curr_sen = []
    return new_sens

def remove_html(line):
    """
    Remove all html tags (i.e. anyting between < and >)
    """
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

def to_sentences(tokens, abbrevs):
    """
    Take a list of tokens, return a list of lists representing
    the sentences in the tweet. The heuristic I use is roughly
    what is found in Manning and Shutze 4.2.4, with some simplifications
    (I don't consider different kinds of abbreviations, and I don't
    use names in addition to lowercase for determining boundaries).
    This function also separates out quotation marks.
    """
    new_tokens = []
    curr_sen = []
    for i,token in enumerate(tokens):
        # Deal with quotation marks
        ends_quote = False
        is_bound = False
        if token.startswith('"'):
            token = token[1:]
            curr_sen.append('"')
        if token.endswith('"'):
            ends_quote = True
            token = token[:-1]
        # First handle ellipsis: we consider it EOS if following letter is uppercase
        if token.find('..') > -1:
            ind = token.find('..')
            if token[:ind]:
                curr_sen.append(token[:ind])
            curr_sen.append(token[ind:])
            # EOS case
            if i+1 < len(tokens) and tokens[i+1][0].isupper():
                is_bound = True   
        # Periods considered EOS unless abbreviation followed by lowercase
        elif token.find('.') > -1:
            ind = token.find('.')
            if token[:ind]:
                curr_sen.append(token[:ind])
            curr_sen.append(token[ind:])
            # If it's not an abbreviation and followed by lowercase, split
            if not (token[:ind+1] in abbrevs
                    and i+1 < len(tokens) and not tokens[i+1][0].isupper()):
                is_bound = True
        # ?, ! considered EOS unless it is followed by a lowercase
        elif token.find('?') > -1 or token.find('!') > -1:
            if not token.find('?') > -1:
                ind = token.find('!')
            elif not token.find('!') > -1:
                ind = token.find('?')
            else:
                ind = min(token.find('!'), token.find('?'))
            if token[:ind]:
                curr_sen.append(token[:ind])
            curr_sen.append(token[ind:])
            if i+1 < len(tokens) and tokens[i+1][0].isupper():
                is_bound = True
        else:
            curr_sen.append(token)
        if ends_quote:
            curr_sen.append('"')
        if is_bound:
            new_tokens.append(curr_sen)
            curr_sen = []
    # If the current sentence is not empty, dump it
    if curr_sen:
        new_tokens.append(curr_sen)

    return new_tokens

def remove_hash_url(tokens):
    """
    Remove all tokens that look like a url, remove hashtags
    and @ from the beginning of tokens
    """
    new_tokens = []
    for token in tokens:
        # Look for website match
        if re.match(r'(www|http|Http).*', token) or re.match(r'.*\.(com|net|org|edu|ca)/.*', token) \
                or re.match(r'youtu\.be/.*', token):
            continue
        if (token.startswith('#') or token.startswith('@')) and len(token) > 1:
            new_tokens.append(token[1:])
        else:
            new_tokens.append(token)
    return new_tokens

def to_ascii(line):
    """
    Replace &,<,>," with ascii equivalent
    """
    line = line.replace('&amp;gt;', '>')
    line = line.replace('&amp;lt;', '<')
    line = line.replace('&amp;', '&')
    line = line.replace('quot;', '"')
    return line

def script(input, output):
    abr_file = open('abbrev.english')
    abbrevs = list(abr_file)
    tagger = NLPlib.NLPlib()
    outfile = open(output, 'w')
    with open(input, 'rU') as file:
        for line in file:
            out_lines = parse(line, abbrevs, tagger)
            for l in out_lines:
                outfile.write(l+'\n')
            outfile.write('|\n')
    outfile.close()

def parse_args(args):
    parser = ArgumentParser(description=__doc__.strip())
    
    parser.add_argument('input', help='Raw tweet input file')
    parser.add_argument('output', help='Output tokenized & tagged file')
    return parser.parse_args(args)

def main(args=sys.argv[1:]):
    args = parse_args(args)
    script(**vars(args))

if __name__ == '__main__':
    sys.exit(main())
