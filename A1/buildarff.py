"""
Take tagged and tokenized tweets and build
arff file from them containing 20 required features.
"""

import os
import sys

__author__ = 'Tal Friedman (talf301@gmail.com)'

def count_token_tag(tweet, wordlist, taglist):
    """
    Generic method for computing features 
    which involve a count of the number of 
    tokens/tag pairs both in correspondoning lists.
    """
    count = 0
    for line in tweet:
        for token, tag in line:
            if token in wordlist and tag in taglist:
                count += 1
    return count

def count_token(tweet, wordlist):
    """
    Generic method for computing features
    which inolve a count of the number of tokens
    (not tags) in some list.
    Assumption is that tweets come as a list (entire tweet)
    of lists (sentences) of pairs (token,tag)
    """
    count = 0
    for line in tweet:
        for token, _ in line:
            if token in wordlist:
                count += 1
    return count

def count_tag(tweet, worldlist):
    """
    Generic method for computing features
    which inolve a count of the number of tags
    in some list.
    Assumption is that tweets come as a list (entire tweet)
    of lists (sentences) of pairs (token,tag)
    """
    count = 0
    for line in tweet:
        for _ , tag in line:
            if tag in wordlist:
                count += 1
    return count

def av_sen_len(tweet):
    """
    Returns the average length of the sentneces in tokens.
    """
    return sum(len(l) for l in tweet) / float(len(tweet))

def av_token_len(tweet):
    """
    Returns the average length of tokens excluding punctuation
    """
    total_sum = 0
    total_count = 0
    punc = ['#', '$', '.', ',', ':', '(', ')', '"', "'"]
    for line in tweet:
        for token, tag in line:
            if tag not in punc:
                total_sum += len(token)
                total_count += 1

def num_sen(tweet):
    """
    Returns the number of sentences in the given tweet.
    """
    return len(tweet)

def build_line(tweet, class_label):
    """
    Takes a tweet in our processed format along with a 
    class label and whatever wordlists we need, and returns
    the line to be written to arff file.
    """

    
def main(args=sys.argv[1:]):
    # Get if we need to use the first X tweets
    num_tweets = 0
    if args[0].startswith('-'):
        num_tweets = int(args[0][1:])
        args = args[1:]
    classes = []

    # Load in required wordlists

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

    # Create output file and write all the headers
    out_filename = args[-1]
    out_file = open(out_filename, 'w')
    out_file.write('@relation %s\n\n' % out_filename.split('.')[0])
    # To add another numeric feature to header, just add to this list
    numer_features = ['fpp_count', 'spp_count', 'tpp_count', 'cc_count', 'ptv_count',
            'ftv_count', 'comma_count', '(semi)colon_count', 'dash_count', 'paren_count',
            'ellipse_count', 'cn_count', 'pn_count', 'adv_count', 'wh_count', 'slang_count',
            'allcaps_count', 'sen_len', 'token_len', 'num_sen']
    for feature in numer_features:
        out_file.write('@attribute %s numeric\n' % feature)
    out_file.write('@attribute class {%s}\n\n' % ', '.join([l[0] for l in classes]))
    out_file.write('@data\n')
    
    # Create actual data lines
    for c in classes:
        for filename in c[1:]:
            file = open(filename, 'rU')
            curr_tweet = []
            for line in file:
                if line.startswith('|'):
                    build_line(curr_tweet, c[0])
                    curr_tweet = []
                else:
                    pairs = line.strip().split()
                    curr_tweet.append([p.split('/') for p in pairs])


if __name__ == '__main__':
    sys.exit(main())
