function diameter_error = diameterModelEvaluation(Hs, ys, ts, sHs, sys, sts)
% This function allows to estimate the error propagation while diameter is
% computed. This evaluation follows from the ones for error propagation in
% profile extraction.
% This analysis suppose that the diameter is computed using Erone's formula
%
%                                 2 * a * b * c
%    D = ----------------------------------------------------------------
%        sqrt(( a + b + c )*( - a + b + c )*( a - b + c )*( a + b - c ));
%
% where:
%   * 'D' is the diameter
%   * 'a', 'b' and 'c' are the sides of inscribed triangle in the wheel
%     circumference
% Accordingly with Figure /mm/diameter-reference-system.png we can write:
%   ° wi = yi * sin(ti)
%   ° zi = yi * cos(ti) + Hi
%   ° a = sqrt( (w1 - w2)^2 + (z1 - z2)^2 )
%
% Parameters:
%    Hs  - Laser projectors distances (in mm) from reference system origin
%          O = (0, 0, 0)
%    ys  - Coordinates (in mm) of the rolling points, along world y axis
%    ts  - Laser angles with respect to the Hs axe in [deg]
%    sHs - Hs standard deviations in [mm]
%    sys - ys standard deviations (obtained from error propagation 
%          in triangulation systems) in [mm]
%    sts - ts standard deviations in [deg]
% All the input parameters are 3x1 array containing the datas relative to
% the three profiles acquired (sides of wheel inscribed triangle)
% 
% Return:
%    diameter_error - Propagated error due by diameter estimation
%
%   ts = deg2rad(ts);
%   sts = deg2rad(sts);
  derivates = solveDerivates(Hs, ys, ts);

  diameter_error = 0;
  diameter_error = diameter_error + sum((derivates(1:3) .* sHs').^2);
  diameter_error = diameter_error + sum((derivates(4:6) .* sys').^2);
  diameter_error = diameter_error + sum((derivates(7:9) .* sts').^2);
  diameter_error = sqrt(diameter_error);
end

% Derivates considering 'b' in the formula - correct relation
function derivates = solveDerivates(Hs, ys, ts)
% This function allows to compute the derivatives needed for evaluate the
% error computed estimating the diameter
%
  % Parameters unboxing to semplify notation
  H1 = Hs(1);
  H2 = Hs(2);
  H3 = Hs(3);
  
  y1 = ys(1);
  y2 = ys(2);
  y3 = ys(3);
  
  t1 = ts(1);
  t2 = ts(2);
  t3 = ts(3);
  
  % Computation of the derivatives
  load('./test/Diameter/derivates.mat');
  derivates = zeros(9, 1);
  
  % Hs derivates
  derivates(1) = dh1(H1, H2, H3, t1, t2, t3, y1, y2, y3);
  derivates(2) = dh2(H1, H2, H3, t1, t2, t3, y1, y2, y3);
  derivates(3) = dh3(H1, H2, H3, t1, t2, t3, y1, y2, y3);
  
  % ys derivates
  derivates(4) = dy1(H1, H2, H3, t1, t2, t3, y1, y2, y3);
  derivates(5) = dy2(H1, H2, H3, t1, t2, t3, y1, y2, y3);
  derivates(6) = dy3(H1, H2, H3, t1, t2, t3, y1, y2, y3);
  
  % ts derivates
  derivates(7) = dt1(H1, H2, H3, t1, t2, t3, y1, y2, y3);
  derivates(8) = dt2(H1, H2, H3, t1, t2, t3, y1, y2, y3);
  derivates(9) = dt3(H1, H2, H3, t1, t2, t3, y1, y2, y3);
end
