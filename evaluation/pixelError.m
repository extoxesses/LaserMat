function [row_err, col_err] = pixelError (...
    pixel, ...
    baseline, phi, ...
    calib_consts, image_size, pix_size, ...
    laser, scheimpflug, ...
    subpix_err, pix_err ...
)
% This function allows to evaluate the error made in measuring a profile,
% using a laser triangulation system.
%
% Parameters:
%   pixel           - Ispectioned pixel coordinates [int, int]
%
%   baseline        - Camera-to-laser distance [mm]
%   phi             - Triangulation angle [degree]
%
%   calib_consts    - Calibration constants given by calibration methods.
%     f             - Lens focal lenght
%     kappa1        - Lens radial distortion coefficient
%
%   image_size      - Image size [px] (along subpixel detection direction)
%   pix_size        - Sensor's pixel size [mm] (along subpixel detection direction)
%
%   laser_angles    - Struct containing laser position errors
%     roll          - Roll angle [degree]
%     sigma_roll    - Error in roll approximation
%     pitch         - Pitch angle [degree]
%     sigma_pitch   - Error in pitch approximation
%
%   scheimpflug_err - Scheimpflug angles and errors due lenses tilt and swing 
%     chi           - Scheimpflug angle with respect to x axis [degree]
%     sigma_chi     - Error in chi approximation
%     upsilon       - Scheimpflug angle with respect to y axis [degree]
%     sigma_upsilon - Error in upsilon approximation
%
%   subpix_err      - Error made evaluating laser peak position in the pixel along y axis [mm]
%   pix_err         - Error made evaluating laser peak position in the pixel along x axis [mm]
%
% Return:
%   row_err - Error along subpixel approximation axe
%   col_err - Error along the other axe
%
%
% REF 1: "Sviluppo di algoritmi innovativi e soluzioni flessibili per la
%        generazione automatica di traiettorie robot per applicazioni
%        industriali".
%        Tesi di Laurea magistrale Andrea QUATTRINI - Politecnico di Milano
%
% REF 2: "Error Propagation and Accurate Calibration for Camera Model"
%        B. Guendouz, C. Eswaran and S. V. Muniandy,
%        2006 IEEE International Conference on Engineering of Intelligent
%        Systems, Islamabad, 2006, pp. 1-5.
%
% REF 3:	"A versatile camera calibration technique for high-accuracy 3D
%	      machine vision metrology using off-the-shelf TV cameras and lens" 
%	      R.Y. Tsai, IEEE Trans R&A RA-3, No.4, Aug 1987, pp 323-344.
% 
  addpath('./coordinates/');
    
  % Triangulation angles degrees-2-radians conversion
  phi = deg2rad(phi);                                   % [rad]
  laser.roll = deg2rad(laser.roll);                     % [rad]
  laser.pitch = deg2rad(laser.pitch);                   % [rad]
  scheimpflug.upsilon = deg2rad(scheimpflug.upsilon);   % [rad]
  scheimpflug.chi = deg2rad(scheimpflug.chi);           % [rad]
  
  % Get undistort coordinates and compute errors due to lens distortions
  [Xu, Yu] = undistort(pixel, calib_consts);
  
  sigma_yd = sensorError(calib_consts.dpy, subpix_err);
  sigma_yu = distortionError(image_size, pix_size, calib_consts.kappa1, calib_consts.kappa2,sigma_yd);
  
  sigma_xd = sensorError(calib_consts.dpx, pix_err);
  sigma_xu = distortionError(image_size, pix_size, calib_consts.kappa1, calib_consts.kappa2, sigma_xd);
  
  % Tilt and swing coordinates
  p_tilt = perp2tilt(Xu, Yu, calib_consts.f, scheimpflug.chi, scheimpflug.upsilon);
  p1 = p_tilt(1);
  p2 = p_tilt(2);
  
  % Evaluate angles due to pixel position in (x, y) reference system
  alpha = atan(p2 / calib_consts.f); % [rad]
  beta  = atan(p1 / calib_consts.f); % [rad]

  % Evaluation of y approximation error
  sigma_ys = yScheimpflugError(p1, p2, scheimpflug, calib_consts.f, sigma_xu, sigma_yu);
  sigma_alpha = triangError(p2, sigma_ys, calib_consts.f);  
  row_err = yError(baseline, alpha, sigma_alpha, laser, phi);

  % Evaluation of x approximation error
  sigma_xs = xScheimpflugError(p1, p2, scheimpflug, calib_consts.f, sigma_xu, sigma_yu);
  sigma_beta = triangError(p1, sigma_xs, calib_consts.f);
  y = baseline * tan(phi + alpha) * cos(laser.roll);
  % col_err = xError(y*cos(alpha), phi, alpha, beta, laser, row_err, sigma_alpha, sigma_beta);
  col_err = xError(y, phi, alpha, beta, laser, row_err, sigma_alpha, sigma_beta);
end


%%% SUPPORT FUNCTIONS
function sigma = sensorError(dp, pix_err)
  sigma = sqrt(dp^2 * pix_err^2);
end

function sigma = distortionError(image_size, pix_size, k1, k2, sigma_yd)
  r = (image_size * pix_size) / 2;
  sigma = sqrt( (1 + k1*r^2 + k2*r^4)^2 * sigma_yd^2 );
end


function sigma = yScheimpflugError( ...
    xp, yp, scheimpflug, f, sigma_x, sigma_y ...
)
% This methods allows to evaluate the propagation errore due by the use of
% Scheimpglug angle.
%
%           (xt, yt) - Are the coordinate of the point under analysis
%        scheimpflug - Are the Scheimpflug angles and errors
%                      (u for y-axe, c for x_axe rotations)
%                  f - Focal distance [mm]
% (sigma_x, sigma_y) - Standart deviation error for x and y coordinates
  c = scheimpflug.chi;
  sigma_c = scheimpflug.sigma_c;
  
  u = scheimpflug.upsilon;
  sigma_u = scheimpflug.sigma_u;
  
  den  = - yp*sec(c)*tan(u) - xp*tan(c) + f;
  
  % Partial derivates
  dy = f*sec(u)/den + f*yp*sec(c)*tan(u)*sec(u)/den^2;
  dx = f*yp*tan(c)*sec(u)/den^2;
  dc = f*yp*sec(u) * (-yp*tan(c)*sec(c)*tan(u) - xp*sec(c)^2) / den^2;
  du = f * yp^2 * sec(c)*sec(u)^3/den^2 + f*yp*tan(u)*sec(u)/den;
  
  % Sigma Computation
  sigma = sqrt( dy^2*sigma_y^2 + dx^2*sigma_x^2 + du^2*sigma_u^2 + dc^2*sigma_c^2);
end


function sigma = xScheimpflugError( ...
    xp, yp, scheimpflug, f, sigma_x, sigma_y )
% This methods allows to evaluate the propagation errore due by the use of
% Scheimpglug angle.
%
% Parameters:
%             (xt, yt) - Are the coordinate of the point under analysis
%               (u, c) - Are the angles due by Scheimpflug (u for y-axe, c for x_axe rotations)
%                    f - Focal distance [mm]
%   (sigma_x, sigma_y) - Standart deviation error for x and y coordinates
%   (sigma_u, sigma_v) - Standard deviation error for Scheimpglug angles
%
% Return:
%   sigma - Error due to Scheimpflug principle
%
  c = scheimpflug.chi;
  sigma_c = scheimpflug.sigma_c;
  
  u = scheimpflug.upsilon;
  sigma_u = scheimpflug.sigma_u;
  
  den  = f - yp*sec(c)*tan(u) - xp*tan(c);
  
  dx = f*sec(c)/den + f*tan(c)*(yp*tan(c)*tan(u) + xp*sec(c))/den^2;
  dy = f*tan(c)*tan(u)/den + f*sec(c)*tan(u)*(yp*tan(c)*tan(u) + xp*sec(c))/den^2;
  dc = f*(yp*sec(c)^2*tan(u) + xp*tan(c)*sec(c))/den - f*(yp*tan(c)*tan(u) + xp*sec(c))*(-yp*tan(c)*sec(c)*tan(u) - xp*sec(c)^2)/den^2;  
  du = f*yp*tan(c)*sec(u)^2/den + f*yp*sec(c)*sec(u)^2*(yp*tan(c)*tan(u) + xp*sec(c))/den^2;

  sigma = (dx * sigma_x)^2 + (dy * sigma_y)^2 + (dc * sigma_c)^2 + (du * sigma_u)^2;
  sigma = sqrt( sigma );
end


function sigma = triangError(point, sigma_point, f)
  sigma = sqrt( (f / (f^2 + point^2) * sigma_point)^2 );
end


function sigma = yError(baseline, alpha, sigma_alpha, laser, phi)
% This method allows to evaluate di error due by triangulation system
% configuration and variables.
%
% Parameters:
%                    b - Baseline (camera-2-laser distance)
% (alpha, sigma_alpha) - Triangulation angle delta and its standard deviation error
%     (rho, sigma_rho) - Laser pitch effect and its standard deviation error
%                  phi - Initial triangulation angle
%
% Returns:
%   sigma - Row error;
%
  sigma = (baseline * (1 + tan(phi + alpha)^2) * cos(laser.roll) * sigma_alpha)^2 ...
           + (- baseline * tan(phi + alpha) * sin(laser.roll) * laser.sigma_roll)^2;
  sigma = sqrt( sigma );
end

function sigma = xError(y, phi, alpha, beta, laser, sigma_y, sigma_a, sigma_b)
  pitch = laser.pitch;
  sigma_pitch = laser.sigma_pitch;
  
  % Partial derivative
  dy = tan(beta) * cos(pitch) / sin(phi+alpha);
  da = - y * tan(beta) * cos(pitch) * cos(phi+alpha) / sin(phi+alpha)^2;
  db = y * cos(pitch) / (sin(phi+alpha) * cos(beta)^2);
  % d(phi) is negligible thanks to calibration
  dp = - y * tan(beta) * sin(pitch) / sin(phi+alpha);
  
  sigma = (dy * sigma_y)^2 + (da * sigma_a)^2 + (db * sigma_b)^2 + (dp * sigma_pitch)^2;
  sigma = sqrt( sigma );
end
