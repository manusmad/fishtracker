% Given tracks struct array and corresponding time array T, create NaNs for times where there is no track
% information.
%
% Manu Madhav
% 16-Jul-14
function tracks = fillWithNaNs(tracks,T,nCh)

[track0.t,track0.f1,track0.a1,track0.a2,track0.a3,...
        track0.p1,track0.p2,track0.p3,track0.id] = deal(NaN);
track0.conf = -1000;
if isempty(nCh)
    nCh = length(tracks(1).a1);
end
[track0.a1,track0.a2,track0.a3,track0.p1,track0.p2,track0.p3] = deal(NaN(nCh,1));

addpath('progressbar');
% If first argument is empty, return a tracks array with all NaN fields
if isempty(tracks)
    tracks = repmat(track0,size(T));
    for k = 1:length(T)
        tracks(k).t = T(k);
    end
else
    % Delete all tracks with f1=NaN, to start with a clean slate
    delIdx = isnan([tracks.f1]);
    tracks(delIdx) = [];
    
    % How many tracks are there?
    ids = unique([tracks.id]);
    nTracks = length(ids);
    
    progressbar('Filling empty data...');
    
    for j = 1:nTracks
        progressbar(j/nTracks);
        idTrack = tracks([tracks.id] == ids(j));
        
        [~,memberIdx] = ismember([idTrack.t],T);
        if any(memberIdx) == 0
            error('Spectrogram and tracks times do not coincide');
        end
        
        notMember = 1:length(T);
        notMember(memberIdx) = [];
        
        for k = 1:length(notMember)
            newTrack = track0;
            newTrack.t = T(notMember(k));
            newTrack.id = ids(j);
            tracks = [tracks newTrack];
        end
    end
end    
rmpath('progressbar');

