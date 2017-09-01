function error = firError(dim_px, window, sigma, varargin)
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
  addpath('./signals');
  
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

function error = getError(window, saturated_pix, sigma, snr)
% This function allows to estimate the peack of a simulated gaussian laser
% spot included inside a pixel
%
% window        - window size for pixel to taking into account
% saturated_pix - number of saturated pixels
% sigma         - laser width [pix]
% 
  error = -1;
  [n_pt, p_pt] = getLimits(window, saturated_pix, sigma, snr);

  x0 = n_pt(1,1);  y0 = n_pt(1,2);
  x1 = p_pt(1,1);  y1 = p_pt(1,2);

  if y1 ~= y0
    error = x0 - y0 * (x1 - x0)/(y1 - y0);
    error = abs(error-floor(error));
  end
end

function [negative_pt, positive_pt] = getLimits(window, saturated_pix, sigma, snr)
% This method finds the last positive value and the first negative value of
% the first order discrete derivate of the gaussian laser spot
% (limits for 0 approximation)
%
% window        - window size for pixel to taking into account
% saturated_pix - number of saturated pixels
% sigma         - laser width [pix]
% 
  positive_pt = zeros(1,2);
  negative_pt = zeros(1,2);

  points = -window:1:window;
  normal = approxNormalDistribution(points, 0.5, sigma, snr);
  
  if saturated_pix > 1
    half = floor(saturated_pix/2);
    sat_points = (-half:1:half);
    idx = strfind(points, sat_points);
    normal(idx:idx+length(sat_points)-1) = ones(1, length(sat_points));
  end
 
  ll_derived = derive(normal, window/2, window/2);
  l_derived = derive(normal, (window/2)+1, window/2);
  for c = (window/2)+2:length(normal)-(window/2)
    derived = derive(normal, c, window/2);
    
    if l_derived > 0 && derived < 0
      negative_pt = [c-1 l_derived];
      positive_pt = [c derived];
      return;

     elseif ll_derived > 0 && 0 == l_derived && derived < 0
       negative_pt = [c-2 ll_derived];
       positive_pt = [c derived];
       return;
    end
    
    ll_derived = l_derived;
    l_derived = derived;
  end
end

function derived = derive(func, idx, window)
% This method compute a first order discrete derivate of the gaussian
% signal
%
% func   - laser spot signal
% window - window size for pixel to taking into account
% idx    - center for derivate estimation
%
  derived = 0;
  for i=-window:window-1
     derived = derived + sign(i)*func(idx+i+1);
  end
  
  % Test without considering moving window
  %derived = func(idx+2) + func(idx+1) - func(idx-1) - func(idx-2);
end
