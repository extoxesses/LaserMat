function matrix = rotate(matrix, alpha, beta, phi)
% This function allows to rotate a set of points along an axis.
%
% Parameters:
%   matrix - Matrix Nx3 on 3D world points
%   alpha  - Rotation angle in the X axis
%   beta   - Rotation angle in the Y axis
%   gamma  - Rotation angle in the Z axis
%
% Returns:
%   matrix - The rotated input matrix
%
  alpha = deg2rad(alpha);
  beta = deg2rad(beta);
  phi = deg2rad(phi);
  
  rx = [1 0          0; ...
        0 cos(alpha) -sin(alpha); ...
        0 sin(alpha) cos(alpha)];
      
  ry = [cos(beta)  0 sin(beta); ...
        0          1 0; ...
        -sin(beta) 0 cos(beta)];
      
  rz = [cos(phi) -sin(phi) 0; ...
        sin(phi) cos(phi)  0; ...
        0        0         1];
  
  R = rz * ry * rx;
  
  for i=1:length(matrix)
    matrix(i,:) = (R * matrix(i,:)')';
  end
end