% Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('..');

folder_name = uigetdir(pwd,'Select dataset folder ...');
            
%% Choose which file to generate video for
particle_file_name = 'TerraRonca_Calibration_01_100s_particle.mat';
% particle_file_name = 'TerraRonca_Calibration_02_100s_particle.mat';
% particle_file_name = 'TerraRonca_Calibration_03_100s_particle.mat';
% particle_file_name = 'TerraRonca_Calibration_04_100s_particle.mat';

tracked_dir_path        = fullfile(folder_name,'terraronca','tracked');
trackedVideo_dir_path   = fullfile(folder_name,'terraronca','tracked_video');
spec_dir_path           = fullfile(folder_name,'terraronca','spec');
freqtracks_dir_path     = fullfile(folder_name,'terraronca','freqtracks');

trackedVideo_file_name  = strrep(particle_file_name,'particle','video');
spec_file_name          = strrep(particle_file_name,'particle','spec');
freqtracks_file_name    = strrep(particle_file_name,'particle','tracks');


%% Load files
    
particleTracked         = load(fullfile(tracked_dir_path, particle_file_name),'xMean', 'yMean','thMean','gridCoord','tankCoord','nFish','ampAll','fishTime');
spec                    = load(fullfile(spec_dir_path, spec_file_name),'spec');
freqtracks              = load(fullfile(freqtracks_dir_path, freqtracks_file_name),'tracks');

spec = hlp_deserialize(spec.spec);
Smag = mean(normSpecMag(spec.S),3);


%% Video parameters

nFrame                  = size(particleTracked.thMean,2);
frameInterval           = 767:962;
frameRate               = 8;
fishSelect              = [9 10];
nFrames                 = frameInterval(end)-frameInterval(1)+1;

%%
fW                  = 1;
fL                  = 7;
colrs               = distinguishable_colors(particleTracked.nFish);
scrsz               = get(groot,'ScreenSize');
hAxis               = figure('Position',[1 scrsz(4)/2 scrsz(3)/1.6 scrsz(4)]);
set(gcf,'color',[0 0 0]);

writerObj           = VideoWriter(fullfile(trackedVideo_dir_path, trackedVideo_file_name),'MPEG-4');
writerObj.FrameRate = frameRate;

progressbar('Writing Video');
open(writerObj);  

flag = zeros(1,particleTracked.nFish);
dispStep = ones(1,particleTracked.nFish);
for frameIdx = frameInterval
    progressbar((frameIdx-frameInterval(1))/nFrames);

    time = particleTracked.fishTime(frameIdx);
    
    figure(hAxis), cla;
    
    subplot(1,2,1), hold on;

    [~,hSpec] = plotSpectrogram(gca,spec.T,spec.F,Smag);
    [~,hTracks] = plotTracks(gca,freqtracks.tracks,[]);

    ylimits = [290,450];
    plot([time,time],ylimits,'--y','LineWidth',1);

    ylim(ylimits);
    xlim([spec.T(1),spec.T(end)]);

    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    
    hold off;
    
    subplot(1,2,2), hold on;
    plot(particleTracked.gridCoord(:,1),particleTracked.gridCoord(:,2),'ok','LineWidth',3.01);
    plot(particleTracked.gridCoord(:,1),particleTracked.gridCoord(:,2),'+k','LineWidth',3.01);
    
    for i = 1:length(fishSelect)
        fID = fishSelect(i);
        if sum(~isnan(squeeze(particleTracked.ampAll(fID,:,frameIdx))))
            colrsMat = [colrs(fID,:);colrs(fID,:)];
            dispStep(fID) = frameIdx;
            flag(fID) = 0;
        else
            colrsMat = [1 1 1;colrs(fID,:)];
            if flag(fID) == 0
                dispStep(fID) = frameIdx-1;
                flag(fID) = 1;
            end
        end
        pb=plot_ellipse(fW,fL,particleTracked.xMean(fID,dispStep(fID)),particleTracked.yMean(fID,dispStep(fID)),rad2deg(particleTracked.thMean(fID,dispStep(fID))),[colrsMat(1,:); colrsMat(2,:)]);       
        alpha(pb,0.65);      
    end
    xlim([-125 125])
    ylim([-125 125])
    f = getframe(hAxis);
    writeVideo(writerObj,f);

end
close(writerObj);
progressbar(1);

display('Done')

