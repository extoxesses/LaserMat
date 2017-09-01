% '../datasets/gio3003/2_centro-corsa.bmp'
function resolution = sqrResolution(path, low, high, square_mm)
  image = imread(path);
  %square_px = getSquares(image, low, high, th);
  square_px = getSquares(image, low, high);
  
  resolution = square_mm / square_px;
end

function squares = getSquaresFromLaser(image, low, high, th)
  [rows, cols] = size(image);
  roi = roicolor(image, low, high);
  imshow(roi);
  
  prev_sum = 0;
  init_row = -1;
  final_row = -1;
  max = 0;
  
  for r = 1:rows
    row_sum = sum(roi(r,:));
    
    if row_sum > max
      max = row_sum;
    end
    
    if init_row == -1 && row_sum < 0.7*prev_sum
      init_row = r;
    end
        
    if final_row == -1 && init_row ~= -1 && row_sum < 0.7*prev_sum && prev_sum > th
      final_row = r;
    end
    
    prev_sum = row_sum;
  end
  
  if final_row == -1 && init_row ~= -1
    final_row = cols;
  end
  
  squares = final_row - init_row;
  
  % For debug
  for c=1:cols
    roi(init_row,c) = 1;
    roi(final_row,c) = 1;
  end
  imshow(roi);
  %imwrite(roi, 'test.bmp');
end

function squares_size = getSquares(image, low, high)
  roi = roicolor(image, low, high);
  [image_points, board_size] = detectCheckerboardPoints(roi);
  
  if board_size(1) == 0
    squares_size = 0;
    return;
  end
  
  x_coordinates = image_points(:,1);
  y_coordinates = image_points(:,2);
  
  imshow(roi);
  hold on;
  scatter(x_coordinates, y_coordinates);
  line(x_coordinates, y_coordinates);
  hold off;
  
  if board_size(1) > board_size(2)
    squares_size = y_coordinates(1) - y_coordinates(board_size(1));
  else
    squares_size = y_coordinates(1) - y_coordinates(board_size(2));
  end
end