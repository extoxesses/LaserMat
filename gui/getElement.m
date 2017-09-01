function value = getElement(data, name)
  l = length(data);
%   idx = contains(data, name);
  idx = strcmp(data, name);
  idx = find(idx == 1);
  value = data{idx+l};
end
