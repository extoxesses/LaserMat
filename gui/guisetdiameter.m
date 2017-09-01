% System configuration
H = zeros(3, 2); % Triangulation groups distances in [mm]
  H(1, :) = [0 0];
  H(2, :) = [(H(1, 1) + 30) 0];
  H(3, :) = [(H(2, 1) +  50.00) 0];

t = zeros(1, 3); % Angles of the triangulation groups in [deg]
  t(1) = 40;
  t(2) = 70;
  t(3) = 90;

% Stimated errors
sH = ones(1,3);             % [mm]
st = 1e-4 * ones(1, 3);   % [deg] 
sy = 0.1 * ones(1,3);    % [mm] 
       
% Railway data
h_rail = 110; % [mm]
ideal_diameter = 400; % [mm]

