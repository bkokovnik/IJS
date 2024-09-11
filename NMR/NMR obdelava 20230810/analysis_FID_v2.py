import os #os path functions for importing
import re #searching strings,etc (regex)
import matplotlib           #plots
import numpy as np          #numpy for all numerical
import matplotlib.pyplot as plt #short notation for plots
from scipy.optimize import curve_fit    #fitting algorithm from scipy
import pickle               #pickle for saving python objects
#from matplotlib.gridspec import GridSpec       #widgets for matplotlib plots
#from matplotlib.widgets import SpanSelector
#from matplotlib.widgets import Button

#plot colors from colorbrewer
colors = ['#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#ffff33','#a65628','#f781bf','#999999']

#set some global settings for plots
plot_font = {'family': 'Calibri', 'size': '12'}
matplotlib.rc('font', **plot_font)  # make the font settings global for all plots

### global variables/lists (everything that might cahnge at some point and should be acessible from multiple points)
GLOBAL_pkl_list = ['series','raw_file_list','raw_dir','possible_series']

#create a FID class that takes care of extracting and analyzing the fid files from 7nmr
class FID:
    '''Class that opens and analyzes data from the 7nmr files'''

    def __init__(self, file_name, file_dir):
        '''Initializes the class taking the name and directory of the file'''
        self.file_name = file_name
        
        self.Open_file(file_name, file_dir)
        
    ### routines        
        
    def Open_file(self, file_name, file_dir):
        '''Opens the file and extracts parameters as dict and the lists of data'''
        self.parameters = dict()

        with open(os.path.join(file_dir, file_name)) as f:
            lines = list(f)
            #remove the \n
            lines = [l.strip() for l in lines]

            #extract the parameters (old rules list) 
            # initialize a dictionary [item : value , item2 : value2, ...]   
            
            for l in lines[lines.index("[PARAMETERS]")+1 : lines.index("[DATA]")]:
                tmp = l.split("=")
                #skip the non a=b lines
                if len(tmp) != 2: continue
                #convert what you can into floats
                try:
                    self.parameters[tmp[0]] = float(tmp[1])
                #when error occurs leave it as string
                except:
                    self.parameters[tmp[0]] = tmp[1]

            #extract the data columns 
            self.x1 = []
            self.x2 = []
            for l in lines[lines.index("[DATA]")+1 : ]:
                #tmp=re.findall(exp_notation, l)
                tmp = l.split()
                self.x1.append(float(tmp[0]))
                self.x2.append(float(tmp[1]))

        #make a complex numpy array for editing
        self.x = np.array(self.x1) + 1j * np.array(self.x2)
        self.x_len = len(self.x)

    def Run(self, broaden_width=None, shl=None, mirroring=None, zero_fill=1):
        '''Runs the basic analysis on self'''
        print("FID.Run was called")
        self.Offset(offset_range = (-200,-1))
        self.Find_SHL(3)
        if shl:
            self.Shift_left(shl)
        else:
            self.Shift_left(self.shl, mirroring=mirroring)
        if broaden_width:
            self.Line_broaden(broaden_width)
        self.Fourier(zero_fill=zero_fill)
        self.Phase_spc()
        self.Phase_rotate(self.phase_spc)
        self.Plot_fid()
        self.Plot_spc()

    def Offset(self, offset_range=(-200,-1)):
        '''Calculates mean offset of last points of x and sets it to 0'''
        self.mean = np.mean(self.x[slice(*offset_range)])
        self.x = self.x - self.mean
        self.offset_range = offset_range

    def Find_SHL(self, convolution=1):
        '''Smooths the list with symmetric convolution and finds maximal element'''
        convolved = np.convolve(np.ones(2*convolution-1), self.x, 'same')
        self.shl = np.argmax(np.absolute(convolved))

    def Shift_left(self, shl, mirroring=None):
        '''Shifts the array to left and pads with zeroes or mirrors to back'''
        if not mirroring:
            self.x = np.delete(self.x, np.s_[0:shl])
            self.x = np.append(self.x, np.zeros(shl))
            self.offset_range = (self.offset_range[0] - shl, None)
            self.mirroring=False
        else:
            self.x = np.roll(self.x, -shl)
            self.offset_range = (self.offset_range[0] - shl, None)
            self.mirroring=True

    def Line_broaden(self, broaden_width):
        '''Broadens the spectral lines by putting a gaussian envelope over the fid'''
        dw = self.parameters['DW']
        if not self.mirroring:
            a = np.array(range(self.x_len))
        else:
            #adds the negative side of the broadening gaussian on the second half
            a = np.concatenate((range(self.x_len//2), range(-self.x_len//2, 0)))

        self.broaden_width = broaden_width
        self.x = np.multiply(self.x, np.exp(-(a*broaden_width*dw)**2/(4*np.log(2))))

    def Fourier(self, zero_fill=1):
        '''Fourier transforms the fid and sorts the lists b frequency'''
        fill_len = self.x_len * 2**zero_fill
        time_step = self.parameters['DW'] #s
        center_frequency = self.parameters['FR'] #MHz
        #make fft on data
        if not self.mirroring:
            #regular fill
            spectrum = np.fft.fft(self.x, fill_len)
        else:
            #fill in center
            spectrum = np.fft.fft(np.insert(self.x, int(self.x_len/2), np.zeros(int(fill_len/2))), fill_len)
        #generate correct list of frequencies for the fft
        frequencies = -np.fft.fftfreq(fill_len, time_step)/10**6 + center_frequency #MHz
        #sorting and saving
        sort_list = frequencies.argsort()
        self.spc = spectrum[sort_list]
        self.spc_fr = frequencies[sort_list]
        self.spc_len = fill_len

    def Phase_fid(self, phase_range=(0,None)):
        '''Calculates the phase of the signal form the fid (in given range)'''
        self.phase_fid = np.angle(np.sum(self.x[slice(*phase_range)]))

    def Phase_spc(self, phase_range=(0,None)):
        '''Calculates the phase of the signal from the spc (in given range)'''
        self.phase_spc = np.angle(np.sum(self.spc[slice(*phase_range)]))

    def Phase_rotate(self, phase):
        '''Rotates the phase of the fid and spc by the given phase'''
        self.x = self.x * np.exp(-1j * phase)
        if 'spc' in self.__dict__:
            self.spc = self.spc * np.exp(-1j * phase)

    def Integral_spc(self, integral_range):
        '''Integrates the area under the real part of the spectrum in given (list index) range'''
        self.area_spc = np.sum(self.spc.real[slice(*integral_range)])
        self.integral_range_spc = integral_range

    def Integral_fid(self, integral_range):
        '''Integrates the area under the absolute value of fid in given (list index) range'''
        self.area_fid = np.sum(self.spc.real[slice(*integral_range)])

    def Plot_fid(self, x_range=None, time_axis=False):
        '''Shows a plot of the current fid'''
        plt.figure()
        #add the traces
        if time_axis:
            self.t = np.linspace(0, self.x_len-1, self.x_len) * self.parameters['DW']*1.0e+6
            plt.plot(self.t, self.x.real, color=colors[1],label="Re")
            plt.plot(self.t, self.x.imag, color=colors[2],label="Im")
            plt.plot(self.t, np.absolute(self.x), color=colors[3],label="Abs")
            plt.xlabel("t (us)")
        else:
            # x axis is in points, not time units.
            plt.plot(self.x.real, color=colors[1],label="Re")
            plt.plot(self.x.imag, color=colors[2],label="Im")
            plt.plot(np.absolute(self.x), color=colors[3],label="Abs")
            plt.xlabel("t (index)")
            
        try:
            off= self.x_len + self.offset_range
            plt.axvline(x=off,color=colors[-1])
        except: pass
        #plot labels and frames
        plt.title("Current fid function")
        plt.ylabel("signal")
        plt.grid()
        plt.legend(loc='upper right')
        #plot range
        if x_range:
            plt.xlim(xmax=x_range)
        #post plot
        plt.show()

    def Plot_spc(self, plot_range=None, frequency_axis=True):
        #plots the current fid
        plt.figure()
        #add the traces
        if frequency_axis:
            plt.plot(self.spc_fr, self.spc.real, color=colors[1],label="Re",marker='.')
            plt.plot(self.spc_fr, self.spc.imag, color=colors[2],label="Im",marker='.')
            plt.axvline(x=self.parameters['FR'],color=colors[-1])
            #plot range
            if plot_range:
                plt.xlim((self.parameters['FR']-plot_range,self.parameters['FR']+plot_range))
            else:
                plt.xlim((self.parameters['FR']-0.5,self.parameters['FR'] +0.5))
        else:
            plt.plot(self.spc.real, color=colors[1],label="Re",marker='.')
            plt.plot(self.spc.imag, color=colors[2],label="Im",marker='.')
        try:
            l= self.spc_fr[self.integral_range_spc[0]]
            r= self.spc_fr[self.integral_range_spc[1]]
            plt.axvline(x=l,color=colors[-1])
            plt.axvline(x=r,color=colors[-1])
        except: pass
        #plot labels and frames
        plt.title("Current spc function")
        plt.xlabel("t (index)")
        plt.ylabel("signal")
        plt.grid()
        plt.legend(loc='upper right')

        #print the plot
        plt.show()