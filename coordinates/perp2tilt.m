function p_tilt = perp2tilt(xp, yp, f, c, u)
% This method allows to trasform sensor coordinates from pependicular plane
% to tilted system, due to Scheimpflug lens tilt and swing.
%
% Parameters:
%   (xp, yp) - Are the perpendicular sensor coordinates
%   f        - is the lens focal lenght
%   (c, u)   - Are the tilt and swing angles respectively
%
% REF: "A New Method For Scheimpflug Camera Calibration"
%      2011 10th International Workshop on Electronics, Control,
%      Measurement and Signals, Liberec, 2011, pp. 1-5.
%
  lambda = f / (f - xp*tan(c) - yp*tan(u)/cos(c));
  p_tilt = lambda * (xp*[1/cos(c); 0] + yp*[tan(u)*tan(c); 1/cos(u)]);
end