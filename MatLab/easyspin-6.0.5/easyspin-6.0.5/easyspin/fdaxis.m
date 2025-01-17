% fdaxis  Frequency domain axis 
%
%   xf = fdaxis(dT,N)
%   xf = fdaxis(xt)
%
%   Returns a vector xf containing the frequency-domain axis of the FFT of
%   a N-point time-domain vector xt sampled with period dT. Specify either
%   xt, or dT and N.
%
%   xf has the DC component (zero frequency) in the center. Units:
%   [xf] = 1/[dT]. Time yields frequency, NOT angular frequency.
