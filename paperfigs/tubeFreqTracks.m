% Replace with standard data folder
gridDataFolder = '/Volumes/JAR_data/grid_data_final/methodsPaperData';

addpath(fullfile('..','packages','serialization'));
addpath(fullfile('..','frequencyTracking','helpers'));
addpath(fullfile('..','frequencyTracking','tracking'));

%% Single tube, trial 03

load(fullfile(gridDataFolder,'140403_singleTubeTrials','spec','140403_003_spec'),'spec');
load(fullfile(gridDataFolder,'140403_singleTubeTrials','freqtracks','140403_003_tracks'),'tracks');
spec = hlp_deserialize(spec);
Smag = mean(normSpecMag(spec.S),3);

figure(1), clf, hold on;

[~,hSpec] = plotSpectrogram(gca,spec.T,spec.F,Smag);
[~,hTracks] = plotTracks(gca,tracks,[]);

title('Single Tube, trial 03');
ylim([330,360]);
xlim([spec.T(1),spec.T(end)]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');

hold off;

%% Single tube, trial 04

load(fullfile(gridDataFolder,'140403_singleTubeTrials','spec','140403_004_spec'),'spec');
load(fullfile(gridDataFolder,'140403_singleTubeTrials','freqtracks','140403_004_tracks'),'tracks');
spec = hlp_deserialize(spec);
Smag = mean(normSpecMag(spec.S),3);

figure(2), clf, hold on;

[~,hSpec] = plotSpectrogram(gca,spec.T,spec.F,Smag);
[~,hTracks] = plotTracks(gca,tracks,[]);

title('Single Tube, trial 04');
ylim([330,360]);
xlim([spec.T(1),spec.T(end)]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');

hold off;

%% Single tube, trial 11

load(fullfile(gridDataFolder,'140403_singleTubeTrials','spec','140403_011_spec'),'spec');
load(fullfile(gridDataFolder,'140403_singleTubeTrials','freqtracks','140403_011_tracks'),'tracks');
spec = hlp_deserialize(spec);
Smag = mean(normSpecMag(spec.S),3);

figure(3), clf, hold on;

[~,hSpec] = plotSpectrogram(gca,spec.T,spec.F,Smag);
[~,hTracks] = plotTracks(gca,tracks,[]);

title('Single Tube, trial 11');
ylim([330,360]);
xlim([spec.T(1),spec.T(end)]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');

hold off;

%% Three tube, trial 01

load(fullfile(gridDataFolder,'140417_threeTubeTrials','spec','140417_001_spec'),'spec');
load(fullfile(gridDataFolder,'140417_threeTubeTrials','freqtracks','140417_001_tracks'),'tracks');
spec = hlp_deserialize(spec);
Smag = mean(normSpecMag(spec.S),3);

figure(4), clf, hold on;

[~,hSpec] = plotSpectrogram(gca,spec.T,spec.F,Smag);
[~,hTracks] = plotTracks(gca,tracks,[]);

title('Three Tube, trial 01');
ylim([280,400]);
xlim([spec.T(1),spec.T(end)]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');

hold off;


%% Three tube, trial 25 

load(fullfile(gridDataFolder,'140417_threeTubeTrials','spec','140417_025_spec'),'spec');
load(fullfile(gridDataFolder,'140417_threeTubeTrials','freqtracks','140417_025_tracks'),'tracks');
spec = hlp_deserialize(spec);
Smag = mean(normSpecMag(spec.S),3);

figure(5), clf, hold on;

[~,hSpec] = plotSpectrogram(gca,spec.T,spec.F,Smag);
[~,hTracks] = plotTracks(gca,tracks,[]);

title('Three Tube, trial 25');
ylim([280,400]);
xlim([spec.T(1),spec.T(end)]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');

hold off;

%% Three tube, trial 38

load(fullfile(gridDataFolder,'140417_threeTubeTrials','spec','140417_038_spec'),'spec');
load(fullfile(gridDataFolder,'140417_threeTubeTrials','freqtracks','140417_038_tracks'),'tracks');
spec = hlp_deserialize(spec);
Smag = mean(normSpecMag(spec.S),3);

figure(6), clf, hold on;

[~,hSpec] = plotSpectrogram(gca,spec.T,spec.F,Smag);
[~,hTracks] = plotTracks(gca,tracks,[]);

title('Three Tube, trial 25');
ylim([280,400]);
xlim([spec.T(1),spec.T(end)]);
xlabel('Time (s)');
ylabel('Frequency (Hz)');

hold off;