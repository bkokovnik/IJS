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
% Sys.g = [-0.9053, 0.911, 6.6537]  % Najboljši fit do sedaj
% Sys.g = [-0.9053 0.9110 6.6537];  % Vrednosti iz članka
% Sys.D = [3000 750];     % MHz
% Sys.lw = [0 300];             % mT
% Sys.Nucs = 'Yb';
% Sys.A = [2 3 5]*360;  % MHz
Sys.L = 3;
Sys.soc = -2900*clight*1e-4;
Exp.Temperature = 30;
Sys.CF2 = [2000 -200 1800 -1700 700];
% Sys.CF2 = [0 0 4658774.79732 0 0];          % CF(2,q) with q = +2,+1,0,-1,-2
% Sys.CF4 = [0 0 0 0 -1729802.48266 0 0 0 0];
% Sys.CF6 = [14177185.33882 0 0 0 0 0 -767468.69248 0 0 0 0 0 0];
Sys.HStrain = [5283.23 16440.8 5437.88];
% Sys.HStrain = [4270.63 11005 10082.4];  % Najboljši fit do sedaj
% Exp.CrystalSymmetry = 113;
% Sys.g = 1.1429;
% Sys.CF2 = [1.48086e+08 0 1.01681e+08 0 0];          % CF(2,q) with q = +2,+1,0,-1,-2
% Sys.CF4 = [0 0 0 0 9.46368e+06 0 0 0 0];
% Sys.HStrain = [9704.18 9416.19 9501.77];

[B,spec0] = pepper(Sys,Exp,Opt);

plot(B,spec0);
axis tight;
xlabel('magnetic field (mT)');