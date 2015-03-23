function varargout = spatialTracking(varargin)
% SPATIALTRACKING MATLAB code for spatialTracking.fig
%      SPATIALTRACKING, by itself, creates a new SPATIALTRACKING or raises the existing
%      singleton*.
%
%      H = SPATIALTRACKING returns the handle to a new SPATIALTRACKING or the handle to
%      the existing singleton*.
%
%      SPATIALTRACKING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPATIALTRACKING.M with the given input arguments.
%
%      SPATIALTRACKING('Property','Value',...) creates a new SPATIALTRACKING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spatialTracking_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spatialTracking_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spatialTracking

% Last Modified by GUIDE v2.5 12-Mar-2015 08:35:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spatialTracking_OpeningFcn, ...
                   'gui_OutputFcn',  @spatialTracking_OutputFcn, ...
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


% --- Executes just before spatialTracking is made visible.
function spatialTracking_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spatialTracking (see VARARGIN)

% Choose default command line output for spatialTracking
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spatialTracking wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = spatialTracking_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function data_path_Callback(hObject, eventdata, handles)
% hObject    handle to data_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_path as text
%        str2double(get(hObject,'String')) returns contents of data_path as a double


% --- Executes during object creation, after setting all properties.
function data_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_load.
function push_load_Callback(hObject, eventdata, handles)
% hObject    handle to push_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.dir_path        = get(handles.data_path, 'String');
if ~get(handles.Wild,'Value')
    handles.vdata_path  = [handles.dir_path(end-5:end) 'clips'];
end

dir_struct                  = dir(handles.dir_path);
[sorted_names,~]            = sortrows({dir_struct.name}');
allFile_names               = sorted_names;

tracks_search               = strfind(allFile_names,'tracks.mat');
tracksIdx                   = find(not(cellfun('isempty', tracks_search)));

tracksList                  = {allFile_names{tracksIdx}};
set(handles.elecFiles,'String',tracksList,'Value',1)

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in elecFiles.
function elecFiles_Callback(hObject, eventdata, handles)
% hObject    handle to elecFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns elecFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from elecFiles


% --- Executes during object creation, after setting all properties.
function elecFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to elecFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function particles_Callback(hObject, eventdata, handles)
% hObject    handle to particles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of particles as text
%        str2double(get(hObject,'String')) returns contents of particles as a double


% --- Executes during object creation, after setting all properties.
function particles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to particles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_track.
function push_track_Callback(hObject, eventdata, handles)
% hObject    handle to push_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
