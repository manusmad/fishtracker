function varargout = FishGPS(varargin)
% FishGPS MATLAB code for FishGPS.fig
%      FishGPS, by itself, creates a new FishGPS or raises the existing
%      singleton*.
%
%      H = FishGPS returns the handle to a new FishGPS or the handle to
%      the existing singleton*.
%
%      FishGPS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FishGPS.M with the given input arguments.
%
%      FishGPS('Property','Value',...) creates a new FishGPS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FishGPS_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FishGPS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FishGPS

% Last Modified by GUIDE v2.5 26-Jan-2015 16:41:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FishGPS_OpeningFcn, ...
                   'gui_OutputFcn',  @FishGPS_OutputFcn, ...
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


% --- Executes just before FishGPS is made visible.
function FishGPS_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FishGPS (see VARARGIN)

% Choose default command line output for FishGPS
handles.output = hObject;

% Global variables
handles.vidFileName = '';

% Electrode file
handles.elecFileName = '';

handles.PrevVid      = '';
handles.PrevElec     = '';
handles.elecData     = 0; 
handles.elecTime     = 0; 
handles.elec     = 0; 
handles.x_particles     = 0; 
handles.xhRecord     = 0; 
handles.xD     = 0; 
handles.yD     = 0; 
handles.gAmp     = 0;
handles.elecTrunc = [];
handles.elecFile = '';
handles.dir_path = '';
handles.vdata_path = '';
handles.scaleFact = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FishGPS wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FishGPS_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.elecTrunc   = str2num(get(handles.elecList,'String'));
particles           = str2double(get(handles.particles,'String'));
time                = str2double(get(handles.time,'String'));

% dataFolder          = '~/Documents/My Folder/Projects/Grid/grid/Tank_Reprocessed_140703/140422_threeFreeTrials/tracks';
dataFolder          = handles.dir_path;
dir_struct          = dir(dataFolder);
[sorted_names,~]    = sortrows({dir_struct.name}');
file_names          = sorted_names;

fileIdx = [];
k       = 1;
% tracks_search           = strfind(file_names,'tracks.mat');
% file_idx              = find(not(cellfun('isempty', tracks_search)));

for i = 1:length(file_names)
    if ~isempty(strfind(file_names{i},'tracks.mat'))
        fileIdx = [fileIdx i];
        dataFileList{k} = fullfile(dataFolder,file_names{i});
        k = k+1;
    end
end

      
% Video file
handles.vidFileName = '130611_011.mov';

index_selected      = get(handles.elecFiles,'Value');
file_list           = get(handles.elecFiles,'String');
filename            = file_list{index_selected};
handles.elecFile    = filename;
%         handles.elecFile = file_names{fileIdx(fileLoop)}; %loop
% clipsname           = filename([1:end-11,end-3:end]) % Pre-tube datasets
clipsname = [filename([1:end-11]),'_tubes',filename([end-3:end])];
%        clipsname = file_names{fileIdx(fileLoop)}([1:end-11,end-3:end]); %loop

try
    handles.elecTracked = open(fullfile(handles.dir_path, filesep,filename));
    %         handles.elecTracked = open(dataFileList{fileLoop}); %loop
catch ex
    errordlg(ex.getReport('basic'),'File Type Error','modal')
end

if ~get(handles.Wild,'Value')
    try
        handles.vidTracked = open(fullfile(handles.vdata_path, filesep,clipsname));
    catch ex
        errordlg(ex.getReport('basic'),'File Type Error','modal')
    end
end

if ~get(handles.Wild,'Value')
    handles.scaleFact   = 6;

    gridTemp            = (handles.vidTracked.gridcen-repmat(handles.vidTracked.gridcen(5,:),9,1))/handles.scaleFact;
    handles.gridCoord   = [gridTemp(:,1) -gridTemp(:,2)];
    tankTemp            = (handles.vidTracked.tankcen-repmat(handles.vidTracked.gridcen(5,:),4,1))/handles.scaleFact;
    handles.tankCoord   = [tankTemp(1:2,:);tankTemp(4:-1:3,:);tankTemp(1,:)];
else
    [xD,yD]             = FS_testGridSim(get(handles.Wild,'Value'));
    handles.gridCoord   = [xD yD];
    bndry               = 200;
    handles.tankCoord   = [-bndry -bndry;bndry -bndry;bndry bndry;-bndry bndry;-bndry -bndry];
end

handles = Grid_Main(particles, time, handles);

guidata(hObject, handles);           

% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
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



function time_Callback(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time as text
%        str2double(get(hObject,'String')) returns contents of time as a double


% --- Executes during object creation, after setting all properties.
function time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sim.
function Sim_Callback(hObject, eventdata, handles)
% hObject    handle to Sim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Sim


% --- Executes on button press in Exp.
function Exp_Callback(hObject, eventdata, handles)
% hObject    handle to Exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Exp


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function elecList_Callback(hObject, eventdata, handles)
% hObject    handle to elecList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of elecList as text
%        str2double(get(hObject,'String')) returns contents of elecList as a double


% --- Executes during object creation, after setting all properties.
function elecList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to elecList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.dir_path        = get(handles.data_path, 'String');
if ~get(handles.Wild,'Value')
    handles.vdata_path  = get(handles.clips_path, 'String');
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



function data_path_Callback(hObject, eventdata, handles)
% hObject    handle to data_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_path as text
%        str2double(get(hObject,'String')) returns contents of data_path as a double



function clips_path_Callback(hObject, eventdata, handles)
% hObject    handle to clips_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clips_path as text
%        str2double(get(hObject,'String')) returns contents of clips_path as a double


% --- Executes during object creation, after setting all properties.
function clips_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clips_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in dataTypePanel.
function dataTypePanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in dataTypePanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
handles.dataType = get(eventdata.NewValue,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function dataTypePanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataTypePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.dataType = get(get(hObject,'SelectedObject'),'String');
guidata(hObject, handles);


% --- Executes when selected object is changed in motionPanel.
function motionPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in motionPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
handles.motion = get(eventdata.NewValue,'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function motionPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motionPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.motion = get(get(hObject,'SelectedObject'),'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function trialTypePanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trialTypePanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.trialType = get(get(hObject,'SelectedObject'),'String');
guidata(hObject, handles);


% --- Executes when selected object is changed in trialTypePanel.
function trialTypePanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in trialTypePanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
handles.trialType = get(eventdata.NewValue,'String');
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.dir_path        = get(handles.data_path, 'String');
if ~get(handles.Wild,'Value')
    handles.vdata_path  = get(handles.clips_path, 'String');
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
