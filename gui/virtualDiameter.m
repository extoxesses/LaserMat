function [evaluation, points] = virtualDiameter(center, data)
  addpath('./math/', './wpms/');
  
  H = zeros(3, 2);
  H(1, :) = str2num(getElement(data, "H_1"));
  H(2, :) = str2num(getElement(data, "H_2"));
  H(3, :) = str2num(getElement(data, "H_3"));
  
  t = str2num(getElement(data, "t"));
  
  sH = str2num(getElement(data, "sH"));
  st = str2num(getElement(data, "st"));
  sy = str2num(getElement(data, "sy"));
  
  radius = str2num(getElement(data, "ideal_diameter")) / 2;
  
  [evaluation, points] = run(center, radius, H, t, sH, sy, st);
end

function [evaluation, points] = run(center, radius, H, t, sH, sy, st)
  % Rolling points are computed as intersection between the wheel and the three lasers
  points = getIntersections(center, radius, H, t);
  diameter = erone(points(1, :), points(2, :), points(3, :));

  % This is needed if we consider H1 ~= [0 0]
  H_axis = H(:, 1) + (abs(H(:, 2)) .* tan( deg2rad(90 - t)) );
  y1 = pointDistance([points(1,:) 0], [H_axis(1) 0 0]);
  y2 = pointDistance([points(2,:) 0], [H_axis(2) 0 0]);
  y3 = pointDistance([points(3,:) 0], [H_axis(3) 0 0]);

  % Error estimation using error propagation theory over Erone's formula
  error = diameterModelEvaluation(H_axis, [y1 y2 y3], t, sH, sy, st);

  % Print results on screen
  x1 = y1 * cos(deg2rad(t(1))) + H_axis(1);
  x2 = y2 * cos(deg2rad(t(2))) + H_axis(2);
  x3 = y3 * cos(deg2rad(t(3))) + H_axis(3);
  l1 = pointDistance([x1 y1 0], [x2 y2 0]);
  l2 = pointDistance([x3 y3 0], [x2 y2 0]);
  l3 = pointDistance([x1 y1 0], [x3 y3 0]);
  perimetro = l1 + l2 + l3;
  area = sqrt(( l1 + l2 + l3 )*( - l1 + l2 + l3 )*( l1 - l2 + l3 )*( l1 + l2 - l3 ))/4;
  H1 = x2 - x1;
  H2 = x3 - x2;
  
  evaluation = [diameter, error, y1, y2, y3, l1, l2, l3, perimetro, area, H1, H2, center];
end

function points = getIntersections(center, radius, H, t)
% This function returns three virtual points, generated from the virtual
% wheel and lasers.
%
% Parameters:
%   center - the center of the wheel
%   radius - ideal wheel radius
%   H      - Distances in [mm] between the groups of triangulation [3x1]
%   t      - Triangulation in [degree] angles [3x1]
%
% Returns:
%  virtual points.
%
  syms x y;
  w1 = symfun( (x - center(1))^2 + (y - center(2))^2 - radius^2, [x, y]);
  w2 = symfun( (x - center(1))^2 + (y - center(2))^2 + radius^2, [x, y]);
  
  try
    try
      p1 = intersect(w1, H(1, :), deg2rad(t(1)));
    catch
      p1 = intersect(w2, H(1, :), deg2rad(t(1)));
    end

    try
      p2 = intersect(w1, H(2, :), deg2rad(t(2)));
    catch
      p2 = intersect(w2, H(2, :), deg2rad(t(2)));
    end

    try
      p3 = intersect(w1, H(3, :), deg2rad(t(3)));
    catch
      p3 = intersect(w3, H(3, :), deg2rad(t(3)));
    end
    
    points = [p1; p2; p3];
  catch
    points = NaN * ones(3,2);
  end
end

function point = intersect(wheel, H, theta)
% This function conputes the intersection between the wheel and the lasers
%
  syms x y;
  laser = symfun( (y - H(2)) - tan(theta) * (x - H(1)), [x, y] );
  point = solve(wheel, laser);
  [~, i] = min(point.y);
  
  point = double([point.x(i) point.y(i)]);
end






