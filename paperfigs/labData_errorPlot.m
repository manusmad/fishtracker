clear
clc
%%
% Add all Mathworks folders
addpath('../packages/addpath_recurse');
addpath_recurse('..');

%% Select datafolder - select the folder that contains the subfolders tracked,videotracks, raw etc
baseFolder      = uigetdir(pwd,'Select dataset folder ...');
%%
% Uncomment following for generating tube fish error plot
% trialFolder{1}  = '140403_singleTubeTrials';
% trialFolder{2}  = '140417_threeTubeTrials';
% % Uncomment following for generating free fish error plot
trialFolder{1}  = '140406_singleFreeTrials';
trialFolder{2}  = '140422_threeFreeTrials';
%%            
allError = [];

for dataFoldLoop = 1:length(trialFolder)
    if dataFoldLoop == 2
        clear fishMap
        load(fullfile(baseFolder,trialFolder{dataFoldLoop},'fishMap.mat'));
    end
    
    % Extracting file names
    dir_struct                  = dir(fullfile(baseFolder,trialFolder{dataFoldLoop},'tracked'));
    [sorted_names,~]            = sortrows({dir_struct.name}');
    allFile_names               = sorted_names;
    tracks_search               = strfind(allFile_names,'particle.mat');
    tracksIdx                   = find(not(cellfun('isempty', tracks_search)));
    tracksList                  = {allFile_names{tracksIdx}};

    for dataIdx = 1:length(tracksList)   
        filename                = tracksList{dataIdx};
        load(fullfile(baseFolder,trialFolder{dataFoldLoop},'tracked',tracksList{dataIdx}));
        vidTracked              = load(fullfile(baseFolder,trialFolder{dataFoldLoop},'videotracks',strrep(tracksList{dataIdx},'particle','videotracks')));
        scaleFact               = 6;
        gridTemp                = (vidTracked.gridcen-repmat(vidTracked.gridcen(5,:),9,1))/scaleFact;
        gridCoord               = [gridTemp(:,1) -gridTemp(:,2)];
        
        nSteps                  = length(vidTracked.frameTime);
        elecTime                = particle.t;
        timeIdx                 = zeros(nSteps,1);
        for n = 1:nSteps
           [~,timeIdx(n)] = min(abs(elecTime - vidTracked.frameTime(n)));
        end

        for id = 1:particle.nFish
            if particle.nFish == 1
                notNan          = ~isnan(vidTracked.fishCen(:,1));
                X               = vidTracked.fishCen(notNan,1:2);
                X               = (X-repmat(vidTracked.gridcen(5,:),length(notNan),1))/scaleFact;
                withinGridIdx   = (X(:,1) < (max(gridCoord(:,1))) & (X(:,1) > min(gridCoord(:,1))) ...
                                & X(:,2) < (max(gridCoord(:,2))) & X(:,2) > (min(gridCoord(:,2))));
                distError       = sqrt((X(:,1) - particle.fish(id).x(timeIdx(notNan))).^2+(X(:,2) - particle.fish(id).y(timeIdx(notNan))).^2);
                thError         = circ_dist(particle.fish(id).theta(timeIdx(notNan)), vidTracked.fishTheta(notNan,:));
            else
                notNan          = ~isnan(vidTracked.fishCen(:,1,fishMap(dataIdx,id)));
                X               = vidTracked.fishCen(notNan,:,fishMap(dataIdx,id));
                X               = (X-repmat(vidTracked.gridcen(5,:),length(notNan),1))/scaleFact;
                withinGridIdx   = (X(:,1) < (max(gridCoord(:,1))) & (X(:,1) > min(gridCoord(:,1))) ...
                                & X(:,2) < (max(gridCoord(:,2))) & X(:,2) > (min(gridCoord(:,2))));
                distError       = sqrt((X(:,1) - particle.fish(id).x(timeIdx(notNan))).^2+(X(:,2) - particle.fish(id).y(timeIdx(notNan))).^2);
                thError         = circ_dist(particle.fish(id).theta(timeIdx(notNan)), vidTracked.fishTheta(notNan,fishMap(dataIdx,id)));
            end
            allError            = [allError; distError thError withinGridIdx];
        end
    end
end
%%
    
colrs                           = distinguishable_colors(2);
ThError                         = rad2deg(allError(:,2));
[~,centersAll]                  = hist(ThError,2000);

GridIdx{1}                      = find(allError(:,3)==1);
GridIdx{2}                      = find(allError(:,3)==0);

scrsz = get(groot,'ScreenSize');
h1 = figure('Position',[1 scrsz(4)/2 scrsz(3)/1.6 scrsz(4)]);
h2 = figure('Position',[1 scrsz(4)/2 scrsz(3)/1.6 scrsz(4)]);

for i = 1:2
    figure(h1)
    allThError = rad2deg(allError(GridIdx{i},2));
        hline = rose(deg2rad(allThError),110);
    if i == 2
        uistack(hline,'down')
    end
    title('Orientation Error Radial Histogram','FontSize',18);
    % 
    flipPosIdx = find(allThError > 90);
    allThError(flipPosIdx) = allThError(flipPosIdx) -180;

    flipNegIdx = find(allThError < -90);
    allThError(flipNegIdx) = allThError(flipNegIdx) +180;

    allThError = abs(allThError);
    [countsTh,centersTh] = hist(allThError,centersAll);
    hold on
figure(h2)
    hold on
    plot(centersTh,cumsum(countsTh/sum(countsTh))*100,'Color',colrs(i,:),'LineWidth',1);
    alpha(0.3); 
    xlabel('Angle Estimate Error (in degrees)','FontSize',15); ylabel('Cumulative percentage of pose estimates','FontSize',15);
    title('Orientation Error','FontSize',18);
    ylim([0 100])
    xlim([0 90])
end
title('Orientation Error','FontSize',18);
set(gca,'FontSize',15)

%%
colrs                           = distinguishable_colors(2);
centersAll                      = linspace(0,70,10000);

scrsz = get(groot,'ScreenSize');
figure('Position',[1 scrsz(4)/2 scrsz(3)/1.6 scrsz(4)]);
GridIdx{1} = find(allError(:,3)==1);
GridIdx{2} = find(allError(:,3)==0);

for i = 1:2
    [counts,centers]            = hist(allError(GridIdx{i},1),centersAll);
    hold on
    plot(centers,cumsum(counts/sum(counts))*100,'Color',colrs(i,:),'LineWidth',1);
    alpha(0.3);
end
xlabel('Position Estimate Error (in cm)','FontSize',15); ylabel('Cumulative percentage of pose estimates','FontSize',15);
plot([20 20],get(gca,'ylim'),'color','k','LineWIdth',2);
title({'Position Error'},'FontSize',18);
ylim([0 100])
% xlim([0 max(centersAll)])
xlim([0 100])
set(gca,'FontSize',15)
