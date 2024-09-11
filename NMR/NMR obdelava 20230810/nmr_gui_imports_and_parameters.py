# necessary imports
import numpy as np # for mathematic functions
import matplotlib # for plotting
import csv  # for importing and exporting csv files
import gc
import os
### now using matplotlib 2.0.0
import matplotlib.pyplot as plt
matplotlib.use('TkAgg') # sets tkinter to be the backend of matplotlib

#matplotlib canvas and plot edit toolbar
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk # NavigationToolbar2TkAgg
NavigationToolbar2TkAgg = NavigationToolbar2Tk

# implement the default mpl key bindings
from matplotlib.backend_bases import key_press_handler

#scipy fitting function
from scipy.optimize import curve_fit

# (Tkinter for Python 3) gui objects
import tkinter as tk
from tkinter import ttk
from tkinter import messagebox

#import analysis functions and classes
#from analysis_v2 import *
from analysis_FID_v2 import *
from analysis_T1_v2 import *
from analysis_T2_v2 import *
from analysis_gluespc_v2 import *
from analysis_remainder_v2 import *

#colorbrewer nice plot colot set
colors = ['#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#ffff33','#a65628','#f781bf','#999999',
          '#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#ffff33','#a65628','#f781bf','#999999',
          '#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#ffff33','#a65628','#f781bf','#999999']

#set some global settings for plots
plot_font = {'family': 'Calibri', 'size': '12'}
matplotlib.rc('font', **plot_font)  # make the font settings global for all plots


### global data
#make sure things that are going to change in future and might be used in multiple places are here!
GLOBAL_experiment_dirs = ['pkl', 'raw', 'csv']
GLOBAL_t1_default_params = {'mean_range':(-4,None), 'offset':(1500,None),
                            'integral_range':(2000,2100), 'mirroring':False, 'stretch':True}
GLOBAL_t2_default_params = {'mean_range':(0,4), 'offset':(1500,None),
                            'integral_range':(2000,2100), 'mirroring':False}
GLOBAL_t1_displayed_params = ['T1', 'r', 'analysed', 'disabled', 'mirroring', 'fr', 'temp_set', 'mean_shl',
                              'mean_phase_deg', 'mean_range', 'offset_range', 'integral_range',
                              'file_key', 'file_dir', 'TAU', 'D1', 'D2', 'D3', 'D9', 'NS', 'D5_min', 'D5_max']
GLOBAL_t2_displayed_params = ['T2', 'r', 'analysed', 'disabled', 'mirroring', 'fr', 'temp_set', 'mean_shl',
                              'mean_phase_deg', 'mean_range', 'offset_range', 'integral_range',
                              'file_key', 'file_dir', 'D1', 'D3', 'D9', 'NS']
GLOBAL_spc_default_params = {'shl_start':220, 'offset':(1500,None),
                            'integral_range':(2000,2100), 'mirroring':False}
GLOBAL_spc_displayed_params = ['fr', 'broaden_width', 'fr_density', 'analysed', 'disabled', 'mirroring', 'temp_set', 'mean_shl',
                              'mean_range', 'offset_range', 'integral_range',
                              'file_key', 'file_dir', 'TAU', 'D1', 'D3', 'D9', 'NS']