clear
[B,spc,Params] = eprload('C:\Users\Bor Kokovnik\Documents\IJS\eprPodatki\Yb2Be2GeO7_20K.DTA');

Exp.mwFreq = 9.659833;
Exp.Range = [0 1180];
Exp.Temperature = 20;


Sys.S = 1/2;
Sys.g = 1.1429;
Sys.L = 3;
Sys.soc = -2900*clight*1e-4;
% Sys.CF2 = [1.48086e+08 0 1.01681e+08 0 0];          % CF(2,q) with q = +2,+1,0,-1,-2
% Sys.CF4 = [0 0 0 0 9.46368e+06 0 0 0 0];
% Sys.HStrain = [9704.18 9416.19 9501.77];

% % Optimalni parametri
% Sys.g = 1.1429;
% Sys.CF2 = [1.37811e+08 0 1.05105e+08 0 0];
% Sys.CF4 = [0 0 0 0 9.60566e+06 0 0 0 0];
% Sys.HStrain = [9748.41 9800.47 10625];

Sys.g = 1.1429;
Sys.CF2 = [0 0 2.98927e+06 0 0];
Sys.CF4 = [5044.27 0 0 0 51346.3 0 0 0 0];
Sys.CF6 = [0 0 -8357.16 0 0 0 683.98 0 0 0 0 0 0];
Sys.HStrain = [9381.48 5946.79 9426.38];


% SysVary.g = 0.1;
SysVary.CF2 = [0 0 0.25e+06 0 0];
SysVary.CF4 = [5000 0 0 0 5000 0 0 0 0];
SysVary.CF6 = [0 0 2000 0 0 0 200 0 0 0 0 0 0];
SysVary.HStrain = [10000 10000 10000];

FitOpt.TolFun = 1e-6;

esfit(spc,@pepper,{Sys,Exp},{SysVary});