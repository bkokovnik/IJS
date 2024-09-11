from nmr_gui_imports_and_parameters import *

class Frame_plot_spc_quick(tk.Frame):
    '''Quick settings for spectrum gluing'''
    def __init__(self, parent, trace, root):
        '''makes the subframe and fills it up'''
        tk.Frame.__init__(self, parent, bd=5)
        self.pack(side='left', fill='both', expand=True)
        
        #reference to parent
        self.parent = parent
        #reference to current trace:
        self.trace = trace

        #starting data
        self.shl = self.parent.temperatures.previous_spc['shl_start']
        self.mirroring = self.parent.temperatures.previous_spc['mirroring']
        self.offset_select = self.parent.temperatures.previous_spc['offset'][0]

        #load widgets
        self.Widgets()

        #run quick t1
        quick_tables = trace.Quick_spc()
        self.Fill_plots(*quick_tables)

        #take focus away from listbox
        self.focus()
        #global key binds
        self.root = root
        self.root.bind('<Left>', self.Interrupt)
        self.root.bind('<Right>', self.Confirm)


    def Confirm(self, event=None):
        '''Saves shl, disables its selection and plots phases'''
        #disable shl setters
        self.entry_shl.config(state='disabled')
        self.button_set_shl.config(state='disabled')
        self.check_mirroring.config(state='disabled')
        self.button_confirm_shl.config(state='disabled')
        self.entry_offset.config(state='disabled')
        self.button_set_offset.config(state='disabled')
        #disconnect drag events
        self.fig_left2.canvas.mpl_disconnect(self.axes_left2_vline_drag)
        self.fig_right1.canvas.mpl_disconnect(self.axes_right1_hline_drag)

        #enable confirm button
        self.button_confirm.config(state='enabled')
        self.entry_k.config(state='enabled')
        self.entry_n.config(state='enabled')
        self.button_fit.config(state='enabled')

        #remember shl
        self.mean_shl = self.shl
        self.trace.mean_shl = self.shl
        self.parent.temperatures.previous_spc['shl_start']=self.shl
        
        #remember offset
        self.trace.offset_range = (self.offset_select, None)
        self.parent.temperatures.previous_spc['offset'] = (self.offset_select, None)
        
        #remember mirroring
        self.trace.mirroring = self.check_mirroring_var.get()
        self.parent.temperatures.previous_spc['mirroring'] = self.check_mirroring_var.get()


        self.trace.Get_phase(self.shl, (self.offset_select,None),
                             (self.fit_range_l_var.get(), self.fit_range_r_var.get())
                             )

        
        #update entry values
        self.entry_k_var.set('%.4g' %self.trace.phase_fit_p[0])
        self.entry_n_var.set('%.4g' %self.trace.phase_fit_p[1])


        #plot 4 phase
        self.axes_right2 = self.fig_right2.add_subplot(111)
        self.axes_right2.plot(self.trace.fr_list, np.unwrap(self.trace.phase_list, 0.5*np.pi), marker='.',
                             color=colors[1], label='SHL')
        self.axes_right2_line2, = self.axes_right2.plot(self.trace.fr_list, self.trace.phase_fit,
                                                        color=colors[2], label='linear fit')
        self.axes_vline_l = self.axes_right2.axvline(x=self.trace.fr_list[self.fit_range_l_var.get()], color=colors[4])
        self.axes_vline_r = self.axes_right2.axvline(x=self.trace.fr_list[self.fit_range_r_var.get()-1], color=colors[4])
        self.axes_right2.margins(0.02, 0.1)
        self.axes_right2.set_title('Phase check')
        self.axes_right2.set_xlabel('Frequency (MHz)')
        self.axes_right2.set_ylabel('Phase')
        #self.axes_right2.legend(loc='lower right')
        self.axes_right2.grid()
        self.fig_right2.canvas.draw()

        def Drag(event):
            '''Allows dragging of the markers for fit range on spectrum plot'''
            if event.button == 1 and event.inaxes != None:
                #find the index of selected points
                self.fit_range_l_var.set(np.searchsorted(self.trace.fr_list, event.xdata, side='right'))
                #print(self.fit_range_l_var.get())
                #self.range_l_select = int(event.xdata)
                #update plot
                self.axes_vline_l.set_xdata(event.xdata)
                self.fig_right2.canvas.draw()

            if event.button == 3 and event.inaxes != None:
                #find the index of selected points
                self.fit_range_r_var.set(np.searchsorted(self.trace.fr_list, event.xdata, side='left'))
                #print(self.fit_range_r_var.get())
                #self.range_r_select = int(event.xdata)
                #update plot
                self.axes_vline_r.set_xdata(event.xdata)
                self.fig_right2.canvas.draw()

        self.axes_vline_drag = self.fig_right2.canvas.mpl_connect('motion_notify_event', Drag)

        self.root.bind('<Right>', self.Finish)


        
    def Finish(self, event=None):
        '''Accepts the data on this screen and closes it up'''      

        #hide this frame
        self.pack_forget()
        #close plots
        plt.close('all')
        #forget global key bind
        self.root.unbind('<Right>')
        self.root.unbind('<Left>')

        #run next frame
        self.parent.plot_spc_ranges = Frame_plot_spc_ranges(self.parent, self.trace, self.root)

    def Interrupt(self, event=None):
        '''Stops the analysis loop'''
        #Destroy frame and plots
        self.pack_forget()
        self.destroy()
        plt.close('all')
        #unbind global keys
        self.root.unbind('<Right>')
        self.root.unbind('<Left>')

        #stop the analysis loop
        self.parent.temperatures.wait.set(False)

    def Refit(self, event=None):
        '''manual fit, change k, n values'''

##        #manual version
##        k = float(self.entry_k_var.get())
##        n = float(self.entry_n_var.get())
##        x = np.array(self.trace.fr_list)
##        y = k*x+n
##        self.axes_right2_line2.set_ydata(y)
##
##        self.fig_right2.canvas.draw()
##
##        self.trace.phase_fit_p = [k, n]
##        self.trace.phase_fir = y

        #refit using new fit range
        self.trace.Get_phase(self.shl, (self.offset_select,None),
                             (self.fit_range_l_var.get(), self.fit_range_r_var.get())
                             )

        self.axes_right2_line2.set_ydata(self.trace.phase_fit)
        self.fig_right2.canvas.draw()

        self.entry_k_var.set('%.4g' %self.trace.phase_fit_p[0])
        self.entry_n_var.set('%.4g' %self.trace.phase_fit_p[1])


    def Widgets(self):
        '''Builds all the subframes and canvases'''

        def Set_shl(event=None):
            '''Entry chang eof shl, replot with new value'''
            try:
                self.shl = int(self.entry_shl.get())
                #update plots
                self.axes_left2_vline.set_xdata(self.shl)
                self.axes_right1_hline.set_ydata(self.shl)
                self.fig_left2.canvas.draw()
                self.fig_right1.canvas.draw()
            except ValueError:
                tk.messagebox.showerror('Error', 'The inserted value must be integer!')

        def Set_offset(event=None):
            '''Entry change of offset select, replot with new value'''
            try:
                self.offset_select = int(self.entry_offset.get())
                #update plots
                self.axes_left2_vline_offset.set_xdata(self.offset_select)
                self.fig_left2.canvas.draw()

            except ValueError:
                tk.messagebox.showerror('Error', 'The inserted value must be integer!')
        
        #split in two half frames
        self.frame_left = tk.Frame(self)
        self.frame_right = tk.Frame(self)
        self.frame_left.pack(side='left', fill='y')
        self.frame_right.pack(side='left', fill='y')

        #add frames on left side
        self.frame_left1 = tk.Frame(self.frame_left, bd=5)
        self.frame_left2 = tk.Frame(self.frame_left, bd=5)
        self.frame_left3 = tk.Frame(self.frame_left, bd=5)
        self.frame_left1.pack(side='top')
        self.frame_left2.pack(side='top')
        self.frame_left3.pack(side='top', fill='x')
        #add frames on right side
        self.frame_right1 = tk.Frame(self.frame_right, bd=5)
        self.frame_right2 = tk.Frame(self.frame_right, bd=5)
        self.frame_right3 = tk.Frame(self.frame_right, bd=5)
        self.frame_right4 = tk.Frame(self.frame_right, bd=5)
        self.frame_right1.pack(side='top')
        self.frame_right2.pack(side='top', fill='x')
        self.frame_right3.pack(side='top')
        self.frame_right4.pack(side='top', fill='x')

        

        #add canvases and toolbars
        #plot 1
        self.fig_left1 = plt.figure(dpi=100, figsize=(7,2.5))
        self.fig_left1.subplots_adjust(bottom=0.20, left= 0.12, right=0.96, top=0.88)
        self.fig_left1.suptitle(self.trace.file_key, x=0.01, horizontalalignment='left')
        self.canvas_left1 = FigureCanvasTkAgg(self.fig_left1, self.frame_left1)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_left1, self.frame_left1)
        self.canvas_left1._tkcanvas.pack()

        #plot 2
        self.fig_left2 = plt.figure(dpi=100, figsize=(7,4.5))
        self.fig_left2.subplots_adjust(bottom=0.15, left= 0.12, right=0.96, top=0.9)
        self.canvas_left2 = FigureCanvasTkAgg(self.fig_left2, self.frame_left2)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_left2, self.frame_left2)
        self.canvas_left2._tkcanvas.pack()
        
        #interrupt button
        self.button_interrupt = ttk.Button(self.frame_left3, text='Interrupt', command=self.Interrupt)
        self.button_interrupt.pack(side='left', anchor='w')

        #confirm shl selection, jump to phase
        self.button_confirm_shl = ttk.Button(self.frame_left3, text='Confirm', command=self.Confirm)
        self.button_confirm_shl.pack(side='right', anchor='e')
        
        #check button for mirroring fid
        self.check_mirroring_var = tk.BooleanVar(self, False)
        if self.mirroring:
            self.check_mirroring_var.set(True)
            
        self.check_mirroring = (ttk.Checkbutton(self.frame_left3, variable=self.check_mirroring_var))
        self.check_mirroring.pack(side='right')
        
        self.label_mirroring = tk.Label(self.frame_left3,  text='Mirroring')
        self.label_mirroring.pack(side='right')

        #label and edit of mean_range
        self.frame_left3_middle = tk.Frame(self.frame_left3)
        self.frame_left3_middle.pack(anchor='center')

        self.label_offset = tk.Label(self.frame_left3_middle,  text='Chosen offset range:')
        self.label_offset.pack(side='left')

        self.entry_offset_var = tk.StringVar(self, value=self.offset_select)
        self.entry_offset = ttk.Entry(self.frame_left3_middle,
                                    textvariable=self.entry_offset_var, width=4)
        self.entry_offset.pack(side='left')
        self.entry_offset.bind('<Return>', Set_offset)

        self.button_set_offset = ttk.Button(self.frame_left3_middle, text='Set offset', command=Set_offset)
        self.button_set_offset.pack(side='left')

        #plot 3
        self.fig_right1 = plt.figure(dpi=100, figsize=(7,2.5))
        self.fig_right1.subplots_adjust(bottom=0.20, left= 0.12, right=0.96, top=0.88)
        self.canvas_right1 = FigureCanvasTkAgg(self.fig_right1, self.frame_right1)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_right1, self.frame_right1)
        self.canvas_right1._tkcanvas.pack()

        #label and edit of shl select
        self.frame_right2_middle = tk.Frame(self.frame_right2)
        self.frame_right2_middle.pack(anchor='center')

        self.label_shl = tk.Label(self.frame_right2_middle,  text='Chosen shl:')
        self.label_shl.pack(side='left')

        self.entry_shl_var = tk.StringVar(self, value=self.shl)
        self.entry_shl = ttk.Entry(self.frame_right2_middle,
                                    textvariable=self.entry_shl_var, width=4)
        self.entry_shl.pack(side='left')
        self.entry_shl.bind('<Return>', Set_shl)

        self.button_set_shl = ttk.Button(self.frame_right2_middle, text='Set SHL', command=Set_shl)
        self.button_set_shl.pack(side='left')



        #plot 4
        self.fig_right2 = plt.figure(dpi=100, figsize=(7,4))
        self.fig_right2.subplots_adjust(bottom=0.15, left= 0.10, right=0.96, top=0.9)
        self.canvas_right2 = FigureCanvasTkAgg(self.fig_right2, self.frame_right3)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_right2, self.frame_right2)
        self.canvas_right2._tkcanvas.pack()

        #entries for phase fit (lin)
        self.label_k = tk.Label(self.frame_right4, text='k:')
        self.label_k.pack(side='left')

        self.entry_k_var = tk.StringVar(self, value=None)
        self.entry_k = ttk.Entry(self.frame_right4, textvariable=self.entry_k_var, width=6, state='disabled')
        self.entry_k.pack(side='left')

        self.label_n = tk.Label(self.frame_right4, text='n:')
        self.label_n.pack(side='left')

        self.entry_n_var = tk.StringVar(self, value=None)
        self.entry_n = ttk.Entry(self.frame_right4, textvariable=self.entry_n_var, width=6, state='disabled')
        self.entry_n.pack(side='left')

        self.button_fit = ttk.Button(self.frame_right4, text='Refit', command=self.Refit, state='disabled')
        self.button_fit.pack(side='left')

        #add button to confirm selection
        self.button_confirm = ttk.Button(self.frame_right4, text='Confirm', command=self.Finish, state='disabled')
        self.button_confirm.pack(side='right')


        #fitting range variables for phase fit
        self.fit_range_l_var = tk.IntVar(self, value=0)
        self.fit_range_r_var = tk.IntVar(self, value=-1)
        try:
            self.fit_range_l_var.set(self.trace.fit_range[0])
            self.fit_range_r_var.set(self.trace.fit_range[1])
        except:
            pass

       

    def Fill_plots(self, temp_list, temp_list2, temp_set, fr_list, shl_list):
        '''Puts the contents into the plot fields'''
        #starting values
        self.mean_shl = np.mean(shl_list)

        #x axes
        n = len(fr_list)
        x_list = np.linspace(1,n,n)

        #fids
        fids = list()
        for file in self.trace.file_list:
            fid = FID(file, self.trace.file_dir)
            fids.append(fid.x)
        
        #plot 1, temperature stabillity    
        self.axes_left1 = self.fig_left1.add_subplot(111)
        try:
            if abs(np.mean(temp_list) - temp_set) < 2:
                self.axes_left1.plot(x_list, temp_list, marker='.', color=colors[1], label='ITC_R1')
            if abs(np.mean(temp_list2) - temp_set) < 2:
                self.axes_left1.plot(x_list, temp_list2, marker='.', color=colors[2], label='ITC_R2')
        except: pass
        self.axes_left1.axhline(y=temp_set, color=colors[0], label='Set T')
        self.axes_left1.margins(0.02, 0.1)
        self.axes_left1.set_title('Temperature stabillity check')
        self.axes_left1.set_xlabel('File index')
        self.axes_left1.set_ylabel('Temperature (K)')
        self.axes_left1.legend(loc='upper right')
        self.axes_left1.grid()

        #plot 2
        self.axes_left2 = self.fig_left2.add_subplot(111)
        for i, fid in enumerate(fids):
            self.axes_left2.plot(np.abs(fid)+np.amax(np.abs(fids))*0.5*i,
                                 color=colors[i%9], label=str(i))
        self.axes_left2_vline = self.axes_left2.axvline(x=self.shl,
                                                        color=colors[0], label='Select')
        self.axes_left2_vline_offset = self.axes_left2.axvline(x=self.offset_select,
                                                        color=colors[2], label='Offset Select')
        self.axes_left2.set_title('offset range select')
        self.axes_left2.set_xlabel('Time, (A.U.)')
        self.axes_left2.set_ylabel('Signal')
        #legend = self.axes_left2.legend(loc='lower right')
        #legend.draggable()
        self.axes_left2.grid()
        
        #plot 3
        self.axes_right1 = self.fig_right1.add_subplot(111)
        self.axes_right1.plot(x_list, shl_list, marker='.',
                             color=colors[1], label='SHL')
        self.axes_right1_hline = self.axes_right1.axhline(self.shl,
                                                          color=colors[0], label='Mean SHL')
        self.axes_right1.margins(0.02, 0.1)
        self.axes_right1.set_title('SHL select')
        self.axes_right1.set_xlabel('File index')
        self.axes_right1.set_ylabel('Shift left')
        #self.axes_right1.legend(loc='lower right')
        self.axes_right1.grid()

        #redraw canvases
        self.fig_left1.canvas.draw()
        self.fig_left2.canvas.draw()
        self.fig_right1.canvas.draw()
        

        #draggable vline event
        def Drag(event):
            '''Allows dragging of the marker in left2, redraws the line on right'''
            if event.button == 3 and event.inaxes != None:
                #find the index of selected points
                self.offset_select = int(event.xdata)
                self.entry_offset_var.set(self.offset_select)
                #update plot
                self.axes_left2_vline_offset.set_xdata(event.xdata)
                self.fig_left2.canvas.draw()

        #draggable vline event
        def Drag_shl(event):
            '''Allows dragging of the marker in left2, redraws the line on right'''
            if event.button == 1 and event.inaxes != None:
                #find the index of selected points
                self.shl = int(event.xdata)
                self.entry_shl_var.set(self.shl)
                #update plot
                self.axes_left2_vline.set_xdata(self.shl)
                self.axes_right1_hline.set_ydata(self.shl)
                self.fig_left2.canvas.draw()
                self.fig_right1.canvas.draw()


        #draggable hline event
        def Drag_shl2(event):
            ''''Allows dragging of the marker in right1, redraws shl lines'''
            if event.button == 1 and event.inaxes !=None:
                #find selected index
                self.shl = int(event.ydata)
                self.entry_shl_var.set(self.shl)
                #update plots
                self.axes_left2_vline.set_xdata(self.shl)
                self.axes_right1_hline.set_ydata(event.ydata)
                self.fig_left2.canvas.draw()
                self.fig_right1.canvas.draw()
                

        self.axes_left2_vline_drag = self.fig_left2.canvas.mpl_connect('motion_notify_event', Drag)
        self.axes_left2_vline_drag = self.fig_left2.canvas.mpl_connect('motion_notify_event', Drag_shl)
        self.axes_right1_hline_drag = self.fig_right1.canvas.mpl_connect('motion_notify_event', Drag_shl2)


class Frame_plot_spc_ranges(tk.Frame):
    '''Pioneer first preview plot'''
    def __init__(self, parent, trace, root):
        '''makes the subframe and fills it up'''
        tk.Frame.__init__(self, parent, bd=5)
        self.pack(side='left', fill='both', expand=True)
        
        #reference to parent
        self.parent = parent
        #reference to current trace:
        self.trace = trace

        self.range_l_select = self.parent.temperatures.previous_spc['integral_range'][0]
        self.range_r_select = self.parent.temperatures.previous_spc['integral_range'][1]
        
        #load widgets
        self.Widgets()

        #load plots and read
        self.Choose_ranges(trace)

        self.focus()
        #global key bindings
        self.root = root
        self.root.bind('<Left>', self.Previous)
        self.root.bind('<Right>', self.Finish)

        
   

    def Widgets(self):
        '''Builds all the subframes and canvases'''
     
        def Set_offset(event=None):
            '''Entry change of offset, replot and write value'''
            try:
                self.offset_select = int(self.entry_offset.get())
                #update plot
                self.axes_left1_vline.set_xdata(self.offset_select)
                self.axes_left2_vline.set_xdata(self.offset_select)
                self.fig_left1.canvas.draw()
                self.fig_left2.canvas.draw()
            except ValueError:
                tk.messagebox.showerror('Error', 'The inserted values must be integers!')

        def Set_range(event=None):
            '''Entry change of ranges, replot and save value'''
            try:
                self.range_l_select = int(self.entry_range_l_var.get())
                self.range_r_select = int(self.entry_range_r_var.get())
                self.axes_left1_vline_l.set_xdata(self.spc_fr[self.range_l_select])
                self.axes_left2_vline_l.set_xdata(self.spc_fr[self.range_l_select])
                self.axes_left1_vline_r.set_xdata(self.spc_fr[self.range_r_select])
                self.axes_left2_vline_r.set_xdata(self.spc_fr[self.range_r_select])
                self.fig_left1.canvas.draw()
                self.fig_left2.canvas.draw()
            except ValueError:
                tk.messagebox.showerror('Error', 'The inserted values must be integers!')
            

        #split in two half frames
        self.frame_left = tk.Frame(self)
        self.frame_right = tk.Frame(self)
        self.frame_left.pack(side='left', fill='y')
        self.frame_right.pack(side='left', fill='y')

        #add frames on left side
        self.frame_left1 = tk.Frame(self.frame_left, bd=5)
        self.frame_left2 = tk.Frame(self.frame_left, bd=5)
        self.frame_left3 = tk.Frame(self.frame_left, bd=5)
        self.frame_left1.pack(side='top')
        self.frame_left2.pack(side='top')
        self.frame_left3.pack(side='top', fill='x')
        #add frames on right side
        self.frame_right1 = tk.Frame(self.frame_right, bd=5)
        self.frame_right2 = tk.Frame(self.frame_right, bd=5)
        self.frame_right3 = tk.Frame(self.frame_right, bd=5)
        self.frame_right1.pack(side='top')
        self.frame_right2.pack(side='top')
        self.frame_right3.pack(side='top', fill='x')

        #plot 1
        self.fig_left1 = plt.figure(dpi=100, figsize=(7,2.5))
        self.fig_left1.subplots_adjust(bottom=0.20, left= 0.10, right=0.96, top=0.88)
        self.canvas_left1 = FigureCanvasTkAgg(self.fig_left1, self.frame_left1)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_left1, self.frame_left1)
        self.canvas_left1._tkcanvas.pack()

        #plot 2
        self.fig_left2 = plt.figure(dpi=100, figsize=(7,4.5))
        self.fig_left2.subplots_adjust(bottom=0.12, left= 0.10, right=0.96, top=0.93)
        self.canvas_left2 = FigureCanvasTkAgg(self.fig_left2, self.frame_left2)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_left2, self.frame_left2)
        self.canvas_left2._tkcanvas.pack()

        #buttons left
        self.button_previous = ttk.Button(self.frame_left3, text='Repeat previous', command=self.Previous)
        self.button_previous.pack(side='left')

        self.button_confirm = ttk.Button(self.frame_left3, text='Confirm', command=self.Finish)
        self.button_confirm.pack(side='right')

        #middle frame
        self.frame_left3_middle = tk.Frame(self.frame_left3)
        self.frame_left3_middle.pack(anchor='center')

        self.label_range = tk.Label(self.frame_left3_middle,  text='Selected ranges:')
        self.label_range.pack(side='left')
        
        self.entry_range_l_var = tk.StringVar(self, value=self.range_l_select)
        self.entry_range_l = ttk.Entry(self.frame_left3_middle,
                                       textvariable=self.entry_range_l_var, width=5)
        self.entry_range_l.pack(side='left')
        self.entry_range_l.bind('<Return>', Set_range)

        self.label_range_comma = tk.Label(self.frame_left3_middle,  text=' , ')
        self.label_range_comma.pack(side='left')

        self.entry_range_r_var = tk.StringVar(self, value=self.range_r_select)
        self.entry_range_r = ttk.Entry(self.frame_left3_middle,
                                       textvariable=self.entry_range_r_var, width=5)
        self.entry_range_r.pack(side='left')
        self.entry_range_r.bind('<Return>', Set_range)

        self.button_set_range = ttk.Button(self.frame_left3_middle, text='Set range', command=Set_range)
        self.button_set_range.pack(side='left')



    #button commands
    def Previous(self, event=None):
        '''Back to the previous step!'''
        #reload offset
        self.parent.plot_spc_quick.pack(side='left', fill='both', expand=True)
        #destroy me
        self.pack_forget()
        self.destroy()
        #unbind global keys
        self.root.unbind('<Right>')
        self.root.unbind('<Left>')


    def Finish(self, event=None):
        '''Confirm the selection in this screen'''
        #save the integral ranges
        self.trace.integral_range = (self.range_l_select, self.range_r_select)
        self.parent.temperatures.previous_spc['integral_range'] = (self.range_l_select,
                                                                  self.range_r_select)

        #finish the analysis
        self.trace.Run(broaden_width=100, fr_density=100) # used to be 50000. fr_density=10 (default)
        
        #unpack and destroy
        self.trace.analysed = True
        self.parent.plot_spc_quick.destroy()
        self.pack_forget()
        self.destroy()
        plt.close('all')
        #unbind global keys
        self.root.unbind('<Right>')
        self.root.unbind('<Left>')

        #load the overview frame
        self.parent.plot_spc_view = Frame_plot_spc_view(self.parent, self.trace, self.root)


    def Choose_ranges(self, trace):
        '''Operations and plotting for choosing spectrum integral ranges'''
        k = self.trace.phase_fit_p
        spcs = list()
        fr_list = list()
        for i, file in enumerate(trace.file_list):
            fid = FID(file, trace.file_dir)
            fid.Offset(trace.offset_range)
            fid.Shift_left(trace.mean_shl, mirroring=trace.mirroring)
            fid.Fourier()
            fid.Phase_rotate(trace.phase_fit[i])

            spcs.append(fid.spc)
            fr_list.append(fid.parameters['FR'])

        max_spc = np.unravel_index(np.argmax(spcs), (len(spcs),len(spcs[0])))[0]

        self.spc_fr = fid.spc_fr
        spc_mean = spcs[max_spc]
        center = int(len(spc_mean)/2)


        #plot 3
        self.axes_left1 = self.fig_left1.add_subplot(111)
        self.axes_left1.plot(np.real(spc_mean), color=colors[1], label='Re')
        self.axes_left1.plot(np.imag(spc_mean), color=colors[2], label='Im')
        self.axes_left1.axvline(x=center, color=colors[-1])
        self.axes_left1_vline_l = self.axes_left1.axvline(x=self.range_l_select,
                                                            color=colors[4])
        self.axes_left1_vline_r = self.axes_left1.axvline(x=self.range_r_select,
                                                            color=colors[4])
        self.axes_left1.set_xlim((center -200, center +200))
        self.axes_left1.set_title('Mean spectrum (Drag with left and right mouse button)')
        self.axes_left1.set_xlabel('Frequency (MHz)')
        self.axes_left1.set_ylabel('Signal (A.U.)')
        self.axes_left1.legend(loc='upper left')
        self.axes_left1.grid()

        #plot 4
        self.axes_left2 = self.fig_left2.add_subplot(111)
        for i, spc in enumerate(spcs):
            self.axes_left2.plot(np.real(spc)+np.amax(np.abs(spc_mean))*0.5*i,
                                  color=colors[i%9], label=str(i))
        self.axes_left1.axvline(x=center, color=colors[-1])
        self.axes_left2_vline_l = self.axes_left2.axvline(x=self.range_l_select,
                                                            color=colors[4])
        self.axes_left2_vline_r = self.axes_left2.axvline(x=self.range_r_select,
                                                            color=colors[4])
        self.axes_left2.set_xlim((center -200,+ center +200))
        self.axes_left2.margins(0.02, 0.02)
        self.axes_left2.set_title('All FIDs')
        self.axes_left2.set_xlabel('Frequency (MHz)')
        self.axes_left2.set_ylabel('Real part of signal (A.U.)')
        self.axes_left2.grid()

        #draggable vline event
        def Drag(event):
            '''Allows dragging of the marker in left2, recalculates mean of selected points'''
            if event.button == 1 and event.inaxes != None:
                #find the index of selected points
                self.entry_range_l_var.set(int(event.xdata))
                self.range_l_select = int(event.xdata)
                #update plot
                self.axes_left1_vline_l.set_xdata(event.xdata)
                self.axes_left2_vline_l.set_xdata(event.xdata)
                self.fig_left1.canvas.draw()
                self.fig_left2.canvas.draw()

            if event.button == 3 and event.inaxes != None:
                #find the index of selected points
                self.entry_range_r_var.set(int(event.xdata))
                self.range_r_select = int(event.xdata)
                #update plot
                self.axes_left1_vline_r.set_xdata(event.xdata)
                self.axes_left2_vline_r.set_xdata(event.xdata)
                self.fig_left1.canvas.draw()
                self.fig_left2.canvas.draw()

        self.axes_left1_vline_drag = self.fig_left1.canvas.mpl_connect('motion_notify_event', Drag)
        self.axes_left2_vline_drag = self.fig_left2.canvas.mpl_connect('motion_notify_event', Drag)

        self.fig_left1.canvas.draw()
        self.fig_left2.canvas.draw()
        

class Frame_plot_spc_view(tk.Frame):
    '''Pioneer first preview plot'''
    def __init__(self, parent, trace, root):
        '''makes the subframe and fills it up'''
        tk.Frame.__init__(self, parent)
        self.pack(side='left', anchor='n')
        
        #reference to parent
        self.parent = parent
        #reference to current trace:
        self.trace = trace
        
        #load widgets
        self.Widgets()

        #global key bind
        self.root = root
        self.root.bind('<Right>', self.Confirm)

    def Widgets(self):
        '''Builds all the subframes and canvases'''
        #button commands

        def Disable(event=None):
            '''Disables and red-flags the point to avoid plotting'''
            #try:
            self.trace.disabled = not self.trace.disabled
            #except:
            #    self.trace.disabled = True
            self.Refresh_parameters()

        def Repeat(event=None):
            '''Clears the trace and starts the analysis from scratch'''
            self.trace.Reinit()
            self.Confirm()
            self.trace.analysed = False

            
        #bottom button row
        self.frame_bottom = tk.Frame(self)
        self.frame_bottom.pack(side='bottom', fill='x')
        #split in columns
        self.frame_parameters = tk.Frame(self, bd=5)
        self.frame_parameters.pack(side='left', anchor='n')
        self.frame_plot = tk.Frame(self, bd=5)
        self.frame_plot.pack(side='left', anchor='n')
        self.frame_fit = tk.Frame(self, bd=5)
        self.frame_fit.pack(side='left', anchor='n', fill='y')


        #parameters
        self.label_parameters = tk.Label(self.frame_parameters,  text='Parameters')
        self.label_parameters.pack(side='top')

        self.tree_columns = ('Name','Value')
        self.tree_parameters = ttk.Treeview(self.frame_parameters, columns=self.tree_columns,
                                            show='headings', selectmode='none', height=25)
        self.tree_parameters.pack(side='top',fill='y', expand=True)

        #define column widths
        self.tree_parameters.column('Name', width=80)
        self.tree_parameters.column('Value', width=120)
        #define column names
        for column in self.tree_columns:
            self.tree_parameters.heading(column, text=column)
        #display in degrees
        #fill in params
        self.Refresh_parameters()
        
        # disable point button
        self.button_disable = ttk.Button(self.frame_parameters, text='Disable/enable Point',
                                         command=Disable, width=20)
        self.button_disable.pack(side='top')
        #redo analysis button
        self.button_repeat = ttk.Button(self.frame_parameters, text='Repeat analysis',
                                        command=Repeat, width=20)
        self.button_repeat.pack(side='top')

        #point plot
        self.fig_spc = plt.figure(dpi=100, figsize=(8,3))
        self.fig_spc.subplots_adjust(bottom=0.15, left= 0.10, right=0.96, top=0.92)
        self.fig_spc.suptitle(self.trace.file_key, x=0.01, horizontalalignment='left')


        self.canvas_spc = FigureCanvasTkAgg(self.fig_spc, self.frame_plot)
        self.canvas_spc._tkcanvas.pack()

        #glue plot
        self.fig_glue = plt.figure(dpi=100, figsize=(8,4))
        self.fig_glue.subplots_adjust(bottom=0.15, left= 0.10, right=0.96, top=0.92)

        self.canvas_glue = FigureCanvasTkAgg(self.fig_glue, self.frame_plot)
        self.canvas_glue._tkcanvas.pack()

        #fitting range variables
        self.fit_range_l_var = tk.IntVar(self, value=0)
        self.fit_range_r_var = tk.IntVar(self, value=len(self.trace.fr_list))
        try:
            self.fit_range_l_var.set(self.trace.fit_range[0])
            self.fit_range_r_var.set(self.trace.fit_range[1])
        except:
            pass

        self.Fill_plot()
        self.Fitting_frame()
        

##        #add button to confirm selection
##        self.button_confirm = ttk.Button(self.frame_bottom, text='Confirm', command=self.Confirm)
##        self.button_confirm.pack(side='right')
##        self.button_confirm.bind('<Return>', self.Confirm)
##  
##        #add button to export spectra
##        self.button_confirm = ttk.Button(self.frame_bottom, text='Export CSV', command=self.Export)
##        self.button_confirm.pack(side='right')

    def Fitting_frame(self, event=None):
        '''Repacks/initializes the fitting frame for the selected fitting function'''

        #repack if existing:
        try:
            self.frame_fit.destroy()
        except:
            pass
        #fit frame
        self.frame_fit = tk.Frame(self, bd=5)
        self.frame_fit.pack(side='left', anchor='n', fill='y')

        #fit functions
        def Fit_lorentz(x, x0=0, a=500, g=1000):
            '''Lorentzian lineshape model'''
            return a*g/np.pi/(g**2 + (x-x0)**2)

        def Asym(x, x0, c):
            '''The smoothened function used to assymetrise'''
            b = 10
            return np.abs(c)/(1+np.exp((x-x0)*np.sign(c)*b))+1

        def Fit_lorentz_asymmetric(x, x0=0, a=500, g=1000, c=0.2):
            '''Lorentzian lineshape model with asymmetry'''
            ga = g*Asym(x, x0, c)
            aa = a*Asym(x, x0, c)
            return aa*ga/np.pi/(ga**2 + (x-x0)**2)

##        def Fit_lorentz_asymmetric(x, x0=0, a=500, g=1000, b=1, c=0):
##            '''Lorentzian with fermi changing linewidth for asymmetry'''
##            g2 = g*(1/(1+np.exp((x-x0)/b)) + c)
##            return a*g2/np.pi/(g2**2 + (x-x0)**2)

        def Fit_polynom(x, x0=0, a=1, b=0, c=0, d=0):
            '''T1 fit model for spin 3/2'''
            return a*(x-x0)**3 + b*(x-x0)**2 + c*(x-x0) + d

        def Fit_gaussian(x, x0=0, a=1, s=1000):
            '''Gaussian lineshape model'''
            return a/(s*np.sqrt(2*np.pi))*np.exp(-0.5*((x-x0)/s)**2)



        #reference to functions
        # [function, fit_params, start guess, label, tex_form]
        self.fit_names = {'Lorentz':[Fit_lorentz, ['x0', 'a', 'g'],
                                     [self.trace.fr_list[int(len(self.trace.fr_list)/2)],
                                      self.trace.spc_list_points[int(len(self.trace.fr_list)/2)],
                                      self.trace.fr_list[-1]-self.trace.fr_list[0]/2
                                      ],
                                     'a*g/pi/(g^2+(x-x0)^2)'
                                     ],
                          'Asymmetric':[Fit_lorentz_asymmetric, ['x0', 'a', 'g', 'c'],
                                        [self.trace.fr_list[int(len(self.trace.fr_list)/2)],
                                         self.trace.spc_list_points[int(len(self.trace.fr_list)/2)],
                                         self.trace.fr_list[-1]-self.trace.fr_list[0]/2,
                                         0
                                         ],
                                        'a*g(x)/pi/(g(x)^2+(x-x0)^2)'
                                        ],
                          'Polynom':[Fit_polynom, ['x0','a','b','c','d'],
                                     [self.trace.fr_list[int(len(self.trace.fr_list)/2)],
                                      1,
                                      3*self.trace.fr_list[int(len(self.trace.fr_list)/2)],
                                      0,
                                      0],
                                     'a*x^3+b*x^2+c*x+d'
                                     ],
                          'Gauss':[Fit_gaussian, ['x0', 'a', 's'],
                                     [self.trace.fr_list[int(len(self.trace.fr_list)/2)],
                                      self.trace.spc_list_points[int(len(self.trace.fr_list)/2)],
                                      self.trace.fr_list[-1]-self.trace.fr_list[0]/2
                                      ],
                                     'a*/sqrt(2*pi)*exp(-0.5*((x-x0)/s)**2)^2'
                                     ]
                          }

        def Fit():
            '''Executes the fit with given parameters and plots it'''
            Fit_function = self.fit_names[self.combo_fit_var.get()][0]
            #read values from entry boxes
            start_params = dict()
            for entry,param in zip(self.entry_params_start, param_list):
                start_params[param]=float(entry.get())
            #data points
            fit_range=(int(self.fit_range_l_var.get()), int(self.fit_range_r_var.get()))
            #print(fit_range)

            x = self.trace.fr_list
            x2 = self.trace.fr_list[slice(*fit_range)]
            y = self.trace.spc_list_points[slice(*fit_range)]

            
            #print(x,y)
            y_start = [Fit_function(xx, **start_params) for xx in x]

            #check if last parameter is enabled or not
            p_start = [start_params[key] for key in param_list]
##            if not self.check_params_start_var.get():
##                p_start.pop(-1)
##                self.entry_params_fit[-1].config(state='normal')
##                self.entry_params_fit[-1].delete(0, 'end')
##                self.entry_params_fit[-1].insert('end', 1)
##                self.entry_params_fit[-1].config(state='readonly')

            #run fit, p_optimal, p_covariance matrix
            try:
                popt,pcov = curve_fit(Fit_function, x2, y, p0=p_start)
                y_fit = [Fit_function(xx, *popt) for xx in x]
            except:
                return

            #print values to entry boxes
            for i,p in enumerate(popt):
                self.entry_params_fit[i].config(state='normal')
                self.entry_params_fit[i].delete(0, 'end')
                self.entry_params_fit[i].insert('end','%.4g' %p)
                self.entry_params_fit[i].config(state='readonly')

            #update plots
            self.axes_start_plot.set_ydata(y_start)
            self.axes_fit_plot.set_ydata(y_fit)
            self.fig_spc.canvas.draw()


            #save parameters
            self.trace.fit_params = popt
            self.trace.fit_param_cov = pcov
            self.trace.fr = popt[0]
            self.trace.width = popt[2]
            self.trace.fit_range = fit_range
##            if self.check_params_start_var.get():
##                self.trace.r = popt[-1]
##            else:
##                self.trace.r = 1

            self.Refresh_parameters()

        def Change_fit(event=None):
            '''Changes the current fitting function'''
            #update memory in parent
            self.parent.temperatures.previous_t1['fit']=self.combo_fit_var.get()
            #repack the entries
            self.Fitting_frame()
            #rerun
            #Fit()

       
        #implement more options later if necessary
        self.label_fit = tk.Label(self.frame_fit, text='Fitting function')
        self.label_fit.pack(side='top')

        self.combo_fit_var = tk.StringVar()
        try:
            self.combo_fit_var.set(self.parent.temperatures.previous_spc['fit'])
        except KeyError:
            self.combo_fit_var.set('Lorentz')
            self.parent.temperatures.previous_spc['fit']='Lorentz'
             
        self.combo_fit = ttk.Combobox(self.frame_fit, state='readonly', values=sorted(list(self.fit_names.keys())),
                                      textvar=self.combo_fit_var)
        self.combo_fit.pack(side='top')
        self.combo_fit.bind("<<ComboboxSelected>>", Change_fit)

        

        self.label_fit_fun = tk.Label(self.frame_fit, text=self.fit_names[self.combo_fit_var.get()][3], bd=5)
        self.label_fit_fun.pack(side='top')

        self.label_starting_params = tk.Label(self.frame_fit, text='Starting values', bd=5)
        self.label_starting_params.pack(side='top')

        param_list = self.fit_names[self.combo_fit_var.get()][1]
        #guesses for where params should start
        start_guess = self.fit_names[self.combo_fit_var.get()][2]
##        start_guess = [self.trace.tau_list[self.trace.mean_range[0]-5],
##                       np.mean(self.trace.area_list[slice(*self.trace.mean_range)]),
##                       -self.trace.area_list[0]/self.trace.area_list[-1],
##                       1]
##        if self.combo_fit_var.get() == 'Spin 3/2':
##            start_guess[0] = start_guess[0]*6

        #start parameters entry rows
        self.frame_params_start = list()
        self.label_params_start = list()
        self.entry_params_start = list()
        for i,param in enumerate(param_list):
            self.frame_params_start.append(tk.Frame(self.frame_fit))
            self.frame_params_start[i].pack(side='top', fill='y')

            self.label_params_start.append(tk.Label(self.frame_params_start[i], text=param+' = '))
            self.label_params_start[i].pack(side='left', anchor='e')

            self.entry_params_start.append(tk.Entry(self.frame_params_start[i],
                                                    width=10, justify='right'))
            self.entry_params_start[i].insert(0, '%.4g' % start_guess[i])
            self.entry_params_start[i].pack(side='left', anchor='e')

        #check button for stretch
##        self.check_params_start_var = tk.BooleanVar(self, 0)
##        try:
##            if self.trace.r != 1:
##                self.check_params_start_var.set(1)
##        except AttributeError: pass
##        self.check_params_start = (ttk.Checkbutton(self.frame_params_start[-1],
##                                                   variable=self.check_params_start_var))
##        self.check_params_start.pack(side='left')
            
        self.button_fit = ttk.Button(self.frame_fit, text='Retry fit', command=Fit)
        self.button_fit.pack(side='top')

        self.label_fit_params = tk.Label(self.frame_fit, text='Fitted values', bd=5)
        self.label_fit_params.pack(side='top')

        #fit results entry rows
        self.frame_params_fit = list()
        self.label_params_fit = list()
        self.entry_params_fit = list()
        for i,param in enumerate(param_list):
            self.frame_params_fit.append(tk.Frame(self.frame_fit))
            self.frame_params_fit[i].pack(side='top', fill='y')

            self.label_params_fit.append(tk.Label(self.frame_params_fit[i], text=param+' = '))
            self.label_params_fit[i].pack(side='left')

            self.entry_params_fit.append(tk.Entry(self.frame_params_fit[i], width=10,
                                                  state='readonly', justify='right'))
            self.entry_params_fit[i].pack(side='left')

        #run first lap of fit
        Fit()

        # Add buttons for changing glue properties

        self.frame_change_broadening = tk.Frame(self.frame_fit)
        self.frame_change_broadening.pack(side='top', pady=100)
        self.label_broadening = tk.Label(self.frame_change_broadening,  text=' Broadening')
        self.label_broadening.pack(side='top')
        self.entry_broadening = tk.StringVar(self, value=100)
        self.entry_broadening_r = ttk.Entry(self.frame_change_broadening,
                                       textvariable=self.entry_broadening, width=10)
        self.entry_broadening_r.pack(side='top')

        self.label_fr_density = tk.Label(self.frame_change_broadening,  text=' FR density')
        self.label_fr_density.pack(side='top')
        self.entry_fr_density = tk.StringVar(self, value=10)
        self.entry_fr_density_r = ttk.Entry(self.frame_change_broadening,
                                       textvariable=self.entry_fr_density, width=5)
        self.entry_fr_density_r.pack(side='top')

        self.button_broadenind = ttk.Button(self.frame_change_broadening, text='Set broadening and FR density', command=self.Set_broadening)
        self.button_broadenind.pack(side='top')



        #add button to confirm selection
        self.button_confirm = ttk.Button(self.frame_fit, text='Confirm', command=self.Confirm)
        self.button_confirm.pack(side='bottom')
        self.button_confirm.bind('<Return>', self.Confirm)

        #add export csv button
        self.button_export = ttk.Button(self.frame_fit, text='Export CSV', command=self.Export)
        self.button_export.pack(side='bottom')
        self.button_export.bind('<F5>', self.Export)

        #add export glue button
        self.button_export_glue = ttk.Button(self.frame_fit, text='Export Glue', command=self.Export_glue)
        self.button_export_glue.pack(side='bottom')
        self.button_export_glue.bind('<F6>', self.Export_glue)

    def Set_broadening(self, event=None):
        '''Change the current broadening value'''
        print("Changing broadening")
        self.trace.Run(broaden_width=float(self.entry_broadening.get()), fr_density=int(self.entry_fr_density.get()))
        x = self.trace.spc_fr
        y = self.trace.spc_sig_real
        y2 = self.trace.spc_sig_imag
        y3 = np.sqrt(y**2 + y2**2)
        #glue plot
        self.glue_re_line[0].set_xdata(x)
        self.glue_im_line[0].set_xdata(x)
        self.glue_abs_line[0].set_xdata(x)
        self.glue_re_line[0].set_ydata(y)
        self.glue_im_line[0].set_ydata(y2)
        self.glue_abs_line[0].set_ydata(y3)

        self.fig_glue.canvas.draw()

    def Confirm(self, event=None):
        '''Confirm the selection in this screen'''
        #unpack, dont destroy untill series is done, in case corrections are needed
        self.parent.temperatures.wait.set(False)
        self.pack_forget()
        self.destroy()
        plt.close('all')

        #move to later stages
        self.trace.analysed = True

    def Refresh_parameters(self):
        '''refreshes the parameters table'''
        self.tree_parameters.delete(*self.tree_parameters.get_children())
        self.trace.Get_params()
        for item in GLOBAL_spc_displayed_params:
            try:
                pair = (item, self.trace.__dict__[item])
                self.tree_parameters.insert('', 'end', values=pair)
            except: pass

    def Export(self):
        '''Saves the plotted data into a CSV file for further analysis'''
        file_name = self.trace.__dict__['file_key'] + '.csv'
        file_directory = os.path.join('data', self.parent.current_experiment, 'csv', 'spc')

        #make the csv folder for old experiments
        try:
            os.mkdir(file_directory)
        except: pass

        #write file
        with open(os.path.join(file_directory, file_name), 'w', newline='') as f:
            writer = csv.writer(f, delimiter=';')
            #name row
            writer.writerow(['fr(MHz)', 'area(A.U.)'])
            #data
            for i in range(len(self.trace.fr_list)):
                row = [self.trace.fr_list[i], self.trace.spc_list_points[i]]
                writer.writerow(row)

        tk.messagebox.showinfo('Export complete', 'The file was saved as '+file_name)

    def Export_glue(self):
        '''Saves the glue points into a CSV file'''
        file_name = self.trace.__dict__['file_key'] + '.csv'
        file_directory = os.path.join('data', self.parent.current_experiment, 'csv', 'glue_spc')

        #make the csv folder for old experiments
        try:
            os.mkdir(file_directory)
        except: pass

        #define data lines
        x = self.trace.spc_fr
        y = self.trace.spc_sig_real
        y2 = self.trace.spc_sig_imag
        y3 = np.sqrt(y**2 + y2**2)

        #write file
        with open(os.path.join(file_directory, file_name), 'w', newline='') as f:
            writer = csv.writer(f, delimiter=';')
            #name row
            writer.writerow(['fr(MHz)', 'Re(A.U.)','Im(A.U.)','Abs(A.U.)'])
            #data
            for i in range(len(x)):
                row = [x[i], y[i], y2[i], y3[i]]
                writer.writerow(row)

        tk.messagebox.showinfo('Export complete', 'The file was saved as '+file_name)

    def Fill_plot(self):
        '''Plots the T1 trend and fits it'''
        #data lines
        x = self.trace.fr_list
        y = self.trace.spc_list_points

##        sorting = np.argsort(x)
##        x = np.array(x)[sorting]
##        y = np.array(y)[sorting]


        #point plot
        self.axes = self.fig_spc.add_subplot(111)
        self.axes.plot(x, y, marker='o', linestyle='-', color=colors[1], label='Data')
        self.axes_start_plot, = self.axes.plot(x, y, color=colors[3],
                                               linestyle='dashed', label='Fit start')
        self.axes_fit_plot, = self.axes.plot(x, y, color=colors[4], label='Fit')
        self.axes_vline_l = self.axes.axvline(x=self.trace.fr_list[self.fit_range_l_var.get()], color=colors[4])
        self.axes_vline_r = self.axes.axvline(x=self.trace.fr_list[self.fit_range_r_var.get()-1], color=colors[4])
        self.axes.set_title('Delta spectrum')
        self.axes.set_xlabel(r'$\nu$ (MHz)')
        self.axes.set_ylabel('Area (A.U.)')
        legend = self.axes.legend(loc='lower right')
        self.axes.grid()


        x = self.trace.spc_fr
        y = self.trace.spc_sig_real
        y2 = self.trace.spc_sig_imag
        y3 = np.sqrt(y**2 + y2**2)
        #glue plot
        self.axes_glue = self.fig_glue.add_subplot(111)
        self.glue_re_line = self.axes_glue.plot(x, y, color=colors[1], label='Re')
        self.glue_im_line = self.axes_glue.plot(x, y2, color=colors[2], label='Im')
        self.glue_abs_line = self.axes_glue.plot(x, y3, color=colors[3], label='Abs')
        self.axes_glue.set_title('Glued spectrum')
        self.axes_glue.set_xlabel(r'$\nu$ (MHz)')
        self.axes_glue.set_ylabel('Signal (A.U.)')
        legend = self.axes_glue.legend(loc='lower right')
        self.axes_glue.grid()

        #draggable vline event
                                            
        def Drag(event):
            '''Allows dragging of the markers for fit range on spectrum plot'''
            if event.button == 1 and event.inaxes != None:
                #find the index of selected points
                self.fit_range_l_var.set(np.searchsorted(self.trace.fr_list, event.xdata, side='right'))
                #print(self.fit_range_l_var.get())
                #self.range_l_select = int(event.xdata)
                #update plot
                self.axes_vline_l.set_xdata(event.xdata)
                self.fig_spc.canvas.draw()

            if event.button == 3 and event.inaxes != None:
                #find the index of selected points
                self.fit_range_r_var.set(np.searchsorted(self.trace.fr_list, event.xdata, side='left'))
                #print(self.fit_range_r_var.get())
                #self.range_r_select = int(event.xdata)
                #update plot
                self.axes_vline_r.set_xdata(event.xdata)
                self.fig_spc.canvas.draw()

        self.axes_vline_drag = self.fig_spc.canvas.mpl_connect('motion_notify_event', Drag)
        
        
class Frame_plot_spc_frvt(tk.Frame):
    '''T1vT trend plotting'''
    def __init__(self, parent, trace):
        '''makes the subframe and fills it up'''
        tk.Frame.__init__(self, parent)
        self.pack(side='left', anchor='n')
        
        #reference to parent
        self.parent = parent
        #reference to current series
        self.trace = trace

        #counter for plots
        self.counter = 0
        
        #load widgets
        self.Widgets()

    def Widgets(self):
        '''Builds all the subframes and canvases'''
        #button commands
        def Confirm(event=None):
            '''Confirm the selection in this screen'''
            #unpack, dont destroy untill series is done, in case corrections are needed
            self.parent.temperatures.wait.set(False)
            self.pack_forget()
            self.destroy()
            plt.close('all')

            self.parent.traces.button_show.config(state='normal')

        #split in columns
        self.frame_plot_left = tk.Frame(self)
        self.frame_plot_left.pack(side='left', anchor='n')
        self.frame_plot_right = tk.Frame(self)
        self.frame_plot_right.pack(side='left', anchor='n')

        #plot frames
        self.frame_plot1 = tk.Frame(self.frame_plot_left, bd=5)
        self.frame_plot1.pack(side='top', anchor='n')
        self.frame_plot2 = tk.Frame(self.frame_plot_right, bd=5)
        self.frame_plot2.pack(side='top', anchor='n')
        self.frame_plot3 = tk.Frame(self.frame_plot_right, bd=5)
        self.frame_plot3.pack(side='top', anchor='n')

        #buttons frame
        self.frame_buttons = tk.Frame(self.frame_plot_right, bd=5)
        self.frame_buttons.pack(side='top', anchor='e')
        
        #T1 plot
        self.fig_t1vt = plt.figure(dpi=100, figsize=(7,4.5))
        self.fig_t1vt.subplots_adjust(bottom=0.12, left= 0.11, right=0.96, top=0.94)
        self.canvas_t1vt = FigureCanvasTkAgg(self.fig_t1vt, self.frame_plot1)
        self.canvas_t1vt._tkcanvas.pack()

        #fr plot
        self.fig_fr = plt.figure(dpi=100, figsize=(7,2.5))
        self.fig_fr.subplots_adjust(bottom=0.18, left= 0.11, right=0.96, top=0.90)
        self.canvas_fr = FigureCanvasTkAgg(self.fig_fr, self.frame_plot2)
        self.canvas_fr._tkcanvas.pack()

        #stretch plot
        self.fig_r = plt.figure(dpi=100, figsize=(7,2.5))
        self.fig_r.subplots_adjust(bottom=0.18, left= 0.11, right=0.96, top=0.90)
        self.canvas_r = FigureCanvasTkAgg(self.fig_r, self.frame_plot3)
        self.canvas_r._tkcanvas.pack()


        #add button to confirm selection
        self.button_confirm = ttk.Button(self.frame_buttons, text='Confirm', command=Confirm)
        self.button_confirm.pack(side='right')
        self.button_confirm.bind('<Return>', Confirm)

        #plot the stuff
        self.Fill_plot()

        #add button to export parameters
        self.button_export = ttk.Button(self.frame_buttons, text='Export CSV', command=self.Export)
        self.button_export.pack(side='right')



    def Add_trace(self, trace):
        '''Adds traces to plots using given trace'''
        #initialize lists
        x = list()
        fr = list()
        width = list()
        amp = list()
        for temp in self.trace:
            if self.trace[temp].analysed and not self.trace[temp].disabled:

                x.append(self.trace[temp].temp_set)
                #maby calculate some center frequency at some point?
                fr.append(self.trace[temp].fr)
                width.append(self.trace[temp].width)
                amp.append(self.trace[temp].fit_params[1])
                name = self.trace[temp].file_key
        #sort by temperature
        sorting = np.argsort(x)
        x = np.array(x)[sorting]
        fr = np.array(fr)[sorting]
        width = np.array(width)[sorting]
        amp = np.array(amp)[sorting]
                           

        

        #draw trace
        self.axes_1.plot(x, fr, 'bo', color=colors[self.counter],
                         label=self.parent.current_trace, linestyle='dashed')
        self.axes_2.plot(x, fr, 'bo', color=colors[self.counter],
                         label=self.parent.current_trace, linestyle='dashed')
        self.axes_3.plot(x, 2*width, 'bo', color=colors[self.counter],
                         label=self.parent.current_trace, linestyle='dashed')

        #save for export
        self.data = dict()
        self.data['T'] = x
        self.data['fr'] = fr
        self.data['FWHM'] = 2*width
        self.data['amp'] = amp/np.pi/width
  

        #increase plot counter
        self.counter += 1

    def Export(self):
        '''Saves the plotted data into a CSV file for further analysis'''
        file_name = self.parent.current_trace + '.csv'
        file_directory = os.path.join('data', self.parent.current_experiment, 'csv', 'spc')

        #make the csv folder for old experiments
        try:
            os.mkdir(file_directory)
        except: pass

        #write file
        with open(os.path.join(file_directory, file_name), 'w', newline='') as f:
            writer = csv.writer(f, delimiter=';')
            #name row
            writer.writerow(['T(K)', 'fr(MHz)','FWHM(MHz)','amplitude'])
            #data
            for i in range(len(self.data['T'])):
                row = [self.data['T'][i], self.data['fr'][i], self.data['FWHM'][i], self.data['amp'][i]]
                writer.writerow(row)

        tk.messagebox.showinfo('Export complete', 'The file was saved as '+file_name)

    def Fill_plot(self):
        '''Creates the plots for T1vT'''

        self.axes_1 = self.fig_t1vt.add_subplot(111)
        self.axes_1.set_xscale('log')
        #self.axes_1.set_yscale('log')
        self.axes_1.set_title('Frequency temperature dependence')
        self.axes_1.set_xlabel('Temperature (K)')
        self.axes_1.set_ylabel(r'Frequency (MHz)')
        #self.axes_1.legend(loc='lower right')
        self.axes_1.grid()

        self.axes_2 = self.fig_fr.add_subplot(111)
        self.axes_2.set_title('Frequency temperature dependence')
        self.axes_2.set_xlabel('Temperature (K)')
        self.axes_2.set_ylabel('Frequency (MHz)')
        #self.axes_2.get_yaxis().get_major_formatter().set_useOffset(False)
        self.axes_2.margins(0.05, 0.1)
        self.axes_2.grid()

        self.axes_3 = self.fig_r.add_subplot(111)
        self.axes_3.set_title('Linewidth')
        self.axes_3.set_xlabel('Temperature (K)')
        self.axes_3.set_ylabel('Linewidth')
        #self.axes_3.get_yaxis().get_major_formatter().set_useOffset(False)
        self.axes_3.margins(0.05, 0.1)
        self.axes_3.grid()

