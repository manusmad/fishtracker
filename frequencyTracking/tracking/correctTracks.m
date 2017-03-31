% CORRECTTRACKS Script for correcting tracks with some errors
% 
% Not a part of the GUI code, but can be used to correct some errors in
% manually edited tracks files.
%
% Manu S. Madhav
% 2016
% See also NOREPEATTIMES, FILLWITHNANS

% Open tracks file
[tracksFileNames,filePath] = uigetfile('*tracks.mat','MultiSelect','on');        
if ~iscell(tracksFileNames)
    tracksFileNames = {tracksFileNames};
end
N = length(tracksFileNames);
specFileNames = cell(N,1);

for k = 1:N
    specFileNames{k} = [tracksFileNames{k}(1:end-10) 'spec.mat'];
end

addpath('serialization');
for k = 1:N
    load(fullfile(filePath,tracksFileNames{k}),'tracks');
    
    load(fullfile(filePath,specFileNames{k}),'spec');
    spec = hlp_deserialize(spec);
    
    % Delete all tracks with f1=NaN, to start with a clean slate
    delIdx = isnan([tracks.f1]);
    tracks(delIdx) = [];
    
    delIdx = [];
    % Correct amplitude instead of normalized amplitude
    for j = 1:length(tracks)
        tidx = find(spec.T == tracks(j).t,1);
        [~,fidx] = min(abs(spec.F-tracks(j).f1));

        delIdx = [];
        if ~isempty(tidx)
            tracks(j).a1 = abs(squeeze(spec.S(fidx,tidx,:)));
            tracks(j).a2 = abs(squeeze(spec.S(fidx*2,tidx,:)));
            tracks(j).a3 = abs(squeeze(spec.S(fidx*3,tidx,:)));
            
            tracks(j).p1 = angle(squeeze(spec.S(fidx,tidx,:)));
            tracks(j).p2 = angle(squeeze(spec.S(fidx*2,tidx,:)));
            tracks(j).p3 = angle(squeeze(spec.S(fidx*3,tidx,:)));
        else
            delIdx = [delIdx j];
        end
    end
    tracks(j) = [];
    
    % Ensure that there are no repeating times in each track.
    tracks = noRepeatTimes(tracks);
    
    % Add NaNs in time instances where the fish is not being detected.
    tracks = fillWithNaNs(tracks,spec.T,size(spec.S,3));

    % Add metadata as variable
    meta = spec.meta;
    meta.F = spec.F;
    meta.T = spec.T; 

    save(fullfile(filePath,tracksFileNames{k}),'tracks','meta');
end
rmpath('serialization');