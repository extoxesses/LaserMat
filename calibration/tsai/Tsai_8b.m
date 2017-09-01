% f = Tsai_8b(params, params_const, xw, yw, zw, X, Y) 
% 
% ************************************************************************
% ***** Calibrating a Camera Using a Monoview Coplanar Set of Points *****
% ************************************************************************
%                              6/2004   Simon Wan  
%                              simonwan@hit.edu.cn 
% 
% Note: This is not called directly but as a function handle from the "fminsearch" 

function f = Tsai_8b(params, params_const, xw, yw, zw, X, Y) 
  % unpack the params
  f  = params(1);
  Tz = params(2);
  k1 = params(3);

  % unpack the params_const
  r4 = params_const(1);
  r5 = params_const(2);
  r6 = params_const(3);
  r7 = params_const(4);
  r8 = params_const(5);
  r9 = params_const(6);
  dx = params_const(7);
  dy = params_const(8);
  sx = params_const(9);
  Ty = params_const(10);

  r_sq = (1/sx * dx*X).^2 + (dy*Y).^2;     % r forula after (8b)
  res = (dy*Y) .* (1 + k1*r_sq) - f*(r4*xw + r5*yw + r6*zw + Ty) ./ (r7*xw + r8*yw + r9*zw + Tz);
                                    % (8b)
  f = norm(res, 2);
end
