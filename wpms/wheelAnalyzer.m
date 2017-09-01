function  [measures, key_pts]= wheelAnalyzer(wheel, show, varargin)
% This method performs an analysis of the measure of the wheel
%
% Parameters:
%   wheel    - Nx3 matrix of point of the wheel in the world reference system
%   show     - Flag. If true, the result will be graphically shown
%   varargin - If show is true, if is a flag to show a more datailed cad
%              information over the image
%
% Returns:
%   measures - Estimated measures
%   key_pts  - Keypoints of the wheel, used for the measures estimation
%
  measures = struct;
  
  % Keypoints
  key_pts = wheelKeypoints(wheel);
  
  len = length(wheel);
  measures.FH = abs(key_pts.rolling_point(2) - key_pts.flange_top(2));
  measures.FT = abs(key_pts.Q3(1) - key_pts.Q2(1));
  measures.QR = abs(key_pts.Q1(1) - key_pts.Q2(1));
  [measures.RW, p1, p2] = computeRW(wheel, key_pts.rolling_point);
  measures.RT = abs(key_pts.rolling_point(2) - wheel(len, 2));
  
  cad = false;
  if nargin == 3
    cad = cell2mat(varargin);
  end
  if show
    plotMeasures(wheel, key_pts, [p1; p2], cad);
  end
end

function [rw, p1, p2] = computeRW(wheel, rolling_pt)
  len = length(wheel);
  
  p1 = wheel(len, :);
  wheel(wheel(:,1) > rolling_pt(1), :) = [];
  
  diff = abs(wheel(:,2) - p1(2));
  [~, idx] = min(diff);
  p2 = wheel(idx, :);
  
  rw = abs(p2(1) - p1(1));
end


function plotMeasures(wheel, pts, rw_pt, cad)
  figure;
  hold on;
  
  %%% Wheel
  plot(wheel(:,1), wheel(:,2), '.r');
  
  %%% Keypoints used for measure
  plot(pts.rolling_point(:,1), pts.rolling_point(:,2), 'ok');
  plot(pts.flange_top(:,1), pts.flange_top(:,2), 'ok');
  
  plot(pts.Q1(:,1), pts.Q1(:,2), 'ok');
  plot(pts.Q2(:,1), pts.Q2(:,2), 'ok');
  plot(pts.Q3(:,1), pts.Q3(:,2), 'xb');
  
  plot(rw_pt(1,1), rw_pt(1,2), 'xk');
  plot(rw_pt(2,1), rw_pt(2,2), 'xk');
  
  len = length(wheel);
  plot(wheel(len,1), wheel(len,2), 'ob');
  
  if cad
    plotCad(wheel, pts);
  end
end

function plotCad(wheel, keypoints)
  len = length(wheel);
  
  x = [wheel(3,1)-5 wheel(len-3,1)+15];
  % Rolling point line
  y = [keypoints.rolling_point(2) keypoints.rolling_point(2)];
  plot(x, y, '--b');
  
  % RW base line
  y = [wheel(len,2) wheel(len,2)];
  plot(x, y, '--b');

  % Flange top line
  x = [wheel(3,1)-5 keypoints.rolling_point(1)+5];
  y = [keypoints.flange_top(2) keypoints.flange_top(2)];
  plot(x, y, '--b');
  
  % Q1 and Q2 lines
  x = [keypoints.Q1(1)-5 keypoints.Q1(1) + 20];
  y = [keypoints.Q1(2) keypoints.Q1(2)];
  plot(x, y, '--b');
  x = [wheel(3,1)-5 keypoints.Q1(1) + 20];
  y = [keypoints.Q2(2) keypoints.Q2(2)];
  plot(x, y, '--b');
  
  
  %%% RT vertical line
  x = [wheel(len-3,1)+10 wheel(len-3,1)+10];
  y = [wheel(len-10,2)-5 keypoints.rolling_point(2)+5];
  plot(x, y, '-.k');
  
  %%% Q1 and Q2 vertical lines
  x = [keypoints.Q2(1) keypoints.Q2(1)];
  y = [keypoints.Q2(2)-5 keypoints.Q1(2)+5];
  plot(x, y, '-.k');
  
  %%% Rolling point vertical lines
  x = [keypoints.rolling_point(1) keypoints.rolling_point(1)];
  y = [keypoints.rolling_point(2)-5 keypoints.flange_top(2)+5];
  plot(x, y, '-.k');
end
