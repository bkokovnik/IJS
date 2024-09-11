#######################################
# Gui program for analyzing nmr data (from 7NMR)
# created by Nejc Jansa
# nejc.jansa@ijs.si
# document creation 14.11.2016
# last version: 06.11.2018
#######################################

# Beta version (0.2)
# Memory leak not adressed, have to restart between long datasets to prevent freezing and loss of data!
# Works with analysis_v2.py

# Ideas for next version:
# Should split up code in several files for clarity
# Allow moving of files into diffent trace (for patching up bad sets)
# Marking of traces that are interesting, renaming, hiding Bad files...
# Find memory leak in tkinter/matplotlib
# Test direct execution or even transforming into .exe?
# Clear up dead buttons
# Prevent multiple plot instances from opening
# Better keyboard control
# More consistency with class naming and functions/methods
# A way of combining datasets, management of the raw data files
# Plotting specra angle dependence
# More controll over analysis parameters, make editable tables for it
# a D1 plot
# Implement parameters for smaller figure sizes to account for smaller resolution!!
# External input of new fitting formulas
# Simplify adding a sum of fits
# Remember selected fit function for each trace
# Better export format for fit results
# Select what is exported/ displayed/ plotted
# do not auto fit when opening old data (or remember the old fit function)
# add manual change of SHL and phase in T1, T2
# fix the export temperatures not matching file names (due to decimals)


# Versions of packages:
# numpy-1.11.2+mkl-cp35-cp35m-win_amd64.whl
# scipy-0.18.1-cp35-cp35m-win_amd64.whl
# matplotlib-2.0.0-cp35-cp35m-win_amd64.whl

from nmr_gui_imports_and_parameters import *
from nmr_gui_spc import *
from nmr_gui_T1 import *
from nmr_gui_T2 import *

class Frame_experiments(tk.Frame):
    '''Leftmost frame with selection of experiment'''
    def __init__(self, parent):
        '''makes the subframe and fills it up'''
        tk.Frame.__init__(self, parent, bd=5)
        self.pack(side='left', fill='y')

        #reference to parent
        self.parent = parent

        #load widgets
        self.Widgets()

    def Widgets(self):
        '''Puts all the widgets on the frame'''
        #adds label to frame
        self.label_experiments = tk.Label(self, text='Experiments')
        self.label_experiments.pack(side='top')
        
        #adds list to frame
        self.listbox_experiments = tk.Listbox(self, exportselection=0, bd=5,
                                              relief='flat', height=15)
        self.listbox_experiments.pack(side='top',fill='y')
        self.listbox_experiments.bind('<Return>', self.Open)
        self.listbox_experiments.bind('<F5>', self.New)
        #checks for all experiments
        for experiment in sorted(self.parent.data):
            self.listbox_experiments.insert('end', experiment)
        self.listbox_experiments.focus()
        
        #adds button to frame
        self.button_open = ttk.Button(self, text='Open', command=self.Open)
        self.button_open.pack(side='top')
        self.button_new = ttk.Button(self, text='New', command=self.New)
        self.button_new.pack(side='top')

    def New(self, event=None):
        '''Actions to perform when button_new is pressed'''

        #define button functions
        def Create(event=None):
            '''Create action, creates new experiment_data'''
            try:
                new_name = self.entry_new.get()
                path = os.path.join('data', new_name)
                os.mkdir(path)
                for sub_dir in GLOBAL_experiment_dirs:
                    os.mkdir(os.path.join(path, sub_dir))
                #adds an entry to listbox
                self.listbox_experiments.insert('end', new_name)
                #creates the Experiment_data
                self.parent.data[new_name] = Experiment_data(new_name)

                #asks for folder
                dir_new = tk.filedialog.askdirectory(parent=root,initialdir=os.path.dirname(os.path.realpath(__file__)),title='Please select a directory')
                self.parent.data[new_name].raw_dir = dir_new
                
                self.parent.data[new_name].Add_series()
                self.parent.data[new_name].Pkl_save()
                
            except FileExistsError:
                tk.messagebox.showerror('Error','The directory already exists!')

            #forgets and removes the button and entry field
            Cancel()
            
        def Cancel(event=None):
            '''Cancel button action, removes the entry boxes'''
            self.frame_new.destroy()
            #reenables the buttons
            self.button_new.config(state='normal')
            self.button_open.config(state='normal')
            self.listbox_experiments.bind('<Return>', self.Open)
            self.listbox_experiments.bind('<F5>', self.New)
            #focus back to experiments listbox
            self.listbox_experiments.focus()

        #build the addon frame under experiments
        self.frame_new = tk.Frame(self)

        #add label
        self.label_new = tk.Label(self.frame_new, text='New experiment', bd=5)
        self.label_new.pack(side='top')

        #add entry box and set it to focus
        self.entry_new = ttk.Entry(self.frame_new, takefocus=True)
        self.entry_new.pack(side='top')
        self.entry_new.focus()
        #define enter and ecape commands within entry box
        self.entry_new.bind('<Return>', Create)
        self.entry_new.bind('<Escape>', Cancel)

        #add create button
        self.button_create = ttk.Button(self.frame_new, text='Create', command=Create)
        self.button_create.pack(side='top')
        #add cancel creation button
        self.button_cancel = ttk.Button(self.frame_new, text='Cancel', command=Cancel)
        self.button_cancel.pack(side='top')
        
        #disable the upper buttons to prevent multiple entry boxes
        self.button_new.config(state='disabled')
        self.button_open.config(state='disabled')
        self.listbox_experiments.unbind('<Return>')
        self.listbox_experiments.unbind('<F5>')

        #pack the holding frame
        self.frame_new.pack(side='top')
        

    def Open(self, event=None):
        '''Opens selected experiment and shows available series'''

        #define button functions
        def Select(event=None):
            '''Opens the traces of the selected series, loads them into listbox'''
            #get the selected series
            self.parent.current_series = self.listbox_series.get('active')
            #call traces frame functions
            self.parent.traces.Load_series()

        def Refresh(event=None):
            '''Updates raw_file_list by scanning directories again'''
            self.parent.data[self.parent.current_experiment].Find_raw_files()
            for serie in self.parent.data[self.parent.current_experiment].series:
                self.parent.data[self.parent.current_experiment].series[serie].Keys()
            msg = 'The file directory was scanned and the file lists updated!'
            tk.messagebox.showinfo('File list updated', msg)

        def Save(event=None):
            '''Save and close the current experiment'''
            self.frame_series.destroy()
            #reenables the buttons
            self.button_new.config(state='normal')
            self.button_open.config(state='normal')
            self.listbox_experiments.config(state='normal')
            self.listbox_experiments.bind('<Return>', self.Open)
            self.listbox_experiments.bind('<F5>', self.New)
            #focus back to experiments listbox
            self.listbox_experiments.focus()

            #pickle all the containing data
            self.parent.data[self.parent.current_experiment].Pkl_save()

            #close up other frames
            self.parent.traces.Disable()
            self.parent.temperatures.Disable()
            
        
        #remembers what experiment we are working on and loads it
        self.parent.current_experiment = self.listbox_experiments.get('active')
        if not self.parent.data[self.parent.current_experiment].opened:
            self.parent.data[self.parent.current_experiment].Pkl_load()
            self.parent.data[self.parent.current_experiment].opened = True


        #disable the upper buttons to prevent multiple frames
        self.button_new.config(state='disabled')
        self.button_open.config(state='disabled')
        self.listbox_experiments.config(state='disabled')
        self.listbox_experiments.unbind('<Return>')
        self.listbox_experiments.unbind('<F5>')
 
        #makes new frame for popup series
        self.frame_series = tk.Frame(self)

        #button to close and save series section
        self.button_save = ttk.Button(self.frame_series, text='Save & Close', command=Save)
        self.button_save.pack(side='top')

        #button to update file lists
        self.button_refresh = ttk.Button(self.frame_series, text='Refresh files', command=Refresh)
        self.button_refresh.pack(side='top')
        
        #add label
        self.label_series = tk.Label(self.frame_series,  text='Series', bd=5)
        self.label_series.pack(side='top')
        
        #add listbox
        self.listbox_series = tk.Listbox(self.frame_series, exportselection=0, bd=5, relief='flat')
        self.listbox_series.pack(side='top', fill='y')
        self.listbox_series.bind('<Return>', Select)
        #fill listbox
        for series in sorted(self.parent.data[self.parent.current_experiment].series):
            self.listbox_series.insert('end', series)
        self.listbox_series.focus()
        
        #add buttons
        self.button_select = ttk.Button(self.frame_series, text='Select', command=Select)
        self.button_select.pack(side='top')

        #pack popdown frame
        self.frame_series.pack(side='top')

        

class Frame_traces(tk.Frame):
    '''The frame for selecting traces and fits to display on plot'''
    def __init__(self, parent):
        '''makes the subframe and fills it up'''
        tk.Frame.__init__(self, parent, bd=5)
        self.pack(side='left', fill='y')

        #reference to parent
        self.parent = parent

        #load widgets
        self.Widgets()
        #flag to keep track if frame is already in use
        self.enabled = False

    def Widgets(self):
        '''Puts all the widgets on the frame'''
        #add label
        self.label_traces = tk.Label(self, text='Traces', state='disabled')
        self.label_traces.pack(side='top')
        
        #add listbox
        self.listbox_traces = tk.Listbox(self, exportselection=0, bd=5, height=30,
                                        relief='flat', state='disabled')
        self.listbox_traces.pack(side='top',fill='y')
        self.listbox_traces.bind('<Return>', self.Edit)

        #adds button to frame
        self.button_show = ttk.Button(self, text='Edit', command=self.Edit, state='disabled')
        self.button_show.pack(side='top')
        self.button_delete = ttk.Button(self, text='Plot', command=self.Plot,
                                        state='disabled')
        self.button_delete.pack(side='top')
        self.button_new = ttk.Button(self, text='New', command=self.New, state='disabled')
        self.button_new.pack(side='top')

    def Enable(self):
        '''Enables the items in the frame'''
        if not self.enabled:
            for child in self.winfo_children():
                child.config(state='normal')
        self.enabled = True

    def Disable(self):
        '''Disables all items in the frame'''
        if self.enabled:
            for child in self.winfo_children():
                child.config(state='disabled')
        self.enabled = False

    def Load_series(self):
        '''Actions on selection of a series'''
        self.Enable()
        self.Clear()
        for key in sorted(self.parent.data[self.parent.current_experiment].series[self.parent.current_series].keys):
            self.listbox_traces.insert('end', key)
        self.listbox_traces.focus()
        
            
    def Clear(self):
        '''Cleanup actions to do when another series is opened, or experiment is closed'''
        self.listbox_traces.delete(0, 'end')


    def Edit(self, event=None):
        '''Displayes the temperature tab of the trace and allows analysis'''
        self.parent.current_trace = self.listbox_traces.get('active')
        self.parent.temperatures.Load_trace()

    def Plot(self):
        '''Opens a frame with T1vT plot ...'''

        #disable Temperatures frame
        self.parent.temperatures.Disable()
        #disable interfering buttons
        self.button_show.config(state='disabled')
        #save selected trace
        self.parent.current_trace = self.listbox_traces.get('active')
        #T1 analysis
        if self.parent.current_series == "T1vT":
##            try:
##                if self.parent.plot_t1_t1vt.counter > 0:
##                    self.parent.plot_t1_t1vt.Add_trace(self.parent.data[self.parent.current_experiment].series[self.parent.current_series].traces[self.parent.current_trace])
##            except:
            self.parent.plot_t1_t1vt = Frame_plot_T1_t1vt(self.parent, self.parent.data[self.parent.current_experiment].series[self.parent.current_series].traces[self.parent.current_trace])
            self.parent.plot_t1_t1vt.Add_trace(self.parent.data[self.parent.current_experiment].series[self.parent.current_series].traces[self.parent.current_trace])        
        elif self.parent.current_series == "T2vT":
            self.parent.plot_t2_t2vt = Frame_plot_T2_t2vt(self.parent, self.parent.data[self.parent.current_experiment].series[self.parent.current_series].traces[self.parent.current_trace])
            self.parent.plot_t2_t2vt.Add_trace(self.parent.data[self.parent.current_experiment].series[self.parent.current_series].traces[self.parent.current_trace])        
        elif self.parent.current_series == "Spectrum":
            self.parent.plot_spc_frvt = Frame_plot_spc_frvt(self.parent, self.parent.data[self.parent.current_experiment].series[self.parent.current_series].traces[self.parent.current_trace])
            self.parent.plot_spc_frvt.Add_trace(self.parent.data[self.parent.current_experiment].series[self.parent.current_series].traces[self.parent.current_trace])        


    def New(self):
        Error_incomplete()
        plt.figure(figsize=(8,6))
        plt.plot([1,2,3,4,5,6,7], color=colors[1])
        plt.title("Fids")
        plt.xlabel("t (index)")
        plt.ylabel("signal")
        plt.grid()
        #print the plot
        plt.show()

    def Edit_set(self):
        '''Changes to single selection in the trace listbox and enabled edit button'''
        Error_incomplete()

    def Plot_set(self):
        '''Changes to multiple selection to allow plotting of several traces'''
        Error_incomplete()
        

class Frame_temperatures(tk.Frame):
    '''The frame for selecting traces and fits to display on plot'''
    def __init__(self, parent):
        '''makes the subframe and fills it up'''
        tk.Frame.__init__(self, parent, bd=5)
        self.pack(side='left', fill ='y')

        #reference to parent
        self.parent = parent

        #load widgets
        self.Widgets()

        #flag to keep track if frame is already in use
        self.enabled = False
        self.wait = tk.BooleanVar(master=self, value=False)

        #memory of selected params
        self.previous_t1 = GLOBAL_t1_default_params
        self.previous_t2 = GLOBAL_t2_default_params
        self.previous_spc = GLOBAL_spc_default_params

    def Analyze_fid(self, trace):
        '''gets the (T1) trace class and runs the analysis and plotting functions'''
        #T1 analysis
        if self.parent.current_series == "T1vT":
            if trace.analysed:
                #skip to reviewing
                self.parent.plot_t1_view = Frame_plot_T1_view(self.parent, trace, root)
                self.wait.set(False)
            else:
                #run analysis
                self.parent.plot_t1_quick = Frame_plot_T1_quick(self.parent, trace, root)
        elif self.parent.current_series == "T2vT":
            if trace.analysed:
                #skip to reviewing
                self.parent.plot_t2_view = Frame_plot_T2_view(self.parent, trace, root)
                self.wait.set(False)
            else:
                #run analysis
                self.parent.plot_t2_quick = Frame_plot_T2_quick(self.parent, trace, root)
        elif self.parent.current_series == "Spectrum":
            if trace.analysed:
                #skip to reviewing
                self.parent.plot_spc_view = Frame_plot_spc_view(self.parent, trace, root)
                self.wait.set(False)
            else:
                #run analysis
                self.parent.plot_spc_quick = Frame_plot_spc_quick(self.parent, trace, root)
        else:
            Error_incomplete()
            self.parent.temperatures.wait.set(False)
            self.button_show.config(state='normal')
            self.parent.traces.button_show.config(state='normal')
            #refresh the temperatures tab
            self.parent.temperatures.Load_trace()
            
    def Widgets(self):
        '''Puts all the widgets on the frame'''
        #button functions
        def Show(action=None):
            '''Opens analysis window for selected temperatures'''
            #disable buttons that could interrupt loop
            self.button_show.config(state='disabled')
            self.parent.traces.button_show.config(state='disabled')
            #run analysis loop
            for select in self.listbox_temperatures.curselection():
                temp = self.listbox_temperatures.get(select)
                self.wait.set(True)
                self.Analyze_fid(self.parent.data[self.parent.current_experiment].series[self.parent.current_series].traces[self.parent.current_trace][temp])
                #wait untill the analysis is finished before continuing the loop!
                root.wait_variable(self.wait)
            #reenable buttons
            self.button_show.config(state='normal')
            self.parent.traces.button_show.config(state='normal')
            #refresh the temperatures tab
            self.parent.temperatures.Load_trace()
       
        def Delete():
            '''Deletes the reference to the selected temperatures'''
            #loop over selected files
            for select in self.listbox_temperatures.curselection():
                temp = self.listbox_temperatures.get(select)
                self.parent.data[self.parent.current_experiment].series[self.parent.current_series].traces[self.parent.current_trace].pop(temp, None)

            #refresh list
            self.Load_trace()

        def Deselect(action=None):
            '''Deselects the active entries in listbox'''
            self.listbox_temperatures.selection_clear(0,'end')
    
        #add label
        self.label_temperatures = tk.Label(self,  text='Temperatures', state='disabled')
        self.label_temperatures.pack(side='top')

        #listbox frame
        self.frame_listbox = tk.Frame(self)
        self.frame_listbox.pack(side='top', fill='y')
        #add listbox
        self.listbox_temperatures = tk.Listbox(self.frame_listbox, selectmode='extended', exportselection=0,
                                               bd=5, relief='flat', state='disabled', height=30)
        self.listbox_temperatures.pack(side='left',fill='y')
        #keybinds for listbox
        self.listbox_temperatures.bind('<Return>', Show)
        self.listbox_temperatures.bind('<Escape>', Deselect)

        #add scrollbar
        self.scrollbar_listbox = ttk.Scrollbar(self.frame_listbox, orient='vertical')
        self.scrollbar_listbox.config(command=self.listbox_temperatures.yview)
        self.scrollbar_listbox.pack(side='right',fill='y')
        self.listbox_temperatures.config(yscrollcommand=self.scrollbar_listbox.set)

        #adds button to frame
        self.button_show = ttk.Button(self, text='Show', command=Show, state='disabled')
        self.button_show.pack(side='top')
        self.button_deselect = ttk.Button(self, text='Deselect', command=Deselect,
                                        state='disabled')
        self.button_deselect.pack(side='top')
        self.button_delete = ttk.Button(self, text='Delete', command=Delete, state='disabled')
        self.button_delete.pack(side='top')

    def Enable(self):
        '''Enables the items in the frame'''
        if not self.enabled:
            for child in self.winfo_children():
                try:
                    child.config(state='normal')
                except: pass
            self.listbox_temperatures.config(state='normal')
        self.enabled = True

    def Disable(self):
        '''disables the items in the frame'''
        if self.enabled:
            for child in self.winfo_children():
                try:
                    child.config(state='disabled')
                except: pass
            self.listbox_temperatures.config(state='disabled')
        self.enabled = False
        
    def Load_trace(self):
        '''Actions on selection of editing a trace'''
        if self.enabled:
            self.Clear()
        elif not self.enabled:
            self.Enable()
        self.Clear()
        for temp in sorted(self.parent.data[self.parent.current_experiment].series[self.parent.current_series].traces[self.parent.current_trace]):
            self.listbox_temperatures.insert('end', temp)
        self.listbox_temperatures.focus()

        for i, temp in enumerate(self.listbox_temperatures.get(0, 'end')):
            if self.parent.data[self.parent.current_experiment].series[self.parent.current_series].traces[self.parent.current_trace][temp].analysed:
                self.listbox_temperatures.itemconfig(i, bg='pale green',
                                                     selectbackground='dark green')
            #try:
            if self.parent.data[self.parent.current_experiment].series[self.parent.current_series].traces[self.parent.current_trace][temp].disabled:
                self.listbox_temperatures.itemconfig(i, bg='light salmon',
                                                     selectbackground='red')
            #except: pass

    def Clear(self):
        '''Cleanup actions to do when another temp is opened, or experiment is closed'''
        self.listbox_temperatures.delete(0, 'end')
   
class Main_application(tk.Frame):
    '''Main application calling all the sub sections'''
    def __init__(self, parent, *args, **kwargs):
        '''Initializes the main application as a frame in tkinter'''
        #check for computers screen resolution
        width_px = root.winfo_screenwidth()
        height_px = root.winfo_screenheight()
        if width_px < 1720:
            self.Warn_resolution()
        
        tk.Frame.__init__(self, parent, height=1020, width =1720, *args, **kwargs)
        self.parent = parent
        # sets the window title
        self.parent.wm_title('NMR data analysis and overview')
        #sets the window minimal size
        self.parent.minsize(width=1880, height=770)
        # allow editing the exit command
        self.parent.protocol('WM_DELETE_WINDOW', self.On_close)
        #makes the window strechable
        self.pack(fill='both', expand=True)
        self.pack()

        #place to save Experiment_data classes
        self.Open_data()
        
        #calls subframes and packs them
        self.Sub_frames()

    def Open_data(self):
        '''Opens all experiments from folders data subdirectory'''
        self.data = dict()

        #adds the existing experiments
        if os.path.isdir('data'):
            for entry in os.scandir('data'):
                if entry.is_dir():  
                    #initiates a dict of the experiment data classes
                    self.data[entry.name] = Experiment_data(entry.name)
        #makes the raw experiment folder
        else:
            msg = 'The current directory does not contain the correct file structure.' \
                  '\nCreate new folders in current directory?'
            if tk.messagebox.askyesno('No data in current directory', msg):
                os.mkdir('data')
        

    def Sub_frames(self):
        '''Creates all the subframes and positions them'''
        #first column
        self.experiments = Frame_experiments(self)
        #self.experiments.pack(side='left', fill='y')

        #second column
        self.traces = Frame_traces(self)
        #self.traces.pack(side='left', fill='y')

        #3rd column
        self.temperatures = Frame_temperatures(self)
        #self.temperatures.pack(side='left', fill ='y')

        ## construct it every time instead (to avoid memory problems)
        #4th column, plotter
        class Tracer():
            pass
        #self.plot1 = Frame_plot_T1_view(self, Tracer)
        #temporary pack
        #self.plot1.pack(side='left', fill='both', expand=True)

    def On_close(self):
        '''Actions to execute when the master window is closed with ('X')'''
        msg = 'Are you sure you want to close the program?\n' \
              'Unsaved data will be lost!'
        if tk.messagebox.askokcancel('Quit', msg):
            #close all plots and figures
            plt.close('all')
            self.parent.destroy()

    def Warn_resolution(self):
        '''Warns the user that the resolution of the program is not optimal for the monitor'''
        msg = 'The resolution of the program is larger than the resolution of the monitor!\n' \
              'The program might not function or appear properly!'
        tk.messagebox.showerror('Error', msg)
        #implement parameters for smaller figure sizes to account for smaller resolution!!
        
def Error_incomplete():
    '''Lets user know that the content doesnt exist yet'''
    tk.messagebox.showerror('Error', 'The function is not yet implemented!')
        
def Quit_program():
    '''destroys root and quits the tkinter'''
    root.destroy()
    
if __name__ == '__main__':
    '''Initializes tkinter and main application if this is a standalone file'''
    root = tk.Tk()   
    Main_application(root)
    root.mainloop()


