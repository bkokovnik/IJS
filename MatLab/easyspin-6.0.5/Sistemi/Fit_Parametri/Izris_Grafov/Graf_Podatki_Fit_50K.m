%==========================================================================
clear, clf, clc

[B_m,spc_m,Params] = eprload('C:\Users\Bor Kokovnik\Documents\IJS\eprPodatki\Yb2Be2GeO7_50K.DTA');


% Simulation options
Opt.Verbosity = 1;

% Experimental parameters
Exp.mwFreq = 9.659833;
Exp.Range = [0 1180];
Exp.nPoints = 4096;

Sys.S = 1/2;
Sys.g = 1.1429;
Sys.L = 3;
Sys.soc = -2900*clight*1e-4;
Exp.Temperature = 50;
Sys.CF2 = [0 0 2957960 0 0];
Sys.CF4 = [3838.72 0 0 0 57747.6 0 0 0 0];
Sys.CF6 = [0 0 -8701.53 0 0 0 736.57 0 0 0 0 0 0];
Sys.HStrain = [10413.70 3861.06 8987.05];


[B,spec0] = pepper(Sys,Exp,Opt);

plot(B_m, spc_m);
% plot(B,spec0);
axis tight;
title('1');