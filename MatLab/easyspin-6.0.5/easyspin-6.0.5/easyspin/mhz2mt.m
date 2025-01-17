% mhz2mt   Conversion from MHz to mT
%
%   value_mT = mhz2mt(value_MHz)
%   value_mT = mhz2mt(value_MHz,g)
%
%   Converts the value in value_MHz, assumed to be in units
%   of MHz (megahertz) to mT (millitesla), returning
%   the result in value_mT.
%
%   For the conversion, the g factor given as second
%   parameter is used. If it is not given, the g factor
%   of the free electron (gfree) is used.
%
%   value_MHz can be a vector of values. In this case, g
%   can be a scalar or a vector of the same size as value_MHz.
