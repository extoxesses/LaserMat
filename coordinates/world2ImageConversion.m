function image_pts = world2ImageConversion(world_pts, cc)
% This function allows to convert a set of points in the world coordinates
% reference system, into the image reference system.
%
% Parameters:
%   world_pts - Matrix Nx3 of points in the world reference system
%   cc        - Intrinsic and extrinsic calibration values
%
% Returns:
%   image_pts - Matrix Nx2 of points in the image reference system
%
  camera = zeros(size(world_pts));
  for i=1:length(world_pts)
    camera(i,:) = (cc.R * world_pts(i,:)' + cc.T)';
  end

  % Convert from camera coordinates to undistorted sensor plane coordinates
  Xu = cc.f * camera(:,1) ./ camera(:,3);
  Yu = cc.f * camera(:,2) ./ camera(:,3);

  % Convert from undistorted to distorted sensor plane coordinates
  [Xd, Yd] = distort(Xu, Yu, cc);

  % Convert from distorted sensor plane coordinates to image coordinates
  Xf = Xd * cc.scale_factor / cc.dpx + cc.Cx;
  Yf = Yd / cc.dpy + cc.Cy;
  image_pts = [Xf Yf];
end

function [Xd, Yd] = distort(Xu, Yu, cc)
  Xd = zeros(size(Xu));
  Yd = zeros(size(Yu));
  
  if (((sum(Xu) == 0) && (sum(Yu) == 0)) || (cc.kappa1 == 0))
    Xd = Xu;
    Yd = Yu;
    return;
  end

  Ru = sqrt(Xu.^2 + Yu.^2);

  c = 1 / cc.kappa1;
  d = -c * Ru;

  Q = c / 3;
  R = -d / 2;
  D = Q^3 + R.^2;

  for i=1:length(D)
    if (D(i) >= 0) % one real root
      D(i) = sqrt(D(i));
      S = nthroot(R(i) + D(i), 3);
      T = nthroot(R(i) - D(i), 3);
      Rd = S + T;

      if (Rd < 0)
        Rd = sqrt(-1 / (3 * cc.kappa1));
        % fprintf (stderr, "\nWarning: undistorted image point to distorted image point mapping limited by\n");
        % fprintf (stderr, "         maximum barrel distortion radius of %lf\n", Rd);
        % fprintf (stderr, "         (Xu = %lf, Yu = %lf) -> (Xd = %lf, Yd = %lf)\n\n", Xu, Yu, Xu * Rd / Ru, Yu * Rd / Ru);
      end
    else % three real roots
      D(i) = sqrt(-D(i));
      S = nthroot(sqrt(R(i)^2 + D(i)^2), 3);
      T = atan2(D(i), R(i)) / 3;
      sinT = sin(T);
      cosT = cos(T);

      % the larger positive root is    2*S*cos(T)
      % the smaller positive root is   -S*cos(T) + SQRT(3)*S*sin(T)
      % the negative root is           -S*cos(T) - SQRT(3)*S*sin(T)

      Rd = -S * cosT + sqrt(3) * S * sinT; % use the smaller positive root
    end
    
    lambda = Rd / Ru(i);

    Xd(i) = Xu(i) * lambda;
    Yd(i) = Yu(i) * lambda;
  end
end
  