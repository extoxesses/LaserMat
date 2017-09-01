function [Xu, Yu] = undistort(image_pts, cc)
% This function allows to convert a set of points in the image coordinates
% reference system, to undistorted sensor plane coordinates
%
% Parameters:
%   image_pts - Matrix Nx2 of points in the image reference system
%   cc        - Intrinsic and extrinsic calibration values
%
% Returns:
%   [Xu, Yu] - Vectors Nx1 of points in the undistorted sensor plane
%              reference system
%
  % Conversion from image to sensor coordinates
  Xd = cc.dpx * (image_pts(:,1) - cc.Cx) ./ cc.scale_factor;
  Yd = cc.dpy * (image_pts(:,2) - cc.Cy);
  
  % Conversion from distorted sensor to undistorted sensor plane coordinates
  r = sqrt(Xd.^2 + Yd.^2);
  rad_dist_factor = 1 + cc.kappa1.*(r.^2);
  if isfield(cc, 'kappa2')
    rad_dist_factor = rad_dist_factor + cc.kappa2.*(r.^4);
  end
  
  % Full formula, considering first order tangential distortion
%   Xu = Xd .* rad_dist_factor + (p1*(r.^2 - Xd) + 2*p2*Xd.*Yd);
%   Yu = Yd .* rad_dist_factor + (p2*(r.^2 - Yd) + 2*p1*Xd.*Yd);
  
  Xu = Xd .* rad_dist_factor;
  Yu = Yd .* rad_dist_factor;
end
