function angle = pitchCorrectionAngle(corners, model)
% This function compute the pitch correction angle need to match the
% profile with the model.
% This is a typical situation when laser is rotate with respect to the y
% axis.
%
% Parameters:
%   corners = Profile keypoints
%   model   = Model keypoints
%
% Returns:
%   The pitch correction angle
%
  len = length(model);
  profile_len = pointDistance(corners(len-1,:), corners(2,:));
  model_len = pointDistance(model(len-1,:), model(2,:));
  
  if model_len(1) > profile_len(1)
    warning('Probifile is smaller than profile!');
    angle = 0;
  else
    angle = rad2deg(acos(model_len(1) / profile_len(1)));
  end  
end
