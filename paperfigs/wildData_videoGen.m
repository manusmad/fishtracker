% Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('..');

baseFolder = uigetdir(pwd,'Select dataset folder ...');
trialFolder = 'terraronca';
            
%% Choose which file to generate video for
% particle_file_name = 'TerraRonca_Calibration_01_100s_particle.mat';
% particle_file_name = 'TerraRonca_Calibration_02_100s_particle.mat';
% particle_file_name = 'TerraRonca_Calibration_03_100s_particle.mat';
particle_file_name = 'TerraRonca_Calibration_04_100s_particle.mat';

tracked_dir_path        = fullfile(baseFolder,trialFolder,'tracked');
trackedVideo_dir_path   = fullfile(baseFolder,trialFolder,'tracked_video');
spec_dir_path           = fullfile(baseFolder,trialFolder,'spec');
freqtracks_dir_path     = fullfile(baseFolder,trialFolder,'freqtracks');

spec_file_name          = strrep(particle_file_name,'particle','spec');
freqtracks_file_name    = strrep(particle_file_name,'particle','tracks');

trackedVideo_file_name  = strrep(particle_file_name,'particle.mat','video');

%% Load files
    
load(fullfile(tracked_dir_path, particle_file_name));
spec                    = load(fullfile(spec_dir_path, spec_file_name),'spec');
freqtracks              = load(fullfile(freqtracks_dir_path, freqtracks_file_name),'tracks');

spec = hlp_deserialize(spec.spec);
tracks = freqtracks.tracks;
Smag = mean(normSpecMag(spec.S),3);

%% Plot
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.01], [0.125 0.125], [0.03 0.01]);

fW                  = 1;
fL                  = 7;
colrs               = distinguishable_colors(particle.nFish,{'r','k','y'});
scrsz               = get(groot,'ScreenSize');
hAxis               = figure('Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)]);
set(gcf,'color',[1 1 1]);

nFrames             = length(particle.t);
frameRate           = 8;
writerObj           = VideoWriter(fullfile(trackedVideo_dir_path, trackedVideo_file_name),'MPEG-4');
writerObj.FrameRate = frameRate;

ids = unique([tracks.id]);
nTracks = length(ids);

isObs = ~isnan(squeeze(sum(particleTracked.ampAll,2)));
[firstIdx,lastIdx] = deal(zeros(particleTracked.nFish,1));
for fID = 1:particleTracked.nFish
    firstIdx(fID) = find(isObs(fID,:),1,'first');
    lastIdx(fID) = find(isObs(fID,:),1,'last');
end

progressbar('Writing Video');
open(writerObj);  
elapsedTime = zeros(nFrames,1);

flag = zeros(1,particle.nFish);
dispStep = ones(1,particle.nFish);
for frameIdx = 1:nFrames
    tic;
    progressbar(frameIdx/nFrames);

    time = particle.t(frameIdx);
    
    figure(hAxis), clf;
    
    h1 = subplot(1,2,1);
    hold on;
    plotSpectrogram(gca,spec.T,spec.F,Smag);
    
    for k = 1:nTracks
        idTrack = tracks([tracks.id]==ids(k));
        [~,idx] = sort([idTrack.t]);
        idTrack = idTrack(idx);

        plot([idTrack.t],[idTrack.f1],'.-','Color',colrs(k,:),'LineWidth',3);
    end
    
    ylimits = [290,450];
    plot([time,time],ylimits,'--y','LineWidth',1);

    ylim(ylimits);
    h1.FontSize = 12;
    xlim([spec.T(1),spec.T(end)]);

    xlabel('Time (s)','FontSize',12);
    ylabel('Frequency (Hz)','FontSize',12);
    title('Spectrogram with Frequency Tracks','FontSize',18);
    hold off;
    
    subplot(1,2,2), hold on;
    plot(particle.gridCoord(:,1),particle.gridCoord(:,2),'ok','LineWidth',3.01);
    plot(particle.gridCoord(:,1),particle.gridCoord(:,2),'+k','LineWidth',3.01);
    
    for fID = 1:particle.nFish
        visible = frameIdx>=firstIdx(fID) && frameIdx<=lastIdx(fID);
        
        if visible
            if isObs(fID,frameIdx)
                colrsMat = [colrs(fID,:);colrs(fID,:)];
            else
                colrsMat = [1 1 1;colrs(fID,:)];         
            end
            pb=plot_ellipse(fW,fL,particle.fish(fID).x(frameIdx),particle.fish(fID).y(frameIdx),rad2deg(particle.fish(fID).theta(frameIdx)),[colrsMat(1,:); colrsMat(2,:)]);       
            alpha(pb,0.65);
        end
    end
    xlim([-125 125])
    ylim([-125 125])
    set(gca,'YTick',[]);
    set(gca,'XTick',[]);
    set(gca,'Visible','off');
    
    plot([-125,-75],[-125,-125],'LineWidth',2,'Color','k');
    plot([-125,-125],[-120,-130],'LineWidth',2,'Color','k');
    plot([-75,-75],[-120,-130],'LineWidth',2,'Color','k');
    text(-105,-130,'50 cm');
    
    title('Overhead View with Spatial Estimates','FontSize',18);
    hold off;
    
    f = getframe(hAxis);
    writeVideo(writerObj,f);
    
    elapsedTime(frameIdx) = toc;
    fprintf('\nFrame %d of %d (%f s.)',frameIdx,nFrames,elapsedTime(frameIdx));
end
close(writerObj);
progressbar(1);

display('Done')