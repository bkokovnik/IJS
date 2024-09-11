    epr = evalin('base','epr');
    idx = get(handles.lbFiles, 'Value');
    idx = idx(1); % normalizes to first selected specter
    max_idx = numel(get(handles.lbFiles, 'String'));
    
    prompt = {'Enter range:'};
    dlg_title = 'Normalize All to Chi2';
    num_lines = 1;
    def = {'[0 inf]'};
    [input] = inputdlg(prompt,dlg_title,num_lines,def);
    range_str = input{1};
    opts = fitoptions('Method','Nonlinear');
    opts.Display = 'notify'; % 'notify'  'off'  'iter'
    opts.Algorithm = 'Trust-Region';
    opts.MaxIter = 1000;
    opts.MaxFunEvals = 1000;
    opts.TolFun = 1e-10;
    opts.TolX = 1e-10;
    opts.Robust = 'Off';
    opts.StartPoint = [0 0 0];
    opts.Upper = [];
    opts.Lower = [];
    fitfunstr = 'a2*x^2 + a1*x + y0';
    model = fittype(fitfunstr, 'coefficients', {'a2', 'a1', 'y0'});
    % fitfunstr = 'a8*x^8 + a7*x^7 + a6*x^6 + a5*x^5 + a4*x^4 + a3*x^3 + a2*x^2 + a1*x + y0';
    % model = fittype(fitfunstr, 'coefficients', {'a8', 'a7', 'a6', 'a5', 'a4', 'a3', 'a2', 'a1', 'y0'});
    chi2=[];
	
    for i=1:max_idx
        H = epr.data{i}.H;
        Y = epr.data{i}.Y;
        epr.data{i}.Yold = Y;
        [H Y] = extrange(H,Y,range_str);
        H = reshape(H,[],1);
        Y = reshape(Y,[],1);
        [f1 gof] = fit(H, Y, model, opts);
        chi2{i} = gof.sse;
    end
	
	for i=1:max_idx
        epr.data{i}.Y = sqrt(chi2{idx}/chi2{i})*epr.data{i}.Y;
        if isfield(epr.data{i},'X')
            epr.data{i}.X = sqrt(chi2{idx}/chi2{i})*epr.data{i}.X;
        end
    end
    assignin('base','epr',epr);
    
    butReload_Callback(hObject, eventdata, handles);
    %set(handles.lbFiles, 'Value',idx);
    eprplot(handles);
    epr_update(hObject, eventdata, handles);
    msgbox('Done','Normalize All to Chi2');