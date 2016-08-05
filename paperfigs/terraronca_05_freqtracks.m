addpath(fullfile('..','packages','serialization'));
addpath(fullfile('..','frequencyTracking','helpers'));
addpath(fullfile('..','frequencyTracking','tracking'));


% Change code to load files from standard data folder
load(fullfile('data','TerraRonca_PostCalibration_05_spec'),'spec');
load(fullfile('data','TerraRonca_PostCalibration_05_tracks'),'tracks');

spec = hlp_deserialize(spec);

Smag = mean(normSpecMag(spec.S),3);

%%
figure(1), clf, hold on;

[~,hSpec] = plotSpectrogram(gca,spec.T,spec.F,Smag);
[~,hTracks] = plotTracks(gca,tracks,[]);

ylim([290,450]);

hold off;