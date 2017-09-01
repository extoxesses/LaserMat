function peaks = linear(image, laser)
% This function allows to apply the 'linear' subpixel filter to
% intput laser spots (zero of the first order derivate)
%
% Parameters:
% image  - Image to elaborate
% laser  - Laser coordinates in the image space
%
% Return:
% peaks  - Detected subpixels spots
%
  num_pts = length(laser);
  peaks = laser;
  
  for i=1:num_pts
    a = double(image(laser(i,2), laser(i,1)-1));
    b = double(image(laser(i,2), laser(i,1)));
    c = double(image(laser(i,2), laser(i,1)+1));
    num = a-c;
    
    if c > a
      den = 2*(b-a);
    else
      den = 2*(b-c);
    end

    delta = num/den;
    if ~isnan(delta)
      peaks(i,1) = double(laser(i,1)) - delta;
    end
  end
end
