function varargout = fishFinder(varargin)
% FISHFINDER MATLAB code for fishFinder.fig
%      FISHFINDER, by itself, creates a new FISHFINDER or raises the existing
%      singleton*.
%
%      H = FISHFINDER returns the handle to a new FISHFINDER or the handle to
%      the existing singleton*.
%
%      FISHFINDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FISHFINDER.M with the given input arguments.
%
%      FISHFINDER('Property','Value',...) creates a new FISHFINDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fishFinder_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fishFinder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fishFinder

% Last Modified by GUIDE v2.5 03-Mar-2015 10:19:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fishFinder_OpeningFcn, ...
                   'gui_OutputFcn',  @fishFinder_OutputFcn, ...
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

% --- Executes just before fishFinder is made visible.
function fishFinder_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
    % Choose default command line output for fishFinder
    handles.output = hObject;    
    clc;
    
    % Add all Mathworks folders
    addpath('addpath_recurse');
    addpath_recurse('.');

    set(handles.log,'String',{''});
    set(handles.threshSlider,'Min',0.0);
    set(handles.threshSlider,'Max',1.0);
      
    % Undo and redo stacks
    handles.undo = CStack();
    handles.redo = CStack();
  
    % Parameter structure - All the global parameters which can be saved and
    % loaded should go here, and should be set in the function setParams
    handles.params.smrFilePrefix = 'Ch';
    handles.params.nFFT = 32768;
    handles.params.overlap = 0.75;
    handles.params.fRes = 0.1;
    handles.params.tRes = 0.1;
    handles.params.rangeF1 = 0;
    handles.params.rangeF2 = 100;
    handles.params.rangeT1 = 0;
    handles.params.rangeT2 = 1000;
    handles.params.viewMode = 'Normal';
    handles.params.viewChannel = 'Mean';
    handles.params.viewSpec = 1;
    handles.params.viewTracks = 1;
    handles.params.thresh = 0.2;
    handles.params.trackHighlight = 1;

    handles = initParams(handles);
  
    %handles = writeLog(handles,'Ready');
     % Set selection highlight color in tracksListBox
%     jScrollPane = findjobj(handles.tracksListBox);
%     jListbox = jScrollPane.getViewport.getComponent(0);
%     set(jListbox, 'SelectionBackground',java.awt.Color.yellow); % option #1

    guidata(hObject, handles);
  
% --- Outputs from this function are returned to the command line.
function varargout = fishFinder_OutputFcn(~, ~, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in specComputeBtn.
function specComputeBtn_Callback(hObject, ~, handles)
    handles = specCompute(handles);
    guidata(hObject,handles);

function nFFTEdit_Callback(hObject, ~, handles)
    num = str2double(get(hObject,'String'));
    if isnan(num)
        num = handles.params.nFFT;
        set(hObject,'String',num2str(num));
        warndlg('Input must be numerical');
    else
        handles.params.nFFT = num;
    end
    
    handles = computeResolutions(handles);
    idx = find(strcmp(get(handles.specPresetPopup,'String'),'Custom'),1);
    set(handles.specPresetPopup,'Value',idx);
    guidata(hObject,handles);
    
function log_Callback(hObject, ~, handles)
    jhEdit = findjobj(handles.log);
    jEdit = jhEdit.getComponent(0).getComponent(0);
    jEdit.setCaretPosition(jEdit.getDocument.getLength);
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
    end
    
    idx = find(strcmp(get(handles.specPresetPopup,'String'),'Custom'),1);
    set(handles.specPresetPopup,'Value',idx);
    handles = computeResolutions(handles);
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
    handles = refreshPlot(handles);
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
    handles = refreshPlot(handles);
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
    handles = refreshPlot(handles);
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
    handles = refreshPlot(handles);
    guidata(hObject,handles);

% --- Executes on button press in refreshPlotBtn.
function refreshPlotBtn_Callback(hObject, ~, handles)
    handles = populateTracksList(handles);
    handles = populateChannelList(handles);
    handles = refreshPlot(handles);
    handles = writeLog(handles,'Plot refreshed');
    guidata(hObject,handles);

% --- Executes on slider movement.
function threshSlider_Callback(hObject, ~, handles)
    handles.params.thresh = get(hObject,'Value');
    set(handles.threshEdit,'String',num2str(handles.params.thresh));
    handles = computeThreshold(handles);
    handles = refreshPlot(handles);
    guidata(hObject,handles);

% --- Executes on selection change in channelListBox.
function channelListBox_Callback(hObject, ~, handles)
    handles = refreshPlot(handles);
    guidata(hObject,handles);

function prefixEdit_Callback(hObject, ~, handles)    
    handles.params.smrFilePrefix = get(hObject,'String');
    guidata(hObject, handles);
  
% --- Executes on selection change in specPresetPopup.
function specPresetPopup_Callback(hObject, ~, handles)
    strList = get(hObject,'String');
    newStr = strList{get(hObject,'Value')};
    if strcmp(newStr,'Rough')
        handles.params.nFFT = 16384;
        handles.params.overlap = 0.5;
    elseif strcmp(newStr,'Fine')
        handles.params.nFFT = 32768;
        handles.params.overlap = 0.875;
    elseif strcmp(newStr,'Tank')
        handles.params.nFFT = 16384;
        handles.params.overlap = 0.9375;
    end
    
    handles = writeLog(handles,'Preset "%s" loaded',newStr);
    set(handles.nFFTEdit,'String',num2str(handles.params.nFFT));
    set(handles.overlapEdit,'String',num2str(handles.params.overlap));
    handles = computeResolutions(handles);
    guidata(hObject,handles);

% --- Executes on button press in loadParamsBtn.
function loadParamsBtn_Callback(hObject, ~, handles)
    [paramsFileName,paramsFilePath,~] = uigetfile('./*.par');
    load(fullfile(paramsFilePath,paramsFileName),'-mat','params');

    handles.params = params;
    handles = setParams(handles);
    
    writeLog(handles,'Loaded params from %s',paramsFileName);
    guidata(hObject, handles);

% --- Executes on button press in saveParamsBtn.
function saveParamsBtn_Callback(hObject, ~, handles)
    [paramsFileName,paramsFilePath] = uiputfile('./*.par');

    params = handles.params; %#ok<NASGU>
    save(fullfile(paramsFilePath,paramsFileName),'params');
    writeLog(handles,'Saved params to %s',paramsFileName);
    guidata(hObject, handles);

% --- Executes on button press in trackBtn.
function trackBtn_Callback(hObject, ~, handles)
    if isfield(handles,'spec')
        tic;
        handles.tracks = findTracks(handles.spec.S,handles.spec.F,handles.spec.T,handles.params.thresh);
        runTime = toc;
        
        handles = tracksView(handles);
        handles = refreshPlot(handles);
        handles = populateTracksList(handles);
        set(handles.tracksFileTxt,'String',sprintf('Computed from spectrogram data'));
        handles = writeLog(handles,'Tracked, %d tracks found (%.2f s)',handles.nTracks,runTime);  
    else
        handles = writeLog(handles,'No spectrogram to track');
    end
    
    guidata(hObject,handles);

% --- Executes on button press in nFFTUpBtn.
function nFFTUpBtn_Callback(hObject, ~, handles)
    handles = nFFTUp(handles);
    handles = computeResolutions(handles);
    guidata(hObject, handles);

% --- Executes on button press in nFFTDnBtn.
function nFFTDnBtn_Callback(hObject, ~, handles)
    handles = nFFTDn(handles);
    handles = computeResolutions(handles);
    guidata(hObject, handles);

% --- Executes on button press in overlapUpBtn.
function overlapUpBtn_Callback(hObject, ~, handles)
    handles = overlapUp(handles);
    handles = computeResolutions(handles);
    guidata(hObject, handles);

% --- Executes on button press in overlapDnBtn.
function overlapDnBtn_Callback(hObject, ~, handles)
    handles = overlapDn(handles);
    handles = computeResolutions(handles);
    guidata(hObject, handles);
    
% --- Executes when selected object is changed in viewChannelsPanel.
function viewChannelsPanel_SelectionChangeFcn(hObject, eventdata, handles)
    handles.params.viewChannel = get(eventdata.NewValue,'String');
    handles = viewChannelsChanged(handles);    
    guidata(hObject,handles);

% --- Executes on button press in viewSpectrogramCheck.
function viewSpectrogramCheck_Callback(hObject, ~, handles)
    handles.params.viewSpec = get(hObject,'Value');
    handles = refreshPlot(handles);
    guidata(hObject,handles);

% --- Executes on button press in viewTracksCheck.
function viewTracksCheck_Callback(hObject, ~, handles)
    handles.params.viewTracks = get(hObject,'Value');
    handles = refreshPlot(handles);
    guidata(hObject,handles);
    
% --- Executes when selected object is changed in viewModePanel.
function viewModePanel_SelectionChangeFcn(hObject, eventdata, handles)
    handles.params.viewMode = get(eventdata.NewValue,'String');
    handles = viewModeChanged(handles);
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
    guidata(hObject,handles);

% --- Executes on button press in printPlotBtn.
function printPlotBtn_Callback(hObject, ~, handles)
    handles = printPlot(handles);    
    guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FILE HANDLING FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% --- Executes on button press in loadElecBtn.
function loadElecBtn_Callback(hObject, ~, handles)
    handles = loadElec(handles);
    guidata(hObject,handles);

% --- Executes on button press in saveElecBtn.
function saveElecBtn_Callback(hObject, ~, handles)
    handles = saveElec(handles);
    guidata(hObject,handles);
    
% --- Executes on button press in loadSmrBtn.
function loadSmrBtn_Callback(hObject, ~, handles)
    if isfield(handles,'smrFilePath')
        [smrFileName,smrFilePath] = uigetfile([handles.smrFilePath filesep '*.smr'],'Choose smr file');
    elseif isfield(handles,'lastOpenPath')
        [smrFileName,smrFilePath] = uigetfile([handles.lastOpenPath filesep '*.smr'],'Choose smr file');
    else
        [smrFileName,smrFilePath,~] = uigetfile('*.smr','Choose smr file');
    end

    if smrFileName
        try
            tic;
            elec = loadSmrFile(smrFilePath,smrFileName,handles.params.smrFilePrefix);
            runTime = toc;

            % Verify that the loaded data conforms to the rest of the data
            if compareMetaAll(handles,'elec',elec.meta)
                handles = writeLog(handles,'Parsed smr file %s, %d channels loaded. (%.2f s)',smrFileName,elec.meta.nCh,runTime);
                set(handles.elecFileTxt,'String',sprintf('Data from %s',smrFileName));

                handles.smrFileName = smrFileName;
                handles.smrFilePath = smrFilePath;
                handles.lastOpenPath = smrFilePath;
                handles.elec = elec;
                handles.meta = elec.meta;

                handles = setRanges(handles,0,elec.meta.Fs/2,elec.t(1),elec.t(end));
                handles = createSubplots(handles);
                handles = populateChannelList(handles);
                handles = computeResolutions(handles);
            else
                handles = writeLog(handles,'File %s not loaded',smrFileName);
            end
        catch
            handles = writeLog(handles,'Could not load %s (%.2f s)',smrFileName,runTime);
            progressbar(1);
        end      
    end
    guidata(hObject,handles);
    
% --- Executes on button press in loadSpecBtn.
function loadSpecBtn_Callback(hObject, ~, handles)
    if isfield(handles,'specFilePath')
        [specFileName,specFilePath] = uigetfile([handles.specFilePath filesep '*.mat'],'Choose spectrogram file');
    elseif isfield(handles,'lastOpenPath')
        [specFileName,specFilePath] = uigetfile([handles.lastOpenPath filesep '*.mat'],'Choose spectrogram file');
    else
        [specFileName,specFilePath] = uigetfile('*.mat','Choose spectrogram file');
    end
    
    if specFileName
        try
            progressbar('Loading spectrogram data');
            tic;
            load(fullfile(specFilePath,specFileName),'spec');
            spec = hlp_deserialize(spec); %#ok<NODEF>
            runTime = toc;
            progressbar(1);
            
            % Verify that the loaded data conforms to the rest of the data
            if compareMetaAll(handles,'spec',spec.meta)
                set(handles.specFileTxt,'String',specFileName);
                handles.specFileName = specFileName;
                handles.specFilePath = specFilePath;
                handles.lastOpenPath = specFilePath;
                handles.spec = spec;
                handles.meta = spec.meta;

                handles.params.nFFT = spec.meta.nFFT;
                set(handles.nFFTEdit,'String',num2str(spec.meta.nFFT));
                handles.params.overlap = spec.meta.overlap;
                set(handles.overlapEdit,'String',num2str(spec.meta.overlap));
                handles.Smag = normSpecMag(spec.S);

                handles = setRanges(handles,spec.F(1),spec.F(end),spec.T(1),spec.T(end));
                handles = createSubplots(handles);
                handles = populateChannelList(handles);
                handles = computeResolutions(handles);
                handles = computeThreshold(handles);
                handles = refreshPlot(handles);
                handles = writeLog(handles,'Loaded spectrogram file %s (%.2f s)',specFileName,runTime);
            else
                handles = writeLog(handles,'File %s not loaded',specFileName);
            end
        catch
            handles = writeLog(handles,'Could not load %s',specFileName);
            progressbar(1);
        end
    end
    guidata(hObject,handles);

% --- Executes on button press in saveSpecBtn.
function saveSpecBtn_Callback(hObject, ~, handles)
    if isfield(handles,'spec')
        if isfield(handles,'specFileName') && isfield(handles,'specFilePath')
            [specFileName,specFilePath] = uiputfile(fullfile(handles.specFilePath,handles.specFileName),'Save spectrogram as...');
        elseif isfield(handles,'specFilePath')
            [specFileName,specFilePath] = uiputfile([handles.specFilePath filesep '*.mat'],'Save spectrogram as...');
        elseif isfield(handles,'lastOpenPath')
            [specFileName,specFilePath] = uiputfile([handles.lastOpenPath filesep '*.mat'],'Save spectrogram as...');
        else
            [specFileName,specFilePath] = uiputfile('*.mat','Save spectrogram as...');
        end
        
        if specFileName
            progressbar('Saving spectrogram data');
            tic;
            spec = hlp_serialize(handles.spec); %#ok<NASGU>
            savefast(fullfile(specFilePath,specFileName),'spec');
            runTime = toc;
            progressbar(1);

            handles = writeLog(handles,'Saved spectrogram file %s (%.2f s)',specFileName,runTime);
            set(handles.specFileTxt,'String',specFileName);

            handles.specFileName = specFileName;
            handles.specFilePath = specFilePath;
            handles.lastOpenPath = specFilePath;
        end
    else
        handles = writeLog(handles,'No spectrogram data available');
    end
    guidata(hObject,handles);


% --- Executes on button press in loadTracksBtn.
function loadTracksBtn_Callback(hObject, ~, handles)
    if isfield(handles,'tracksFilePath')
        [tracksFileName,tracksFilePath] = uigetfile([handles.tracksFilePath filesep '*.mat'],'Choose tracks file');    
    elseif isfield(handles,'lastOpenPath')
        [tracksFileName,tracksFilePath] = uigetfile([handles.lastOpenPath filesep '*.mat'],'Choose tracks file');    
    else
        [tracksFileName,tracksFilePath] = uigetfile('*.mat','Choose tracks file');
    end
    
    if tracksFileName
        try
            progressbar('Loading tracks data');
            tic;
            load(fullfile(tracksFilePath,tracksFileName),'tracks');
            runTime = toc;
            progressbar(1);
            
            handles.tracksFileName = tracksFileName;
            handles.tracksFilePath = tracksFilePath;
            handles.lastOpenPath = tracksFilePath;
            handles.tracks = tracks;

            handles = refreshPlot(handles);
            handles = populateTracksList(handles);

            handles.undo.empty();
            handles.redo.empty();
            handles = setUndoVisibility(handles);

            set(handles.tracksFileTxt,'String',tracksFileName);
            handles = writeLog(handles,'Loaded data file %s (%.2f s)',tracksFileName,runTime);  
        catch
            handles = writeLog(handles,'Could not load %s (%.2f s)',tracksFileName,runTime);
        end
    end
    guidata(hObject,handles);


% --- Executes on button press in saveTracksBtn.
function saveTracksBtn_Callback(hObject, ~, handles)
    if isfield(handles,'tracks')
        if isfield(handles,'tracksFileName') && isfield(handles,'tracksFilePath')
            [tracksFileName,tracksFilePath] = uiputfile(fullfile(handles.tracksFilePath,handles.tracksFileName),'Save tracks as...');
        elseif isfield(handles,'tracksFilePath')
            [tracksFileName,tracksFilePath] = uiputfile([handles.tracksFilePath filesep '*.mat'],'Save tracks as...');
        elseif isfield(handles,'lastOpenPath')
            [tracksFileName,tracksFilePath] = uiputfile([handles.lastOpenPath filesep '*.mat'],'Save tracks as...');
        else
            [tracksFileName,tracksFilePath] = uiputfile('*.mat','Save tracks as...');
        end

        if tracksFileName
            progressbar('Filling empty data...','Saving tracks data');
            handles.tracks = fillWithNaNs(handles.tracks,handles.spec.T,size(handles.spec.S,3));
            tracks = handles.tracks; %#ok<NASGU>
            tic;
            meta = handles.meta;
            meta.F = handles.spec.F;
            meta.T = handles.spec.T;
            save(fullfile(tracksFilePath,tracksFileName),'tracks','meta');
            runTime = toc;
            progressbar(1,1);

            handles = writeLog(handles,'Saved data file %s (%.2f s)',tracksFileName,runTime);
            set(handles.tracksFileTxt,'String',tracksFileName);

            handles.tracksFileName = tracksFileName;
            handles.tracksFilePath = tracksFilePath;
            handles.lastOpenPath = tracksFilePath;
        end
    else
        handles = writeLog(handles,'No tracks data available');
    end
    guidata(hObject,handles);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DATA HANDLING FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
% --- Executes on button press in deleteChannelsBtn.
function deleteChannelsBtn_Callback(hObject, ~, handles)
    delidx = get(handles.channelListBox,'Value');
    
    handles.meta.chNum(delidx) = [];
    handles.meta.nCh = handles.meta.nCh - length(delidx);
    
    if isfield(handles,'elec')
        handles.elec.data(:,delidx) = [];
        handles.elec.meta = handles.meta;
    end
    
    if isfield(handles,'spec')
        handles.spec.S(:,:,delidx) = [];
        handles.Smag(:,:,delidx) = [];
        handles.Sthresh(:,:,delidx) = [];
        handles.spec.meta = handles.meta;
    end
    
    set(handles.channelListBox,'Value',1);
    handles = createSubplots(handles);
    handles = populateChannelList(handles);
    handles = refreshPlot(handles);
    
    if ~isempty(delidx)
        handles = writeLog(handles,'Channel(s) deleted');
    end
    guidata(hObject,handles);

% --- Executes on button press in trimRangeBtn.
function trimRangeBtn_Callback(hObject, ~, handles)
    if isfield(handles,'elec')
        elec = handles.elec;
        tidx = elec.t>=handles.params.rangeT1 & elec.t<=handles.params.rangeT2;
        elec.t = elec.t(tidx);
        elec.data = elec.data(tidx,:);
        elec.meta.N = length(elec.t);
        
        handles.elec = elec;
        handles.meta = elec.meta;
        handles = computeResolutions(handles);
    end
    
    if isfield(handles,'spec')
        spec = handles.spec;
        tidx = spec.T>=handles.params.rangeT1 & spec.T<=handles.params.rangeT2;
        fidx = spec.F>=handles.params.rangeF1 & spec.F<=handles.params.rangeF2;
        
        spec.T = spec.T(tidx);
        spec.F = spec.F(fidx);
        spec.S = spec.S(fidx,tidx,:);
        spec.meta.N = (handles.params.rangeT2-handles.params.rangeT1)/spec.meta.int;
        
        handles.spec = spec;
        handles.meta = spec.meta;
        handles = computeResolutions(handles);
        handles.Smag = normSpecMag(spec.S);
    end
       
    handles = writeLog(handles,'Range trimmed');
    guidata(hObject,handles);

    
function ret = compareMeta(meta1,meta2)
    fields1 = sort(fieldnames(meta1));
    fields2 = sort(fieldnames(meta2));
    ret = isequal(sort(fields1),sort(fields2));
    
    % Check if both datasets are from the same source file.
    if ret
        if isfield(meta1,'sourceFile')
            if ~strcmp(meta1.sourceFile,meta2.sourceFile)
                ret = 0;
            end
        else
            ret = 0;
        end
    end
    
function ret = compareMetaAll(handles,except,meta)
    ret1 = 1;
    if isfield(handles,'elec') && ~strcmp(except,'elec')
        ret1 = compareMeta(handles.elec.meta,meta);
    end
    
    ret2 = 1;
    if isfield(handles,'spec') && ~strcmp(except,'spec')
        ret2 = compareMeta(handles.spec.meta,meta);
    end
    
    ret = ~any(~[ret1 ret2]);
    if ~ret
        handles = writeLog(handles,'Data is not from the same source');
    end

% --- Executes on button press in clearElecBtn.
function clearElecBtn_Callback(hObject, ~, handles)
    handles = clearElec(handles);
    guidata(hObject,handles);

% --- Executes on button press in clearSpecBtn.
function clearSpecBtn_Callback(hObject, ~, handles)
    handles = clearSpec(handles);
    guidata(hObject,handles);

% --- Executes on button press in clearTracksBtn.
function clearTracksBtn_Callback(hObject, ~, handles)
    handles = clearTracks(handles);
    handles = refreshPlot(handles);
    handles = populateTracksList(handles);
    guidata(hObject,handles);
    
% --- Executes on button press in clearAllBtn.
function clearAllBtn_Callback(hObject, ~, handles)
    handles = clearElec(handles);
    handles = clearSpec(handles);
    handles = clearTracks(handles);
    handles = refreshPlot(handles);
    handles = populateChannelList(handles);
    handles = populateTracksList(handles);
    guidata(hObject,handles);
 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TRACK EDIT FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% --- Executes on button press in deleteTracksBtn.
function deleteTracksBtn_Callback(hObject, ~, handles)
    handles = deleteTracksAction(handles);
    guidata(hObject,handles); 

% --- Executes on button press in cleanTracksBtn.
function cleanTracksBtn_Callback(hObject, ~, handles)
    handles = cleanTracksAction(handles);
    guidata(hObject,handles); 

% --- Executes on button press in joinTracksBtn.
function joinTracksBtn_Callback(hObject, ~, handles)
    handles = joinTracksAction(handles);
    guidata(hObject,handles); 

% --- Executes on button press in splitTracksBtn.
function splitTracksBtn_Callback(hObject, ~, handles)
    handles = splitTracksAction(handles);
    guidata(hObject,handles); 
    
 % --- Executes on button press in trackHighlightCheck.
function trackHighlightCheck_Callback(hObject, ~, handles)
    handles.params.trackHighlight = get(hObject,'Value');
    handles = refreshPlot(handles);
    guidata(hObject,handles);

% --- Executes on button press in newLineBtn.
function newLineBtn_Callback(hObject, ~, handles)
     handles = newLine(handles);
    guidata(hObject,handles);

% --- Executes on button press in newPointBtn.
function newPointBtn_Callback(hObject, ~, handles)
     handles = newPoint(handles);
    guidata(hObject,handles);
    
% --- Executes on button press in assignPointsBtn.
function assignPointsBtn_Callback(hObject, ~, handles)
    handles = assignPoints(handles);
    guidata(hObject,handles);

% --- Executes on button press in deletePointsBtn.
function deletePointsBtn_Callback(hObject, ~, handles)
    handles = deletePoints(handles);
    guidata(hObject,handles);

% --- Executes on button press in newTrackBtn.
function newTrackBtn_Callback(hObject, ~, handles)
    handles = newTrack(handles);
    guidata(hObject,handles);

% --- Executes on button press in selectPointsBtn.
function selectPointsBtn_Callback(hObject, ~, handles)
    handles = selectPoints(handles);
    guidata(hObject,handles);

% --- Executes on button press in constCheckBox.
function constCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to constCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of constCheckBox

% --- Executes on button press in rangeRestoreBtn.
function rangeRestoreBtn_Callback(hObject, ~, handles)
    if isfield(handles,'spec')
        handles = setRanges(handles,handles.spec.F(1),handles.spec.F(end),handles.spec.T(1),handles.spec.T(end));
        handles = refreshPlot(handles);
    end
    guidata(hObject,handles);

% --- Executes on selection change in tracksListBox.
function tracksListBox_Callback(hObject, ~, handles)
    handles = refreshPlot(handles);
    guidata(hObject,handles);
    
% --- Executes on button press in trackSelectBtn.
function trackSelectBtn_Callback(hObject, ~, handles)
    handles = selectTrackAction(handles);
    guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% UNDO AND REDO FUNCTIONALITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in tracksUndoBtn.
function tracksUndoBtn_Callback(hObject, ~, handles)
    handles = undo(handles);
    guidata(hObject,handles);

% --- Executes on button press in tracksRedoBtn.
function tracksRedoBtn_Callback(hObject, ~, handles)
    handles = redo(handles);
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