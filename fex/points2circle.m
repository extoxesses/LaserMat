% Function found at
% https://it.mathworks.com/matlabcentral/newsreader/view_thread/165185
%

function [xy,r] = points2circle(A,B,C)
% POINTS2CIRCLE - find circle given three points
%
% [XY,R] = POINTS2CIRCLE(A,B,C) finds the center point XY and the radius R
% of the circle passing through the three points A, B, and C
%
% POINTS2CIRCLE(P) in which P = [A ; B ; C] can also be used. P is a 3-by-2
% matrix.
%
% Example:
% POINTS2CIRCLE([1 0],[-4 3],[3,2])

  if nargin==1,
      P = A ;
      if size(P,1) ~=3 | size(P,2) ~=2,
          error ('A single input should be a 3-by-2 matrix') ;
      end
  elseif ~isequal(numel(A),numel(B),numel(C),2),
      error('The three points should all have 2 elements.')
  else
      P = [A(:) B(:) C(:)] .' ; 
  end

  % matrix
  M = [...
          1 1 1 1 ; ...
          (P(1,1).^2 + P(1,2).^2) P(1,1) P(1,2) 1 ; ...
          (P(2,1).^2 + P(2,2).^2) P(2,1) P(2,2) 1 ; ...
          (P(3,1).^2 + P(3,2).^2) P(3,1) P(3,2) 1 ...
      ] ;

  M11 = local_minordet(M,1,1) ;
  if M11==0
      xy = [] ;
      r = [] ;
      warning('No solution! Points may be on a straight line.') ;
  else
      xy(1) = 0.5 * (local_minordet(M,1,2) ./ M11) ;
      xy(2) = -0.5 * (local_minordet(M,1,3) ./ M11) ;
      r = sqrt(xy(1).^2 + xy(2).^2 + (local_minordet(M,1,4) ./ M11)) ;
  end
end

function md = local_minordet(M,i,j) ;
  % minor determinant
  M(i,:)=[] ;
  M(:,j)=[] ;
  md = det(M) ;
end