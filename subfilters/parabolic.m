function peaks = parabolic(live_image, laser, window)
% This function allows to apply the 'parabolic' subpixel filter to
% intput laser spots
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
  peaks = laser;
  
  half = floor(window/2);
  num_filter = [-ones(1, half) 0 ones(1, half)];
  den_filter = 2*[ones(1, half) -2 ones(1, half)];
  
  num_pts = length(laser);
  for i=1:num_pts
    d = imageDerive(live_image, laser(i,2), laser(i,1), num_filter);
    num = d(ceil(length(d)/2));
    d = imageDerive(live_image, laser(i,2), laser(i,1), den_filter, 2);
    den = d(ceil(length(d)/2));
    
    peaks(i, 1) = laser(i, 1) + num/den;
  end
end
