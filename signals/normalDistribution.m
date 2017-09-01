function nd = normalDistribution(points, mu, sigma)
% This function generates a first order approximation of the normal
% distribution.
%
% Parameters:
%   points - Inpunt points
%   mu     - Gaussian mean value
%   sigma  - Gaussian standard deviation
%
% Returns:
%   nd - Normal Distribution

  nd = 1/(sigma * sqrt(2)) * exp(- (points - mu).^2 / (2*sigma^2));
end
 