function [world, subpixel] = subpixelFilter(live_image, laser, filter, costants, varargin)
% This method was thougth to simplify the use of subpixel filters, with a
% simple general method. It takes in input the image and the laser
% coordinates, and apply the correct filters.
%
% Parameters:
%   live_image - Image to filter
%   laser      - Laser coordinate in the image reference system, obtained
%                using findLaser method
%   filter     - Filter to use. The possibilities are:
%                "centerofmass", "blaisrioux", "fir", "gaussian", "linear" and "parabolic"
%   costants   - Intrinsic and extrinsic calibration values
%   varargin   - In the order, they are:
%       window - Size of the window (in pix) used by the filter
%       rotate - If the laser is horizontal, the image will be rotated of
%                90 degrees
%       show   - If true, results are plotted
%       save   - If true, results are saved
%
% Returns:
%   world - Filtered laser coordinates in the world reference system
%   subpixel - Filtered laser coordinates in the image reference system
%
  window = 0;
  if nargin > 4
    window = cell2mat(varargin(1));
  end
  
  rotate = false;
  if nargin > 5
    rotate = cell2mat(varargin(2));
  end
  
  show = false;
  if nargin > 6
    show = cell2mat(varargin(3));
  end
  
  save = false;
  if nargin > 7
    save = cell2mat(varargin(4));
  end

  subpixel = getSubpixeling(live_image, laser, filter, window, rotate);
  
  world = image2WorldConversion(subpixel, costants);
  notnan_idx = ~isnan(world);
  world = world(notnan_idx(:,1) & notnan_idx(:,2), :);

  if show
    figure;
    imshow(live_image);
    hold on;
    plot(subpixel(:,1), subpixel(:,2), '.r');
  end
  
  if save
    writedxf(strcat(filter, int2str(window)), world(:,1), world(:,2), world(:,3));
    save(strcat(filter, int2str(window)), 'subpixel');
  end
end

function subpixel = getSubpixeling(image, laser, filter, window, rotate)
  if rotate
    [~, col] = size(image);
    image = imrotate(image, 90);
    laser = rot270Laser(laser, col);
  end

  if strcmp(filter, "centerofmass")
    subpixel = centerOfMass(image, laser, window);
  elseif strcmp(filter, "blaisrioux")
    subpixel = blaisRioux(image, laser, window);
  elseif strcmp(filter, "fir")
    subpixel = fir(image, laser, window);
  elseif strcmp(filter, "gaussian")
    subpixel = gaussian(image, laser);
  elseif strcmp(filter, "linear")
    subpixel = linear(image, laser);
  elseif strcmp(filter, "parabolic")
    subpixel = parabolic(image, laser, window);
  else
    error(char(strcat("Invalid call to '", filter, "'. Filter not found!")));
  end
  
  if rotate
    subpixel = rot90Laser(subpixel, col);
  end 
end

function laser = rot90Laser(laser, col)
  tmp = laser;
  laser(:,1) = col - laser(:,2);
  laser(:,2) = tmp(:,1);
end

function out = rot270Laser(laser, row)
  out(:,1) = laser(:,2);
  out(:,2) = row - laser(:,1);
end
