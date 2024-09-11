%==========================================================================
clear, clf, clc


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
Exp.Temperature = 10;
Sys.CF2 = [0 0 2.95077e+06 0 0];
Sys.CF4 = [4965.13 0 0 0 52747.6 0 0 0 0];
Sys.CF6 = [0 0 -8271.72 0 0 0 635.173 0 0 0 0 0 0];
Sys.HStrain = [9339.56, 6955.05, 8701.18];


[B,spec0] = pepper(Sys,Exp,Opt);


plot(B,spec0);
axis tight;
title('1');