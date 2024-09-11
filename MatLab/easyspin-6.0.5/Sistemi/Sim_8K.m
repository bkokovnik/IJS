clear
[B,spc,Params] = eprload('C:\Users\Bor Kokovnik\Documents\IJS\eprPodatki\Yb2Be2GeO7_8K.DTA');

Exp.mwFreq = 9.659833;
Exp.Range = [0 1180];
Exp.Temperature = 8;


Sys.S = 1/2;
Sys.g = 1.1429;
Sys.L = 3;
Sys.soc = -2900*clight*1e-4;
Sys.CF2 = [0 0 2939128.116 0 0];
Sys.CF4 = [5576.277 0 0 0 47748.000 0 0 0 0];
Sys.CF6 = [0 0 -8191.501 0 0 0 586.028 0 0 0 0 0 0];
Sys.HStrain = [9074.459 8295.430 9587.865];

% Exp.CrystalSymmetry = 113;


SysVary.g = 0.1;
SysVary.CF2 = [0 0 0.25e+06 0 0];
SysVary.CF4 = [5000 0 0 0 5000 0 0 0 0];
SysVary.CF6 = [0 0 2000 0 0 0 200 0 0 0 0 0 0];
SysVary.HStrain = [10000 10000 10000];


esfit(spc,@pepper,{Sys,Exp},{SysVary});