% Yb2Be2GeO7
%=================================================
% clear
% Sys.S = 1/2;
% Sys.L = 3;
% Sys.soc = -2900*clight*1e-4;
% Sys.g = [2 2 2];
% Ori = 'z';
% FieldRange = [0 1100];
% mwFreq = 9.659833;
% 
% levelsplot(Sys,Ori,FieldRange,mwFreq);

clear
Sys.S = 1/2;
Sys.g = [-0.9053 0.9110 6.6537];
Sys.L = 3;
Sys.soc = -2900*clight*1e-4;
Ori = 'y';
FieldRange = [0 1300];  % mT
mwFreq = 9.659833;  % GHz
Sys.CF2 = [0 0 19500000 0 0];
% Sys.CF2 = [983.289 -178.412 1534.02 -555.26 480.16];
Opt.SlopeColor = true;
levelsplot(Sys,Ori,FieldRange,mwFreq,Opt);
% ylim([-2.1385e5 -2.137e5])