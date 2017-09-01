% This exaple shows how detect the laser in an image, and filter it.

clear;
close all;
clc;
addpath('./filters/', './subfilters/', './tools/');

threshold = 30;
image = imread('./examples/e2-laser/figure.bmp');
% image = rgb2gray(image);
image = thresholdFilter(image, threshold);

min_value = 200;
rotate = false;
show = true;
laser = findLaser(image, min_value, rotate, show);

window = 11;
filtered_laser = centerOfMass(image, laser, window);

figure;
plot(filtered_laser(:,1), filtered_laser(:,2), '.r');
