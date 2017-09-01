function varargout = guidiameter(varargin)
% GUIDIAMETER MATLAB code for guidiameter.fig
%      GUIDIAMETER, by itself, creates a new GUIDIAMETER or raises the existing
%      singleton*.
%
%      H = GUIDIAMETER returns the handle to a new GUIDIAMETER or the handle to
%      the existing singleton*.
%
%      GUIDIAMETER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDIAMETER.M with the given input arguments.
%
%      GUIDIAMETER('Property','Value',...) creates a new GUIDIAMETER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guidiameter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guidiameter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guidiameter

% Last Modified by GUIDE v2.5 30-Aug-2017 11:22:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guidiameter_OpeningFcn, ...
                   'gui_OutputFcn',  @guidiameter_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before guidiameter is made visible.
function guidiameter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guidiameter (see VARARGIN)

  % Choose default command line output for guidiameter
  handles.output = hObject;

  % Update handles structure
  guidata(hObject, handles);

  file_path = './gui/guisetdiameter.m';
  GuiHandle = ancestor(hObject, 'figure');
  getData(GuiHandle, file_path);
  set(handles.results, 'data', []);
  
  warning('off');

  % UIWAIT makes guidiameter wait for user response (see UIRESUME)
  % uiwait(handles.figure1);
% end

% --- Outputs from this function are returned to the command line.
function varargout = guidiameter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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
% end

% --- Executes on button press in evaluate.
function evaluate_Callback(hObject, eventdata, handles)
% hObject    handle to evaluate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  GuiHandle = ancestor(hObject, 'figure');
  handles = guidata(GuiHandle);

  input = get(handles.setup);
  input = input.Data;
  
  h_rail = str2num(getElement(input, "h_rail"));
  
  centerX = get(handles.center);
  centerX = str2num(centerX.String);
  centerY = h_rail + str2num(getElement(input, "ideal_diameter"))/2;
  center = [centerX centerY];
  
  [evaluation, points] = virtualDiameter(center, input);

  cols = ["diameter"; "error"; "y1"; "y2"; "y3"; "L1"; "L2"; "L3"; ...
          "perimetro"; "area"; "H1"; "H2"];

  result = [cols string(evaluation(1:12)')];
  set(handles.results, 'data', cellstr(result));
  
  
  H = zeros(3, 2);
  H(1, :) = str2num(getElement(input, "H_1"));
  H(2, :) = str2num(getElement(input, "H_2"));
  H(3, :) = str2num(getElement(input, "H_3"));
  t = str2num(getElement(input, "t"));

  plotIntersections(center, evaluation(1)/2, H, t, points, h_rail, handles);
% end

% --- Executes on button press in refresh.
function refresh_Callback(hObject, eventdata, handles)
% hObject    handle to refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  GuiHandle = ancestor(hObject, 'figure');
  handles = guidata(GuiHandle);
  set(handles.results, 'data', [])
  
  cla;
% end

% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  GuiHandle = ancestor(hObject, 'figure');
  handles = guidata(GuiHandle);

  output = get(handles.center);
  name = strcat("d_center_", output.String);
  
  output = get(handles.results);
  output = output.Data;
  
  save(char(strcat(name, '.mat')), 'output')
  
  fh = figure;
  copyobj(handles.plotout, fh);
  saveas(fh, char(name), 'fig');
  close(fh);
% end


function center_Callback(hObject, eventdata, handles)
% hObject    handle to center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of center as text
%        str2double(get(hObject,'String')) returns contents of center as a double


% --- Executes during object creation, after setting all properties.
function center_CreateFcn(hObject, eventdata, handles)
% hObject    handle to center (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
