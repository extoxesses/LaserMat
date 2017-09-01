function p_perp = tilt2perp(xt, yt, f, c, u)
% This method allows to trasform sensor tilted coordinates to perpendicular
% system, due to Scheimpflug lens tilt and swing.
%
% Parameters:
%   (xp, yp) - Are the tilted sensor coordinates
%   f        - is the lens focal lenght
%   (c, u)   - Are the tilt and swing angles respectively
%
% REF: "A New Method For Scheimpflug Camera Calibration"
%      2011 10th International Workshop on Electronics, Control,
%      Measurement and Signals, Liberec, 2011, pp. 1-5.
%
  lambda = f / (f + xt*sin(c) + yt*sin(u)*cos(c));
  p_perp = lambda * (xt * [cos(c); 0] + yt * [sin(u)*cos(c); cos(u)]);
end