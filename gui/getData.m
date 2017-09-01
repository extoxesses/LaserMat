function getData(GuiHandle, file_path)
  handles = guidata(GuiHandle);
  set(handles.filePath, 'String', file_path);
  
  run(file_path);
  clear name path file_path GuiHandle eventdata hObject
  
  vars = whos;
  data = strings(1, 2);
  k = 1;
  
  for i = 1:numel(vars)
    if ~strcmp(vars(i).name, 'handles') && ~strcmp(vars(i).name, 'vars') && ~strcmp(vars(i).name, 'data')
      value = eval(vars(i).name);
      ismat = sum(size(value) > [1 1]);
      if(~isstruct(value)) && ismat < 2
        data(k, 1) = vars(i).name;
        data(k, 2) = num2str(value);
        k = k + 1;
        
      elseif (~isstruct(value)) && ismat >= 2
        for j = 1:size(value, 1)
          data(k, 1) = strcat(vars(i).name, "_", num2str(j));
          data(k, 2) = num2str(value(j, :));
          k = k + 1;
        end
        
      else
        fields = fieldnames(value);
        for j = 1:numel(fields)
          data(k, 1) = fields{j};
          data(k, 2) = num2str(value.(fields{j}));
          k = k + 1;
        end
      end
    end
  end
  
  set(handles.setup, 'data', cellstr(data));
end
