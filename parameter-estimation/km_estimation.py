# -*- coding: utf-8 -*-
"""

Estimate Monod's constant for E.coli lactose growth based on experimental
growth curves.


Input:

Load data from experimentally measured growth curves in the tab-delim format,
with these column names from input_filename:

TimeHours | OD | LactomsemM
...       | .. | ..


Model:

N = cell density: y[0]
c = nutrient concentration: y[1]
LambdaMax = maximum growth rate
Y = yield factor; affects maximum cell density obtainable

Equations that are solved are:
 dN/dt = LambdaMax*N*c/(c+Km)
 dc/dt = -(LambdaMax/Y)*N*c/(c+Km)

Initial conditions:
 N(t=0) = 0.01 (CellsInitialOD)
 c(t=0) = loaded from file (NutrientInitialmM)


Output:

PDF file with the plot, output_filename.


Created on Wed Sep 30 17:18:42 2015

@author: Igor
"""

import numpy as np
import matplotlib.cm as cm
import matplotlib.pyplot as plt
import pandas as pd
from scipy.integrate import odeint
from matplotlib.backends.backend_pdf import PdfPages

# Filenames
input_filename = 'growth_curves_data.txt'
output_filename = 'growth_curve_fits_Km_0.1_mM.pdf'

# First fix LambdaMax = 0.61 hr^-1, (0.59 hr^-1 for best fit)
LambdaMax = 0.59

# Yield = 0.19 OD/mM (0.185 for best fit)
Yield = 0.19

# Km in mM
Km = 0.10

# Simulation time points
TimeRange = np.arange(0, 10.01, 0.1)

# Initial conditions
CellsInitialOD = 0.01
# NutrientInitialmM is loaded from the file

# Load experimental data
ExperimentalData = pd.read_csv(input_filename, delimiter='\t')
ExpDataList = {}

# Convert data frame to dictionary
for Lactose in set(ExperimentalData['LactosemM']):
    ExpDataList[Lactose] = ExperimentalData.loc[ExperimentalData.LactosemM == Lactose, ['TimeHours', 'OD']].as_matrix()

# Define derivatives
def Deriv(y, t): # return derivative of the array y
    return np.array([ LambdaMax*y[1]*y[0]/(y[1] + Km), -(1/Yield)*LambdaMax*y[1]*y[0]/(y[1] + Km)])


# Initialize plot
Colors = cm.jet(np.linspace(0, 1, len(ExpDataList.keys())))
fig = plt.figure()
ax = fig.add_subplot(1,1,1)
ExpDataListKeys = ExpDataList.keys()

# Solve the system for each nutrient level and update plot
for i in range(len(ExpDataListKeys)):
    NutrientInitialmM = ExpDataListKeys[i]
    YInit = np.array([CellsInitialOD, NutrientInitialmM])
    y = odeint(Deriv, YInit, TimeRange)
    line, = ax.plot(TimeRange, y[:,0], linewidth=2, color=Colors[i])
    point, = ax.plot(ExpDataList[NutrientInitialmM][:,0], ExpDataList[NutrientInitialmM][:,1], 'o',
                     label=ExpDataListKeys[i], markersize=10, color=Colors[i], )

# Annotate plot
ax.set_yscale('log')
ax.set_ylabel('OD')
ax.set_xlabel('Time (hours)')
legend = ax.legend(title='Lactose (mM)', loc='left')

# Save plot to file
pp = PdfPages(output_filename)
pp.savefig(fig)
pp.close()
