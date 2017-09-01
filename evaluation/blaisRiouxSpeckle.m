function min_error = blaisRiouxSpeckle(lambda, phi, d, dist)
% This function allows to evaluate the limitation in distance measurements
% (depht in laser triangulation systems) due to coherent lasers speckle
% noise using Blais&Rioux subpixel approximation.
%
% Parameters:
%   lambda = It the laser wavelength. It is related to laser color [in mm]
%   phi    = It is the triangulation angle [in degree]
%   d      = It is the lens diameter [in mm]
%   dist   = It is the distance from the lens to the target [in mm]
%
% Returns:
%   the minimum errors due to speckle noise
%
% REF: R. Baribeau and M. Rioux, "Influence of speckle on laser range
%      finders," Appl. Opt. 30, 2873-2878 (1991)
%

  min_error = (1 / sqrt(2*pi)) * (lambda / d) * (dist / sin(deg2rad(phi)));
end
