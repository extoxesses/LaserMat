function [subpix_err, row_err, col_err] = evaluateGui(data, filter, window)
  addpath('./evaluation/');
  
  dim_px = str2num(getElement(data, 'pixel_size'));
  sigma = str2num(getElement(data, 'laser_amplitude'));
  sat = str2num(getElement(data, 'saturation'));
  snr = str2num(getElement(data, 'SNR'));
  
  pix_err = 1/sqrt(12);
  subpix_err = getSubpixel(filter, dim_px, window, sigma, sat, snr);
  
  pixel = str2num(getElement(data, 'pixel'));
  baseline = str2num(getElement(data, 'baseline'));
  phi = str2num(getElement(data, 'triangulation_angle'));
  image_size = str2num(getElement(data, 'image_size'));
  
  laser = struct;
         laser.roll = str2num(getElement(data, 'roll'));
   laser.sigma_roll = str2num(getElement(data, 'sigma_roll'));
        laser.pitch = str2num(getElement(data, 'pitch'));
  laser.sigma_pitch = str2num(getElement(data, 'sigma_pitch'));

  scflug = struct;
    scflug.upsilon = str2num(getElement(data, 'upsilon'));
    scflug.sigma_u = str2num(getElement(data, 'sigma_u'));
        scflug.chi = str2num(getElement(data, 'chi'));
    scflug.sigma_c = str2num(getElement(data, 'sigma_c'));
  
  cc_path = char(getElement(data, 'calib_const_path'));
  try
    load(cc_path);
  catch
    msgbox(strcat('The file ', cc_path, ' does not exist!'));
  end
  
  try
    [row_err, col_err] = pixelError(...
      pixel, ...
      baseline, phi, ...
      costants, image_size, dim_px, ... 
      laser, scflug, ...
      subpix_err, pix_err ...
    );
  catch e
    msgbox(e.message);
  end
end

function err = getSubpixel(filter, dim_px, window, sigma, sat, snr)
  if strcmp(filter, 'Center of mass')
    err = comError(dim_px, window, sigma, sat, snr);
  elseif strcmp(filter, 'Blaise & Rioux')
    err = blaisRiouxError(dim_px, window, sigma, sat, snr);
  elseif strcmp(filter, 'FIR')
    err = firError(dim_px, window, sigma, sat, snr);
  elseif strcmp(filter, 'Parabolic')
    err = parabolicError(dim_px, window, sigma, sat, snr);
  else
    msgbox('Sorry, the filter is not supported yet!');
    err = NaN;
  end
end
