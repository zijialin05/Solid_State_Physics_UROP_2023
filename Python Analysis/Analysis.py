import numpy as np
import os
import glob
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from scipy.fft import fft

pre = input('Type the title: ')
os.makedirs(pre, exist_ok=True)

region = [32,44]
regionname = ['T','B']

map = 'hot'
fonty = 14
fmin = 0
fmax = 14
fres = 1
Xmin = 0
Xmax = 60
Xres = 10
cmin = 0
cmax = 1
c_log = 1

plot_ALLFIELDS = 1
log_col_plot = 1

plot_SELECTFIELDS = 0

file_list = glob.glob('table*.txt')
tabledata = []

for file in file_list:
    data = pd.read_csv(file, sep="\s+", header=None)
    tabledata.append(data)

tabledata = pd.concat(tabledata)
tabledata = tabledata.sort_values(by=[15])

H = tabledata.iloc[:,15]/10
H_u = H.unique()
H_l = len(H_u)

t = tabledata.iloc[:,0]
t_u = np.array_split(t, H_l)[0]
t_l = len(t_u)

dt = np.mean(np.diff(t_u)) * 1e9
Fs = 1 / dt
N = t_l
dF = Fs / N
f = np.arange(-Fs/2 + dF, Fs/2 + dF, dF)

Nx = tabledata.iloc[0,4]
Ny = tabledata.iloc[0,5]
Nz = tabledata.iloc[0,6]

cx = tabledata.iloc[0,7]
cy = tabledata.iloc[0,8]
cz = tabledata.iloc[0,9]

LX = (np.arange(cx, cx*Nx + cx, cx)) * 1e9
LY = (np.arange(cy, cy*Ny + cy, cy)) * 1e9
LZ = (np.arange(cz, cz*Nz + cz, cz)) * 1e9

R_l = len(region)

MDYN = []
for i in range(R_l):
    j = region[i]
    temp = tabledata.iloc[:,(j-1):(j+1)]
    MDYN.append(temp.values.reshape(-1, t_l, 3))

MDYN = np.transpose(np.array(MDYN), (1, 2, 0, 3))

Power = []
for i in range(3):
    M = MDYN[:,:,:,i]
    M_fft = fft(M, t_l, 1)
    P_comp = np.abs(M_fft)
    Power.append(P_comp)

Power = np.flip(Power, 1)
Power = Power[:, :int(t_l/2)+1, :, :]
PowerT = np.sqrt(np.sum(np.power(Power, 2), axis=0))
frequency = f[int(len(f)/2):]

# The code below will require some adjustments based on how you would like to plot the graphs.
# Due to the interactive nature of plotting and saving figures in Python, the code below may not work exactly as expected.
# In general, to plot figures in Python, you can use plt.figure(), plt.plot(), plt.savefig(), etc.

for r in range(len(region)):
    P = PowerT[:,:,r].T
    Pmax = np.max(P)
    Pnorm = P / Pmax

    plt.figure()
    plt.imshow(Pnorm, extent=(H_u[0], H_u[-1], frequency[0], frequency[-1]), origin='lower', aspect='auto', cmap=map)
    if c_log == 1:
        plt.yscale('log')
    plt.ylim([fmin, fmax])
    plt.xlim([Xmin, Xmax])
    plt.colorbar()
    plt.title(regionname[r])
    plt.xlabel('µ0H (mT)')
    plt.ylabel('frequency (GHz)')
    plt.savefig(pre + '/' + pre + ' ' + regionname[r] + ' HEATMAP.png')

    Lmap = cm.get_cmap('jet', H_l)

    fig, ax = plt.subplots(figsize=(10, 15))
    for i in range(H_l):
        if log_col_plot == 1:
            P = np.log(Pnorm[:,i]) + i
        else:
            P = Pnorm[:,i] + i
        ax.plot(frequency, P, color=Lmap(i), linewidth=2)
    ax.set_xlabel('frequency (GHz)')
    ax.set_ylabel('Power (au)')
    ax.set_xlim([fmin, fmax])
    ax.set_title(regionname[r])
    ax.figure.savefig(pre + '/' + pre + ' ' + regionname[r] + ' ALLFIELDS.png')

    if plot_SELECTFIELDS == 1:
        H_user = [float(n) for n in input('Fields to plot [H1,H2,H3,...,Hn]: ').split(",")]
        Lmap = cm.get_cmap('jet', len(H_user))
        closestIndex = [np.argmin(np.abs(h - H_u)) for h in H_user]

        plt.figure(figsize=(15, 10))
        for i in range(len(H_user)):
            P = Pnorm[:,closestIndex[i]]
            plt.plot(frequency, P, color=Lmap(i), linewidth=2)
        plt.title(regionname[r])
        plt.xlabel('frequency (GHz)')
        plt.ylabel('Power (au)')
        plt.legend([f'{h} mT' for h in H_user], loc='upper right')
        plt.xlim([fmin, fmax])
        plt.savefig(pre + '/' + pre + ' ' + regionname[r] + ' SELECTFIELDS.png')