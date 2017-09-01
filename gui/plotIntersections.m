function plotIntersections(center, radius, H, t, points, h_rail, handles)
  x = -1.5*radius:1.5*radius;
  x = x + center(1);
  
  % Plot ground
  get(handles.plotout);
  plot(x, zeros(1, length(x)), '--k')
  hold on; axis equal;
  plot(x, h_rail*ones(1, length(x)), '--k')
  for i=1:10:length(x)
    y = tan(45)*(x - x(i));
    idx = y >= 0 & y <= h_rail;
    plot(x(idx), y(idx), '--', 'Color', [0.4 0.4 0.4])
  end
  
  % --- Plot wheel --- %
  % Rolling circle
  plotWheel(x, radius, center, 'k');
  % Rim
  plotWheel(x, radius-45, center, 'k');
  % Flange
  plotWheel(x, radius+28, center, 'k');
  % Axis
  plotWheel(x, 12, center, 'k');

  % --- Plot lasers --- %
  plotLaser(x, t(1), H(1, :), center, '-.r');
  plotLaser(x, t(2), H(2, :), center, '-.b');
  plotLaser(x, t(3), H(3, :), center, '-.m');
  
  plot(points(:,1), points(:,2), 'or', 'LineWidth', 2);
  
  points = [points; points(1,:)];
  plot(points(:,1), points(:,2));
  hold off;
end

function plotWheel(x, radius, center, color)
  y1 = (radius^2 - (x - center(1)).^2).^0.5 + center(2);
  idx = diff(real(y1)) ~= 0;
  plot(x(idx), y1(idx), char(color));
  
  y2 = (radius^2 - (x - center(1)).^2).^0.5 - center(2);
  idx = [(diff(real(y2)) ~= 0) 0] & (y2<=0);
  plot(x(idx), -y2(idx), char(color));
  xlabel('mm')
  ylabel('mm')
end

function plotLaser(x, t, H, center, color)
  if abs(t) ~= 90
    y = tan(deg2rad(t)) * (x - H(1)) + H(2);
    idx = y >= H(2) & y < center(2);
    plot(x(idx), y(idx), char(color), 'LineWidth', 1.5);
  else
    x = [H(1) H(1)];
    y = [H(2) center(2)];
    plot(x, y, char(color), 'LineWidth', 1.5);
  end
end
