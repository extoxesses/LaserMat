function profile = wheelInterpolation(sections, varargin)
% This function perform a light interpolation for each section of the
% wheel.
%
% Parameters
%   sections - Structure contains the section of the wheel. They are:
%     inner_side
%     flange_side
%     rolling_section
%     outer_side
%   varargin - It is a flag to graphically show the results
%
% Returns:
%   profile - fitted profile
%
  outer_side = trimSide(sections.outer_side);
  [~, idx] = sort(outer_side(:,2));
  outer_side = outer_side(flipud(idx), :);
  show = false;
  if nargin == 2
    show = cell2mat(varargin(1));
  end
  
%   inner_side = sortrows(trimSide(sections.inner_side), [2 1]);
  inner_side = trimSide(sections.inner_side);
  flange_side = trimFlange(sections.flange_side);
  rolling_section = trimRolling(sections.rolling_section);
%   outer_side = sortrows(trimSide(sections.outer_side), [2 -1]);
  outer_side = trimSide(sections.outer_side);
  [~, idx] = sort(outer_side(:,2));
  outer_side = outer_side(flipud(idx), :);
  
  profile = [inner_side; flange_side; rolling_section; outer_side];
  
  if show
    figure;
    plot(profile(:,1), profile(:,2), '.r');
  end
end

function side = trimSide(side)
  m = min(side(:,2));
  [M, i] = max(side(:,2));
  
%   x = side(i, 1) * ones(length(side), 1);
  x = mean(side(:,1)) * ones(length(side), 1);
  y = linspace(m, M, length(side))';
  
  side = [x y side(:,3)];
end

function flange = trimFlange(flange)
%   y = flange(:, 2);
%   y = medfilt1(y, 10);
%   y = smooth(y, 'rloess');
%   
%   step = 1 / (1.5*length(flange));
%   x0 = flange(1,1);
%   x1 = flange(length(flange),1);
%   lin = (x0:step:x1)';
%   y = interp1(flange(:,1), y, lin);
%
%   flange = [lin y zeros(length(y), 1)];

  % Top
  mask = flange(:,1) > -60 & flange(:,1) < -50;
  cc = polyfit(flange(mask,1), flange(mask,2), 2);
  flange(mask,2) = polyval(cc, flange(mask,1));

  mask = flange(:,1)  > -52 & flange(:,1)  < -48;
  cc = polyfit(flange(mask,1), flange(mask,2), 2);
  flange(mask,2) = polyval(cc, flange(mask,1));
  
%   mask = flange(:,1)  > -48;
%   cc = polyfit(flange(mask,1), flange(mask,2), 3);
%   flange(mask,2) = polyval(cc, flange(mask,1));
end

function section = trimRolling(section)
  %%% Firts test
%   y = medfilt1(section(:, 2), 3);
%   section(:,2) = smooth(y, 'rlowess');

  %%% Interpolation tests
  % Split the profile in 20 segments
  step = floor(length(section)/20);
  
  % Interpolate the section along 4 parts
  c1 = polyfit(section(1:step,1), section(1:step,2), 3);
  c2 = polyfit(section(step:5*step,1), section(step:5*step,2), 3);
  c3 = polyfit(section(4*step:10*step,1), section(4*step:10*step,2), 3);
  c4 = polyfit(section(10*step:15*step,1), section(10*step:15*step,2), 3);
  
  % Save profile as interpolation
  section(1:step,2) = polyval(c1, section(1:step,1));
  section(step:4*step,2) = polyval(c2, section(step:4*step,1));
  section(4*step:10*step,2) = polyval(c3, section(4*step:10*step,1));
  section(10*step:14*step,2) = polyval(c4, section(10*step:14*step,1));

  % Smooth to fix interpolation board
  y = medfilt1(section(:, 2), 3);
  section(:,2) = smooth(y, 'rlowess');
end
