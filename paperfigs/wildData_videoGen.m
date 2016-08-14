% Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('..');

baseFolder = uigetdir(pwd,'Select dataset folder ...');
trialFolder = 'terraronca';          

%% Choose which file to generate video for
particle_file_name = 'TerraRonca_PostCalibration_05_100s_particle.mat';

tracked_dir_path        = fullfile(baseFolder,trialFolder,'tracked');
trackedVideo_dir_path   = fullfile(baseFolder,trialFolder,'tracked_video');
spec_dir_path           = fullfile(baseFolder,trialFolder,'spec');
freqtracks_dir_path     = fullfile(baseFolder,trialFolder,'freqtracks');

trackedVideo_file_name  = strrep(particle_file_name,'particle.mat','video');
spec_file_name          = strrep(particle_file_name,'particle','spec');
freqtracks_file_name    = strrep(particle_file_name,'particle','tracks');

%% Load files
    
particleTracked         = load(fullfile(tracked_dir_path, particle_file_name),'xMean', 'yMean','thMean','gridCoord','tankCoord','nFish','ampAll','fishTime');
spec                    = load(fullfile(spec_dir_path, spec_file_name),'spec');
freqtracks              = load(fullfile(freqtracks_dir_path, freqtracks_file_name),'tracks');

spec = hlp_deserialize(spec.spec);
tracks = freqtracks.tracks;
Smag = mean(normSpecMag(spec.S),3);

%% Video parameters

nFrame                  = size(particleTracked.thMean,2);
frameInterval           = 767:962;
frameRate               = 8;
fishSelect              = [9 10];
nFrames                 = frameInterval(end)-frameInterval(1)+1;

%% Plot
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.01], [0.125 0.125], [0.03 0.01]);

fW                  = 1;
fL                  = 7;
colrs               = distinguishable_colors(length(fishSelect),{'r','k','y'});
scrsz               = get(groot,'ScreenSize');
hAxis               = figure('Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)]);
set(gcf,'color',[1 1 1]);

writerObj           = VideoWriter(fullfile(trackedVideo_dir_path, trackedVideo_file_name),'MPEG-4');
writerObj.FrameRate = frameRate;

ids = unique([tracks.id]);
nTracks = length(ids);

progressbar('Writing Video');
open(writerObj);  

flag = zeros(1,particleTracked.nFish);
dispStep = ones(1,particleTracked.nFish);
time1 = particleTracked.fishTime(frameInterval(1));
time2 = particleTracked.fishTime(frameInterval(end));

for frameIdx = frameInterval
    progressbar((frameIdx-frameInterval(1))/nFrames);

    time = particleTracked.fishTime(frameIdx);
    
    figure(hAxis), cla;
    
    h1 = subplot(1,2,1);
    hold on;

    plotSpectrogram(gca,spec.T,spec.F,Smag);
    
    for k = 1:length(fishSelect)
        idTrack = tracks([tracks.id]==ids(fishSelect(k)));
        [~,idx] = sort([idTrack.t]);
        idTrack = idTrack(idx);

        plot([idTrack.t],[idTrack.f1],'.-','Color',colrs(k,:),'LineWidth',3);
    end
    
    ylimits = [370,410];
    plot([time,time],ylimits,'--y','LineWidth',1);

    ylim(ylimits);
    xlim([time1,time2]);
    h1.FontSize = 12;
    xlim([spec.T(1),spec.T(end)]);

    xlabel('Time (s)','FontSize',12);
    ylabel('Frequency (Hz)','FontSize',12);
    title('Spectrogram with Frequency Tracks','FontSize',18);
    hold off;
    
    h2 = subplot(1,2,2), hold on;
    plot(particleTracked.gridCoord(:,1),particleTracked.gridCoord(:,2),'ok','LineWidth',3.01);
    plot(particleTracked.gridCoord(:,1),particleTracked.gridCoord(:,2),'+k','LineWidth',3.01);
    
    for i = 1:length(fishSelect)
        fID = fishSelect(i);
        if sum(~isnan(squeeze(particleTracked.ampAll(fID,:,frameIdx))))
            colrsMat = [colrs(i,:);colrs(i,:)];
            dispStep(fID) = frameIdx;
            flag(fID) = 0;
        else
            colrsMat = [1 1 1;colrs(i,:)];
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
    h2.FontSize = 12;
    set(gca,'YTick',[]);
    xlabel('Distance (cm)','FontSize',12);
    title('Overhead View with Spatial Estimates','FontSize',18);
    hold off;
    
    f = getframe(hAxis);
    writeVideo(writerObj,f);

end
close(writerObj);
progressbar(1);

display('Done')