function [handles, dataFileName] = FS_Main(nPart, nIter,handles)
progressbar(0)
% parpool;

wildTag = get(handles.Wild,'Value');
if wildTag
    dataType = 'wild';
else
    dataType = 'tank';
end

tankCoord   = handles.tankCoord;
gridCoord   = handles.gridCoord;
fishHist    = handles.elecTracked.tracks;
fishID      = unique([fishHist.id]);
nFish       = length(fishID);
nCh         = size(fishHist(1).a1,1);
fishTime    = sort(unique([fishHist.t]),'ascend');
[~,sortIdx] = sort([fishHist.t],'ascend');
fishHist    = fishHist(sortIdx);

%% FOR TESTING ONLY
% tLength = 1001;
% load x; 
% trajList{1} = x(:,1:tLength);
% %     trajList{1}(1:2,:) = .8*(trajList{1}(1:2,:) - repmat([40;20],1,tLength));
% clear x
% load y; 
% trajList{2} = y(:,1:tLength);
% clear y
% load z;
% trajList{3} = z(:,1:tLength);
% trajList{3}(1:2,:) = .8*(trajList{3}(1:2,:) - repmat([20;40],1,tLength));
% clear z
% 
% [xD,yD] = FS_testGridSim();
% gridCoord = [xD yD];
% tankCoord = [-80 80; 80 80; 80 -80; -80 -80; -80 80];
% motion = 'random';   
% fishID = 1;
% for idLoop = 1:1
%     for time = 1:tLength
%         X = trajList{fishID}(:,time);
%         fishcen(time,:,idLoop) = X(1:2);
%         fishTheta(time,idLoop) = X(3);
%         fishHist{time}(idLoop).id = idLoop;
%         fishHist{time}(idLoop).a1 = FS_AmpSimGen(X,motion,gridCoord,zDist);
% %             fishHist{time}(idLoop).a1 = nan(9,1);
%         fishHist{time}(idLoop).p1 = zeros(9,1);
%     end
% end
% totalTime = 500;
% fishTime = 0:totalTime/(tLength-1):totalTime;
% nFish = 1;
% if nFish > 0
%     fish1 = idFish(fishHist,1);
%     nCh = size([fish1.a1],1);
% end

%% Particle filter


tInt  = mean(diff(fishTime));
nTime = length(fishTime);
[nx,sys] = FS_processEq(handles.motion);
% nIter = 1;
nGen = 2;

% Cycles
fMat = 1:nTime; rMat = nTime-1:-1:1; ffMat = 2:nTime;
fL = length(fMat); rL= length(rMat) + fL; 
% ffL = length(ffMat) + rL;
cycleMat = [fMat rMat ffMat];
nLoops   = length(cycleMat);

xFish    = zeros(nFish,nTime,nx);
xPart    = zeros(nFish,nTime,nPart,nx+1);
xAmp     = zeros(nFish,nTime,nCh, 2);
xWeight  = zeros(nFish,nTime,nPart);
xIdxDesc = zeros(nFish,nTime,nPart);
xFishIter = zeros(nFish,nIter,nTime,nx);

angThresh = 0;
motionUni = strcmp(handles.motion,'uni');
motionRandom = strcmp(handles.motion,'random');

for id = 1:nFish
    display(sprintf('\nFish %d of %d',id,nFish));
         
    p1 = [fishHist(find([fishHist.id] == fishID(id))).p1];
    for i = 1:nTime
        p2 = p1(:,i);
        if sum(isnan(p1(:,i))) < (nCh - 4)                           
            nanVec          = isnan(p1(:,i));
            p1Def           = p1(~nanVec,i);
            clustVec        = circ_clust(p1Def',2);

            c1Idx       = find(clustVec==1);
            c1          = p1Def(c1Idx);
            c1Med       = circ_median(c1);

            c2Idx       = find(clustVec==2);
            c2          = p1Def(c2Idx);
            c2Med       = circ_median(c2);

            p2 = zeros(nCh,1);
            if abs(rad2deg(circ_dist(c1Med,c2Med))) >= angThresh
                p1Def(c1Idx) = 0;
                p1Def(c2Idx) = pi;
            else
                p1Def(:)     = 0;
            end
            p2(~nanVec) = p1Def;
            p2(nanVec) = NaN;
        end 
        p1(:,i) = p2;            
    end

    amp = ([fishHist([fishHist.id] == fishID(id)).a1]).*sign(cos(p1));
    freqCell{id} = [[fishHist([fishHist.id] == fishID(id)).t]' ... 
    [fishHist([fishHist.id] == fishID(id)).f1]']; 
    
    % Make maximum amplitude positive
    [~,Midx] = max(abs(amp));
    for c = 1:size(amp,2)
        if amp(Midx(c),c)<0
            amp(:,c) = -amp(:,c);
        end
    end
    
    % Initialize pf(id) structure
    [pf(id).x ,pf(id).w] = FS_initParticles(nPart, nx+1, handles.motion, tankCoord);
    
%     if motionUni
%         for t = 1:nLoops 
%             display(strcat(num2str(t),'/',num2str(nLoops)));
%             t1 = cycleMat(t);
% 
%             % Particle filter    
%             [pf(id).x, xh, pf(id).w] = FS_filter(pf(id), sys, amp(handles.elecTrunc,t1),...
%                 handles.motion, handles.gridCoord(:,:), handles.tankCoord, tInt);
%     %         [xh,~]=FS_Optim(xP,amp(handles.elecTrunc,t1),handles.gridCoord);
% 
% %             xPart(id,t1,:,:) = squeeze(pf(id).x)';
% %             xFish(id,t1,:) = xh';
% 
%             if strcmp(handles.motion, 'uni') && (t == fL || t == rL)
%                 pf(id).x(4:5,:) = -pf(id).x(4:5,:);
%             end
%         end
%     else
        if motionRandom
        for iterLoop = 1:nIter
            display(sprintf('\nIteration %d of %d',iterLoop,nIter));
            for t = 1:nTime 
                progressbar(((id-1)*nIter*nTime + (iterLoop-1)*nTime + t)/(1.1*nFish*nIter*nTime))
                for genLoop = 1:nGen
                    % Particle filter                     
                    [pf(id).x, xh, pf(id).w, pf(id).idxDesc,yk,ahk] = FS_filter(pf(id), sys, amp(:,t),...
                        handles.motion, gridCoord, tankCoord, tInt);
                end
%                 xAmp(id,t,:,:)  = [normc(yk) normc(ahk')];
                xPart(id,t,:,:) = squeeze(pf(id).x)';
                xWeight(id,t,:) = squeeze(pf(id).w)';
%                 xIdxDesc(id,t,:)= squeeze(pf(id).idxDesc)';
%                 xFish(id,t,:)   = 
                xFishIter(id,iterLoop,t,:) = xh';
            end
%             xFishIter(id,iterLoop,:,:) = xFish(id;
        end
    end
    ampAll(id,:,:) = amp;
end
% matlabpool('close');
%% Save all data
if wildTag
%     [~,dataFileName,~] = fileparts(handles.elecFile);
%     dataFileName = fullfile(handles.dir_path,[dataFileName '_temp.mat']);
    dataFileName = fullfile(handles.dir_path,'temp.mat');
    
    cHullPart = 200;
    for fID = 1:nFish
        for i = 1:nTime
           xMean(fID,i,1) = squeeze(mean(xFishIter(fID,:,i,1)));
%            xStd(fID,i,1)  = squeeze(std(xFishIter(fID,:,i,1)));

           yMean(fID,i,1) = squeeze(mean(xFishIter(fID,:,i,2)));
%            yStd(fID,i,1)  = squeeze(std(xFishIter(fID,:,i,2)));

           thMean(fID,i,1) = circ_mean(squeeze(xFishIter(fID,:,i,3))');
%            thStd(fID,i,1)  = circ_std(squeeze(xFishIter(fID,:,i,3))');
           
%            ampMean(fID,i,:) = FS_ObsvModel(squeeze([xMean(fID,i,1);yMean(fID,i,1);thMean(fID,i,1)]), gridCoord, tankCoord, handles.motion)';

%            x = squeeze(xPart(1,i,xIdxDesc(fID,i,1:cHullPart),1));
%            y = squeeze(xPart(1,i,xIdxDesc(fID,i,1:cHullPart),2));

%            [~,V]  = convhull(x,y);
%            rConv(fID,i) = sqrt(V/pi);
        end
    end
    
%     save(dataFileName,'rConv','xMean', 'xStd', 'yMean', 'yStd','thMean', 'thStd', 'ampMean','xPart', 'xFishIter','xFish', 'xAmp', 'xWeight', 'xIdxDesc', 'fishHist','fishTime','wildTag','tankCoord','gridCoord','dataType','nFish','ampAll','freqCell','-v7.3');   
save(dataFileName,'xMean', 'yMean','thMean','xPart', 'xFishIter', 'xWeight','fishTime','wildTag','tankCoord','gridCoord','dataType','nFish','ampAll','freqCell','-v6');   
    
elseif strcmp(dataType,'sim')   
    cHullPart = 200;
    for fID = 1:nFish
        for i = 1:nTime
           xMean(fID,i,1) = squeeze(mean(xFishIter(fID,:,i,1)));
           xStd(fID,i,1)  = squeeze(std(xFishIter(fID,:,i,1)));

           yMean(fID,i,1) = squeeze(mean(xFishIter(fID,:,i,2)));
           yStd(fID,i,1)  = squeeze(std(xFishIter(fID,:,i,2)));

           thMean(fID,i,1) = circ_mean(squeeze(xFishIter(fID,:,i,3))');
           thStd(fID,i,1)  = circ_std(squeeze(xFishIter(fID,:,i,3))');
           
           ampMean(fID,i,:) = FS_ObsvModel(squeeze([xMean(fID,i,1);yMean(fID,i,1);thMean(fID,i,1)]), gridCoord, tankCoord, handles.motion)';

           x = squeeze(xPart(1,i,xIdxDesc(fID,i,1:cHullPart),1));
           y = squeeze(xPart(1,i,xIdxDesc(fID,i,1:cHullPart),2));

%            [~,V]  = convhull(x,y);
%            rConv(fID,i) = sqrt(V/pi);
        end
    end
    %%
    
%     meanErr(zDist) = mean(sqrt((xMean-trajList{fishID}(1,:)).^2 + (yMean-trajList{fishID}(2,:)).^2));
%     stdErr(zDist)  = std(sqrt((xMean-trajList{fishID}(1,:)).^2 + (yMean-trajList{fishID}(2,:)).^2));
else

    cenElec = handles.vidTracked.gridcen(5,:);
    xFish(:,:,1) = xFish(:,:,1)*handles.scaleFact + cenElec(1);
    xFish(:,:,2) = -xFish(:,:,2)*handles.scaleFact + cenElec(2);

    xPart(:,:,:,1) = xPart(:,:,:,1)*handles.scaleFact + cenElec(1);
    xPart(:,:,:,2) = -xPart(:,:,:,2)*handles.scaleFact + cenElec(2);

    xFishIter(:,:,:,1) = xFishIter(:,:,:,1)*handles.scaleFact + cenElec(1);
    xFishIter(:,:,:,2) = -xFishIter(:,:,:,2)*handles.scaleFact + cenElec(2);
    
    gridCoord = gridCoord*handles.scaleFact + repmat(cenElec,size(gridCoord,1),1);
    tankCoord = tankCoord*handles.scaleFact + repmat(cenElec,size(tankCoord,1),1);

%     [~,dataFileName,~] = fileparts(handles.elecFile);
%     dataFileName = fullfile(handles.dir_path,[dataFileName '_temp.mat']);
    dataFileName = fullfile(handles.dir_path,'temp.mat');
    vidParams = handles.vidTracked;

    nanIdx = find((cellfun('isempty', vidParams.tubecen)));
    noNanIdx = find(not(cellfun('isempty', vidParams.tubecen)));
    
    nanTube = repmat([nan nan],length(nanIdx),1);
    nanAng  = repmat([nan],length(nanIdx),1);
    for noNanLoop = 1:length(noNanIdx)
        noNanTube(noNanLoop,:) = vidParams.tubecen{noNanIdx(noNanLoop)}(1,:);
        noNanAng(noNanLoop,:)  = vidParams.tubeang{noNanIdx(noNanLoop)}(1);
    end
    
    tubeCen([nanIdx; noNanIdx],:) = [nanTube; noNanTube];
    tubeAng([nanIdx; noNanIdx],:) = [nanAng; noNanAng];
    vidParams.tubecen = tubeCen;
    vidParams.tubeang = tubeAng;
    
    vidParams.fishCen = tubeCen;
    vidParams.fishTheta = tubeAng;
  
    nFrames = vidParams.nFrames;
    elecTime = fishTime + vidParams.elecTime(1);
    timeIdx  = zeros(nFrames,1);
    for n = 1:nFrames
       [~,timeIdx(n)] = min(abs(elecTime - vidParams.frameTime(n)));
    end

    clear n
    for n = 1:nFrames
        ampActNormed(:,n) = xAmp(1,timeIdx(n),:,1);
    end
    
    cHullPart = 200;
    for fID = 1:nFish
        for i = 1:length(timeIdx)
           xMean(fID,i,1) = squeeze(mean(xFishIter(fID,:,timeIdx(i),1)));
           xStd(fID,i,1)  = squeeze(std(xFishIter(fID,:,timeIdx(i),1)));

           yMean(fID,i,1) = squeeze(mean(xFishIter(fID,:,timeIdx(i),2)));
           yStd(fID,i,1)  = squeeze(std(xFishIter(fID,:,timeIdx(i),2)));

           thMean(fID,i,1) = wrapTo2Pi(circ_mean(squeeze(xFishIter(fID,:,timeIdx(i),3))'));
           thStd(fID,i,1)  = circ_std(squeeze(xFishIter(fID,:,timeIdx(i),3))');
            
           ampMean(fID,i,:) = FS_ObsvModel(squeeze([xMean(fID,i,1);yMean(fID,i,1);thMean(fID,i,1)]), gridCoord, tankCoord, handles.motion)';
           
           x = squeeze(xPart(1,timeIdx(i),xIdxDesc(fID,timeIdx(i),1:cHullPart),1));
           y = squeeze(xPart(1,timeIdx(i),xIdxDesc(fID,timeIdx(i),1:cHullPart),2));

           [~,V]  = convhull(x,y);
           rConv(fID,i) = sqrt(V/pi);
        end
        
        if ndims(vidParams.tubecen) == 2
                notNan = ~isnan(vidParams.tubecen(:,1));

                xError = vidParams.tubecen(notNan,1)' - squeeze(xMean(fID, notNan,:));
                yError = vidParams.tubecen(notNan,2)' - squeeze(yMean(fID, notNan,:));
    %             thError = vidParams.tubecen( find(~isnan(vidParams.fishTheta(:,1))),2)' - squeeze(yMean(fID, find(~isnan(vidParams.tubecen(:,1))),:));

                dCenElec = abs((vidParams.tubecen(notNan,1)' - vidParams.gridcen(5,1)) ...
                              +1i*(vidParams.tubecen(notNan,2)' - vidParams.gridcen(5,2)));

                xMSE = mean(xError.^2)/length(timeIdx);
                yMSE = mean(yError.^2)/length(timeIdx);

        elseif ndims(vidParams.tubecen) == 3
            dCenElec = [];
            for fVidID = 1:size(vidParams.tubecen,3)
                notNan = ~isnan(vidParams.tubecen(:,1,fVidID));

                xError = vidParams.tubecen(notNan,1,fVidID)' - squeeze(xMean(fID,notNan,:));
                yError = vidParams.tubecen(notNan,2,fVidID)' - squeeze(yMean(fID,notNan,:));
    %             thError = vidParams.tubecen( find(~isnan(vidParams.fishTheta(:,1))),2)' - squeeze(yMean(fID, find(~isnan(vidParams.tubecen(:,1))),:));

                xMSE(fVidID) = mean((vidParams.tubecen(notNan,1,fVidID)' - squeeze(xMean(fID,notNan,:))).^2)/length(timeIdx);
                yMSE(fVidID) = mean((vidParams.tubecen(notNan,2,fVidID)' - squeeze(yMean(fID,notNan,:))).^2)/length(timeIdx);
            end
        end
    end
    save(dataFileName,'xError','yError','dCenElec', 'xMSE', 'yMSE','rConv','xMean', 'xStd', 'yMean', 'yStd','thMean', 'thStd', 'ampMean', 'xPart', 'xFishIter','xFish', 'xAmp', 'xWeight', 'xIdxDesc', 'fishHist','fishTime','vidParams','wildTag','tankCoord','gridCoord','ampActNormed','dataType','ampAll','nFish','freqCell','timeIdx','-v7.3');

end
progressbar(1)
display('Done!')