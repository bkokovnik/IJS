clear
[B,spc,Params] = eprload('C:\Users\Bor Kokovnik\Documents\IJS\eprPodatki\Yb2Be2GeO7_10K.DTA');

Exp.mwFreq = 9.659833;
Exp.Range = [0 1180];
Exp.Temperature = 10;


Sys.S = 1/2;
Sys.g = 1.1429;
Sys.L = 3;
Sys.soc = -2900*clight*1e-4;
% Sys.CF2 = [0 0 1.01681e+08 0 0];          % CF(2,q) with q = +2,+1,0,-1,-2
% Sys.CF4 = [0 0 0 0 9.46368e+06 0 0 0 0];
% Sys.CF6 = [1e+05 0 0 0 0 0 1e+05 0 0 0 0 0 0];
% Sys.CF2 = [0 0 2.0423e+06 0 0];
% Sys.CF4 = [12425 0 0 0 57819 0 0 0 0];
% Sys.CF6 = [0 0 4200.06 0 0 0 513 0 0 0 0 0 0];
% Sys.HStrain = [4000.87 4000.83 4000.81];
% Sys.CF2 = [0 0 2.95077e+06 0 0];
% Sys.CF4 = [4965.13 0 0 0 52747.6 0 0 0 0];
% Sys.CF6 = [0 0 -8271.72 0 0 0 635.173 0 0 0 0 0 0];
% Sys.HStrain = [9339.56, 6955.05, 8701.18];


% Fit z mesti parametrov iz članka
% Sys.g = 0.0332861;
% Sys.HStrain = [8298.62 16718.3 7640.08];
% Sys.CF2 = [0 0 2.4276e+08 0 0];
% Sys.CF4 = [0 0 0 0 9.65058e+06 0 0 0 0];
% Sys.CF6 = [3.10529e+07 0 0 0 0 0 1.49307e+06 0 0 0 0 0 0];

% % Optimalni parametri
% Sys.g = 1.1429;
Sys.CF2 = [0 0 3.07401e+06 0 0];
Sys.CF4 = [3618.27 0 0 0 50379.5 0 0 0 0];
Sys.CF6 = [0 0 -8889.88 0 0 0 678.39 0 0 0 0 0 0];
Sys.HStrain = [9124.38 8088.21 9596.74];


SysVary.g = 0.1;
SysVary.CF2 = [0 0 0.25e+06 0 0];
SysVary.CF4 = [5000 0 0 0 5000 0 0 0 0];
SysVary.CF6 = [0 0 2000 0 0 0 200 0 0 0 0 0 0];
SysVary.HStrain = [10000 10000 10000];

esfit(spc,@pepper,{Sys,Exp},{SysVary});