function FS_plotOverhead(handles)

fishSelect  = handles.fishSelect;
numFish     = length(fishSelect); 
wildTag     = handles.particle.wildTag;
gridCoord   = handles.particle.gridCoord;
tankCoord   = handles.particle.tankCoord;
stepNo      = handles.timeIdx(handles.sNo);

colrs       = distinguishable_colors(handles.particle.nFish);

axes(handles.ax_overhead)
cla

xlim(handles.bndryX);
ylim([handles.bndryY]);  
set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[])
set(gca,'Color',[0.92 0.97 1]);
fW = 0.5;
fL = 3;
plot(tankCoord(:,1),tankCoord(:,2),'Color',[0.4,0.4,0.4],'LineWidth',10.01),hold on;
plot(gridCoord(:,1),gridCoord(:,2),'ok','LineWidth',3.01);
plot(gridCoord(:,1),gridCoord(:,2),'+k','LineWidth',3.01);

if wildTag    
    set(gca,'YDir','normal');
else
    if handles.showVid == 1
        for i = 1:numFish
            iFish = fishSelect(i);
            if handles.particle.nFish > 1  
                    mapFish = fishMap(handles.file_idx,iFish);
            else
                mapFish = iFish;
            end
            [x,ia,~] = unique(handles.vidTracked.fishCen(:,1,mapFish),'stable');
            y = handles.vidTracked.fishCen(ia,2,mapFish);
            x = (x - handles.vidTracked.gridcen(5,1))/handles.scaleFact;
            y = (y - handles.vidTracked.gridcen(5,2))/handles.scaleFact;
            plot(x,y,'Color',colrs(iFish,:), 'LineWidth',1.5);
            xCurr = (handles.vidTracked.fishCen(handles.sNo,1,mapFish) - handles.vidTracked.gridcen(5,1))/handles.scaleFact;
            yCurr = (handles.vidTracked.fishCen(handles.sNo,2,mapFish) - handles.vidTracked.gridcen(5,2))/handles.scaleFact;
            plot_ellipse(fW/2,fL,xCurr,yCurr,rad2deg(handles.vidTracked.fishTheta(handles.sNo,mapFish)),[colrs(iFish,:); 0 0 0]);
            hold on
        end
    end
    set(gca,'YDir','reverse');
end

if handles.showTrack ~= 2
    for i = 1:numFish
        fishLoop = fishSelect(i);
        fishPresentIdx = find(sum(isnan(squeeze(handles.particle.fish(fishLoop).ampAct))) ~= handles.particle.nChannels);
        if handles.showTrack == 3
            fishPresentIdx = fishPresentIdx(fishPresentIdx<=stepNo);
        end
        scatter(handles.particle.fish(fishLoop).x(fishPresentIdx),handles.particle.fish(fishLoop).y(fishPresentIdx),20,colrs(fishLoop,:),'fill');
        [xF,ia,~] = unique(handles.particle.fish(fishLoop).x(fishPresentIdx),'stable');
        yF        = handles.particle.fish(fishLoop).y(fishPresentIdx(ia),1);
        plot(xF,yF,'--','Color',colrs(fishLoop,:));
    end
end
    

if handles.showPosition == 1
    for i = 1:numFish
        fID = fishSelect(i);
        if sum(~isnan(squeeze(handles.particle.fish(fID).ampAct(:,handles.sNo))))
            scatter(handles.particle.fish(fID).x(stepNo),handles.particle.fish(fID).y(stepNo),100,colrs(fID,:),'filled')
        else
            scatter(handles.particle.fish(fID).x(stepNo),handles.particle.fish(fID).y(stepNo),100,colrs(fID,:))
        end       
    end
elseif handles.showAngle == 1
    for i = 1:numFish
        fID = fishSelect(i);
        if sum(~isnan(squeeze(handles.particle.fish(fID).ampAct(:,handles.sNo))))
            colrsMat = [colrs(fID,:);colrs(fID,:)];
        else
            colrsMat = [1 1 1;colrs(fID,:)];
        end
        plot_ellipse(fW,fL,handles.particle.fish(fID).x(stepNo),handles.particle.fish(fID).y(stepNo),rad2deg(handles.particle.fish(fID).theta(stepNo)),colrsMat);
    end
end

if handles.showTime == 1
   xBound = get(gca,'xlim'); yBound = get(gca,'ylim'); 
   xText = xBound(2) - (diff(xBound)/10); yText = yBound(2) - (diff(yBound)/20);
   text(xText, yText, ['Time: ' num2str(handles.particle.t(stepNo)) 's']);
   text(xBound(2) - (diff(xBound)/2), yBound(1) + (diff(yBound)/20), handles.filename, 'interpreter', 'none');
end 