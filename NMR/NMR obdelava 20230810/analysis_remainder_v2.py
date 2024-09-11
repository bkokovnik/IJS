#######################################
# program for analyzing nmr data (from 7NMR)
# created by Nejc Jansa
# nejc.jansa@ijs.si
# document creation 14.11.2016
# last version: 06.11.2018
#######################################

#conventions:
#functions capitalized, variables small
#data lists should be numpy arrays np.array(), once they get big
#ranges should go around as tuples:
#last element: tup=(-5, None), then make a[slice(*tup)]
#never put random integers in function, always name them and default call them


#points to consider:
#

#(minimal) necessary imports

# Versions of packages:
# numpy-1.11.2+mkl-cp35-cp35m-win_amd64.whl
# scipy-0.18.1-cp35-cp35m-win_amd64.whl
# matplotlib-2.0.0-cp35-cp35m-win_amd64.whl

#should minimalize...?
import os #os path functions for importing
import re #searching strings,etc (regex)
import matplotlib           #plots
import numpy as np          #numpy for all numerical
import matplotlib.pyplot as plt #short notation for plots
from scipy.optimize import curve_fit    #fitting algorithm from scipy
import pickle               #pickle for saving python objects

from analysis_FID_v2 import *
from analysis_T1_v2 import *
from analysis_T2_v2 import *
from analysis_gluespc_v2 import *

#plot colors from colorbrewer
colors = ['#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#ffff33','#a65628','#f781bf','#999999']

#set some global settings for plots
plot_font = {'family': 'Calibri', 'size': '12'}
matplotlib.rc('font', **plot_font)  # make the font settings global for all plots

### global variables/lists (everything that might cahnge at some point and should be acessible from multiple points)
GLOBAL_pkl_list = ['series','raw_file_list','raw_dir','possible_series']

class D1:
    '''Evaluates a series of fid measurements, analyzing D1 maximum'''

    def __init__(self, file_key, file_dir):
        '''Initializes the class and sets the file keys and directory'''
        self.file_key = file_key
        self.file_dir = file_dir
        self.Find_files()

        self.analysed = False
        self.disabled = False


    def Find_files(self):
        '''Makes a list of all files with key and 000-999.DAT'''
        dir_list = os.listdir(self.file_dir)
        key = '^' + self.file_key + '-[0-9]*.DAT$'
        #save the sorted list
        def Sort_key(item):
            '''sort key to sort files by last number xxx.DAT'''
            return int(item.split('-')[-1][:-4])
        self.file_list = sorted([i for i in dir_list if re.search(key, i)], key=Sort_key)


    def Extract_D1(self):
        '''Runs all the routines required to get the T2 of the series'''
        pass

    

class Series():
    '''Series, replaces separate series classes'''
    def __init__(self, parent, series_type):
        '''initializes the series class and remembers the type relevant info'''
        # 'calling_name': [class_for_point, file_prepend] #
        types = {'T1vT': [T1, 'T1'], 'T2vT': [T2, 'T2'], 'Spectrum': [Glue_spc, 'spc'], 'D1_sweep': [D1, 'D1']}
        self.file_prepend = types[series_type][1]
        self.point_method = types[series_type][0]

        #reference to parent (experiment_data class)
        self.parent = parent
        #dictionary of traces, data: (make sure it never gets deleted!)
        self.traces = dict()
        self.Keys()


    def Keys(self):
        '''finds the unique keys from parent and adds to the trace structure'''
        self.points = [point for point in self.parent.raw_file_list if point[0][0]==self.file_prepend]
        self.keys = sorted(list(set(point[1] for point in self.points)))
        #make sure there are trace entries for each key
        for key in self.keys:
            if key not in self.traces:
                self.traces[key] = dict()
        #adds all the new points in the tree
        for point in self.points:
            key = point[1]
            temp = point[0][-1]
            if temp not in self.traces[key]:
                #creates runs the T1 class for the selected temperature
                self.traces[key][temp] = self.point_method(point[2], point[3])
        
        
class Test():
    '''Dummy testing class'''
    def __init__(self,parent):
        self.parent = parent


class Experiment_data():
    '''A class that handles data searching, adding and saving'''
    def __init__(self, experiment):
        '''Prepares the selected experiment'''
        #define directories
        self.file_dir = os.path.join('data', experiment)
        #self.raw_dir = os.path.join('data', experiment, 'raw')
        self.pkl_dir = os.path.join('data', experiment, 'pkl')

        #self.possible_series = {'Spectrum':Spectrum, 'T1vT':T1vT, 'T2vT':T2vT}
        self.possible_series = ['Spectrum', 'T1vT', 'T2vT', 'D1_sweep']

        #Flag if data is loaded
        self.opened = False


    def Add_series(self):
        '''Finds all files and makes the predefined series classes. This will DELETE all previous data!!!'''
        #search for files
        self.Find_raw_files()
        #introduce the classes for further analysis        
        self.series = dict()
        #initialize all possible series
        for serie in self.possible_series:
            #self.series[serie]=self.possible_series[serie](self)
            self.series[serie]=Series(self,serie)

    def Pkl_load(self):
        '''Loads all pickled data'''
        #search the pkl dir for files, removes ending!
        pkl_list = [os.path.splitext(pkl)[0] for pkl in os.listdir(self.pkl_dir)if pkl.endswith('.pkl')]
        #adds all the pickled data into the class
        for p in pkl_list:
            p_name = os.path.join(self.pkl_dir, p + '.pkl')
            with open(p_name, 'rb') as pfile:
                self.__dict__[p] = pickle.load(pfile)
        #cringy fix for referencing (remind them who their parent is :)
        for serie in self.series:
            self.series[serie].parent = self

    def Pkl_save(self):
        '''Saves the data that should be pickled'''
        #save
        for p in GLOBAL_pkl_list:
            p_name = os.path.join(self.pkl_dir, p + '.pkl')
            with open(p_name, 'wb') as pfile:
                pickle.dump(self.__dict__[p], pfile, protocol=-1)

    #for now going with a linear list of filenames...
    #implement dictionaries if slow!!!
    def Find_raw_files(self):
        '''Makes a list of all raw files in directory and subdir'''
        raw_file_list = list()

        def Sort_key(item):
            '''Sorts over file keys first, then temperature'''
            l1 = len(item[0])
            #looks at the key split and takes other parts first and temperature last
            return (item[0][:-1],float(item[0][-1]))


        #takes the lists of directory path, directory name and the file name
        for dir_path, dir_names, file_names in os.walk(self.raw_dir):
            #takes every file matching the ending in directory
            for file_name in [file for file in file_names if file.endswith('G.DAT') or file.endswith('G.dat')]:
                split = file_name.split('-')[:-1]  #ignores xxx.DAT
                file_key = '-'.join(split)
                #put T at end
                for s in split:
                    if s[-1] == 'K':
                        split.remove(s)
                        #adds T as float
                        split.append(float(s[:-1].replace('p','.')))
                        break #ends once T is found
                unique_key = '-'.join(split[:-1])
                raw_file_list.append([split, unique_key, file_key, dir_path])
        #save list
        self.raw_file_list = sorted(raw_file_list, key=Sort_key)

    def File_sets(self):
        '''Shows the sets with different temperature from raw_file_list'''
        unique = sorted(list(set(['-'.join(i[0][:-1]) for i in self.raw_file_list])))
        for i in unique:
            print(i)




if __name__ == "__main__":
    '''Runs if this is the excecuted file'''
    #some test filenames
    fd = 'D:\Data\180716_CuIrO_NQR'
    fn = 'spc-18dB-20K-2lr-103.DAT'
        











