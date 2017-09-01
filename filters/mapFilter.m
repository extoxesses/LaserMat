function filtered_image = mapFilter(live_image, varargin)
% This filters remaps the image with respect of its minimun and maximum
% value.
%
% Parameters:
%   live_image - Image to be filtered
%   varargin   - Martrix 1x2 of the min and maximum values
%
% Returns:
%   filtered_image - Filtered image
%
  if nargin == 2
    min_value = varargin{1}(1);
    max_value = varargin{1}(2);
  else
    min_value = min(min(live_image));
    max_value = max(max(live_image));
  end
  step = (max_value - min_value) / 255;
  
  filtered_image = (live_image - min_value) * step;
end
