% Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('..');

baseFolder = uigetdir(pwd,'Select dataset folder ...');
trialFolder = 'terraronca';

%% Choose which file to plot
particle_file_name = 'TerraRonca_Calibration_01_100s_particle.mat';
iFishVec = [6,9,10];

% particle_file_name = 'TerraRonca_Calibration_02_100s_particle.mat';
% iFishVec = [8 10 12];

% particle_file_name = 'TerraRonca_Calibration_03_100s_particle.mat';
% iFishVec = [8 12 15];

% particle_file_name = 'TerraRonca_Calibration_04_100s_particle.mat';
% iFishVec = [9 12 14];

tracked_dir_path        = fullfile(baseFolder,trialFolder,'tracked');
handclick_dir_path      = fullfile(baseFolder,trialFolder,'handclick');
spec_dir_path           = fullfile(baseFolder,trialFolder,'spec');
freqtracks_dir_path     = fullfile(baseFolder,trialFolder,'freqtracks');
photo_dir_path          = fullfile(baseFolder,trialFolder,'rectified_photos');

handclick_file_name     = strrep(particle_file_name,'100s_particle','handclickTube');
spec_file_name          = strrep(particle_file_name,'particle','spec');
freqtracks_file_name    = strrep(particle_file_name,'particle','tracks');
photo_file_name         = strrep(particle_file_name,'_100s_particle.mat','.jpg');

fig_dir_path          = fullfile(baseFolder,trialFolder,'figures');
fig_file_name         = strrep(particle_file_name,'_particle.mat','.pdf');

%% Load files
load(fullfile(tracked_dir_path, particle_file_name));
load(fullfile(handclick_dir_path,handclick_file_name));
spec                    = load(fullfile(spec_dir_path, spec_file_name),'spec');
freqtracks              = load(fullfile(freqtracks_dir_path, freqtracks_file_name),'tracks');

spec = hlp_deserialize(spec.spec);
tracks = freqtracks.tracks;
Smag = mean(normSpecMag(spec.S),3);

%%
gridCenter = [1983 1452];
scaleFact = 23.8;

for iLoop = 1:length(iFishVec)
    i = iFishVec(iLoop);
    xFish(iLoop) = scaleFact*mean(particle.fish(i).x)+gridCenter(1);
    yFish(iLoop) = scaleFact*mean(particle.fish(i).y)+gridCenter(2);
    thFish(iLoop) = wrapTo2Pi(circ_mean(atan(tan(wrapTo2Pi(particle.fish(i).theta))))); 
    
%     posStd(iLoop) = max([std(xMean(i,:)) std(yMean(i,:))]); 
    posStd(iLoop) = std(sqrt((particle.fish(i).x - mean(particle.fish(i).x)).^2+ (particle.fish(i).y - mean(particle.fish(i).y)).^2));
    thStd(iLoop) = circ_std(2*particle.fish(i).theta,[],[],1);
end
%% Error vars readout
%{
strjoin(file_parts(1:3),'_')
errorPos = sqrt(sum((tubeCen - [xFish; yFish]).^2,1))./scaleFact
posStd

errorTh  = wrapTo180(rad2deg(thFish - tubeAng));
flipPosIdx = find(errorTh > 90);
errorTh(flipPosIdx) = errorTh(flipPosIdx) -180;
flipNegIdx = find(errorTh < -90);
errorTh(flipNegIdx) = errorTh(flipNegIdx) +180;

errorThDeg = abs(errorTh)
thStdDeg = rad2deg(thStd)
%}

%% Plot
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.01], [0.125 0.125], [0.03 0.01]);

colrs               = distinguishable_colors(particle.nFish,{'r','k','y'});
scrsz               = get(groot,'ScreenSize');
hAxis               = figure('Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)]);
set(gcf,'color',[1 1 1]);

ids = unique([tracks.id]);
nTracks = length(ids);

h1 = subplot(1,2,1);
hold on;
plotSpectrogram(gca,spec.T,spec.F,Smag);

for k = 1:nTracks
    idTrack = tracks([tracks.id]==ids(k));
    [~,idx] = sort([idTrack.t]);
    idTrack = idTrack(idx);

    plot([idTrack.t],[idTrack.f1],'.-','Color',colrs(k,:),'LineWidth',3);
end

ylim([290,450]);
h1.FontSize = 12;
xlim([spec.T(1),spec.T(end)]);

xlabel('Time (s)','FontSize',12);
ylabel('Frequency (Hz)','FontSize',12);
title('Spectrogram with Frequency Tracks','FontSize',18);
hold off;

subplot(1,2,2), hold on;
imageMat = imread(fullfile(photo_dir_path,photo_file_name));
imshow(imageMat,'InitialMagnification',50);
hold on;
plot(scaleFact*particle.gridCoord(1:end,1)+gridCenter(1),scaleFact*particle.gridCoord(1:end,2)+gridCenter(2),'ok','LineWidth',3.01)
plot(scaleFact*particle.gridCoord(1:end,1)+gridCenter(1),scaleFact*particle.gridCoord(1:end,2)+gridCenter(2),'+k','LineWidth',3.01)
for iLoop = 1:length(iFishVec)
    viscircles([xFish(iLoop) yFish(iLoop)],2*scaleFact*posStd(iLoop),'Color',colrs(iFishVec(iLoop),:));

    quiver(xFish(iLoop),yFish(iLoop),2*scaleFact*posStd(iLoop)*cos(thFish(iLoop)+2*thStd(iLoop)),2*scaleFact*posStd(iLoop)*sin(thFish(iLoop)+2*thStd(iLoop)),'LineWidth',1.5,'Color',colrs(iFishVec(iLoop),:));
    quiver(xFish(iLoop),yFish(iLoop),2*scaleFact*posStd(iLoop)*cos(thFish(iLoop)-2*thStd(iLoop)),2*scaleFact*posStd(iLoop)*sin(thFish(iLoop)-2*thStd(iLoop)),'LineWidth',1.5,'Color',colrs(iFishVec(iLoop),:));
    quiver(xFish(iLoop),yFish(iLoop),2*scaleFact*posStd(iLoop)*cos(thFish(iLoop)),2*scaleFact*posStd(iLoop)*sin(thFish(iLoop)),'LineWidth',1.5,'Color',colrs(iFishVec(iLoop),:));

    quiver(xFish(iLoop),yFish(iLoop),2*scaleFact*posStd(iLoop)*cos(thFish(iLoop)+pi+2*thStd(iLoop)),2*scaleFact*posStd(iLoop)*sin(thFish(iLoop)+pi+2*thStd(iLoop)),'LineWidth',1.5,'Color',colrs(iFishVec(iLoop),:));
    quiver(xFish(iLoop),yFish(iLoop),2*scaleFact*posStd(iLoop)*cos(thFish(iLoop)+pi-2*thStd(iLoop)),2*scaleFact*posStd(iLoop)*sin(thFish(iLoop)+pi-2*thStd(iLoop)),'LineWidth',1.5,'Color',colrs(iFishVec(iLoop),:));
    quiver(xFish(iLoop),yFish(iLoop),2*scaleFact*posStd(iLoop)*cos(thFish(iLoop)+pi),2*scaleFact*posStd(iLoop)*sin(thFish(iLoop)+pi),'LineWidth',1.5,'Color',colrs(iFishVec(iLoop),:));
    
    plot(tubeCen(1,iLoop),tubeCen(2,iLoop),'.','MarkerSize',20,'Color',colrs(iFishVec(iLoop),:))
end

title('Overhead View with Spatial Estimates','FontSize',18);
hold off;

% export_fig(fullfile(fig_dir_path,fig_file_name),'-pdf','-nocrop','-painters')