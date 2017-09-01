function rolling_pt = getRolling(wheel)
% This function determine the rolling point of the wheel.
%
% Parameters:
%   wheel - Nx3 matrix of point of the wheel
%
% Returns:
%   rolling_pt - Rolling point of the wheel
%
  x = wheel(5, 1) + 70;
  
  diff = abs(wheel(:,1) - x);
  [~, idx] = min(diff);
  rolling_pt = wheel(idx, :);
end