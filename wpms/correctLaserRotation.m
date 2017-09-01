function [laser, z_rot] = correctLaserRotation(laser, range, flip)
% This function allows to apply the radial correction to the wheel.
%
% Parameters:
%   laser - Nx3 matrix of point belonging to the profile of the wheel
%   range - 1x2 vector of initial and final index of the section we are
%           interested in
%   flip  - Flag. If true the data are flipped inside the laser matrix.
%
% Returns:
%   laser - Corrected profile
%   z_rot - Estimated correction angle
%
  if flip
    laser(:,1) = flipud(laser(:,1));
    laser(:,2) = flipud(laser(:,2));
  end
  
  % Find rotation and fix it
  line_coef = polyfit(laser(range,1), laser(range,2), 1);
  z_rot = atan(line_coef(1));
  z_rot = rad2deg(sign(z_rot)*pi/2 - z_rot);

  % Center profile at the origin
  origin = laser(1,:);
  laser = laser - origin;
  
  laser = rotate(laser, 0, 0, z_rot);
  laser = laser + origin;
end
