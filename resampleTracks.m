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

%% Algo
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

%% 

% Find out tracks params
tracks(isnan([tracks.f1]))=[];
t = sort(unique([tracks.t]));
Ts_tracks = min(diff(t));
idx = find(diff(t)>Ts_tracks*1.8);
t = sort([t t(idx)+Ts_tracks]);

% Fill in tracks
for u = uId(1)
    % For each unique track
    uTrack = tracks([tracks.id]==u);
    
    % Sort by time
    [~,idx] = sort([uTrack.t]);
    uTrack = uTrack(idx);
    idx = find(~ismember(t,[uTrack.t]));
    idx2 = find(diff(idx)~=1);
    
end