function [calibration_costant] = Tsai( ...
  corner_pts, world_pts, image_size, sensor_size, pixel_size, scale_factor ...
)
% Since  the  calibration  points  are  on a common plane, the (xw, yw, zw)
% coordinate system can be chosen such  that zw = 0  and the corigin is not
% lose to the center of the view or y axis of the camera coordinate system.
% Since the (xw, yw, zw) is user-defined and the origin is arbitrary, it is
% no  problem setting  the origin of (xw, yw, zw) to be out of the field of
% view and not close to  the y axis.  The purpose for the latter is to make
% sure that Ty is not exactly zero.
%
% Params:
%   corner_pts   - Gage points
%   world_pts    - Relative world points
%   image_size   - Image size in number of pixels
%   sensor_size  - Sensor size in number of pixels
%   pixel_size   - Pixel size in mm
%   scale_factor - Input scale factor if it exists
%
% Return:
%  calibration_costants - Calibration costants, such as:
%                     f - Focal lenght
%      [kappa1, kappa2] - Radial distortion coefficents
%                     R - Rotation matrix
%                     T - Translation matrix
%          scale_factor - Costant to 1
%            [dpx, dpy] - Center-2-center sensors distances
%              [Cx, Cy] - Principal point
%     min_search_output - Matlab obtimization method output
% 
% REF:	"A versatile camera calibration technique for high-accuracy 3D
%        machine vision metrology using off-the-shelf TV cameras and lens" 
%	     R.Y. Tsai, IEEE Trans R&A RA-3, No.4, Aug 1987, pp 323-344.
%

  % Param extraction to be consistent with the reference article
  Xf = corner_pts(:,1);
  Yf = corner_pts(:,2);
  
  xw = world_pts(:,1);
  yw = world_pts(:,2);
  zw = world_pts(:,3);
  
  Ncx = sensor_size(1);
  Nfx = Ncx;
  
  dx = pixel_size(1);
  dy = pixel_size(2);
  
  Cx = Ncx / 2.0;
  Cy = sensor_size(2) / 2.0;
  % ------------------------------------------------------------
  
  if nargin == 6
    [R, T, f, k1, dpx, min_search] = monoview_coplanar(Xf, Yf, xw, yw, zw, Ncx, Nfx, dx, dy, Cx, Cy, scale_factor);
  else
    [R, T, f, k1, sx, min_search] = monoview_noncoplanar(Xf, Yf, xw, yw, zw, Ncx, Nfx, dx, dy, Cx, Cy);
  end

  calibration_costant.f = f;
  calibration_costant.kappa1 = k1;
  calibration_costant.kappa2 = 0;
  calibration_costant.R = R;
  calibration_costant.T = T;
  calibration_costant.scale_factor = scale_factor;
  calibration_costant.dpx = dpx;
  calibration_costant.dpy = dy;
  calibration_costant.Cx = Cx;
  calibration_costant.Cy = Cy;
  calibration_costant.min_search_output = min_search;
end

function [R, T, f, k1, dpx, min_search] = monoview_coplanar( ...
    Xf, Yf, xw, yw, zw, Ncx, Nfx, dx, dy, Cx, Cy, sx ...
  )
  % Stage 1 - Compute 3D Orientation, Position (x and y): 
  % - a) Compute the distored image coordinates (Xd, Yd) Procedure: 
  dpx = dx * Ncx / Nfx;                         % (6d)
    
  X = Xf - Cx;    Y = Yf - Cy; 
    
  Xd = dpx * X / sx;                            % (6a)
  Yd = dy * Y;                                  % (6b)

  % - b) Compute the five unknowns Ty^(-1)*r1, Ty^(-1)*r2, Ty^(-1)*Tx, Ty^(-1)*r4, Ty^(-1)*r5 
  A = [Yd.*xw Yd.*yw Yd -Xd.*xw -Xd.*yw];       % (10)
  C = A\Xd;                                     % (10)
    
  r1p = C(1); 
  r2p = C(2); 
  Txp = C(3); 
  r4p = C(4); 
  r5p = C(5); 
  clear A B C;
  
  % - c) Compute (r1,...,r9,Tx,Ty) from (Ty^(-1)*r1, Ty^(-1)*r2, Ty^(-1)*Tx, Ty^(-1)*r4, Ty^(-1)*r5): 
  % --- 1) Compute |Ty| from (Ty^(-1)*r1, Ty^(-1)*r2, Ty^(-1)*Tx, Ty^(-1)*r4, Ty^(-1)*r5): 
  C = [r1p, r2p; r4p, r5p];                     % (11)
  Sr = r1p^2 + r2p^2 + r4p^2 + r5p^2;           % (12-13)
  if rank(C) == 2 
    Ty2 = (Sr - sqrt(Sr^2 - 4 * (r1p*r5p - r4p*r2p)^2)) / (2 * (r1p*r5p - r4p*r2p)^2);
                                                % (12)
  else 
    z = C(abs(C) > 0); 
    Ty2 = 1.0 / (z(1)^2 + z(2)^2);              % (13)
  end
  Ty = abs(sqrt(Ty2));
  clear C Sr Ty2 z
  
  % --- 2) Determine the sign of Ty: 
  [~, i_max] = max(Xd.^2 + Yd.^2);              % (i)
  % Point (ii) left
  r1 = r1p*Ty;                                  % (iii)
  r2 = r2p*Ty; 
  r4 = r4p*Ty; 
  r5 = r5p*Ty; 
  Tx = Txp*Ty; 
  x = r1*xw(i_max) + r2*yw(i_max) + Tx; 
  y = r4*xw(i_max) + r5*yw(i_max) + Ty;
  if ~((sign(x) == sign(Xf(i_max))) && (sign(y) == sign(Yf(i_max))))
    Ty = - Ty;
  end
  clear ymax i x y
  
  % --- 3) Compute the 3D rotation matrix R, or r1, r2,...,r9
  % Recompuntation is needed due to Ty sign chances
  r1 = r1p*Ty;
  r2 = r2p*Ty;
  r4 = r4p*Ty;
  r5 = r5p*Ty;
  Tx = Txp*Ty;
  
  s = -sign(r1*r4 + r2*r5);                     % after (14a)
  R = [r1 r2 sqrt(1-r1^2-r2^2); r4 r5 s*sqrt(1-r4^2-r5^2)];
  R = [R(1:2,:); cross(R(1,:), R(2,:))];

  r7 = R(3,1); 
  r8 = R(3,2); 
  r9 = R(3,3); 
  
  % Stage (2d) ----------------
  y = r4*xw + r5*yw + Ty; 
  w = r7*xw + r8*yw; 
  z = [y -dy*Y] \ [w*dy.*Y];
  f = z(1);
  Tz = z(2);
  % ---------------------------
  
  if f < 0                                      % (14b)
    R(1,3) = -R(1,3); 
    R(2,3) = -R(2,3); 
    R(3,1) = -R(3,1); 
    R(3,2) = -R(3,2);
  end 
     
  r3 = R(1,3); 
  r6 = R(2,3); 
  r7 = R(3,1); 
  r8 = R(3,2); 
  clear s y w z

  % --- e) Compute the exactly solution for f, Tz, k1: 
  params_const = [r4 r5 r6 r7 r8 r9 dpx dy sx Ty];
  params = [f, Tz, 0];		% add initial guess for k1 
  [x, f_val, exit_flag, output] = fminsearch(@Tsai_8b, params, [], params_const, xw, yw, zw, X, Y );
  f = x(1); 
  Tz = x(2); 
  k1 = x(3);

  T = [Tx; Ty; Tz];
 
  % fval the value of the objective function fun at the solution x. 
  min_search.f_val = f_val;
  
  % exitflag that describes the exit condition of fminsearch 
  % > 0 Indicates that the function converged to a solution x. 
  % = 0 Indicates that the maximum number of function evaluations was exceeded. 
  % < 0 Indicates that the function did not converge to a solution. 
  min_search.exit_flag = exit_flag;
  
  % output that contains information about the optimization 
  % output.algorithm  The algorithm used 
  % output.funcCount  The number of function evaluations 
  % output.iterations The number of iterations taken
  min_search.output = output;
end

function [R, T, f, k1, sx, min_search] = monoview_noncoplanar(Xf, Yf, xw, yw, zw, Ncx, Nfx, dx, dy, Cx, Cy)
  % DO STUFF
  R = 0;
  T = 0;
  f = 0;
  k1 = 0;
  sx = 0;
  min_search = 0;
end
