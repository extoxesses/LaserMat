%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script shows how to perform a correct calibration using coplanar
% Tsai algorithm.
% First of all, the script creates the grid of point from a set of images
% of a known target, and then it calibrates. Finally, all the data are
% saved in a .mat file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear;
warning ('off','all'); 
clc;
addpath('./calibration/');

% Variables definition
% --------------------
  gage_paths
  n = length(paths);         % Number of used frames
  
  
  threshold = 0.5*n;

  image_size = [1000 1000];  % [pix x pix]
  sensor_size = [1000 1000]; % [pix x pix]
  pixel_size = [0.5 0.5];    % [mm x mm]

% Script
% --------------------
grid = createGrid(paths, threshold);
clear n paths threshold

[constants, error] = calibrateGage( ...
    grid(:,4:5), grid(:,1:3), ...
    image_size, sensor_size, pixel_size, ...
    true ...
);
save('calibration.mat', 'grid', 'constants', 'error');
