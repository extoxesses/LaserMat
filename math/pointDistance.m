function distance = pointDistance(p1, p2)
% This fuction allows to compute the distance from p1 to p2.
%
% Parameters:
%   p1 = First point. It could be a single point 1x3 or a matrix Nx3
%   p2 = Second point. It could be a single point 1x3 or a matrix Nx3
%
% Returns:
%   p1 to p2 euclidean distances
%
  s1 = size(p1);
  s2 = size(p2);
  
  if s1(1) == 1 && s2(1) == 1
    distance = single(p1, p2);
    
  elseif s1(1) > 1 && s2(1) == 1
    distance = point2vector(p1, p2);
  elseif s1(1) == 1 && s2(1) > 1
    distance = point2vector(p2, p1);
    
  else
    distance = arrays(p1, p2);
    
  end
end

% -- Functions -- %
function distance = single(p1, p2)
  distance = sqrt((p1(1)-p2(1))^2 + (p1(2)-p2(2))^2 + (p1(3)-p2(3))^2);
end

function distance = point2vector(p1, p2)
  distance = sqrt( ...
    (p1(:,1) - p2(1)).^2 + ...
    (p1(:,2) - p2(2)).^2 + ...
    (p1(:,3) - p2(3)).^2 ...
  );
end

function distance = arrays(p1, p2)
  distance = sqrt( ...
    (p1(:,1) - p2(:,1)).^2 + ...
    (p1(:,2) - p2(:,2)).^2 + ...
    (p1(:,3) - p2(:,3)).^2 ...
  );
end
