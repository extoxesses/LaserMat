function error = blaisRiouxError(dim_px, window, sigma, varargin)
% This function allows to compute the accuracy reached using Blaise
% and Rioux subpixel method for laser extraction
%
% Parameters:
%   dim_px   - Pixel dimension (assume that pixels are squared. It they
%              aren't, use pixels dimension along laser detection);
%   window   - Window size
%   sigma    - Laser amplitude
%   varargin - If present, it allows to simulate signal saturation
%
% Returns:
%   error - Error made using Blais&Rioux subpixel filter.
%
  addpath('./signals');
  
  saturated_pix = 0;
  if nargin > 3
     saturated_pix = cell2mat(varargin(1));
  end
  snr = nan;
  if nargin > 4
     snr = cell2mat(varargin(2));
  end
  
  error = getError(window, sigma, saturated_pix, snr);
  error = abs(0.5 - error) * dim_px;
end

function br = getError(window, sigma, saturated_pix, snr)
  half = floor(window/2);
  offset = saturated_pix + 5;
  x = -half-offset:1:half+offset;
  func = approxNormalDistribution(x, 0.5, sigma, snr);
  
  if saturated_pix > 1
    half_sat = floor(saturated_pix/2);
    sat_points = (-half_sat:1:half_sat);
    idx = strfind(x, sat_points);
    func(idx:idx+length(sat_points)-1) = ones(1, length(sat_points));
  end
  
  % Needed if condition is true
  offset = 0;
  idx = find(x == 0);
  if func(idx+1) < func(idx-1)
    offset = -1;
  end

  % Blais & Rioux estimator
  points = (-half:1:half);
  idxs = strfind(x, points);
  idxs = idxs:1:(idxs + length(points) - 1);
  gi  = sum(-sign(points).*func(idxs + offset));
  gii = sum(-sign(points).*func(idxs + 1 + offset));
  br = (gi / (gi - gii)) + offset;
end
