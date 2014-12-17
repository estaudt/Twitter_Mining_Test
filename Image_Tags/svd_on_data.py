import numpy as np
import scipy.io as sio
import os
import glob
import scipy.linalg as linalg

# params
objectsDir = '/Users/elliotstaudt/Documents/MIRFLICKR-25000/objects/'

list_of_BOW = []
# creat an list that will hold all the numbers
for num in range(10000):
  local_BOW_files = glob.glob(objectsDir+str(num).zfill(5)+'/BoW200_*.mat')
  if len(local_BOW_files) > 0:
    for path_ in local_BOW_files:
      bow = sio.loadmat(path_)
      list_of_BOW.append(np.array(bow['BOW']))
      
# create a numpy array to hold all the BOW values  
num_objects = len(list_of_BOW)    
array_of_BOW = np.zeros([200,num_objects])

# fill the numpy array
count = 0
for BOW in list_of_BOW:
  for count2 in range(len(BOW)):
    array_of_BOW[count2,count] = BOW[count2]
  count+=1

# clean up
list_of_BOW = None
  
# perform the SVD analysis
SVD_a = linalg.svd( array_of_BOW, compute_uv=False, overwrite_a=True, check_finite=False )
sio.savemat('/Users/elliotstaudt/Documents/MIRFLICKR-25000/Clusters/200_svd.mat', SVD_a)

