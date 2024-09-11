clear

Sys.S = 1/2;
Sys.g = [1.5, 4.2, 0.5];
Sys.L = 3;
Sys.soc = -2900*clight*1e-4;
Sys.lw = [0 10];
Sys.Nucs = 'Yb';

Exp.Range = [0 1200];  % mT
Exp.mwFreq = 9.659833;  % GHz
Exp.Temperature = 30;

[B,spec0] = pepper(Sys,Exp);
plot(B,spec0);