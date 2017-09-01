function error = parabolicError(dim_px, window, sigma, varargin)
% This function allows to compute the accuracy reached using gaussian
% first order derivate subpixel method for laser extraction
%
% Parameters:
%   dim_px   - Pixel dimension (assume that pixels are squared. It they
%              aren't, use pixels dimension along laser detection);
%   window   - Derivative window size
%   sigma    - Laser amplitude
%   varargin - If present, it allows to simulate signal saturation
%
% Returns:
%   error - Error made using Blais&Rioux subpixel filter.
%
  addpath('./signals', './math/');
  
  saturated_pix = 0;
  if nargin > 3
     saturated_pix = cell2mat(varargin(1));
  end
  snr = nan;
  if nargin > 4
     snr = cell2mat(varargin(2));
  end
  
  error = getError(window, saturated_pix, sigma, snr);
  error = abs(0.5 - error) * dim_px;
end

function peakspar = getError(window, saturated_pix, sigma, snr)
  points = -window:1:window;
  normal = approxNormalDistribution(points, 0.5, sigma, snr);
  
  if saturated_pix > 1
    half = floor(saturated_pix/2);
    offset = strcmp(points, half);
    sat_points = (-half:1:half) + offset;
    idx = strfind(points, sat_points);
    normal(idx:idx+length(sat_points)-1) = ones(1, length(sat_points));
  end
  
  num = imageDerive(normal, 1, floor(window/2), floor(window/2));
  den = imageDerive(normal, 1, floor(window/2), floor(window/2), 2);
  peakspar = - num/den;
end
