function derived = imageDerive(live_image, row, col, filter, varargin)
% This method compute a first order discrete derivate of the laser gaussian
% signal in the image row
%
% Parameters:
%   live_image - image to evaluate
%   (row, col) - center point for row derivate estimation
%   filter     - Filter to apply to compute derivative
%   varargin   - if present, allow to evaluate greater order derivate
%
% Returns:
%   Signal derivate along image's rows
%
  [~, cols] = size(live_image);
  half = floor(length(filter)/2);
    
  degree = 1;
  if 5 == nargin
    degree = cell2mat(varargin(1));
  end
  
  points = double(live_image(row, :));
  for i=1:degree-1
    points = conv(points, filter);
    points(1:half-1) = [];
    points(length(points)-half:length(points)) = [];
  end
  
  half = floor(length(filter)/2);
  inf = max(1, col - half);
  sup = min(cols, col + half);
  idxs = inf:1:sup;
  
  derived = conv(points(idxs), filter);
end