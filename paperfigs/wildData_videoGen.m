% Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('..');

%% Select datafolder - select the folder that contains the subfolders freqtracks,videotracks, raw etc
[file_name,path_name]  = uigetfile({'*particle.mat'},'Select tracked wild file ...',pwd, ...
                                    'MultiSelect', 'off');

%%                                
C = strsplit(path_name,filesep);
baseFolder = strjoin(C(1:end-2),filesep);
trackedVideo_dir_path   = fullfile(baseFolder,'tracked_video');

trackedVideo_file_name  = strrep(file_name,'particle','video');
%% Load files
    
particleTracked         = load(fullfile(path_name, file_name),'xMean', 'yMean','thMean','gridCoord','tankCoord','nFish','ampAll');

%% Video parameters

nFrame                  = size(particleTracked.thMean,2);
frameInterval           = 767:962;
frameRate               = 8;
fishSelect              = [9 10];

%%
fW                  = 1;
fL                  = 7;
colrs               = distinguishable_colors(particleTracked.nFish);
scrsz               = get(groot,'ScreenSize');
hAxis               = figure('Position',[1 scrsz(4)/2 scrsz(3)/1.6 scrsz(4)]);
set(gcf,'color',[0 0 0]);

writerObj           = VideoWriter(fullfile(trackedVideo_dir_path, trackedVideo_file_name),'MPEG-4');
writerObj.FrameRate = frameRate;
open(writerObj);  

flag = zeros(1,particleTracked.nFish);
dispStep = ones(1,particleTracked.nFish);
for frameLoop = 1:length(frameInterval)
    hold on;
    plot(particleTracked.gridCoord(:,1),particleTracked.gridCoord(:,2),'ok','LineWidth',3.01);
    plot(particleTracked.gridCoord(:,1),particleTracked.gridCoord(:,2),'+k','LineWidth',3.01);
    
    frameIdx = frameInterval(frameLoop);       
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
    cla(hAxis)
end
close(writerObj);
display('Done')

