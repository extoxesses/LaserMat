function varargout = lasermatgui(varargin)
% LASERMATGUI MATLAB code for lasermatgui.fig
%      LASERMATGUI, by itself, creates a new LASERMATGUI or raises the existing
%      singleton*.
%
%      H = LASERMATGUI returns the handle to a new LASERMATGUI or the handle to
%      the existing singleton*.
%
%      LASERMATGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LASERMATGUI.M with the given input arguments.
%
%      LASERMATGUI('Property','Value',...) creates a new LASERMATGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lasermatgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lasermatgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lasermatgui

% Last Modified by GUIDE v2.5 29-Aug-2017 17:45:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lasermatgui_OpeningFcn, ...
                   'gui_OutputFcn',  @lasermatgui_OutputFcn, ...
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


% --- Executes just before lasermatgui is made visible.
function lasermatgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lasermatgui (see VARARGIN)

% Choose default command line output for lasermatgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lasermatgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lasermatgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  main;

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  guidiameter;