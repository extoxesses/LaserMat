function data = readPointFromTxt(file_path, cols, format_spec)
% This fuction extract data from Matteo's txt files with pixel and world
% coordinates
% 
  fID = fopen(char(file_path), 'r');
  if -1 == fID
    error(char(strcat('File "', string(file_path), '" not found!')));
  end
  size = [cols Inf];

  data = fscanf(fID, format_spec, size);
  fclose(fID);
  
  data = data';
end