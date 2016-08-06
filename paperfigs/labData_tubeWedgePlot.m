clear 
clc

    % Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('../packages');
addpath_recurse('.');

%%
[file_name,tracked_dir_path]   = uigetfile({'*particle.mat'},'Select datafile ...',pwd, ...
                                    'MultiSelect', 'off');
%% 
C = strsplit(tracked_dir_path,filesep);
baseFolder = strjoin(C(1:end-2),filesep);

tempStr = strsplit(file_name,'_');
datasetName = strjoin(tempStr(1:end-1),'_');

fig_dir_path            = fullfile(baseFolder,'figures');
videotracks_dir_path    = fullfile(baseFolder,'videotracks');
videotracks_file_name   = strrep(file_name,'particle','videotracks');
%% Load files 
particleTracked         = load(fullfile(tracked_dir_path, file_name),'xMean', 'yMean','thMean');
vidTracked              = load(fullfile(videotracks_dir_path, videotracks_file_name),'gridcen','tankcen','nFish','tubeFrame');            

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
end

export_fig(fullfile(fig_dir_path,datasetName),'-pdf','-nocrop','-painters')