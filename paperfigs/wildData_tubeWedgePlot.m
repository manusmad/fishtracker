clear 
clc

    % Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('../packages');
addpath_recurse('.');

%%
[file_name,path_name]   = uigetfile({'Terraronca_Calibration*particle.mat'},'Select datafile ...',pwd, ...
                                    'MultiSelect', 'on');
%%  
C = strsplit(path_name,filesep);
baseFolder = strjoin(C(1:end-2),filesep);

file_parts              = strsplit(file_name, '_');
imageFileName           = [strjoin(file_parts(1:3),'_') '.jpg'];
handClickFileName       = [strjoin(file_parts(1:3),'_') '_handclickTube.mat'];

%Tube fish in freqtracks: 3 tubes in each dataset, rows 1 thru 4 -->
%datasets 1 thru 4
iFishMat = [6 9 10;...
            8 10 12;...
            8 12 15;...
            9 12 14]; 

iFishVec = iFishMat(str2double(file_parts{3}),:);        
%%
load(fullfile(path_name, file_name),'xMean', 'yMean','thMean','gridCoord');
load(fullfile(baseFolder,handClickFileName));
%%
gridCenter = [1983 1452];
scaleFact = 23.8;

for iLoop = 1:length(iFishVec)
    i = iFishVec(iLoop);
    xFish(iLoop) = scaleFact*mean(xMean(i,:))+gridCenter(1);
    yFish(iLoop) = scaleFact*mean(yMean(i,:))+gridCenter(2);
    thFish(iLoop) = wrapTo2Pi(circ_mean(atan(tan(wrapTo2Pi(thMean(i,:))))'))'; 
    
%     posStd(iLoop) = max([std(xMean(i,:)) std(yMean(i,:))]); 
    posStd(iLoop) = std(sqrt((xMean(i,:) - mean(xMean(i,:))).^2+ (yMean(i,:) - mean(xMean(i,:))).^2));
    thStd(iLoop) = circ_std(2*thMean(i,:),[],[],2);
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
%%
plotFig = 1;
if plotFig
    imageMat = imread(fullfile(baseFolder,imageFileName));
    imshow(imageMat,'InitialMagnification',50);
    hold on;
    scatter(scaleFact*gridCoord(1:end,1)+gridCenter(1),scaleFact*gridCoord(1:end,2)+gridCenter(2),100,'filled')
    for iLoop = 1:length(iFishVec)
        viscircles([xFish(iLoop) yFish(iLoop)],2*scaleFact*posStd(iLoop));

        quiver(xFish(iLoop),yFish(iLoop),2*scaleFact*posStd(iLoop)*cos(thFish(iLoop)+2*thStd(iLoop)),2*scaleFact*posStd(iLoop)*sin(thFish(iLoop)+2*thStd(iLoop)),'LineWidth',1.5,'Color','r');
        quiver(xFish(iLoop),yFish(iLoop),2*scaleFact*posStd(iLoop)*cos(thFish(iLoop)-2*thStd(iLoop)),2*scaleFact*posStd(iLoop)*sin(thFish(iLoop)-2*thStd(iLoop)),'LineWidth',1.5,'Color','r');
        quiver(xFish(iLoop),yFish(iLoop),2*scaleFact*posStd(iLoop)*cos(thFish(iLoop)),2*scaleFact*posStd(iLoop)*sin(thFish(iLoop)),'LineWidth',1.5,'Color','g');

        quiver(xFish(iLoop),yFish(iLoop),2*scaleFact*posStd(iLoop)*cos(thFish(iLoop)+pi+2*thStd(iLoop)),2*scaleFact*posStd(iLoop)*sin(thFish(iLoop)+pi+2*thStd(iLoop)),'LineWidth',1.5,'Color','r');
        quiver(xFish(iLoop),yFish(iLoop),2*scaleFact*posStd(iLoop)*cos(thFish(iLoop)+pi-2*thStd(iLoop)),2*scaleFact*posStd(iLoop)*sin(thFish(iLoop)+pi-2*thStd(iLoop)),'LineWidth',1.5,'Color','r');
        quiver(xFish(iLoop),yFish(iLoop),2*scaleFact*posStd(iLoop)*cos(thFish(iLoop)+pi),2*scaleFact*posStd(iLoop)*sin(thFish(iLoop)+pi),'LineWidth',1.5,'Color','g');
        scatter(tubeCen(1,iLoop),tubeCen(2,iLoop),200,'filled')
    end
end

export_fig(fullfile(baseFolder,'figures','freeFish_TerraRonca_01_covar95ellipse'),'-pdf','-nocrop','-painters')