function peaks = centerOfMass(live_image, laser, window, varargin)
% This function allows to apply the 'center of mass' subpixel filter to
% intput laser spots
%
% Parameters
% live_image - Image to elaborate
% laser      - Laser coordinates in the image space
% window     - Numver of pixels to take into account for the evaluation
% varargin   - If present, it allows to set a threshold for a high band
%              filter. COM is very sensible to low band noise.
%
% Return:
% peaks  - Detected subpixels spots
%
  addpath('./filters/');
  
  noise_threshold = 0;
  if nargin > 3
    noise_threshold = cell2mat(varargin(1));
  end
  filtered = thresholdFilter(live_image, noise_threshold);

  if length(window) == 2
    low = window(1);
    high = window(2);
  else
    half = floor(window/2);
    low = -half;
    high = half;
  end
      
  peaks = compute(filtered, laser, low, high);
end

function peaks = compute(image, laser, low, high)
% This function allows to apply the 'center of mass' subpixel filter with
% a potential asymmetrical window with respect to each spot belonging
% to $laser
%
% Parameters:
% image       - Image to elaborate
% laser       - Laser coordinates in the image space
% [low, high] - Range with respect to the spot
%
% Return:
% peaks  - Detected subpixels spots
%
  [~, icols] = size(image);
  num_pts = length(laser);
  peaks = laser;
  
  for i = 1:num_pts    
    num = getNum(image, laser(i, 2), laser(i, 1), icols, low, high);
    den = getDen(image, laser(i, 2), laser(i, 1), icols, low, high);
    
    peaks(i,1) = double(laser(i,1)) + num/den;
  end
end


function numerator = getNum(image, row_idx, col_idx, num_cols, low, high)
   [low, high] = getBound(col_idx, num_cols, low, high);
   c = (low:1:high) - col_idx;
   numerator = sum(c .* double(image(row_idx, low:high)));
   numerator = double(numerator);
end

function denominator = getDen(image, row_idx, col_idx, num_cols, low, high)
   [low, high] = getBound(col_idx, num_cols, low, high);
   denominator = sum(image(row_idx, low:high));
end

function [low, high] = getBound(col_idx, num_cols, low, high)
   low = max(1, (col_idx-abs(low)));
   high = min((col_idx+high), num_cols);
end
