	epr = evalin('base','epr');
    s = 0;
    y0 = 0;
    q = 0;

    coefs = get(handles.uitFit,'Data');
    if ~isempty(coefs)
        coefstr = coefs(:,1);
        coefval = coefs(:,2);

        for i=1:numel(coefstr)
            if strcmp(coefstr{i},'y0')
                y0 = coefval{i};
            end
        end
        for i=1:numel(coefstr)
            if strcmp(coefstr{i},'s')
                s = coefval{i};
            end
        end
        for i=1:numel(coefstr)
            if strcmp(coefstr{i},'q1')
                q = coefval{i};
            end
        end
    end

    prompt = {'q = ','s =','y0 ='};
    dlg_title = 'Substract y = q*x*x + s*x + y0';
    num_lines = 1;

    def = {num2str(q),num2str(s),num2str(y0)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if numel(answer)==0
        return;
    end

    q = str2double(answer{1});
    s = str2double(answer{2});
    y0 = str2double(answer{3});

    idx = get(handles.lbFiles, 'Value');

    H = epr.data{idx}.H; % in mT
    Y = epr.data{idx}.Y;
    H = reshape(H,[],1);
    
    epr.data{idx}.Y = Y  - q*H.*H - s*H - y0;

    assignin('base','epr',epr);
    eprplot(handles);
