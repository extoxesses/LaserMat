%%%
% @author Alex Badan
% @date 13/07/2017
% @package script
%
% This is a simple script that show how to use the proposed model for error
% propagation analysis.
% It allows to aggregate all the usefull sub-pixel approximations analyzed,
% and shows all errors compared with the discrete pixel approximation.
%%%

close all;
clear; 
clc;
addpath('./evaluation/');

run('./examples/e3-model/setup.m');
load('./examples/e3-model/constants.mat');

pix_error = 1 / sqrt(12)
subpix_err = comError(1, 11, laser_amplitude, saturation, SNR)

[y_error, x_error] = pixelError( ...
        pixel, baseline, triangulation_angle, ...
        constants, image_size, pixel_size, ...
        laser, scflug, ...
        subpix_err, pix_error ...
    )
pts_error = sqrt(y_error^2+x_error^2)

clear baseline constants grid image_size laser laser_amplitude model_file_name
clear pixel pixel_size saturation scflug SNR triangulation_angle error