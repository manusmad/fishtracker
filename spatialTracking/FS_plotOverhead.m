function FS_plotOverhead(handles)

filename    = handles.filename;
type        = handles.dataType;
gridCoord   = handles.gridCoord;
tankCoord   = handles.tankCoord;
xMean       = handles.xMean;
yMean       = handles.yMean;
thMean      = handles.thMean;
nFish       = handles.nFish;
vidParams   = handles.vidParams; 
stepNo      = handles.sNo;
fishSelect  = handles.fishSelect; 
xPart       = handles.xPart;
xWeight     = handles.xWeight;
nPart       = handles.nPart;
file_idx    = handles.file_idx; 
numFish     = length(fishSelect); 
xFish       = handles.xFish;
yFish       = handles.yFish;
thFish      = handles.thFish;

axes(handles.ax_overhead)
cla
colrs = distinguishable_colors(nFish);

ThreeFishMap = [3 2 1;
                3 2	1;
                3 2	1;
                3 2	1;
                3 2	1;
                3 2	1;
                3 2	1;
                3 2	1;
                3 1	2;
                3 1	2;
                3 1	2;
                3 1	2;
                3 2	1];

ThreeTubeMap = [2 3 1; %1
                2 1 3; %2
                2 1 3; %3 
                2 1 3; %4
                3 1 2; %5 was 2 1 3
                2 3 1; %6
                2 3 1; %7
                2 3 1; %8
                2 3 1; %9
                2 3 1; %10
                2 3 1; %11
                2 3 1; %12
                2 1 3; %13
                2 1 3; %14
                2 1 3; %15
                2 3 1; %16
                2 1 3; %17
                2 1 3; %18
                2 3 1; %19
                1 2 3; %20
                3 1 2; %21
                3 2 1; %22
                3 2 1; %23
                1 2 3; %24
                3 2 1; %25
                2 1 3; %26 was 3 2 1
                1 2 3; %27
                3 2 1; %28
                3 2 1; %29
                2 1 3; %30 was 2 3 1
                3 2 1; %31
                3 2 1; %32
                3 2 1; %33
                1 2 3; %34
                3 2 1; %35
                2 3 1; %36
                2 3 1; %37
                2 3 1; %38
                2 3 1; %39
                2 1 3; %40
                ];
elecToVid = [];            
for i = 1:length(ThreeTubeMap)
    x = ThreeTubeMap(i,:);
    for j = 1:3
        elecToVid(i,j) = find(x ==j);
    end
end            
            
if strcmp(type,'tank')
    stepNoFish      = handles.timeIdx(handles.sNo);
else
    stepNoFish      = stepNo;
end

% plot(tankCoord(:,1),'ob','LineWidth',1.01),hold on;
plot(tankCoord(:,1),tankCoord(:,2),'COlor',[0.4,0.4,0.4],'LineWidth',10.01),hold on;
% plot(tankCoord(:,1),tankCoord(:,2),'+b','LineWidth',1.01);
% plot(tankCoord(:,1),tankCoord(:,2),'Color','k','LineWidth',5)
plot(gridCoord(:,1),gridCoord(:,2),'ok','LineWidth',3.01);
plot(gridCoord(:,1),gridCoord(:,2),'+k','LineWidth',3.01);

if strcmp(type,'wild')
    fW = 1.5;
    fL = 10;
    if handles.showTrack == 1
        for i = 1:numFish
            fishLoop = fishSelect(i);
            fishPresentIdx = find(sum(isnan(squeeze(handles.ampAll(fishLoop,:,:)))) ~= 16);
            fishPresentIdx = fishPresentIdx(fishPresentIdx<=size(xMean,2));
            scatter(xMean(fishLoop,fishPresentIdx,1),yMean(fishLoop,fishPresentIdx,1),20,colrs(fishLoop,:),'fill');
        end
    elseif handles.showTrack == 3
        for i = 1:numFish
            fishLoop = fishSelect(i);
            fishPresentIdx = find(sum(isnan(squeeze(handles.ampAll(fishLoop,:,:)))) ~= 16);
            fishPresentIdx = fishPresentIdx(fishPresentIdx<=size(xMean,2));
            scatter(xMean(fishLoop,fishPresentIdx(fishPresentIdx<=stepNo),1),yMean(fishLoop,fishPresentIdx(fishPresentIdx<=stepNo),1),20,colrs(fishLoop,:),'fill');
        end
    end

%     xlim([-handles.bndry,handles.bndry]);
%     ylim([-handles.bndry,handles.bndry]);  
    
    % set(gca,'YDir','reverse');
    %  axis off
elseif  strcmp(type,'sim')
    fW = 1.5;
    fL = 10;
    if handles.showVid == 1
        scatter(trajList{fishID}(1,:),trajList{fishID}(2,:),80,'k','fill');
    end
    if handles.showTrack == 1
        for i = 1:numFish
            fishLoop = fishSelect(i);
            scatter(xMean(fishLoop,:,1),yMean(fishLoop,:,1),20,colrs(fishLoop,:),'fill');
        end
    elseif handles.showTrack == 3
        for i = 1:numFish
            fishLoop = fishSelect(i);
            scatter(xMean(fishLoop,1:stepNo,1),yMean(fishLoop,1:stepNo,1),20,colrs(fishLoop,:),'fill');
        end
    end

%     xlim([-handles.bndry,handles.bndry]);
%     ylim([-handles.bndry,handles.bndry]);   
    % set(gca,'YDir','reverse');
    %  axis off
else
    fW = 3;
    fL = 20;
    if handles.showVid == 1
        for i = 1:numFish
            iFish = fishSelect(i);
            if nFish > 1  
                [~,foldername,~] = fileparts(handles.dir_path);

                if strcmp(foldername, '140417_threeTubeTrials')
                    mapFish = elecToVid(file_idx,iFish);
                elseif strcmp(foldername, '140422_threeFreeTrials')
                    mapFish = ThreeFishMap(file_idx,iFish);
                else
                    mapFish = iFish;
                end
            else
                mapFish = 1;
            end
%             scatter(vidParams.fishCen(:,1,mapFish),vidParams.fishCen(:,2,mapFish),20,colrs(iFish,:),'d');
            
            [x,ia,~] = unique(vidParams.fishCen(:,1,mapFish),'stable');
            y = vidParams.fishCen(ia,2,mapFish);
%             xx = min(x):1:max(x);
%             yy = spline(x,y,xx);
%             plot(x,y,'Color',colrs(iFish,:), 'LineWidth',1.5);
%             plot(x,y,'Color','r', 'LineWidth',2);
            plot_ellipse(fW/2,fL,vidParams.fishCen(stepNo,1,mapFish),vidParams.fishCen(stepNo,2,mapFish),rad2deg(vidParams.fishTheta(stepNo,mapFish)-pi/2),[colrs(iFish,:); 0 0 0]);
%             plot_ellipse(fW/2,fL,vidParams.fishCen(stepNo,1,mapFish),vidParams.fishCen(stepNo,2,mapFish),rad2deg(vidParams.fishTheta(stepNo,mapFish)-pi/2),[1 0 0; 0 0 0]);
            hold on
        end
    end
    if handles.showTrack == 1
        for i = 1:numFish
            fishLoop = fishSelect(i);
            scatter(xMean(fishLoop,:,1),yMean(fishLoop,:,1),20,colrs(fishLoop,:),'fill');
%             scatter(xFish(fishLoop,:,1),yFish(fishLoop,:,1),20,colrs(fishLoop,:),'fill');
            [xF,ia,~] = unique(xMean(fishLoop,:,1),'stable');
            yF        = yMean(fishLoop,ia,1);
            plot(xF,yF,'--','Color',colrs(fishLoop,:));
%             f=fit(xF',yF','poly3');
%             plot(f,xF,yF)
%             plot(xF,yF,'--','Color',colrs(fishLoop,:));
        end
    elseif handles.showTrack == 3
        
        for i = 1:numFish
            fishLoop = fishSelect(i);
            scatter(xMean(fishLoop,1:stepNo,1),yMean(fishLoop,1:stepNo,1),20,colrs(fishLoop,:),'fill');
            [xF,ia,~] = unique(xMean(fishLoop,1:stepNo,1),'stable');
            yF        = yMean(fishLoop,ia,1);
            plot(xF,yF,'Color',colrs(iFish,:));
        end
    end
%     xlim([vidParams.tankcen(1,1),vidParams.tankcen(2,1)]);
%     ylim([vidParams.tankcen(1,2),vidParams.tankcen(4,2)]);    

    set(gca,'YDir','reverse');
    %  axis off
end
xlim(handles.bndryX);
ylim([handles.bndryY]);  
set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[])
set(gca,'Color',[0.92 0.97 1]);

amp = zeros(1,size(squeeze(handles.ampAll(1,:,stepNoFish)),2));
for fID = 1:numFish
    i = fishSelect(fID);
    if sum(isnan(squeeze(handles.ampAll(i,:,stepNoFish)))) == 0
       amp = amp + squeeze(handles.ampAll(i,:,stepNoFish));
    end   
end

if handles.showPosition == 1
    for i = 1:numFish
        fID = fishSelect(i);
        if sum(~isnan(squeeze(handles.ampAll(fID,:,handles.sNo))))
            scatter(xMean(fID,stepNo),yMean(fID,stepNo),100,colrs(fID,:),'filled')
        else
            scatter(xMean(fID,stepNo),yMean(fID,stepNo),100,colrs(fID,:))
        end       
    end
elseif handles.showAngle == 1
    for i = 1:numFish
        fID = fishSelect(i);
        if sum(~isnan(squeeze(handles.ampAll(fID,:,stepNoFish))))
            colrsMat = [colrs(fID,:);colrs(fID,:)];
        else
            colrsMat = [1 1 1;colrs(fID,:)];
        end
%         plot_ellipse(fW,fL,xMean(fID,stepNo),yMean(fID,stepNo),rad2deg(thMean(fID,stepNo)-pi/2),colrsMat);
        plot_ellipse(fW,fL,xMean(fID,stepNo),yMean(fID,stepNo),rad2deg(thMean(fID,stepNo)-pi/2),colrsMat);
    end
end

if handles.showTime == 1
%     if strcmp(type,'tank')
%         stepNo      = handles.timeIdx(handles.sNo);
%     end
   xBound = get(gca,'xlim'); yBound = get(gca,'ylim'); 
   xText = xBound(2) - (diff(xBound)/10); yText = yBound(2) - (diff(yBound)/20);
   text(xText, yText, ['Time: ' num2str(handles.fishTime(stepNoFish)) 's']);
   text(xBound(2) - (diff(xBound)/2), yBound(1) + (diff(yBound)/20), filename, 'interpreter', 'none');
end

if handles.showHull == 1
%     if strcmp(type,'tank')
%         stepNo      = handles.timeIdx(handles.sNo);
%     end
    wt_perc = 0.9;
    for i = 1:numFish
        fID = fishSelect(i);
%         convIdx = find(xWeight(fID,stepNoFish,:) > wt_perc*max(xWeight(fID,stepNoFish,:)));
%         partXY = squeeze(xPart(fID,stepNoFish,:,1:2));
%         if size(convIdx,1) > 3
%             k = convhull(partXY(:,1),partXY(:,2));
%             plot(partXY(k,1),partXY(k,2),'Color',colrs(fID,:))
%         end
        
        convPartNum = ceil(0.1*size(xWeight,3));
        [~,idxDesc] = sort(xWeight(fID,stepNoFish,:),'descend'); 
        partXY = squeeze(xPart(fID,stepNoFish,idxDesc(1:convPartNum),1:2));
        k = convhull(partXY(:,1),partXY(:,2));
        plot(partXY(k,1),partXY(k,2),'Color',colrs(fID,:))
    end
end

if handles.showParticles == 1   
%     if strcmp(type,'tank')
%         stepNo      = handles.timeIdx(handles.sNo);
%     end
    t= 0:pi/10:2*pi;
    for i = 1:numFish
        fID = fishSelect(i);
        xPatch = repmat(sin(t)',1,nPart)+repmat(reshape(xPart(fID,stepNoFish,:,1),1,nPart),length(t),1);
        yPatch = repmat(cos(t)',1,nPart)+repmat(reshape(xPart(fID,stepNoFish,:,2),1,nPart),length(t),1);  
        pb=patch(xPatch,yPatch,colrs(fID,:),'EdgeColor','none');
        alpha(pb,0.08);
        hold on;
    end
end
    

    