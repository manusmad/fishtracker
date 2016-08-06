% Replace with standard data folder
gridDataFolder = '/Volumes/JAR_data/grid_data_final/methodsPaperData';

addpath(fullfile('..','packages','serialization'));
addpath(fullfile('..','frequencyTracking','helpers'));
addpath(fullfile('..','frequencyTracking','tracking'));

%% Load spectrogram to visualize
% load(fullfile(gridDataFolder,'140403_singleTubeTrials','spec','140403_003_spec'),'spec');
% % load(fullfile(gridDataFolder,'140403_singleTubeTrials','freqtracks','140403_003_tracks'),'tracks');
% spec = hlp_deserialize(spec);
% Smag = mean(normSpecMag(spec.S),3);
% 
% [~,hSpec] = plotSpectrogram(gca,spec.T,spec.F,Smag);
% ylim([330,360]);


%% Load electrode file
load(fullfile(gridDataFolder,'140403_singleTubeTrials','elec','140403_003_elec'),'elec');

f1 = 330;
f2 = 360;

Wp = 2*[f1 f2]/elec.meta.Fs;
Ws = 2*[0.9*f1 1.1*f2]/elec.meta.Fs;
Rp = 3;
Rs = 40;
[n,Wn] = buttord(Wp,Ws,Rp,Rs);
[b,a] = butter(n,Wn);

y = filter(b,a,elec.data);
y = mean(y,2);
y = (y - min(y))/(max(y)-min(y));   % Normalize  0 - 1
y = y*2-1;                          % Normalize -1 - 1

% sound(y,elec.meta.Fs);
audiowrite('foo.wav',y,elec.meta.Fs);

