% nucfrq2d  HYSCORE powder spectrum outline 
%
%   nucfrq2d(Sys,B0)
%   nucfrq2d(Sys,B0,tau)
%
%   Computes powder HYSCORE peaks (without amplitudes)
%   from spin system Sys at external magnetic field magnitude B0
%   (in mT) and plots the result.
%
%   alpha-beta correlations are in blue, beta-alpha correlations are in red.
%
%   Only S=1/2 systems are supported.
%
%   tau (in µs) specifies a vector of tau values.
%
%   If tau is given, a colored background indicating peak
%   suppression regions (blind spots) is shown. White indicates
%   no suppression, the darker the gray the stronger the suppression.
%
%   Example:
%
%      Sys = struct('Nucs','1H','g',[2 2 2]);
%      Sys.A = 3 + [-1 -1 2]*5;
%      nucfrq2d(Sys,350,0.120);   % field 350 mT, tau 120 ns
