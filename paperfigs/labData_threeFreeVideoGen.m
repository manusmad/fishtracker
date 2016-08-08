% Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('..');

%% Select datafolder - select the folder that contains the subfolders tracked,videotracks, raw etc
baseFolder = uigetdir(pwd,'Select dataset folder ...');
trialFolder = '140422_threeFreeTrials';

%% Three Free
% 
% Uncomment one of the following
% particle_file_name = '140422_001_05m50s_06m09s_particle.mat';
% particle_file_name = '140422_001_08m40s_09m05s_particle.mat';
% particle_file_name = '140422_001_09m12s_09m37s_particle.mat'; 
particle_file_name = '140422_001_09m50s_11m00s_particle.mat'; 

% Uncomment the following lines
tracked_dir_path        = fullfile(baseFolder,trialFolder,'tracked');
videotracks_dir_path    = fullfile(baseFolder,trialFolder,'videotracks');
trackedVideo_dir_path   = fullfile(baseFolder,trialFolder,'tracked_video');
spec_dir_path           = fullfile(baseFolder,trialFolder,'spec');
freqtracks_dir_path     = fullfile(baseFolder,trialFolder,'freqtracks');

videotracks_file_name   = strrep(particle_file_name,'particle','videotracks');
trackedVideo_file_name  = strrep(particle_file_name,'particle','video');
spec_file_name          = strrep(particle_file_name,'particle','spec');
freqtracks_file_name    = strrep(particle_file_name,'particle','tracks');

video_file_path         = fullfile(baseFolder,trialFolder,'raw','140422_001.mp4');

%% Load files
    
particleTracked         = load(fullfile(tracked_dir_path, particle_file_name),'xMean', 'yMean','thMean');
vidTracked              = load(fullfile(videotracks_dir_path, videotracks_file_name),'gridcen', 'tankcen','xcrop','ycrop','nFish','frameIdx','frameTime');            
vObj                    = VideoReader(video_file_path);  

spec                    = load(fullfile(spec_dir_path, spec_file_name),'spec');
freqtracks              = load(fullfile(freqtracks_dir_path, freqtracks_file_name),'tracks');

spec = hlp_deserialize(spec.spec);
Smag = mean(normSpecMag(spec.S),3);

%%

fW                  = 3;
fL                  = 20;
colrs               = distinguishable_colors(vidTracked.nFish);
scrsz               = get(groot,'ScreenSize');
hAxis               = figure('Position',[1 scrsz(4)/2 scrsz(3)/1.6 scrsz(4)]);
set(gcf,'color',[0 0 0]);

writerObj           = VideoWriter(fullfile(trackedVideo_dir_path, trackedVideo_file_name),'MPEG-4');
writerObj.FrameRate = 9;
nFrames = size(vidTracked.frameIdx,2);

progressbar('Writing Video');
open(writerObj);
for timeLoop = 1:nFrames
        progressbar(timeLoop/nFrames);
        
        frame = read(vObj,vidTracked.frameIdx(timeLoop));
        frame = frame(vidTracked.ycrop(1):vidTracked.ycrop(2),vidTracked.xcrop(1):vidTracked.xcrop(2),:);
        
        time = vidTracked.frameTime(timeLoop);
        
        figure(hAxis), cla;
        
        subplot(1,2,1);
        hold on;
        [~,hSpec] = plotSpectrogram(gca,spec.T,spec.F,Smag);
        [~,hTracks] = plotTracks(gca,freqtracks.tracks,[]);
        
        ylimits = [280,400];
        plot([time,time],ylimits,'--y','LineWidth',1);
        
        ylim(ylimits);
        xlim([spec.T(1),spec.T(end)]);
        
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        hold off;
        
        subplot(1,2,2);
        imshow(frame,'InitialMagnification',100), 
        hold on;
        plot(vidTracked.tankcen(:,1),vidTracked.tankcen(:,2),'+b','LineWidth',1.01);
        plot(vidTracked.gridcen(:,1),vidTracked.gridcen(:,2),'ok','LineWidth',3.01);
        plot(vidTracked.gridcen(:,1),vidTracked.gridcen(:,2),'+k','LineWidth',3.01);
        for i = 1:vidTracked.nFish
                pb=plot_ellipse(fW,fL,particleTracked.xMean(i,timeLoop),particleTracked.yMean(i,timeLoop),rad2deg(particleTracked.thMean(i,timeLoop)),[colrs(i,:); colrs(i,:)]);       
                alpha(pb,0.65);      
        end
        f = getframe(hAxis);
        writeVideo(writerObj,f);
end
close(writerObj);
progressbar(1);

display('Done')