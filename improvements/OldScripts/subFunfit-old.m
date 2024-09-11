function mnuSubFit_Callback(hObject, eventdata, handles)

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

    if numel(epr.fit.fits) < index || isempty(epr.fit.fits{index}) 
        msgbox('Fit not available!','Error');
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

    fitY = epr.fit.fits{index}.f(H);
    epr.data{idx}.Y = Y - factor*fitY;

    assignin('base','epr',epr);
    eprplot(handles);