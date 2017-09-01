function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in guimodel.M with the given input arguments.
%
%      guimodel('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guimodel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guimodel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guimodel

% Last Modified by GUIDE v2.5 29-Aug-2017 17:29:02

% Begin initialization code - DO NOT EDIT
  gui_Singleton = 1;
  gui_State = struct('gui_Name',       mfilename, ...
                     'gui_Singleton',  gui_Singleton, ...
                     'gui_OpeningFcn', @main_OpeningFcn, ...
                     'gui_OutputFcn',  @main_OutputFcn, ...
                     'gui_LayoutFcn',  [] , ...
                     'gui_Callback',   []);

  if nargin && ischar(varargin{1})
      gui_State.gui_Callback = str2func(varargin{1});
  end

  clc;
  
  if nargout
      [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
  else
      gui_mainfcn(gui_State, varargin{:});
  end
  % End initialization code - DO NOT EDIT
end

% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
  % This function has no output args, see OutputFcn.
  % hObject    handle to figure
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  % varargin   command line arguments to main (see VARARGIN)

  % Choose default command line output for main
  handles.output = hObject;

  % Update handles structure
  guidata(hObject, handles);

  
  file_path = './gui/guisetup.m';
  GuiHandle = ancestor(hObject, 'figure');
  getData(GuiHandle, file_path);
  set(handles.results, 'data', []);
  
  % UIWAIT makes main wait for user response (see UIRESUME)
  % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
  varargout{1} = handles.output;
end

function filters_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in importFile.
function importFile_Callback(hObject, eventdata, handles)
% hObject    handle to importFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  [name, path] = uigetfile();
  file_path = char(strcat(path, name));
  GuiHandle = ancestor(hObject, 'figure');
  
  getData(GuiHandle, file_path);
  set(handles.results, 'data', []);
end

% --- Executes on button press in Evaluate.
function Evaluate_Callback(hObject, eventdata, handles)
% hObject    handle to Evaluate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)  
  GuiHandle = ancestor(hObject, 'figure');
  handles = guidata(GuiHandle);
  
  window_size = get(handles.windowSize);
  window_size = str2num(window_size.String);
  
  filter = get(handles.filters);
  filter = filter.String(filter.Value);
  filter = filter{1};
  
  data = get(handles.setup);
  data = data.Data;
  [sp, ey, ex] = evaluateGui(data, filter, window_size);
  
  result = get(handles.results);
  row = [string(filter), sp, ey, ex, ey+ex];
  if numel(result) ~= 0
    result = [result.Data; row];
  else
    result = row;
  end
  
  set(handles.results, 'data', cellstr(result));
end


% --- Executes on button press in refresh.
function refresh_Callback(hObject, eventdata, handles)
% hObject    handle to refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  GuiHandle = ancestor(hObject, 'figure');
  handles = guidata(GuiHandle);
  set(handles.results, 'data', []);
end

% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  GuiHandle = ancestor(hObject, 'figure');
  handles = guidata(GuiHandle);
  
  data = get(handles.setup);
  name = char(getElement(data.Data, 'model_file_name'));
  
  output = get(handles.results);
  output = output.Data;
  
  save(char(strcat(name, '.mat')), 'output')
end
