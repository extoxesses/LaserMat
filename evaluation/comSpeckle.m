function min_error = comSpeckle(lambda, na)
% This function allows to evaluate the limitation in distance measurements
% (depht in laser triangulation systems) due to coherent lasers speckle
% noise using Center of Mass subpixel approximation.
%
% Parameters:
%   lambda = It the laser wavelength. It is related to laser color [in mm]
%   na     = Lens Numerical Aperture. It characterizes the range of light
%            rays angle that the lens can caputer
% Returns:
%   the minimum errors due to speckle noise
%
% REF: R. Dorsch, G. Häusler, and J. Herrmann, "Laser triangulation:
%      fundamental uncertainty in distance measurement," Appl. Opt. 33,
%      1306-1314 (1994).
%
  min_error = (1 / 2*pi) * (lambda / na);
end
