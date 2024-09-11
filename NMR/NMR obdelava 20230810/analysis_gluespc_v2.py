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

class Glue_spc:
    '''takes a series of fid measurements and makes a wide spectrum'''
    # in future give it all the properties of a FID class?

    def __init__(self, file_key, file_dir):
        '''Initializes the class and sets the file keys and directory and makes the list'''
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

    def Run2(self, offset_range=(-200,None), shl=None, fr_density=1000, broaden_width=None, fit=True, mirroring=None):
        '''Executes the analysis functions'''
        self.Get_shl(shl=shl, offset_range=offset_range)
        self.Get_phase()
        self.Get_spc(broaden_width=broaden_width, fit=fit, fr_density=fr_density, mirroring=mirroring)
        self.Plot_joined_spc()

    def Run(self, broaden_width=None, fr_density=10):
        '''finnishes the analysis for gui'''
        #glued spc:
        #start the glued spectrum array
        self.spc_fr =  np.linspace(self.fr_min - self.fr_step, self.fr_max + self.fr_step,
                                   len(self.file_list)*fr_density)
        self.spc_sig_real = np.zeros(len(self.spc_fr))
        self.spc_sig_imag = np.zeros(len(self.spc_fr))

        #list of individual spectra
        self.spc_list_real = list()
        self.spc_list_imag = list()
        self.spc_list_points = list()
        self.fr_list = list()

        for f, phase in zip(self.file_list, self.phase_fit):
            fid = FID(f, self.file_dir)
            fid.Offset(self.offset_range)
            print("self.mean_shl", self.mean_shl)
            fid.Shift_left(self.mean_shl, mirroring=self.mirroring)
            if broaden_width:
                fid.Line_broaden(broaden_width)
            fid.Fourier()
            fid.Phase_rotate(phase)
            #integral for point spc
            fid.Integral_spc(self.integral_range)
            #add data
            self.spc_list_points.append(fid.area_spc)
            self.fr_list.append(fid.parameters['FR'])
            #interpolate the spectrum to new frequencies
            interp_real = np.interp(self.spc_fr, fid.spc_fr, fid.spc.real)
            interp_imag = np.interp(self.spc_fr, fid.spc_fr, fid.spc.imag)
            self.spc_list_real.append(interp_real)
            self.spc_list_imag.append(interp_imag)
            #accumulate total spectrum
            self.spc_sig_real += interp_real
            self.spc_sig_imag += interp_imag

        self.broaden_width = broaden_width
        self.fr_density = fr_density


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
        '''Extracts useful constant parameters for display from FIDs and saves into trace'''

        #initiate a representable FID
        fid = FID(self.file_list[-1], self.file_dir)
        #copy other usefull values
        self.TAU = str(1000000*fid.parameters['TAU'])+'u'
        self.D1 = str(1000000*fid.parameters['D1'])+'u'
        self.D3 = str(1000000*fid.parameters['D3'])+'u'
        self.D9 = str(int(1000*fid.parameters['D9']))+'m'
        self.NS = int(fid.parameters['NS'])


    def Get_shl(self, offset_range=(-200,None), shl=None):
        '''Checks the suggested SHL and saves the frequency list'''
        self.shl_list = list()
        self.fr_list = list()
        for f in self.file_list:
            fid = FID(f, self.file_dir)
            fid.Offset(offset_range)
            fid.Find_SHL()
            self.shl_list.append(fid.shl)
            self.fr_list.append(fid.parameters['FR'])

        #set the frequency range
        self.fr_min, self.fr_max = (min(self.fr_list), max(self.fr_list))
        self.fr_step = (self.fr_max - self.fr_min)/len(self.file_list)

        self.offset_range=offset_range
        
        print(self.shl_list)
        #choose offset by hand :(
        if not shl:
            self.shl = int(input('Choose the shl value: '))

    def Get_phase(self, shl=None, offset_range=None, fit_range=None):
        '''Gets the phases from spectra'''
        self.phase_list = list()

        if shl:
            self.shl = shl
        if offset_range:
            self.offset_range = offset_range
        if fit_range:
            self.fit_range = fit_range

        for f in self.file_list:
            fid = FID(f, self.file_dir)
            fid.Offset(self.offset_range)
            fid.Shift_left(self.shl)
            fid.Fourier()
            fid.Phase_spc()
            self.phase_list.append(fid.phase_spc)

        #linear fit to phases
        def Lin_fit(x, k=1, n=0):
            return k*x + n
        #axes
        x=self.fr_list
        y=np.unwrap(self.phase_list, 0.5*np.pi)

        #cange fit ranges
        if fit_range:
            x2=x[slice(*fit_range)]
            y=y[slice(*fit_range)]
        
        #starting values
        p_start=[1,0]
        #run fit
        popt,pcov = curve_fit(Lin_fit, x2, y, p0=p_start)
        self.phase_fit = [Lin_fit(xx, *popt) for xx in x]
        #save fit params
        self.phase_fit_p = popt
        
    def Get_spc(self, fit=True, fr_density=100, broaden_width=None, mirroring=None):
        '''Gets the individual spectra and the total spectrum'''
        #start the glued spectrum array
        self.spc_fr =  np.linspace(self.fr_min - self.fr_step, self.fr_max + self.fr_step,
                                   len(self.file_list)*fr_density)
        self.spc_sig_real = np.zeros(len(self.spc_fr))
        self.spc_sig_imag = np.zeros(len(self.spc_fr))

        #list of individual spectra
        self.spc_list_real = list()
        self.spc_list_imag = list()

        for f, phase in zip(self.file_list, self.phase_fit):
            fid = FID(f, self.file_dir)
            fid.Offset(self.offset_range)
            fid.Shift_left(self.shl, mirroring=mirroring)
            if broaden_width:
                fid.Line_broaden(broaden_width)
            fid.Fourier()
            if fit:
                fid.Phase_rotate(phase)
            else:
                fid.Phase_spc()
                fid.Phase_rotate(fid.phase_spc)
            #interpolate the spectrum to new frequencies
            interp_real = np.interp(self.spc_fr, fid.spc_fr, fid.spc.real)
            interp_imag = np.interp(self.spc_fr, fid.spc_fr, fid.spc.imag)
            self.spc_list_real.append(interp_real)
            self.spc_list_imag.append(interp_imag)
            #accumulate total spectrum
            self.spc_sig_real += interp_real
            self.spc_sig_imag += interp_imag


    def Plot_joined_spc(self):
        '''test function for plotting the joined spectra'''
        plt.figure(dpi=100,figsize=(12,6))
        #add the traces
        for i in range(len(self.file_list)):
            plt.plot(self.spc_fr, self.spc_list_real[i], color=colors[i%8], label=str(self.fr_list[i])+'MHz')
            plt.axvline(x=self.fr_list[i] , color=colors[i%8])
        plt.plot(self.spc_fr, self.spc_sig_real, color=colors[-1],label="Re",marker='.')
        #plot labels and frames
        plt.title("Joined spectrum")
        plt.xlabel("Frequency (MHz)")
        plt.ylabel("Summed signal")
        plt.grid()
        #plt.legend(loc='upper right')
        plt.xlim(self.spc_fr[0], self.spc_fr[-1])
        #print the plot
        plt.show()

    def Plot_phase(self):
        '''Show how the phase is selected along the measurement'''
        #what to do about the phase jumps?
        plt.figure()
        #add the traces
        plt.plot(self.fr_list, np.unwrap(self.phase_list), color=colors[1],label="phase",marker='.')
        try:
            plt.plot(self.fr_list, self.phase_fit, color=colors[2],label="lin fit",marker='.')
        except: pass
        #plot labels and frames
        plt.title("Current spc function")
        plt.xlabel("t (index)")
        plt.ylabel("signal")
        plt.grid()
        plt.legend(loc='upper left')
        #print the plot
        plt.show()

    def Plot_fid_all(self, height_fact=0.5):
        '''Plots all FIDs'''
        fids = list()
        for file in self.file_list:
            fid = FID(file, self.file_dir)
            fids.append(fid.x)

        height = np.amax(np.abs(fids))
        
        plt.figure(figsize=(8,6))
        for i,fid in enumerate(fids):
            plt.plot(np.abs(fid) + height*height_fact*i, color=colors[i % len(colors)], label=str(i))
        plt.title("Fids")
        plt.xlim(0,len(fids[0]))
        plt.xlabel("t (index)")
        plt.ylabel("signal")
        plt.grid()
        #plt.legend(loc='upper left')
        #print the plot
        plt.show()

    def Plot_spc_all(self, broaden_width=None, fit=False):
        '''Plots all spectra'''
        spcs = list()
        for f, phase in zip(self.file_list, self.phase_fit):
            fid = FID(f, self.file_dir)
            fid.Offset(self.offset_range)
            fid.Shift_left(self.shl)
            if broaden_width:
                fid.Line_broaden(broaden_width)
            fid.Fourier()
            if fit:
                fid.Phase_rotate(phase)
            else:
                fid.Phase_spc()
                fid.Phase_rotate(fid.phase_spc)

        height = np.amax(np.abs(spcs[-1]))
        
        plt.figure(figsize=(8,6))
        for i,spc in enumerate(spcs):
            plt.plot(np.abs(fid)+ height*0.5*i, color=colors[i % len(colors)], label=str(i))
        plt.title("Fids")
        plt.xlabel("t (index)")
        plt.ylabel("signal")
        plt.grid()
        plt.legend(loc='upper left')
        #print the plot
        plt.show()
        
    def Quick_spc(self, offset_range=(-200,-1), phase_range=(0,-1), shl_convol=1, integral_range=None):
        '''Runs through all files to determine shls values and preplot the fids'''
  
        self.quick_shl = list()
        self.temp_list = list()
        self.temp_list2 = list()
        self.fr_list = list()

        fid = FID(self.file_list[-1], self.file_dir)
        self.temp_set = fid.parameters.get('_ITC_R0',0)

        #integral range hevristics
        if not integral_range:
            integral_range = (int(fid.parameters['D3']/fid.parameters['DW']/2),
                              int(fid.parameters['D3']/fid.parameters['DW']*2))

        for file in self.file_list:
            fid = FID(file, self.file_dir)
            fid.Offset(offset_range)
            fid.Find_SHL(convolution=shl_convol)

            #fill the tables
            self.quick_shl.append(fid.shl)
            self.fr_list.append(fid.parameters['FR'])
            try:
                self.temp_list.append(fid.parameters.get('_ITC_R1',0))
                self.temp_list2.append(fid.parameters.get('_ITC_R2',0))
            except:
                pass

        #set the frequency range
        self.fr_min, self.fr_max = (min(self.fr_list), max(self.fr_list))
        self.fr_step = (self.fr_max - self.fr_min)/len(self.file_list)

        #resort the filelist by frequency
        ###try fix frequency sorting (has to happen sooner!)
        sorting = np.argsort(self.fr_list)
        self.fr_list = np.array(self.fr_list)[sorting]
        self.file_list = np.array(self.file_list)[sorting]
        self.quick_shl = np.array(self.quick_shl)[sorting]
        try:
            self.temp_list = np.array(self.temp_list)[sorting]
            self.temp_list2 = np.array(self.temp_list2)[sorting]
        except: pass

        return (self.temp_list, self.temp_list2, self.temp_set, self.fr_list, self.quick_shl)
