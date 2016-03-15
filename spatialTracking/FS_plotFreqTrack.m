function FS_plotFreqTrack(handles)

type        = handles.dataType;
fishSelect  = handles.fishSelect; 
numFish     = length(fishSelect);

if strcmp(handles.heatType,'theoretical')
    amp = zeros(1,size(squeeze(handles.ampMean(1,:,handles.sNo)),2));
    for fID = 1:numFish
        i = fishSelect(fID);
        if sum(isnan(squeeze(handles.ampMean(i,:,handles.sNo)))) < size(squeeze(handles.ampMean(1,:,handles.sNo)),2)
           amp = amp + squeeze(handles.ampMean(i,:,handles.sNo));
        end   
    end
% theoretAmp = amp;


    gridCoord   = handles.gridCoord;
    tankCoord   = handles.tankCoord;
    divNo = 100;

    xRange = max(gridCoord(:,1))- min(gridCoord(:,1));
    yRange = max(gridCoord(:,2))- min(gridCoord(:,2));
    xVec = min(gridCoord(:,1)):(max(gridCoord(:,1))- min(gridCoord(:,1)))/divNo:max(gridCoord(:,1));
    yVec = min(gridCoord(:,2)):(max(gridCoord(:,2))- min(gridCoord(:,2)))/divNo:max(gridCoord(:,2));
    [xq, yq] = meshgrid(xVec, yVec);

    notNanIdx = find(~isnan(amp));
    vq = griddata(gridCoord(notNanIdx,1),gridCoord(notNanIdx,2),amp(notNanIdx),xq,yq);
    vq = flipdim(vq ,1);

    axes(handles.ax_freqTrack); cla

    imagesc(vq); hold on
    save('theoHeat','vq')

    imGridCoord = (divNo+1)*(gridCoord - repmat([min(gridCoord(:,1)) min(gridCoord(:,2))],size(gridCoord,1),1))./repmat([xRange yRange],size(gridCoord,1),1);
    plot(imGridCoord(:,1),imGridCoord(:,2),'ow');
    plot(imGridCoord(:,1),imGridCoord(:,2),'+w');

    set (gca, 'xtick', [],'ytick', []);
    axis tight
else
    type        = handles.dataType;
    fishSelect  = handles.fishSelect; 
    numFish     = length(fishSelect);

    freqCell    = handles.freqCell;
    nFish       = handles.nFish;
    if strcmp(type,'tank')
        stepNo      = handles.timeIdx(handles.sNo);
    else
        stepNo      = handles.sNo;
    end

    axes(handles.ax_freqTrack)
    reset(handles.ax_freqTrack);
    cla
    colrs = distinguishable_colors(nFish); 

    for fID = 1:numFish
        i = fishSelect(fID);
        plot(freqCell{i}(:,1),freqCell{i}(:,2),'Color',colrs(i,:),'LineWidth',1.5);hold on
    end

    axis tight
    ylim(ylim + [-1 1]*0.1*diff(ylim));
    line([freqCell{i}(stepNo,1),freqCell{i}(stepNo,1)],ylim,'Color', 'w','LineWidth',1.2);
    set(gca, 'fontsize',8)
    set(gca,'Color',[0 0 0]);
end