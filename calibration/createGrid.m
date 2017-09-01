function [grid] = createGrid(paths, h_group_threshold, varargin)
% This function allows to create a grid of points, starting from a seriers
% of gage images. This grid is needed to calibrate the system using Tsai
% algorithm, present in /calibration/tsai/Tsai.m
%
% Parameters:
% paths              - Array of gage images paths
% h_group_treshold   - Treshold used to filter out points while horizontal
%                      coefficients are evaluated. Good value could be
%                      0.25*length(paths)
% varargin:
%    medfilter_core  - Core for median filter (to reduce salt/pepper
%                      noise). Default is [1 1]
%    noise_threshold - Threshold to remove black-noise in the image.
%                      Default is [0]
%
% Return:
% grid - Generated grid
%
  addpath('./fex/', './filters/', './math/', './subfilters/');
  
  medfilter_core = [1 1];
  if nargin == 3
    medfilter_core = cell2mat(varargin(1));
  end
  
  noise_threshold = 0;
  if nargin == 4
    noise_threshold  = cell2mat(varargin(1));
  end
  
  [raw_corners, raw_indexes, v_coeffs] = ...
    getVerticalCoefficients(paths, medfilter_core, noise_threshold);
  
  % Compute coefficents of horizontal parabolas
  h_coeffs = getHorizontalCoefficients(raw_corners, raw_indexes, h_group_threshold);

  % Compute grids from found points
  [pts_camera, pts_world] = add2Grid(v_coeffs, h_coeffs);

  grid = [pts_world pts_camera];
  grid(grid(:,4) < 0 | grid(:,5) < 0, :) = [];
  
  coefficients.vertical = v_coeffs;
  coefficients.horizontal = h_coeffs;
  
  save('cam2worldGrid.mat', 'coefficients', 'grid', 'raw_corners', 'raw_indexes');
  plotGraphs(raw_corners, grid, v_coeffs, h_coeffs)
end

function [corners, indexes, coeffs] = ...
    getVerticalCoefficients(paths, medfilter_core, noise_threshold)
% This function allows to compute vertical coefficients and gage hole
% corners.
%
% Parameters:
% paths           - Array of gage images paths
% medfilter_core  - Core for median filter (to reduce salt/pepper noise)
% noise_threshold - Threshold to remove black-noise in the image
%
% Return:
% corners - Grid raw corners
% indexes - Horizontal groups ids
% coeffs  - Vertical parabolas coefficients
%
  len = length(paths);
  coeffs = zeros(len, 3);
  corners = [];
  indexes = [];
  
  for i=1:len
    % disp(strcat('Computing image: ', paths(i)));
    disp(strcat('Computing image: ', num2str(i)));
    image = imread(char(paths(i)));
    image = medfilt2(image, medfilter_core);
    image = thresholdFilter(image, noise_threshold);
    
    % Find maximum laser spots to fit the parabola along each column
    laser = findLaser(image, 20, false, false);
    outliers_idx = isoutlier(laser(:,1));
    laser(outliers_idx, :) = [];

    laser_coeffs = lowbandFilter(image, laser, 254);
    laser_coeffs = centerOfMass(image, laser_coeffs, 16, 100);
    coeffs(i,:) = polyfit(laser_coeffs(:,1), laser_coeffs(:,2), 2);
    % coeffs(i,:) = [0 polyfit(laser_coeffs(:,1), laser_coeffs(:,2), 1)];
    
    % Research lasers spots to find 'L' along the gage
    blocks = findBlocks(laser(:,1), laser(:,2));
    local_corners = findCorners(laser, coeffs(i,:), blocks);
    
    % Group the horizontaly to interpolate horizontal parabolas
    [corners, indexes] = groupHorizontaly(corners, indexes, local_corners);
  end
end

function [h_coeffs] = ...
    getHorizontalCoefficients(corners, indexes, min_treshold)
% This function allows to compute vertical coefficients and gage hole
% corners.
%
% Parameters:
% corners      - Grid raw corners
% indexes      - Horizontal groups ids
% min_treshold - Minimum number of points needed for interpolate images
%
% Return:
% h_coeffs - Horizontal parabolas corners
%
  h_coeffs = zeros(max(indexes), 3);
  for i=1:max(indexes)
    idx = find(indexes == i);
    if length(idx) > min_treshold
      h_coeffs(i,:) = polyfit(corners(idx,1), corners(idx,2), 2);
      % h_coeffs(i,:) = [0 polyfit(corners(idx,1), corners(idx,2), 1)];
    end
  end
  h_coeffs( ~any(h_coeffs, 2), : ) = [];
end

function [laser] = lowbandFilter(image, laser, light_treshold)
% This function allows to remove laser spots with light intensity lower
% than given threshold
%
% Parameters:
% image           - Image to compute
% laser           - Laser spots in image space
% light_threshold - Pixel intensity threshold
%
% Return:
% laser - Filtered laser spots
%
  image = mapFilter(image);
  for i=1:length(laser)
    if image(laser(i,2), laser(i,1)) < light_treshold
      laser(i,1) = -1;
    end
  end

  laser(laser(:,1) == -1,:) = [];
  
  dx = find(diff(laser(:,1)) < 0);
  laser(dx+1,:) = [];
  dx = find(diff(laser(:,1)) < 0);
  laser(dx+1,:) = [];
end

function clusters = findBlocks(x, y)
% This function allows to determine each gage hole
%
% Parameters:
% (x, y) - Laser spots
%
% Return:
% clutesters - Begin index of each gage hole
%
   expected_clusters = 10;
   clusters = zeros(expected_clusters, 1);
   clusters(1) = 1;
   count = 2;
   
   for i=count:length(x)
     if pointDistance([x(i-1) y(i-1) 0], [x(i) y(i) 0]) > 15
       clusters(count) = i;
       count = count+1;
     end
   end
   
   if clusters(count-1) ~= length(x)
     clusters(count) = length(x);
   end
end

function corners = findCorners(laser, v_coeffs, clusters)
% This function allows to determine each gage hole angle
%
% Parameters:
% laser    - Laser spots
% v_coeffs - Gage with line coefficients
% cluster  - Clusters beginning indexes
%
% Return:
% clutesters - Begin index of each gage hole
%
  corners = zeros(length(clusters)-1, 2);
  u = sym('u');
  fv = symfun(v_coeffs(1)*u^2 + v_coeffs(2)*u + v_coeffs(3), u);
  
  for i=1:length(clusters)-1
    % First and Last cluster indices
    f = clusters(i);
    l = clusters(i+1)-1;
    
    if l-f < 10
      % If there are less than 10 points discard the cluster
      continue;
    end
    
    % Extract cluster
    xc = laser(f:l, 1);    yc = laser(f:l, 2);
    gradient = diff(xc);

    idx = getConcave(1, l-f, [yc xc], gradient, 45, 1, 1);
    if idx == 0
      continue;
    end
    outliers_idx = idx:1:length(xc);
    
    if length(outliers_idx) > 5
      orto_coeffs = polyfit(xc(outliers_idx), yc(outliers_idx), 1); 
      % Compute curves intersection
      fh = symfun(orto_coeffs(1)*u + orto_coeffs(2), u);
      corners(i,:) = curveIntersection(fv, fh, u);
    end
  end
  
  % Remove void cells
  corners(~any(corners, 2), :) = [];
  
  x_out = find(corners(:,1) == 0);
  y_out = find(corners(:,2) == 0);
  outliers = intersect(x_out, y_out);
  corners(outliers, :) = [];
end

function [corners, indexes] = groupHorizontaly(corners, indexes, local_corners)
% This function allows to group corners in the horizontal direction
%
% Parameters:
% corners       - Global set of corners
% indexes       - Global set of group ids
% local_corners - Set of corners to group with $corners
%
% Return:
% corners - Global set of groupped corners
% indexes - Global set of group ids
%
  local_corners = deleteoutliers(local_corners, 0.1, 1);

  if isempty(corners)
    corners = local_corners;
    indexes = (1:1:length(local_corners))';

  else
    try
    mins = zeros(length(local_corners), 1);
    idxs = zeros(length(local_corners), 1);
    parfor i=1:length(local_corners)
      dists = zeros(length(corners), 1);
      for j=1:length(corners)
        dists(j) = pointDistance([local_corners(i,:) 0], [corners(j,:) 0]);
      end
      [mins(i), idxs(i)] = nanmin(dists);
    end
    catch
      1
    end
    len = length(indexes);
    corners = [corners; local_corners];
    indexes = [indexes; zeros(length(mins),1)];
    for i=1:length(mins)
      if mins(i) < 50
        indexes(len+i) = indexes(idxs(i));
      else
        indexes(len+i) = max(indexes) + 1;
      end
    end
  end %if-else
end

function [pts_camera, pts_world] = add2Grid(coeffs, orto_coeffs)
  m = length(coeffs);
  n = length(orto_coeffs);
  
  x_cam = zeros(n,m);     y_cam = zeros(n,m);
  x_world = zeros(n,m);   y_world = zeros(n,m);
  
  u = sym('u');
  
  % Following two lines are require to reduce parfor overhead
  c1 = coeffs(:,1);       c2 = coeffs(:,2);       c3 = coeffs(:,3);
  oc1 = orto_coeffs(:,1); oc2 = orto_coeffs(:,2); oc3 = orto_coeffs(:,3);
  
  parfor i=1:m % loop along coeffs (columns)
    disp(strcat('[add2Grid] Column: ', num2str(i)));
    ver = symfun(c1(i)*u^2 + c2(i)*u + c3(i), u);
    
    for j=1:n % loop along orto_coeffs (rows)
      hor = symfun(oc1(j)*u^2 + oc2(j)*u + oc3(j), u);
      res = curveIntersection(ver, hor, u);
      x_cam(j,i) = res(1);
      y_cam(j,i) = res(2);
      
      x_world(j,i) = 20*j;       % y camera
      y_world(j,i) = 500 - 5*i;  % -x camera
    end
  end
  
  [~, idxs] = sort(y_cam(:,1));
  x_cam = x_cam(idxs, :);
  y_cam = y_cam(idxs, :);
  
  pts_camera = [reshape(x_cam, [m*n, 1]) reshape(y_cam, [m*n, 1])];
  pts_world = [reshape(x_world, [m*n, 1]) reshape(y_world, [m*n, 1]) zeros(m*n, 1)];
end

function plotGraphs(raw_corners, grid, v_coeffs, h_coeffs)
  figure;
  imshow(zeros(2000))
  hold on;
  plot(raw_corners(:,1), raw_corners(:,2), '+r');
  plot(grid(:,4), grid(:,5), '+y');
  lin = 1:1:1000;
  for i=1:length(v_coeffs)
    plot(lin, polyval(v_coeffs(i,:), lin), 'b');
  end
  for i=1:length(h_coeffs)
    plot(lin, polyval(h_coeffs(i,:), lin), 'b');
  end
end
