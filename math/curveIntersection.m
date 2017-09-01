function corner = curveIntersection(f1, f2, incognita)
% This function compute symbolic intersection between two curves.
%
% Parameters:
%   f1 - First curve.
%   f2 - Second curve.
%   incogita - Unknown variable, to determine-
%
% Returns:
%    corner - the intersectino between the two curves.
%
  res = solve(f1==f2, incognita, 'Real', true);
  % This soltion does not guarantee the reality of the solution
  %res = vpasolve(f1==f2);

  if length(res) < 1
    corner = [NaN NaN];
  elseif res(1) > -50
    corner = [res(1), f1(res(1))];
  else
    corner = [res(2), f1(res(2))];
  end
end