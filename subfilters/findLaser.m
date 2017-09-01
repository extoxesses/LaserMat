function [laser, max_saturation] = findLaser(live_image, threshold, rotate, show)
  image = live_image;
  if rotate
    [~, col] = size(live_image);
    image = imrotate(live_image, 90);
  end
  
  [laser, max_saturation] = extract(image, threshold);
 
  if rotate
    tmp = laser;
    laser(:,1) = col - laser(:,2);
    laser(:,2) = tmp(:,1);
  end
  
  if show
    plotGraph(live_image, laser);
  end
end

function [laser, max_saturation] = extract(live_image, threshold)
% This function returns the x and y coordinates of the laser spots in the 
% image
%
% param live_image - Image to analyze
% param threshold  - Light intensity threshold that must be lower or equal 
%                    to spot intensity
% return [x, y]    - spots coordinates in the image space
% return max_saturation - max number of pixels involved in saturation 
%                         effect
%
  [rows, ~] = size(live_image);
  x = -ones(rows, 1);
  y = -ones(rows, 1);
  max_saturation = zeros(rows, 1);
  
  for r = 1:rows
    max_th = threshold;
    [max_th, max_col, max_count] = analyzeRow(live_image(r,:), max_th);
    if max_th  == -1
      continue;
    end
    max_saturation(r) = max_count;
    
    x(r) = max_col + floor((max_count-1)/2);
    y(r) = r;
  end
  
  laser = [x y];
  laser(-1 == x, :) = [];
  max_saturation = max(max_saturation);
end

function [m, idx, seq_length] = analyzeRow(row, threshold)
% This function search the maximum spot in the image, filling hole of 2 or
% 3 pixels
%
% param row         - Image row to analyze
% param threshold   - Light intensity threshold that must be lower or equal to spot intensity
% return m          - max spot value. If no spot is fount, m == -1
% return idx        - index of first maximum spot
% return seq_length - length of max sequence
%
  m = max(row);
  if m < threshold
    m = -1;
    idx = nan;
    seq_length = 0;
    return;
  end
  
  idxs = find(row == m);
  if length(idxs) == 1
    idx = idxs;
    seq_length = 1;
  else
    peaks = find(diff(idxs)<=3);
    if isempty(peaks)
        idx = idxs(1);
        seq_length = 1;
    else
        seq = [peaks peaks(length(peaks)) + 1];
        idx = idxs(seq(1));
        seq_length = length(seq);
    end
  end
end

function plotGraph(live_image, laser)
  figure;
  imshow(live_image);
  hold on;
  scatter(laser(:,1), laser(:,2), '.r');
  hold off;
end
