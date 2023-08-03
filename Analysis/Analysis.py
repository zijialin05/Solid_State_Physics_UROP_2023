# -*- coding: utf-8 -*-
"""
Created on Thu Jul 27 19:11:53 2023

@author: LZJ
"""

from scipy.io import loadmat
import matplotlib.pyplot as plt
# from scipy.interpolate import CubicSpline
import numpy as np

# Load the .mat file
mat_contents_freq = loadmat('freq.mat')

# Access the saved array
freq = mat_contents_freq['frequency']

# Load the .mat file
mat_contents_P = loadmat('P.mat')

# Access the saved array
P = mat_contents_P['P']

fig = plt.figure("Shape")
plt.plot(freq, P)
plt.xlabel("Frequency (GHz)")
plt.ylabel("Power (au)")
plt.grid()
plt.savefig("20mT_P_vs_Freq", dpi=600)
plt.show()

freq_list = np.array([9.36563, 8.52647, 7.26773, 6.21878, 5.13986, 3.73127])
freq_diff = freq_list[1:]-freq_list[:-1]
avg = np.mean(freq_diff)
std = np.std(freq_diff)
