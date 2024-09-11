clear
[B,spc,Params] = eprload('Yb2Be2GeO7_30K.DTA');

Exp.mwFreq = 9.659833;
Exp.Range = [0 1180];
Exp.Temperature = 30;


Sys.S = 1/2;
Sys.g = 1.1429;
Sys.L = 3;
Sys.soc = -2900*clight*1e-4;
Sys.CF2 = [0 0 2.0423e+06 0 0];
Sys.CF4 = [12425 0 0 0 57819 0 0 0 0];
Sys.CF6 = [0 0 4200.06 0 0 0 513 0 0 0 0 0 0];
Sys.HStrain = [8262.87 9601.83 8980.81];
% Sys.lw = [0 300];


% SysVary.g = 0.5;
SysVary.CF2 = [0 0 1e+06 0 0];
SysVary.CF4 = [10000 0 0 0 10000 0 0 0 0];
SysVary.CF6 = [0 0 2000 0 0 0 200 0 0 0 0 0 0];
SysVary.HStrain = [10000 10000 10000];


esfit(spc,@pepper,{Sys,Exp},{SysVary});