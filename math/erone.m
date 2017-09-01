function d = erone(p1, p2, p3)
% This function allows to evaluate the Erone's formula to evaluate the
% diameter of the inscribed circle in a triangle defined by the point p1,
% p2 and p3.
%
% Parameters:
%  * p1, p2, p3 - the vertex of the triangle
% Returns:
%  * the diameter of the inscribed circle
%
  if length(p1) + length(p2) + length(p3) < 9
    [a, b, c] = erone2D(p1, p2, p3);
  else
    [a, b, c] = erone3D(p1, p2, p3);
  end
  
  num = 2 * a * b * c;
  den = sqrt(( a + b + c )*( - a + b + c )*( a - b + c )*( a + b - c ));
  d = num / den;    
end

function [a, b, c] = erone2D(p1, p2, p3)
% This function allows determine the length of the edge of the 2D triangle
% definede by the points p1, p2 and p3.
%
% Parameters:
%  * p1, p2, p3 - the vertex of the triangle
% Returns:
%  * the length of the three edge
%
  a = sqrt( (p1(1) - p2(1))^2 + (p1(2) - p2(2))^2 );
  b = sqrt( (p3(1) - p2(1))^2 + (p3(2) - p2(2))^2 );
  c = sqrt( (p1(1) - p3(1))^2 + (p1(2) - p3(2))^2 );
end

function [a, b, c] = erone3D(p1, p2, p3)
% This function allows determine the length of the edge of the 3D triangle
% definede by the points p1, p2 and p3.
%
% Parameters:
%  * p1, p2, p3 - the vertex of the triangle
% Returns:
%  * the length of the three edge
%
  a = sqrt( (p1(1) - p2(1))^2 + (p1(2) - p2(2))^2 + (p1(3) - p2(3))^2 );
  b = sqrt( (p3(1) - p2(1))^2 + (p3(2) - p2(2))^2 + (p3(3) - p2(3))^2 );
  c = sqrt( (p1(1) - p3(1))^2 + (p1(2) - p3(2))^2 + (p1(3) - p3(3))^2 );
end
