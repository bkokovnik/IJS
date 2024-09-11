% Yb2Be2GeO7
%=================================================
clear
Sys.S = 1/2;
Sys.g = 1.1429;
Sys.L = 3;
Sys.soc = -2900*clight*1e-4;
Ori = 'x';
FieldRange = [0 1300];  % mT
mwFreq = 9.659833;  % GHz
Sys.CF2 = [0 0 2.0423e+06 0 0];
Sys.CF4 = [12425 0 0 0 57819 0 0 0 0];
Sys.CF6 = [0 0 4200.06 0 0 0 513 0 0 0 0 0 0];
% Sys.CF2 = [983.289 -178.412 1534.02 -555.26 480.16];
Opt.SlopeColor = true;
levelsplot(Sys,Ori,FieldRange,mwFreq,Opt);
% ylim([-1.9e5 -1.102e5])