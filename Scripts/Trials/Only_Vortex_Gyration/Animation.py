# -*- coding: utf-8 -*-
"""
Created on Fri Jul 14 20:04:00 2023

@author: LZJ
"""

import imageio as io
from skimage.transform import resize

fig_folder_name = 'TRI_ISLAND_P.out/'
prefix_l = ['B_D', 'B_M', 'T_D', 'T_M']

for prefix in prefix_l:
    body = '_020_n0200oe_'
    num_of_imgs = 201
    folder = 'Animation/'

    file_names = []

    for i in range(num_of_imgs):

        if i == 0:
            suffix = '00ps.jpg'
        else:
            suffix = f'{i*10}ps.jpg'

        fname = fig_folder_name+prefix+body+suffix
        file_names.append(fname)

    images = []

    for filename in file_names:
        image = io.imread(filename)
        images.append(resize(image, (320, 1100)))

    io.mimsave(folder+prefix+'.gif', images, duration=0.05)
