% Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('..');

baseFolder = uigetdir(pwd,'Select dataset folder ...');
trialFolder = '140403_singleTubeTrials';

%% Single tube files
% particle_file_name = '140403_003_particle.mat';
particle_file_name = '140403_004_particle.mat';
% particle_file_name = '140403_011_particle.mat';

fig_dir_path            = fullfile(baseFolder,trialFolder,'figures');
videotracks_dir_path    = fullfile(baseFolder,trialFolder,'videotracks');
tracked_dir_path        = fullfile(baseFolder,trialFolder,'tracked');
spec_dir_path           = fullfile(baseFolder,trialFolder,'spec');
freqtracks_dir_path     = fullfile(baseFolder,trialFolder,'freqtracks');

trackedVideo_file_name  = strrep(particle_file_name,'particle','video');
spec_file_name          = strrep(particle_file_name,'particle','spec');
freqtracks_file_name    = strrep(particle_file_name,'particle','tracks');
videotracks_file_name   = strrep(particle_file_name,'particle','videotracks');

%% Load files 
particleTracked         = load(fullfile(tracked_dir_path, particle_file_name),'xMean', 'yMean','thMean');
vidTracked              = load(fullfile(videotracks_dir_path, videotracks_file_name),'gridcen','tankcen','nFish','tubeFrame');            

spec                    = load(fullfile(spec_dir_path, spec_file_name),'spec');
freqtracks              = load(fullfile(freqtracks_dir_path, freqtracks_file_name),'tracks');

spec = hlp_deserialize(spec.spec);
Smag = mean(normSpecMag(spec.S),3);

%%
for iLoop = 1:vidTracked.nFish
    xFish(iLoop) = mean(particleTracked.xMean(iLoop,:));
    yFish(iLoop) = mean(particleTracked.yMean(iLoop,:));
    thFish(iLoop) = wrapTo2Pi(circ_mean(atan(tan(wrapTo2Pi(particleTracked.thMean(iLoop,:))))'))'; 
    posStd(iLoop) = std(sqrt((particleTracked.xMean(iLoop,:) - mean(particleTracked.xMean(iLoop,:))).^2+ (particleTracked.yMean(iLoop,:) - mean(particleTracked.xMean(iLoop,:))).^2));
    thStd(iLoop) = circ_std(2*particleTracked.thMean(iLoop,:),[],[],2);
end
%%
plotFig = 1;
if plotFig
    subplot(1,2,1);
    hold on;
    [~,hSpec] = plotSpectrogram(gca,spec.T,spec.F,Smag);
    [~,hTracks] = plotTracks(gca,freqtracks.tracks,[]);
        
    ylim([330,360]);
    xlim([spec.T(1),spec.T(end)]);
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    hold off;
    
    subplot(1,2,2);
    imshow(vidTracked.tubeFrame);
    hold on;
    scatter(vidTracked.gridcen(:,1),vidTracked.gridcen(:,2),100,'filled')
    scatter(vidTracked.tankcen(:,1),vidTracked.tankcen(:,2),100,'filled')
    for iLoop = 1:vidTracked.nFish
        viscircles([xFish(iLoop) yFish(iLoop)],2*posStd(iLoop));

        quiver(xFish(iLoop),yFish(iLoop),2*posStd(iLoop)*cos(thFish(iLoop)+2*thStd(iLoop)),2*posStd(iLoop)*sin(thFish(iLoop)+2*thStd(iLoop)),'LineWidth',1.5,'Color','r');
        quiver(xFish(iLoop),yFish(iLoop),2*posStd(iLoop)*cos(thFish(iLoop)-2*thStd(iLoop)),2*posStd(iLoop)*sin(thFish(iLoop)-2*thStd(iLoop)),'LineWidth',1.5,'Color','r');
        quiver(xFish(iLoop),yFish(iLoop),2*posStd(iLoop)*cos(thFish(iLoop)),2*posStd(iLoop)*sin(thFish(iLoop)),'LineWidth',1.5,'Color','g');

        quiver(xFish(iLoop),yFish(iLoop),2*posStd(iLoop)*cos(thFish(iLoop)+pi+2*thStd(iLoop)),2*posStd(iLoop)*sin(thFish(iLoop)+pi+2*thStd(iLoop)),'LineWidth',1.5,'Color','r');
        quiver(xFish(iLoop),yFish(iLoop),2*posStd(iLoop)*cos(thFish(iLoop)+pi-2*thStd(iLoop)),2*posStd(iLoop)*sin(thFish(iLoop)+pi-2*thStd(iLoop)),'LineWidth',1.5,'Color','r');
        quiver(xFish(iLoop),yFish(iLoop),2*posStd(iLoop)*cos(thFish(iLoop)+pi),2*posStd(iLoop)*sin(thFish(iLoop)+pi),'LineWidth',1.5,'Color','g');
    end
    hold off;
end

export_fig(fullfile(fig_dir_path,strrep(particle_file_name,'_particle.mat','')),'-pdf','-nocrop','-painters')