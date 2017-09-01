function filtered_img = thresholdFilter(live_image, threshold)
% This filters move to 0 all the pixel with a value less the threshold
%
% Parameters:
%   live_image - Image to be filtered
%   threshold  - Cut threshold
%
% Returns:
%   filtered_image - Filtered image
%
  filtered_img = live_image;
  filtered_img(live_image < threshold) = 0;
end
