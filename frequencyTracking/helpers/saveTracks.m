function handles = saveTracks(handles)
% SAVETRACKS Saves tracks file
%
% Prompts user to choose a filename. Makes sure there are no points with
% the same track id and time. Fills the empty spots in all tracks with
% NaNs, and then saves the track structure to file.
%
% Manu S. Madhav
% 2016
% See also NOREPEATTIMES, FILLWITHNANS

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
            handles.tracks = noRepeatTimes(handles.tracks);
            handles.tracks = fillWithNaNs(handles.tracks,handles.spec.T,handles.spec.meta.chNum,handles.meta.chNumOrig);
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