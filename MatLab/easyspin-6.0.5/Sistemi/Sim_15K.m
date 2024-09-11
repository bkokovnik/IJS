clear
[B,spc,Params] = eprload('C:\Users\Bor Kokovnik\Documents\IJS\eprPodatki\Yb2Be2GeO7_15K.DTA');

Exp.mwFreq = 9.659833;
Exp.Range = [0 1180];
Exp.Temperature = 15;


Sys.S = 1/2;
Sys.g = 1.1429;
Sys.L = 3;
Sys.soc = -2900*clight*1e-4;
% Sys.CF2 = [1.48086e+08 0 1.01681e+08 0 0];          % CF(2,q) with q = +2,+1,0,-1,-2
% Sys.CF4 = [0 0 0 0 9.46368e+06 0 0 0 0];
% Sys.HStrain = [9704.18 9416.19 9501.77];
% 
% % % Optimalni parametri
% % Sys.g = 1.1429;
% % Sys.CF2 = [1.10752e+08 0 1.51627e+08 0 0];
% % Sys.CF4 = [0 0 0 0 7.47304e+06 0 0 0 0];
% % Sys.HStrain = [6984 10319 8369];
% 
% 
% SysVary.g = 0.5;
% SysVary.HStrain = [10000 10000 10000];
% SysVary.CF2 = [0.5e+08 0 0.5e+08 0 0];
% SysVary.CF4 = [0 0 0 0 2e+06 0 0 0 0];


Sys.g = 1.1429;
Sys.CF2 = [0 0 3.00239e+06 0 0];
Sys.CF4 = [4995.17 0 0 0 50399.2 0 0 0 0];
Sys.CF6 = [0 0 -8488.92 0 0 0 677.63 0 0 0 0 0 0];
Sys.HStrain = [9112.12 7532.16 9469.5];


% SysVary.g = 0.1;
SysVary.CF2 = [0 0 0.25e+06 0 0];
SysVary.CF4 = [5000 0 0 0 5000 0 0 0 0];
SysVary.CF6 = [0 0 2000 0 0 0 200 0 0 0 0 0 0];
SysVary.HStrain = [10000 10000 10000];

FitOpt.TolFun = 1e-6;

esfit(spc,@pepper,{Sys,Exp},{SysVary});