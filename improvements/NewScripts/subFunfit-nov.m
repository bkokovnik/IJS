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
