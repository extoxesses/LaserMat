function write2txt(file_name, varargin)
  fid = fopen(char(file_name), 'a');
  try
    for i=1:length(varargin)
      str = string(varargin{i});
      for j=1:length(str)
        fprintf(fid, strcat(str(j), '\n'));
      end
    end
    fprintf(fid, '\n');
  end
  fclose(fid);
end
