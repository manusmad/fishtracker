% Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('..');

baseFolder = uigetdir(pwd,'Select dataset folder ...');
trialFolder = '140403_singleTubeTrials';

%% Single tube files
particle_file_name = '140403_003_particle.mat';
% particle_file_name = '140403_004_particle.mat';
% particle_file_name = '140403_011_particle.mat';

fig_dir_path            = fullfile('.');
videotracks_dir_path    = fullfile(baseFolder,trialFolder,'videotracks');
tracked_dir_path        = fullfile(baseFolder,trialFolder,'tracked');
spec_dir_path           = fullfile(baseFolder,trialFolder,'spec');
freqtracks_dir_path     = fullfile(baseFolder,trialFolder,'freqtracks');

spec_file_name          = strrep(particle_file_name,'particle','spec');
freqtracks_file_name    = strrep(particle_file_name,'particle','tracks');
videotracks_file_name   = strrep(particle_file_name,'particle','videotracks');

%% Load files 
load(fullfile(tracked_dir_path, particle_file_name));
vidTracked              = load(fullfile(videotracks_dir_path, videotracks_file_name),'gridcen','tankcen','nFish','tubeFrame','frameTime');            

spec                    = load(fullfile(spec_dir_path, spec_file_name),'spec');
freqtracks              = load(fullfile(freqtracks_dir_path, freqtracks_file_name),'tracks');

spec = hlp_deserialize(spec.spec);
tracks = freqtracks.tracks;
Smag = mean(normSpecMag(spec.S),3);

nSteps                  = length(vidTracked.frameTime);
elecTime                = particle.t;
timeIdx                 = zeros(nSteps,1);
for n = 1:nSteps
   [~,timeIdx(n)] = min(abs(elecTime - vidTracked.frameTime(n)));
end

for iLoop = 1:vidTracked.nFish
    xFish(iLoop) = mean(particle.fish(iLoop).x(unique(timeIdx)));
    yFish(iLoop) = mean(particle.fish(iLoop).y(unique(timeIdx)));
    thFish(iLoop) = wrapTo2Pi(circ_mean(atan(tan(wrapTo2Pi(particle.fish(iLoop).theta(unique(timeIdx))))))); 
    posStd(iLoop) = std(sqrt((particle.fish(iLoop).x(unique(timeIdx)) - mean(particle.fish(iLoop).x(unique(timeIdx)))).^2+ (particle.fish(iLoop).y(unique(timeIdx)) - mean(particle.fish(iLoop).y(unique(timeIdx)))).^2));
    thStd(iLoop) = circ_std(2*particle.fish(iLoop).theta(unique(timeIdx)),[],[],1);
end

scaleFact = 6;
xFish = xFish*scaleFact+vidTracked.gridcen(5,1);
yFish = yFish*scaleFact+vidTracked.gridcen(5,2);
posStd = posStd*scaleFact;

%% Plot
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.01], [0.125 0.125], [0.03 0.01]);

ids = unique([tracks.id]);
nTracks = length(ids);
colrs = distinguishable_colors(nTracks,{'r','k','y'});

h1 = subplot(1,2,1);
hold on;
plotSpectrogram(gca,spec.T,spec.F,Smag);

for k = 1:nTracks
    idTrack = tracks([tracks.id]==ids(k));
    [~,idx] = sort([idTrack.t]);
    idTrack = idTrack(idx);

    plot([idTrack.t],[idTrack.f1],'.-','Color',colrs(k,:),'LineWidth',3);
end

ylim([330,360]);
h1.FontSize = 12;
xlim([spec.T(1),spec.T(end)]);

xlabel('Time (s)','FontSize',12);
ylabel('Frequency (Hz)','FontSize',12);
title('Spectrogram with Frequency Tracks','FontSize',18);
hold off;

subplot(1,2,2);
imshow(vidTracked.tubeFrame);
hold on;

plot(vidTracked.gridcen(:,1),vidTracked.gridcen(:,2),'+k','LineWidth',3.01);
plot(vidTracked.gridcen(:,1),vidTracked.gridcen(:,2),'ok','LineWidth',3.01);
plot(vidTracked.tankcen(:,1),vidTracked.tankcen(:,2),'+b','LineWidth',1.01);

for iLoop = 1:vidTracked.nFish
    viscircles([xFish(iLoop) yFish(iLoop)],2*posStd(iLoop),'Color',colrs(iLoop,:));

    quiver(xFish(iLoop),yFish(iLoop),2*posStd(iLoop)*cos(thFish(iLoop)+2*thStd(iLoop)),2*posStd(iLoop)*sin(thFish(iLoop)+2*thStd(iLoop)),'LineWidth',1.5,'Color',colrs(iLoop,:));
    quiver(xFish(iLoop),yFish(iLoop),2*posStd(iLoop)*cos(thFish(iLoop)-2*thStd(iLoop)),2*posStd(iLoop)*sin(thFish(iLoop)-2*thStd(iLoop)),'LineWidth',1.5,'Color',colrs(iLoop,:));
    quiver(xFish(iLoop),yFish(iLoop),2*posStd(iLoop)*cos(thFish(iLoop)),2*posStd(iLoop)*sin(thFish(iLoop)),'LineWidth',1.5,'Color',colrs(iLoop,:));

    quiver(xFish(iLoop),yFish(iLoop),2*posStd(iLoop)*cos(thFish(iLoop)+pi+2*thStd(iLoop)),2*posStd(iLoop)*sin(thFish(iLoop)+pi+2*thStd(iLoop)),'LineWidth',1.5,'Color',colrs(iLoop,:));
    quiver(xFish(iLoop),yFish(iLoop),2*posStd(iLoop)*cos(thFish(iLoop)+pi-2*thStd(iLoop)),2*posStd(iLoop)*sin(thFish(iLoop)+pi-2*thStd(iLoop)),'LineWidth',1.5,'Color',colrs(iLoop,:));
    quiver(xFish(iLoop),yFish(iLoop),2*posStd(iLoop)*cos(thFish(iLoop)+pi),2*posStd(iLoop)*sin(thFish(iLoop)+pi),'LineWidth',1.5,'Color',colrs(iLoop,:));
end
title('Overhead View with Spatial Estimates','FontSize',18);
hold off;

export_fig(fullfile(fig_dir_path,strrep(particle_file_name,'_particle.mat','')),'-pdf','-nocrop','-painters')