function world_pts = image2WorldConversion(image_pts, cc)
% This function allows to convert a set of points in the image coordinates
% reference system, into the world reference system.
%
% Parameters:
%   image_pts - Matrix Nx2 of points in the image reference system
%   cc        - Intrinsic and extrinsic calibration values
%
% Returns:
%   world_pts- Matrix Nx3 of points in the world reference system
% 
  n_pts = length(image_pts);
  world_pts = zeros(n_pts, 3);
  
  % Conversion from image to distorted sensor coordinates and than
  % conversion from distorted sensor to undistorted sensor plane coordinates
  [Xu, Yu] = undistort(image_pts, cc);
  
  % Computation of the corresponding Xw and Yw world coordinates
  [xw, yw, zw] = cast2WorldMat(Xu, Yu, cc);
  
  world_pts(:,1) = xw;
  world_pts(:,2) = yw;
  world_pts(:,3) = zw;
end

function [Xw, Yw, Zw] = cast2WorldMat(Xu, Yu, cc)
  % Zw is set equal to 0 because laser lies in Z=0 plane
  Zw = zeros(length(Xu), 1);
  
  r1 = cc.R(1,1); r2 = cc.R(1,2); r3 = cc.R(1,3);
  r4 = cc.R(2,1); r5 = cc.R(2,2); r6 = cc.R(2,3);
  r7 = cc.R(3,1); r8 = cc.R(3,2); r9 = cc.R(3,3);
  
  T = cc.T;
  f = cc.f;
  
  denominator = (...
      (r1 * r8 - r2 * r7) .* Yu + ...
      (r5 * r7 - r4 * r8) .* Xu - ...
      (r1 * r5 - r2 * r4) * f ...
  );
 
  Xw = (( ...
          (r2 * r9 - r3 * r8) .* Yu + (r6 * r8 - r5 * r9) .* Xu - ...
          (r2 * r6 - r3 * r5) * f * ones(length(Xu), 1) ...
      ) .* Zw + ...
      (r2 * T(3) - r8 * T(1)) .* Yu + (r8 * T(2) - r5 * T(3)) .* Xu - ... 
      (r2 * T(2) - r5 * T(1)) * f * ones(length(Xu), 1) ...
  ) ./ denominator;
 
  Yw = - (( ...
          (r1 * r9 - r3 * r7) .* Yu + (r6 * r7 - r4 * r9) .* Xu - ...
          (r1 * r6 - r3 * r4) * f * ones(length(Xu), 1) ...
      ) .* Zw + ...
      (r1 * T(3) - r7 * T(1)) .* Yu + (r7 * T(2) - r4 * T(3)) .* Xu - ...
      (r1 * T(2) - r4 * T(1)) * f * ones(length(Xu), 1) ...
  ) ./ denominator;
end
