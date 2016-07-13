function varargout = frequencyTracking(varargin)
% FREQUENCYTRACKING MATLAB code for frequencyTracking.fig
%      FREQUENCYTRACKING, by itself, creates a new FREQUENCYTRACKING or raises the existing
%      singleton*.
%
%      H = FREQUENCYTRACKING returns the handle to a new FREQUENCYTRACKING or the handle to
%      the existing singleton*.
%
%      FREQUENCYTRACKING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FREQUENCYTRACKING.M with the given input arguments.
%
%      FREQUENCYTRACKING('Property','Value',...) creates a new FREQUENCYTRACKING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before frequencyTracking_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to frequencyTracking_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help frequencyTracking

% Last Modified by GUIDE v2.5 12-Jul-2016 22:24:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @frequencyTracking_OpeningFcn, ...
                   'gui_OutputFcn',  @frequencyTracking_OutputFcn, ...
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

% --- Executes just before frequencyTracking is made visible.
function frequencyTracking_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
    % Choose default command line output for frequencyTracking
    handles.output = hObject;    
    clc;
    
    % Add all Mathworks folders
    addpath('../packages/addpath_recurse');
    addpath_recurse('../packages');
    addpath_recurse('.');

    handles = initParams(handles);
    set(handles.log,'String','Ready');  

     % Set selection highlight color in tracksListBox
%     jScrollPane = findjobj(handles.tracksListBox);
%     jListbox = jScrollPane.getViewport.getComponent(0);
%     set(jListbox, 'SelectionBackground',java.awt.Color.yellow); % option #1
    guidata(hObject, handles);
  
% --- Outputs from this function are returned to the command line.
function varargout = frequencyTracking_OutputFcn(~, ~, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;

% --- Executes on button press in specComputeBtn.
function specComputeBtn_Callback(hObject, ~, handles)
    handles = specCompute(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

function nFFTEdit_Callback(hObject, ~, handles)
    num = str2double(get(hObject,'String'));
    if isnan(num)
        num = handles.params.nFFT;
        set(hObject,'String',num2str(num));
        warndlg('Input must be numerical');
    else
        handles.params.nFFT = num;
        idx = find(strcmp(get(handles.specPresetPopup,'String'),'Custom'),1);
        set(handles.specPresetPopup,'Value',idx);
        handles = computeResolutions(handles);
    end
    returnFocus(hObject);
    guidata(hObject,handles);
    
function log_Callback(hObject, ~, handles)
    jhEdit = findjobj(handles.log);
    jEdit = jhEdit.getComponent(0).getComponent(0);
    jEdit.setCaretPosition(jEdit.getDocument.getLength);
    returnFocus(hObject);
    guidata(hObject,handles);    

% --- Executes on edits on the overlap field.
function overlapEdit_Callback(hObject, ~, handles)
    num = str2double(get(hObject,'String'));
    if isnan(num)
        num = handles.params.overlap;
        set(hObject,'String',num2str(num));
        warndlg('Input must be numerical');
    else
        handles.params.overlap = num;
        idx = find(strcmp(get(handles.specPresetPopup,'String'),'Custom'),1);
        set(handles.specPresetPopup,'Value',idx);
        handles = computeResolutions(handles);
    end
    returnFocus(hObject);
    guidata(hObject,handles);

function rangeF1Edit_Callback(hObject, ~, handles)
    num = str2double(get(hObject,'String'));
    if isnan(num)
        num = handles.params.rangeF1;
        set(hObject,'String',num2str(num));
        warndlg('Input must be numerical');
    else
        handles.params.rangeF1 = num;
    end
    if handles.params.rangeF1<handles.params.rangeF2
        handles = refreshPlot(handles);
    end
    returnFocus(hObject);
    guidata(hObject,handles);

function rangeF2Edit_Callback(hObject, ~, handles)
    num = str2double(get(hObject,'String'));
    if isnan(num)
        num = handles.params.rangeF2;
        set(hObject,'String',num2str(num));
        warndlg('Input must be numerical');
    else
        handles.params.rangeF2 = num;
    end
    if handles.params.rangeF1<handles.params.rangeF2
        handles = refreshPlot(handles);
    end
    returnFocus(hObject);
    guidata(hObject,handles);

function rangeT1Edit_Callback(hObject, ~, handles)
    num = str2double(get(hObject,'String'));
    if isnan(num)
        num = handles.params.rangeT1;
        set(hObject,'String',num2str(num));
        warndlg('Input must be numerical');
    else
        handles.params.rangeT1 = num;
    end
    if handles.params.rangeT1<handles.params.rangeT2
        handles = refreshPlot(handles);
    end
    returnFocus(hObject);
    guidata(hObject,handles);

function rangeT2Edit_Callback(hObject, ~, handles)
    num = str2double(get(hObject,'String'));
    if isnan(num)
        num = handles.params.rangeT2;
        set(hObject,'String',num2str(num));
        warndlg('Input must be numerical');
    else
        handles.params.rangeT2 = num;
    end
    if handles.params.rangeT1<handles.params.rangeT2
        handles = refreshPlot(handles);
    end
    returnFocus(hObject);
    guidata(hObject,handles);
    
function minF1Edit_Callback(hObject, ~, handles)
    num = str2double(get(hObject,'String'));
    if isnan(num)
        num = handles.params.minF1;
        warndlg('Input must be numerical');
    else
        if isfield(handles,'spec')
            if num < handles.spec.F(1)
                num = handles.spec.F(1);
            elseif num > handles.spec.F(end)
                num = handles.spec.F(end);
            end
        end
        
        if num > handles.params.maxF1
            num = handles.params.maxF1;
        end
    end       
    handles.params.minF1 = num;
    set(hObject,'String',num2str(num));
    returnFocus(hObject);
    guidata(hObject,handles);

function maxF1Edit_Callback(hObject, ~, handles)
    num = str2double(get(hObject,'String'));
    if isnan(num)
        num = handles.params.maxF1;
        warndlg('Input must be numerical');
    else
        if isfield(handles,'spec')
            if num < handles.spec.F(1)
                num = handles.spec.F(1);
            elseif num > handles.spec.F(end)
                num = handles.spec.F(end);
            end
        end
        
        if num < handles.params.minF1
            num = handles.params.minF1;
        end
    end       
    handles.params.maxF1 = num;
    set(hObject,'String',num2str(num));
    returnFocus(hObject);
    guidata(hObject,handles);


function ratio12Edit_Callback(hObject, ~, handles)
    num = str2double(get(hObject,'String'));
    if isnan(num)
        num = handles.params.ratio12;
        warndlg('Input must be numerical');
    end
    
    handles.params.ratio12 = abs(num);
    set(hObject,'String',num2str(num));
    
    handles = computeThreshold(handles);
    handles = refreshPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);
    
% --- Executes on button press in refreshPlotBtn.
function refreshPlotBtn_Callback(hObject, ~, handles)
    handles = populateTracksList(handles);
    handles = populateChannelList(handles);
    handles = refreshPlot(handles);
    handles = writeLog(handles,'Plot refreshed');
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on slider movement.
function threshSlider_Callback(hObject, ~, handles)
    handles.params.thresh = get(hObject,'Value');
    set(handles.threshEdit,'String',num2str(handles.params.thresh));
    handles = computeThreshold(handles);
    handles = refreshPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on selection change in channelListBox.
function channelListBox_Callback(hObject, ~, handles)
    handles = refreshPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

function prefixEdit_Callback(hObject, ~, handles)    
    handles.params.smrFilePrefix = get(hObject,'String');
    returnFocus(hObject);
    guidata(hObject, handles);
  
% --- Executes on selection change in specPresetPopup.
function specPresetPopup_Callback(hObject, ~, handles)
    strList = get(hObject,'String');
    handles.specPreset = strList{get(hObject,'Value')};
    handles = setSpecPreset(handles);
    handles = computeResolutions(handles);
    handles = writeLog(handles,'Preset "%s" loaded',handles.specPreset);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in loadParamsBtn.
function loadParamsBtn_Callback(hObject, ~, handles)
    [paramsFileName,paramsFilePath,~] = uigetfile('./*.par');
    load(fullfile(paramsFilePath,paramsFileName),'-mat','params');

    handles.params = params;
    handles = setParams(handles);
    
    writeLog(handles,'Loaded params from %s',paramsFileName);
    returnFocus(hObject);
    guidata(hObject, handles);

% --- Executes on button press in saveParamsBtn.
function saveParamsBtn_Callback(hObject, ~, handles)
    [paramsFileName,paramsFilePath] = uiputfile('./*.par');

    params = handles.params; %#ok<NASGU>
    save(fullfile(paramsFilePath,paramsFileName),'params');
    writeLog(handles,'Saved params to %s',paramsFileName);
    returnFocus(hObject);
    guidata(hObject, handles);

% --- Executes on button press in trackBtn.
function trackBtn_Callback(hObject, ~, handles)
    if isfield(handles,'spec')
        tic;
        handles.tracks = findTracks(handles.spec.S,handles.spec.F,handles.spec.T,...
            handles.params.minF1,handles.params.maxF1,handles.params.ratio12,handles.params.thresh);
        runTime = toc;
        
        handles = tracksView(handles);
        handles = refreshPlot(handles);
        handles = populateTracksList(handles);
        set(handles.tracksFileTxt,'String',sprintf('Computed from spectrogram data'));
        handles = writeLog(handles,'Tracked, %d tracks found (%.2f s)',handles.nTracks,runTime);  
    else
        handles = writeLog(handles,'No spectrogram to track');
    end
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in nFFTUpBtn.
function nFFTUpBtn_Callback(hObject, ~, handles)
    handles = nFFTUp(handles);
    handles = computeResolutions(handles);
    returnFocus(hObject);
    guidata(hObject, handles);

% --- Executes on button press in nFFTDnBtn.
function nFFTDnBtn_Callback(hObject, ~, handles)
    handles = nFFTDn(handles);
    handles = computeResolutions(handles);
    returnFocus(hObject);
    guidata(hObject, handles);

% --- Executes on button press in overlapUpBtn.
function overlapUpBtn_Callback(hObject, ~, handles)
    handles = overlapUp(handles);
    handles = computeResolutions(handles);
    returnFocus(hObject);
    guidata(hObject, handles);

% --- Executes on button press in overlapDnBtn.
function overlapDnBtn_Callback(hObject, ~, handles)
    handles = overlapDn(handles);
    handles = computeResolutions(handles);
    returnFocus(hObject);
    guidata(hObject, handles);
    
% --- Executes when selected object is changed in viewChannelsPanel.
function viewChannelsPanel_SelectionChangeFcn(hObject, eventdata, handles)
    handles.params.viewChannel = get(eventdata.NewValue,'String');
    handles = viewChannelsChanged(handles);    
    handles = refreshPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in viewSpectrogramCheck.
function viewSpectrogramCheck_Callback(hObject, ~, handles)
    handles.params.viewSpec = get(hObject,'Value');
    handles = refreshPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in viewTracksCheck.
function viewTracksCheck_Callback(hObject, ~, handles)
    handles.params.viewTracks = get(hObject,'Value');
    handles = refreshPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);
    
% --- Executes when selected object is changed in viewModePanel.
function viewModePanel_SelectionChangeFcn(hObject, eventdata, handles)
    handles.params.viewMode = get(eventdata.NewValue,'String');
    handles = viewModeChanged(handles);
    handles = refreshPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

function threshEdit_Callback(hObject, ~, handles)
    num = str2double(get(hObject,'String'));
    if isnan(num)
        set(hObject,'String',num2str(handles.params.thresh));
        warndlg('Input must be numerical');
    else
        handles.params.thresh = num;
        set(handles.threshSlider,'Value',num);
    end
    handles = computeThreshold(handles);
    handles = refreshPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in printPlotBtn.
function printPlotBtn_Callback(hObject, ~, handles)
    handles = printPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FILE HANDLING CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% --- Executes on button press in loadElecBtn.
function loadElecBtn_Callback(hObject, ~, handles)
    handles = loadElec(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in saveElecBtn.
function saveElecBtn_Callback(hObject, ~, handles)
    handles = saveElec(handles);
    returnFocus(hObject);
    guidata(hObject,handles);
    
% --- Executes on button press in loadSmrBtn.
function loadSmrBtn_Callback(hObject, ~, handles)
    handles = loadSmr(handles);
    returnFocus(hObject);
    guidata(hObject,handles);
    
% --- Executes on button press in loadSpecBtn.
function loadSpecBtn_Callback(hObject, ~, handles)
    handles = loadSpec(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in saveSpecBtn.
function saveSpecBtn_Callback(hObject, ~, handles)
    handles = saveSpec(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in loadTracksBtn.
function loadTracksBtn_Callback(hObject, ~, handles)
    handles = loadTracks(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in saveTracksBtn.
function saveTracksBtn_Callback(hObject, ~, handles)
    handles = saveTracks(handles);
    returnFocus(hObject);
    guidata(hObject,handles);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DATA HANDLING FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in deleteChannelsBtn.
function deleteChannelsBtn_Callback(hObject, ~, handles)
    handles = deleteChannels(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in trimRangeBtn.
function trimRangeBtn_Callback(hObject, ~, handles)
    handles = trimRange(handles);
    handles = writeLog(handles,'Range trimmed');
    returnFocus(hObject);
    guidata(hObject,handles);
    
% --- Executes on button press in clearElecBtn.
function clearElecBtn_Callback(hObject, ~, handles)
    handles = clearElec(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in clearSpecBtn.
function clearSpecBtn_Callback(hObject, ~, handles)
    handles = clearSpec(handles);
    handles = refreshPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in clearTracksBtn.
function clearTracksBtn_Callback(hObject, ~, handles)
    handles = clearTracks(handles);
    handles = refreshPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);
    
% --- Executes on button press in clearAllBtn.
function clearAllBtn_Callback(hObject, ~, handles)
    handles = clearElec(handles);
    handles = clearSpec(handles);
    handles = clearTracks(handles);
    handles = refreshPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);
 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TRACK EDIT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% --- Executes on button press in deleteTracksBtn.
function deleteTracksBtn_Callback(hObject, ~, handles)
    handles = deleteTracksAction(handles);
    returnFocus(hObject);
    guidata(hObject,handles); 

% --- Executes on button press in cleanTracksBtn.
function cleanTracksBtn_Callback(hObject, ~, handles)
    handles = cleanTracksAction(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in interpolateTracksBtn.
function interpolateTracksBtn_Callback(hObject, ~, handles)
    handles = interpolateTracksAction(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in joinTracksBtn.
function joinTracksBtn_Callback(hObject, ~, handles)
    handles = joinTracksAction(handles);
    returnFocus(hObject);
    guidata(hObject,handles); 

% --- Executes on button press in splitTracksBtn.
function splitTracksBtn_Callback(hObject, ~, handles)
    handles = splitTracksAction(handles);
    returnFocus(hObject);
    guidata(hObject,handles); 

% --- Executes on button press in combineTracksBtn.
function combineTracksBtn_Callback(hObject, ~, handles)
    handles = combineTracksAction(handles);
    returnFocus(hObject);
    guidata(hObject,handles); 
    
 % --- Executes on button press in trackHighlightCheck.
function trackHighlightCheck_Callback(hObject, ~, handles)
    handles.params.trackHighlight = get(hObject,'Value');
    handles = refreshPlot(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in newLineBtn.
function newLineBtn_Callback(hObject, ~, handles)
    handles = newLine(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in newPointBtn.
function newPointBtn_Callback(hObject, ~, handles)
    handles = newPoint(handles);
    returnFocus(hObject);
    guidata(hObject,handles);
    
% --- Executes on button press in assignPointsBtn.
function assignPointsBtn_Callback(hObject, ~, handles)
    handles = assignPoints(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in deletePointsBtn.
function deletePointsBtn_Callback(hObject, ~, handles)
    handles = deletePoints(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in newTrackBtn.
function newTrackBtn_Callback(hObject, ~, handles)
    handles = newTrack(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in selectPointsBtn.
function selectPointsBtn_Callback(hObject, ~, handles)
    handles = selectPoints(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in rangeRestoreBtn.
function rangeRestoreBtn_Callback(hObject, ~, handles)
    if isfield(handles,'spec')
        handles = setRanges(handles,handles.spec.F(1),handles.spec.F(end),handles.spec.T(1),handles.spec.T(end));
        handles = refreshPlot(handles);
    end
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on selection change in tracksListBox.
function tracksListBox_Callback(hObject, ~, handles)
    handles = refreshPlot(handles);
    guidata(hObject,handles);
    
% --- Executes on button press in trackSelectBtn.
function trackSelectBtn_Callback(hObject, ~, handles)
    handles = selectTrackAction(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% UNDO AND REDO FUNCTIONALITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in tracksUndoBtn.
function tracksUndoBtn_Callback(hObject, ~, handles)
    handles = undo(handles);
    returnFocus(hObject);
    guidata(hObject,handles);

% --- Executes on button press in tracksRedoBtn.
function tracksRedoBtn_Callback(hObject, ~, handles)
    handles = redo(handles);
    returnFocus(hObject);
    guidata(hObject,handles);   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CREATEFCNS AND OTHER NECESSARY BUT JUNK CODE %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, afte~ setting all properties.
function prefixEdit_CreateFcn(hObject, ~, ~) %#ok<*DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function log_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function specPresetPopup_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function channelListBox_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function rangeF1Edit_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function nFFTEdit_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function tResValTxt_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function fResValTxt_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function overlapEdit_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function rangeF2Edit_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function rangeT1Edit_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function rangeT2Edit_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function threshSlider_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

% --- Executes during object creation, after setting all properties.
function bwThreshEdit_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function threshEdit_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function tracksListBox_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
% --- Executes during object creation, after setting all properties.
function minF1Edit_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
% --- Executes during object creation, after setting all properties.
function maxF1Edit_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function ratio12Edit_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% KEYPRESS CALLBACKS FOR KEYBOARD SHORTCUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on key press with focus on channelListBox and none of its controls.
function channelListBox_KeyPressFcn(hObject, eventdata, handles)
    handles = manageKeyPresses(handles,eventdata);
    guidata(hObject,handles);

% --- Executes on key press with focus on tracksListBox and none of its controls.
function tracksListBox_KeyPressFcn(hObject, eventdata, handles)
    handles = manageKeyPresses(handles,eventdata);
    guidata(hObject,handles);

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
    handles = manageKeyPresses(handles,eventdata);
    guidata(hObject,handles);

% --- Executes on key press with focus on log and none of its controls.
function log_KeyPressFcn(hObject, eventdata, handles)
    handles = manageKeyPresses(handles,eventdata);
    guidata(hObject,handles);
    
 

function returnFocus(hObject)
    set(hObject, 'Enable', 'off');
    drawnow;
    set(hObject, 'Enable', 'on');
