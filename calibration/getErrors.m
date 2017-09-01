function [error, world_pts_calc] = getErrors( ...
    camera_pts, world_pts, calibration_constant ...
  )
% This function computes the Ist type error for calibration results.
%
% Parameters:
%   camera_pts           - Grid of points, in the image reference system (pix)
%   world_pts            - Grid of points, in the world reference system (mm)
%   calibration_constant - Calibration constants computed using Tsai
%
% Returns:
%   error          - Calibration error
%   world_pts_calc - Computed world projection from camera_pts, using the
%                    passed calibration_constants
%
  addpath('./coordinates/');
  world_pts_calc = image2WorldConversion(camera_pts, calibration_constant);
  
  pt_dists = (world_pts - world_pts_calc).^2;
  dists = zeros(length(pt_dists), 1);
  for k=1:length(pt_dists)
    dists(k) = sqrt(pt_dists(k,1) + pt_dists(k,2) + pt_dists(k,3));
  end
  
  error = zeros(1,2);
  error(1) = mean(dists);
  error(2) = std(dists); 
end
