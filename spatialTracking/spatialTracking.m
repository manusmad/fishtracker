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

% Last Modified by GUIDE v2.5 21-Mar-2015 16:37:16

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
    handles.vdata_path  = [handles.dir_path(1:end-6) 'clips'];
end

dir_struct                  = dir(handles.dir_path);
[sorted_names,~]            = sortrows({dir_struct.name}');
allFile_names               = sorted_names;

if get(handles.rawRadio,'Value')
    tracks_search               = strfind(allFile_names,'tracks.mat');
    set(handles.push_track,'String','Track');
else
    tracks_search               = strfind(allFile_names,'particle.mat');
    set(handles.push_track,'String','Load Tracked File');
end
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

particles           = str2double(get(handles.particles,'String'));

index_selected      = get(handles.elecFiles,'Value');
file_list           = get(handles.elecFiles,'String');
filename            = file_list{index_selected};
handles.elecFile    = filename;
clipsname = [filename([1:end-11]),'_tubes',filename([end-3:end])];

handles.motion = 'random';
try
    handles.elecTracked = open(fullfile(handles.dir_path, filesep,filename));
catch ex
    errordlg(ex.getReport('basic'),'File Type Error','modal')
end

if get(handles.rawRadio,'Value')
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

    [handles, dataFileName] = FS_Main(particles, handles);
    load(dataFileName)
else
    load(fullfile(handles.dir_path, filesep,filename));
    if wildTag
        set(handles.Wild,'Value',1);
        set(handles.Tank,'Value',0);
    end
end

handles.dataType    = dataType;
handles.gridCoord   = gridCoord;
handles.tankCoord   = tankCoord; 
handles.xMean       = xMean;
handles.yMean       = yMean;
handles.thMean      = thMean;
handles.nFish       = nFish;
handles.fishTime    = fishTime;
handles.xPart       = xPart;
handles.xWeight     = xWeight;

handles.sNo         = 1;
handles.ampAll      = ampAll;
handles.freqCell    = freqCell;
handles.showPosition = get(handles.estPosition,'Value');
handles.showAngle   = get(handles.estAngle,'Value');
handles.showTime = get(handles.timeOverlay,'Value');
handles.showAllFish = get(handles.plotAllFish,'Value');
handles.showHull = get(handles.plotHull,'Value');

if exist('vidParams')
    set(handles.plotVidFish,'Visible','on');
    handles.showVid = get(handles.plotVidFish,'Value');
end


if get(handles.Wild,'Value')
   timeIdx = '';
   vidParams = '';
else 
    handles.timeIdx = timeIdx;
end
handles.vidParams   = vidParams;

if ~get(handles.Wild,'Value')
    handles.nSteps = vidParams.nFrames;
else
    handles.nSteps = length(fishTime);
    handles.timeIdx = 1:handles.nSteps;
end

set(handles.timeText,'String',['Time: ' num2str(handles.fishTime(1)) 's of ' num2str(handles.fishTime(end)) 's']);
set(handles.totalStep, 'String',['of ' num2str(handles.nSteps)])
set(handles.stepNo, 'String',num2str(1))
set(handles.stepSlider,'Value',0)

set(handles.dataName,'String', ['Dataset: ' filename]);
set(handles.numFish,'String', ['Number of Fish: ' num2str(nFish)]);


handles.fishList = mat2cell(1:nFish);
set(handles.elecFishList,'String',handles.fishList,'Value',1)
set(handles.elecFishList,'Max',nFish,'Min',0);
set(handles.vidStartStep,'String',num2str(1));
set(handles.vidStopStep,'String',num2str(handles.nSteps));

if ~handles.showAllFish
    C = get(handles.elecFishList,{'string','value'});
    handles.fishSelect = C{2};
else
    handles.fishSelect = 1:nFish;
end

if get(handles.trackAll,'Value')
    handles.showTrack = 1;
elseif get(handles.trackNone,'Value')
    handles.showTrack = 2;
elseif get(handles.trackNone,'Value')
    handles.showTrack = 3;
end 


FS_plotOverhead(handles)
FS_plotHeat(handles)
FS_plotFreqTrack(handles)

% set(handles.fishList,'String',fishList,'Value',1)
% handles.FishId = get(handles.fishList,'Value');

% set(handles.enableVFish,'Value',1);
% set(handles.enableEFish,'Value',1);

% handles.showVF = get(handles.enableVFish,'Value');
% handles.showEF = get(handles.enableEFish,'Value');
%%
display(['Done loading']);    
guidata(hObject, handles);

% --- Executes on slider movement.
function stepSlider_Callback(hObject, eventdata, handles)
% hObject    handle to stepSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

stepScale = get(handles.stepSlider,'Value');
curr_step      = floor(stepScale*(handles.nSteps));
if ~curr_step 
    curr_step = 1;
end

handles.sNo = curr_step;

FS_plotOverhead(handles)
FS_plotHeat(handles)
FS_plotFreqTrack(handles)

set(handles.stepNo,'String',num2str(curr_step));
set(handles.timeText,'String',['Time: ' num2str(handles.fishTime(curr_step)) 's of ' num2str(handles.fishTime(end)) 's']);
% handles.showVF = get(handles.enableVFish,'Value');
% handles.showEF = get(handles.enableEFish,'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stepSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in playPause.
function playPause_Callback(hObject, eventdata, handles)
% hObject    handle to playPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k          = 0;
stepNo    = str2double(get(handles.stepNo,'String'));

while (get(handles.playPause,'Value') == 1 && strcmp(get(handles.playPause,'String'),'Play') ...
        || (get(handles.playPause,'Value') == 0 && strcmp(get(handles.playPause,'String'),'Pause')))
    
    tMult      = str2double(get(handles.pSpeed,'String'));
    
    set(handles.stepNo,'String',num2str(stepNo));  
    set(handles.timeText,'String',['Time: ' num2str(handles.fishTime(stepNo)) 's of ' num2str(handles.fishTime(end)) 's']);
    handles.sNo = stepNo;
    
    FS_plotOverhead(handles)
    FS_plotHeat(handles)
    FS_plotFreqTrack(handles)
    
%     handles.frameIdx = floor(stepNo/handles.nSkip)+1;
    
    stepScale = (stepNo-1)/handles.nSteps;
    set(handles.stepSlider,'Value',stepScale);
    
%     stepScale = get(handles.stepSlider,'Value');
%     stepNo      = 1 + floor(stepScale*(handles.nSteps));
    
    if (stepNo+tMult*1) < handles.nSteps
        stepNo = stepNo+tMult*1;    
    else
        break
    end
    
    if k == 0
%         set(handles.stepSlider,'Value',stepScale);
        set(handles.playPause,'Value',0);
        set(handles.playPause,'String','Pause');
        k = 1;
        guidata(hObject, handles);
    end
end
set(handles.playPause,'Value', 0);
set(handles.playPause,'String', 'Play');
guidata(hObject, handles);


function stepNo_Callback(hObject, eventdata, handles)
% hObject    handle to stepNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepNo as text
%        str2double(get(hObject,'String')) returns contents of stepNo as a double
stepNo = str2double(get(handles.stepNo,'String'));
    
handles.sNo = stepNo;

FS_plotOverhead(handles)
FS_plotHeat(handles)
FS_plotFreqTrack(handles)
    
stepScale = stepNo/handles.nSteps;

if stepScale < 0
    stepScale = 0;
elseif stepScale > 1
    stepScale = 1;
end

set(handles.stepSlider,'Value',stepScale);
set(handles.timeText,'String',['Time: ' num2str(handles.fishTime(stepNo)) 's of ' num2str(handles.fishTime(end)) 's']);
    
%     handles.showVF = get(handles.enableVFish,'Value');
%     handles.showEF = get(handles.enableEFish,'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function stepNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to pSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pSpeed as text
%        str2double(get(hObject,'String')) returns contents of pSpeed as a double


% --- Executes during object creation, after setting all properties.
function pSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in prevPush.
function prevPush_Callback(hObject, eventdata, handles)
% hObject    handle to prevPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.showVF = get(handles.enableVFish,'Value');
% handles.showEF = get(handles.enableEFish,'Value');

stepNo    = str2double(get(handles.stepNo,'String'));
tMult      = str2double(get(handles.pSpeed,'String'));
    
if (stepNo-tMult*1) > 1
    stepNo = stepNo-tMult*1;    
else
    stepNo = 1;
end    
set(handles.stepNo,'String',num2str(stepNo)); 
set(handles.timeText,'String',['Time: ' num2str(handles.fishTime(stepNo)) 's of ' num2str(handles.fishTime(end)) 's']);

handles.sNo = stepNo;

FS_plotOverhead(handles)
FS_plotHeat(handles)
FS_plotFreqTrack(handles)

stepScale = (stepNo-1)/handles.nSteps;
set(handles.stepSlider,'Value',stepScale);

guidata(hObject, handles);

% --- Executes on button press in nextPush.
function nextPush_Callback(hObject, eventdata, handles)
% hObject    handle to nextPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.showVF = get(handles.enableVFish,'Value');
% handles.showEF = get(handles.enableEFish,'Value');

stepNo    = str2double(get(handles.stepNo,'String'));
tMult      = str2double(get(handles.pSpeed,'String'));
    
if (stepNo+tMult*1) < handles.nSteps
    stepNo = stepNo+tMult*1;    
else
    stepNo = handles.nSteps;
end
set(handles.stepNo,'String',num2str(stepNo));
set(handles.timeText,'String',['Time: ' num2str(handles.fishTime(stepNo)) 's of ' num2str(handles.fishTime(end)) 's']);
handles.sNo = stepNo;

FS_plotOverhead(handles)
FS_plotHeat(handles)
FS_plotFreqTrack(handles)
    
stepScale = (stepNo-1)/handles.nSteps;
set(handles.stepSlider,'Value',stepScale);
guidata(hObject, handles);


% --- Executes on selection change in elecFishList.
function elecFishList_Callback(hObject, eventdata, handles)
% hObject    handle to elecFishList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns elecFishList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from elecFishList


C = get(handles.elecFishList,{'string','value'});
handles.fishSelect = C{2};

if ~handles.showAllFish
    FS_plotOverhead(handles)
    FS_plotHeat(handles)
    FS_plotFreqTrack(handles)
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function elecFishList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to elecFishList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotAllFish.
function plotAllFish_Callback(hObject, eventdata, handles)
% hObject    handle to plotAllFish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotAllFish

handles.showAllFish = get(handles.plotAllFish,'Value');
if ~handles.showAllFish
    C = get(handles.elecFishList,{'string','value'});
    handles.fishSelect = C{2};
else
    handles.fishSelect = 1:handles.nFish;
end
FS_plotOverhead(handles)
FS_plotHeat(handles)
FS_plotFreqTrack(handles)
guidata(hObject, handles);

% --- Executes on button press in plotVidFish.
function plotVidFish_Callback(hObject, eventdata, handles)
% hObject    handle to plotVidFish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotVidFish
handles.showVid = get(handles.plotVidFish,'Value');

FS_plotOverhead(handles)
guidata(hObject, handles);
% --- Executes on button press in saveFig.
function saveFig_Callback(hObject, eventdata, handles)
% hObject    handle to saveFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.rawRadio,'Value')
    fName = [handles.elecFile(1:end-11) '_' num2str(handles.sNo) '.pdf'];
    pdfName = fullfile(handles.dir_path, fName);
else
    fName = [handles.elecFile(1:end-13) '_' num2str(handles.sNo) '.pdf'];
    pdfName = fullfile(handles.dir_path, fName);
end
export_fig(handles.ax_overhead,pdfName);

set(handles.figSaveText,'String',['Saved ' fName ' at ' datestr(now)]);
guidata(hObject, handles);

% --- Executes on button press in saveVideo.
function saveVideo_Callback(hObject, eventdata, handles)
% hObject    handle to saveVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stepStart   = str2num(get(handles.vidStartStep,'String'));
stepStop    = str2num(get(handles.vidStopStep ,'String'));

if stepStart >= stepStop
    set(handles.figSaveText,'String','Invalid start step and/or stop step.');
else
    if get(handles.rawRadio,'Value')
        fName = [handles.elecFile(1:end-11) '_' num2str(stepStart) '_' num2str(stepStop) '_video.mp4'];
        writeFileName = fullfile(handles.dir_path, fName);
    else
        fName = [handles.elecFile(1:end-13) '_' num2str(stepStart) '_' num2str(stepStop) '_video.mp4'];
        writeFileName = fullfile(handles.dir_path, fName);
    end

    set(handles.figSaveText,'String',['Saving ' fName ' at ' datestr(now)]);

    writerObj = VideoWriter(writeFileName,'MPEG-4');
    writerObj.FrameRate = 1/mean(diff(handles.fishTime));
    open(writerObj);

    frameCount = 0;
    set(handles.ax_progBar,'Visible','on');
    
    for i = stepStart:stepStop
        handles.sNo = i;

        FS_plotOverhead(handles)
        FS_plotHeat(handles)
        FS_plotFreqTrack(handles)

        set(handles.stepNo,'String',num2str(i));
        set(handles.timeText,'String',['Time: ' num2str(handles.fishTime(i)) 's of ' num2str(handles.fishTime(end)) 's']);
        stepScale = (i-1)/handles.nSteps;
        set(handles.stepSlider,'Value',stepScale);

        f = getframe(handles.ax_overhead);
        writeVideo(writerObj,f);
        
        frameCount = frameCount + 1;
        progPerc = frameCount/(stepStop-stepStart);
        axes(handles.ax_progBar); cla
        rectangle('Position',[0,0,progPerc,1],'EdgeColor','b','FaceColor','b')
        xlim([0 1]); ylim([0 1]);
    end

    close(writerObj);
    cla
    set(handles.ax_progBar,'Visible','off');
    set(handles.figSaveText,'String',['Saved ' fName ' at ' datestr(now)]);
end
guidata(hObject, handles);

% --- Executes on button press in timeOverlay.
function timeOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to timeOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of timeOverlay
handles.showTime = get(handles.timeOverlay,'Value');

FS_plotOverhead(handles)

guidata(hObject, handles)

% --- Executes on button press in trackOverlay.
function trackOverlay_Callback(hObject, eventdata, handles)
% hObject    handle to trackOverlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trackOverlay
handles.showTrack = get(handles.trackOverlay,'Value');

FS_plotOverhead(handles)

guidata(hObject, handles);

% --- Executes on button press in estPosition.
function estPosition_Callback(hObject, eventdata, handles)
% hObject    handle to estPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of estPosition
handles.showPosition = get(handles.estPosition,'Value');

FS_plotOverhead(handles)

guidata(hObject, handles);

% --- Executes on button press in estAngle.
function estAngle_Callback(hObject, eventdata, handles)
% hObject    handle to estAngle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of estAngle
handles.showAngle = get(handles.estAngle,'Value');

FS_plotOverhead(handles)

guidata(hObject, handles);


% --- Executes on button press in plotHull.
function plotHull_Callback(hObject, eventdata, handles)
% hObject    handle to plotHull (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotHull
handles.showHull = get(handles.plotHull,'Value');

FS_plotOverhead(handles)

guidata(hObject, handles);


% --- Executes when selected object is changed in trackOverlayType.
function trackOverlayType_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in trackOverlayType 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

if get(handles.trackAll,'Value')
    handles.showTrack = 1;
elseif get(handles.trackNone,'Value')
    handles.showTrack = 2;
elseif get(handles.trackCurrStep,'Value')
    handles.showTrack = 3;
end   

FS_plotOverhead(handles)

guidata(hObject, handles);



function vidStartStep_Callback(hObject, eventdata, handles)
% hObject    handle to vidStartStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vidStartStep as text
%        str2double(get(hObject,'String')) returns contents of vidStartStep as a double


% --- Executes during object creation, after setting all properties.
function vidStartStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vidStartStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vidStopStep_Callback(hObject, eventdata, handles)
% hObject    handle to vidStopStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vidStopStep as text
%        str2double(get(hObject,'String')) returns contents of vidStopStep as a double


% --- Executes during object creation, after setting all properties.
function vidStopStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vidStopStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
