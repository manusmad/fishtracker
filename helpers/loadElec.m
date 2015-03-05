function handles = loadElec(handles)
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

            if ~isfield(elec,'meta') %#ok<NODEF>
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