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
Exp.Temperature = 30;
% Sys.CF2 = [2000 -200 1800 -1700 700];
% Sys.CF2 = [0 0 4658774.79732 0 0];
% Sys.CF4 = [0 0 0 0 -1729802.48266 0 0 0 0];
% Sys.CF6 = [14177185.33882 0 0 0 0 0 -767468.69248 0 0 0 0 0 0];
Sys.HStrain = [5283.23 5440.8 5437.88];

Sys.CF2 = [0 20000 0 0 0];
[B,spec0] = pepper(Sys,Exp,Opt);

Sys.CF2 = [0 2000 0 0 0];
[B,spec1] = pepper(Sys,Exp,Opt);

Sys.CF2 = [0 200 0 0 0];
[B,spec2] = pepper(Sys,Exp,Opt);

Sys.CF2 = [0 20 0 0 0];
[B,spec3] = pepper(Sys,Exp,Opt);

Sys.CF2 = [0 0 0 0 0];
[B,spec4] = pepper(Sys,Exp,Opt);

Sys.CF2 = [0 10000 0 -10000 0];
[B,spec5] = pepper(Sys,Exp,Opt);

Sys.CF2 = [0 1000 0 -1000 0];
[B,spec6] = pepper(Sys,Exp,Opt);

Sys.CF2 = [0 100 0 -100 0];
[B,spec7] = pepper(Sys,Exp,Opt);

Sys.CF2 = [0 10 0 -10 0];
[B,spec8] = pepper(Sys,Exp,Opt);

Sys.CF2 = [0 0 0 0 0];
[B,spec9] = pepper(Sys,Exp,Opt);









% plot(B,spec0);
% axis tight;
% xlabel('magnetic field (mT)');

subplot(5,2,1);
plot(B,spec0);
axis tight;
title('1');
subplot(5,2,3);
plot(B,spec1);
axis tight;
title('2');
subplot(5,2,5);
plot(B,spec2);
axis tight;
title('3');
xlabel('magnetic field (mT)');
subplot(5,2,7);
plot(B,spec3);
axis tight;
title('4');
xlabel('magnetic field (mT)');
subplot(5,2,9);
plot(B,spec4);
axis tight;
title('5');
xlabel('magnetic field (mT)');


subplot(5,2,2);
plot(B,spec5);
axis tight;
title('6');
subplot(5,2,4);
plot(B,spec6);
axis tight;
title('7');
subplot(5,2,6);
plot(B,spec7);
axis tight;
title('8');
xlabel('magnetic field (mT)');
subplot(5,2,8);
plot(B,spec8);
axis tight;
title('9');
xlabel('magnetic field (mT)');
subplot(5,2,10);
plot(B,spec9);
axis tight;
title('10');
xlabel('magnetic field (mT)');