% function FS_errorPlot
clear
clc

% Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('../packages');
addpath_recurse('.');
%% Select datafolder - select the folder that contains the subfolders freqtracks,videotracks, raw etc
folder_name = uigetdir(pwd,'Select dataset folder ...');
%% Single Free

% Uncomment one of the following
% file_name = '140406_002_01m07s_01m27s_tracks_particle.mat';
% file_name = '140406_002_03m34s_03m54s_tracks_particle.mat';
% file_name = '140406_002_07m05s_07m55s_tracks_particle.mat';

% Uncomment the following lines
% freqtracks_dir_path     = fullfile(folder_name,'freqtracks');
% videotracks_dir_path    = fullfile(folder_name,'videotracks');
% trackedVideo_dir_path   = fullfile(folder_name,'tracked_video');
% video_file_path         = fullfile(folder_name,'raw','140406_002.mp4');
% videotracks_file_name   = strrep(file_name,'tracks_particle','videotracks');
% trackedVideo_file_name  = strrep(file_name,'tracks_particle','video');
%% Three Free

% Uncomment one of the following
% file_name = '140422_001_05m50s_06m09s_tracks_particle.mat';
% file_name = '140422_001_08m40s_09m05s_tracks_particle.mat';
% file_name = '140422_001_09m12s_09m37s_tracks_particle.mat'; 
file_name = '140422_001_09m50s_11m00s_tracks_particle.mat'; 

% Uncomment the following lines
freqtracks_dir_path     = fullfile(folder_name,'freqtracks');
videotracks_dir_path    = fullfile(folder_name,'videotracks');
trackedVideo_dir_path   = fullfile(folder_name,'tracked_video');
video_file_path         = fullfile(folder_name,'raw','140422_001.mp4');
videotracks_file_name   = strrep(file_name,'tracks_particle','videotracks');
trackedVideo_file_name  = strrep(file_name,'tracks_particle','video');
%% Load files
    
particleTracked         = load(fullfile(freqtracks_dir_path, file_name),'xMean', 'yMean','thMean');
vidTracked              = load(fullfile(videotracks_dir_path, videotracks_file_name),'gridcen', 'tankcen','xcrop','ycrop','nFish','frameIdx');            
vObj                    = VideoReader(video_file_path);  

%%
fW                  = 3;
fL                  = 20;
colrs               = distinguishable_colors(vidTracked.nFish);
scrsz               = get(groot,'ScreenSize');
hAxis               = figure('Position',[1 scrsz(4)/2 scrsz(3)/1.6 scrsz(4)]);
set(gcf,'color',[0 0 0]);

writerObj           = VideoWriter(fullfile(trackedVideo_dir_path, trackedVideo_file_name),'MPEG-4');
writerObj.FrameRate = 9;
open(writerObj);  
for timeLoop = 1:size(vidTracked.frameIdx,2)
        frame = read(vObj,vidTracked.frameIdx(timeLoop));
        frame = frame(vidTracked.ycrop(1):vidTracked.ycrop(2),vidTracked.xcrop(1):vidTracked.xcrop(2),:);
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
        cla(hAxis)
end
close(writerObj);
display('Done')

