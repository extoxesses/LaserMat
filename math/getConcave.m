function [idx] = getConcave(init, fin, profile, gradient, varargin)
% This function allows to determine concave point along a profile.
%
% Parameters:
%   init - Index of the first point
%   fin  - Index of the last point
%   profile - Nx3 matrix of points
%   gradient - Profile gradient along the direction of interest
%   varargin - It contains:
%     min_window - lower bound for the window size in number of points;
%     max_window - upper bound for the window size in number of points;
%     window     - window size in number of points;
%
% Returns:
%   idx - The index of the concave point
%
  gradient = smooth(gradient, 11, 'lowess');

  min_window = 5;
  max_window = 5;
  window = 5;
  
  if nargin > 4
    min_window = cell2mat(varargin(1));
  end
  if nargin > 5
    max_window = cell2mat(varargin(2));
  end
  if nargin > 6
    window = cell2mat(varargin(3));
  end
  
  for i=init+min_window+1:fin-max_window-1
    if sum((gradient(i-min_window:i))) > 0 && ...
            sum((gradient(i:i+max_window))) < 0 && ...
            abs(sum(gradient(i:i+max_window))) > 0.1
      [~, rel_i] = max(profile(i-window:i+window, 2));
      idx = i - window + rel_i - 1;
      return;
    end
  end
  
  idx = 0;
end
