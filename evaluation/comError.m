function error = comError(dim_px, window, sigma, varargin)
% This function allows to compute the accuracy reached using center of
% mass as subpixel method for laser extraction
%
% Parameters:
%   dim_px   - Pixel dimension (assume that pixels are squared. It they
%              aren't, use pixels dimension along laser detection);
%   window   - C.O.M. window size
%   sigma    - Laser amplitude
%   varargin - If present, it allows to simulate signal saturation
%
% Returns:
%   error - Error made using Blais&Rioux subpixel filter.
%
  addpath('./signals');
  
  saturated_pix = 0;
  if nargin > 3
     saturated_pix = cell2mat(varargin(1));
  end
  snr = nan;
  if nargin > 4
     snr = cell2mat(varargin(2));
  end
  
  com = filter(window, sigma, saturated_pix, snr);
  error = abs(0.5 - com) * dim_px;
 end

function com = filter(window, sigma, saturated_pix, snr)
  half = floor(window/2);
  points = (-half:1:half);
  normal = approxNormalDistribution(points, 0.5, sigma, snr);
  
  if saturated_pix > 1
    half = floor(saturated_pix/2);
    sat_points = (-half:1:half);
    idx = strfind(points, sat_points);
    normal(idx:idx+length(sat_points)-1) = ones(1, length(sat_points));
  end
  
  num = sum(points.*normal);
  den = sum(normal);
  
  com = num / den;
end
