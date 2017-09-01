function [res_v, res_h] = cameraResolution( ...
    dist_LC, dist_CT, h_pix_num, pix_size, focal, h_vision_angle ...
  )
% This function allows to compute the camera resolution given the working
% distances of the laser triangulation system
% 
% dist_LC   - It is the laser-camera distance
% dist_CT   - It is the camera-target distance (aka working distance)
% h_pix_num - It is the number of pixels in the sensor along the horizontal
%             axis

% Distances used in wheel profile
% dist_LC = 200 from the camera lens
% dist_CT = 450 from the camera lens
% h_pix_num = 1710 using LUPA
% pix_size = 0.008
% focal = 25 mm
% h_vision_angle = 30.6

  dist_LT = sqrt(dist_CT^2 - dist_LC^2);
  alpha = rad2deg(atan(dist_LT / dist_LC));

  pixel_vertical_angle = atan(pix_size / focal);
  res_v = dist_CT * tan(pixel_vertical_angle) / cos(deg2rad(alpha));
  res_h = 2 * dist_CT * tan(deg2rad(h_vision_angle/2)) / h_pix_num;
end