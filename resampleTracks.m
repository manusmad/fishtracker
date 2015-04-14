% resampleTracks
%
% Resample tracks at desired sampling rate directly from raw electrode data
%
% Manu Madhav
% 06-Apr-15

[tracksFileName,tracksFilePath] = uigetfile('*.mat','Choose tracks file');
load(fullfile(tracksFilePath,tracksFileName),'tracks');

[elecFileName,elecFilePath] = uigetfile([tracksFilePath filesep '*.mat'],'Choose electrode data file');
load(fullfile(elecFilePath,elecFileName),'elec');

%% Params
Tres_out = 0.05;
Fres_out = 0.1;

[nT,nCh] = size(elec.data);
Ts_in = diff(elec.t(1:2));
Fs_in = 1/Ts_in;
uId = unique([tracks.id]);

if Tres_out<Ts_in
    error('Output sampling rate greater than input');
end

% Compute closest possible overlap
nOverlap = round(Tres_out/Ts_in);
fprintf('\nActual output sampling rate: %f\n',1/(nOverlap*Ts_in));

%% Fill in tracks

% Find out tracks params
tracks(isnan([tracks.f1]))=[];
t = sort(unique([tracks.t]));
Ts_tracks = min(diff(t));
idx = find(diff(t)>Ts_tracks*1.8);
t = sort([t t(idx)+Ts_tracks]);


newTrack = tracks(1);
newTrack.t = [];
newTrack.f1 = [];
newTrack.id = -1;
newTrack.conf = -1000;
addpath('packages/disperse')
clf, hold on;
for u = uId(1)
    % For each unique track
    uTrack = tracks([tracks.id]==u);
    plot([uTrack.t],[uTrack.f1],'.b');
    
    % Sort by time
    [~,idx] = sort([uTrack.t]);
    uTrack = uTrack(idx);
    
    % Find at which times tracks are missing
    [timeidx,trackidx] = ismember(t,[uTrack.t]);
    
    % When there is only one point missing, we can easily interpolate
    mididx = strfind(timeidx,[1 0 1]);
    newTracks = repmat(newTrack,1,length(mididx));
    [newTracks.t] = disperse(t(mididx+1));
    [newTracks.f1] = disperse(mean([[uTrack(trackidx(mididx)).f1];[uTrack(trackidx(mididx)+1).f1]]));
    uTrack = [uTrack newTracks];
    plot([newTracks.t],[newTracks.f1],'*r');

    
    % Sort and find again
    [~,idx] = sort([uTrack.t]);
    uTrack = uTrack(idx);
    

    % When there is an end, we can add one more point
    endidx = strfind(timeidx,[1 1 0]);   
    newTracks = repmat(newTrack,1,length(endidx));
    [newTracks.t] = disperse(t(endidx+2));
    [newTracks.f1] = disperse(2*[uTrack(trackidx(endidx)+1).f1] - [uTrack(trackidx(endidx)).f1]);
    uTrack = [uTrack newTracks];
    plot([newTracks.t],[newTracks.f1],'*g');
    
    % Sort and find again
    [~,idx] = sort([uTrack.t]);
    uTrack = uTrack(idx);
    [timeidx,trackidx] = ismember(t,[uTrack.t]);
    
    % Same for a beginning
    begidx = strfind(timeidx,[0 1 1]);   
    newTracks = repmat(newTrack,1,length(begidx));
    [newTracks.t] = disperse(t(begidx));
    [newTracks.f1] = disperse(2*[uTrack(trackidx(begidx)+1).f1] - [uTrack(trackidx(begidx)+2).f1]);
    uTrack = [uTrack newTracks];
    plot([newTracks.t],[newTracks.f1],'*k');
end
rmpath('packages/disperse')

%% Window the data according to chosen frequency resolution and overlap
