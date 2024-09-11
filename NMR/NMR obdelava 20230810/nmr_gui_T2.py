from nmr_gui_imports_and_parameters import *

class Frame_plot_T2_quick(tk.Frame):
    '''Pioneer first T2 preview plot'''
    def __init__(self, parent, trace, root):
        '''makes the subframe and fills it up'''
        tk.Frame.__init__(self, parent, bd=5)
        self.pack(side='left', fill='both', expand=True)
        
        #reference to parent
        self.parent = parent
        #reference to current trace:
        self.trace = trace

        #starting data
        self.range = self.parent.temperatures.previous_t2['mean_range'][1]

        #load widgets
        self.Widgets()

        #run quick t2
        quick_tables = trace.Quick_T2()
        self.Fill_plots(*quick_tables)

        #take focus away from listbox
        self.focus()
        #global key binds
        self.root = root
        self.root.bind('<Left>', self.Interrupt)
        self.root.bind('<Right>', self.Finish)
        


    def Finish(self, event=None):
        '''Accepts the data on this screen and closes it up'''
        #save data
        self.trace.mean_range = (0, self.range)
        self.trace.mean_shl = int(self.mean_shl)
        self.trace.mean_phase = self.mean_phase
        self.parent.temperatures.previous_t2['mean_range']=(0, self.range)
        #hide this frame
        self.pack_forget()
        #close plots
        plt.close('all')
        #forget global key bind
        self.root.unbind('<Right>')
        self.root.unbind('<Left>')

        #run next frame
        self.parent.plot_t2_ranges = Frame_plot_T2_ranges(self.parent, self.trace, self.root)

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

    def Widgets(self):
        '''Builds all the subframes and canvases'''
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
        self.frame_right1.pack(side='top')
        self.frame_right2.pack(side='top')

        #add canvases and toolbars
        #plot 1
        self.fig_left1 = plt.figure(dpi=100, figsize=(7,3))
        self.fig_left1.subplots_adjust(bottom=0.20, left= 0.12, right=0.96, top=0.88)
        self.fig_left1.suptitle(self.trace.file_key, x=0.01, horizontalalignment='left')
        self.canvas_left1 = FigureCanvasTkAgg(self.fig_left1, self.frame_left1)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_left1, self.frame_left1)
        self.canvas_left1._tkcanvas.pack()

        #plot 2
        self.fig_left2 = plt.figure(dpi=100, figsize=(7,4))
        self.fig_left2.subplots_adjust(bottom=0.15, left= 0.12, right=0.96, top=0.9)
        self.canvas_left2 = FigureCanvasTkAgg(self.fig_left2, self.frame_left2)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_left2, self.frame_left2)
        self.canvas_left2._tkcanvas.pack()
        
        #interrupt button
        self.button_interrupt = ttk.Button(self.frame_left3, text='Interrupt', command=self.Interrupt)
        self.button_interrupt.pack(side='left', anchor='w')

        #label and edit of mean_range
        self.frame_left3_middle = tk.Frame(self.frame_left3)
        self.frame_left3_middle.pack(anchor='center')

        self.label_mean = tk.Label(self.frame_left3_middle,  text='Selected range:')
        self.label_mean.pack(side='left')

        self.entry_mean_var = tk.StringVar(self, value=self.range)
        self.entry_mean = ttk.Entry(self.frame_left3_middle,
                                    textvariable=self.entry_mean_var, width=3)
        self.entry_mean.pack(side='left')


        #plot 3
        self.fig_right1 = plt.figure(dpi=100, figsize=(7,3.5))
        self.fig_right1.subplots_adjust(bottom=0.15, left= 0.10, right=0.96, top=0.9)
        self.canvas_right1 = FigureCanvasTkAgg(self.fig_right1, self.frame_right1)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_right1, self.frame_right1)
        self.canvas_right1._tkcanvas.pack()

        #plot 4
        self.fig_right2 = plt.figure(dpi=100, figsize=(7,3.5))
        self.fig_right2.subplots_adjust(bottom=0.15, left= 0.10, right=0.96, top=0.9)
        self.canvas_right2 = FigureCanvasTkAgg(self.fig_right2, self.frame_right2)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_right2, self.frame_right2)
        self.canvas_right2._tkcanvas.pack()


        #add button to confirm selection
        self.button_confirm = ttk.Button(self.frame_right, text='Confirm', command=self.Finish)
        self.button_confirm.pack(side='top', anchor='ne')

    def Fill_plots(self, temp_list, temp_list2, temp_set, tau_list, t2_list, phase_list, shl_list):
        '''Puts the contents into the plot fields'''
        #starting values
        self.mean_t2 = np.mean(t2_list[:self.range])
        self.mean_phase = np.mean(np.unwrap(phase_list[:self.range]))
        self.mean_shl = np.round(np.mean(shl_list[:self.range]))
        #x axes
        n = len(tau_list)
        x_list = np.linspace(1,n,n)
        
        #plot 1, temperature stabillity    
        self.axes_left1 = self.fig_left1.add_subplot(111)
        if abs(np.mean(temp_list) - temp_set) < 2:
            self.axes_left1.plot(x_list, temp_list, marker='.', color=colors[1], label='ITC_R1')
        if abs(np.mean(temp_list2) - temp_set) < 2:
            self.axes_left1.plot(x_list, temp_list2, marker='.', color=colors[2], label='ITC_R2')
        self.axes_left1.axhline(y=temp_set, color=colors[0], label='Set T')
        self.axes_left1.margins(0.02, 0.1)
        self.axes_left1.set_title('Temperature stabillity check')
        self.axes_left1.set_xlabel('File index')
        self.axes_left1.set_ylabel('Temperature (K)')
        self.axes_left1.legend(loc='upper right')
        self.axes_left1.grid()

        #plot 2
        self.axes_left2 = self.fig_left2.add_subplot(111)
        self.axes_left2.plot(tau_list, t2_list, 'bo', color=colors[1], label='Data')
        self.axes_left2_vline = self.axes_left2.axvline(x=tau_list[self.range],
                                                        color=colors[2], label='Select')
        self.axes_left2_hline = self.axes_left2.axhline(y=self.mean_t2, color=colors[0],
                                                        label='Plato')
        self.axes_left2.set_yscale('log')
        self.axes_left2.set_title('T2 quick check')
        self.axes_left2.set_xlabel(r'$\tau$ ($\mu$s)')
        self.axes_left2.set_ylabel('Signal')
        #legend = self.axes_left2.legend(loc='lower right')
        #legend.draggable()
        self.axes_left2.grid()
        
        #plot 3
        self.axes_right1 = self.fig_right1.add_subplot(111)
        self.axes_right1.plot(x_list, np.unwrap(np.array(phase_list))*180/np.pi, marker='.',
                             color=colors[1], label='Phase')
        self.axes_right1_hline = self.axes_right1.axhline(self.mean_phase*180/np.pi, color=colors[0], label='Mean phase')
        self.axes_right1.margins(0.02, 0.1)
        self.axes_right1.set_title('Phase check')
        self.axes_right1.set_xlabel('File index')
        self.axes_right1.set_ylabel('Phase (Deg)')
        #self.axes_right1.legend(loc='lower right')
        self.axes_right1.grid()

        #plot 4
        self.axes_right2 = self.fig_right2.add_subplot(111)
        self.axes_right2.plot(x_list, shl_list, marker='.',
                             color=colors[1], label='SHL')
        self.axes_right2_hline = self.axes_right2.axhline(self.mean_shl,
                                                          color=colors[0], label='Mean SHL')
        self.axes_right2.margins(0.02, 0.1)
        self.axes_right2.set_title('SHL check')
        self.axes_right2.set_xlabel('File index')
        self.axes_right2.set_ylabel('Shift left')
        #self.axes_right2.legend(loc='lower right')
        self.axes_right2.grid()

        #redraw canvases
        self.fig_left1.canvas.draw()
        self.fig_left2.canvas.draw()
        self.fig_right1.canvas.draw()
        self.fig_right2.canvas.draw()
        

        #draggable vline event
        def Drag(event):
            '''Allows dragging of the marker in left2, recalculates mean of selected points'''
            if event.button == 1 and event.inaxes != None:
                #find the index of selected points
                self.range = np.searchsorted(tau_list, event.xdata, side='right')
                self.mean_t2 = np.mean(t2_list[:self.range])
                self.mean_phase = np.mean(np.unwrap(phase_list[:self.range]))
                self.mean_shl = np.round(np.mean(shl_list[:self.range]))
                self.entry_mean_var.set(self.range)
                #update plot
                self.axes_left2_vline.set_xdata(event.xdata)
                self.axes_left2_hline.set_ydata(self.mean_t2)
                self.axes_right1_hline.set_ydata(self.mean_phase*180/np.pi)
                self.axes_right2_hline.set_ydata(self.mean_shl)
                self.fig_left2.canvas.draw()
                self.fig_right1.canvas.draw()
                self.fig_right2.canvas.draw()

        self.axes_left2_vline_drag = self.fig_left2.canvas.mpl_connect('motion_notify_event', Drag)


class Frame_plot_T2_ranges(tk.Frame):
    '''Pioneer first T2 preview plot'''
    def __init__(self, parent, trace, root):
        '''makes the subframe and fills it up'''
        tk.Frame.__init__(self, parent, bd=5)
        self.pack(side='left', fill='both', expand=True)
        
        #reference to parent
        self.parent = parent
        #reference to current trace:
        self.trace = trace

        self.offset_select = self.parent.temperatures.previous_t2['offset'][0]
        self.range_l_select = self.parent.temperatures.previous_t2['integral_range'][0]
        self.range_r_select = self.parent.temperatures.previous_t2['integral_range'][1]
        self.mirroring = self.parent.temperatures.previous_t2['mirroring']
        self.spc_display_width = 0.2 # TODO get from previous

        #load widgets
        self.Widgets()

        #load plots and read
        self.Choose_offset(trace)

        self.focus()
        #global key bindings
        self.root = root
        self.root.bind('<Left>', self.Previous)
        self.root.bind('<Right>', self.Confirm_offset)

        
   

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
                self.axes_right1_vline_l.set_xdata(self.spc_fr[self.range_l_select])
                self.axes_right2_vline_l.set_xdata(self.spc_fr[self.range_l_select])
                self.axes_right1_vline_r.set_xdata(self.spc_fr[self.range_r_select])
                self.axes_right2_vline_r.set_xdata(self.spc_fr[self.range_r_select])
                self.fig_right1.canvas.draw()
                self.fig_right2.canvas.draw()
            except ValueError:
                tk.messagebox.showerror('Error', 'The inserted values must be integers!')
            
        def Set_display_width(event=None):
            '''Entry change of spc display width, replot and save value'''
            try:
                self.spc_display_width = float(self.entry_disp_width_var.get())
                self.axes_right1.set_xlim((self.trace.fr -self.spc_display_width,+ self.trace.fr +self.spc_display_width))
                self.fig_right1.canvas.draw()
                self.axes_right2.set_xlim((self.trace.fr -self.spc_display_width,+ self.trace.fr +self.spc_display_width))
                self.fig_right2.canvas.draw()
            except ValueError:
                tk.messagebox.showerror('Error', 'The inserted value must be a float!')

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

        #add canvases and toolbars
        #plot 1
        self.fig_left1 = plt.figure(dpi=100, figsize=(7,2.5))
        self.fig_left1.subplots_adjust(bottom=0.20, left= 0.10, right=0.96, top=0.88)
        self.fig_left1.suptitle(self.trace.file_key, x=0.01, horizontalalignment='left')
        self.canvas_left1 = FigureCanvasTkAgg(self.fig_left1, self.frame_left1)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_left1, self.frame_left1)
        self.canvas_left1._tkcanvas.pack()

        #plot 2
        self.fig_left2 = plt.figure(dpi=100, figsize=(7,4.5))
        self.fig_left2.subplots_adjust(bottom=0.12, left= 0.08, right=0.96, top=0.93)
        self.canvas_left2 = FigureCanvasTkAgg(self.fig_left2, self.frame_left2)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_left2, self.frame_left2)
        self.canvas_left2._tkcanvas.pack()
 
        #buttons left
        self.button_previous = ttk.Button(self.frame_left3, text='Repeat previous', command=self.Previous)
        self.button_previous.pack(side='left')

        self.button_confirm = ttk.Button(self.frame_left3, text='Confirm', command=self.Confirm_offset)
        self.button_confirm.pack(side='right')

        #check button for mirroring fid
        self.check_mirroring_var = tk.BooleanVar(self, False)
        if self.mirroring:
            self.check_mirroring_var.set(True)
            
        self.check_mirroring = (ttk.Checkbutton(self.frame_left3, variable=self.check_mirroring_var))
        self.check_mirroring.pack(side='right')
        
        self.label_mirroring = tk.Label(self.frame_left3,  text='Mirroring')
        self.label_mirroring.pack(side='right')
        

        #middle frame
        self.frame_left3_middle = tk.Frame(self.frame_left3)
        self.frame_left3_middle.pack(anchor='center')

        self.label_offset = tk.Label(self.frame_left3_middle,  text='Selected offset:')
        self.label_offset.pack(side='left')
        
        self.entry_offset_var = tk.StringVar(self, value=self.offset_select)
        self.entry_offset = ttk.Entry(self.frame_left3_middle,
                                      textvariable=self.entry_offset_var, width=5)
        self.entry_offset.pack(side='left')
        self.entry_offset.bind('<Return>', Set_offset)

        self.button_set_offset = ttk.Button(self.frame_left3_middle,
                                            text='Set offset', command=Set_offset)
        self.button_set_offset.pack(side='left')


        #plot 3
        self.fig_right1 = plt.figure(dpi=100, figsize=(7,2.5))
        self.fig_right1.subplots_adjust(bottom=0.20, left= 0.10, right=0.96, top=0.88)
        self.canvas_right1 = FigureCanvasTkAgg(self.fig_right1, self.frame_right1)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_right1, self.frame_right1)
        self.canvas_right1._tkcanvas.pack()

        #plot 4
        self.fig_right2 = plt.figure(dpi=100, figsize=(7,4.5))
        self.fig_right2.subplots_adjust(bottom=0.12, left= 0.10, right=0.96, top=0.93)
        self.canvas_right2 = FigureCanvasTkAgg(self.fig_right2, self.frame_right2)
        #self.toolbar = NavigationToolbar2TkAgg(self.canvas_right2, self.frame_right2)
        self.canvas_right2._tkcanvas.pack()

        #buttons right
        self.label_range = tk.Label(self.frame_right3,  text='Selected ranges:')
        self.label_range.pack(side='left')
        
        self.entry_range_l_var = tk.StringVar(self, value=self.range_l_select)
        self.entry_range_l = ttk.Entry(self.frame_right3,
                                       textvariable=self.entry_range_l_var, width=5)
        self.entry_range_l.pack(side='left')
        self.entry_range_l.bind('<Return>', Set_range)

        self.label_range_comma = tk.Label(self.frame_right3,  text=' , ')
        self.label_range_comma.pack(side='left')

        self.entry_range_r_var = tk.StringVar(self, value=self.range_r_select)
        self.entry_range_r = ttk.Entry(self.frame_right3,
                                       textvariable=self.entry_range_r_var, width=5)
        self.entry_range_r.pack(side='left')
        self.entry_range_r.bind('<Return>', Set_range)

        self.button_set_range = ttk.Button(self.frame_right3, text='Set range', command=Set_range)
        self.button_set_range.pack(side='left')

        self.label_disp_width = tk.Label(self.frame_right3,  text=' Display width')
        self.label_disp_width.pack(side='left')

        self.entry_disp_width_var = tk.StringVar(self, value=self.spc_display_width)
        self.entry_disp_width_var_r = ttk.Entry(self.frame_right3,
                                       textvariable=self.entry_disp_width_var, width=5)
        self.entry_disp_width_var_r.pack(side='left')

        self.button_set_display_width = ttk.Button(self.frame_right3, text='Set display width', command=Set_display_width)
        self.button_set_display_width.pack(side='left')

        self.button_close = ttk.Button(self.frame_right3, text='Confirm',
                                       command=self.Close, state='disabled')
        self.button_close.pack(side='right')

    #button commands
    def Previous(self, event=None):
        '''Back to the previous step!'''
        #reload offset
        self.parent.plot_t2_quick.pack(side='left', fill='both', expand=True)
        #destroy me
        self.pack_forget()
        self.destroy()
        #unbind global keys
        self.root.unbind('<Right>')
        self.root.unbind('<Left>')


    def Confirm_offset(self, event=None):
        '''Saves current offset range and opens integral ranges select'''
        self.trace.offset_range = (self.offset_select, None)
        self.parent.temperatures.previous_t2['offset'] = (self.offset_select, None)
        
        #remember mirroring
        self.parent.temperatures.previous_t2['mirroring'] = self.check_mirroring_var.get()
        self.trace.mirroring = self.check_mirroring_var.get()
        
        self.Choose_ranges(self.trace)
        self.button_confirm.config(state='disabled')
        self.button_close.config(state='enabled')
        self.button_close.focus_set()

        #change global keys
        self.root.bind('<Right>', self.Close)

    def Close(self, event=None):
        '''Confirm the selection in this screen'''
        #save the integral ranges
        self.trace.integral_range = (self.range_l_select, self.range_r_select)
        self.parent.temperatures.previous_t2['integral_range'] = (self.range_l_select,
                                                                  self.range_r_select)

        #finish the analysis
        self.trace.Run()
        
        #unpack and destroy
        self.trace.analysed = True
        self.parent.plot_t2_quick.destroy()
        self.pack_forget()
        self.destroy()
        plt.close('all')
        #unbind global keys
        self.root.unbind('<Right>')
        self.root.unbind('<Left>')

        #load the overview frame
        self.parent.plot_t2_view = Frame_plot_T2_view(self.parent, self.trace, self.root)

    def Choose_offset(self, trace):
        '''Operations and plotting for choosing the FID offsets'''
        fids = list()
        for file in trace.file_list:
            fid = FID(file, trace.file_dir)
            fids.append(fid.x)

        x_mean = np.mean(fids[slice(*trace.mean_range)], axis=0)

        #plot 1
        self.axes_left1 = self.fig_left1.add_subplot(111)
        self.axes_left1.plot(np.real(x_mean), color=colors[1], label='Re')
        self.axes_left1.plot(np.imag(x_mean), color=colors[2], label='Im')
        self.axes_left1.plot(np.abs(x_mean), color=colors[0], label='Abs')
        self.axes_left1.axvline(x=trace.mean_shl, color=colors[-1])
        self.axes_left1_vline = self.axes_left1.axvline(x=self.offset_select, color=colors[4])
        self.axes_left1.margins(0.02, 0.1)
        self.axes_left1.set_title('Mean FID')
        self.axes_left1.set_xlabel('Time (index)')
        self.axes_left1.set_ylabel('Signal (A.U.)')
        #self.axes_left1.legend(loc='upper right')
        self.axes_left1.grid()

        #plot 2
        self.axes_left2 = self.fig_left2.add_subplot(111, sharex=self.axes_left1)
        for i, fid in enumerate(fids):
            self.axes_left2.plot(np.abs(fid)+np.amax(np.abs(x_mean))*0.5*i,
                                 color=colors[i%9], label=str(i))
        self.axes_left2.axvline(x=trace.mean_shl, color=colors[-1], label='shl')
        self.axes_left2_vline = self.axes_left2.axvline(x=self.offset_select,
                                                        color=colors[4], label='Select')
        self.axes_left2.margins(0.02, 0.02)
        self.axes_left2.set_title('All FIDs')
        self.axes_left2.set_xlabel('Time (index)')
        self.axes_left2.set_ylabel('Absolute signal (A.U.)')
        self.axes_left2.grid()

        #draggable vline event
        def Drag(event):
            '''Allows dragging of the marker in left2, recalculates mean of selected points'''
            if event.button == 1 and event.inaxes != None:
                #find the index of selected points
                self.offset_select = int(event.xdata)
                self.entry_offset_var.set(self.offset_select)
                #update plot
                self.axes_left1_vline.set_xdata(event.xdata)
                self.axes_left2_vline.set_xdata(event.xdata)
                self.fig_left1.canvas.draw()
                self.fig_left2.canvas.draw()

        self.axes_left1_vline_drag = self.fig_left1.canvas.mpl_connect('motion_notify_event', Drag)
        self.axes_left2_vline_drag = self.fig_left2.canvas.mpl_connect('motion_notify_event', Drag)

    def Choose_ranges(self, trace):
        '''Operations and plotting for choosing spectrum integral ranges'''
        spcs = list()
        for file in trace.file_list:
            fid = FID(file, trace.file_dir)
            fid.Offset(trace.offset_range)
            fid.Shift_left(trace.mean_shl, mirroring=trace.mirroring)
            fid.Fourier()
            fid.Phase_rotate(trace.mean_phase)

            spcs.append(fid.spc)

        spc_fr = fid.spc_fr
        self.spc_fr = spc_fr
        spc_mean = np.mean(spcs[slice(*trace.mean_range)], axis=0)

        #plot 3
        self.axes_right1 = self.fig_right1.add_subplot(111)
        self.axes_right1.plot(spc_fr, np.real(spc_mean), color=colors[1], label='Re')
        self.axes_right1.plot(spc_fr, np.imag(spc_mean), color=colors[2], label='Im')
        self.axes_right1.axvline(x=trace.fr, color=colors[-1])
        self.axes_right1_vline_l = self.axes_right1.axvline(x=spc_fr[self.range_l_select],
                                                            color=colors[4])
        self.axes_right1_vline_r = self.axes_right1.axvline(x=spc_fr[self.range_r_select],
                                                            color=colors[4])
        self.axes_right1.set_xlim((trace.fr -0.5,+ trace.fr +0.5))
        self.axes_right1.set_title('Mean spectrum (Drag with left and right mouse button)')
        self.axes_right1.set_xlabel('Frequency (MHz)')
        self.axes_right1.set_ylabel('Signal (A.U.)')
        self.axes_right1.legend(loc='upper left')
        self.axes_right1.grid()

        #plot 4
        self.axes_right2 = self.fig_right2.add_subplot(111)
        for i, spc in enumerate(spcs):
            self.axes_right2.plot(spc_fr, np.real(spc)+np.amax(np.abs(spc_mean))*0.5*i,
                                  color=colors[i%9], label=str(i))
        self.axes_right1.axvline(x=trace.fr, color=colors[-1])
        self.axes_right2_vline_l = self.axes_right2.axvline(x=spc_fr[self.range_l_select],
                                                            color=colors[4])
        self.axes_right2_vline_r = self.axes_right2.axvline(x=spc_fr[self.range_r_select],
                                                            color=colors[4])
        self.axes_right2.set_xlim((trace.fr -0.5,+ trace.fr +0.5))
        self.axes_right2.margins(0.02, 0.02)
        self.axes_right2.set_title('All FIDs')
        self.axes_right2.set_xlabel('Frequency (MHz)')
        self.axes_right2.set_ylabel('Real part of signal (A.U.)')
        self.axes_right2.grid()

        #draggable vline event
        def Drag(event):
            '''Allows dragging of the marker in left2, recalculates mean of selected points'''
            if event.button == 1 and event.inaxes != None:
                #find the index of selected points
                self.range_l_select = np.searchsorted(spc_fr, event.xdata, side='left')
                self.entry_range_l_var.set(self.range_l_select)
                #update plot
                self.axes_right1_vline_l.set_xdata(event.xdata)
                self.axes_right2_vline_l.set_xdata(event.xdata)
                self.fig_right1.canvas.draw()
                self.fig_right2.canvas.draw()

            if event.button == 3 and event.inaxes != None:
                #find the index of selected points
                self.range_r_select = np.searchsorted(spc_fr, event.xdata, side='right')
                self.entry_range_r_var.set(self.range_r_select)
                #update plot
                self.axes_right1_vline_r.set_xdata(event.xdata)
                self.axes_right2_vline_r.set_xdata(event.xdata)
                self.fig_right1.canvas.draw()
                self.fig_right2.canvas.draw()

        self.axes_right1_vline_drag = self.fig_right1.canvas.mpl_connect('motion_notify_event', Drag)
        self.axes_right2_vline_drag = self.fig_right2.canvas.mpl_connect('motion_notify_event', Drag)

        self.fig_right1.canvas.draw()
        self.fig_right2.canvas.draw()
        
class Frame_plot_T2_view(tk.Frame):
    '''Pioneer first T2 preview plot'''
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
            '''Clears the T2 trace and starts the analysis from scratch'''
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
        self.trace.mean_phase_deg = self.trace.mean_phase*180/np.pi
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

        #T2 plot
        self.fig_t2 = plt.figure(dpi=100, figsize=(8,6))
        self.fig_t2.subplots_adjust(bottom=0.1, left= 0.10, right=0.96, top=0.94)
        self.fig_t2.suptitle(self.trace.file_key, x=0.01, horizontalalignment='left')
        self.fig_t2.text(0.82, 0.97, r'$y_0 \exp(-(\frac{x}{T_2})^r)$',
                                horizontalalignment='center', verticalalignment='center')


        self.canvas_t2 = FigureCanvasTkAgg(self.fig_t2, self.frame_plot)
        self.canvas_t2._tkcanvas.pack()

        self.Fill_plot()
        self.Fitting_frame()
        
    def Fitting_frame(self, event=None):
        '''Initializes/repacks the fitting frame, depending on the selected fitting function'''
        #repack
        try:
            self.frame_fit.destroy()
        except:
            pass
        #fit frame
        self.frame_fit = tk.Frame(self, bd=5)
        self.frame_fit.pack(side='left', anchor='n', fill='y')

        #fit functions
        def Fit_exponential(x, T2=0.001, y0=1000, r=1):
            '''T2 exponential fit model'''
            return y0*np.exp(-(x/T2)**r)

        def Fit_2exponential(x, T21=0.001, T22=0.01, y01=100, y02=100, r=1):
            '''T2 double exponential decay model'''
            return y01*np.exp(-x/T21) + y02*np.exp(-x/T22)\

        def Fit_exp_gauss(x, T21=0.001, T22=0.01, y01=100, y02=100, r=1):
            '''T2 exponential plus gaussian model'''
            return y01*np.exp(-x/T21) + y02*np.exp(-(x/T22)**2)

        def Fit_exp_gauss_2(x, T21=0.001, T22=0.01, y0=100, r=1):
            '''T2 exponential and gaussian model'''
            return y0*np.exp(-x/T21 -(x/(2*T22))**2)

        #fit start point estimates
        yy1=self.trace.area_list[0]
        yy2=self.trace.area_list[5]
        xx1=self.trace.tau_list[0]
        xx2=self.trace.tau_list[5]
        kk=(yy2-yy1)/(xx2-xx1)
        nn=yy1-kk*xx1

        #reference to functions   #[self.trace.tau_list[self.trace.mean_range[1]]
        # [function, fit_params, start guess, label, tex_form]

        self.fit_names = {'Single Exp':[Fit_exponential, ['T2', 'y0', 'r'], [-nn/kk, nn, 1],
                                        'y0*exp(-(x/T2)^r)'],
                          'Double Exp':[Fit_2exponential, ['T21','T22', 'y01', 'y02', 'r'],
                                        [-nn/kk, -nn/kk*10, nn/2, nn/2, 1],
                                        'y01*exp(-x/T21)+y02*exp(-x/T22)'],
                          'Gauss Exp':[Fit_exp_gauss, ['T21','T22', 'y01', 'y02', 'r'],
                                        [-nn/kk, -nn/kk, nn/2, nn/2, 1],
                                        'y01*exp(-x/T21)+y02*exp((-x/T22)**2)'],
                          'Gauss Exp 2':[Fit_exp_gauss_2, ['T21','T22', 'y0', 'r'],
                                        [-nn/kk, -nn/kk, nn/2, 1],
                                        'y0*exp(-x/T21 -(x/(2*T22))**2 )']
                         }

        
        def Fit():
            '''Executes the fit with given parameters and plots it'''
            Fit_function = self.fit_names[self.combo_fit_var.get()][0]
            #read values from entry boxes
            start_params = dict()
            for entry,param in zip(self.entry_params_start, param_list):
                start_params[param]=float(entry.get())
            #data points
            x = np.array(self.trace.tau_list)*2
            y = self.trace.area_list
            y_start = [Fit_function(xx, **start_params) for xx in x]

            #check if last parameter is enabled or not
            p_start = [start_params[key] for key in param_list]
            if not self.check_params_start_var.get():
                r_tmp = p_start.pop(-1)
                self.entry_params_fit[-1].config(state='normal')
                self.entry_params_fit[-1].delete(0, 'end')
                self.entry_params_fit[-1].insert('end', 1)
                self.entry_params_fit[-1].config(state='readonly')

            #run fit, p_optimal, p_covariance matrix
            if not self.check_params_start_var.get():
                popt,pcov = curve_fit(lambda x, *param_list: Fit_function(x, *param_list, r=r_tmp), x, y, p0=p_start)
            else:
                popt,pcov = curve_fit(Fit_function, x, y, p0=p_start)
            #readd last parameter
            if not self.check_params_start_var.get():
                popt = np.append(popt, r_tmp)
            y_fit = [Fit_function(xx, *popt) for xx in x]

            #print values to entry boxes
            for i,p in enumerate(popt):
                self.entry_params_fit[i].config(state='normal')
                self.entry_params_fit[i].delete(0, 'end')
                self.entry_params_fit[i].insert('end','%.4g' %p)
                self.entry_params_fit[i].config(state='readonly')

            #update plots
            self.axes_start_plot.set_ydata(y_start)
            self.axes_fit_plot.set_ydata(y_fit)
            self.fig_t2.canvas.draw()

            #save parameters
            self.trace.fit_params = popt
            self.trace.fit_param_cov = pcov
            self.trace.fit_fun = self.combo_fit_var.get()
            self.trace.T2 = popt[0]
            #if self.check_params_start_var.get():
            self.trace.r = popt[-1]
            #else:
            #    self.trace.r = 1

            self.Refresh_parameters()

        def Change_fit(event=None):
            '''Changes the current fitting function'''
            #update memory in parent
            self.parent.temperatures.previous_t2['fit']=self.combo_fit_var.get()
            #reload
            self.Fitting_frame()
            #rerun
            #Fit()

       
        #implement more options later if necessary
        self.label_fit = tk.Label(self.frame_fit, text='Fitting function')
        self.label_fit.pack(side='top')

        self.combo_fit_var = tk.StringVar()
        try:
            self.combo_fit_var.set(self.parent.temperatures.previous_t2['fit'])
        except KeyError:
            self.combo_fit_var.set('Single Exp')
            self.parent.temperatures.previous_t2['fit']='Single Exp'
             
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

        self.check_params_start_var = tk.BooleanVar(self, 0)
        self.check_params_start = (ttk.Checkbutton(self.frame_params_start[-1],
                                                   variable=self.check_params_start_var))
        self.check_params_start.pack(side='left')
            
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

        #add button to confirm selection
        self.button_confirm = ttk.Button(self.frame_fit, text='Confirm', command=self.Confirm)
        self.button_confirm.pack(side='bottom')
        self.button_confirm.bind('<Return>', self.Confirm)

        #export csv button
        self.button_export = ttk.Button(self.frame_fit, text='Export CSV', command=self.Export)
        self.button_export.pack(side='bottom')
        self.button_export.bind('<F5>', self.Export)

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
        for item in GLOBAL_t2_displayed_params:
            try:
                pair = (item, self.trace.__dict__[item])
                self.tree_parameters.insert('', 'end', values=pair)
            except: pass

    def Export(self, event=None):
        '''Saves the datapoints of the plot to a CSV file'''
        file_name = self.trace.file_key  + '.csv'
        file_directory = os.path.join('data', self.parent.current_experiment, 'csv', 'T2_raw', )

        #make the csv folder for old experiments
        try:
            os.mkdir(file_directory)
        except: pass

        #write file
        with open(os.path.join(file_directory, file_name), 'w', newline='') as f:
            writer = csv.writer(f, delimiter=';')
            #name row
            writer.writerow(['tau(s)', 'Signal(a.u.)'])
            #data
            for i in range(len(self.trace.tau_list)):
                row = [self.trace.tau_list[i], self.trace.area_list[i]]
                writer.writerow(row)

        tk.messagebox.showinfo('Export complete', 'The file was saved as '+file_name)

    def Fill_plot(self):
        '''Plots the T1 trend and fits it'''
        #data lines
        x = np.array(self.trace.tau_list)*2
        y = np.array(self.trace.area_list)

        #T1 plot
        self.axes = self.fig_t2.add_subplot(111)
        self.axes.plot(x, y, 'bo', color=colors[1], label='Data')
        self.axes_start_plot, = self.axes.plot(x, y, color=colors[3],
                                               linestyle='dashed', label='Fit start')
        self.axes_fit_plot, = self.axes.plot(x, y, color=colors[4], label='Fit')
        self.axes.axvline(x=x[self.trace.mean_range[1]], color=colors[2])
        self.axes.set_yscale('log')
        self.axes.set_title('T2')
        self.axes.set_xlabel(r'2*$\tau$ ($\mu$s)')
        self.axes.set_ylabel('Signal')
        legend = self.axes.legend(loc='lower right')
        self.axes.grid()


class Frame_plot_T2_t2vt(tk.Frame):
    '''T2vT trend plotting'''
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
        self.fig_t2vt = plt.figure(dpi=100, figsize=(7,4.5))
        self.fig_t2vt.subplots_adjust(bottom=0.12, left= 0.11, right=0.96, top=0.94)
        self.canvas_t2vt = FigureCanvasTkAgg(self.fig_t2vt, self.frame_plot1)
        self.canvas_t2vt._tkcanvas.pack()

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
        self.button_confirm.pack(side='right', anchor='e')
        self.button_confirm.bind('<Return>', Confirm)

        self.Fill_plot()

        #add button to export to csv
        self.button_export = ttk.Button(self.frame_buttons, text='Export CSV', command=self.Export)
        self.button_export.pack(side='right', anchor='e')

    def Add_trace(self, trace):
        '''Adds traces to plots using given trace'''
        #initialize lists
        x = list()
        y = list()
        fr = list()
        r = list()

        #prepare all items for export
        popts = list()
        pcovs = list()

      
        
        for temp in self.trace:
            if self.trace[temp].analysed and not self.trace[temp].disabled:

                x.append(temp)
                y.append(self.trace[temp].T2)
                #maby calculate some center frequency at some point?
                fr.append(self.trace[temp].fr)
                #get stretch
                try:
                    r.append(self.trace[temp].r)
                except AttributeError:
                    r.append(1)
                #get second T2
                except AttributeError:
                    yb.append(1)
                name = self.trace[temp].file_key

                popts.append(self.trace[temp].fit_params)
                pcovs.append(self.trace[temp].fit_param_cov)
                
        #sort by temperature
        sorting = np.argsort(x)
        x = np.array(x)[sorting]
        y = np.array(y)[sorting]
        y2 = 1/y
        fr = np.array(fr)[sorting]
        r = np.array(r)[sorting]
        popts = np.array(popts)[sorting]
        pcovs = np.array(pcovs)[sorting]

        #draw trace
        self.axes_1.plot(x, y2, 'bo', color=colors[self.counter],
                         label=self.parent.current_trace, linestyle='dashed')
        self.axes_2.plot(x, fr, 'bo', color=colors[self.counter],
                         label=self.parent.current_trace, linestyle='dashed')
        self.axes_3.plot(x, r, 'bo', color=colors[self.counter],
                         label=self.parent.current_trace, linestyle='dashed')


        #save for export
        self.data = dict()
        self.data['T'] = x
        self.data['T2'] = y
        self.data['fr'] = fr
        self.data['r'] = r
        self.data['popts'] = popts
        self.data['pcovs'] = pcovs

        #increase plot counter
        self.counter += 1

    def Export(self):
        '''Saves the plotted data into a CSV file for further analysis'''
        file_name = self.parent.current_trace + '.csv'
        file_directory = os.path.join('data', self.parent.current_experiment, 'csv', 'T2')

        #make the csv folder for old experiments
        try:
            os.mkdir(file_directory)
        except: pass

        #write file
        with open(os.path.join(file_directory, file_name), 'w', newline='') as f:
            writer = csv.writer(f, delimiter=';')
            #name row
            writer.writerow(['T(K)', 'T2(s)', 'fr(MHz)', 'r', 'popts'])
            #data
            for i in range(len(self.data['T'])):
                row = [self.data['T'][i], self.data['T2'][i], self.data['fr'][i], self.data['r'][i]] + list(self.data['popts'][i])
                writer.writerow(row)

        tk.messagebox.showinfo('Export complete', 'The file was saved as '+file_name)

    def Fill_plot(self):
        '''Creates the plots for T2vT'''

        self.axes_1 = self.fig_t2vt.add_subplot(111)
        self.axes_1.set_xscale('log')
        self.axes_1.set_yscale('log')
        self.axes_1.set_title('T2 temperature dependence')
        self.axes_1.set_xlabel('Temperature (K)')
        self.axes_1.set_ylabel(r'1/T2 (1/$\mu$s)')
        #self.axes_1.legend(loc='lower right')
        self.axes_1.grid()

        self.axes_2 = self.fig_fr.add_subplot(111)
        self.axes_2.set_title('Center frequencies')
        self.axes_2.set_xlabel('Temperature (K)')
        self.axes_2.set_ylabel('Frequency (MHz)')
        #self.axes_2.get_yaxis().get_major_formatter().set_useOffset(False)
        self.axes_2.margins(0.05, 0.1)
        self.axes_2.grid()

        self.axes_3 = self.fig_r.add_subplot(111)
        self.axes_3.set_title('Stretch')
        self.axes_3.set_xlabel('Temperature (K)')
        self.axes_3.set_ylabel('Stretch r')
        #self.axes_3.get_yaxis().get_major_formatter().set_useOffset(False)
        self.axes_3.margins(0.05, 0.1)
        self.axes_3.grid()