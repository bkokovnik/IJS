clear
[B,spc,Params] = eprload('Yb2Be2GeO7_30K.DTA');

% Experimental parameters
Exp.mwFreq = 9.659833;
Exp.Range = [0 1180];
% Exp.nPoints = 4096;

Sys.S = 1/2;
Sys.g = 1.1429;
% Sys.g = [-0.9053 0.9110 6.6537];  % Vrednosti iz članka
% Sys.g = [-5.43594 0.785285 2.04464]  % Najboljši fit do sedaj
% Sys.D = [3000 750];     % MHz
% Sys.lw = [0 300];             % mT
% Sys.Nucs = 'Yb';
% Sys.A = [2 3 5]*360;  % MHz
Sys.L = 3;
Sys.soc = -2900*clight*1e-4;
Exp.Temperature = 30;
% Sys.CF2 = [0 0 4658774.79732 0 0];          % CF(2,q) with q = +2,+1,0,-1,-2
% Sys.CF4 = [0 0 0 0 1729802.48266 0 0 0 0];
% Sys.CF6 = [14177185.33882 0 0 0 0 0 767468.69248 0 0 0 0 0 0];
% Sys.CF2 = [0 0 7740000 0 0];  % Podatki iz članka
Sys.HStrain = [9704.18 9416.19, 9501.77];
% Sys.HStrain = [5460 10476.1 10149.6];  % Najboljši fit do sedaj
% Exp.CrystalSymmetry = 113;
Sys.CF2 = [1.48086e+08 0 1.01681e+08 0 0];          % CF(2,q) with q = +2,+1,0,-1,-2
Sys.CF4 = [0 0 0 0 9.46368e+06 0 0 0 0];

% SysVary.CF2 = [1000 1000 1000 1000, 1000];
% SysVary.lw = [0, 1000];
SysVary.g = 0.5;
SysVary.HStrain = [50000 50000 50000];
% SysVary.CF2 = [0 0 2000000 0 0];
% SysVary.CF4 = [0 0 0 0 600000 0 0 0 0];
% SysVary.CF6 = [5000000 0 0 0 0 0 300000 0 0 0 0 0 0];

esfit(spc,@pepper,{Sys,Exp},{SysVary});