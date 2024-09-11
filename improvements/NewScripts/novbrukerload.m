function [H, Y, exp] = brukerload(filename)

    [Path, Name, Ext] = fileparts(filename);
    Path = [Path '\'];
    
    % Initialize variables
    temp = [];
    npnt = [];
    freq = [];
    powr = [];
    cent = [];
    swep = [];
    modb = [];
    modf = [];
    rcco = [];
    stim = [];
    nscn = [];
    RCAG = [];
    ctim = [];
    
    % Read .DSC description file
    id = fopen([Path Name '.DSC']);
    if id == -1
        error([Name ' cannot be found !!!']);
    end
    
    str = fgetl(id);
    while ischar(str)
        if contains(str, 'DATE')
            DATE = str(9:end);
        end
        if contains(str, 'TIME')
            TIME = str(9:end);
        end
        if contains(str, 'MWFQ')  % MW_frequency
            freq = str2double(str(9:end));
        end
        if contains(str, 'MWPW')  % MW_power
            powr = str2double(str(9:end));
        end
        if contains(str, 'CenterField')  % Center Field
            cent = str2double(str(15:end-2));
        end
        if contains(str, 'SweepWidth')  % Sweep
            swep = str2double(str(14:end-2));
        end
        if contains(str, 'ModAmp')  % Modulation_Field
            modb = str2double(str(10:end-2));
        end
        if contains(str, 'ModFreq')  % Modulation_Field
            modf = str2double(str(11:end-4));
        end
        if contains(str, 'TimeConst')  % RC_Constant
            rcco = str2double(str(15:end-3));
        end
        if contains(str, 'SweepTime')  % Sweep_Time
            stim = str2double(str(11:end-2));
        end
        if contains(str, 'NbScansDone')  % Number of scans
            nscn = str2double(str(15:end));
        end
        if contains(str, 'XPTS')  % Number of points
            npnt = str2double(str(5:end));
        end
        if contains(str, 'RCAG')  % Sensitivity
            RCAG = str2double(str(5:end));
        end
        if contains(str, 'ConvTime')  % Sensitivity
            ctim = 1e-3 * str2double(str(14:end-3));
        end
        if contains(str, 'Temperature')  % Temperature
            temp = str2double(str(15:end-2));
        end
        str = fgetl(id);
    end
    fclose(id);

    % Check if 'temp' was set and if file name contains 'RT'
    if isempty(temp) && contains(Name, 'RT')
        temp = 295;
    end

    % Ensure npnt is set
    if isempty(npnt)
        error('Number of points (XPTS) not found in .DSC file');
    end

    % Read .DTA data file
    id = fopen([Path Name '.DTA'], 'r', 'ieee-be');
    if id == -1
        error([Name ' cannot be found !!!']);
    end
    Y = fread(id, [npnt, 1], 'float64', 'ieee-be');
    fclose(id);

    H = linspace((cent - swep / 2), (cent + swep / 2), npnt); % in Gauss

    % Fill the exp structure
    exp = struct();
    if ~isempty(temp)
        exp.Temperature = temp;
    end
    if ~isempty(freq)
        exp.mwFreq = freq;
    end
    if ~isempty(powr)
        exp.Power = powr;
    end
    if ~isempty(cent) && ~isempty(swep)
        exp.CenterSweep = [cent swep] / 10; % units: [mT]
    end
    if ~isempty(npnt)
        exp.nPoints = npnt;
    end
    if ~isempty(nscn)
        exp.nScans = nscn;
    end
    if ~isempty(modf)
        exp.modFreq = modf;
    end
    if ~isempty(modb)
        exp.modB = modb;
    end
    if ~isempty(rcco)
        exp.RC_Constant = rcco;
    end
    if ~isempty(ctim)
        exp.cTime = ctim;
    end
    if ~isempty(RCAG)
        exp.RCAG = RCAG;
    end

    % Correct amplitude
    if isempty(nscn) || nscn == 0
        nscn = 1;
    end
    Y = Y / nscn;

end