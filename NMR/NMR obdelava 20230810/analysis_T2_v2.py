import os #os path functions for importing
import re #searching strings,etc (regex)
import matplotlib           #plots
import numpy as np          #numpy for all numerical
import matplotlib.pyplot as plt #short notation for plots
from scipy.optimize import curve_fit    #fitting algorithm from scipy
import pickle               #pickle for saving python objects

from analysis_FID_v2 import *

#plot colors from colorbrewer
colors = ['#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#ffff33','#a65628','#f781bf','#999999']

#set some global settings for plots
plot_font = {'family': 'Calibri', 'size': '12'}
matplotlib.rc('font', **plot_font)  # make the font settings global for all plots

### global variables/lists (everything that might cahnge at some point and should be acessible from multiple points)
GLOBAL_pkl_list = ['series','raw_file_list','raw_dir','possible_series']

class T2:
    '''Evaluates a series of fid measurements, analyzing T2'''

    def __init__(self, file_key, file_dir):
        '''Initializes the class and sets the file keys and directory'''
        self.file_key = file_key
        self.file_dir = file_dir
        self.Find_files()

        self.analysed = False
        self.disabled = False
        self.mirroring = False

        self.Get_params()

    def Reinit(self):
        '''deletes all content and reinitializes class'''
        file_key = self.file_key
        file_dir = self.file_dir
        #clear parameters and restart
        self.__dict__.clear()
        self.__init__(file_key, file_dir)

    def Find_files(self):
        '''Makes a list of all files with key and 000-999.DAT'''
        dir_list = os.listdir(self.file_dir)
        key = '^' + self.file_key + '-[0-9]*.DAT$'
        #save the sorted list
        def Sort_key(item):
            '''sort key to sort files by last number xxx.DAT'''
            return int(item.split('-')[-1][:-4])
        self.file_list = sorted([i for i in dir_list if re.search(key, i)], key=Sort_key)


    def Get_params(self):
        '''Extracts useful constant parameters from FIDs and saves into trace'''

        #initiate a representable FID
        fid = FID(self.file_list[-1], self.file_dir)
        #copy other usefull values
        self.D1 = str(1000000*fid.parameters['D1'])+'u'
        self.D3 = str(1000000*fid.parameters['D3'])+'u'
        self.D9 = str(int(1000*fid.parameters['D9']))+'m'
        self.NS = int(fid.parameters['NS'])


    def Quick_T2(self, offset_range=(-200,-1), phase_range=(0,-1), shl_convol=1, integral_range=None):
        '''Quick T2 points for range and mean selections'''
            
        self.quick_T2 = list()
        self.quick_phase = list()
        self.quick_shl = list()
        self.temp_list = list()
        self.temp_list2 = list()
        self.tau_list = list()

        fid = FID(self.file_list[0], self.file_dir)
        self.temp_set = fid.parameters.get('_ITC_R0',0)
        self.fr = fid.parameters['FR']

        #integral range hevristics
        if not integral_range:
            integral_range = (int(fid.parameters['D3']/fid.parameters['DW']/2),
                              int(fid.parameters['D3']/fid.parameters['DW']*2))

        for file in self.file_list:
            fid = FID(file, self.file_dir)
            fid.Offset(offset_range)
            fid.Find_SHL(convolution=shl_convol)
            fid.Shift_left(fid.shl)
            fid.Fourier()
            fid.Phase_spc(phase_range)
            fid.Phase_rotate(fid.phase_spc)
            fid.Integral_fid(integral_range)
            #fill the tables
            self.tau_list.append(fid.parameters['TAU'])
            self.quick_T2.append(fid.area_fid)
            self.quick_phase.append(fid.phase_spc)
            self.quick_shl.append(fid.shl)
            self.temp_list.append(fid.parameters.get('_ITC_R1',0))
            self.temp_list2.append(fid.parameters.get('_ITC_R2',0))

        return (self.temp_list, self.temp_list2, self.temp_set, self.tau_list,
                self.quick_T2, self.quick_phase, self.quick_shl)
        
    def Run(self):
        '''Uses the determined ranges and finalizes calculations'''
        self.area_list = list()

        #perhaps mean phase should be recalculated!!
        #allow for running with fid integral?

        for file in self.file_list:
            fid = FID(file, self.file_dir)
            fid.Offset(self.offset_range)
            fid.Shift_left(self.mean_shl, mirroring=self.mirroring)
            fid.Fourier()
            fid.Phase_rotate(self.mean_phase)
            fid.Integral_spc(self.integral_range)
            #update lists
            self.area_list.append(fid.area_spc)