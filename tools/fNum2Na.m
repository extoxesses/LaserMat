function na = fNum2Na(f_number)
% This function allows to approximate the lens Numerical Aperture from its
% f-number
%
% Parameters:
%   f_number = Lens f-number
%
% Return:
%   The lens numerical aperture
%
  na = 1 / (2 * f_number);
end
