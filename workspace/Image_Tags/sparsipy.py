import numpy as np
import os
from nltk.corpus import wordnet as wn
from nltk import word_tokenize
from nltk import pos_tag


def sparsify(a, lambda_, dist_type):
  cols = []
  vals = np.array(a)
  cover = vals*0
  sort_index = np.argsort(vals)
  min_dist = np.linalg.norm(vals)
  min_ind = len(a)
  
  for count in range(len(a)):
    cover[sort_index[-1-count]]=vals[sort_index[-1-count]]
    vals[sort_index[-1-count]] = 0
    temp_dist = np.linalg.norm(vals) + lambda_*np.linalg.norm(cover, dist_type)
    if temp_dist <= min_dist:
      min_dist = temp_dist
      min_ind = count+1
  
  for count in range(min_ind):
    cols.append(sort_index[-1-count])

  return np.array(cols)


def convertToSynonyms(fname):
  with open(fname) as f:
    content = [x.strip('\n') for x in f.readlines()]
    content = [x.strip('\r') for x in content]
  
  # define file in which to store synonyms
  [root,ext]=os.path.splitext(fname)
  fsavename = root + '_synonyms' + ext
  
  # open file for writing
  sf = open(fsavename, 'w')
  
  local_count = 0
  for word in content:
    # check to see the word is ascii encoded
    try:
      word = word.decode('ascii')
    except UnicodeDecodeError:
      continue
    # word is ascii encoded so attempt to find the synonym
    syn = wn.morphy(word)
    if syn != None:
      # a synonym was found, so confirm it was a basic noun
      text = word_tokenize(word)
      token = pos_tag(text)
      if token[1] != 'NN':
        continue
      # it was a proper noun so write it to the file
      local_count+=1
      if local_count > 1:
        sf.write('\n')
      sf.write(syn)

  # close the file for writing
  sf.close()
  
  
  