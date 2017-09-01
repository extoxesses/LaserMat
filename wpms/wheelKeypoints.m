function keypoints = wheelKeypoints(wheel)
% This method allows to determine the basic keypoints of a train wheel.
%
% Parameters:
%   Wheel - Nx3 matrix of points belonging to the section of the wheel
%
% Returns:
%   keypoints - Structure contains the coordinates of the keypoints of
%   interest.
%

  % Rolling cicle point
  roll_point = getRolling(wheel);
  
  % Top of the flange
  [~, idx] = max(wheel(:,2));
  flange_top = wheel(idx, :);
  
  % Q1 and Q2 need to compute QR
  Q1 = getQ1(wheel, flange_top);
  Q2 = getQ2(wheel, roll_point, flange_top);
  Q3 = getQ3(wheel, roll_point, flange_top);

  %%% BUILD OUTPUT
  keypoints = struct;
  keypoints.rolling_point = roll_point;
  keypoints.flange_top = flange_top;
  keypoints.Q1 = Q1;
  keypoints.Q2 = Q2;
  keypoints.Q3 = Q3;
  keypoints.R1 = wheel(length(wheel), :);
  keypoints.R2 = wheel(1, :);
end

function q1 = getQ1(wheel, flange_top)
  y = flange_top(2) - 2;
  wheel(wheel(:,1) < flange_top(1), :) = [];
  
  diff = abs(wheel(:,2) - y);
  [~, idx] = min(diff);
  q1 = wheel(idx, :);
end

function q2 = getQ2(wheel, rolling_pt, flange_top)
  y = rolling_pt(2) + 10;
  wheel(wheel(:,1) < flange_top(1), :) = [];
  
  diff = abs(wheel(:,2) - y);
  [~, idx] = min(diff);
  q2 = wheel(idx, :);
end

function q3 = getQ3(wheel, rolling_pt, flange_top)
  y = rolling_pt(2) + 10;
  wheel(wheel(:,1) > flange_top(1), :) = [];
  
  diff = abs(wheel(:,2) - y);
  [~, idx] = min(diff);
  q3 = wheel(idx, :);
end
