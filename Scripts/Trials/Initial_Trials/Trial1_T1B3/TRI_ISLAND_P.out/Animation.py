# -*- coding: utf-8 -*-
"""
Created on Fri Jul 14 20:04:00 2023

@author: LZJ
"""

import imageio as io
from skimage.transform import resize

prefix = 'T_D'
suffix = '0oe.jpg'
num_of_imgs = 61
folder = 'Animation/'

file_names = []

for i in range(num_of_imgs):

    if i < 10:
        body = '00'+f'{i}'
    else:
        body = '0'+f'{i}'
    body = '_'+body+'_p'+body

    fname = prefix+body+suffix
    file_names.append(fname)


# %%

images = []

for filename in file_names:
    image = io.imread(filename)
    images.append(resize(image, (320, 1100)))

io.mimsave(folder+prefix+'.gif', images, duration=0.1)
