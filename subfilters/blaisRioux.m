function peaks = blaisRioux(image, laser, window)
% This function allows to apply the 'blais and rioux' subpixel filter to
% intput laser spots
%
% Parameters:
% image  - Image to elaborate
% laser  - Laser coordinates in the image space
% window - Numver of pixels to take into account for the evaluation
%
% Return:
% peaks  - Detected subpixels spots
%
  num_pts = length(laser);
  peaks = laser;
  
  for i=1:num_pts
    offset = 0;
    if image(laser(i, 2), laser(i,1)+1) < image(laser(i, 2), laser(i,1)-1)
      offset = -1;
    end
    
    x = laser(i, 1) + offset;
    g1  = double( gFunction( image, laser(i, 2), x, window ) );
    g2 = double( gFunction( image, laser(i, 2), x+1, window ) );
    peaks(i, 1) = double(laser(i, 1)) + (g1 / (g1 - g2)) + offset;
  end
end

function g = gFunction(image, row, col, window)
% This function allows to compute a sort of first order discrete derivate
% for the given row
%
% image      - Image to elaborate
% [row, col] - Coordinate of the discrete spot in the image space
% window     - Number of pixel to take into account for the evaluation
%
% Return:
% g - Value of the computed g function
%
  [~, cols] = size(image);
  half = floor(window/2);
  low = max(1, (col - half));
  high = min((col + half), cols);
   
  idxs = low:1:high;
  c = idxs - col;
  
  g = sum(- sign(c) .* double(image(row, idxs)));
end
