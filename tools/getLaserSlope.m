function angle = getLaserSlope(real_world_pts, nominal_distance, threshold)
    count = 0;
    angle = 0.0;
    
    for i=2:length(real_world_pts)
      dist = abs(ptDist(real_world_pts(i-1,:), real_world_pts(i,:)));
      if dist < threshold && abs(nominal_distance / dist) < 1
          angle = angle + acos(nominal_distance / dist);
          count = count + 1;
      end
    end
    angle = rad2deg(angle / count);
end