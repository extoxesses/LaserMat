function str = struct2txt(istruct)
  str = strings;
  
  fields = fieldnames(istruct);
  for i = 1:numel(fields)
    str = strcat(str, char(fields{i}), ': \t', string(istruct.(fields{i})), '\n');
  end
end
