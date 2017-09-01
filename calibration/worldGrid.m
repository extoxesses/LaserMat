function [grid] = worldGrid(board_size, sqr_size)
% This method creates a grid of world points corresponding to the points
% detected by 'detectCheckerboardPoints' in the checkboard.
% Tsai require right-hand coordinate system model and the 3D word
% coordinate system origin should far from the center of the image plane.
% Furthermore if monoview-coplanar is used, z must be zero.
% According to:
% http://stackoverflow.com/questions/32066241/order-of-points-returned-by-detectcheckerboardpoints
% checkboard points should be first along longer side, then shorter one.
%
% Parameters:
%   board_size - Define the size of the detected checkboard
%   sqr_size   - Is the size of the checkboard square
%
% Returns:
%   grid - The grid of world points
%
  grid = [(board_size(1)-1)*(board_size(2)-1) 3];
  ind = 0;
  for i = 1:(board_size(2)-1)
    for j = 1:(board_size(1)-1)
      pt = [board_size(2)-i-1 board_size(1)-j-1 0] * sqr_size;

      ind = ind + 1;
      grid(ind, 1) = pt(1);
      grid(ind, 2) = pt(2);
      grid(ind, 3) = pt(3);
    end
  end
end
