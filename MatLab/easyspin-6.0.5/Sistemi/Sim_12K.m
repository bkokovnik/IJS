clear
[B,spc,Params] = eprload('C:\Users\Bor Kokovnik\Documents\IJS\eprPodatki\Yb2Be2GeO7_12K.DTA');

Exp.mwFreq = 9.659833;
Exp.Range = [0 1180];
Exp.Temperature = 12;


Sys.S = 1/2;
Sys.g = 1.1429;
Sys.L = 3;
Sys.soc = -2900*clight*1e-4;
Sys.CF2 = [0 0 3.04032e+06 0 0];
Sys.CF4 = [4988.61 0 0 0 50483.2 0 0 0 0];
Sys.CF6 = [0 0 -7765.95 0 0 0 644.82 0 0 0 0 0 0];
Sys.HStrain = [8629.96 5739.08 9682.49];

% % Optimalni parametri
% Sys.CF2 = [0 0 3.16109e+06 0 0];
% Sys.CF4 = [4256.31 0 0 0 52627.1 0 0 0 0];
% Sys.CF6 = [0 0 -9006.02 0 0 0 766.984 0 0 0 0 0 0];
% Sys.HStrain = [7337.47 7438.5 6471.69];

% Sys.g = 1.1429;
% Sys.CF2 = [0 0 2.95077e+06 0 0];
% Sys.CF4 = [4965.13 0 0 0 52747.6 0 0 0 0];
% Sys.CF6 = [0 0 -8271.72 0 0 0 635.173 0 0 0 0 0 0];
% Sys.HStrain = [9339.56, 6955.05, 8701.18];


SysVary.g = 0.1;
SysVary.CF2 = [0 0 0.25e+06 0 0];
SysVary.CF4 = [5000 0 0 0 5000 0 0 0 0];
SysVary.CF6 = [0 0 2000 0 0 0 200 0 0 0 0 0 0];
SysVary.HStrain = [10000 10000 10000];


FitOpt.TolFun = 1e-6;

esfit(spc,@pepper,{Sys,Exp},{SysVary});