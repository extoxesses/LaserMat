function interpolated = verboseWheelInterpolation(profile, keypoints)
% This function perform a heavy interpolation for each section of the
% wheel.
%
% Parameters
%   sections - Structure contains the section of the wheel. They are:
%     inner_side
%     flange_side
%     rolling_section
%     outer_side
%   keypoits - Structure contains the keypoints of interest
%
% Returns:
%   interpolated - Interpolated profile
%

  % Wheel profile partitioning accordingly to railway wheel normative
  masks = wheelSegmentation(profile, keypoints);

  % Wheel segments interpolation and merging
  interpolated = interpolate(profile, masks);
  interpolated = [interpolated zeros(length(interpolated), 1)];
  
%   gap = diff(interpolated(:,1));
%   idxs = find(gap > 0.05);
%   for i=1:length(idxs)
%   for i=length(idxs):-1:1
%     x = interpolated(idxs(i)-10:idxs(i)+10, 1);
%     y = interpolated(idxs(i)-10:idxs(i)+10, 2);
%     line = (linspace(min(x), max(x), (max(x)-min(x))/0.05))';
%     int = interp1(x, y, line);
%     interpolated = [ interpolated(1:idxs(i), :); ...
%                      line int zeros(length(line), 1); ...
%                      interpolated(idxs(i)+1:length(interpolated), :)];
%   end
end

function masks = wheelSegmentation(profile, keypoints)
% NB: each 'magic number' was put considering actual coordinates
%     reference system
%
  
  % Inner side
  masks.inner_side = profile(:,2) < keypoints.Q3(:,2) + 0.5 & ...
         profile(:,1) < keypoints.flange_top(:,1);

  % Flange top
  masks.flange_top = profile(:,2) > keypoints.Q1(:,2);

  % First segment before the flange top segment
  masks.before_flange = profile(:,2) > keypoints.Q1(:,2) - 2 & ...
         profile(:,2) < keypoints.Q1(:,2) & ...
         profile(:,1) < keypoints.flange_top(:,1);
       
  % First segment after the flange top segment
  masks.after_flange = profile(:,2) > keypoints.Q1(:,2) - 4 & ...
         profile(:,2) < keypoints.Q1(:,2) & ...
         profile(:,1) > keypoints.Q1(:,1);
       
  % Before Q2
  masks.before_q2 = profile(:,2) > keypoints.Q2(:,2) - 1 & ...
         profile(:,2) < keypoints.Q1(:,2) - 4 & ...
         profile(:,1) > keypoints.flange_top(:,1);

  % After Q2
  masks.after_q2 = profile(:,2) < keypoints.Q2(:,2) + 1 & ...
         profile(:,2) > keypoints.Q2(:,2)-4 & ...
         profile(:,1) > keypoints.flange_top(:,1);

  % Final curvature
  masks.final_curve = profile(:,1) > 58 & profile(:,2) > - 10;

  % outer side
  masks.outer_side = profile(:,1) > keypoints.rolling_point(:,1) & ...
         profile(:,2) < -10;

  % Remaing parts
  fields = fieldnames(masks);
  mask = zeros(length(profile), 1);
  for i = 1:numel(fields)
    mask = mask | masks.(fields{i});
  end
  
  % Segment after inner side
  masks.after_is = ~mask & (profile(:,1) < keypoints.flange_top(1));
  masks.roll = ~mask & (profile(:,1) > keypoints.flange_top(1));
end

function interpolated = interpolate(profile, masks)
  interpolated = [];
%   profile(:,1) = smooth(profile(:,1));

  % Inner side
  segment = InterpAvg(profile, masks.inner_side);
  interpolated = [interpolated; segment];

  % Init flange segment
  segment = InterpInitFlange(profile, masks.after_is);
  interpolated = [interpolated; segment];
  
  % Before Flange Top
  segment = InterpPoly(profile, masks.before_flange, 2);
  interpolated = [interpolated; segment];
  % Flange
  segment = InterpPoly(profile, masks.flange_top, 2);
  interpolated = [interpolated; segment];
  % After flange
  segment = InterpPoly(profile, masks.after_flange, 2);
  interpolated = [interpolated; segment];

  % Before Q2
  segment = InterpPoly(profile, masks.before_q2, 4);
  interpolated = [interpolated; segment];
  % After Q2
  segment = InterpPoly(profile, masks.after_q2, 4);
  segment = flipud(segment);
  interpolated = [interpolated; segment];
  
  % Rolling section
  segment = InterpRoll(profile, masks.roll);
%   segment = segment(segment(:,1) > -34.6, :);
  interpolated = [interpolated; segment];

  % Final curvature
  segment = InterpPoly(profile, masks.final_curve, 6);
  interpolated = [interpolated; segment];

  [~, i] = sort(interpolated(:,1));
  interpolated = interpolated(i,:);
  
  % outer side
  segment = InterpAvg(profile, masks.outer_side);
  [~, i] = sort(segment(:,2));
  segment = segment(flipud(i),:);
  interpolated = [interpolated; segment];
end


function segment = InterpAvg(profile, mask)
  segment = profile(mask, :);
  
  avg = mean(segment(:,1));
  segment = [avg * ones(length(segment), 1), segment(:,2)];
end

function segment = InterpPoly(profile, mask, degree)
  segment = profile(mask,:); 
  
  coeffs = polyfit(segment(:,1), segment(:,2), degree);
  segment = [segment(:,1), polyval(coeffs, segment(:,1))];
end

function segment = InterpInitFlange(profile, mask)
  segment = profile(mask,:);
  quarter = floor(length(segment)/4);
  
  s1 = segment(1:3*quarter, :);
  s2 = segment(2*quarter:length(segment), :);
  
  c1 = polyfit(s1(:,1), s1(:,2), 4);
  c2 = polyfit(s2(:,1), s2(:,2), 4);

  s1 = segment(1:2*quarter, :);
  s2 = segment(2*quarter + 1 : length(segment), :);

  segment = [s1(:,1) polyval(c1, s1(:,1)); s2(:,1) polyval(c2, s2(:,1))];
end

function segment = InterpRoll(profile, mask)
  segment = profile(mask,:);
  segment = segment(segment(:,1) > -16, :);
  
%   step = floor(length(segment)/3);
%   r1 = segment(1:step, :); 
%   r2 = segment(step+1:2*step, :);
%   r3 = segment(2*step+1:length(segment), :);
% 
%   c1 = polyfit(r1(:,1), r1(:,2), 5);
%   c2 = polyfit(r2(:,1), r2(:,2), 3);
%   c3 = polyfit(r3(:,1), r3(:,2), 3);
% 
%   segment = [r1(:,1), polyval(c1, r1(:,1)); ...
%              r2(:,1), polyval(c2, r2(:,1)); ...
%              r3(:,1), polyval(c3, r3(:,1))];

  c1 = polyfit(segment(:,1), segment(:,2), 5);
  segment = [segment(:,1), polyval(c1, segment(:,1))];
end