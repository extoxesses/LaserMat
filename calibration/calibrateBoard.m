function [constants, error] = calibrateBoard( ...
    image_path, angle, sensor_size, sqr_size, show ...
  )
% This function allows to calibrate using Tsai. The grid of points is
% obtained from a chekerboard.
%
% Parameters:
%   image_path  - Chekerboard image path
%   angle       - Image rotation angle
%   sensor_size - Number of pixel of the sensor of the camera
%   sqr_size    - Size in mm of the square in the chekerboard
%   show        - If true, the converted grid is shown, with error
%                 information
%
% Returns:
%   constants - Computed calibration constants
%   error     - Ist type calibration error*
%
  addpath('./calibration/tsai/');
  live_image = imrotate(imread(image_path), angle);

  [camera_pts, board_size] = detectCheckerboardPoints(live_image);
  
  world_pts = worldGrid(board_size, sqr_size);
  constants = Tsai( ...
      camera_pts, world_pts, ...
      size(live_image), [1710, 1710], sensor_size, ...
      1 ...
  );
  
  [error, world_pts_calc] = getErrors(camera_pts, world_pts, constants);
  
  plotResults(live_image, camera_pts, world_pts, world_pts_calc, error, show);
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