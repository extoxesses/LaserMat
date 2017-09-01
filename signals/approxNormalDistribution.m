function and = approxNormalDistribution(points, mu, sigma, varargin)
% This function generates a first order approximation of the normal
% distribution.
%
% Paramaters:
%   points - Inpunt points
%   mu     - Gaussian mean value
%   sigma  - Gaussian standard deviation
%
% Returns:
%   and - Discrete approximation of normal distribution
%
  snr = nan;
  if nargin > 3
    snr = cell2mat(varargin);
  end
  
  m = min(points);
  M = max(points);
  points = (m-1):0.01:(M+1);
  
  and = (1 + points * mu/sigma^2) .* exp(- (points.^2) / (2*sigma^2));
  
  discrete = zeros(1, (M-m+1));
  for i=m:1:M
    i0 = find(points == i - 0.5);
    i1 = find(points == i + 0.5);
    discrete(i+M+1) = mean(and(i0:i1));
  end
  
  if isnan(snr)
    and = discrete;
  else
    and = awgn(discrete, snr);
  end
end

%%% Matlab istruction to evaluate images SNR
% image = double(image);
% M = max(image(:))
% m = min(image(:))
% ds = std(image(:))
% snr = 20 * log10((M-m)./ds)

% figure; hold on;
% plot(xs, and, 'xk');
% plot(xs, discrete, 'r');
