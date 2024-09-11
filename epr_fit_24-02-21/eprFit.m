function varargout = eprFit(varargin)
% EPRFIT M-file for eprFit.fig
%      EPRFIT, by itself, creates a new EPRFIT or raises the existing
%      singleton*.
%
%      H = EPRFIT returns the handle to a new EPRFIT or the handle to
%      the existing singleton*.
%
%      EPRFIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EPRFIT.M with the given input arguments.
%
%      EPRFIT('Property','Value',...) creates a new EPRFIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eprFit_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eprFit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% List_Box the above text to modify the response to help eprFit

% Last Modified by GUIDE v2.5 29-Sep-2023 11:53:14
% eprFit v4.6 by Anton Potoènik
% eprFit v5.0 by Peter Lekše sep 2023

% Begin initialization code - DO NOT LIST_BOX
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eprFit_OpeningFcn, ...
                   'gui_OutputFcn',  @eprFit_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT LIST_BOX


% --- Executes just before eprFit is made visible.
function eprFit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eprFit (see VARARGIN)

% Choose default command line output for eprFit
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using eprFit.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5,1));
end

% UIWAIT makes eprFit wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Initialize popFunctions, popSimFun and popGlobFun
funs = fun_lib('');  % Get functions name cell
set(handles.popFunctions, 'String',funs);
funs = fun_lib_glob('');  % Get functions name cell
set(handles.popGlobFun, 'String', funs);
funs = fun_lib_sim('');  % Get functions name cell
set(handles.popSimFun, 'String',funs);

% Set pointer values to guidata
pointers.H1 = 0;
pointers.H2 = 0;
set(handles.figure1,'UserData',pointers);   % Set pointers to figure1
set(handles.txtSell,'BackgroundColor',get(handles.figure1,'Color'));
set(handles.txtVersion,'BackgroundColor',get(handles.figure1,'Color'));


% Create epr default sturcture in does not exist 
if evalin('base','exist(''epr'',''var'')') == 0
   createDefEprStruct();
else
    if strcmp(get(hObject,'Visible'),'off')
        epr = evalin('base','epr');
        epr.glob.coef_names = [];
        epr.glob.shared_idxs = [];
        assignin('base','epr',epr);
    end
end



% User Function Create Default epr structure in base work space
function createDefEprStruct()

    evalin('base','epr.material=''DPPH'';');
    evalin('base','epr.mass=0.0;');
    evalin('base',['epr.date=''' datestr(now,'dd-mm-yyyy') ''';']);
    evalin('base','epr.fit.fits={};');
    evalin('base','epr.glob.file_idxs=[];');
    evalin('base','epr.glob.coef_names={};');
    evalin('base','epr.glob.shared_idxs=[];');
    evalin('base','epr.nra=[];');
    evalin('base','epr.sim={};');
    disp(['Default epr structure (DPPH / 0mg / ' datestr(now,'dd-mm-yyyy') ')']);




% --- Outputs from this function are returned to the command line.
function varargout = eprFit_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --------------------------------------------------------------------
function PrintMenuItem_Callback(~, eventdata, handles)

    printdlg(handles.figure1)



% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)

    selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                         ['Close ' get(handles.figure1,'Name') '...'],...
                         'Yes','No','Yes');
    if strcmp(selection,'No')
        return;
    end

    delete(handles.figure1)



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on selection change in lbFiles.
function lbFiles_Callback(hObject, eventdata, handles)

    eprplot(handles);
    epr_update(hObject, eventdata, handles);



% --- Executes during object creation, after setting all properties.
function lbFiles_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    if evalin('base','exist(''epr'',''var'')') == 1
        epr = evalin('base','epr');
        if isfield(epr,'data')
            for i=1:numel(epr.data)
                [pathstr, name, ext] = fileparts(epr.data{i}.fname);
                shownames{i} = [num2str(i) ' ' name];
            end
            set(hObject, 'String', shownames);
        else
            set(hObject, 'String', []);
        end
    else
        set(hObject, 'String', []);
    end






% --- Executes during object creation, after setting all properties.
function popFunctions_CreateFcn(hObject, ~, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butFitAdd.
function butFitAdd_Callback(hObject, eventdata, handles)

    func_num = get(handles.popFunctions, 'Value');
    func_list = get(handles.popFunctions, 'String');
    list_sel = get(handles.lbFunctions, 'String');
    coefs = get(handles.uitFit, 'Data');
    param_num = size(coefs,1);

    % Delete empty rows
    rm = [];
    for i=1:param_num
       if strcmp(coefs{i,1},'') 
           rm = [rm i];
       end
    end
    coefs(rm,:)=[];
    param_num = size(coefs,1);

    % Search for s*x and y0
    count_sx = 0;
    count_y0 = 0;
    max_number=0;
    for i=1:numel(list_sel)
         if strcmp('s*x',list_sel{i})
             count_sx = count_sx+1;
         elseif strcmp('y0',list_sel{i})
             count_y0 = count_y0+1;
         else
            numb = str2double(list_sel{i}(~isletter(list_sel{i})));
            if numb > max_number
                max_number = numb;
            end
         end
    end

    apend = num2str(max_number+1);
    % Only one term of s*x and y0 is allowed
    if strcmp(func_list{func_num},'s*x') 
        if count_sx > 0 
            return
        else
            apend = '';
            vrstica = {'s',0,-Inf,Inf,false, '', 1};
            coefs = [coefs; vrstica];
            set(handles.uitFit, 'Data', coefs);
        end
    elseif strcmp(func_list{func_num},'y0')
        if count_y0 > 0 
            return
        else
            apend = '';
            vrstica = {'y0',0,-Inf,Inf,false, '', 1};
            coefs = [coefs; vrstica];
            set(handles.uitFit, 'Data', coefs);
        end

    % elseif strcmp(func_list{func_num},'dLorentz')

    % elseif strcmp(func_list{func_num},'dGauss')

    % elseif strcmp(func_list{func_num},'dDyson')

    else
        ft = fittype(fun_lib(func_list{func_num}),'indep','x');
        cnames = coeffnames(ft);

        for j=1:numel(cnames)
            vrstica = {[cnames{j} apend],0,0,Inf,false, '', 1};
            coefs = [coefs; vrstica];
            set(handles.uitFit, 'Data', coefs);
        end

    end


    % Add function
    list_sel{numel(list_sel)+1} = [func_list{func_num} apend];
    set(handles.lbFunctions, 'Value',1);
    set(handles.lbFunctions, 'String',list_sel);


% --- Executes during object creation, after setting all properties.
function lbFunctions_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function lbParameters_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butFitRem.
function butFitRem_Callback(hObject, eventdata, handles)

    list_sel = get(handles.lbFunctions, 'String');
    list_num = get(handles.lbFunctions, 'Value');
    coefs = get(handles.uitFit,'Data');

    % Get Function number
    tmp = list_sel{list_num};
    tmp(isletter(tmp)) = [];                % remove lettters
    if strcmp(tmp,'')
        number = '0';
    else
        number = tmp;
    end

    % Find parameters with function number
    rem = [];
    for i=1:size(coefs,1)
        if strfind(coefs{i,1},number)
            rem = [rem i];
        end
    end
    % Find s parameter
    if strcmp(list_sel{list_num},'s*x')
        rem = [];
        for i=1:size(coefs,1)
            if strfind(coefs{i,1},'s')
                rem = [rem i];
            end
        end
    end
    % Find y0 parameter
    if strcmp(list_sel{list_num},'y0')
        rem = [];
        for i=1:size(coefs,1)
            if strfind(coefs{i,1},'y0')
                rem = [rem i];
            end
        end
    end
    

    if ~strcmp(list_sel{list_num},'y0') && ~strcmp(list_sel{list_num},'s*x')
        % change number order for functions
        for i=list_num:numel(list_sel)
            if ~strcmp(list_sel{i},'y0') && ~strcmp(list_sel{i},'s*x')
                par = list_sel{i};
                name = par; name(~isletter(name))=[];
                number = par; number(isletter(number))=[];
                number = str2double(number)-1;
                list_sel{i} = [name num2str(number)];
            end
        end
        
        % change number order for coefficients
        for i=rem(1):size(coefs,1)
            if ~strcmp(coefs{i,1},'y0') && ~strcmp(coefs{i,1},'s')
                par = coefs{i,1};
                name = par; name(~isletter(name))=[];
                number = par; number(isletter(number))=[];
                number = str2double(number)-1;
                coefs{i,1} = [name num2str(number)];
            end
        end
    end
    
    % Remove parameters
    coefs(rem,:)=[];
    
    % Remove function
    list_sel(list_num) = [];
    
    % write fields
    set(handles.uitFit,'Data',coefs);
    set(handles.lbFunctions, 'String',list_sel);

    % Set function value
    if list_num > 1
        set(handles.lbFunctions, 'Value',list_num-1);
    else
        set(handles.lbFunctions, 'Value',1);
    end




% --- Executes on button press in butPlotFunc.
function butPlotFunc_Callback(hObject, eventdata, handles)

    axes(handles.axes1);
    if strcmp(ylim('mode'),'manual')
        yLims = ylim;
    end
    if strcmp(xlim('mode'),'manual')
        xLims = xlim;
    end

    cla;

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');

    plot(epr.data{idx}.H,epr.data{idx}.Y,'b');
    hold on

    [funstr Nfun] = getEquation(handles);
    coefs = get(handles.uitFit,'Data');
    % Copy linked values (only the first occurence is needed) -------------
    links = {}; % {link name, fixed?}
    for i = 1:size(coefs, 1)

        if size(coefs, 2) >= 6
            link = coefs{i,6};  % Safe to access the 6th column
        else
            link = '';  % Or handle the situation where link is missing
        end

        if size(coefs, 2) >= 7
            value = coefs{i,2} / coefs{i,7};  % Safe to access the 7th column
        else
            % Handle the case where the 7th column does not exist
            value = coefs{i,2};  % Default behavior if the 7th column is missing
        end % normalized value

        if ~isempty(link) % is linked
            linkFound = false;
            for j = 1:size(links,1)
                if strcmp(links{j,1},link) % link found
                    linkFound = true;
                    if coefs{i,5} && ~links{j,2} % if current is fixed but not all linked are
                        for k = 1:size(coefs,1) % all linked are set to fixed
                            if strcmp(coefs{k,6},link)
                                coefs{k,5} = true;
                            end
                        end
                    end
                end
            end
            if ~linkFound % this is the first link
                for j = i+1:size(coefs,1)
                    if strcmp(coefs{j,6},link)
                        coefs{j,2} = value * coefs{j,7}; % all links after this are overwritten to scale
                        if coefs{i,5}
                            coefs{j,5} = true; % if first one is fixed all others get fixed too
                        end
                    end
                end
                links(end+1,:) = {link, coefs{i,5}};
            end
        end
    end
    % disp(coefs);
    set(handles.uitFit,'Data', coefs);               
    %----------------------------------------------------------------------
    coefstr = coefs(:,1);
    coefval = coefs(:,2);
    fty = fittype(funstr,'coef',coefstr);
    tmp='';
    for i=1:numel(coefval)  % write parameters in cfit function
       tmp = [tmp ',' num2str(coefval{i})];  
    end

    range = get(handles.edtFitRange, 'String');
    % [H Y] = extrange(H*1000,Y,range);
    % if isfield(epr.fit,'range')
    [H Y] = extrange(epr.data{idx}.H,epr.data{idx}.Y,range);
    epr.fit.range = range;
    % else
    %     H = epr.data{idx}.H;
    %     Y = epr.data{idx}.Y;
    % end
    H = reshape(H,[],1);
    Y = reshape(Y,[],1);

    cf = eval(['cfit(fty' tmp ');']);
    cf = reshape(cf(H),size(H));
    plot(H,cf,'r');

    plot(H,Y-cf,'g');
    
    % Plot components
    if get(handles.chkShowComp,'value') == 1
        for i=1:Nfun
            funstr = getEquation(handles,i);
            if strcmp(funstr,' + y0')
                funstr = '0*x + y0';
            end
            futy = fittype(funstr);
            cs = coeffnames(futy);

            tmp='';
            for j=1:numel(cs)  % write parameters in cfit function
                ind = cellfun(@(x) isequal(x,cs{j}),coefstr);
                tmp = [tmp ',' num2str(coefval{ind})];  
            end
            cf = eval(['cfit(futy' tmp ');']);
            cf = reshape(cf(H),size(H));
            plot(H,cf,'c');

        end
    end
    hold off

    if exist('yLims','var')
        ylim(yLims);
    end

    if exist('xLims','var')
        xlim(xLims);
    else
        if H(1) < H(end)
            xlim([H(1) H(end)]);
        else
            xlim([H(end) H(1)]);
        end
    end

    legend([num2str(epr.temp(idx)) 'K'],'Fit','Data - Fit');
    xlabel('H (mT)');
    ylabel('dP/dH (a.u.)');
    grid on
    backupFit(handles);




% --- Executes on button press in butFitOpts.
function butFitOpts_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');

    if isfield (epr.fit,'opts')
        opts = epr.fit.opts;
    else
        opts = fitoptions('Method','Nonlinear');
        opts.Algorithm =  'Trust-Region';            % 'Trust-Region'  'Levenberg-Marquardt'
        opts.Display =    'notify';                  % 'notify'  'off'  'iter'
        opts.MaxIter = 1000;
        opts.MaxFunEvals = 1000;
        opts.TolFun = 1e-10;
        opts.TolX = 1e-10;
        opts.Robust = 'Off';
    end
    inspect(opts);
        




% --- Executes on button press in butFitFunc.
function butFitFunc_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');

    opts = fitoptions('Method','Nonlinear');
    opts.Display =    'notify';                  % 'notify'  'off'  'iter'

    string_list = get(handles.popMethod,'String');
    val = get(handles.popMethod,'Value');
    opts.Algorithm = string_list{val};   % 'Trust-Region'  'Levenberg-Marquardt'

    opts.MaxIter = str2double(get(handles.edtMaxIter,'String'));
    opts.MaxFunEvals = str2double(get(handles.edtMaxFunE,'String'));
    opts.TolFun = str2double(get(handles.edtTolFun,'String'));
    opts.TolX = str2double(get(handles.edtTolX,'String'));

    string_list = get(handles.popRobust,'String');
    val = get(handles.popRobust,'Value');
    opts.Robust = string_list{val};

    fitfun = getEquation(handles);

    uicoefs = get(handles.uitFit,'Data');

    % Copy linked values (only the first occurence is needed) -------------
    links = {}; % {link name, fixed?}
    for i = 1:size(uicoefs, 1)

        if size(uicoefs, 2) >= 6
            link = uicoefs{i,6};
        else
            link = '';  % Handle case where the 6th column does not exist
        end
        
        if size(uicoefs, 2) >= 7
            value = uicoefs{i,2} / uicoefs{i,7};  % Safe to access the 7th column
        else
            value = uicoefs{i,2};  % Default behavior if the 7th column is missing
        end
        
        if ~isempty(link) % is linked
            linkFound = false;
            for j = 1:size(links,1)
                if strcmp(links{j,1},link) % link found
                    linkFound = true;
                    if uicoefs{i,5} && ~links{j,2} % if current is fixed but not all linked are
                        for k = 1:size(uicoefs,1) % all linked are set to fixed
                            if strcmp(uicoefs{k,6},link)
                                uicoefs{k,5} = true;
                            end
                        end
                    end
                end
            end
            if ~linkFound % this is the first link
                for j = i+1:size(uicoefs,1)
                    if strcmp(uicoefs{j,6},link)
                        uicoefs{j,2} = value * uicoefs{j,7}; % all links after this are overwritten to scale
                        if uicoefs{i,5}
                            uicoefs{j,5} = true; % if first one is fixed all others get fixed too
                        end
                    end
                end
                links(end+1,:) = {link, uicoefs{i,5}};
            end
        end
    end
    % disp(coefs);
    set(handles.uitFit,'Data', uicoefs);               
    %----------------------------------------------------------------------
    
    
    epr.fit.options = opts;
    epr.fit.chosen = idx;     % Simulate only selected
    epr.fit.fitfun = fitfun;
    epr.fit.coef = uicoefs; % coef;
    epr.fit.plot = 0;   % Please do NOT plot fitted specters and results
    epr.fit.range = get(handles.edtFitRange, 'String');
    if numel(idx) == 1
        epr.fit.fits{idx}.uicoefs = uicoefs;
    end

    idx_curr=idx;
    EPR_fit;

    % Refresh new coefficients
    coef_names  = epr.fit.coef(:,1)'; % fieldnames(epr.fit.coef)';

    if (size(epr.fit.results,2)-2)/2 ~= size(uicoefs,1)
        return
    end
    for i=1:(size(epr.fit.results,2)-2)/2
        ind = -1;
        for j=1:size(uicoefs,1)
            if strcmp(uicoefs{j,1},coef_names{i})
                ind = j;
            end
        end
        if ind > 0
            uicoefs{ind,2} = epr.fit.results(idx_curr,i*2);
        end
    end
    set(handles.uitFit,'Data',uicoefs);
    set(handles.txtChi2, 'String',['Chi2 = ' num2str(epr.fit.fits{idx_curr}.gof.sse,'%5.5e')]);

    set(handles.chkPlotFit,'Value',1);
    butPlotFunc_Callback(hObject, eventdata, handles);

    % Save epr
    assignin('base','epr',epr);
    backupFit(handles);




% --- Executes on button press in butRunFitFun.
function butRunFitFun_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    max_idx = numel(get(handles.lbFiles, 'String'));

    prompt = {'start idx:','stop idx:','abs(step):'};
    dlg_title = 'Run fits';
    num_lines = 1;
    def = {num2str(idx),num2str(max_idx),'1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if ~isempty(answer) % If CANCEL, answer is empty
        idx = str2double(answer{1});
        max_idx = str2double(answer{2});
        step = str2double(answer{3});
    else 
        return
    end
    step = sign(max_idx-idx)*abs(step);

    for i = idx:step:max_idx
        set(handles.lbFiles, 'Value',i);
        eprplot(handles);
        getframe;
        butFitFunc_Callback(hObject, eventdata, handles);
        getframe;
    end
    disp('Fit run finished!');



% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popMethod_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edtMaxIter_CreateFcn(hObject, eventdata, handles)
% Hint: list_box controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edtMaxFunE_CreateFcn(hObject, eventdata, handles)
% Hint: list_box controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edtTolFun_CreateFcn(hObject, eventdata, handles)
% Hint: list_box controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edtTolX_CreateFcn(hObject, eventdata, handles)
% Hint: list_box controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function popRobust_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% User function: retruns equation string from lbFunction
function [equ Nfun] = getEquation(handles,i)

    
    list_sel = get(handles.lbFunctions, 'String');
    equ = '';
    Nfun = numel(list_sel);

    if nargin == 1
        list = 1:Nfun;
    elseif nargin == 2
        list = i;
        if i < 1 || i > Nfun
            error(['i must be greater than 1 or smaller then ' num2str(Nfun)])
        end
    else
        error('equ = getEquation(handles,[i]) requires one or two arguments!!!')
    end
    
    for i=list
         if strcmp('s*x',list_sel{i})
            equ = [equ ' + s*x'];
         elseif strcmp('y0',list_sel{i})
            equ = [equ '+ 0*x + y0'];
         else
            number = str2double(list_sel{i}(~isletter(list_sel{i})));
            func = list_sel{i}(isletter(list_sel{i}));
            equ = [equ ' + ' fun_lib(func,number)];
         end
    end


% User function: retruns equation string from lbSimFun
function equ = getSimEquation(handles)

    list_sel = get(handles.lbSimFun, 'String');
    equ = '';

    for i=1:numel(list_sel)
         if strcmp('s*x',list_sel{i})
            equ = [equ ' + s*x'];
         elseif strcmp('y0',list_sel{i})
            equ = [equ ' + y0'];
         else
            number = str2double(list_sel{i}(~isletter(list_sel{i})));
            func = list_sel{i}(isletter(list_sel{i}));
            equ = [equ ' + ' fun_lib_sim(func,number)];
         end
    end




% User function: plots data with fit or simulations
function eprplot(handles)
    idx = get(handles.lbFiles, 'Value');
    chk_Fit = get(handles.chkPlotFit, 'Value');
    chk_Sim = get(handles.chkPlotSim, 'Value');
    chk_X = get(handles.chkPlotX, 'Value');
    chk_Glob = get(handles.chkPlotGlob, 'Value');
    epr = evalin('base','epr');

    LW = 1.0; % LineWidth

    axes(handles.axes1);

    if strcmp(ylim('mode'),'manual')
        yLims = ylim;
        xLims = xlim;
    end

    cla;    % Clear graph

    j=1; % color counter
    leg=1; % legend counter
    for i=idx
        H = epr.data{i}.H; %mT
        Y = epr.data{i}.Y;
        plot(H,Y,colors(j),'LineWidth',LW);
        M{leg} =  [ num2str(epr.temp(i)) ' K'];  %K, deg, pressure %name{i};
        leg=leg+1;
        hold on
        if chk_Fit
            if numel(epr.fit.fits) >= i && ~isempty(epr.fit.fits{i}) 
                plot(H,epr.fit.fits{i}.f(H),'r','LineWidth',LW);
                M{leg} =  'Fit function';  %K, deg, pressure %name{i};
                leg=leg+1;
                set(handles.chkPlotFit,'Enable','on');
%             else
%                 set(handles.chkPlotFit,'Enable','off');
            end
        end
        if chk_Sim
            if numel(epr.sim) >= i &&  ~isempty(epr.sim{i})
                plot(epr.sim{i}.H,epr.sim{i}.Y,'g','LineWidth',LW);
                M{leg} =  'Simulation';  %K, deg, pressure %name{i};
                leg=leg+1;
                
% ... residual plot
                
                % residual = Y - epr.sim{i}.Y;
                % plot(H, residual, 'r--', 'LineWidth', LW); 
                % M{leg} = 'Residual (Sim)'; 
                % leg = leg + 1;

                set(handles.chkPlotSim,'Enable','on');
%             else
%                 set(handles.chkPlotSim,'Enable','off');
            end
        end
        if chk_X
            %if isfield(epr.data{i},'X') now allways is
                plot(H,epr.data{i}.X,'c','LineWidth',LW);
                M{leg} =  'X component';  %K, deg, pressure %name{i};
                leg=leg+1;
                set(handles.chkPlotX,'Enable','on');
            %else
            %    set(handles.chkPlotX,'Enable','off');
            %end
        end
        if chk_Glob
            if ~isempty(epr.glob.fits{i})
                plot(epr.glob.fits{i}.H, epr.glob.fits{i}.Y, 'b', 'LineWidth', LW);
                M{leg} = 'Global fit';
                leg=leg+1;
                set(handles.chkPlotGlob, 'Enable', 'on');
%             else
%                 set(handles.chkPlotGlob, 'Enable', 'off');
            end
        end
        j=j+1;
    end
    
    
    legend(M);

    if exist('yLims','var')
        ylim(yLims);
        xlim(xLims);
    else
        %if H(1) < H(end)
            xlim([H(1) H(end)]);
        %else
        %    xlim([H(end) H(1)]);
        %end
    end

    title([epr.material '  ' num2str(epr.mass) 'mg  ' epr.date '  \nu = ' num2str(epr.freq(idx(end))) ' GHz']);

    hold off
    grid on
    xlabel('H (mT)');
    ylabel('dP/dH (a.u.)');


    
% User function: show description for a specific file
function str = description(epr,i,modal)
    
    if ~isfield(epr.data{i}.exp,'nPoints')
        epr.data{i}.exp.nPoints = numel(epr.data{i}.Y);
    end
    
    str = {['Material: ' epr.material], ...
           ['Mass: ' epr.mass ' mg'], ...
           ['Source: ' epr.data{i}.fname], ...
           ['freq = ' num2str(epr.freq(i)) ' GHz'], ...
           ['temp = ' num2str(epr.temp(i)) ' K'], ...
           ['date = ' epr.dates{i}], ...
           ['H center = ' num2str(epr.data{i}.exp.CenterSweep(1)) ' G'], ...
           ['H sweep = ' num2str(epr.data{i}.exp.CenterSweep(2)) ' G'], ...
           ['nPoints = ' num2str(epr.data{i}.exp.nPoints)]};
    if isfield(epr.data{i}.exp,'Power')
        str{end+1} = ['Power(mW) = ' num2str(epr.data{i}.exp.Power)];
    end
    if isfield(epr.data{i}.exp,'modB')
        str{end+1} = ['ModAmp(V) = ' num2str(epr.data{i}.exp.modB)];
    end
    if isfield(epr.data{i}.exp,'modFreq')
        str{end+1} = ['ModFreq(kHz) = ' num2str(epr.data{i}.exp.modFreq)];
    end
    if isfield(epr.data{i}.exp,'RE_Constant')
        str{end+1} = ['RC constant = ' num2str(epr.data{i}.exp.RC_Constant)];
    end
    
    if modal==true
        msgbox(str,'Sample Description')
    end

    


% User function: updates all epr text boxes
function epr_update(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');
    set(handles.txtSell,'String',['Selected = ' num2str(idx)]);
    if numel(idx)>1
        return
    end
    
    % Show Experimental Description
    str = description(epr,idx,false);
    disp(' ');    
    for i=1:numel(str)
       disp(str{i}) 
    end

    if isfield(epr.nra,'results')
        if size(epr.nra.results,1) >= idx
            set(handles.txtIntensity,'String',['A = ' num2str(epr.nra.results(idx,2))]);
            set(handles.txtW,'String',['w = ' num2str(epr.nra.results(idx,4))]);
            set(handles.txtXc,'String',['xc = ' num2str(epr.nra.results(idx,6))]);
            set(handles.edtBLCorr,'String',['[' num2str(epr.nra.bline_corr) ']']);
            set(handles.edtCutOff,'String',num2str(epr.nra.cutoff));

            methods = get(handles.popWmethod,'String');
            for i=1:size(methods,1)
                if strcmp(methods{i},epr.nra.w_method)
                    set(handles.popWmethod,'Value',i);
                end
            end

            methods = get(handles.popXcmethod,'String');
            for i=1:size(methods,1)
                if strcmp(methods{i},epr.nra.xc_method)
                    set(handles.popXcmethod,'Value',i);
                end
            end
        else
            set(handles.txtIntensity,'String','A = ');
            set(handles.txtW,'String','dH = ');
            set(handles.txtXc,'String','xc = ');    
        end
    else
        set(handles.txtIntensity,'String','A = ');
        set(handles.txtW,'String','dH = ');
        set(handles.txtXc,'String','xc = ');
    end

    if isfield(epr.nra,'results_g')
        if size(epr.nra.results,1) >= idx
            set(handles.txtG,'String',['g = ' num2str(epr.nra.results_g(idx,6))]);
        else
            set(handles.txtG,'String','g = ');
        end
    else
        set(handles.txtG,'String','g = ');
    end




    if get(handles.chkUpdate, 'Value') == 1

        % Update fitting functions
        if ~isempty(epr.fit.fits{idx})
            set(handles.lbFunctions,'String','');
            set(handles.uitFit, 'Data',[]);
            functions = get(handles.popFunctions,'String');

            if isfield(epr.fit,'results')
                for j=1:50   % Test for 50 function of the same type
                    for i=1:numel(functions)-2
                        testfun = fun_lib(functions{i},j);
                        if ~iscell(testfun)  % Search only among found functions - unknown name results in cell array of known functions
                            k = strfind(epr.fit.fitfun, testfun);
                            if isempty(k)
                                ttfun = testfun;
                                ttfun(strfind(ttfun,'+'))=[];
                                ttfun(strfind(ttfun,'-'))=[];
                                fffun = epr.fit.fitfun;
                                fffun(strfind(fffun,'+'))=[];
                                fffun(strfind(fffun,'-'))=[];
                                k = strfind(fffun, ttfun);
                                if k > 0
                                    msgbox(['Function found was without + or - !!! =>' functions{i}]);
                                end
                            end
                            if k > 0
                                set(handles.popFunctions,'Value',i)
                                butFitAdd_Callback(hObject, eventdata, handles);
                                break;
                            end
                        end
                    end
                end

                % Separeated because they have only one instance - no number at the
                % end
                k = strfind(epr.fit.fitfun, 's*x');
                if k > 0
                    set(handles.popFunctions,'Value',numel(functions)-1)
                    butFitAdd_Callback(hObject, eventdata, handles);
                end
                k = strfind(epr.fit.fitfun, 'y0');
                if k > 0
                    set(handles.popFunctions,'Value',numel(functions))
                    butFitAdd_Callback(hObject, eventdata, handles);
                end
            end

            % Refresh new coefficients
            if isfield(epr.fit,'results') && size(epr.fit.results,1) >= idx
                coef_names  = epr.fit.coef(:,1)';
                idx = get(handles.lbFiles, 'Value');
                if isfield(epr.fit.fits{idx},'uicoefs')
                    coefs = epr.fit.fits{idx}.uicoefs;
                else
                    coefs = get(handles.uitFit,'Data');
                    for i=1:(size(epr.fit.results,2)-2)/2  % Omit error values
                        ind = -1;
                        for j=1:size(coefs,1)
                            if strcmp(coefs{j,1},coef_names{i})
                                ind = j;
                            end
                        end
                        if ind > 0
                            coefs{ind,2} = epr.fit.results(idx,i*2);
                        else
                            disp(['ERROR: ' coef_names{i} ' coefficient not found!!!']);
                        end
                    end
                end
                set(handles.uitFit,'Data',coefs);
                set(handles.txtChi2, 'String',['Chi2 = ' num2str(epr.fit.fits{idx}.gof.sse,'%5.5e')]);
            end
        end


        % Update simulation function
        i=idx(end);
        if i<=numel(epr.sim) && ~isempty(epr.sim{i})
            if isfield(epr.sim{i},'coefs')     % New version
                set(handles.lbSimFun, 'String', epr.sim{i}.SimFuncs);
                set(handles.uitSim, 'Data', epr.sim{i}.coefs);
                set(handles.edtNpwdr,'String',num2str(epr.sim{idx}.Nstep)); 
                set(handles.edtSimNOP,'String',num2str(epr.sim{idx}.NOP));
                set(handles.edtSimRange,'String',num2str(epr.sim{idx}.range));
                set(handles.txtSimChi, 'String', ['Chi2 = ' num2str(epr.sim{idx}.chi2)]);
                set(handles.edtRep,'String',num2str(epr.sim{idx}.rep));
                set(handles.edtSimIter,'String',num2str(epr.sim{idx}.NIter));
                set(handles.edtSimFunTol,'String',num2str(epr.sim{idx}.FunTol));
                set(handles.edtSimXTol,'String',num2str(epr.sim{idx}.XTol));

            elseif isfield(epr.sim{i},'gx')     % Old version
               disp(['Temp = ' num2str(epr.temp(idx)) '   Freq = ' num2str(epr.freq(idx))])
               if epr.sim{idx}.type == 1, disp('---powdersimu: Lorentz'); end;
               if epr.sim{idx}.type == 2, disp('---powdersimu: Gauss'); end;
               disp(['A = ' num2str(epr.sim{idx}.A)])
               disp(['g[x,y,z] = [' num2str([epr.sim{idx}.gx epr.sim{idx}.gy epr.sim{idx}.gz]) ']'])
               disp(['dH[x,y,z] = [' num2str([epr.sim{idx}.dHx epr.sim{idx}.dHy epr.sim{idx}.dHz]) ']'])
               disp(['phase = ' num2str(epr.sim{idx}.phase)])
               disp('---Lorentzian')
               disp(['B = ' num2str(epr.sim{idx}.B)])
               disp(['W = ' num2str(epr.sim{idx}.W)])
               disp(['Hc = ' num2str(epr.sim{idx}.Hc)])
               disp(['Phi = ' num2str(epr.sim{idx}.Phi)])
               disp(['s = ' num2str(epr.sim{idx}.s)])
               disp(['y0 = ' num2str(epr.sim{idx}.y0)])
               set(handles.edtSimRange,'String',num2str(epr.sim{idx}.range));
               set(handles.edtSimNOP,'String',num2str(epr.sim{idx}.NOP));
            end
            if isfield(epr.sim{i},'ES')     % New version 4.3
                set(handles.edtES,'String',epr.sim{idx}.ES);
            end
        end

    end
    
    % Update calibration edit boxes
    if isfield(epr, 'cal')
        set(handles.edtCalibrate,'String',epr.cal.params); 
        set(handles.txtCalibrate,'String',epr.cal.chi);
        set(handles.txtCalN,'String',epr.cal.N);
    end




% --- Executes on button press in butPointer1.
function butPointer1_Callback(hObject, eventdata, handles)

    [H Y but] = ginput(1);

    idx = get(handles.lbFiles, 'Value');
    idx = idx(end);
    epr = evalin('base','epr');
    g = xc2g(H,epr.freq(idx));

    set(handles.butPointer1, 'String',['H = ' num2str(H,'%10.1f') ' mT   g = ' num2str(g)])
    pointers = get(handles.figure1,'UserData');   % Get pointers from figure1
    pointers.H1 = H;
    set(handles.figure1,'UserData',pointers);     % Set pointers to figure1

    
    dH = abs(pointers.H1-pointers.H2);
    set(handles.txtdH, 'String',['dH = ' num2str(dH,'%10.1f') ' mT']);
    
    if but == 1
        num2clip(round(H*1e3)/1e3);
        disp(['Pointer1: H = ' num2str(H,'%10.3f') ' mT   Y = ' num2str(Y,'%10.5e') ';  H copied to clipboard']);
    else
        num2clip(Y);
        disp(['Pointer1: H = ' num2str(H,'%10.3f') ' mT   Y = ' num2str(Y,'%10.5e') ';  Y copied to clipboard']);
    end



% --- Executes on button press in butPointer2.
function butPointer2_Callback(hObject, eventdata, handles)

    [H Y but] = ginput(1);
    
    disp(['Pointer2: H = ' num2str(H,'%10.3f') ' mT   Y = ' num2str(Y,'%10.5e') ';   H copied to clipboard']);
    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');
    g = xc2g(H,epr.freq(idx));

    set(handles.butPointer2, 'String',['H = ' num2str(H,'%10.1f') ' mT   g = ' num2str(g)])
    pointers = get(handles.figure1,'UserData');   % Get pointers from figure1
    pointers.H2 = H;
    set(handles.figure1,'UserData',pointers);     % Set pointers to figure1

    dH = abs(pointers.H1-pointers.H2);
    set(handles.txtdH, 'String',['dH = ' num2str(dH,'%10.1f') ' mT']);

    if but == 1
        num2clip(round(H*1e3)/1e3);
        disp(['Pointer1: H = ' num2str(H,'%10.3f') ' mT   Y = ' num2str(Y,'%10.5e') ';  H copied to clipboard']);
    else
        num2clip(Y);
        disp(['Pointer1: H = ' num2str(H,'%10.3f') ' mT   Y = ' num2str(Y,'%10.5e') ';  Y copied to clipboard']);
    end



% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)



% --- Executes on button press in butNAnalyse.
function butNAnalyse_Callback(hObject, eventdata, handles)

    blcorr = eval(get(handles.edtBLCorr,'String'));
    cutoff = str2double(get(handles.edtCutOff,'String'));
    wmeth = get(handles.popWmethod,'String');
    val = get(handles.popWmethod,'Value');
    wmeth = wmeth{val};
    xcmeth = get(handles.popXcmethod,'String');
    val = get(handles.popXcmethod,'Value');
    xcmeth = xcmeth{val};

    idx = get(handles.lbFiles, 'Value');
    names = get(handles.lbFiles, 'String');
    epr = evalin('base','epr');
    H = epr.data{idx}.H;
    Y = epr.data{idx}.Y;

    range = get(handles.edtNRArange, 'String');
    [H Y] = extrange(H,Y,range);

    [Z, A, w, xc] = nranalysis(H, Y, blcorr, cutoff, wmeth, xcmeth);

    cla;
    plot(H,Z);
    if H(1) < H(end)
        xlim([H(1) H(end)]);
    else
        xlim([H(end) H(1)]);
    end
    grid on
    legend([num2str(epr.temp(idx)) 'K']);
    xlabel('H (mT)');
    ylabel('P (a.u.)');

    g = xc2g(xc,epr.freq(idx));
    set(handles.txtIntensity,'String',['A = ' num2str(A)]);
    set(handles.txtW,'String',['w = ' num2str(w)]);
    set(handles.txtXc,'String',['xc = ' num2str(xc)]);
    set(handles.txtG,'String',['g = ' num2str(g)]);

    disp(' ');
    disp([names{idx} ':']);
    disp(['A = ' num2str(A)]);
    disp(['w = ' num2str(w)]);
    disp(['xc = ' num2str(xc)]);
    disp(['g = ' num2str(g)]);

    % Save results
    epr.nra.chosen = idx;
    epr.nra.cutoff = cutoff;
    epr.nra.bline_corr = blcorr;  % Gauss
    epr.nra.w_method = wmeth;
    epr.nra.xc_method = xcmeth;
    epr.nra.plot = 0;   % False
    epr.nra.results(idx,:) = [epr.temp(idx) A 0 w 0 xc 0];
    epr.nra.results_g(idx,:) = [epr.temp(idx) A 0 w 0 g 0];
    assignin('base','epr',epr);



% --- Executes during object creation, after setting all properties.
function popWmethod_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function popXcmethod_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edtCutOff_CreateFcn(hObject, eventdata, handles)

% Hint: list_box controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edtBLCorr_CreateFcn(hObject, eventdata, handles)

% Hint: list_box controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in chkPlotFit.
function chkPlotFit_Callback(hObject, eventdata, handles)


% --- Executes on button press in chkUpdate.
function chkUpdate_Callback(hObject, eventdata, handles)


% --- Executes on selection change in lbFunctions.
function lbFunctions_Callback(hObject, eventdata, handles)



% --- Executes on selection change in popWmethod.
function popWmethod_Callback(hObject, eventdata, handles)


% --- Executes on selection change in popXcmethod.
function popXcmethod_Callback(hObject, eventdata, handles)




% --- Executes on selection change in popMethod.
function popMethod_Callback(hObject, eventdata, handles)

% --- Executes on selection change in popRobust.
function popRobust_Callback(hObject, eventdata, handles)

% --- Executes on selection change in popFunctions.
function popFunctions_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function mnuEPR_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)

function edtCutOff_Callback(hObject, eventdata, handles)

function edtBLCorr_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuExport_Callback(hObject, eventdata, handles)


function edtTolX_Callback(hObject, eventdata, handles)

function edtTolFun_Callback(hObject, eventdata, handles)


function edtMaxFunE_Callback(hObject, eventdata, handles)


function edtMaxIter_Callback(hObject, eventdata, handles)


% --- Executes on button press in btnNRArun.
function btnNRArun_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    max_idx = numel(get(handles.lbFiles, 'String'));

    while idx <= max_idx
        set(handles.lbFiles, 'Value',idx);
        eprplot(handles);
        getframe;
        butNAnalyse_Callback(hObject, eventdata, handles);
        idx = idx+1;
    end



% --- Executes on button press in btnSaveNRAH1.
function btnSaveNRAH1_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');

    pointers = get(handles.figure1,'UserData');
    xc = pointers.H1;
    g = xc2g(xc,epr.freq(idx));

    % Save results
    epr.nra.results(idx,6) = xc;
    epr.nra.results_g(idx,6) = g;
    assignin('base','epr',epr);
    epr_update(hObject, eventdata, handles);


% --- Executes on button press in btnSaveNRAH2.
function btnSaveNRAH2_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');

    pointers = get(handles.figure1,'UserData');
    xc = pointers.H2;
    g = xc2g(xc,epr.freq(idx));

    % Save results
    epr.nra.results(idx,6) = xc;
    epr.nra.results_g(idx,6) = g;
    assignin('base','epr',epr);
    epr_update(hObject, eventdata, handles);




% --- Executes on button press in btnSaveNRAdH.
function btnSaveNRAdH_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');

    pointers = get(handles.figure1,'UserData');
    w = abs(pointers.H2-pointers.H1);

    % Save results
    epr.nra.results(idx,4) = w;
    assignin('base','epr',epr);
    epr_update(hObject, eventdata, handles);


% --- Executes on button press in btnInegrate.
function btnInegrate_Callback(hObject, eventdata, handles)

    blcorr = eval(get(handles.edtBLCorr,'String'));

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');
    H = epr.data{idx}.H;
    Y = epr.data{idx}.Y;
    range = get(handles.edtNRArange, 'String');
    [H Y] = extrange(H,Y,range);
    Z = nranalysis(H, Y, blcorr);

    cla;
    plot(H,Z);
    grid on
    if H(1) < H(end)
        xlim([H(1) H(end)]);
    else
        xlim([H(end) H(1)]);
    end
    legend([num2str(epr.temp(idx)) 'K']);
    xlabel('H (G)');
    ylabel('P (a.u.)');





% --- Executes on button press in butPlotRes2.
function butPlotRes2_Callback(hObject, eventdata, handles)



% --- Executes on button press in butPlotRes.
function butPlotRes_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    % title_str = [epr.material '  ' epr.date];
    % plot_results(epr.fit.results_g,title_str,1);
    plot_fit_results(epr);


% --- Executes on button press in butDelete.
function butDelete_Callback(hObject, eventdata, handles)



% --- Executes on button press in butReload.
function butReload_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    if isfield(epr,'data')
        shownames = {};
        for i=1:numel(epr.data)
            [pathstr, name, ext] = fileparts(epr.data{i}.fname);
            shownames{i} = [num2str(i) ' ' name];
        end
        set(handles.lbFiles, 'String', shownames);
        axes(handles.axes1);
        title([epr.material '  ' num2str(epr.mass) 'mg  ' epr.date]);
    else
        set(handles.lbFiles, 'String', []);
    end



% --- Executes on button press in butNRA.
function butNRA_Callback(hObject, eventdata, handles)

    set(handles.panNRA,'Visible','on');
    set(handles.panFit,'Visible','off');
    set(handles.panGlobFit,'Visible','off'); %
    set(handles.panSim,'Visible','off');
    set(handles.panES,'Visible','off');
    set(handles.panOther,'Visible','off');


% --- Executes on button press in butFitting.
function butFitting_Callback(hObject, eventdata, handles)

    set(handles.panFit,'Visible','on');
    set(handles.panGlobFit,'Visible','off'); %
    set(handles.panNRA,'Visible','off');
    set(handles.panSim,'Visible','off');
    set(handles.panES,'Visible','off');
    set(handles.panOther,'Visible','off');


% --- Executes on button press in butSimul.
function butSimul_Callback(hObject, eventdata, handles)

    set(handles.panSim,'Visible','on');
    set(handles.panNRA,'Visible','off');
    set(handles.panFit,'Visible','off');
    set(handles.panGlobFit,'Visible','off'); %
    set(handles.panES,'Visible','off');
    set(handles.panOther,'Visible','off');


% --- Executes on button press in butES.
function butES_Callback(hObject, eventdata, handles)
    set(handles.panNRA,'Visible','off');
    set(handles.panFit,'Visible','off');
    set(handles.panGlobFit,'Visible','off');
    set(handles.panSim,'Visible','off');
    set(handles.panES,'Visible','on');
    set(handles.panOther,'Visible','off');
    
    
% --- Executes on button press in butOther.
function butOther_Callback(hObject, eventdata, handles)

    set(handles.panNRA,'Visible','off');
    set(handles.panFit,'Visible','off');
    set(handles.panGlobFit,'Visible','off');
    set(handles.panSim,'Visible','off');
    set(handles.panES,'Visible','off');
    set(handles.panOther,'Visible','on');

    
% --- Executes on button press in butGlobFit.
function butGlobFit_Callback(hObject, eventdata, handles)

    set(handles.panNRA,'Visible','off');
    set(handles.panFit,'Visible','off');
    set(handles.panGlobFit,'Visible','on');
    set(handles.panSim,'Visible','off');
    set(handles.panES,'Visible','off');
    set(handles.panOther,'Visible','off');


% --------------------------------------------------------------------
function mnuLoad_Callback(hObject, eventdata, handles)
    [FileName,PathName] = uigetfile({'*.*','All files';'*.DTA','Bruker DTA';'*.DSC','Bruker DSC'},'MultiSelect','on');
    if ~isequal(FileName, 0)
        cd(PathName)
        epr = evalin('base','epr');
        if iscell(FileName)
            for i=1:numel(FileName)
                epr.path = [PathName FileName{i}];
                EPR_load;
                epr.sim{epr.N} = [];
                epr.fit.fits{epr.N} = [];
                epr.glob.fits{epr.N} = [];
            end
        else
            epr.path = [PathName FileName];
            EPR_load;
            prompt = {'Temperature:','Frequency:'};
            dlg_title = 'Load EPR data';
            num_lines = 1;
            t = epr.data{epr.N}.exp.Temperature;
            f = epr.data{epr.N}.exp.mwFreq;
            def = {num2str(t),num2str(f)};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            epr.data{epr.N}.exp.Temperature = str2double(answer{1});
            epr.data{epr.N}.exp.mwFreq = str2double(answer{2});
            epr.temp(epr.N) = str2double(answer{1});
            epr.freq(epr.N) = str2double(answer{2});
            epr.sim{epr.N} = [];
            epr.fit.fits{epr.N} = [];
            epr.glob.fits{epr.N} = [];
        end
        assignin('base','epr',epr);
        butReload_Callback(hObject, eventdata, handles);
        set(handles.lbFiles, 'Value',epr.N);
        eprplot(handles);
        epr_update(hObject, eventdata, handles);
        axis auto
    end




% --------------------------------------------------------------------
function mnuSampleD_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');

    prompt = {'Material:','Mass [mg]:','Date:'};
    dlg_title = 'Sample Description';
    num_lines = 1;
    if isfield(epr,'material')
        def = {epr.material,num2str(epr.mass),epr.date};
    else
        def = {'DPPH','0.0',datestr(now, 'dd-mm-yyyy')};
    end
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if ~isempty(answer) % If CANCEL answer is empty
        epr.material = answer{1};
        epr.mass = answer{2};
        epr.date = answer{3};
    end

    axes(handles.axes1);
    title([epr.material '  ' num2str(epr.mass) 'mg  ' epr.date]);

    assignin('base','epr',epr);



% --- Executes on button press in butEdit.
function butEdit_Callback(hObject, eventdata, handles)

    
% --------------------------------------------------------------------
function mnuSort_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');

    prompt = {'By (temp/freq/dates):','Direction (ascend/descend):'};
    dlg_title = 'Sort data';
    num_lines = 1;
    sortby = 'temp';
    sortdir = 'descend';

    if isfield(epr,'sort')
        sortby = epr.sort;
    end
    if isfield(epr,'sortDir')
        sortdir = epr.sortDir;
    end

    def = {sortby,sortdir};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if numel(answer)==0
        return;
    end

    epr.sort = answer{1};
    epr.sortDir = answer{2};
    EPR_sort;

    assignin('base','epr',epr);

    butReload_Callback(hObject, eventdata, handles);
    msgbox('Sort done!','Sort')


% --------------------------------------------------------------------
function toolSave_ClickedCallback(hObject, eventdata, handles)

    [FileName,PathName] = uiputfile('*.efi');
    if ~isequal(FileName, 0)
        cd(PathName);
        epr = evalin('base','epr');
        save([PathName FileName],'epr');
    end


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)

    [FileName,PathName] = uigetfile('*.efi');
    if ~isequal(FileName, 0)
        cd(PathName)
        load([PathName FileName],'-mat');

        if ~exist('epr','var')
            errordlg('Wrong file format!');
            return
        end

        % Verify Compatibility 

        if isfield(epr,'sim')
            if isfield(epr.sim,'fits')
                epr.fit = epr.sim;
                epr.sim = {};
            end
        else
            epr.sim={};
        end
        if ~isfield(epr,'nra'), epr.nra=[]; end
        if ~isfield(epr,'fit'), epr.fit.fits={}; end

        for i=1:epr.N
           if ~isfield(epr.data{i},'X')
               epr.data{i}.X = zeros(size(epr.data{i}.Y));
           end

        end

        assignin('base','epr',epr);

        butReload_Callback(hObject, eventdata, handles);
        set(handles.lbFiles, 'Value',epr.N);
        epr_update(hObject, eventdata, handles);
        eprplot(handles);
        axis auto
        if isfield(epr,'ES')     % New version 4.3
            set(handles.edtES,'String',epr.ES);
        end
    end



% --------------------------------------------------------------------
function mnuExpFit_Callback(hObject, eventdata, handles)

    [FileName,PathName] = uiputfile('*.dat');
    if ~isequal(FileName, 0)
        cd(PathName);
        epr = evalin('base','epr');
        idx = get(handles.lbFiles, 'Value');
        export_fit([PathName FileName],epr,idx);
    end
    msgbox(['Fit has been saved to ' [PathName FileName]],'Saved');


% --------------------------------------------------------------------
function mnuExpAFit_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    names = get(handles.lbFiles, 'String');
    nameParts = split(names{1}, ' ');
    FileName = ['fit' nameParts{2} '.dat'];
    [FileName,PathName] = uiputfile('*.dat','Save to directory',FileName);
    if ~isequal(FileName, 0)
        ret = questdlg('All files will be saved in this directory with an appendix ''fit...'' .','Confirm');
        if ~strcmp(ret,'Yes')
            return
        end
        cd(PathName);

        for i=1:numel(names)
            nameParts = split(names{i}, ' ');
            FileName = ['fit' nameParts{2} '.dat'];
            export_fit([PathName FileName],epr,i);
        end
    end
    msgbox(['Fits have been saved to ' PathName],'Saved');



% --------------------------------------------------------------------
function mnuExpSim_Callback(hObject, eventdata, handles)

    [FileName,PathName] = uiputfile('*.dat');
    if ~isequal(FileName, 0)
        cd(PathName);
        epr = evalin('base','epr');
        idx = get(handles.lbFiles, 'Value');
        export_sim([PathName FileName],epr,idx);
    end
    msgbox(['Simulation has been saved to ' [PathName FileName]],'Saved');

% --------------------------------------------------------------------
function mnuExpASim_Callback(hObject, eventdata, handles)



% User function: export selected fit
function export_fit(Filename, epr, idx)

    H = epr.data{idx}.H';
    Y = epr.data{idx}.Y';
    F = epr.fit.fits{idx}.f(H)';

    fid = fopen(Filename, 'wt');
    fprintf(fid, '# eprFit 5.0  exported data+fit file;  Anton Potocnik @ IJS F5\n');
    fprintf(fid, '# ------------------------------------------------------------\n');
    fprintf(fid, '# Original data file:\n');
    fprintf(fid, '# %s\n',epr.data{idx}.fname);
    fprintf(fid, '# Fit function:\n');
    fprintf(fid, '# %s\n',epr.fit.fitfun);
    fprintf(fid, '# Coefficients:\n');
    tmp = epr.fit.coef(:,1); % fieldnames(epr.fit.coef);
    for i=1:size(tmp,1)
        fprintf(fid, '#  %s\t',tmp{i});
        fprintf(fid, '%e\t+-%e\n',[epr.fit.results(idx,i*2);epr.fit.results(idx,i*2+1)]); %fprintf(fid, '%f\t+-%f\n',[epr.fit.results(idx,i*2);epr.fit.results(idx,i*2+1)]);
    end
    fprintf(fid, '# Data:\n');
    fprintf(fid, '# X\t \tY\t \tFit\n');

    fprintf(fid, '%e\t%e\t%e\n', [H; Y; F]);
    fclose(fid);




% User function: export selected simulations
function export_sim(Filename, epr, idx)

%     H = epr.data{idx}.H';
%     Y = epr.data{idx}.Y';
    HS = epr.sim{idx}.H';
    S = epr.sim{idx}.Y';

    fid = fopen(Filename, 'wt');
    fprintf(fid, 'XSim\tYSim\n');

    fprintf(fid, '%e\t%e\n', [HS; S]);
    fclose(fid);



% User function: export selected fit
function export_NRAres(Filename, epr)

    T = epr.nra.results(:,1);
    A = epr.nra.results(:,2);
    dH = epr.nra.results(:,4);
    g = epr.nra.results_g(:,6);
    xc = epr.nra.results(:,6);

    fid = fopen(Filename, 'wt');
    fprintf(fid, '# eprFit 5.0  exported NRA results;  Anton Potocnik @ IJS F5\n');
    fprintf(fid, '# ----------------------------------------------------------\n');
    fprintf(fid, '# Material/Mass/Date:\n');
    fprintf(fid, '# %s\n',[epr.material '  ' num2str(epr.mass) 'mg' '  ' epr.date]);
    fprintf(fid, '# W method:\t%s\n',epr.nra.w_method);
    fprintf(fid, '# Xc method:\t%s\n',epr.nra.xc_method);
    fprintf(fid, '# Integration Cut Off:\t%s\n',num2str(epr.nra.cutoff));

    fprintf(fid, '# Data:\n');
    fprintf(fid, '# T\t \tA\t \tdH\t \tg\t \txc\n');

    fprintf(fid, '%e\t%e\t%e\t%e\t%e\n', [T'; A'; dH'; g'; xc']); %fprintf(fid, '%f\t%f\t%f\t%f\t%f\n', [T'; A'; dH'; g'; xc']);
    fclose(fid);



% User function: export selected fit
function export_Simres(Filename, epr)

    % names = fieldnames(epr.fit.coef);
    % 
    % fid = fopen(Filename, 'wt');
    % fprintf(fid, '# eprFit 5.0  exported Fit results;  Anton Potocnik @ IJS F5\n');
    % fprintf(fid, '# ----------------------------------------------------------\n');
    % fprintf(fid, '# Material/Mass/Date:\n');
    % fprintf(fid, '# %s\n',[epr.material '  ' num2str(epr.mass) 'mg' '  ' epr.date]);
    % fprintf(fid, '# Fit function:\n')
    % fprintf(fid, '# %s\n',epr.fit.fitfun);
    % 
    % for i=1:numel(names)
    %     names{i,2} = ' ';
    % end
    % names = reshape(names',1,[]);
    % fprintf(fid, '# Data:\n');
    % fprintf(fid, '# %s',cell2mat(names));
    % 
    % fprintf(fid, '%f\n', epr.fit.results_g);
    % fclose(fid);
    res = epr.fit.results_g;
    save(Filename,'res','-ascii')


% User function: export selected fit
function export_linear(Filename, epr, idx)

    X = epr.data{idx}.linear.X';
    Q = epr.data{idx}.linear.Q';
    Ql = epr.data{idx}.linear.Ql';
    Qg = epr.data{idx}.linear.Qg';

    fid = fopen(Filename, 'wt');
    fprintf(fid, '# eprFit 5.0  exported linearized lorentzian;  Anton Potocnik @ IJS F5\n');
    fprintf(fid, '# ------------------------------------------------------------\n');
    fprintf(fid, '# Data file:\n');
    fprintf(fid, '# %s\n',epr.data{idx}.fname);
    fprintf(fid, '# \n');
    fprintf(fid, '# X\t \tQ\t \tQlor\t \tQgauss\n');

    fprintf(fid, '%e\t%e\t%e\t%e\n', [X; Q; Ql; Qg]);
    fclose(fid);


% --------------------------------------------------------------------
function mnuNRAres_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    if ~isfield(epr,'nra')
        errordlg('NRA results not available!');
        return
    end

    [FileName,PathName] = uiputfile({'*.txt';'*.dat'});
    if ~isequal(FileName, 0)
        cd(PathName);
        export_NRAres([PathName FileName],epr);
        msgbox(['NRA results have been saved to ' [PathName FileName]],'Saved');
    end



% --------------------------------------------------------------------
function mnuFitRes_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    if ~isfield(epr,'sim')
        errordlg('Fit results not available!');
        return
    end

    [FileName,PathName] = uiputfile({'*.txt';'*.dat'});
    if ~isequal(FileName, 0)
        cd(PathName);
        export_Simres([PathName FileName],epr);
        msgbox(['Fit results have been saved to ' [PathName FileName]],'Saved');
    end




% --------------------------------------------------------------------
function mnuNew_Callback(hObject, eventdata, handles)

    if evalin('base','exist(''epr'',''var'');') == 1
        answ = questdlg('All data in base workspace will be deleted! Do you really want to proceed?','New Experiment');
        if ~strcmp(answ,'Yes')
            return
        end
    end

    evalin('base','clear epr');
    createDefEprStruct();
    set(handles.lbFunGlob, 'String', []);
    set(handles.uitShared, 'Data', {});
    set(handles.uitSpecific, 'Data', {});
    mnuSampleD_Callback(hObject, eventdata, handles);
    butReload_Callback(hObject, eventdata, handles);
    axes(handles.axes1);  cla;
    axis auto




% --- Executes on button press in butTODO.
function butTODO_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function cmnEdit_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    names = get(handles.lbFiles, 'String');
%     if numel(names)==1
%         return;
%     end

    epr = evalin('base','epr');

    prompt = {'Temperature:','Frequency:'};
    dlg_title = names{idx};
    num_lines = 1;
    t = epr.temp(idx);
    f = epr.freq(idx);

    def = {num2str(t),num2str(f)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if numel(answer)==0
        return;
    end

    epr.data{idx}.exp.Temperature = str2double(answer{1});
    epr.data{idx}.exp.mwFreq = str2double(answer{2});
    epr.temp(idx) = str2double(answer{1});
    epr.freq(idx) = str2double(answer{2});

    assignin('base','epr',epr);

    butReload_Callback(hObject, eventdata, handles);
    set(handles.lbFiles, 'Value',idx); %???%
    eprplot(handles);
    epr_update(hObject, eventdata, handles);


% --------------------------------------------------------------------
function cmnDelete_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');

    if epr.N < 1
        return; % Not selected
    end

    if strcmp(questdlg('Do you really want to delete this measurement?','Delete'), 'Yes') ~= 1
        return
    end

    epr = EPR_delete(epr,idx);
    assignin('base','epr',epr);
    
    coefs_specific = get(handles.uitSpecific, 'Data');
    % removing file-specific parameters and lowering others' numbers
    rem_sp=[];
    for i=1:size(coefs_specific,1)
        par = coefs_specific{i,1};
        name = par; name = name(isletter(name));
        numbs = par; numbs(isletter(numbs) | numbs == ' ')=[];
        numbs = split(numbs, '_'); % string vector
        for j=idx
            if isempty(numbs) || str2double(numbs(2)) == j
                rem_sp = [rem_sp i];
            end
        end
        coefs_specific{i,1} = [name char(numbs(1)) '_' num2str(str2double(numbs(2)) - sum(idx < str2double(numbs(2))))];
    end
    coefs_specific(rem_sp,:) = [];
    set(handles.uitSpecific, 'Data', coefs_specific);

    if epr.N < 1
        set(handles.lbFiles, 'Value',0);
    else
        if idx > epr.N 
            set(handles.lbFiles, 'Value',epr.N);
        else
            set(handles.lbFiles, 'Value',idx);
        end
    end

    butReload_Callback(hObject, eventdata, handles);
    eprplot(handles);




% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)

    OpenMenuItem_Callback(hObject, eventdata, handles)


% --- Executes on button press in butSubBaseLine.
function butSubBaseLine_Callback(hObject, eventdata, handles)


% --- Executes on button press in butLorentz.
function butLorentz_Callback(hObject, eventdata, handles)



% --- Executes on button press in butSubData.
function butSubData_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuExpTestLor_Callback(hObject, eventdata, handles)

    [FileName,PathName] = uiputfile('*.txt');
    if ~isequal(FileName, 0)
        cd(PathName);
        epr = evalin('base','epr');
        idx = get(handles.lbFiles, 'Value');

        export_linear([PathName FileName],epr,idx);
    end
    msgbox(['Linearization has been saved to ' [PathName FileName]],'Saved');


% --------------------------------------------------------------------
function cmnCpyData_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');

    plotX = get(handles.chkPlotX, 'Value');
    plotXe = get(handles.chkPlotX, 'Enable');
    if strcmp(plotXe,'on') && plotX == 1
        plotX = 1;
    else
        plotX = 0;
    end

    ma = [];

    for i=idx
        H = reshape(epr.data{i}.H,[],1);
        Y = reshape(epr.data{i}.Y,[],1);
        H = [0; H];
        Y = [epr.temp(i); Y];
        ma = [ma H Y];
        if plotX == 1
            X = [0; reshape(epr.data{i}.X,[],1)];
            ma = [ma X];
        end
    end
    num2clip(ma)
    % for i=idx
    %     H = epr.data{i}.H;
    %     Y = epr.data{i}.Y;
    %     fit=0;
    %     if isfield(epr.fit,'fits')
    %         if numel(epr.fit.fits) >= i && ~isempty(epr.fit.fits{i})
    %             fitY = epr.fit.fits{i}.f(H);
    %             fitY = [0; fitY];
    %             fit=1;
    %         end
    %     end
    %     H = [0; H];
    %     Y = [epr.temp(i); Y];
    % 
    %     if fit==1
    %         ma = [ma H Y fitY];
    %     else
    %         ma = [ma H Y];
    %     end
    % end



% --------------------------------------------------------------------
function mnuNormAll_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    max_idx = numel(get(handles.lbFiles, 'String'));

    for idx=1:max_idx
        Y = epr.data{idx}.Y;
        epr.data{idx}.Y = normalize(Y);
        epr.data{idx}.Yold = Y;
    end
    assignin('base','epr',epr);

    butReload_Callback(hObject, eventdata, handles);
    set(handles.lbFiles, 'Value',idx);
    eprplot(handles);
    epr_update(hObject, eventdata, handles);
    msgbox('Data hase been normalized between [0 1]. To undo use Renormalize All.','Normalize')

    function Y = normalize(Y)
    ymax = max(Y);
    ymin = min(Y);

    Y = (Y-ymin)/(ymax-ymin);



% --------------------------------------------------------------------
function mnuReNormAll_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');

    max_idx = numel(get(handles.lbFiles, 'String'));

    if ~isfield(epr.data{1},'Yold')
        msgbox('Renormalization not available!','Renormalize')
        return
    end

    for idx=1:max_idx
        epr.data{idx}.Y = epr.data{idx}.Yold;
    end
    assignin('base','epr',epr);

    butReload_Callback(hObject, eventdata, handles);
    set(handles.lbFiles, 'Value',idx);
    eprplot(handles);
    epr_update(hObject, eventdata, handles);
    msgbox('Data hase been renormalized.','Renormalize')



% --------------------------------------------------------------------
function mnuCpyNRAres_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    if ~isfield(epr,'nra')
        errordlg('NRA results not available!');
        return
    end

    T = epr.nra.results(:,1);
    A = epr.nra.results(:,2);
    dH = epr.nra.results(:,4);
    g = epr.nra.results_g(:,6);
    xc = epr.nra.results(:,6);
    num2clip([T A dH g xc]);
    msgbox('NRA results have been copied to clipboard','Saved');


% --------------------------------------------------------------------
function mnuCpyFitResulse_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    if ~isfield(epr,'fit') || ~isfield(epr.fit,'results_g')
        errordlg('Fit results not available!');
        return
    end

    res = epr.fit.results_g;
    num2clip(res)
    msgbox('Fit results have been copied to clipboard','Saved');



% --- Executes on button press in nutShowRes.
function nutShowRes_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    title_str = [epr.material '  ' epr.date];
    plot_results(epr.nra.results,title_str,1);





function edtFitRange_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtFitRange_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtNRArange_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtNRArange_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function CpyPointers_Callback(hObject, eventdata, handles)

    pointers = get(handles.figure1,'UserData');

    val = get(handles.edtFitRange,'String');
    val = [val ' [' num2str(pointers.H1,'%10.0f') ' ' num2str(pointers.H2,'%10.0f') ']'];
    set(handles.edtFitRange,'String',val);


% --------------------------------------------------------------------
function RangeEdt_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function AppNRArangePoint_Callback(hObject, eventdata, handles)

    pointers = get(handles.figure1,'UserData');
    val = get(handles.edtNRArange,'String');
    val = [val ' [' num2str(pointers.H1,'%10.0f') ' ' num2str(pointers.H2,'%10.0f') ']'];
    set(handles.edtNRArange,'String',val);


% --------------------------------------------------------------------
function NRArangeEdt_Callback(hObject, eventdata, handles)

function edtPhase_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    PHASE = str2double(get(handles.edtPhase,'String'))/180*pi;
    idx = get(handles.lbFiles, 'Value');

    if ~isfield(epr.data{idx},'X')
        return
    end

    if isfield(epr.data{idx},'Y0')
        X0 = epr.data{idx}.X0;
        Y0 = epr.data{idx}.Y0;
    else
        X0 = epr.data{idx}.X;
        Y0 = epr.data{idx}.Y;
    end

    X = cos(PHASE)*X0+sin(PHASE)*Y0;
    Y = -sin(PHASE)*X0+cos(PHASE)*Y0;

    epr.data{idx}.X = X;
    epr.data{idx}.Y = Y;
    epr.data{idx}.X0 = X0;
    epr.data{idx}.Y0 = Y0;

    assignin('base','epr',epr);
    eprplot(handles);



% --- Executes during object creation, after setting all properties.
function edtPhase_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butPhUp.
function butPhUp_Callback(hObject, eventdata, handles)

    PHASE = str2double(get(handles.edtPhase,'String'));
    PHASE = PHASE + 1;
    set(handles.edtPhase,'String',num2str(PHASE));
    edtPhase_Callback(hObject, eventdata, handles)



% --- Executes on button press in butPhDown.
function butPhDown_Callback(hObject, eventdata, handles)

    PHASE = str2double(get(handles.edtPhase,'String'));
    PHASE = PHASE - 1;
    set(handles.edtPhase,'String',num2str(PHASE));
    edtPhase_Callback(hObject, eventdata, handles)



% --- Executes on key press with focus on butPhUp and none of its controls.
function butPhUp_KeyPressFcn(hObject, eventdata, handles)

% --- Executes on key press with focus on edtPhase and none of its controls.
function edtPhase_KeyPressFcn(hObject, eventdata, handles)


% --- Executes on button press in butAbs.
function butAbs_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    idx = get(handles.lbFiles, 'Value');

    if isfield(epr.data{idx},'Y0')
        X0 = epr.data{idx}.X0;
        Y0 = epr.data{idx}.Y0;
    else
        X0 = epr.data{idx}.X;
        Y0 = epr.data{idx}.Y;
    end

    X = angle(complex(Y0,X0));
    Y = abs(complex(Y0,X0));

    epr.data{idx}.X = X;
    epr.data{idx}.Y = Y;
    epr.data{idx}.X0 = X0;
    epr.data{idx}.Y0 = Y0;

    assignin('base','epr',epr);

    butReload_Callback(hObject, eventdata, handles);
    set(handles.lbFiles, 'Value',idx); %???%
    eprplot(handles);
    epr_update(hObject, eventdata, handles);


% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)

    toolSave_ClickedCallback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function getTemp_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    max_idx = numel(get(handles.lbFiles, 'String'));
    names = get(handles.lbFiles, 'String');

    for idx=1:max_idx

        tmp = names{idx};
        start = union(strfind(tmp,'-'),strfind(tmp,'_'));
        start = union(start,strfind(tmp,'.'));
        stop = strfind(tmp,'K');

        % Find beginning and end of temperature ... the closest symbols
        [H W] = meshgrid(1:numel(start),1:numel(stop));
        stops = stop(W);
        starts = start(H);
        distance = stops - starts;
        distance(distance<=1) = inf;
        [mini, i] = min(distance);
        [mini, j] = min(mini);
        istart = start(i(j))+1;
        istop = stop(j)-1;

        if mini < 7 % nikoli ne bo šlo preko 1000p00K
            tmp = tmp(istart:istop);
            tmp = strrep(tmp,'p','.');
            t = str2double(tmp);
            if isnan(t)
                t = 300;
            end
        else
            t = 300;
        end

        epr.data{idx}.exp.Temperature = t;
        epr.temp(idx) = t;
    end
    assignin('base','epr',epr);

    butReload_Callback(hObject, eventdata, handles);
    set(handles.lbFiles, 'Value',idx);
    msgbox('Parsing Temperatures Done!','Parse Temperature')




function edtNpwdr_Callback(hObject, eventdata, handles)
% hObject    handle to edtNpwdr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtNpwdr as text
%        str2double(get(hObject,'String')) returns contents of edtNpwdr as a double


% --- Executes during object creation, after setting all properties.
function edtNpwdr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtNpwdr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGxx_Callback(hObject, eventdata, handles)
% hObject    handle to edtGxx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGxx as text
%        str2double(get(hObject,'String')) returns contents of edtGxx as a double


% --- Executes during object creation, after setting all properties.
function edtGxx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGxx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGyy_Callback(hObject, eventdata, handles)
% hObject    handle to edtGyy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGyy as text
%        str2double(get(hObject,'String')) returns contents of edtGyy as a double


% --- Executes during object creation, after setting all properties.
function edtGyy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGyy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGzz_Callback(hObject, eventdata, handles)
% hObject    handle to edtGzz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGzz as text
%        str2double(get(hObject,'String')) returns contents of edtGzz as a double


% --- Executes during object creation, after setting all properties.
function edtGzz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGzz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtHxx_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtHxx_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtHyy_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtHyy_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edtHzz_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtHzz_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butSimulate.
function butSimulate_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');  % Must be defined

    % Get simulation parameters
    % anglStep = str2double(get(handles.edtNpwdr,'String'));
    Nstep = str2double(get(handles.edtNpwdr,'String')); % number of points on a sphere
    Nmwdir = str2double(get(handles.edtNmwdir,'String')); % number of microwave directions
    NOP = str2double(get(handles.edtSimNOP,'String')); % number of H points considered
    
    H = epr.data{idx}.H; 
    Y = epr.data{idx}.Y;
    n = numel(H); k = floor(n/NOP); if k==0, k=1; end
    H = H(1:k:end);
    Y = Y(1:k:end);

    range = get(handles.edtSimRange, 'String');
    [H Y] = extrange(H,Y,range);
    if numel(H) == 1 || isempty(H)
        msgbox('Please widen your range!', 'Error Range');
        return
    end

    % Nstep = 360/anglStep;   % Must be defined
    x = H;                  % Must be defined
    freq = epr.freq(idx);   % Must be defined
    
    coefs = get(handles.uitSim, 'Data');
    simfun_str = getSimEquation(handles);
    
    % Copy linked values (only the first occurence is needed) -------------
    links = {}; % {link name, fixed?}
    for i = 1:size(coefs, 1)
        link = coefs{i,4};
        value = coefs{i,2}/coefs{i,5}; % normalized value
        if ~isempty(link) % is linked
            linkFound = false;
            for j = 1:size(links,1)
                if strcmp(links{j,1},link) % link found
                    linkFound = true;
                    if coefs{i,3} && ~links{j,2} % if current is fixed but not all linked are
                        for k = 1:size(coefs,1) % all linked are set to fixed
                            if strcmp(coefs{k,4},link)
                                coefs{k,3} = true;
                            end
                        end
                    end
                end
            end
            if ~linkFound % this is the first link
                for j = i+1:size(coefs,1)
                    if strcmp(coefs{j,4},link)
                        coefs{j,2} = value * coefs{j,5}; % all links after this are overwritten to scale
                        if coefs{i,3}
                            coefs{j,3} = true; % if first one is fixed all others get fixed too
                        end
                    end
                end
                links(end+1,:) = {link, coefs{i,3}};
            end
        end
    end
    % disp(coefs);
    set(handles.uitSim,'Data', coefs);               
    %----------------------------------------------------------------------
    
    for i = 1:size(coefs,1)
        name = coefs{i,1};
        value = coefs{i,2};
        eval([name '=' num2str(value) ';']);
    end
    tic
    Ysim = eval(simfun_str);
    toc
    for i = 1:size(coefs,1)
        name = coefs{i,1};
        eval(['epr.sim{idx}.' name '=' name ';']);
    end

    epr.sim{idx}.coefs = coefs;
    epr.sim{idx}.sim_name = simfun_str;
    epr.sim{idx}.Nstep = Nstep;
    epr.sim{idx}.Nmwdir = Nmwdir;
    epr.sim{idx}.NOP = NOP;
    epr.sim{idx}.H = H;
    epr.sim{idx}.Y = Ysim;
    epr.sim{idx}.range = range;
    epr.sim{idx}.SimFuncs = get(handles.lbSimFun, 'String');
    epr.sim{idx}.rep = str2double(get(handles.edtRep,'String'));
    epr.sim{idx}.NIter = str2double(get(handles.edtSimIter,'String'));
    epr.sim{idx}.FunTol = str2double(get(handles.edtSimFunTol,'String'));
    epr.sim{idx}.XTol = str2double(get(handles.edtSimXTol,'String'));
    
    chi2 = sum((Y-Ysim).*(Y-Ysim));
    epr.sim{idx}.chi2 = chi2;
    set(handles.txtSimChi, 'String', ['Chi2 = ' num2str(chi2)]);

    set(handles.uitSim, 'Data',coefs);
    assignin('base','epr',epr);
    set(handles.chkPlotSim,'Value',1);
    eprplot(handles);
    backupSim(handles);
    

% --- Executes on button press in rbutgIso.
function rbutgIso_Callback(hObject, eventdata, handles)


% --- Executes on button press in rbutgCil.
function rbutgCil_Callback(hObject, eventdata, handles)


% --- Executes on button press in rbutgAniso.
function rbutgAniso_Callback(hObject, eventdata, handles)


% --- Executes on button press in chkPlotSim.
function chkPlotSim_Callback(hObject, eventdata, handles)

% --- Executes on button press in chkPlotGlob.
function chkPlotGlob_Callback(hObject, eventdata, handles)

% --- Executes on button press in chkPlotX.
function chkPlotX_Callback(hObject, eventdata, handles)


% --- Executes on key press with focus on butDelete and none of its controls.
function butDelete_KeyPressFcn(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuAnalyse_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuSub_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuSubBL_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    indices = get(handles.lbFiles, 'Value');
    
    for i = 1:numel(indices)
        idx = indices(i);
    
        H = epr.data{idx}.H; % in mT
        Y = epr.data{idx}.Y;
        H = reshape(H, [], 1);
    
        % Select the first few and last few points
        numPoints = round(0.02 * length(H)); % Number of points to select
        firstPoints = H(1:numPoints);
        lastPoints = H(end-numPoints+1:end);
        selectedPoints = [firstPoints; lastPoints];
        selectedData = [Y(1:numPoints); Y(end-numPoints+1:end)];
    
        % Fit a line to the selected points
        fitResult = polyfit(selectedPoints, selectedData, 1);
    
        % Subtract the line from the data
        baseline = polyval(fitResult, H);
        epr.data{idx}.Y = Y - baseline;
    end
    
    assignin('base', 'epr', epr);
    eprplot(handles);



% --------------------------------------------------------------------
function mnuSubData_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    idx = get(handles.lbFiles, 'Value');

    prompt = {'spc_idx =','ref_idx =','factor ='};
    dlg_title = 'Substract reference data';
    num_lines = 1;
    index = idx;
    def = {num2str(idx),'1', '1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if numel(answer)==0
        return;
    end

    spc_idx = str2num(answer{1});
    ref_idx = str2double(answer{2});
    factor = str2double(answer{3});

    for idx = spc_idx
        H = epr.data{idx}.H;
        Y = epr.data{idx}.Y;
        X = epr.data{idx}.X;

        if ~isfield(epr.data{idx},'Y0')
            epr.data{idx}.Y0 = Y;
            epr.data{idx}.X0 = X;
            epr.data{idx}.H0 = H;
        end

        [refH XI] = sort(epr.data{ref_idx}.H);
        refY = epr.data{ref_idx}.Y(XI);
        [H XI] = sort(H);
        Y = Y(XI);
        
        [b,i,j]=unique(refH); % Remove duplicates from x        

        epr.data{idx}.Y=Y - factor*interp1(b,refY(i),H,'nearest','extrap');
        disp(idx)
    end

    assignin('base','epr',epr);
    eprplot(handles);



% --------------------------------------------------------------------
function mnuSubFit_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    indices = get(handles.lbFiles, 'Value');

    prompt = {'factor ='};
    dlg_title = 'Subtract simulation';
    num_lines = 1;
    def = {'1'};
    answer = inputdlg(prompt, dlg_title, num_lines, def);
    if isempty(answer)
        return;
    end

    factor = str2double(answer{1});

    for i = 1:numel(indices)
        idx = indices(i);
    
        if numel(epr.fit.fits) < idx || isempty(epr.fit.fits{idx})
            msgbox('Fit not available!', 'Error');
            continue;
        end
    
        H = epr.data{idx}.H;
        Y = epr.data{idx}.Y;
        X = epr.data{idx}.X;
    
        if ~isfield(epr.data{idx}, 'Y0')
            epr.data{idx}.Y0 = Y;
            epr.data{idx}.X0 = X;
            epr.data{idx}.H0 = H;
        end
    
        fitY = epr.fit.fits{idx}.f(H);
        epr.data{idx}.Y = Y - factor * fitY;
    end
    
    assignin('base', 'epr', epr);
    eprplot(handles);



% --------------------------------------------------------------------
function mnuSubSim_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    idx = get(handles.lbFiles, 'Value');

    prompt = {'idx =','factor ='};

    dlg_title = 'Substract simulation';
    num_lines = 1;
    index = idx;
    def = {num2str(index), '1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if numel(answer)==0
        return;
    end

    index = str2double(answer{1});
    factor = str2double(answer{2});

    if numel(epr.sim) < index || isempty(epr.sim{index}) 
        msgbox('Simulation not available!','Error');
        return
    end

    H = epr.data{idx}.H;
    Y = epr.data{idx}.Y;
    X = epr.data{idx}.X;

    if ~isfield(epr.data{idx},'Y0')
        epr.data{idx}.Y0 = Y;
        epr.data{idx}.X0 = X;
        epr.data{idx}.H0 = H;
    end

    simY = epr.sim{index}.Y;
    simH = epr.sim{index}.H;

    % if numel(simH) < numel(H)
    %     msgbox('Not entire specter is simulated!','Error')
    %     return;
    % end

    epr.data{idx}.Y = Y - factor*interp1(simH,simY,H,'nearest','extrap');

    assignin('base','epr',epr);
    eprplot(handles);




% --------------------------------------------------------------------
function mnuTestLor_Callback(hObject, eventdata, handles)

    axes(handles.axes1);

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');

    coefs = get(handles.uitFit,'Data');
    coefstr = coefs(:,1);
    coefval = coefs(:,2);

    prompt = {'dHfwhm =','H0 ='};
    dlg_title = 'Test Lorentzian';
    num_lines = 1;
    dH = coefval{2};%100;
    H0 = coefval{3};%3350;
    def = {num2str(dH),num2str(H0)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if numel(answer)==0
        return;
    end

    cla;

    dH = str2double(answer{1});
    dHpp = dH/sqrt(3);
    H0 = str2double(answer{2});

    H = epr.data{idx}.H;
    Z = epr.data{idx}.Y;
    ymax = max(Z);

    Al = ymax*2*pi*dH*dH/3/sqrt(3);
    L = -16/pi*Al*(H-H0)*dH./((4*(H-H0).^2 + dH^2).^2);

    dH = dHpp/2; %Gauss uses dH...hwhm
    Ag = ymax*sqrt(2*pi)*dH*dH*exp(1/2);
    G = -Ag/sqrt(2*pi)*1/dH^3.*(H-H0).*exp(-(H-H0).^2/2/dH^2);

    X = (2*(H-H0)/dHpp).^2;
    % Q = sqrt(-16/sqrt(3)/3*2*(H-H0)*ymax./Z/dH)-1;
    % Ql = sqrt(-16/sqrt(3)/3*2*(H-H0)*ymax./L/dH)-1;

    Q = sqrt(-2*(H-H0)./dHpp.*ymax./Z);
    Ql = sqrt(-2*(H-H0)./dHpp.*ymax./L);
    Qg = sqrt(-2*(H-H0)./dHpp.*ymax./G);

    epr.data{idx}.linear.X = X;
    epr.data{idx}.linear.Q = Q;
    epr.data{idx}.linear.Ql = Ql;
    epr.data{idx}.linear.Qg = Qg;
    %plot(X,Q,X,Ql,X,X/4+3/4);
    %plot(X,Q,X,Ql,X,Qg,X,exp(-1/4).*exp(X/4));
    plot(X,Q,X,Ql,X,Qg);
    axis([0 100 0 50])
    legend('Data','Lorentz','Gauss')
    xlabel('(2*(H-H0)/dHpp)^2');
    ylabel('sqrt(-2*(H-H0)/dHpp*Ymax/Y)');
    grid on

    figure
    plot(H,Z,H,L,H,G);
    legend('Data','Lorentz','Gauss')
    assignin('base','epr',epr);


% --------------------------------------------------------------------
function pshAxisAuto_ClickedCallback(hObject, eventdata, handles)
    axis auto





% --------------------------------------------------------------------
function mnuShowInfo_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');
    i = idx(end);
    
    description(epr,i,true);



% --- Executes on button press in butFitSim.
function butFitSim_Callback(hObject, eventdata, handles)

rep = str2double(get(handles.edtRep,'String'));

for re = 1:rep
    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');
    
    % Get simulation options
    NIter = str2double(get(handles.edtSimIter,'String'));
    FunTol = str2double(get(handles.edtSimFunTol,'String'));
    XTol = str2double(get(handles.edtSimXTol,'String'));
    opts = optimset('TolX',1e-9,'Display','final','MaxIter',NIter,'TolFun',FunTol,'TolX',XTol,'MaxFunEvals',10000,'PlotFcns',@optimplotfval); %@optimplotx);%,'OutputFcn', @outfun);

    % Get simulation parameters
    % anglStep = str2double(get(handles.edtNpwdr,'String'));
    Nstep = str2double(get(handles.edtNpwdr,'String'));
    Nmwdir = str2double(get(handles.edtNmwdir,'String')); % number of microwave directions
    NOP = str2double(get(handles.edtSimNOP,'String'));
    coefs = get(handles.uitSim, 'Data');
    simfun_str = getSimEquation(handles);
    
    % Copy linked values (only the first occurence is needed) -------------
    links = {}; % {link name, fixed?}
    for i = 1:size(coefs, 1)
        link = coefs{i,4};
        value = coefs{i,2}/coefs{i,5}; % normalized value
        if ~isempty(link) % is linked
            linkFound = false;
            for j = 1:size(links,1)
                if strcmp(links{j,1},link) % link found
                    linkFound = true;
                    if coefs{i,3} && ~links{j,2} % if current is fixed but not all linked are
                        for k = 1:size(coefs,1) % all linked are set to fixed
                            if strcmp(coefs{k,4},link)
                                coefs{k,3} = true;
                            end
                        end
                    end
                end
            end
            if ~linkFound % this is the first link
                for j = i+1:size(coefs,1)
                    if strcmp(coefs{j,4},link)
                        coefs{j,2} = value * coefs{j,5}; % all links after this are overwritten to scale
                        if coefs{i,3}
                            coefs{j,3} = true; % if first one is fixed all others get fixed too
                        end
                    end
                end
                links(end+1,:) = {link, coefs{i,3}};
            end
        end
    end
    % disp(coefs);
    set(handles.uitSim,'Data', coefs);               
    %----------------------------------------------------------------------
    
    % Get data
    H = epr.data{idx}.H; 
    Y = epr.data{idx}.Y;
    n = numel(H); k = floor(n/NOP); if k==0, k=1; end
    H = H(1:k:end);
    Y = Y(1:k:end);
    range = get(handles.edtSimRange, 'String');
    [H Y] = extrange(H,Y,range);
    if numel(H) == 1 || isempty(H)
        msgbox('Please widen your range!', 'Error Range');
        return
    end
    
    % Set parameters & fitting parameter string including values
    param_idx = 1;
    z0 = [];
    Link = {}; % elements {link index, parameter index}
    link_idx = 1;
   
    for i = 1:size(coefs,1)
        name = coefs{i,1};
        value = coefs{i,2}/coefs{i,5}; % normalized value
        eval([name '=' num2str(value*coefs{i,5}) ';']); % scaled value
        
        if coefs{i,3} ~= 1 % it is not fixed

            isLinked = 0;
            if ~isempty(coefs{i,4}) % it is linked
                for j=1:numel(Link)
                   if strcmp(Link{j}{1},coefs{i,4})  % if you found a link
                       isLinked = Link{j}{2}; % parameter index
                       break
                   end
                end
                if isLinked <= 0
                    Link{link_idx} = {coefs{i,4},param_idx};
                    link_idx = link_idx + 1;
                end
            end
            
            if isLinked > 0
                param_idx = param_idx - 1;
                pname = [num2str(coefs{i,5}) '*z(' num2str(isLinked) ')']; % variable scaled
            else
                pname = [num2str(coefs{i,5}) '*z(' num2str(param_idx) ')']; % variable scaled
                z0(param_idx) = value; % z is normalized
            end

            param_idx = param_idx + 1;
            simfun_str = strrep(simfun_str,name,pname);
        else
            simfun_str = strrep(simfun_str,name,num2str(value*coefs{i,5},12));
        end

    end

    % Nstep = 360/anglStep;   % Must be defined
    x = H;                  % Must be defined
    Y0 = Y;
    freq = epr.freq(idx);   % Must be defined
    
    simfun_str = strrep(simfun_str,'Nstep',num2str(Nstep,12));
    simfun_str = strrep(simfun_str,'Nmwdir',num2str(Nmwdir,12));
    simfun_str = strrep(simfun_str,'freq',num2str(freq,12));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    results = fminsearch(@(z) Mini(Y0,x,simfun_str,z),z0,opts);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Set fitted values
    param_idx = 1;
    for i = 1:size(coefs,1)
        isLinked = 0;
        if coefs{i,3} ~= 1 % it is not fixed
            if ~isempty(coefs{i,4}) % it is linked
                for j=1:numel(Link) % Search for linkage
                   if strcmp(Link{j}{1},coefs{i,4})  % if you found a link
                       isLinked = Link{j}{2}; % parameter index
                       break
                   end
                end
            end
            name = coefs{i,1}; % only the first word is variable name

            if isLinked <= 0
                eval([name '= results(' num2str(param_idx) ')*' num2str(coefs{i,5}) ';']); % scaled values, name values are correct
            else
                eval([name '= results(' num2str(isLinked) ')*' num2str(coefs{i,5}) ';']); % scaled values, name values are correct
                if isLinked ~= param_idx, param_idx = param_idx - 1; end; % not for the first one linked
            end

            eval(['coefs{i,2}=' name ';']);
            param_idx = param_idx + 1;
        end
    end
    
    % Evaluate simulation
    z = results;
    Y = eval(simfun_str);

    % Store parameters and spectrum
    for i = 1:size(coefs,1)
        name = strtok(coefs{i,1}); % only the first word is variable name
        eval(['epr.sim{idx}.' name '=' name ';']);
    end
    epr.sim{idx}.Y = Y;
    epr.sim{idx}.H = x;
    epr.sim{idx}.coefs = coefs;
    epr.sim{idx}.SimFuncs = get(handles.lbSimFun, 'String');
    epr.sim{idx}.sim_name = getSimEquation(handles);
    epr.sim{idx}.Nstep = Nstep;
    epr.sim{idx}.Nmwdir = Nmwdir;
    epr.sim{idx}.NOP = NOP;
    epr.sim{idx}.range = get(handles.edtSimRange, 'String');
    epr.sim{idx}.rep = rep;
    epr.sim{idx}.NIter = NIter;
    epr.sim{idx}.FunTol = FunTol;
    epr.sim{idx}.XTol = XTol;
    
    % Calculate Chi2
    chi2 = sum((Y-Y0).*(Y-Y0));
    epr.sim{idx}.chi2 = chi2;
    set(handles.txtSimChi, 'String', ['Chi2 = ' num2str(chi2)]);

    % Save and plot
    set(handles.uitSim, 'Data', coefs);
    assignin('base','epr',epr);
    set(handles.chkPlotSim,'Value',1);
    axes(handles.axes1); % It is making it very slow!!!
    eprplot(handles);
end
backupSim(handles);


function minimize = Mini(Y0,x,simfun_str,z)
    Y = eval(simfun_str);
    in = isnan(Y);
    Y(in)=[];
    Y0(in)=[];
    minimize = sum((Y-Y0).*(Y-Y0));


% User Function
function stop = outfun(x, optimValues, state)
    stop = false;
    % Check if directional derivative is less than .01.
    title(num2str(optimValues.fval));


% --- Executes on key press with focus on edtGxx and none of its controls.
function edtGxx_KeyPressFcn(hObject, eventdata, handles)


function edtSimPhase_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtSimPhase_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkFitG.
function chkFitG_Callback(hObject, eventdata, handles)

% --- Executes on button press in chkFitH.
function chkFitH_Callback(hObject, eventdata, handles)


% --- Executes on button press in chkFitPh.
function chkFitPh_Callback(hObject, eventdata, handles)


function edtSimIter_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtSimIter_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in butReduceN.
function butReduceN_Callback(hObject, eventdata, handles)


function edtSimFunTol_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtSimFunTol_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtSimXTol_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtSimXTol_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butRunFitSim.
function butRunFitSim_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    max_idx = numel(get(handles.lbFiles, 'String'));

    prompt = {'start idx:','stop idx:','abs(step):'};
    dlg_title = 'Run simulation';
    num_lines = 1;
    def = {num2str(idx),num2str(max_idx),'1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if ~isempty(answer) % If CANCEL, answer is empty
        idx = str2double(answer{1});
        max_idx = str2double(answer{2});
        step = str2double(answer{3});
    else 
        return
    end
    step = sign(max_idx-idx)*abs(step);

    for i = idx:step:max_idx
        set(handles.lbFiles, 'Value',i);
        eprplot(handles);
    %     set(handles.edtSimIter,'String',1000');
    %     set(handles.edtSimRange,'String','[0 inf]');
    %     getframe;
    %     butSimFit_Callback(hObject, eventdata, handles);
    %     set(handles.chkFitH,'Value',1);
        getframe;
        butFitSim_Callback(hObject, eventdata, handles);
        getframe;
    end
    disp('Simulation run finished!');
    


function edtSimLin_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtSimLin_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtSimConst_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtSimConst_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkFitLin.
function chkFitLin_Callback(hObject, eventdata, handles)


% --- Executes on button press in chkFitConst.
function chkFitConst_Callback(hObject, eventdata, handles)



function edtSimAmp_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtSimAmp_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in butSimCopy.
function butSimCopy_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    idx = get(handles.lbFiles, 'Value');
    coefs = get(handles.uitSim, 'Data');
    results = [epr.temp(idx) epr.freq(idx)];
    header = 'Temp Freq';
    for i=1:size(coefs,1)
        header = [header ' ' coefs{i,1}];
        results(end+1) = coefs{i,2};
    end
    header = [header '  chi2'];
    results(end+1) = epr.sim{idx}.chi2;
    disp(header)
    num2clip(results);
    disp(results)



function edtSimRange_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtSimRange_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --------------------------------------------------------------------
function mnuMultiAll_Callback(hObject, eventdata, handles)
    
    epr = evalin('base','epr');
    max_idx = numel(get(handles.lbFiles, 'String'));

    prompt = {'Enter numeric factor:'};
    dlg_title = 'Multiply All';
    num_lines = 1;
    def = {'100'};
    factor = str2double(inputdlg(prompt,dlg_title,num_lines,def));

    for idx=1:max_idx
        epr.data{idx}.Y = factor*epr.data{idx}.Y;
        if isfield(epr.data{idx},'X')
            epr.data{idx}.X = factor*epr.data{idx}.X;
        end
    end
    assignin('base','epr',epr);

    butReload_Callback(hObject, eventdata, handles);
    set(handles.lbFiles, 'Value',idx);
    eprplot(handles);
    epr_update(hObject, eventdata, handles);
    msgbox('Done','Multiply All');


% --------------------------------------------------------------------
function mnuNormAllChi2_Callback(hObject, eventdata, handles)

    % Retrieve the 'epr' variable from the base workspace
    epr = evalin('base', 'epr');
    idx = get(handles.lbFiles, 'Value');
    idx = idx(1); % normalize to the first selected spectrum
    max_idx = numel(get(handles.lbFiles, 'String'));

    % Prompt for the range
    prompt = {'Enter range:'};
    dlg_title = 'Normalize All to Chi2';
    num_lines = 1;
    def = {'[0 inf]'};
    input = inputdlg(prompt, dlg_title, num_lines, def);

    if isempty(input)
        msgbox('Operation cancelled', 'Error', 'error');
        return;
    end

    range_str = input{1};

    % Prompt for the polynomial degree
    prompt = {'Enter the degree of the polynomial fit:'};
    dlg_title = 'Polynomial Degree';
    num_lines = 1;
    def = {'2'};
    degree_input = inputdlg(prompt, dlg_title, num_lines, def);

    if isempty(degree_input)
        msgbox('Operation cancelled', 'Error', 'error');
        return;
    end

    degree = str2double(degree_input{1});

    if isnan(degree)
        msgbox('Invalid input for degree. Operation cancelled', 'Error', 'error');
        return;
    end

    % Construct the fit function string
    fitfunstr = '';
    for i = degree:-1:0
        fitfunstr = [fitfunstr, sprintf('a%d*x^%d + ', i, i)];
    end
    fitfunstr = fitfunstr(1:end-3); % Remove the last " + "

    % Define coefficient names and model
    coeff_names = regexp(fitfunstr, 'a\d+', 'match');
    model = fittype(fitfunstr, 'coefficients', coeff_names);

    % Define options for the fit
    opts = fitoptions('Method', 'Nonlinear');
    opts.Display = 'notify';
    opts.Algorithm = 'Trust-Region';
    opts.MaxIter = 1000;
    opts.MaxFunEvals = 1000;
    opts.TolFun = 1e-10;
    opts.TolX = 1e-10;
    opts.Robust = 'Off';
    opts.StartPoint = zeros(1, degree+1);
    opts.Upper = [];
    opts.Lower = [];

    % Chi2 normalization loop
    chi2 = cell(1, max_idx);
    for i = 1:max_idx
        H = epr.data{i}.H;
        Y = epr.data{i}.Y;
        epr.data{i}.Yold = Y;
        [H, Y] = extrange(H, Y, range_str);
        H = reshape(H, [], 1);
        Y = reshape(Y, [], 1);
        [f1, gof] = fit(H, Y, model, opts);
        chi2{i} = gof.sse;
    end

    % Normalize the data based on the chi2 values
    for i = 1:max_idx
        epr.data{i}.Y = sqrt(chi2{idx} / chi2{i}) * epr.data{i}.Y;
        if isfield(epr.data{i}, 'X')
            epr.data{i}.X = sqrt(chi2{idx} / chi2{i}) * epr.data{i}.X;
        end
    end

    % Assign the modified 'epr' back to the base workspace
    assignin('base', 'epr', epr);

    % Refresh the UI
    butReload_Callback(hObject, eventdata, handles);
    eprplot(handles);
    epr_update(hObject, eventdata, handles);

    % Notify the user of completion
    msgbox('Done', 'Normalize All to Chi2');



% function mnuNormAllChi2_Callback(hObject, eventdata, handles)
% 
%     epr = evalin('base','epr');
%     idx = get(handles.lbFiles, 'Value');
%     idx = idx(1); % normalizes to first selected specter
%     max_idx = numel(get(handles.lbFiles, 'String'));
% 
%     prompt = {'Enter range:'};
%     dlg_title = 'Normalize All to Chi2';
%     num_lines = 1;
%     def = {'[0 inf]'};
%     [input] = inputdlg(prompt,dlg_title,num_lines,def);
%     range_str = input{1};
%     opts = fitoptions('Method','Nonlinear');
%     opts.Display = 'notify'; % 'notify'  'off'  'iter'
%     opts.Algorithm = 'Trust-Region';
%     opts.MaxIter = 1000;
%     opts.MaxFunEvals = 1000;
%     opts.TolFun = 1e-10;
%     opts.TolX = 1e-10;
%     opts.Robust = 'Off';
%     opts.StartPoint = [0 0 0 0 0 0 0 0 0];
%     opts.Upper = [];
%     opts.Lower = [];
%     % fitfunstr = 'a2*x^2 + a1*x + y0';
%     % model = fittype(fitfunstr, 'coefficients', {'a2', 'a1', 'y0'});
%     fitfunstr = 'a8*x^8 + a7*x^7 + a6*x^6 + a5*x^5 + a4*x^4 + a3*x^3 + a2*x^2 + a1*x + y0';
%     model = fittype(fitfunstr, 'coefficients', {'a8', 'a7', 'a6', 'a5', 'a4', 'a3', 'a2', 'a1', 'y0'});
%     chi2=[];
% 
%     for i=1:max_idx
%         H = epr.data{i}.H;
%         Y = epr.data{i}.Y;
%         epr.data{i}.Yold = Y;
%         [H Y] = extrange(H,Y,range_str);
%         H = reshape(H,[],1);
%         Y = reshape(Y,[],1);
%         [f1 gof] = fit(H, Y, model, opts);
%         chi2{i} = gof.sse;
%     end
% 
% 	for i=1:max_idx
%         epr.data{i}.Y = sqrt(chi2{idx}/chi2{i})*epr.data{i}.Y;
%         if isfield(epr.data{i},'X')
%             epr.data{i}.X = sqrt(chi2{idx}/chi2{i})*epr.data{i}.X;
%         end
%     end
%     assignin('base','epr',epr);
% 
%     butReload_Callback(hObject, eventdata, handles);
%     %set(handles.lbFiles, 'Value',idx);
%     eprplot(handles);
%     epr_update(hObject, eventdata, handles);
%     msgbox('Done','Normalize All to Chi2');
% 
function edtSimQuad_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtSimQuad_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkFitQuad.
function chkFitQuad_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuMulti_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    idx = get(handles.lbFiles, 'Value');

    prompt = {'Enter numeric factor:'};
    dlg_title = 'Multiply';
    num_lines = 1;
    def = {'100'};
    factor = str2double(inputdlg(prompt,dlg_title,num_lines,def));

    epr.data{idx}.Y = factor*epr.data{idx}.Y;
    if isfield(epr.data{idx},'X')
        epr.data{idx}.X = factor*epr.data{idx}.X;
    end

    assignin('base','epr',epr);

    butReload_Callback(hObject, eventdata, handles);
    set(handles.lbFiles, 'Value',idx);
    eprplot(handles);
    epr_update(hObject, eventdata, handles);
    msgbox('Done','Multiply')



% --------------------------------------------------------------------
function mnuCpySimRes_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    max_idx = numel(get(handles.lbFiles, 'String'));
    ress = [];
    header = '';
    for idx=1:max_idx
        if isempty(epr.sim{idx}), continue; end
        coefs = epr.sim{idx}.coefs;
        results = [epr.temp(idx) epr.freq(idx)];
        header = 'Temp Freq';
        for i=1:size(coefs,1)
            header = [header ' ' coefs{i,1}];
            results(end+1) = coefs{i,2};
        end
        header = [header ' chi2'];
        results(end+1) = epr.sim{idx}.chi2;
        
        ress(end+1,:) = results; 
    end
    if ~isempty(ress)
        disp(header)
        num2clip(ress);
        disp(ress)
        disp('Simulation results copied to the clipboard!');
    else
        errordlg('Simulation results not available!');
    end



% --------------------------------------------------------------------
function mnuEdit_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuBin_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    idx = get(handles.lbFiles, 'Value');

    n = floor(str2double(inputdlg('Binning:','Bin data', 1, {'2'})));

    if ~isfield(epr.data{idx},'Y0')
        epr.data{idx}.Y0 = epr.data{idx}.Y;
        epr.data{idx}.H0 = epr.data{idx}.H;
        epr.data{idx}.X0 = epr.data{idx}.X;
    end

    len = numel(epr.data{idx}.Y);
    j=1;
    for i=1:n:len-n+1
        Y(j) = mean(epr.data{idx}.Y(i:i+n-1));
        X(j) = mean(epr.data{idx}.X(i:i+n-1));
        H(j) = epr.data{idx}.H(i);
        j=j+1;
    end

    epr.data{idx}.Y = reshape(Y,1,[]);
    epr.data{idx}.X = reshape(X,1,[]);
    epr.data{idx}.H = reshape(H,1,[]);

    epr.data{idx}.exp.nPoints = numel(H);

    assignin('base','epr',epr);

    butReload_Callback(hObject, eventdata, handles);
    eprplot(handles);

    msgbox(['Number of points is ' num2str(epr.data{idx}.exp.nPoints)],'Binning')



% --------------------------------------------------------------------
function mnuBinAll_Callback(hObject, eventdata, handles)
    epr = evalin('base','epr');
    n = floor(str2double(inputdlg('Binning:','Bin data', 1, {'2'})));
    max_idx = numel(get(handles.lbFiles, 'String'));

    for idx=1:max_idx
        if ~isfield(epr.data{idx},'Y0')
            epr.data{idx}.Y0 = epr.data{idx}.Y;
            epr.data{idx}.H0 = epr.data{idx}.H;
            epr.data{idx}.X0 = epr.data{idx}.X;
        end

        len = numel(epr.data{idx}.Y);
        j=1;
        for i=1:n:len-n+1
            Y(j) = mean(epr.data{idx}.Y(i:i+n-1));
            X(j) = mean(epr.data{idx}.X(i:i+n-1));
            H(j) = epr.data{idx}.H(i);
            j=j+1;
        end

        epr.data{idx}.Y = reshape(Y,1,[]);
        epr.data{idx}.X = reshape(X,1,[]);
        epr.data{idx}.H = reshape(H,1,[]);

        epr.data{idx}.exp.nPoints = numel(H);

        assignin('base','epr',epr);

        butReload_Callback(hObject, eventdata, handles);
        eprplot(handles);
    end

    msgbox(['Number of points is ' num2str(epr.data{idx}.exp.nPoints)],'Binning')




function edtSimNOP_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtSimNOP_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit28_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butAbs.
function pushbutton47_Callback(hObject, eventdata, handles)


% --- Executes on button press in butPhDown.
function pushbutton48_Callback(hObject, eventdata, handles)


% --- Executes on button press in butPhUp.
function pushbutton49_Callback(hObject, eventdata, handles)


function edtHilbert_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    PHASE = str2double(get(handles.edtHilbert,'String'))/180*pi;
    idx = get(handles.lbFiles, 'Value');

    Y = epr.data{idx}.Y;
    H = epr.data{idx}.H;

    if isfield(epr.data{idx},'Yhil')
        Yhil = epr.data{idx}.Yhil;
        Xhil = epr.data{idx}.Xhil;
    else
        set(handles.edtHilbert,'String','Wait...');
        getframe();
        Xhil = hilbertTransform(H,Y);
        Yhil = epr.data{idx}.Y;
        set(handles.edtHilbert,'String',num2str(PHASE/pi*180));
    end

    X = cos(PHASE)*Xhil-sin(PHASE)*Yhil;
    Y = sin(PHASE)*Xhil+cos(PHASE)*Yhil;

    disp(['Signal integral = ' num2str(trapz(H,Y))]);

    epr.data{idx}.X = X;
    epr.data{idx}.Y = Y;
    epr.data{idx}.Xhil = Xhil;
    epr.data{idx}.Yhil = Yhil;

    assignin('base','epr',epr);
    eprplot(handles);


% User Function: Hilbert(Y(H)) = X(H)
function X = hilbertTransform(H,Y)
    Y = reshape(Y,1,[]);
    H = reshape(H,1,[]);
    for i=1:numel(H)
        h = H;
        h(i)=[];
        y = Y;
        y(i)=[];
    %     X(i) = trapz(h,y./(h-H(i)));
        X(i) = sum((y./(h-H(i)))*diff(H)');
    end
    X = 1/pi*X;
    X = reshape(X,[],1);


% --- Executes during object creation, after setting all properties.
function edtHilbert_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in butHilDown.
function butHilDown_Callback(hObject, eventdata, handles)

    PHASE = str2double(get(handles.edtHilbert,'String'));
    PHASE = PHASE - 1;
    set(handles.edtHilbert,'String',num2str(PHASE));
    edtHilbert_Callback(hObject, eventdata, handles)



% --- Executes on button press in butHilUp.
function butHilUp_Callback(hObject, eventdata, handles)

    PHASE = str2double(get(handles.edtHilbert,'String'));
    PHASE = PHASE + 1;
    set(handles.edtHilbert,'String',num2str(PHASE));
    edtHilbert_Callback(hObject, eventdata, handles)

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edtPhase.
function edtPhase_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes on key press with focus on edtPhase and none of its controls.
function edit28_KeyPressFcn(hObject, eventdata, handles)


% --- Executes on button press in butHilRecalc.
function butHilRecalc_Callback(hObject, eventdata, handles)

epr = evalin('base','epr');
idx = get(handles.lbFiles, 'Value');
if isfield(epr.data{idx},'Yhil')
    epr.data{idx} = rmfield(epr.data{idx},'Yhil');
    epr.data{idx} = rmfield(epr.data{idx},'Xhil');
end
assignin('base','epr',epr);
edtHilbert_Callback(hObject, eventdata, handles)


function edtLorW_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtLorW_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtLorHc_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtLorHc_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtLorB_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtLorB_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkFitLor.
function chkFitLor_Callback(hObject, eventdata, handles)


% --- Executes on selection change in popSimFun.
function popSimFun_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popSimFun_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edtLorPhi_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtLorPhi_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over butPlotFunc.
function butPlotFunc_ButtonDownFcn(hObject, eventdata, handles)



% --------------------------------------------------------------------
function New_ClickedCallback(hObject, eventdata, handles)



% --- Executes on button press in btnGaussmT.
function btnGaussmT_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    idx = get(handles.lbFiles, 'Value');
    epr.data{idx}.H = epr.data{idx}.H/10;
    assignin('base','epr',epr);
    eprplot(handles);


% --- Executes on button press in pushbutton57.
function pushbutton57_Callback(hObject, eventdata, handles)



% --------------------------------------------------------------------
function cmnCopySim_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');

    plotSim = get(handles.chkPlotSim, 'Value');
    plotSime = get(handles.chkPlotSim, 'Enable');
    if strcmp(plotSime,'on') && plotSim == 1 
        plotSim = 1;
    else
        plotSim = 0;
    end

    ma = [];

    for i=idx
        if plotSim == 1 && numel(epr.sim) >= i && ~isempty(epr.sim{i})
            simH = [0; epr.sim{i}.H];
            simY = [epr.temp(i); epr.sim{i}.Y];
            ma = [ma simH simY];
        else
            msgbox('Nothing to Copy!','Error');
        end
    end
    num2clip(ma)



% --------------------------------------------------------------------
function cmnCopyFit_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');

    plotFit = get(handles.chkPlotFit, 'Value');
    plotFite = get(handles.chkPlotFit, 'Enable');
    if strcmp(plotFite,'on') && plotFit == 1 
        plotFit = 1;
    else
        plotFit = 0;
    end

    ma = [];

    for i=idx
        if plotFit == 1 && numel(epr.fit.fits) >= i && ~isempty(epr.fit.fits{i})
            fitH = [0; epr.data{i}.H];
            fitY = [epr.temp(i); epr.fit.fits{i}.f(epr.data{i}.H)];
            ma = [ma fitH fitY];
        else
            msgbox('Nothing to Copy!','Error');
        end
    end
    num2clip(ma)


% --------------------------------------------------------------------
function mnuRetData_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    indices = get(handles.lbFiles, 'Value');
    
    for i = 1:numel(indices)
        idx = indices(i);
    
        if ~isfield(epr.data{idx}, 'Y0')
            msgbox('Nothing to return!', 'Error');
            continue;
        end
    
        epr.data{idx}.H = epr.data{idx}.H0;
        epr.data{idx}.Y = epr.data{idx}.Y0;
        epr.data{idx}.X = epr.data{idx}.X0;
        epr.data{idx}.exp.nPoints = numel(epr.data{idx}.H);
    end
    
    assignin('base', 'epr', epr);
    eprplot(handles);
    msgbox(['Spectra ' num2str(indices) ' have been restored!'], 'Return Data');


    
% --------------------------------------------------------------------
function mnuFitData_Callback(hObject, eventdata, handles)

    butSim_Callback(hObject, eventdata, handles)



% --------------------------------------------------------------------
function mnuShift_Callback(hObject, eventdata, handles)
    epr = evalin('base','epr');
    idx = get(handles.lbFiles, 'Value');

    shift = inputdlg('Shift data to the right:','Shift',1,{'0'});
    if numel(shift)==0
        return;
    end

    if ~isfield(epr.data{idx},'H0')
        epr.data{idx}.H0 = epr.data{idx}.H;
    end
    epr.data{idx}.H = epr.data{idx}.H + str2num(shift{1})*ones(size(epr.data{idx}.H));

    assignin('base','epr',epr);
    eprplot(handles);
    msgbox(['Specter ' num2str(idx) ' has been shifted!'],'Shift Data');


% --- Executes during object creation, after setting all properties.
function uitFit_CreateFcn(hObject, eventdata, handles)


function edtFN_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtFN_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butESBrowse.
function butESBrowse_Callback(hObject, eventdata, handles)


% --- Executes on button press in butESexe.
function butESexe_Callback(hObject, eventdata, handles)
    
%     fid = fopen(get(handles.edtFN,'String'));
%         C = textscan(fid, '%s','delimiter', '\n');
%     fclose(fid);
        
    eprplot(handles); % replot data
        
    C = get(handles.edtES,'String');
    epr = evalin('base','epr');
    idx = get(handles.lbFiles, 'Value');
    
    Exp = epr.data{idx}.exp;
    spc = epr.data{idx}.Y(1:Exp.nPoints);
    H = epr.data{idx}.H(1:Exp.nPoints);
    
    Exp = rmfield(Exp,'CenterSweep');
    Exp.Range = [H(1) H(end)];
    
    assignin('base','spc',spc);
    assignin('base','Exp',Exp);
    for i=1:numel(C)
        evalin('base',C{i});
    end
    
    
    epr.ES = C;
    if evalin('base','exist(''f'',''var'')')
        epr.sim{idx}.H = evalin('base','f');
        epr.sim{idx}.Y = evalin('base','s');
        epr.sim{idx}.ES = C;
    end
    assignin('base','epr',epr);
    
    

% --- Executes on button press in butESRun.
function butESRun_Callback(hObject, eventdata, handles)


function edtRep_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtRep_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkFitHc.
function chkFitHc_Callback(hObject, eventdata, handles)



function edtCalibrate_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtCalibrate_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butCalibrate.
function butCalibrate_Callback(hObject, eventdata, handles)

    muB = 9.27e-24; %Am2
    kB = 1.38e-23;  %J/K
    Na = 6.022e23;
    txt = get(handles.edtCalibrate,'String');

    for i=1:numel(txt)
        eval(txt{i});
    end

    Std_Mass = Std_Mass/1000;
    Sam_Mass = Sam_Mass/1000;

    Std_N = Std_Mass/Std_MolMass*Na;
    Std_chi = 0.1*Std_N*(Std_gFactor*muB)*(Std_gFactor*muB)*Std_S*(Std_S+1)/3/kB/T

    Sam_N = Sam_Mass/Sam_MolMass*Na;

    Sam_chi = Std_chi/Std_Intensity*Sam_Intensity/Sam_Stpch*Std_Stpch;

    Sam_chi = Sam_chi/Sam_Mass;

    Sam_chi = Sam_chi*Sam_MolMass;

    N = Std_N /Std_Intensity*Sam_Intensity*Std_gFactor*Std_gFactor*Std_S*(Std_S+1)/(Sam_gFactor*Sam_gFactor*Sam_S*(Sam_S+1));

    set(handles.txtCalibrate,'String',['Chi = ' num2str(1e3*Sam_chi) ' 10^-3 emu/mol']);
    set(handles.txtCalN,'String',['N = ' num2str(N,'%e') ' (' num2str(100*N/Sam_N) '%)']);

    epr = evalin('base','epr');
    epr.cal.params = get(handles.edtCalibrate,'String');
    epr.cal.chi = get(handles.txtCalibrate,'String');
    epr.cal.N = get(handles.txtCalN,'String');
    assignin('base','epr',epr);



% --------------------------------------------------------------------
function mnuData_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    names = get(handles.lbFiles, 'String');
    nameParts = split(names{1}, ' ');
    FileName = ['dat' nameParts{2} '.dat'];
    [FileName,PathName] = uiputfile('*.dat','Save to directory',FileName);
    if ~isequal(FileName, 0)
        ret = questdlg('All files will be saved in this directory with an appendix ''dat...'' .','Confirm');
        if ~strcmp(ret,'Yes')
            return
        end
        cd(PathName);

        for i=1:numel(names)
            nameParts = split(names{i}, ' ');
            FileName = ['dat' nameParts{2} '.dat'];
            export_data([PathName FileName],epr,i);
        end
    end
    msgbox(['Fits have been saved to ' PathName],'Saved');



function export_data(Filename, epr, idx)
%     [pathstr, name, ext] = fileparts(Filename);
%     for i=idx
        H = epr.data{idx}.H';
        Y = epr.data{idx}.Y';
        X = epr.data{idx}.X';
        
        fid = fopen(Filename, 'wt');
            fprintf(fid, '# H (mT)\t \tY\t \tX\n');
            fprintf(fid, '%e\t%e\t%e\n', [H; Y; X]); %fprintf(fid, '%f\t%f\t%f\n', [H; Y; X]);
        fclose(fid);
%     end



% --------------------------------------------------------------------
function mnuSData_Callback(hObject, eventdata, handles)

    [FileName,PathName] = uiputfile('*.dat');
    if ~isequal(FileName, 0)
        cd(PathName);
        epr = evalin('base','epr');
        idx = get(handles.lbFiles, 'Value');
        export_data([PathName FileName],epr,idx);
    end
    msgbox(['Data has been saved to ' [PathName FileName]],'Saved');


% --------------------------------------------------------------------
function mnuCalcGfact_Callback(hObject, eventdata, handles)

    epr = evalin('base','epr');
    coefs = get(handles.uitFit,'Data');
    xcs = [];
    if ~isempty(coefs)
        coefstr = coefs(:,1);
        coefval = coefs(:,2);
        for k=1:10
            for i=1:numel(coefstr)
                if strcmp(coefstr{i},['xc' num2str(k)])
                    xcs = [xcs coefval{i}];
                end
            end
        end
    end
    idx = get(handles.lbFiles, 'Value');
    freq = epr.freq(idx);
    gs = 71.44775*freq./xcs;

    prompt = {'xc = ','g = '};
    dlg_title = 'Calculate g-factor';
    num_lines = 1;

    def = {num2str(xcs),num2str(gs)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    while numel(answer)~=0
        if isempty(answer{1})
            gs = str2num(answer{2});
            xcs = 71.44775*freq./gs;
            def = {num2str(xcs),num2str(gs)};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
        elseif isempty(answer{2})
            xcs = str2num(answer{1});
            gs = 71.44775*freq./xcs;
            def = {num2str(xcs),num2str(gs)};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
        else
            answer={};
        end
    end
    


% --------------------------------------------------------------------
function cpyFigure_Callback(hObject, eventdata, handles)
    set(handles.txtSell,'BackgroundColor','white');
    set(handles.txtVersion,'BackgroundColor','white');
    print -dmeta % -dbitmap
    set(handles.txtSell,'BackgroundColor',get(handles.figure1,'Color'));
    set(handles.txtVersion,'BackgroundColor',get(handles.figure1,'Color'));
    msgbox('Done!','Copy Figure')


% --- Executes on selection change in lbSimFun.
function lbSimFun_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function lbSimFun_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butSimAdd.
function butSimAdd_Callback(hObject, eventdata, handles)
    func_num = get(handles.popSimFun, 'Value');
    func_list = get(handles.popSimFun, 'String');
    list_sel = get(handles.lbSimFun, 'String');
    coefs = get(handles.uitSim, 'Data');
    param_num = size(coefs,1);

    % Delete empty rows
    rm = [];
    for i=1:param_num
       if strcmp(coefs{i,1},'') 
           rm = [rm i];
       end
    end
    coefs(rm,:)=[];
    param_num = size(coefs,1);

    % Search for max number
    max_number=0;
    for i=1:numel(list_sel)
        numb = str2double(list_sel{i}(~isletter(list_sel{i})));
        if numb > max_number
            max_number = numb;
        end
    end

    apend = num2str(max_number+1);

    [~, cnames startVal] = fun_lib_sim(func_list{func_num});
    
    for j=1:numel(cnames)
        vrstica = {[cnames{j} apend],startVal(j),false,'', 1};
        coefs = [coefs; vrstica];
        set(handles.uitSim, 'Data', coefs);
    end

    % Add function
    list_sel{numel(list_sel)+1} = [func_list{func_num} apend];
    set(handles.lbSimFun, 'String',list_sel);




% --- Executes on button press in butSimRemove.
function butSimRemove_Callback(hObject, eventdata, handles)

    list_sel = get(handles.lbSimFun, 'String');
    list_num = get(handles.lbSimFun, 'Value');
    coefs = get(handles.uitSim,'Data');

    % Get Function number
    tmp = list_sel{list_num};
    tmp(isletter(tmp)) = [];                % remove lettters
    if tmp == ''
        number = '0';
    else
        number = tmp;
    end

    % Find parameters with function number
    rem = [];
    for i=1:size(coefs,1)
        if strfind(coefs{i,1},number)
            rem = [rem i];
        end
    end

    % Remove parameters
    coefs(rem,:)=[];
    set(handles.uitSim,'Data',coefs);

    % Remove function
    list_sel(list_num) = [];
    set(handles.lbSimFun, 'String',list_sel);

    % Set function value
    if list_num > 1
        set(handles.lbSimFun, 'Value',list_num-1);
    else
        set(handles.lbSimFun, 'Value',1);
    end



% --- Executes during object creation, after setting all properties.
function butRunFitFun_CreateFcn(hObject, eventdata, handles)
    
    
function mnuSimulate_Callback(hObject, eventdata, handles)
    


% --- Executes on button press in pushbutton78.
function pushbutton78_Callback(hObject, eventdata, handles)




function edit46_Callback(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit46 as text
%        str2double(get(hObject,'String')) returns contents of edit46 as a double


% --- Executes during object creation, after setting all properties.
function edit46_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton79.
function pushbutton79_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton79 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton80.
function pushbutton80_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton80 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton81.
function pushbutton81_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton81 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit47_Callback(hObject, eventdata, handles)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit47 as text
%        str2double(get(hObject,'String')) returns contents of edit47 as a double


% --- Executes during object creation, after setting all properties.
function edit47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton82.
function pushbutton82_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton83.
function pushbutton83_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton84.
function pushbutton84_Callback(hObject, eventdata, handles)


function edit48_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit48_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton85.
function pushbutton85_Callback(hObject, eventdata, handles)

% --- Executes on button press in pushbutton86.
function pushbutton86_Callback(hObject, eventdata, handles)


% --- Executes on button press in butESrun.
function butESrun_Callback(hObject, eventdata, handles)



function edtES_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtES_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butESexe.
function pushbutton88_Callback(hObject, eventdata, handles)



% --- Executes on button press in pushbutton89.
function pushbutton89_Callback(hObject, eventdata, handles)


% --- Executes on button press in butSimUndo.
function butSimUndo_Callback(hObject, eventdata, handles)
    if evalin('base','exist(''simHist'',''var'')')
        simHist = evalin('base','simHist');
        ind = simHist.current;
        if ind > 1
            ind = ind - 1;
            set(handles.uitSim, 'Data', simHist.params{ind});
            set(handles.lbSimFun, 'String', simHist.functions{ind});
            simHist.current = ind;
            assignin('base','simHist', simHist);
        else
            disp('No more data!');
        end
    else
        disp('No data!');
    end


% --- Executes on button press in butSimReUndo.
function butSimReUndo_Callback(hObject, eventdata, handles)
    if evalin('base','exist(''simHist'',''var'')')
        simHist = evalin('base','simHist');
        ind = simHist.current;
        if ind < numel(simHist.params)
            ind = ind + 1;
            set(handles.uitSim, 'Data',simHist.params{ind});
            set(handles.lbSimFun, 'String', simHist.functions{ind});
            simHist.current = ind;
            assignin('base','simHist',simHist);
        else
            disp('No more data!');
        end
    else
        disp('No data!');
    end

    
    
function backupSim(handles)
    
    if evalin('base','exist(''simHist'',''var'')')
        simHist = evalin('base','simHist');
    else
        simHist.params = {};
        simHist.functions = {};
        simHist.current = 0;
    end
    
    newPar = get(handles.uitSim, 'Data');
    newFun = get(handles.lbSimFun, 'String');
    if simHist.current > 0
        if isequalcell(simHist.params{end},newPar)
           return; 
        end
    end
    
%     if simHist.current == numel(simHist.param)
        simHist.params{end+1} = newPar;
        simHist.functions{end+1} = newFun;
        simHist.current = numel(simHist.params);
        assignin('base','simHist',simHist);
%     end

function backupFit(handles)
    
    if evalin('base','exist(''fitHist'',''var'')')
        fitHist = evalin('base','fitHist');
    else
        fitHist.params = {};
        fitHist.functions = {};
        fitHist.current = 0;
    end

    newPar = get(handles.uitFit, 'Data');
    newFun = get(handles.lbFunctions, 'String');
    if fitHist.current > 0
        if isequalcell(fitHist.params{end},newPar)
           return; 
        end
    end
    
    fitHist.params{end+1} = newPar;
    fitHist.functions{end+1} = newFun;
    fitHist.current = numel(fitHist.params);
    assignin('base','fitHist',fitHist);


function r = isequalcell(C1,C2)
    r = 0;
    if ~isequal(size(C1),size(C2)), return; end;
    for i=1:numel(C1)
    	if ~isequal(C1{i},C2{i}), return; end;
    end
    r = 1;



% --- Executes on button press in chkShowComp.
function chkShowComp_Callback(hObject, eventdata, handles)
% hObject    handle to chkShowComp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkShowComp


% --- Executes on button press in butFitUndo.
function butFitUndo_Callback(hObject, eventdata, handles)
    if evalin('base','exist(''fitHist'',''var'')')
        fitHist = evalin('base','fitHist');
        ind = fitHist.current;
        if ind > 1
            ind = ind - 1;
            set(handles.uitFit, 'Data',fitHist.params{ind});
            set(handles.lbFunctions, 'String', fitHist.functions{ind});
            fitHist.current = ind;
            assignin('base','fitHist',fitHist);
        else
            disp('No more data!');
        end
    else
        disp('No data!');
    end


% --- Executes on button press in butFitReundo.
function butFitReundo_Callback(hObject, eventdata, handles)
    if evalin('base','exist(''fitHist'',''var'')')
        fitHist = evalin('base','fitHist');
        ind = fitHist.current;
        if ind < numel(fitHist.params)
            ind = ind + 1;
            set(handles.uitFit, 'Data',fitHist.params{ind});
            set(handles.lbFunctions, 'String', fitHist.functions{ind});
            fitHist.current = ind;
            assignin('base','fitHist',fitHist);
        else
            disp('No more data!');
        end
    else
        disp('No data!');
    end


% --- Executes on key press with focus on butFitFunc and none of its controls.
function butFitFunc_KeyPressFcn(hObject, eventdata, handles)


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on edtES and none of its controls.
function edtES_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edtES (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function sort_tables(hObject, eventdata, handles)
    
    coefs_shared = get(handles.uitShared, 'Data');
    coefs_specific = get(handles.uitSpecific, 'Data');
    
    if ~isempty(coefs_shared)
        numbers_sh = coefs_shared(:,1);
        for i=1:size(numbers_sh,1)
            numbers_sh{i} = numbers_sh{i}(~isletter(numbers_sh{i}));
        end
        [~, order] = sort(numbers_sh);
        set(handles.uitShared, 'Data', coefs_shared(order,:));
    end
    
    if ~isempty(coefs_specific)
        numbers_sp = coefs_specific(:,1);
        numbers_sp(:,2) = num2cell(zeros(size(numbers_sp,1),1));
        for i=1:size(numbers_sp,1)
            numbers_sp(i,:) = num2cell(str2double(split(numbers_sp{i}(~isletter(numbers_sp{i})), '_')));
        end
        [~, order] = sortrows(numbers_sp, [2 1]);
        set(handles.uitSpecific, 'Data', coefs_specific(order,:));
    end
    
    
    
function butGlobAdd_Callback(hObject, eventdata, handles)
    
    epr = evalin('base','epr');
    
    file_idxs = epr.glob.file_idxs;
    coef_names = epr.glob.coef_names;
    func_num = get(handles.popGlobFun, 'Value');
    func_list = get(handles.popGlobFun, 'String');
    list_sel = get(handles.lbFunGlob, 'String');
    coefs_shared = get(handles.uitShared, 'Data');
    coefs_specific = get(handles.uitSpecific, 'Data');
    shared_param_num = size(coefs_shared,1);
    specific_param_num = size(coefs_specific,1);
    
    % Delete empty rows
    rm = [];
    for i=1:shared_param_num
       if strcmp(coefs_shared{i,1},'') 
           rm = [rm i];
       end
    end
    coefs_shared(rm,:)=[];
    shared_param_num = size(coefs_shared,1);
    set(handles.uitShared, 'Data', coefs_shared);
    
    rm = [];
    for i=1:specific_param_num
       if strcmp(coefs_specific{i,1},'')
           rm = [rm i];
       end
    end
    coefs_specific(rm,:)=[];
    specific_param_num = size(coefs_specific,1);
    
    max_number=0;
    for i=1:numel(list_sel)
        numb = str2double(list_sel{i}(~isletter(list_sel{i})));
        if numb > max_number
            max_number = numb;
        end
    end
    
    fun_num = num2str(max_number+1);
    ft = fittype(fun_lib_glob(func_list{func_num}),'indep','x', 'dep','neki');
    cnames = coeffnames(ft);
    for i=1:numel(cnames) % add to specific parameters by default
        if any(strcmp(cnames{i}, {'y','s'}))
            min = -Inf;
        else
            min = 0;
        end
        coef_names{end+1} = [cnames{i} fun_num]; % add to parameter list
        for j=file_idxs
            vrstica = {[cnames{i} fun_num '_' num2str(j)],0,min,Inf,false, '', 1};
            coefs_specific = [coefs_specific; vrstica];
        end
    end
    epr.glob.coef_names = coef_names;
    set(handles.uitSpecific, 'Data', coefs_specific);
    
    % Add function
    list_sel{numel(list_sel)+1} = [func_list{func_num} fun_num];
    
    set(handles.lbFunGlob, 'Value',1);
    set(handles.lbFunGlob, 'String',list_sel);
    sort_tables(hObject, eventdata, handles);
    % Save epr
    assignin('base','epr',epr);


function butGlobRem_Callback(hObject, eventdata, handles)
    
    epr = evalin('base','epr');
    
    coef_names = epr.glob.coef_names;
    shared_idxs = epr.glob.shared_idxs;
    list_sel = get(handles.lbFunGlob, 'String');
    list_num = get(handles.lbFunGlob, 'Value');
    coefs_shared = get(handles.uitShared, 'Data');
    coefs_specific = get(handles.uitSpecific, 'Data');
    
    number = list_sel{list_num}(~isletter(list_sel{list_num}));
    
    % Find parameters with function number
    rem = [];
    for i=1:numel(coef_names)
        if strfind(coef_names{i},number)
            rem = [rem i];
        end
    end
    rem_sh = [];
    for i=1:size(coefs_shared,1)
        if strfind(coefs_shared{i},number)
            rem_sh = [rem_sh i];
        end
    end
    rem_sp = [];
    for i=1:size(coefs_specific,1)
        parts = split(coefs_specific{i,1}, '_');
        if strfind(parts{1},number)
            rem_sp = [rem_sp i];
        end
    end
    
    % change number order for functions
    for i=list_num:numel(list_sel)
        par = list_sel{i};
        name = par; name(~isletter(name))=[];
        numb = par; numb(isletter(numb))=[];
        numb = str2double(numb)-1;
        list_sel{i} = [name num2str(numb)];
    end
        
    % change number order for coefficients
    for i=rem(1):numel(coef_names)
        par = coef_names{i};
        name = par; name(~isletter(name))=[];
        numb = par; numb(isletter(numb))=[];
        numb = str2double(numb)-1;
        coef_names{i} = [name num2str(numb)];
    end
    for i=1:size(coefs_shared,1)
        par = coefs_shared{i,1};
        name = par; name(~isletter(name))=[];
        numb = par; numb(isletter(numb))=[];
        numb = str2double(numb)-1;
        if numb >= str2double(number)
            coefs_shared{i,1} = [name num2str(numb)];
        end
    end
    for i=1:size(coefs_specific,1)
        par = coefs_specific{i,1};
        name = par; name(~isletter(name))=[];
        numbs = par; numbs(isletter(numbs))=[];
        numbs = split(numbs, '_'); % string vector
        if str2double(numbs(1)) > str2double(number)
            coefs_specific{i,1} = [name num2str(str2double(numbs(1))-1) '_' char(numbs(2))];
        end
    end
    
    % Remove parameters
    coef_names(rem)=[];
    coefs_shared(rem_sh,:)=[];
    coefs_specific(rem_sp,:)=[];
    
    shared_idxs(ismember(shared_idxs, rem)) = [];
    shared_idxs(shared_idxs > rem(end)) = shared_idxs(shared_idxs > rem(end)) - numel(rem);
    
    
    % Remove function
    list_sel(list_num) = [];
    
    % write fields
    epr.glob.coef_names = coef_names;
    epr.glob.shared_idxs = shared_idxs;
    set(handles.uitShared,'Data',coefs_shared);
    set(handles.uitSpecific,'Data',coefs_specific);
    set(handles.lbFunGlob, 'String',list_sel);

    % Set function value
    if list_num > 1
        set(handles.lbFunGlob, 'Value',list_num-1);
    else
        set(handles.lbFunGlob, 'Value',1);
    end
    % Save epr
    assignin('base','epr',epr);


function butEditShare_Callback(hObject, eventdata, handles)
    
    epr = evalin('base','epr');
    
    file_idxs = epr.glob.file_idxs;
    if ~isfield(epr.glob, 'coef_names') || isempty(epr.glob.coef_names)
        msgbox('No parameters!');
        return
    else
        coef_names = epr.glob.coef_names;
    end
    transfered_values = {};
    shared_idxs = epr.glob.shared_idxs;
    coefs_shared = get(handles.uitShared, 'Data');
    coefs_specific = get(handles.uitSpecific, 'Data');
    
    
    [shared_idxs_new, tf] = listdlg('ListString', coef_names, 'PromptString', 'Select shared parameters', 'InitialValue', shared_idxs, 'Name', 'Shared parameter selection');
    if ~tf
        return
    end
    epr.glob.shared_idxs = shared_idxs_new;
    
    added = shared_idxs_new(~ismember(shared_idxs_new, shared_idxs)); % coef_names indices
    removed = shared_idxs(~ismember(shared_idxs, shared_idxs_new)); % coef_names indices
    
    % removing
    rem_sh = [];
    for i=removed
        idxs = find(contains(coefs_shared(:,1), coef_names(i))); % row indices in shared
        rem_sh = [rem_sh idxs];
        transferred_values{i} = coefs_shared(idxs(1), 2:end); % should be only one value in idxs anyway, copies row without name
    end
    rem_sp = []; %contains(coefs_specific(:,1), coef_names(added));
    for i=added
        idxs = find(contains(coefs_specific(:,1), coef_names(i))); % row indices in specific
        rem_sp = [rem_sp idxs];
        transferred_values{i} = coefs_specific(idxs(1), 2:end); % copies first row without name
    end
    % remove table rows
    coefs_shared(rem_sh,:) =[];
    coefs_specific(rem_sp,:) = [];
    
    
    % adding
    % to shared
    for i=added
        coefs_shared(end+1,:) = [coef_names{i}, transferred_values{i}];
    end
    
    % to specific
    for j=file_idxs
        for i=removed
            coefs_specific(end+1,:) = [[coef_names{i} '_' num2str(j)] transferred_values{i}];
        end
    end
    
    set(handles.uitShared, 'Data', coefs_shared);
    set(handles.uitSpecific, 'Data', coefs_specific);
    sort_tables(hObject, eventdata, handles);
    % Save epr
    assignin('base','epr',epr);
    
    
function butSelectedFiles_Callback(hObject, eventdata, handles)
        
    epr = evalin('base','epr');
        
    file_idxs = epr.glob.file_idxs;
    coef_names = epr.glob.coef_names;
    shared_idxs = epr.glob.shared_idxs;
    coefs_shared = get(handles.uitShared, 'Data');
    coefs_specific = get(handles.uitSpecific, 'Data');
    
    files = get(handles.lbFiles, 'String');
    
    [file_idxs_new, tf] = listdlg('ListString', files, 'PromptString', 'Select used files', 'InitialValue', file_idxs(file_idxs <= numel(files)), 'Name', 'File selection');
    if ~tf
        return
    end
    epr.glob.file_idxs = file_idxs_new;
    
    added = file_idxs_new(~ismember(file_idxs_new, file_idxs)); % files indices
    removed = file_idxs(~ismember(file_idxs, file_idxs_new)); % files indices
    for j = removed % remove fits
        epr.glob.fits{j} = [];
    end
    
    % removing file-specific parameters
    rem_sp=[];
    for j=removed
        for i=1:size(coefs_specific,1)
            par = coefs_specific{i,1};
            numbs = par; numbs(isletter(numbs) | numbs == ' ')=[];
            numbs = split(numbs, '_'); % string vector
            if isempty(numbs) || str2double(numbs(2)) == j
                rem_sp = [rem_sp i];
            end
        end
    end
    coefs_specific(rem_sp,:) = [];
    
    % adding file-specific parameters
    for i=find(~ismember(1:numel(coef_names), shared_idxs))
        if any(strcmp(coef_names{i}(1), {'y','s'}))
            min = -Inf;
        else
            min = 0;
        end
        for j=added
            vrstica = {[coef_names{i} '_' num2str(j)],0,min,Inf,false, '', 1};
            coefs_specific = [coefs_specific; vrstica];
        end
    end
    
    set(handles.uitShared, 'Data', coefs_shared);
    set(handles.uitSpecific, 'Data', coefs_specific);
    sort_tables(hObject, eventdata, handles);
    % Save epr
    assignin('base','epr',epr);


% User function: retruns equation string from lbGlobFun
function equ = getGlobEquation(handles)
        
    funList = get(handles.lbFunGlob, 'String');
    equ = '';
        
    for i = 1:numel(funList)
        number = str2double(funList{i}(~isletter(funList{i})));
        func = funList{ i}(isletter(funList{i}));
        equ = [equ ' + ' fun_lib_glob(func, number)];
    end


function butPlotGlob_Callback(hObject, eventdata, handles)
    
    idxs = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');
    
    funstr = getGlobEquation(handles);
    coefs_shared = get(handles.uitShared, 'Data');
    coefs_specific = get(handles.uitSpecific, 'Data');
    file_idxs = epr.glob.file_idxs;
    coef_names = epr.glob.coef_names;
    shared_idxs = epr.glob.shared_idxs;
    
    toDraw = ismember(idxs, file_idxs);
    if any(~toDraw)
        msgbox(['File(s) ' num2str(idxs(~toDraw)) ...
            ' is/are not selected for global fit.']);
    end
    
    % Copy linked values (only the first occurence is needed) -------------
    links = {}; % {link name, fixed?}
    % shared
    for i = 1:size(coefs_shared, 1)
        link = coefs_shared{i,6};
        value = coefs_shared{i,2}/coefs_shared{i,7}; % normalized value
        if ~isempty(link) % is linked
            linkFound = false;
            for j = 1:size(links,1)
                if strcmp(links{j,1},link) % link found
                    linkFound = true;
                    if coefs_shared{i,5} && ~links{j,2} % if current is fixed but not all linked are
                        for k = 1:size(coefs_shared,1) % all shared linked are set to fixed, specific will be set later
                            if strcmp(coefs_shared{k,6},link)
                                coefs_shared{k,5} = true;
                            end
                        end
                    end
                end
            end
            if ~linkFound % this is the first link
                for j = i+1:size(coefs_shared,1)
                    if strcmp(coefs_shared{j,6},link)
                        coefs_shared{j,2} = value * coefs_shared{j,7}; % all links after this are overwritten to scale
                        if coefs_shared{i,5}
                            coefs_shared{j,5} = true; % if first one is fixed all others get fixed too
                        end
                    end
                end
                for j = i+1:size(coefs_specific,1)
                    if strcmp(coefs_specific{j,6},link)
                        coefs_specific{j,2} = value * coefs_specific{j,7}; % all links after this are overwritten to scale
                        if coefs_specific{i,5}
                            coefs_specific{j,5} = true; % if first one is fixed all others get fixed too
                        end
                    end
                end
                links(end+1,:) = {link, coefs_shared{i,5}};
            end
        end
    end
    % specific
    for i = 1:size(coefs_specific, 1)
        link = coefs_specific{i,6};
        value = coefs_specific{i,2}/coefs_specific{i,7}; % normalized value
        if ~isempty(link) % is linked
            linkFound = false;
            for j = 1:size(links,1)
                if strcmp(links{j,1},link) % link found
                    linkFound = true;
                    if coefs_specific{i,5} && ~links{j,2} % if current is fixed but not all linked are
                        for k = 1:size(coefs_shared,1) % all shared linked are set to fixed
                            if strcmp(coefs_shared{k,6},link)
                                coefs_shared{k,5} = true;
                            end
                        end
                        for k = 1:size(coefs_specific,1) % all  specific linked are set to fixed
                            if strcmp(coefs_specific{k,6},link)
                                coefs_specific{k,5} = true;
                            end
                        end
                    end
                end
            end
            if ~linkFound % this is the first link
                for j = i+1:size(coefs_specific,1)
                    if strcmp(coefs_specific{j,6},link)
                        coefs_specific{j,2} = value * coefs_specific{j,7}; % all links after this are overwritten to scale
                        if coefs_specific{i,5}
                            coefs_specific{j,5} = true; % if first one is fixed all others get fixed too
                        end
                    end
                end
                links(end+1,:) = {link, coefs_specific{i,5}};
            end
        end
    end
    set(handles.uitShared,'Data', coefs_shared);
    set(handles.uitSpecific,'Data', coefs_specific);
    %----------------------------------------------------------------------
    
    chi2 = 0;
    for idx = file_idxs
        H = epr.data{idx}.H;
        Y = epr.data{idx}.Y;
        range = get(handles.edtGlobRange, 'String');
        [H, Y] = extrange(H,Y,range);
        if numel(H) == 1 || isempty(H)
            msgbox('Please widen your range!', 'Error Range');
            return
        end
        x = H;
        for i = 1:size(coefs_shared,1)
            name = coefs_shared{i,1};
            value = coefs_shared{i,2};
%             disp([name ' = ' num2str(value)]);
            eval([name '=' num2str(value) ';']);
        end
        for i = 1:size(coefs_specific,1)
            tmp = coefs_specific{i,1};
            value = coefs_specific{i,2};
            name = split(tmp, '_');
            if str2double(name(2)) == idx
%                 disp([char(name(1)) ' = ' num2str(value)]);
                eval([char(name(1)) '=' num2str(value) ';']);
            end
        end
        
        Ycalc = eval(funstr);
        chi2 = chi2 + sum((Y-Ycalc).*(Y-Ycalc));
        
        epr.glob.fits{idx}.H = H;
        epr.glob.fits{idx}.Y = Ycalc;
    end
    epr.glob.coefs_shared = coefs_shared;
    epr.glob.coefs_specific = coefs_specific;
    epr.glob.range = range;
    epr.glob.funstr = funstr;
    
    set(handles.txtGlobChi2, 'String',['Chi2 = ' num2str(chi2,'%5.5e')]);
    assignin('base','epr',epr);
    set(handles.chkPlotGlob,'Value',1);
    eprplot(handles);
    backupGlob(handles);


function butFitGlob_Callback(hObject, eventdata, handles)
    
    idxs = get(handles.lbFiles, 'Value');
    epr = evalin('base','epr');
    
    funstr = getGlobEquation(handles);
    coefs_shared = get(handles.uitShared, 'Data');
    coefs_specific = get(handles.uitSpecific, 'Data');
    file_idxs = epr.glob.file_idxs;
    coef_names = epr.glob.coef_names;
    shared_idxs = epr.glob.shared_idxs;
    
    opts = fitoptions('Method','Nonlinear');
    opts.Display =    'notify';                  % 'notify'  'off'  'iter'

    string_list = get(handles.popGlobMethod,'String');
    val = get(handles.popGlobMethod,'Value');
    opts.Algorithm = string_list{val};   % 'Trust-Region'  'Levenberg-Marquardt'

    opts.MaxIter = str2double(get(handles.edtGlobMaxIter,'String'));
    opts.MaxFunEvals = str2double(get(handles.edtGlobMaxFunE,'String'));
    opts.TolFun = str2double(get(handles.edtGlobTolFun,'String'));
    opts.TolX = str2double(get(handles.edtGlobTolX,'String'));
    
    string_list = get(handles.popGlobRobust,'String');
    val = get(handles.popGlobRobust,'Value');
    opts.Robust = string_list{val};
    
    range = get(handles.edtGlobRange, 'String');
    
    toDraw = ismember(idxs, file_idxs);
    if any(~toDraw)
        msgbox(['File(s) ' num2str(idxs(~toDraw)) ...
            ' is/are not selected for global fit.']);
    end
    
    % Copy linked values (only the first occurence is needed) -------------
    links = {}; % {link name, fixed?}
    % shared
    for i = 1:size(coefs_shared, 1)
        link = coefs_shared{i,6};
        value = coefs_shared{i,2}/coefs_shared{i,7}; % normalized value
        if ~isempty(link) % is linked
            linkFound = false;
            for j = 1:size(links,1)
                if strcmp(links{j,1},link) % link found
                    linkFound = true;
                    if coefs_shared{i,5} && ~links{j,2} % if current is fixed but not all linked are
                        for k = 1:size(coefs_shared,1) % all shared linked are set to fixed, specific will be set later
                            if strcmp(coefs_shared{k,6},link)
                                coefs_shared{k,5} = true;
                            end
                        end
                    end
                end
            end
            if ~linkFound % this is the first link
                for j = i+1:size(coefs_shared,1)
                    if strcmp(coefs_shared{j,6},link)
                        coefs_shared{j,2} = value * coefs_shared{j,7}; % all links after this are overwritten to scale
                        if coefs_shared{i,5}
                            coefs_shared{j,5} = true; % if first one is fixed all others get fixed too
                        end
                    end
                end
                for j = i+1:size(coefs_specific,1)
                    if strcmp(coefs_specific{j,6},link)
                        coefs_specific{j,2} = value * coefs_specific{j,7}; % all links after this are overwritten to scale
                        if coefs_specific{i,5}
                            coefs_specific{j,5} = true; % if first one is fixed all others get fixed too
                        end
                    end
                end
                links(end+1,:) = {link, coefs_shared{i,5}};
            end
        end
    end
    % specific
    for i = 1:size(coefs_specific, 1)
        link = coefs_specific{i,6};
        value = coefs_specific{i,2}/coefs_specific{i,7}; % normalized value
        if ~isempty(link) % is linked
            linkFound = false;
            for j = 1:size(links,1)
                if strcmp(links{j,1},link) % link found
                    linkFound = true;
                    if coefs_specific{i,5} && ~links{j,2} % if current is fixed but not all linked are
                        for k = 1:size(coefs_shared,1) % all shared linked are set to fixed
                            if strcmp(coefs_shared{k,6},link)
                                coefs_shared{k,5} = true;
                            end
                        end
                        for k = 1:size(coefs_specific,1) % all  specific linked are set to fixed
                            if strcmp(coefs_specific{k,6},link)
                                coefs_specific{k,5} = true;
                            end
                        end
                    end
                end
            end
            if ~linkFound % this is the first link
                for j = i+1:size(coefs_specific,1)
                    if strcmp(coefs_specific{j,6},link)
                        coefs_specific{j,2} = value * coefs_specific{j,7}; % all links after this are overwritten to scale
                        if coefs_specific{i,5}
                            coefs_specific{j,5} = true; % if first one is fixed all others get fixed too
                        end
                    end
                end
                links(end+1,:) = {link, coefs_specific{i,5}};
            end
        end
    end
    set(handles.uitShared,'Data', coefs_shared);
    set(handles.uitSpecific,'Data', coefs_specific);
    %----------------------------------------------------------------------
    
    % Constructing equation string
    specific = coef_names;
    specific(shared_idxs) = [];
    
    padding = 0.001; % padding between datasets
    modelfunstr = '';
    Hmodel = [];
    Ymodel = [];
    n = numel(file_idxs);
    maxH = 0;
    for i = 1:n
        idx = file_idxs(i);
        H = epr.data{idx}.H;
        Y = epr.data{idx}.Y;
        [H Y] = extrange(H,Y,range);
        H = reshape(H,[],1);
        Y = reshape(Y,[],1);
        delta = maxH - H(1) + padding; % how much it is shifted up
        H = H + delta; % shift
        boundry = (H(1) + maxH)/2; % between previous and new dataset (H(1) is now shifted!)
        maxH = H(end); % new maxH
        Hmodel = [Hmodel; H];
        Ymodel = [Ymodel; Y];
        modelfunstr = strrep(modelfunstr, 'boundry', num2str(boundry)); % upper boundry for previous equation
        tmpfunstr = funstr; % a copy of the equation
        for j = 1:numel(specific)
            coef = specific{j};
            new = [coef '_' num2str(idx)];
            tmpfunstr = strrep(tmpfunstr, coef, new); % specific coefficients are inserted
        end
        tmpfunstr = regexprep(tmpfunstr, '(\W)x(\W)', ['$1(x-' num2str(delta) ')$2']); % x are shifted back for correct calculations, regexp used so it doestn replace xc
        % following is equivalent to 'if x < boundry: A else B' where A is
        % the current equation and B is next expression to be nested.
        if i < n
            modelfunstr = [modelfunstr '(sign(boundry-x)+1)/2*(' tmpfunstr ') + (1-(sign(boundry-x)+1)/2)*('];
        else
            modelfunstr = [modelfunstr tmpfunstr repmat(')',1,n-1)]; % last equation is inserted and all the brackets are closed
        end
    end
    
    % Get fit function, coefficient and problems names and values
    coefs = [coefs_shared; coefs_specific];
    
    coef_values = coefs(:,2:end); % coef_values have 1 index less than table coefs
    coef_names_m = coefs(:,1)';
    param_names = coef_names_m;

    % Find vary and not vary indeces (vary = not fixed)
    vary_idx = find(cell2mat(coef_values(:,4))==0);
    not_vary_idx = find(cell2mat(coef_values(:,4))==1);

    % Extract not vary = fixed
    prob_values = coef_values(not_vary_idx,1)'; % num2cell(...)
    prob_names = coef_names_m(not_vary_idx);

    % Extract vary = not fixed
    coef_values(not_vary_idx,:) = [];
    coef_names_m(not_vary_idx) = [];

    linkValues = {}; % {link name, normalized coefficient name}
    model_coefs = {}; % {(normalized) coefficient name, normalized value, normalized upper limit, normalized lower limit}
    for i = 1:size(coef_names_m,2)
        link = coef_values{i,5};
        scale = coef_values{i,6};
        if ~isempty(link) % is linked
            linkFound = false;
            for j = 1:size(linkValues,1) % numel(linkValues(:,1))
                if strcmp(linkValues{j,1},link) % link found
                    linkFound = true;
                    modelfunstr = regexprep(modelfunstr, ['(\W)' coef_names_m{i} '(\W)'], ['$1(' num2str(scale) '*' linkValues{j,2} ')$2']); % coefficient name in function is replaced with scaled normalized coefficient name
                end
            end
            if ~linkFound % this is the first occurence
                linkValues(end+1,:) = {link, coef_names_m{i}}; % adds link name and self name to linkValues
                modelfunstr = regexprep(modelfunstr, ['(\W)' coef_names_m{i} '(\W)'], ['$1(' num2str(scale) '*' coef_names_m{i} ')$2']); % replaces self name with scaled self name (starting values are normalized)
                model_coefs(end+1,:) = {coef_names_m{i}, coef_values{i,1}/scale, coef_values{i,2}/scale, coef_values{i,3}/scale}; % saves coefficient name and normalized value and limits
            end
        else % is not linked
            model_coefs(end+1,:) = {coef_names_m{i}, coef_values{i,1}, coef_values{i,2}, coef_values{i,3}}; % saves coefficient name, value and limits (not normalized because it is not scaled in the equation
        end
    end
    
    % Set fit model
    epr.glob.modelfunstr = modelfunstr;
%     assignin('base','epr',epr);
    model = fittype(modelfunstr,'problem',prob_names,'coefficients', model_coefs(:,1));
    
    
    opts.StartPoint = cell2mat(model_coefs(:,2))'; % coef_values(:,1))';        % Update start value
    if strcmp(opts.Algorithm,'Trust-Region')==1
        opts.Upper = cell2mat(model_coefs(:,4))'; % coef_values(:,3))';         % Update upper limits
        opts.Lower = cell2mat(model_coefs(:,3))'; % coef_values(:,2))';         % Update lower limits
    else
        opts.Upper = [];         % Delete upper limits
        opts.Lower = [];         % Delete lower limits
    end
    
    % FIT
    [f1 gof] = fit(Hmodel, Ymodel, model, opts, 'problem', prob_values);
    res_coefs = coeffvalues(f1);        % Get fit coefficients
    % Extract errors
    ci = confint(f1,0.95);      % Boundaries within 95%
    res_err = (ci(2,:)-ci(1,:))/2;  % Absolute error
%     epr.glob.debug.Hmodel = Hmodel;
%     epr.glob.debug.Ymodel = Ymodel;
%     epr.glob.debug.Ycalc = f1(Hmodel);
    
    coeff = [];
    err = [];
    for j = 1:size(coef_names_m,2)
        link = coef_values{j,5};
        scale = coef_values{j,6};
        if ~isempty(link) % is linked
            link_idx = find(strcmp(linkValues(:,1), link));
            coef_idx = find(strcmp(model_coefs(:,1), linkValues(link_idx,2)));
            coeff = [coeff res_coefs(coef_idx)*scale];
            err = [err res_err(coef_idx)*scale];
        else % is not linked
            coef_idx = find(strcmp(model_coefs(:,1), coef_names_m{j}));
            coeff = [coeff res_coefs(coef_idx)];
            err = [err res_err(coef_idx)];
        end
    end
    
%     epr.glob.f = f1;
    opts.StartPoint = coeff;
    epr.glob.opts = opts;
%     epr.glob.model = model;
    epr.glob.gof = gof;
    
    % First column - coefficients
    res(vary_idx,1) = coeff;
    res(not_vary_idx,1) = cell2mat(prob_values);
    
    % Second column - errors
    res(vary_idx,2) = err;
    res(not_vary_idx,2) = zeros(1,numel(prob_values));
    
    
%     vrstica = [reshape(epr.glob.results',1,[]) epr.glob.gof.sse];  
%     results = vrstica;
%     results_g = results;
%     g_idx = 2*find(strncmpi('xc',param_names,2)) - 1;  % 2* because of the errors
%     for j = g_idx
%         idx = split(param_names(j),'_'); idx = str2double(idx(2)); % KAJ PA PR SHARED ??
%         xc = results(j);
%         dxc = results(j+1);
%         g = xc2g(xc,epr.freq(i));
%         results_g(i,j) = g;
%         results_g(i,j+1) = g*dxc/xc;
%     end

    for i=1:size(res,1)
        ind = -1;
        for j=1:size(coefs,1)
            if strcmp(coefs{j,1},param_names{i})
                ind = j;
            end
        end
        if ind > 0
            coefs{ind,2} = res(i,1);
        end
    end
    Nsh = size(coefs_shared,1);
    
    res_sh = res(1:Nsh,:);
    res_sp = res(Nsh+1:end,:);
    res = [epr.temp(epr.glob.file_idxs)' reshape(res_sp', [], numel(epr.glob.file_idxs))' repmat(reshape(res_sh', 1, []), numel(epr.glob.file_idxs), 1)];
    epr.glob.results = res;
    
    resnames = {'Temp'};
    for name = coefs_specific(1:(numel(coef_names) - numel(shared_idxs)),1)'
        tmp = split(name, '_');
        resnames{end+1} = char(tmp(1));
        resnames{end+1} = ['d ' char(tmp(1))];
    end
    for name = coefs_shared(:,1)'
        name=name{1};
        resnames{end+1} = name;
        resnames{end+1} = ['d ' name];
    end
    epr.glob.resnames = string(resnames);
    
    set(handles.uitShared,'Data',coefs(1:Nsh,:));
    set(handles.uitSpecific,'Data',coefs(Nsh+1:end,:));
    set(handles.txtGlobChi2, 'String',['Chi2 = ' num2str(epr.glob.gof.sse,'%5.5e')]);
    
    % Save epr
    assignin('base','epr',epr);
    
    set(handles.chkPlotGlob,'Value',1);
    butPlotGlob_Callback(hObject, eventdata, handles);
    disp('Done.'); 
    backupGlob(handles);
    
    
function backupGlob(handles)
    
    if evalin('base','exist(''globHist'',''var'')')
        globHist = evalin('base','globHist');
    else
        globHist.sharedParams = {};
        globHist.specificParams = {};
        globHist.functions = {};
        globHist.current = 0;
    end

    newShPar = get(handles.uitShared, 'Data');
    newSpPar = get(handles.uitSpecific, 'Data');
    newFun = get(handles.lbFunGlob, 'String');
    if globHist.current > 0
        if isequalcell(globHist.sharedParams{end},newShPar) && isequalcell(globHist.specificParams{end},newSpPar)
           return; 
        end
    end
    
    globHist.sharedParams{end+1} = newShPar;
    globHist.specificParams{end+1} = newSpPar;
    globHist.functions{end+1} = newFun;
    globHist.current = numel(globHist.sharedParams);
    assignin('base','globHist',globHist);



% --- Executes on button press in butGlobUndo.
function butGlobUndo_Callback(hObject, eventdata, handles)
    if evalin('base','exist(''globHist'',''var'')')
        globHist = evalin('base','globHist');
        ind = globHist.current;
        if ind > 1
            ind = ind - 1;
            set(handles.uitShared, 'Data',globHist.sharedParams{ind});
            set(handles.uitSpecific, 'Data',globHist.specificParams{ind});
            set(handles.lbFunGlob, 'String', globHist.functions{ind});
            globHist.current = ind;
            assignin('base','globHist',globHist);
        else
            disp('No more data!');
        end
    else
        disp('No data!');
    end


% --- Executes on button press in butGlobRedo.
function butGlobRedo_Callback(hObject, eventdata, handles)
    if evalin('base','exist(''globHist'',''var'')')
        globHist = evalin('base','globHist');
        ind = globHist.current;
        if ind < numel(globHist.sharedParams)
            ind = ind + 1;
            set(handles.uitShared, 'Data',globHist.sharedParams{ind});
            set(handles.uitSpecific, 'Data',globHist.specificParams{ind});
            set(handles.lbFunGlob, 'String', globHist.functions{ind});
            globHist.current = ind;
            assignin('base','globHist',globHist);
        else
            disp('No more data!');
        end
    else
        disp('No data!');
    end


function mnuCpyGlobResults_Callback(hObject, eventdata, handles)
    epr = evalin('base','epr');

    res = epr.glob.results;
    num2clip(res)
    msgbox('Global fit results have been copied to clipboard','Saved');

    
% User function: export selected fit
function export_globfit(Filename, epr, idx)

    H = epr.data{idx}.H';
    Y = epr.data{idx}.Y';
    F = epr.glob.fits{idx}.Y';

    fid = fopen(Filename, 'wt');
    fprintf(fid, '# eprFit 5.0  exported data+fit file;  Anton Potocnik @ IJS F5\n');
    fprintf(fid, '# ------------------------------------------------------------\n');
    fprintf(fid, '# Original data file:\n');
    fprintf(fid, '# %s\n',epr.data{idx}.fname);
    fprintf(fid, '# Fit function:\n');
    fprintf(fid, '# %s\n',epr.glob.funstr);
    fprintf(fid, '# Coefficients:\n');
    tmp = epr.glob.resnames; % fieldnames(epr.fit.coef);
    j = find(epr.glob.file_idxs == idx);
    for i=1:(numel(tmp)-1)/2
        fprintf(fid, '#  %s\t',tmp{2*i});
        fprintf(fid, '%e\t+-%e\n',[epr.glob.results(j,i*2);epr.glob.results(j,i*2+1)]); %fprintf(fid, '%f\t+-%f\n',[epr.glob.results(j,i*2);epr.glob.results(j,i*2+1)]);
    end
    fprintf(fid, '# Data:\n');
    fprintf(fid, '# X\t \tY\t \tFit\n');

    fprintf(fid, '%e\t%e\t%e\n', [H; Y; F]);
    fclose(fid);
    
    
function mnuExpGlobFit_Callback(hObject, eventdata, handles)
    
    [FileName,PathName] = uiputfile('*.dat');
    if ~isequal(FileName, 0)
        cd(PathName);
        epr = evalin('base','epr');
        idx = get(handles.lbFiles, 'Value');
        if all(ismember(idx, epr.glob.file_idxs))
            export_globfit([PathName FileName],epr,idx);
        else
            msgbox('This file is not included in global fit.');
            return
        end
    end
    msgbox(['Global fit has been saved to ' [PathName FileName]],'Saved');
        

function mnuExpAGlobFits_Callback(hObject, eventdata, handles)
    
    epr = evalin('base','epr');
    names = get(handles.lbFiles, 'String');
    nameParts = split(names{1}, ' ');
    FileName = ['gfit' nameParts{2} '.dat'];
    [FileName,PathName] = uiputfile('*.dat','Save to directory',FileName);
    if ~isequal(FileName, 0)
        ret = questdlg('All files will be saved in this directory with an appendix ''gfit...'' .','Confirm');
        if ~strcmp(ret,'Yes')
            return
        end
        cd(PathName);

        for idx=epr.glob.file_idxs
            nameParts = split(names{idx}, ' ');
            FileName = ['gfit' nameParts{2} '.dat'];
            export_globfit([PathName FileName],epr,idx);
        end
    end
    msgbox(['Global fits have been saved to ' PathName],'Saved');
        
        
        
