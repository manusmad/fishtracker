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
Ts2 = 0.05;

[nT,nCh] = size(elec.data);
Ts1 = diff(elec.t(1:2));
uId = unique([tracks.id]);

if Ts2<Ts1
    error('Output sampling rate greater than input');
end

% Compute closest possible overlap
nOverlap = round(Ts2/Ts1);
fprintf('\nActual output sampling rate: %f\n',1/(nOverlap*Ts1));

