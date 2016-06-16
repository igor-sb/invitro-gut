# -*- coding: utf-8 -*-
"""

Plot the time course of cell density profiles for two strains


Created on Mon Aug 31 16:00:43 2015

@author: Igor
"""

import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd
import matplotlib.cm as cm
from matplotlib.backends.backend_pdf import PdfPages

# plot configuration
mpl.rcParams['font.family'] = 'sans-serif'
mpl.rcParams['font.sans-serif'] = 'Arial'


# Load & import processed data from R
d = pd.read_csv('cellCountsPlotForPython.txt', delimiter='\t')

# add OD counts based on the fact that we had starting OD = 0.01
d['OD'] = 0
StartODGFP = np.mean(d.loc[(d.group == 'GFP') & (d.tHours == 0.0), 'counts'])
StartODmCh = np.mean(d.loc[(d.group == 'mCh') & (d.tHours == 0.0), 'counts'])
d.loc[d.group == 'GFP', 'OD'] = d.loc[d.group == 'GFP', 'counts']*0.01/StartODGFP
d.loc[d.group == 'mCh', 'OD'] = d.loc[d.group == 'mCh', 'counts']*0.01/StartODmCh


# Change colors to pretty rainbow
colors = cm.rainbow(np.linspace(0, 1, len(pd.unique(d.tHours.ravel()))))
#colors = cm.jet(np.linspace(0, 0.54, len(pd.unique(d.tHours.ravel()))))

# Initialize plot
plotsArray1 = []
plotsArray2 = []
fig = plt.figure(figsize=(2.5,6))


for groupName, group in d.groupby('group'):

    if groupName == 'mCh':
        ax = fig.add_subplot(211)
    elif groupName == 'GFP':
        ax = fig.add_subplot(212)
    else:
        continue

    j = 0
    for key, grp in group.groupby('tHours'):
        # for each time point

        #plotObject, = plt.plot(grp['xCm'], grp['counts'], label=key, color=colors[j], linewidth=5.0)
        plotObject, = ax.plot(grp['xCm'], grp['OD'], label=key, color=colors[j], linewidth=5.0)
        if groupName == "mCh":
            plotsArray1.append(plotObject)
            ax.set_ylabel('OD600, $\Delta$galK mCherry')
        elif groupName == 'GFP':
            plotsArray2.append(plotObject)
            ax.set_ylabel('OD600, $\Delta$lacIYZ GFP')
        else:
            print 'Group name is neither GFP or mCh. Unsupported feature.'

        ax.set_xlabel('position along the channel (cm)')
        j = j + 1
        lgd = ax.legend(plotsArray1[0::3], np.around(pd.unique(d.tHours.ravel())[0::3], decimals=1),
                        bbox_to_anchor=(1.6, 0.5), title="Time (hours)")
fig.savefig('profile_both2.pdf', format='pdf', bbox_extra_artists=(lgd,), bbox_inches='tight')



