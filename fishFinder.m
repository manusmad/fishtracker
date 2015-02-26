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

% Last Modified by GUIDE v2.5 26-Feb-2015 12:37:55

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
  
function handles = initParams(handles)
    set(handles.prefixEdit,'String',handles.params.smrFilePrefix);
    set(handles.nFFTEdit,'String',num2str(handles.params.nFFT));
    set(handles.overlapEdit,'String',num2str(handles.params.overlap));
    set(handles.fResValTxt,'String',num2str(handles.params.fRes));
    set(handles.tResValTxt,'String',num2str(handles.params.tRes));
    set(handles.rangeF1Edit,'String',num2str(handles.params.rangeF1));
    set(handles.rangeF2Edit,'String',num2str(handles.params.rangeF2));
    set(handles.rangeT1Edit,'String',num2str(handles.params.rangeT1));
    set(handles.rangeT2Edit,'String',num2str(handles.params.rangeT2));
    
    if strcmp(handles.params.viewMode,'Threshold')
        set(handles.threshSlider,'Visible','on');
        set(handles.threshEdit,'Visible','on');
    else
        set(handles.threshSlider,'Visible','off');
        set(handles.threshEdit,'Visible','off');
    end
    set(handles.threshSlider,'Value',handles.params.thresh);
    set(handles.threshEdit,'String',num2str(handles.params.thresh));

    
    if strcmp(handles.params.viewChannel,'Single') || strcmp(handles.params.viewChannel,'Mean')
        set(handles.singlePlotPanel,'Visible','on');
        set(handles.multiPlotPanel,'Visible','off');
    else
        set(handles.singlePlotPanel,'Visible','off');
        set(handles.multiPlotPanel,'Visible','on');
    end
    
    set(handles.viewSpectrogramCheck,'Value',handles.params.viewSpec);
    set(handles.viewTracksCheck,'Value',handles.params.viewTracks);
    set(handles.trackHighlightCheck,'Value',handles.params.trackHighlight);
    
    idx = find(strcmp(get(handles.specPresetPopup,'String'),'Custom'),1);
    set(handles.specPresetPopup,'Value',idx);
    
    handles = computeResolutions(handles);
    handles = setUndoVisibility(handles);
    
% --- Outputs from this function are returned to the command line.
function varargout = fishFinder_OutputFcn(~, ~, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Function to populate the channel list box and clear the enable
% selections.
function handles = populateChannelList(handles)
    if isfield(handles,'meta')
        list = cell(handles.meta.nCh,1);
        for k = 1:handles.meta.nCh
            list{k} = sprintf('%s %02d',handles.meta.chPrefix,handles.meta.chNum(k));
        end
        set(handles.channelListBox,'String',list);
    else
        set(handles.channelListBox,'String','Channel list');
    end
    
function handles = populateTracksList(handles)
    if isfield(handles,'tracks')
        ids = unique([handles.tracks.id]);
        handles.nTracks = length(ids);
        list = cell(handles.nTracks,1);
        col = distinguishable_colors(handles.nTracks,{'r','k','y'});
        
        for k = 1:handles.nTracks
            coltag = reshape(dec2hex(round(col(k,:)*255))',1,6);           
            list{k} = sprintf('<html><body bgcolor="%s">Track %02d</body></html>',coltag,ids(k));
        end
        set(handles.tracksListBox,'String',list);
        set(handles.tracksListBox,'ListboxTop',handles.nTracks);
        
        selTrack = get(handles.tracksListBox,'Value');
        if selTrack>handles.nTracks
            set(handles.tracksListBox,'Value',handles.nTracks);
        end
        
        set(handles.nTracksTxt,'String',num2str(handles.nTracks));
    else
        set(handles.channelListBox,'String','Tracks list');
        set(handles.nTracksTxt,'String','0');
    end

% Function to create appropriate subplots
function handles = createSubplots(handles)
    if isfield(handles,'meta')
        nCh = handles.meta.nCh;
    else
        nCh=0;
    end
    
    if nCh
        if isfield(handles,'hSub')
            delete(handles.hSub);
            handles = rmfield(handles,'hSub');
        end
        handles.hSub = zeros(nCh,1);
        
        n = ceil(sqrt(nCh));
        margin = 0.02;
        w = (1 - (n+1)*margin)/n;
        h = (1 - (n+1)*margin)/n;
        
        for k = 1:nCh
            [r,c] = find(~(flipud(reshape(1:n^2,n,n)')-k),1);
            handles.hSub(k) = axes('Parent',handles.multiPlotPanel,...
                'Position',[c*margin + (c-1)*w, r*margin + (r-1)*h, w,h]);
            if r~=1 || c~=1
                set(handles.hSub(k),'XTick',[],'YTick',[]);
            end
        end        
    end
            
% Function to set ranges based on edited values of F1,F2,T1,T2
function handles = setRanges(handles,F1,F2,T1,T2)
    handles.params.rangeF1 = F1;
    handles.params.rangeF2 = F2;
    handles.params.rangeT1 = T1;
    handles.params.rangeT2 = T2;
    
    set(handles.rangeF1Edit,'String',num2str(F1));
    set(handles.rangeF2Edit,'String',num2str(F2));
    set(handles.rangeT1Edit,'String',num2str(T1));
    set(handles.rangeT2Edit,'String',num2str(T2));

% --- Executes on button press in specComputeBtn.
function specComputeBtn_Callback(hObject, ~, handles)
    if isfield(handles,'elec')
        tic;
        spec = specFullFile(handles.elec,handles.params.nFFT,handles.params.overlap);
        spec.meta.nFFT = handles.params.nFFT;
        spec.meta.overlap = handles.params.overlap;
        handles.Smag = normSpecMag(spec.S);

        runTime = toc;
        handles.spec = spec;
        handles = setRanges(handles,spec.F(1),spec.F(end),spec.T(1),spec.T(end));
        handles = refreshPlot(handles);
        set(handles.specFileTxt,'String',sprintf('Computed from electode data'));
        handles = writeLog(handles,'Spectrogram computed (%.2f s)',runTime);
    end
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
    
function handles = writeLog(handles,str,varargin)
    logStr = get(handles.log,'String');
    if ~iscell(logStr)
        logStr = {logStr};
    end
    nLines = length(logStr);
    if (nLines+1) >= get(handles.log,'Max');
        logStr = logStr(2:end);
    end

    if ~isempty(varargin)
        str = sprintf(str,varargin{:});
    end
    
    logStr = [logStr ; str];
    set(handles.log,'String',logStr);
    
     jhEdit = findjobj(handles.log);
     jEdit = jhEdit.getComponent(0).getComponent(0);
     jEdit.setCaretPosition(jEdit.getDocument.getLength);

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

function handles = refreshPlot(handles)
    plotFlag = 0;
    % Clear selections
    if isfield(handles,'hPoly');
        handles = rmfield(handles,'hPoly');
    end
    
    if isfield(handles,'meta')
        if strcmp(handles.params.viewMode,'Threshold')
            axes(handles.hSingle);
            cla(handles.hSingle);
            hold(handles.hSingle,'on');

            if isfield(handles,'spec')
                if strcmp(handles.params.viewChannel,'Single')
                    chan = get(handles.channelListBox,'Value');
                    chan = chan(1);
                    cla(handles.hSingle);
                    [plotFlag,handles.hSpec] = plotSpectrogram(handles.hSingle,handles.spec.T,handles.spec.F,handles.Smag(:,:,chan)>handles.params.thresh);
                elseif strcmp(handles.params.viewChannel,'Mean')
                    cla(handles.hSingle);
                    [plotFlag,handles.hSpec] = plotSpectrogram(handles.hSingle,handles.spec.T,handles.spec.F,mean(handles.Smag,3)>handles.params.thresh);
                elseif strcmp(handles.params.viewChannel,'All')
                    for k = 1:handles.meta.nCh      % For each channel
                        cla(handles.hSub(k));
                        [plotFlag,handles.hSpec] = plotSpectrogram(handles.hSub(k),handles.spec.T,handles.spec.F,handles.Smag(:,:,k)>handles.params.thresh);
                    end
                    
                    % Indicate elected
                    chan = get(handles.channelListBox,'Value');
                    for k = 1:length(chan)
                        x = get(handles.hSub(chan(k)),'XLim');
                        y = get(handles.hSub(chan(k)),'YLim');
                        hold(handles.hSub(chan(k)),'on');
                        plot(handles.hSub(chan(k)),[x(1) x(2) x(2) x(1) x(1)],[y(1) y(1) y(2) y(2) y(1)],'-y','LineWidth',5);
                        hold(handles.hSub(chan(k)),'off');
                    end                    
                end
            end

            axis(handles.hSingle,...
                [handles.params.rangeT1,handles.params.rangeT2, ...
                handles.params.rangeF1,handles.params.rangeF2]);
            hold(handles.hSingle,'off');

        elseif strcmp(handles.params.viewMode,'Normal')

            % Single channel
            if strcmp(handles.params.viewChannel,'Single')
                cla(handles.hSingle);
                hold(handles.hSingle,'on');

                % Plot spectrogram
                if handles.params.viewSpec && isfield(handles,'spec')
                    chan = get(handles.channelListBox,'Value');
                    chan = chan(1);
                    [plotFlag,handles.hSpec] = plotSpectrogram(handles.hSingle,handles.spec.T,handles.spec.F,handles.Smag(:,:,chan));
                end

                % Plot tracks
                if handles.params.viewTracks && isfield(handles,'tracks')
                    if handles.params.trackHighlight
                        selTracks = get(handles.tracksListBox,'Value');
                    else
                        selTracks = [];
                    end
                    [plotFlag,handles.hTracks] = plotTracks(handles.hSingle,handles.tracks,selTracks);
                end

                axis(handles.hSingle,...
                    [handles.params.rangeT1,handles.params.rangeT2, ...
                    handles.params.rangeF1,handles.params.rangeF2]);
                hold(handles.hSingle,'off');

            elseif strcmp(handles.params.viewChannel,'Mean')
                cla(handles.hSingle);
                hold(handles.hSingle,'on');

                % Plot spectrogram
                if handles.params.viewSpec && isfield(handles,'spec')
                    [plotFlag,handles.hSpec] = plotSpectrogram(handles.hSingle,handles.spec.T,handles.spec.F,mean(handles.Smag,3));
                end

                % Plot tracks
                if handles.params.viewTracks  && isfield(handles,'tracks')
                    if handles.params.trackHighlight
                        selTracks = get(handles.tracksListBox,'Value');
                    else
                        selTracks = [];
                    end
                    [plotFlag,handles.hTracks] = plotTracks(handles.hSingle,handles.tracks,selTracks);
                end

                axis(handles.hSingle,...
                    [handles.params.rangeT1,handles.params.rangeT2, ...
                    handles.params.rangeF1,handles.params.rangeF2]);
                hold(handles.hSingle,'off');    

            elseif strcmp(handles.params.viewChannel,'All')
                for k = 1:handles.meta.nCh      % For each channel
                    cla(handles.hSub(k));
                    hold(handles.hSub(k),'on');

                    % Plot spectrogram
                    if handles.params.viewSpec && isfield(handles,'spec')
                        [plotFlag,handles.hSpec] = plotSpectrogram(handles.hSub(k),handles.spec.T,handles.spec.F,handles.Smag(:,:,k));
                        
                        % Set callback function for image clicking
                        set(handles.hSpec,'ButtonDownFcn',{@subFigClickCallBack,handles});
                    end

                    % Plot tracks
                    if handles.params.viewTracks && isfield(handles,'tracks')
                        if handles.params.trackHighlight
                            selTracks = get(handles.tracksListBox,'Value');
                        else
                            selTracks = [];
                        end
                        [plotFlag,handles.hTracks] = plotTracks(handles.hSub(k),handles.tracks,selTracks);
                    end

                    axis(handles.hSub(k),...
                    [handles.params.rangeT1,handles.params.rangeT2, ...
                    handles.params.rangeF1,handles.params.rangeF2]);
                    hold(handles.hSub(k),'off');
                end
                
                % Indicate selected
                chan = get(handles.channelListBox,'Value');
                for k = 1:length(chan)
                    x = get(handles.hSub(chan(k)),'XLim');
                    y = get(handles.hSub(chan(k)),'YLim');
                    hold(handles.hSub(chan(k)),'on');
                    plot(handles.hSub(chan(k)),[x(1) x(2) x(2) x(1) x(1)],[y(1) y(1) y(2) y(2) y(1)],'-y','LineWidth',5);
                    hold(handles.hSub(chan(k)),'off');
                end
            end
        end
    else
        set(handles.singlePlotPanel,'Visible','on');
        set(handles.multiPlotPanel,'Visible','off');
        axes(handles.hSingle);
        cla(handles.hSingle);
    end
    
    if ~plotFlag
        handles = writeLog(handles,'Nothing to refresh');
    end
      
% --- Executes on slider movement.
function threshSlider_Callback(hObject, ~, handles)
    handles.params.thresh = get(hObject,'Value');
    set(handles.threshEdit,'String',num2str(handles.params.thresh));
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

    params = handles.params;
    save(fullfile(paramsFilePath,paramsFileName),'params');
    writeLog(handles,'Saved params to %s',paramsFileName);
    guidata(hObject, handles);

% --- Executes on button press in trackBtn.
function trackBtn_Callback(hObject, ~, handles)
    if isfield(handles,'spec')
        tic;
        handles = tracksView(handles);
        handles.tracks = findTracks(handles.spec.S,handles.spec.F,handles.spec.T,handles.params.thresh);
        runTime = toc;
        
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
    nfft = handles.params.nFFT;    
    npow2 = 2^nextpow2(nfft);
    if npow2 == nfft
        nfft = nfft*2;
    else
        nfft = npow2;
    end
   
    handles.params.nFFT = nfft;
    set(handles.nFFTEdit,'String',num2str(nfft));
    handles = computeResolutions(handles);
    guidata(hObject, handles);

% --- Executes on button press in nFFTDnBtn.
function nFFTDnBtn_Callback(hObject, ~, handles)
    nfft = handles.params.nFFT;
    npow2 = 2^nextpow2(nfft);
    if npow2 == nfft
        nfft = nfft/2;
    else
        nfft = npow2/2;
    end
    
    handles.params.nFFT = nfft;
    set(handles.nFFTEdit,'String',num2str(nfft));
    handles = computeResolutions(handles);
    guidata(hObject, handles);


% --- Executes on button press in overlapUpBtn.
function overlapUpBtn_Callback(hObject, ~, handles)
    overlap = handles.params.overlap;
    overlap = 1/(1-overlap);
    npow2 = 2^nextpow2(overlap);
    
    if npow2 == overlap
        overlap = overlap*2;
    else
        overlap = npow2;
    end
    
    overlap = 1 - 1/overlap;
    handles.params.overlap = overlap;
    set(handles.overlapEdit,'String',num2str(overlap));
    handles = computeResolutions(handles);
    guidata(hObject, handles);

% --- Executes on button press in overlapDnBtn.
function overlapDnBtn_Callback(hObject, ~, handles)
    overlap = handles.params.overlap;
    overlap = 1/(1-overlap);
    npow2 = 2^nextpow2(overlap);
    
    if npow2 == overlap
        overlap = overlap/2;
    else
        overlap = npow2/2;
    end
    
    overlap = 1 - 1/overlap;
    handles.params.overlap = overlap;
    set(handles.overlapEdit,'String',num2str(overlap));
    handles = computeResolutions(handles);
    guidata(hObject, handles);

function handles = computeResolutions(handles)
    if isfield(handles,'meta')
        nFFT = handles.params.nFFT;
        overlap = handles.params.overlap;

        nF = floor(handles.params.nFFT/2)+1;
        Fres = handles.meta.Fs / (2*nF);
        nT = fix((handles.meta.N-nFFT*overlap)/(nFFT*(1-overlap)));
        Tres = handles.meta.int*handles.meta.N / nT;
        
        set(handles.fResValTxt,'String',sprintf('%.2f',Fres));
        set(handles.tResValTxt,'String',sprintf('%.2f',Tres));
    else
        set(handles.fResValTxt,'String','[  ]');
        set(handles.tResValTxt,'String','[  ]');
    end    
    
% --- Executes when selected object is changed in viewChannelsPanel.
function viewChannelsPanel_SelectionChangeFcn(hObject, eventdata, handles)
    viewChannel = get(eventdata.NewValue,'String');
    
    if strcmp(viewChannel,'Single') || strcmp(viewChannel,'Mean')
        set(handles.singlePlotPanel,'Visible','on');
        set(handles.multiPlotPanel,'Visible','off');
    elseif strcmp(viewChannel,'All')
        set(handles.singlePlotPanel,'Visible','off');
        set(handles.multiPlotPanel,'Visible','on');
    end
     
    handles.params.viewChannel = viewChannel;
    handles = refreshPlot(handles);
    guidata(hObject,handles);


% --- Executes on button press in viewSpectrogramCheck.
function viewSpectrogramCheck_Callback(hObject, eventdata, handles)
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
    if strcmp(handles.params.viewMode,'Threshold')
        set(handles.threshSlider,'Visible','on');
        set(handles.threshEdit,'Visible','on');
        set(handles.viewChoosePanel,'Visible','off');
    else
        set(handles.threshSlider,'Visible','off');
        set(handles.threshEdit,'Visible','off');
        set(handles.viewChoosePanel,'Visible','on');
    end
    
    handles = refreshPlot(handles);
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
    
    guidata(hObject,handles);

% --- Executes on button press in printPlotBtn.
function printPlotBtn_Callback(hObject, ~, handles)
    defFileName = [];
    if isfield(handles,'specFileName')
        [~,temp,~] = fileparts(handles.specFileName);
        defFileName = [defFileName temp];
    end
    if isfield(handles,'tracksFileName')
        [~,temp,~] = fileparts(handles.tracksFileName);
        defFileName = [defFileName '_' temp];
    end
    
    [fileName,pathName] = uiputfile([defFileName '.pdf']);
    try
        if strcmp(get(handles.singlePlotPanel,'Visible'),'on')
            export_fig(handles.hSingle,fullfile(pathName,fileName));
            handles = writeLog(handles,'Printed to %s',fileName);
        else
            for k = 1:length(handles.hSub)
                export_fig(handles.hSub(k),fullfile(pathName,sprintf('%d_%s',k,fileName)));
            end
            handles = writeLog(handles,'Printed all to k_%s',fileName);
        end
    catch
        handles = writeLog(handles,'Error printing to %s',fileName);
    end
    
    guidata(hObject,handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FILE HANDLING FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% --- Executes on button press in loadElecBtn.
function loadElecBtn_Callback(hObject, ~, handles)
    if isfield(handles,'elecFilePath')
        [elecFileName,elecFilePath] = uigetfile([handles.elecFilePath filesep '*.mat'],'Choose electrode data file');
    elseif isfield(handles,'lastOpenPath')
        [elecFileName,elecFilePath] = uigetfile([handles.lastOpenPath filesep '*.mat'],'Choose electrode data file');
    else
        [elecFileName,elecFilePath] = uigetfile('*.mat','Choose electrode data file');
    end
    
    if elecFileName
        try
            progressbar('Loading electrode data');
            tic;
            load(fullfile(elecFilePath,elecFileName),'elec');
            runTime = toc;
            progressbar(1);

            if ~isfield(elec,'meta')
                elec2 = elec;
                clear elec;
                fnames = fieldnames(elec2);
                for f = 1:length(fnames)
                    if any(strcmp(fnames{f},{'data','t'}))
                        elec.(fnames{f}) = elec2.(fnames{f});
                    else
                        elec.meta.(fnames{f}) = elec2.(fnames{f});
                    end
                end
            end

            if ~isfield(elec.meta,'nCh')
                elec.meta.nCh = length(elec.data,2);
            end
            if ~isfield(elec.meta,'N')
                elec.meta.N = length(elec.t);
            end
            if ~isfield(elec.meta,'chNum')
                elec.meta.chNum = 1:elec.meta.nCh;
            end
            if ~isfield(elec.meta,'chPrefix')
                elec.meta.chPrefix = 'Ch';
            end
            if ~isfield(elec.meta,'sourceFile')
                elec.meta.sourceFile = elecFileName;
            end

            handles.elecFileName = elecFileName;
            handles.elecFilePath = elecFilePath;
            handles.lastOpenPath = elecFilePath;
            handles.elec = elec;

            handles.meta = elec.meta;
            handles = setRanges(handles,0,elec.meta.Fs/2,elec.t(1),elec.t(end));
            handles = createSubplots(handles);
            handles = populateChannelList(handles);
            handles = computeResolutions(handles);

            set(handles.elecFileTxt,'String',elecFileName);
            handles = writeLog(handles,'Loaded data file %s (%.2f s)',elecFileName,runTime);
        catch
            handles = writeLog(handles,'Could not load %s (%.2f s)',elecFileName,runTime);
            progressbar(1);
        end
    end
    guidata(hObject,handles);

% --- Executes on button press in saveElecBtn.
function saveElecBtn_Callback(hObject, ~, handles)
    if isfield(handles,'elec')
        if isfield(handles,'elecFileName') && isfield(handles,'elecFilePath')
            [elecFileName,elecFilePath] = uiputfile(fullfile(handles.elecFilePath,handles.elecFileName),'Save electrode data as...');
        elseif isfield(handles,'elecFilePath')
            [elecFileName,elecFilePath] = uiputfile([handles.elecFilePath filesep '*.mat'],'Save electrode data as...');
        elseif isfield(handles,'lastOpenPath')
            [elecFileName,elecFilePath] = uiputfile([handles.lastOpenPath filesep '*.mat'],'Save electrode data as...');
        else
            [elecFileName,elecFilePath] = uiputfile('*.mat','Save electrode data as...');
        end
        
        if elecFileName
            elec = handles.elec;
            tic;
            savefast(fullfile(elecFilePath,elecFileName),'elec');
            runTime = toc;

            handles = writeLog(handles,'Saved data file %s (%.2f s)',elecFileName,runTime);
            set(handles.elecFileTxt,'String',elecFileName);

            handles.elecFileName = elecFileName;
            handles.elecFilePath = elecFilePath;
            handles.lastOpenPath = elecFilePath;
        end
    else
        handles = writeLog(handles,'No electrode data loaded');
    end
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
            spec = hlp_deserialize(spec);
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
            spec = hlp_serialize(handles.spec);
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
            tracks = handles.tracks;
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

function handles = clearElec(handles)
    if isfield(handles,'elec')
        handles = rmfield(handles,'elec');
        if isfield(handles,'elecFileName')
            handles = rmfield(handles,'elecFileName');
        end
        set(handles.elecFileTxt,'String','<None>');
        handles = writeLog(handles,'Cleared electrode data');
        
        if isfield(handles,'spec')
            handles.meta = handles.spec.meta;
        else
            handles = rmfield(handles,'meta');
        end
        
        handles = populateChannelList(handles);
    else
        handles = writeLog(handles,'No electrode data to clear');
    end

% --- Executes on button press in clearSpecBtn.
function clearSpecBtn_Callback(hObject, ~, handles)
    handles = clearSpec(handles);
    guidata(hObject,handles);

function handles = clearSpec(handles)
    if isfield(handles,'spec')
        handles = rmfield(handles,'spec');
        if isfield(handles,'specFileName')
            handles = rmfield(handles,'specFileName');
        end
        set(handles.specFileTxt,'String','<None>');
        handles = writeLog(handles,'Cleared spectrogram data');
         
        if isfield(handles,'elec')
            handles.meta = handles.elec.meta;
        else
            handles = rmfield(handles,'meta');
        end
        
        handles = populateChannelList(handles);
    else
        handles = writeLog(handles,'No spectrogram data to clear');
    end
    

% --- Executes on button press in clearTracksBtn.
function clearTracksBtn_Callback(hObject, ~, handles)
    handles = clearTracks(handles);
    handles = refreshPlot(handles);
    handles = populateTracksList(handles);
    guidata(hObject,handles);
    
function handles = clearTracks(handles) 
    if isfield(handles,'tracks')
        handles = rmfield(handles,'tracks');
        if isfield(handles,'tracksFileName')
            handles = rmfield(handles,'tracksFileName');
        end
        set(handles.tracksFileTxt,'String','<None>');
        handles.undo.empty();
        handles.redo.empty();
        handles = setUndoVisibility(handles);
        
        handles = writeLog(handles,'Cleared tracks data');
    else
        handles = writeLog(handles,'No tracks data to clear');
    end
    
    

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

% Function to join two tracks
function [handles,id1] = joinTracks(handles,id1,time1,id2,time2)
    if time1>time2
        % Swap
        temp = id2; id2 = id1; id1 = temp;
        temp = time2; time2 = time1; time1 = temp;
    end

    idx1 = find([handles.tracks.id]==id1 & [handles.tracks.t]==time1,1);
    idx2 = find([handles.tracks.id]==id2 & [handles.tracks.t]==time2,1);
    
    if id1 == id2
        [handles,id12] = splitTrack(handles,id1,time1);
        [handles,~] = splitTrack(handles,id12,time2,id1);
    else
        % Split both tracks at the clicked points
        [handles,id12] = splitTrack(handles,id1,time1);
        [handles,~] = splitTrack(handles,id2,time2,id1);
    end
    
    handles.tracks(idx1).id = id1;
    handles.tracks(idx2).id = id1;
    
%     handles = deleteTrack(handles,id12);
%     handles = deleteTrack(handles,id2);

% Function to find out which id the (time, freq) point belongs to
function [handles,matchid] = matchTrack(handles,time,freq)
    [~,idx] = min(pdist2([ [handles.tracks.t]' [handles.tracks.f1]' ],[time freq]));
    matchid = handles.tracks(idx).id;

% Function to delete a track
function handles = deleteTrack(handles,id)
    handles.tracks([handles.tracks.id]==id) = [];
    handles = populateTracksList(handles);
    % If all tracks are deleted, 
    if handles.nTracks==0
        handles = rmfield(handles,'tracks');
    end
    
% Function to split track of fish given id and time to split
function [handles,newId] = splitTrack(handles,id,time,newId)
    if nargin<4
        newId = max(unique([handles.tracks.id])) + 1;
    end
    
    idx = [handles.tracks.id]==id & [handles.tracks.t]>time;
    if any(idx)
        [handles.tracks(idx).id] = deal(newId);
    end   
    handles = populateTracksList(handles);
    
% Function to 'clean' tracks, i.e. delete tracks of length<2
function [handles,del] = cleanTracks(handles)
    ids = unique([handles.tracks.id]);
    del = 0;
    for id = ids
        track = handles.tracks([handles.tracks.id]==id);
        lTrack = length(track);
   
        if lTrack<=10
            handles = deleteTrack(handles,id);
            del = del+1;
        end
    end
    
% Makes sure the view is optimal for tracks selection and deletion (Single
% axis, normal view mode)
function handles = tracksView(handles)
    if ~strcmp(handles.params.viewMode,'Normal')
        oldsel = get(handles.viewModePanel, 'SelectedObject');
        newsel = handles.viewNormalRadioBtn;
        set(handles.viewModePanel,'SelectedObject',newsel)
        fakeEvent = struct('EventName', 'SelectionChanged', ...
           'OldValue', oldsel, ...
           'NewValue', newsel);
        viewModePanel_SelectionChangeFcn(handles.viewModePanel, fakeEvent, handles);
    end
    
    if strcmp(handles.params.viewChannel,'All')
        oldsel = get(handles.viewChannelsPanel, 'SelectedObject');
        newsel = handles.viewSingleRadioBtn;
        set(handles.viewChannelsPanel,'SelectedObject',newsel)
        fakeEvent = struct('EventName', 'SelectionChanged', ...
           'OldValue', oldsel, ...
           'NewValue', newsel);
        viewChannelsPanel_SelectionChangeFcn(handles.viewChannelsPanel, fakeEvent, handles);
    end
    
    
% --- Executes on button press in deleteTracksBtn.
function deleteTracksBtn_Callback(hObject, ~, handles)
    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        handles = writeLog(handles,'Select track to delete (Right click to cancel)');
        
        [time,freq] = MagnetGInput2(handles.hTracks,true);
        
        if ~isempty(time)
            [handles,id] = matchTrack(handles,time,freq);
            handles = deleteTrack(handles,id);
            
            handles = refreshPlot(handles);
            handles = writeLog(handles,'Track %d deleted',id);
        else
            handles = writeLog(handles,'Delete cancelled');
        end
    else
        handles = writeLog(handles,'No tracks to delete');
    end
    guidata(hObject,handles); 

% --- Executes on button press in cleanTracksBtn.
function cleanTracksBtn_Callback(hObject, ~, handles)
    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        [handles,del] = cleanTracks(handles);
        
        handles = refreshPlot(handles);
        handles = writeLog(handles,'%d tracks cleaned',del);
    else
        handles = writeLog(handles,'No tracks to clean');
    end
    guidata(hObject,handles); 


% --- Executes on button press in joinTracksBtn.
function joinTracksBtn_Callback(hObject, ~, handles)
    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        handles = writeLog(handles,'Select track 1 (Right click to cancel)');
        [time1,freq1] = MagnetGInput2(handles.hTracks,true);

        if ~isempty(time1)
            handles = writeLog(handles,'Select track 2 (Right click to cancel)');
            [time2,freq2] = MagnetGInput2(handles.hTracks,true);
            
            if ~isempty(time2)
                % Match tracks with fish
                [handles,id1] = matchTrack(handles,time1,freq1);
                [handles,id2] = matchTrack(handles,time2,freq2);
                [handles,~] = joinTracks(handles,id1,time1,id2,time2);

                handles = refreshPlot(handles);
                handles = writeLog(handles,'Tracks joined');
            else
                handles = writeLog(handles,'Join cancelled');
            end
        else
            handles = writeLog(handles,'Join cancelled');
        end
    else
        handles = writeLog(handles,'No tracks to join');
    end
    guidata(hObject,handles); 

    
    
% --- Executes on button press in splitTracksBtn.
function splitTracksBtn_Callback(hObject, ~, handles)
    if isfield(handles,'tracks')    
        handles = tracksView(handles);
        handles = addUndo(handles);

        handles = writeLog(handles,'Select track to split (Right click to cancel)');
        
        [time,freq] = MagnetGInput2(handles.hTracks,true);
        
        if ~isempty(time)
            [handles,id] = matchTrack(handles,time,freq);
            [handles,~] = splitTrack(handles,id,time);
            
            handles = refreshPlot(handles);
            handles = writeLog(handles,'Track for fish %d split at time %.2f',id,time);
        else
            handles = writeLog(handles,'Split cancelled');
        end
    else
        handles = writeLog(handles,'No tracks to split');
    end
    guidata(hObject,handles); 
    
 % --- Executes on button press in trackHighlightCheck.
function trackHighlightCheck_Callback(hObject, ~, handles)
    handles.params.trackHighlight = get(hObject,'Value');
    handles = refreshPlot(handles);
    guidata(hObject,handles);


% --- Executes on button press in newLineBtn.
function newLineBtn_Callback(hObject, ~, handles)
    isConst = 1;
   
    if isfield(handles,'tracks')
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        selTrack = get(handles.tracksListBox,'Value');
        selTrack = selTrack(1);
        
        ids = unique([handles.tracks.id]);
        id = ids(selTrack);
        
        while isConst
            handles = writeLog(handles,'Select end points of line to add to track %d',id);
            [time1,freq1] = MagnetGInput2(handles.hSpec,false);
            if ~isInRange(handles,time1,freq1)
                set(handles.constCheckBox,'Value',0);
                break;
            end
            [time2,freq2] = MagnetGInput2(handles.hSpec,false);
            if ~isInRange(handles,time2,freq2)
                set(handles.constCheckBox,'Value',0);
                break;
            end

            if ~isempty(time1) && ~isempty(freq1) && ~isempty(time2) && ~isempty(freq2)    
                handles = addLine(handles,id,time1,freq1,time2,freq2);
                handles = refreshPlot(handles);              
                isConst = get(handles.constCheckBox,'Value');
            else
                handles = writeLog(handles,'No corresponding point found');
            end
        end
    else
        % Need to make a new track
        handles = writeLog(handles,'No tracks data');
    end
    guidata(hObject,handles);

function  handles = addLine(handles,id,time1,freq1,time2,freq2)
    if time1 > time2
        t = time2; time2=time1; time1=t;
        f = freq2; freq2=freq1; freq1=f;
    end
    
    tvec = handles.spec.T(handles.spec.T>=time1 & handles.spec.T<=time2);
    N = length(tvec);
    fvec = linspace(freq1,freq2,N);
    [~,nearestIdx] = min(abs(repmat(handles.spec.F,1,N) - repmat(fvec,length(handles.spec.F),1)));
    fvec = handles.spec.F(nearestIdx);
    handles = addPoints(handles,id,tvec,fvec);
    
function handles = addPoints(handles,id,time,freq)
    [~,tidx] = ismember(time,handles.spec.T);
    [~,fidx] = ismember(freq,handles.spec.F);
    
    for k = 1:length(tidx)
        % Cannot have two points at the same time with the same id
        repeatIdx = [handles.tracks.t]==time(k) & [handles.tracks.id]==id;
        handles.tracks(repeatIdx) = [];
        
        nF = length(handles.spec.F);
        
        [newTrackPt.t,newTrackPt.f1,newTrackPt.a1,newTrackPt.a2,newTrackPt.a3,...
        newTrackPt.p1,newTrackPt.p2,newTrackPt.p3,newTrackPt.id] = deal(NaN);
        
        newTrackPt.t = time(k);
        newTrackPt.f1 = freq(k);
        newTrackPt.a1 = abs(handles.spec.S(fidx(k),tidx(k),:));
        newTrackPt.p1 = angle(handles.spec.S(fidx(k),tidx(k),:));

        if 2*fidx(k)<=nF
            newTrackPt.a2 = abs(handles.spec.S(fidx(k)*2,tidx(k),:));
            newTrackPt.p2 = angle(handles.spec.S(fidx(k)*2,tidx(k),:));
        end
        
        if 3*fidx(k)<=nF
            newTrackPt.a3 = abs(handles.spec.S(fidx(k)*3,tidx(k),:));
            newTrackPt.p3 = angle(handles.spec.S(fidx(k)*3,tidx(k),:));
        end
        
        newTrackPt.id = id;
        newTrackPt.conf = -100;     % To enable detection later

        handles.tracks = [handles.tracks newTrackPt];
    end
    
% --- Executes on button press in newPointBtn.
function newPointBtn_Callback(hObject, ~, handles)
    isConst = 1;
    if isfield(handles,'tracks')
        handles = tracksView(handles);
        handles = addUndo(handles);
        
        selTrack = get(handles.tracksListBox,'Value');
        selTrack = selTrack(1);
        
        ids = unique([handles.tracks.id]);
        id = ids(selTrack);

        while isConst
            handles = writeLog(handles,'Select point to add to track %d',id);
            [time,freq] = MagnetGInput2(handles.hSpec,false);
            if ~isInRange(handles,time,freq)
                set(handles.constCheckBox,'Value',0);
                break;
            end

            if ~isempty(time) && ~isempty(freq)     
                handles = addPoints(handles,id,time,freq);
                handles = refreshPlot(handles);
            else
                handles = writeLog(handles,'No corresponding point found');
            end
            isConst = get(handles.constCheckBox,'Value');
        end
    else
        handles = writeLog(handles,'No tracks data');
    end
    guidata(hObject,handles);
    
function out = isInRange(handles,time,freq)
    out = time>=handles.params.rangeT1 && time<= handles.params.rangeT2 && freq >= handles.params.rangeF1 && freq <= handles.params.rangeF2;       

% --- Executes on button press in assignPointsBtn.
function assignPointsBtn_Callback(hObject, ~, handles)
    if isfield(handles,'tracks')
        if isfield(handles,'hPoly');
            handles = tracksView(handles);
            handles = addUndo(handles);
            
            selTrack = get(handles.tracksListBox,'Value');
            selTrack = selTrack(1);
            ids = unique([handles.tracks.id]);
            assignId = ids(selTrack);
            
            P = getPosition(handles.hPoly);
            selectedIdx = inpolygon([handles.tracks.t]',[handles.tracks.f1]',P(:,1),P(:,2));
           
            % Cannot have repeated times in the track being assigned to
            repeatIdx = [handles.tracks.id]==assignId & ~selectedIdx' & ismember([handles.tracks.t],[handles.tracks(selectedIdx).t]);
           
            % Cannot have repeated times in the selection
            selectedIdx = find(selectedIdx);
            [~,uniqueIdx,~] = unique([handles.tracks(selectedIdx).t]);
            selectedIdx = selectedIdx(uniqueIdx);
           
            [handles.tracks(selectedIdx).id] = deal(assignId);
            handles.tracks(repeatIdx) = [];
            
            handles = cleanTracks(handles);
            handles = populateTracksList(handles);
            handles = refreshPlot(handles);
        else
            handles = writeLog(handles,'No region selected');
        end
    else
        handles = writeLog(handles,'No tracks data');
    end
    guidata(hObject,handles);


% --- Executes on button press in deletePointsBtn.
function deletePointsBtn_Callback(hObject, ~, handles)
    if isfield(handles,'tracks')
        if isfield(handles,'hPoly');
            handles = tracksView(handles);
            handles = addUndo(handles);
            
            P = getPosition(handles.hPoly);
            selectedIdx = inpolygon([handles.tracks.t]',[handles.tracks.f1]',P(:,1),P(:,2));

            handles.tracks(selectedIdx) = [];
            
            handles = cleanTracks(handles);
            handles = populateTracksList(handles);
            handles = refreshPlot(handles);
        else
            handles = writeLog(handles,'No region selected');
        end
    else
        handles = writeLog(handles,'No tracks data');
    end
    guidata(hObject,handles);

% --- Executes on button press in newTrackBtn.
function newTrackBtn_Callback(hObject, ~, handles)
    if isfield(handles,'spec')
        handles = tracksView(handles);
        newTrack = fillWithNaNs([],handles.spec.T,size(handles.spec.S,3));
        if isfield(handles,'tracks')
            handles = addUndo(handles);
            newId = max([handles.tracks.id])+1;
            [newTrack.id] = deal(newId);
            handles.tracks = [handles.tracks newTrack];
        else
            [newTrack.id] = deal(1);
            handles.tracks = newTrack;
        end
        
        handles = refreshPlot(handles);
        handles = populateTracksList(handles);
    else
        handles = writeLog(handles,'No spectrogram data available');
    end
    guidata(hObject,handles);


% --- Executes on button press in selectPointsBtn.
function selectPointsBtn_Callback(hObject, ~, handles)
    if isfield(handles,'tracks')
        handles = tracksView(handles);
        handles.hPoly = impoly(handles.hSingle);
    else
        handles = writeLog(handles,'No tracks data');
    end
    guidata(hObject,handles);


function subFigClickCallBack(hObject,~,handles)

    % Find out which of the subfigures the click came through
    subIdx = find(ismember(handles.hSub,get(hObject,'Parent')));
    
    
%     % Indicate selected
%                 chan = get(handles.channelListBox,'Value');
%                 for k = 1:length(chan)
%                     x = get(handles.hSub(chan(k)),'XLim');
%                     y = get(handles.hSub(chan(k)),'YLim');
%                     hold(handles.hSub(chan(k)),'on');
%                     plot(handles.hSub(chan(k)),[x(1) x(2) x(2) x(1) x(1)],[y(1) y(1) y(2) y(2) y(1)],'-y','LineWidth',5);
%                     hold(handles.hSub(chan(k)),'off');
%                 end


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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% UNDO AND REDO FUNCTIONALITY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Main undo function
function handles = undo(handles)
    if isfield(handles,'tracks')
        if handles.undo.size()
            handles.redo.push(handles.tracks);
            handles.tracks = handles.undo.pop();           
            handles = setUndoVisibility(handles);
            handles = populateTracksList(handles);
            handles = refreshPlot(handles);
        else
            handles = writeLog(handles,'Nothing to undo');
        end
    else
        handles = writeLog(handles,'No tracks data found');
    end

% Main redo function
function handles = redo(handles)
    if isfield(handles,'tracks')
        if handles.redo.size()
            handles.undo.push(handles.tracks);
            handles.tracks = handles.redo.pop();           
            handles = setUndoVisibility(handles);
            handles = populateTracksList(handles);
            handles = refreshPlot(handles);
        else
            handles = writeLog(handles,'Nothing to redo');
        end
    else
        handles = writeLog(handles,'No tracks data found');
    end

function handles = setUndoVisibility(handles)
    if handles.undo.size()
        set(handles.tracksUndoBtn,'Enable','on');
    else
        set(handles.tracksUndoBtn,'Enable','off');
    end
    
    if handles.redo.size()
        set(handles.tracksRedoBtn,'Enable','on');
    else
        set(handles.tracksRedoBtn,'Enable','off');
    end
    
function handles = addUndo(handles)
    handles.undo.push(handles.tracks);
    handles.redo.empty();
    handles = setUndoVisibility(handles);

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

% --- MAIN KEYPRESS FUNCTION FOR FIGURE WINDOW, ADD KEYBOARD SHORTCUTS HERE --- %
function figure1_KeyReleaseFcn(hObject, eventdata, handles)
    if strcmp(eventdata.Key,'z') && ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier,'control')
        handles = undo(handles);
    elseif strcmp(eventdata.Key,'y') && ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier,'control')
        handles = redo(handles);
    end

    guidata(hObject,handles);