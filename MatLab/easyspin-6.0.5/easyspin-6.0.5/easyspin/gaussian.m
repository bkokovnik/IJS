% gaussian  Gaussian line shape
%
%   ya = gaussian(x,x0,fwhm)
%   ya = gaussian(x,x0,fwhm,diff)
%   ya = gaussian(x,x0,fwhm,diff,phase)
%   [ya,yd] = gaussian(...)
%
%   Computes area-normalized Gaussian absorption and dispersion
%   line shapes or their derivatives.
%
%   Input:
%   - x:     abscissa vector (any units)
%   - x0:    center of the lineshape function (same units as x)
%   - fwhm:  full width at half height (same units as x)
%   - diff:  derivative. 0 is no derivative, 1 first,
%            2 second and so on, -1 the integral with -infinity
%            as lower limit. 0 is the default.
%   - phase: phase rotation (radians), mixes absorption and dispersion.
%            phase=pi/2 puts dispersion signal into ya
%
%   Output:
%   - ya:   absorption function values for abscissa x
%   - yd:   dispersion function values for abscissa x
