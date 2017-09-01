function name = getName(path)
  path_split = strsplit(path, '/');
  n = length(path_split);
  cell2str = char(path_split(n));
  
  name = strsplit(cell2str, '.');
  name = char(name(1));
end