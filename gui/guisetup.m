% --- SYSTEM SETUP --- %
model_file_name = 'setup-example';

% Camera configurations
pixel_size = 0.5;         % [mm]
image_size = 1000;        % [px]

% Triangulation condition
baseline = 150;           % [mm]
triangulation_angle = 40; %[degree]
pixel = [1000 1000];

laser = struct;
         laser.roll = 0;  % Rotation around X axis [degree]
   laser.sigma_roll = 0;
        laser.pitch = 0;  % Rotation around Y axis [degree]
  laser.sigma_pitch = 0;

scflug = struct;
  scflug.upsilon = 0;    % Scheimpflug angle with respect to y axis[degree]
  scflug.sigma_u = 0;
      scflug.chi = 0;    % Scheimpflug angle with respect to x axis[degree]24
  scflug.sigma_c = 0;

% Laser properties
laser_amplitude = 3; % [px] = 20 pixel involved by Gaussian
saturation = 5;      % [px]
SNR = nan;

% Calibration constants path
calib_const_path = './gui/guiconstants.mat';