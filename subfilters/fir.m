function peaks = fir(image, laser, window)
% This function allows to apply the 'fir' subpixel filter to
% intput laser spots (zero of the first order derivate)
%
% Parameters:
% image  - Image to elaborate
% laser  - Laser coordinates in the image space
% window - Number of pixels to take into account for the evaluation
%
% Return:
% peaks  - Detected subpixels spots
%
  addpath('./math/');
  
  num_pts = length(laser);
  peaks = laser;
  
  for i=1:num_pts
    [n_pt, p_pt] = getLimits(image, laser(i,:), window);

    x0 = double(n_pt(1,1));    y0 = double(n_pt(1,2));
    x1 = double(p_pt(1,1));    y1 = double(p_pt(1,2));
    
    if y1 ~= y0
      peaks(i, 1) = x0 - y0 * (x1 - x0)/(y1 - y0);
    end
  end
end

function [negative_pt, positive_pt] = getLimits(image, spot, window)
% This method finds the last positive value and the first negative value of
% the first order discrete derivate of the gaussian laser spot
% (limits for 0 approximation)
%
% Parameters:
% image  - image to evaluate
% spot   - Centers of laser spot
% window - window size for pixel to taking into account
%
% Return:
% negative_pt - Last negative point in derivate
% positive_pt - First positive point in derivate
%
  half = floor(window/2);
  filter = [-ones(1, half) 0 ones(1, half)];
  derivate = imageDerive(image, spot(2), spot(1), filter);
  
  n = max(find(derivate < 0));
  p = min(find(derivate > 0));
  half = ceil(length(derivate)/2);

  negative_pt = [spot(1) + n - ceil(half), derivate(n)];
  positive_pt = [spot(1) + p - ceil(half), derivate(p)];
end