function [source] = normalizeProfile(source, flip_v, flip_h)
  % First point should be the base of the triangle
  if flip_v
    source(:,1) = -source(:,1);
  end
  
  % Flip vertically and orizzontally computed profile
  if flip_h
    source(:,2) = -source(:,2);
  end
  
  % Normilize to the origin
  source = source - source(1,:);
end
