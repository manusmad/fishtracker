function FS_plotFreqTrack(handles)

%% Description: 
% Plots either:
%
% 1) the frequency tracks of the fish population in the dataset 
% 2) Plots the distribution of actual electrode readings as a linearly 
%    interpolated heatmap 
%
% in spatialTracking GUI. The two plots can be switched at the press of the
% button below the figure in the GUI. 
%
% Author: Ravikrishnan Perur Jayakumar
%%

fishSelect  = handles.fishSelect; 
numFish     = length(fishSelect);

if ~handles.particle.wildTag
    stepNo      = handles.timeIdx(handles.sNo);
else
    stepNo      = handles.sNo;
end

if strcmp(handles.heatType,'theoretical')
    amp = zeros(handles.particle.nChannels,1);
    for fID = 1:numFish
        i = fishSelect(fID);
        if sum(isnan(handles.particle.fish(i).ampTheor(:,stepNo))) < handles.particle.nChannels
           amp = amp + handles.particle.fish(i).ampTheor(:,stepNo);
        end   
    end
    gridCoord   = handles.gridCoord;
    divNo = 100;

    xRange = max(gridCoord(:,1))- min(gridCoord(:,1));
    yRange = max(gridCoord(:,2))- min(gridCoord(:,2));
    xVec = min(gridCoord(:,1)):(max(gridCoord(:,1))- min(gridCoord(:,1)))/divNo:max(gridCoord(:,1));
    yVec = min(gridCoord(:,2)):(max(gridCoord(:,2))- min(gridCoord(:,2)))/divNo:max(gridCoord(:,2));
    [xq, yq] = meshgrid(xVec, yVec);

    notNanIdx = find(~isnan(amp));
    vq = griddata(gridCoord(notNanIdx,1),gridCoord(notNanIdx,2),amp(notNanIdx),xq,yq);
    if ~get(handles.Wild,'value')
        vq = flipdim(vq ,1);
    end

    axes(handles.ax_freqTrack); cla

    imagesc(vq); hold on
    save('theoHeat','vq')

    imGridCoord = (divNo+1)*(gridCoord(:,1:2) - repmat([min(gridCoord(:,1)) min(gridCoord(:,2))],size(gridCoord,1),1))./repmat([xRange yRange],size(gridCoord,1),1);
    plot(imGridCoord(:,1),imGridCoord(:,2),'ow');
    plot(imGridCoord(:,1),imGridCoord(:,2),'+w');

    set (gca, 'xtick', [],'ytick', []);
    axis tight
else
    axes(handles.ax_freqTrack)
    reset(handles.ax_freqTrack);
    cla
    colrs = distinguishable_colors(handles.particle.nFish); 

    for fID = 1:numFish
        i = fishSelect(fID);
        plot(handles.particle.fish(i).freq(:,1),handles.particle.fish(i).freq(:,2),'Color',colrs(i,:),'LineWidth',1.5);hold on
    end

    axis tight
    ylim(ylim + [-1 1]*0.1*diff(ylim));
    line([handles.particle.t(stepNo),handles.particle.t(stepNo)],ylim,'Color', 'k','LineWidth',1.2);
    set(gca, 'fontsize',8)
    set(gca,'Color',[1 1 1]);
end