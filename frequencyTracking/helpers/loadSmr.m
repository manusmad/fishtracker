function handles = loadSmr(handles)
% LOADELEC Loads Spike2 smr raw data file
%
% Prompts user to choose an smr or smrx file, and then calls loadSmrFile or
% loadSmrxFile with the prefix from the GUI field. 
% Updates the GUI with the loaded parameters of the file.
%
% Manu S. Madhav
% 2016
% See also LOADSMRFILE, LOADSMRXFILE, SETRANGES, CREATESUBPLOTS, 
% POPULATECHANNELLIST, COMPUTERESOLUTIONS

    if isfield(handles,'smrFilePath')
        [smrFileName,smrFilePath] = uigetfile({'*.smr';'*.smrx'},'Choose smr file',handles.smrFilePath);
    elseif isfield(handles,'lastOpenPath')
        [smrFileName,smrFilePath] = uigetfile({'*.smr';'*.smrx'},'Choose smr file',handles.lastOpenPath);
    else
        [smrFileName,smrFilePath,~] = uigetfile({'*.smr';'*.smrx'},'Choose smr file');
    end

    if smrFileName
        try
            tic;
            if ~isempty(regexp(smrFileName,'.smr$', 'once'))
                elec = loadSmrFile(smrFilePath,smrFileName,handles.params.smrFilePrefix);
            else
                elec = loadSmrxFile(smrFilePath,smrFileName,handles.params.smrFilePrefix);
            end
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
            handles = writeLog(handles,'Could not load %s',smrFileName);
            progressbar(1);
        end      
    end