function sections = wheelSection(profile, keypoints, varargin)
% This function allows to determine the main section of the profile of the
% wheel.
%
% Parameters:
%   profile   - Nx3 Matrix of the profile of the wheel
%   keypoints - Keypoints of interest
%   varargin  - Flag, if present allow to graphically show the results.
%
% Returns:
%   section - Structure of determined sections
%
  show = false;
  if nargin == 3
    show = cell2mat(varargin(1));
  end
  
  mask = zeros(length(profile), 1);
  
  top_idx = find(profile == keypoints.flange_top);
  top_idx = top_idx(1);
  
  % Wheel Inner side section
  idxs = find(profile == keypoints.Q3);
  idxs = (profile(:,2) < profile(idxs(1), 2));
  sections.inner_side = profile(idxs, :);
  sections.inner_side(sections.inner_side(:, 1) > keypoints.flange_top(1), :) = [];
  
  % Wheel Flange section
  sections.flange_side = profile;
  sections.flange_side(idxs, :) = [];
  
  % Build mask for rolling section
  flange_idxs = ~idxs;
  idxs(top_idx:length(idxs)) = 0;
  mask = mask | idxs | flange_idxs;
  
  % Wheel Outer side section
  len = length(profile);
  outer_side = profile(ceil(len/2):len, :);
  
  g = diff(outer_side(:,2));
  init = min(find(outer_side(:,1) > 60));
  corner = getConcave(init, length(outer_side), outer_side, g, [10 10]);
  idx = find(outer_side(:,2) < outer_side(corner,2));
  
  sections.outer_side = outer_side(idx, :);

  % Wheel Rolling section
  [~, idxs, ~] = intersect(profile, sections.outer_side, 'rows');
  mask(idxs) = 1;
  sections.rolling_section = profile(~mask, :);

  if show
    printSections(sections);
  end
end

function printSections(sections)
  figure;
  hold on;
  plot( sections.inner_side(:,1),      sections.inner_side(:,2),      '.m' );
  plot( sections.flange_side(:,1),     sections.flange_side(:,2),     '.k' );
  plot( sections.rolling_section(:,1), sections.rolling_section(:,2), '.r' );
  plot( sections.outer_side(:,1),      sections.outer_side(:,2),      '.b' );
end
