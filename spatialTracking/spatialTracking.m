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

% Last Modified by GUIDE v2.5 04-Mar-2017 12:04:14

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

    % Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('../packages');
addpath_recurse('.');

set(handles.plotParticles,'Visible','off');
set(handles.plotParticles,'Value',0);
set(handles.plotHull,'Visible','off')
set(handles.plotHull,'Value',0);

lastFoldAddr = fullfile(fileparts(which('spatialTracking.m')),'lastFold.mat');

if exist(lastFoldAddr,'file') == 2
    load(lastFoldAddr);
    set(handles.data_path,'String',folder_name);
    set(handles.data_path,'ToolTipString',['Dataset Directory: ' folder_name]);
end
    
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


% --- Executes on button press in push_load.
function push_load_Callback(hObject, eventdata, handles)
% hObject    handle to push_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Save the current datasetfolder as the last opened folder
handles.dir_path  = get(handles.data_path, 'String');
folder_name       = handles.dir_path;
lastFoldAddr      = fullfile(fileparts(which('spatialTracking.m')),'lastFold');
save(lastFoldAddr,'folder_name');

% Read grid config file and plot grid
M = dlmread(fullfile(handles.dir_path,'gridConfig.txt'),'',2,0);
xD = M(:,1);
yD = M(:,2);
zD = M(:,3);
handles.gridCoord   = [xD yD zD];
bndry               = 0.25*max(max(xD)-min(xD),max(yD)-min(yD));
handles.tankCoord   = [min(xD)-bndry min(yD)-bndry;
                       max(xD)+bndry min(yD)-bndry;
                       max(xD)+bndry max(yD)+bndry;
                       min(xD)-bndry max(yD)+bndry;
                       min(xD)-bndry min(yD)-bndry];
                   
axes(handles.ax_overhead)
cla;
plot(handles.tankCoord(:,1),handles.tankCoord(:,2),'Color',[0.4,0.4,0.4],'LineWidth',10.01),hold on;
plot(handles.gridCoord(:,1),handles.gridCoord(:,2),'ok','LineWidth',3.01);
plot(handles.gridCoord(:,1),handles.gridCoord(:,2),'+k','LineWidth',3.01);
set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[])
set(gca,'Color',[0.92 0.97 1]);

if ~get(handles.Wild,'Value')
    handles.vdata_path  = fullfile(handles.dir_path, 'videotracks');
end

if get(handles.rawRadio,'Value')
    dir_struct                  = dir(fullfile(handles.dir_path,'freqtracks'));
    [sorted_names,~]            = sortrows({dir_struct.name}');
    allFile_names               = sorted_names;
    tracks_search               = strfind(allFile_names,'tracks.mat');
    set(handles.push_track,'String','Track');
else
    dir_struct                  = dir(fullfile(handles.dir_path,'tracked'));
    [sorted_names,~]            = sortrows({dir_struct.name}');
    allFile_names               = sorted_names;
    tracks_search               = strfind(allFile_names,'particle.mat');
    set(handles.push_track,'String','Load Tracked File');
end
tracksIdx                   = find(not(cellfun('isempty', tracks_search)));

tracksList                  = {allFile_names{tracksIdx}};
set(handles.elecFiles,'String',tracksList,'Value',1)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in push_track.
function push_track_Callback(hObject, eventdata, handles)
% hObject    handle to push_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.nPart               = str2double(get(handles.particles,'String'));
batchProc                   = get(handles.batchProcess,'Value');
handles.motion              = 'random3D';
file_list                   = get(handles.elecFiles,'String');

execFlag                    = 1;
index_selected              = 0;

if get(handles.rawRadio,'Value')
    while execFlag
        if batchProc
            index_selected = index_selected + 1;
            if index_selected == length(file_list)
                execFlag = 0;
            end
        else
            index_selected  = get(handles.elecFiles,'Value');
            execFlag = 0;
        end

        set(handles.elecFiles,'Value',index_selected)
        handles.file_idx    = index_selected;
        filename            = file_list{index_selected};
        handles.elecFile    = filename;

        try
            handles.elecTracked = open(fullfile(handles.dir_path,'freqtracks',filename));
        catch ex
            errordlg(ex.getReport('basic'),'File Type Error','modal')
        end
        if ~get(handles.Wild,'Value') 
            try
                trackFileAddr = fullfile(handles.dir_path,'videotracks',strrep(filename,'tracks','videotracks'));
                handles.vidTracked = open(trackFileAddr);
            catch ex
                errordlg(ex.getReport('basic'),'File Type Error','modal')
            end

            handles.scaleFact   = 6;

            gridTemp            = (handles.vidTracked.gridcen-repmat(handles.vidTracked.gridcen(5,:),9,1))/handles.scaleFact;
            handles.gridCoord   = [gridTemp(:,1) gridTemp(:,2)];
            tankTemp            = (handles.vidTracked.tankcen-repmat(handles.vidTracked.gridcen(5,:),4,1))/handles.scaleFact;
            handles.tankCoord   = [tankTemp(1:2,:);tankTemp(4:-1:3,:);tankTemp(1,:)];
        end
        
        [handles, dataFileName] = FS_Main(handles);
        handles.tempFileName    = dataFileName;
        if batchProc
            dataFileName        = fullfile(handles.dir_path,'freqtracks',strrep(handles.elecFile,'tracks','particle'));
            movefile(handles.tempFileName,dataFileName);
            set(handles.figSaveText,'String',['Saved ' strrep(handles.elecFile,'tracks','particle') ' at ' datestr(now)]);
        else 
            load(dataFileName)
            if ~particle.wildTag 
                if particle.nFish >1
                    load(fullfile(handles.dir_path,'fishMap'));
                    handles.fishMap = fishMap;
                end
            end
            set(handles.saveTrackData,'Enable','on');
            set(handles.limMax,'Enable','on');
            set(handles.limManual,'Enable','on');
            set(handles.figSaveText,'String',['Finished Tracking ' strrep(handles.elecFile,'tracks','particle') ' at ' datestr(now)]);
        end
    end       
else
    index_selected              = get(handles.elecFiles,'Value');
    filename                    = file_list{index_selected};
    load(fullfile(handles.dir_path,'tracked',filename));
    
    if ~particle.wildTag 
        try
            trackFileAddr       = fullfile(handles.dir_path,'videotracks',strrep(filename,'particle','videotracks'));
            handles.vidTracked  = open(trackFileAddr);
        catch ex
            errordlg(ex.getReport('basic'),'File Type Error','modal')
        end
        if particle.nFish >1
            load(fullfile(handles.dir_path,'fishMap'));
            handles.fishMap     = fishMap;
        end
    end
    
    if particle.wildTag
        set(handles.Wild,'Value',1);
        set(handles.Tank,'Value',0);
    end
    set(handles.saveTrackData,'Enable','off');
    set(handles.figSaveText,'String',['Finished Loading ' filename ' at ' datestr(now)]);
end

if ~batchProc
    handles.particle        = particle;
    handles.sNo             = 1;
    handles.showNone        = get(handles.estNone,'Value');
    handles.showPosition    = get(handles.estPosition,'Value');
    handles.showAngle       = get(handles.estAngle,'Value');
    handles.showTime        = get(handles.timeOverlay,'Value');
    handles.showAllFish     = get(handles.plotAllFish,'Value');
    handles.showHull        = get(handles.plotHull,'Value');
    handles.showParticles   = get(handles.plotParticles,'Value');
    handles.heatType        = 'actual';

    if ~handles.particle.wildTag
        set(handles.plotVidFish,'Enable','on');
        handles.showVid     = get(handles.plotVidFish,'Value');
        handles.nSteps      = length(handles.vidTracked.frameTime);
        elecTime            = handles.particle.t;
        handles.timeIdx     = zeros(handles.nSteps,1);
        for n = 1:handles.nSteps
           [~,handles.timeIdx(n)] = min(abs(elecTime - handles.vidTracked.frameTime(n)));
        end
    else
        set(handles.plotVidFish,'Enable','off');
        handles.nSteps      = length(handles.particle.t);
        handles.timeIdx     = 1:handles.nSteps;
    end
%%%
    set(handles.timeText,'String',['Time: ' num2str(handles.particle.t(1)) 's of ' num2str(handles.particle.t(end)) 's']);
    set(handles.totalStep, 'String',['of ' num2str(handles.nSteps)])
    set(handles.stepNo, 'String',num2str(1))
    set(handles.stepSlider,'Value',0)

    set(handles.dataName,'String', ['Dataset: ' filename]);
    set(handles.numFish,'String', ['Number of Fish: ' num2str(handles.particle.nFish)]);
    set(handles.vidFPS,'String', num2str(1/mean(diff(handles.particle.t))));

    handles.filename        = filename(1:end-4);

    handles.fishList = cellfun(@num2str,num2cell(1:handles.particle.nFish),'uniformoutput',0);
    set(handles.elecFishList,'String',handles.fishList,'Value',1)
    set(handles.elecFishList,'Max',handles.particle.nFish,'Min',0);
    
    ids                     = 1:handles.particle.nFish;
    list                    = cell(handles.particle.nFish,1);
    col                     = distinguishable_colors(handles.particle.nFish);

    for k = 1:handles.particle.nFish
        coltag              = reshape(dec2hex(round(col(ids(k),:)*255))',1,6);           
        list{k}             = sprintf('<html><body bgcolor="%s">Fish %02d</body></html>',coltag,ids(k));
    end
    set(handles.elecFishList,'String',list);
    set(handles.vidStartStep,'String',num2str(1));
    set(handles.vidStopStep,'String',num2str(handles.nSteps));

    if ~handles.showAllFish
        C                   = get(handles.elecFishList,{'string','value'});
        handles.fishSelect  = C{2};
    else
        handles.fishSelect  = 1:handles.particle.nFish;
    end

    if get(handles.trackAll,'Value')
        handles.showTrack   = 1;
    elseif get(handles.trackNone,'Value')
        handles.showTrack   = 2;
    elseif get(handles.trackNone,'Value')
        handles.showTrack   = 3;
    end 
%%%
    if get(handles.limDefault,'Value')
        handles.bndryX      = [min(handles.particle.tankCoord(:,1)) max(handles.particle.tankCoord(:,1))];
        handles.bndryY      = [min(handles.particle.tankCoord(:,2)) max(handles.particle.tankCoord(:,2))];
    elseif get(handles.limMax,'Value')
        xMaxAbs             = max(abs([min([handles.particle.fish(:).x]) max([handles.particle.fish(:).x])]));
        yMaxAbs             = max(abs([min([handles.particle.fish(:).y]) max([handles.particle.fish(:).y])]));
        xtankMaxAbs         = max(abs([min(handles.particle.tankCoord(:,1)) max(handles.particle.tankCoord(:,1))]));
        ytankMaxAbs         = max(abs([min(handles.particle.tankCoord(:,2)) max(handles.particle.tankCoord(:,2))]));
        maxLim              = max([xMaxAbs yMaxAbs xtankMaxAbs ytankMaxAbs]);

        handles.bndryX      = [-maxLim maxLim];
        handles.bndryY      = [-maxLim maxLim];        
    elseif get(handles.limManual,'Value')
        str2double(get(handles.limEdit,'String'))
        handles.bndryX      = handles.limScale*[min(handles.particle.tankCoord(:,1)) max(handles.particle.tankCoord(:,1))];
        handles.bndryY      = handles.limScale*[min(handles.particle.tankCoord(:,2)) max(handles.particle.tankCoord(:,2))];
    end
    guidata(hObject, handles);

    FS_plotOverhead(handles)
    FS_plotFreqTrack(handles)
    FS_plotHeat(handles)

    display('Done loading');
end

guidata(hObject, handles);
beep

% end
% --- Executes on slider movement.
function stepSlider_Callback(hObject, eventdata, handles)
% hObject    handle to stepSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

stepScale       = get(handles.stepSlider,'Value');
curr_step       = floor(stepScale*(handles.nSteps));
if ~curr_step 
    curr_step   = 1;
end

handles.sNo     = curr_step;

FS_plotOverhead(handles)
FS_plotFreqTrack(handles)
FS_plotHeat(handles)

set(handles.stepNo,'String',num2str(curr_step));

if ~get(handles.Wild,'Value')
    curr_step   = handles.timeIdx(curr_step);
end

set(handles.timeText,'String',['Time: ' num2str(handles.particle.t(curr_step)) 's of ' num2str(handles.particle.t(end)) 's']);
guidata(hObject, handles);


% --- Executes on button press in playPause.
function playPause_Callback(hObject, eventdata, handles)
% hObject    handle to playPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k           = 0;
stepNo      = str2double(get(handles.stepNo,'String'));
tMult       = str2double(get(handles.pSpeed,'String'));
tMult       = floor(tMult);
set(handles.pSpeed,'String',num2str(tMult));

while ((get(handles.playPause,'Value') == 1 && strcmp(get(handles.playPause,'String'),'Play')) ...
        || (get(handles.playPause,'Value') == 0 && strcmp(get(handles.playPause,'String'),'Pause')))
    
    set(handles.stepNo,'String',num2str(stepNo));  
    set(handles.timeText,'String',['Time: ' num2str(handles.particle.t(stepNo)) 's of ' num2str(handles.particle.t(end)) 's']);
    handles.sNo = stepNo;
    guidata(hObject, handles);
    
    if ~get(handles.Wild,'Value')
        curr_step = handles.timeIdx(stepNo);
    else
        curr_step = stepNo;
    end

    set(handles.timeText,'String',['Time: ' num2str(handles.particle.t(curr_step)) 's of ' num2str(handles.particle.t(end)) 's']);

    FS_plotOverhead(handles)
    FS_plotFreqTrack(handles)
    FS_plotHeat(handles)
    
    pause(0.2)
    stepScale       = (stepNo)/handles.nSteps;
    set(handles.stepSlider,'Value',stepScale);
    
    if (stepNo+tMult*1) <= handles.nSteps
        stepNo      = stepNo+tMult*1;    
    else
        break
    end
    
    if k == 0
        set(handles.playPause,'Value',0);
        set(handles.playPause,'String','Pause');
        k           = 1;
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
stepNo              = str2double(get(handles.stepNo,'String'));
handles.sNo         = stepNo;

FS_plotOverhead(handles)
FS_plotFreqTrack(handles)
FS_plotHeat(handles)
    
stepScale = stepNo/handles.nSteps;

if stepScale < 0
    stepScale = 0;
elseif stepScale > 1
    stepScale = 1;
end

set(handles.stepSlider,'Value',stepScale);
if ~get(handles.Wild,'Value')
    curr_step = handles.timeIdx(stepNo);
else
    curr_step = stepNo;
end

set(handles.timeText,'String',['Time: ' num2str(handles.particle.t(curr_step)) 's of ' num2str(handles.particle.t(end)) 's']);
guidata(hObject, handles);


% --- Executes on button press in prevPush.
function prevPush_Callback(hObject, eventdata, handles)
% hObject    handle to prevPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.showVF = get(handles.enableVFish,'Value');
% handles.showEF = get(handles.enableEFish,'Value');

stepNo    = str2double(get(handles.stepNo,'String'));
tMult     = str2double(get(handles.pSpeed,'String'));
tMult     = floor(tMult);
set(handles.pSpeed,'String',num2str(tMult));
    
if (stepNo-tMult*1) > 1
    stepNo = stepNo-tMult*1;    
else
    stepNo = 1;
end    

set(handles.stepNo,'String',num2str(stepNo)); 

if ~get(handles.Wild,'Value')
    curr_step = handles.timeIdx(stepNo);
else
    curr_step = stepNo;
end

set(handles.timeText,'String',['Time: ' num2str(handles.particle.t(curr_step)) 's of ' num2str(handles.particle.t(end)) 's']);

handles.sNo = stepNo;

FS_plotOverhead(handles)
FS_plotFreqTrack(handles)
FS_plotHeat(handles)

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
set(handles.timeText,'String',['Time: ' num2str(handles.particle.t(stepNo)) 's of ' num2str(handles.particle.t(end)) 's']);
handles.sNo = stepNo;

FS_plotOverhead(handles)
FS_plotFreqTrack(handles)
FS_plotHeat(handles)
    
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

if ~handles.showAllFish
    C = get(handles.elecFishList,{'string','value'});
    handles.fishSelect = C{2};
    FS_plotOverhead(handles)
    FS_plotFreqTrack(handles)
    FS_plotHeat(handles)
else
    handles.fishSelect = 1:handles.particle.nFish;
end

guidata(hObject, handles);


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
    handles.fishSelect = 1:handles.particle.nFish;
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

fishStr = num2str(handles.fishSelect);
fishStr(ismember(fishStr,' ,.:;!')) = [];

if get(handles.rawRadio,'Value')
    fName = [handles.elecFile(1:end-11) '_F' fishStr '_' num2str(handles.sNo) '.pdf'];
    pdfName = fullfile(handles.dir_path, fName);
else
    fName = [handles.elecFile(1:end-20) '_F' fishStr '_' num2str(handles.sNo) '.pdf'];
    pdfName = fullfile(handles.dir_path, fName);
end

%{
[FileName,PathName,~] = uiputfile('*.pdf','Save overhead plot as ..',pdfName);

if FileName ~= 0
    userFileName = fullfile(PathName, FileName);
%     print(fName(1:end-4),'-dpdf')
%     export_fig(userFileName,'-zbuffer',handles.ax_overhead);
    export_fig(handles.ax_overhead,userFileName);
    set(handles.figSaveText,'String',['Saved ' FileName ' at ' datestr(now)]);
end
%}
F = getframe(handles.ax_overhead);
Image = frame2im(F);
imwrite(Image, [fName(1:end-4),'.jpg'])
set(handles.figSaveText,'String',['Saved ' [fName(1:end-4),'.jpg'] ' at ' datestr(now)]);
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

    [FileName,PathName,~] = uiputfile('*.mp4','Save video as ..',writeFileName);

    if FileName ~= 0
        userFileName = fullfile(PathName, FileName);

        set(handles.figSaveText,'String',['Saving ' FileName ' at ' datestr(now)]);

        writerObj = VideoWriter(userFileName,'MPEG-4');

        writerObj.FrameRate = str2num(get(handles.vidFPS,'String'));
        open(writerObj);

        frameCount = 0;
        set(handles.ax_progBar,'Visible','on');

        for i = stepStart:stepStop
            handles.sNo = i;

            FS_plotOverhead(handles)
            FS_plotHeat(handles)
            FS_plotFreqTrack(handles)

            set(handles.stepNo,'String',num2str(i));
            set(handles.timeText,'String',['Time: ' num2str(handles.particle.t(i)) 's of ' num2str(handles.particle.t(end)) 's']);
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


% --- Executes on button press in saveTrackData.
function saveTrackData_Callback(hObject, eventdata, handles)
% hObject    handle to saveTrackData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dataFileName = fullfile(handles.dir_path,'freqtracks',strrep(handles.elecFile,'tracks','particle'));

[FileName,PathName,~] = uiputfile('*.mat','Save tracked data as ..',dataFileName);

if FileName ~= 0
    userFileName = fullfile(PathName, FileName);
    movefile(handles.tempFileName,userFileName);
    set(handles.figSaveText,'String',['Saved ' strrep(handles.elecFile,'tracks','particle') ' at' datestr(now)]);
    set(handles.saveTrackData,'Enable','off');
end

guidata(hObject, handles);


% --- Executes on button press in plotParticles.
function plotParticles_Callback(hObject, eventdata, handles)
% hObject    handle to plotParticles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotParticles

handles.showParticles   = get(handles.plotParticles,'Value');

FS_plotOverhead(handles)

guidata(hObject, handles);



% --- Executes on key press with focus on data_path and none of its controls.
function data_path_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to data_path (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
handles.dir_path  = get(handles.data_path, 'String');
folder_name = uigetdir(handles.dir_path,'Select dataset folder ...');
if folder_name ~= 0
    set(handles.data_path,'String',folder_name);
    set(handles.data_path,'ToolTipString',['Dataset Directory: ' folder_name]);
    lastFoldAddr = fullfile(fileparts(which('spatialTracking.m')),'lastFold');
    save(lastFoldAddr,'folder_name');
end

guidata(hObject, handles);


% --- Executes on button press in selDir.
function selDir_Callback(hObject, eventdata, handles)
% hObject    handle to selDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dir_path  = get(handles.data_path, 'String');
folder_name = uigetdir(handles.dir_path,'Select dataset folder ...');
if folder_name ~= 0
    set(handles.data_path,'String',folder_name);
    set(handles.data_path,'ToolTipString',['Dataset Directory: ' folder_name]);
    lastFoldAddr = fullfile(fileparts(which('spatialTracking.m')),'lastFold');
    save(lastFoldAddr,'folder_name');
end

% exist lastFoldAddr var

guidata(hObject, handles);

% --- Executes when selected object is changed in uipanel17.
function uipanel17_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel17 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

if get(handles.limDefault,'Value')
        handles.bndryX      = [min(handles.particle.tankCoord(:,1)) max(handles.particle.tankCoord(:,1))];
        handles.bndryY      = [min(handles.particle.tankCoord(:,2)) max(handles.particle.tankCoord(:,2))];
    elseif get(handles.limMax,'Value')
        xMaxAbs             = max(abs([min([handles.particle.fish(:).x]) max([handles.particle.fish(:).x])]));
        yMaxAbs             = max(abs([min([handles.particle.fish(:).y]) max([handles.particle.fish(:).y])]));
        xtankMaxAbs         = max(abs([min(handles.particle.tankCoord(:,1)) max(handles.particle.tankCoord(:,1))]));
        ytankMaxAbs         = max(abs([min(handles.particle.tankCoord(:,2)) max(handles.particle.tankCoord(:,2))]));
        maxLim              = max([xMaxAbs yMaxAbs xtankMaxAbs ytankMaxAbs]);

        handles.bndryX      = [-maxLim maxLim];
        handles.bndryY      = [-maxLim maxLim];        
    elseif get(handles.limManual,'Value')
        handles.limScale    = str2double(get(handles.limEdit,'String'));
        handles.bndryX      = handles.limScale*[min(handles.particle.tankCoord(:,1)) max(handles.particle.tankCoord(:,1))];
        handles.bndryY      = handles.limScale*[min(handles.particle.tankCoord(:,2)) max(handles.particle.tankCoord(:,2))];
end

FS_plotOverhead(handles)

guidata(hObject, handles);


% --- Executes when selected object is changed in uipanel19.
function uipanel19_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel19 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
handles.showNone        = get(handles.estNone,'Value');
handles.showPosition    = get(handles.estPosition,'Value');
handles.showAngle       = get(handles.estAngle,'Value');

FS_plotOverhead(handles)

guidata(hObject, handles);


% --- Executes on button press in switchHeat.
function switchHeat_Callback(hObject, eventdata, handles)
% hObject    handle to switchHeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.heatType,'actual')
    handles.heatType = 'theoretical';
    set(handles.switchHeat,'String','Plot Frequency Tracks');
    set(handles.freqPanel,'Title','Theoretical Heatmap');
elseif strcmp(handles.heatType,'theoretical')
    handles.heatType = 'actual';
    set(handles.switchHeat,'String','Plot Theoretical Heat');
    set(handles.freqPanel,'Title','Frequency Tracks');
end

% FS_plotHeat(handles);
FS_plotFreqTrack(handles);

guidata(hObject, handles);

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function selGridButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selGridButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



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

% --- Executes during object creation, after setting all properties.
function stepSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

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


function vidFPS_Callback(hObject, eventdata, handles)
% hObject    handle to vidFPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vidFPS as text
%        str2double(get(hObject,'String')) returns contents of vidFPS as a double


% --- Executes during object creation, after setting all properties.
function vidFPS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vidFPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function limEdit_Callback(hObject, eventdata, handles)
% hObject    handle to limEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of limEdit as text
%        str2double(get(hObject,'String')) returns contents of limEdit as a double


% --- Executes during object creation, after setting all properties.
function limEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to limEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over data_path.
function data_path_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to data_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function numIter_Callback(hObject, eventdata, handles)
% hObject    handle to numIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numIter as text
%        str2double(get(hObject,'String')) returns contents of numIter as a double


% --- Executes during object creation, after setting all properties.
function numIter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function saveFig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uipanel10.
function uipanel10_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel10 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in batchProcess.
function batchProcess_Callback(hObject, eventdata, handles)
% hObject    handle to batchProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of batchProcess


% --- Executes during object creation, after setting all properties.
function push_track_CreateFcn(hObject, eventdata, handles)
% hObject    handle to push_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function uipanel17_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in limManual.
function limManual_Callback(hObject, eventdata, handles)
% hObject    handle to limManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of limManual



% function gridAddr_Callback(hObject, eventdata, handles)
% % hObject    handle to gridAddr (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: get(hObject,'String') returns contents of gridAddr as text
% %        str2double(get(hObject,'String')) returns contents of gridAddr as a double
% 
% 
% % --- Executes during object creation, after setting all properties.
% function gridAddr_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to gridAddr (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% --- Executes on button press in selGridButton.
function selGridButton_Callback(hObject, eventdata, handles)
% hObject    handle to selGridButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.dir_path  = get(handles.data_path, 'String');
[FileName,PathName] = uigetfile(fullfile(handles.dir_path,'*.txt'),'Select grid config file','MultiSelect','off');
if folder_name ~= 0
    set(handles.data_path,'String',folder_name);
    set(handles.data_path,'ToolTipString',['Dataset Directory: ' folder_name]);
    lastFoldAddr = fullfile(fileparts(which('spatialTracking.m')),'lastFold');
    save(lastFoldAddr,'folder_name');
end

% exist lastFoldAddr var

guidata(hObject, handles);


% --- Executes during object deletion, before destroying properties.
function uipanel18_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to uipanel18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
