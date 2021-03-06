function handles = loadSpec(handles)
% LOADSPEC Loads spectrogram file
%
% Prompts user to choose an spectrogram data file, and then attempts to load
% it while showing a progress bar. Once file is loaded, fills in the spec
% metadata structure, and runs the GUI commands to update these parameters.
%
% Manu S. Madhav
% 2016
% See also HLP_DESERIALIZE, SETRANGES, CREATESUBPLOTS, POPULATECHANNELLIST,
% COMPUTERESOLUTIONS, COMPUTETHRESHOLD

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
                handles.specFileName = specFileName;
                handles.specFilePath = specFilePath;
                handles.lastOpenPath = specFilePath;
                handles.spec = spec;
                handles.meta = spec.meta;

                handles.params.nFFT = spec.meta.nFFT;
                set(handles.nFFTEdit,'String',num2str(spec.meta.nFFT));
                handles.params.overlap = spec.meta.overlap;
                set(handles.overlapEdit,'String',num2str(spec.meta.overlap));
                handles.normSmag = normSpecMag(spec.S);
                handles.Smag = abs(spec.S);

                handles = setRanges(handles,spec.F(1),spec.F(end),spec.T(1),spec.T(end));
                handles = createSubplots(handles);
                handles = populateChannelList(handles);
                handles = computeResolutions(handles);
                handles = computeThreshold(handles);
                handles = refreshPlot(handles);
                
                set(handles.specFileTxt,'String',specFileName);
                handles = writeLog(handles,'Loaded spectrogram file %s (%.2f s)',specFileName,runTime);
            else
                handles = writeLog(handles,'File %s not loaded',specFileName);
            end
        catch
            handles = writeLog(handles,'Could not load %s',specFileName);
            progressbar(1);
        end
    end