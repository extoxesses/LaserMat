function [constants, error] = calibrateGage( ...
    camera_pts, world_pts, ...
    image_size, sensor_size, pixel_size, show ...
  )
% This function allows to calibrate using Tsai. The grid of points is
% obtained from a known gage, using createGrid function.
%
% Parameters:
%   camera_pts  - Grid of points, in the image reference system (pix)
%   world_pts   - Grid of points, in the world reference system (mm)
%   image_size  - Number of pixel acquired by the frame grabber (cuold be
%                 different from the sensor size)
%   sensor_size - Number of pixel of the sensor of the camera
%   pixel_size  - Size of the pixel (mm)
%   show        - If true, the converted grid is shown, with error
%                 information
%
% Returns:
%   constants - Computed calibration constants
%   error     - Ist type calibration error*
%
% * REF:	"A versatile camera calibration technique for high-accuracy 3D
%          machine vision metrology using off-the-shelf TV cameras and lens" 
%    	     R.Y. Tsai, IEEE Trans R&A RA-3, No.4, Aug 1987, pp 323-344.
%
  addpath('./calibration/tsai/');
  constants = Tsai( ...
      camera_pts, world_pts, ...
      image_size, sensor_size, pixel_size, 1 ...
  );

  [error, world_pts_calc] = getErrors(camera_pts, world_pts, constants);
  plotResults(zeros(image_size), camera_pts, world_pts, world_pts_calc, error, show);
end

function plotResults(live_image, camera_pts, world_pts, world_pts_calc, error, show)
  fig = figure;
  if 0 == show
    set(fig, 'visible', 'off');
  end
  
  subplot(1, 2, 1);
  hold on;
    imshow(live_image);
    scatter(camera_pts(:,1), camera_pts(:,2));
    line(camera_pts(:,1), camera_pts(:,2));
  hold off;
  
  subplot(1, 2, 2);
  hold on;
    scatter(world_pts(:,1), world_pts(:,2), '+');
    scatter(world_pts_calc(:,1), world_pts_calc(:,2), '+');
  hold off;
  
  dim = [0 0 1 1];
  str = {strcat('Mean= ', num2str(error(1))), strcat('Std= ', num2str(error(2)))};
  annotation('textbox', dim, 'String',char(str),'FitBoxToText','on');
end