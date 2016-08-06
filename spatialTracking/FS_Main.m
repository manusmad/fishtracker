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
file_idx    = handles.file_idx;

% convHullWt_perc = 0.2;

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
                3 1 2; %5
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
                2 1 3; %26
                1 2 3; %27
                3 2 1; %28
                3 2 1; %29
                2 1 3; %30
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

[~,foldername,~] = fileparts(handles.dir_path);

if strcmp(foldername, '140417_threeTubeTrials')
    fishMap = elecToVid;
else
    fishMap = ThreeFishMap;
end

%% PDF of observation noise and noise generator function

% sigma_v = 0.000020*eye(nCh); 
%160614 - 0.020 is interesting
%100k done with - .01
%100kLowVar done with - .00002
%1mFinVar - 0.01

varObs = 0.001;
% varObs = 0.000020;
p_obs_noise   = @(v,truncList,withinGridIdx) mvnpdf(v, zeros(1,length(find(truncList == 1))), varObs*eye(length(find(truncList == 1))));

% p_obs_noise   = @(v,truncList,wGMatList) mvnpdf(v, zeros(1,length(find(truncList == 1))), (0.002*(1-wGMatList).*repmat(eye(length(find(truncList == 1))),[1 1 size(v,1)]) + ...
%                                                                                                     0.00002*(wGMatList).*repmat(eye(length(find(truncList == 1))),[1 1 size(v,1)])));
                                                                                                
% p_obs_noise   = @(v,truncList,withinGridIdx) mvnpdf(v, zeros(1,length(find(truncList == 1))), (0.2*(1-withinGridIdx)*eye(length(find(truncList == 1)))) + ...
%                                                                                                     0.00002*(withinGridIdx)*eye(length(find(truncList == 1))));
                                                                                                
% p_obs_noise   = @(v,truncList,distFrac) mvnpdf(v, zeros(1,length(find(truncList == 1))), ((0.00002+distFrac*0.2)*eye(length(find(truncList == 1)))));
%% Observation likelihood PDF p(y[k] | ykHat[k])
% (under the suposition of additive process noise)
p_yk_given_xk = @(yk, ykHat,truncList,withinGridIdx) p_obs_noise(yk - ykHat,truncList,withinGridIdx);
%% Particle filter
tInt  = mean(diff(fishTime));
nTime = length(fishTime);

[nx,sys] = FS_processEq(handles.motion);

% nIter = 1;
nGen = 1;

xFish       = zeros(nFish,nTime,nx);
xPart       = zeros(nFish,1,nPart,nx+1);
xPartRev    = zeros(nFish,1,nPart,nx+1);

xAmp        = zeros(nFish,nTime,nCh, 2);
% xWeight     = zeros(nFish,nTime,nPart);
% xIdxDesc    = zeros(nFish,nTime,nPart);
xFishIter   = zeros(nFish,nIter,nTime,nx);
ampAll      = zeros(nFish,nCh,nTime);
minAmpIdx   = zeros(nFish,nTime);

angThresh   = 0;
motionUni   = strcmp(handles.motion,'uni');
motionRandom = strcmp(handles.motion,'random') || strcmp(handles.motion,'random3D');

parfor_progress(nFish);

parfor id = 1:nFish
% for id = 1:nFish
    
    display(sprintf('\nFish %d of %d',id,nFish));
    
    pf = struct;
    pfRev = struct;
    p1 = [fishHist(find([fishHist.id] == fishID(id))).p1];
    if ~isfield(fishHist,'dataType')
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
    end

%     p1 = [fishHist(find([fishHist.id] == fishID(id))).p1]; %%%%%% FOR SIM TEST!!! REMOVE FOR REAL
    
    ampMagn = ([fishHist([fishHist.id] == fishID(id)).a1]);
    for i = 1:nCh
         ampMagn(i,:) = ndnanfilter(ampMagn(i,:),'rectwin',3);
    end
    amp = ampMagn.*sign(cos(p1));
    [[fishHist([fishHist.id] == fishID(id)).t]' ... 
    [fishHist([fishHist.id] == fishID(id)).f1]'];
    freqCell{id} = [[fishHist([fishHist.id] == fishID(id)).t]' ... 
    [fishHist([fishHist.id] == fishID(id)).f1]'];
    
    % Make maximum amplitude positive
    [~,Midx] = max(abs(amp));
    amp = amp.*repmat(sign(amp(sub2ind(size(amp),Midx,1:size(amp,2)))),size(amp,1),1);
    [~,subAmpIdxIndiv]  = max(abs(amp),[],1);

    % Initialize pf(id) structure
    tankStart = [tankCoord(1,1);tankCoord(1,2); 0];
    tankRange = [(tankCoord(2,1)-tankCoord(1,1));(tankCoord(4,2)-tankCoord(1,2)); 200];

    [pf.x ,pf.w] = FS_initParticles(nPart, nx+1, handles.motion, tankStart, tankRange);
    [pfRev.x ,pfRev.w] = FS_initParticles(nPart, nx+1, handles.motion, tankStart, tankRange);
    pf.p_yk_given_xk   = p_yk_given_xk;
    pfRev.p_yk_given_xk   = p_yk_given_xk;
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
            xh = zeros(nx,nTime);
            xhRev = zeros(nx,nTime);
        for iterLoop = 1:nIter
            display(sprintf('\nIteration %d of %d',iterLoop,nIter));
            for t = 1:nTime 
%                 progressbar(((id-1)*nIter*nTime + (iterLoop-1)*nTime + t)/(1.1*nFish*nIter*nTime))
                for genLoop = 1:nGen
                    % Particle filter                     

%                     [pf.x, xh(:,t), pf.w, pf(id).idxDesc,yk,ahk,wkPrResamp,xkPriorResamp] = FS_filter(pf, sys, amp(:,t),...
%                         handles.motion, gridCoord, tankCoord, tInt, genLoop,handles.fittedExpModel,minAmpIdx(t));
%                     
%                      [pfRev.x, xhRev(:,nTime-t+1), pfRev.w, pfRev(id).idxDesc,ykRev,ahkRev,wkPrResampRev,xkPriorResampRev] = FS_filter(pfRev, sys, amp(:,nTime-t+1),...
%                         handles.motion, gridCoord, tankCoord, tInt, genLoop,handles.fittedExpModel,minAmpIdx(nTime-t+1));
                    
                    [pf.x, xh(:,t), pf.w, pf.idxDesc,yk,ahk,~,~] = FS_filter(pf, sys, amp(:,t),...
                        handles.motion, gridCoord, tankCoord, tInt, genLoop,handles.fittedExpModel,subAmpIdxIndiv(t));
                    
                     [pfRev.x, xhRev(:,nTime-t+1), pfRev.w, pfRev.idxDesc,~,~,~,~] = FS_filter(pfRev, sys, amp(:,nTime-t+1),...
                        handles.motion, gridCoord, tankCoord, tInt, genLoop,handles.fittedExpModel,subAmpIdxIndiv(nTime-t+1));
                end
                
%                 xPart(id,t,:,:) = squeeze(xkPriorResamp)';
%                 xPartRev(id,nTime-t+1,:,:) = squeeze(xkPriorResampRev)';
                
%                 xWeight(id,t,:) = squeeze(wkPrResamp)';
%                 convPartNum = ceil(0.1*size(xWeight,3));
%                 partXY = squeeze(xPart(id,1,pf(id).idxDesc(1:convPartNum),1:2));
                
%                 if unique(partXY(:,1)) >= 3
%                     [~,convVol(id,t)] = convhull(partXY(:,1),partXY(:,2));
%                 else
%                     convVol(id,t) = NaN;
%                 end                   
%                 xFishIter(id,iterLoop,t,:) = (xh' + fliplr(xhRev'))/2;
%                   figure(2); hist(rad2deg(wrapToPi(pf.x(3,:))),100)
%                   pause
                  xAmp(id,t,:,:)  = [normc(yk) normc(ahk')];
%                 xIdxDesc(id,t,:)= squeeze(pf(id).idxDesc)';
            end
            if strcmp(handles.motion,'random')
                thForwBack_Mean = wrapTo2Pi(circ_mean(atan(tan(wrapTo2Pi([xh(3,:);xhRev(3,:)])))))';
                xFishIter(id,iterLoop,:,:) = [((xh(1:2,:)' + xhRev(1:2,:)')/2) thForwBack_Mean ];
                
%                 xFishIter(id,iterLoop,:,:) = [((xh(1:2,:)' + xhRev(1:2,:)')/2) (circ_mean(xh(3,:),xhRev(3,:)))' ];
            elseif strcmp(handles.motion,'random3D')
                thForwBack_Mean = wrapTo2Pi(circ_mean(atan(tan(wrapTo2Pi([xh(3,:);(xhRev(3,:))])))))';
                xFishIter(id,iterLoop,:,:) = [((xh(1:2,:)' + xhRev(1:2,:)')/2) thForwBack_Mean ((xh(4,:)' + xhRev(4,:)')/2)];
                
%                 xFishIter(id,iterLoop,:,:) = [((xh(1:2,:)' + xhRev(1:2,:)')/2) (circ_mean(xh(3,:),xhRev(3,:)))' ((xh(4,:)' + xhRev(4,:)')/2)];
                
            end
                    
%             xFishIter(id,iterLoop,:,:) = xFish(id;
        end
    end
    ampAll(id,:,:) = amp;
    minAmpIdx(id,:) = subAmpIdxIndiv;
    parfor_progress;
% pause
% clc
end

parfor_progress(0);
delete(gcp)

% matlabpool('close');
%% Save all data
timeIdx = 1:nTime;
if wildTag
%     [~,dataFileName,~] = fileparts(handles.elecFile);
%     dataFileName = fullfile(handles.dir_path,[dataFileName '_temp.mat']);
    dataFileName = fullfile(handles.dir_path,'temp.mat');
%     ampAll  = ampAllTemp;
    cHullPart = 200;
    for fID = 1:nFish
        for i = 1:nTime
           xMean(fID,i,1) = squeeze(mean(xFishIter(fID,:,i,1)));
%            xStd(fID,i,1)  = squeeze(std(xFishIter(fID,:,i,1)));

           yMean(fID,i,1) = squeeze(mean(xFishIter(fID,:,i,2)));
%            yStd(fID,i,1)  = squeeze(std(xFishIter(fID,:,i,2)));

           
           thMean(fID,i,1) = wrapTo2Pi(circ_mean(squeeze(xFishIter(fID,:,i,3))'));
%            thStd(fID,i,1)  = circ_std(squeeze(xFishIter(fID,:,i,3))');
%             thMean(fID,i,1) = wrapTo2Pi(circ_mean(acos(cos(2*wrapTo2Pi((xkm1(3,idxm1)))))/2,wkm1(idxm1)',2))
%            ampMean(fID,i,:) = FS_ObsvModel(squeeze([xMean(fID,i,1);yMean(fID,i,1);thMean(fID,i,1)]), gridCoord, tankCoord, handles.motion)';
           if strcmp(handles.motion,'random3D')
                zMean(fID,i,1) = squeeze(mean(xFishIter(fID,:,i,4)));
                meanPose = squeeze([xMean(fID,i,1);yMean(fID,i,1);thMean(fID,i,1);zMean(fID,i,1)]);
           else
               meanPose = squeeze([xMean(fID,i,1);yMean(fID,i,1);thMean(fID,i,1)]);
               zMean = [];
           end
           ampMean(fID,:,i) = FS_ObsvModel(meanPose, gridCoord, tankCoord, handles.motion,handles.fittedExpModel,minAmpIdx(fID,i))';
        end
    end
    
%     save(dataFileName,'rConv','xMean', 'xStd', 'yMean', 'yStd','thMean', 'thStd', 'ampMean','xPart', 'xFishIter','xFish', 'xAmp', 'xWeight', 'xIdxDesc', 'fishHist','fishTime','wildTag','tankCoord','gridCoord','dataType','nFish','ampAll','freqCell','-v7.3');   
% save(dataFileName,'xMean', 'yMean','thMean','zMean','xPart', 'xFishIter', 'xWeight','fishTime','wildTag','tankCoord','gridCoord','dataType','nFish','ampAll','freqCell','-v7.3');   
% save(dataFileName,'xMean', 'yMean','thMean','zMean', 'xFishIter','wildTag','tankCoord','gridCoord','dataType','nFish','ampAll','freqCell','convVol','xAmp','fishTime','ampMean','timeIdx','-v6');
save(dataFileName,'xMean', 'yMean','thMean','zMean', 'xFishIter','wildTag','tankCoord','gridCoord','dataType','nFish','ampAll','freqCell','xAmp','fishTime','ampMean','timeIdx','varObs','nPart','-v6');
    
elseif strcmp(dataType,'sim')   
    cHullPart = 200;
%     ampAll  = ampAllTemp;
    for fID = 1:nFish
        for i = 1:nTime
           xMean(fID,i,1) = squeeze(mean(xFishIter(fID,:,i,1)));
           xStd(fID,i,1)  = squeeze(std(xFishIter(fID,:,i,1)));

           yMean(fID,i,1) = squeeze(mean(xFishIter(fID,:,i,2)));
           yStd(fID,i,1)  = squeeze(std(xFishIter(fID,:,i,2)));

           thMean(fID,i,1) = circ_mean(squeeze(xFishIter(fID,:,i,3))');
           thStd(fID,i,1)  = circ_std(squeeze(xFishIter(fID,:,i,3))');
           
           thMean(fID,i,1) = wrapTo2Pi(circ_mean(squeeze(xFishIter(fID,:,timeIdx(i),3))'));
           thStd(fID,i,1)  = circ_std(squeeze(xFishIter(fID,:,timeIdx(i),3))');
           
           
           ampMean(fID,i,:) = FS_ObsvModel(squeeze([xMean(fID,i,1);yMean(fID,i,1);thMean(fID,i,1)]), gridCoord, tankCoord, handles.motion,handles.fittedExpModel)';
           
%            x = squeeze(xPart(1,i,xIdxDesc(fID,i,1:cHullPart),1));
%            y = squeeze(xPart(1,i,xIdxDesc(fID,i,1:cHullPart),2));

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

%     xPart(:,:,:,1) = xPart(:,:,:,1)*handles.scaleFact + cenElec(1);
%     xPart(:,:,:,2) = -xPart(:,:,:,2)*handles.scaleFact + cenElec(2);
%     
%     xPartRev(:,:,:,1) = xPartRev(:,:,:,1)*handles.scaleFact + cenElec(1);
%     xPartRev(:,:,:,2) = -xPartRev(:,:,:,2)*handles.scaleFact + cenElec(2);

    xFishIter(:,:,:,1) = xFishIter(:,:,:,1)*handles.scaleFact + cenElec(1);
    xFishIter(:,:,:,2) = -xFishIter(:,:,:,2)*handles.scaleFact + cenElec(2);
    
    gridCoord = gridCoord*handles.scaleFact + repmat(cenElec,size(gridCoord,1),1);
    tankCoord = tankCoord*handles.scaleFact + repmat(cenElec,size(tankCoord,1),1);

%     [~,dataFileName,~] = fileparts(handles.elecFile);
%     dataFileName = fullfile(handles.dir_path,[dataFileName '_temp.mat']);
    dataFileName = fullfile(handles.dir_path,'temp.mat');
    vidParams = handles.vidTracked;
    
    %{
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
    %}
    
     if isfield(vidParams,'clickTimes')
        vidParams.frameTime = vidParams.clickTimes;
    end
    
        nFrames     = length(vidParams.frameTime);
%         elecTime    = fishTime + vidParams.frameTime(1);
        elecTime    = fishTime;
        timeIdx     = zeros(nFrames,1);
        for n = 1:nFrames
           [~,timeIdx(n)] = min(abs(elecTime - vidParams.frameTime(n)));
        end

%     nFrames     = length(vidParams.clickTimes);
%     elecTime    = fishTime + vidParams.clickTimes(1);
% %     elecTime    = fishTime;
%     timeIdx     = zeros(nFrames,1);
%     for n = 1:nFrames
%        [~,timeIdx(n)] = min(abs(elecTime - vidParams.clickTimes(n)));
%     end
    
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
           
           if strcmp(handles.motion,'random3D')
                zMean(fID,i,1) = squeeze(mean(xFishIter(fID,:,timeIdx(i),4)));
                zStd(fID,i,1)  = squeeze(std(xFishIter(fID,:,timeIdx(i),4)));
                meanPose = squeeze([xMean(fID,i,1);yMean(fID,i,1);thMean(fID,i,1);zMean(fID,i,1)]);
           else
               meanPose = squeeze([xMean(fID,i,1);yMean(fID,i,1);thMean(fID,i,1)]);
               zMean = [];
               zStd = [];
           end
            
           ampMean(fID,:,i) = FS_ObsvModel(meanPose, gridCoord, tankCoord, handles.motion,handles.fittedExpModel,minAmpIdx(fID,timeIdx(i)))';
           
%            convVolVid(fID,i) = convVol(fID,timeIdx(i));
%            ampAll(fID,:,i) = ampAllTemp(fID,:,timeIdx(i));
%            x = squeeze(xPart(1,timeIdx(i),xIdxDesc(fID,timeIdx(i),1:cHullPart),1));
%            y = squeeze(xPart(1,timeIdx(i),xIdxDesc(fID,timeIdx(i),1:cHullPart),2));

%            [~,V]  = convhull(x,y);
%            rConv(fID,i) = sqrt(V/pi);
        end
        
        if ndims(vidParams.fishCen) == 2
                notNan = ~isnan(vidParams.fishCen(:,1));

                xError = vidParams.fishCen(notNan,1)' - squeeze(xMean(fID, notNan,:));
                yError = vidParams.fishCen(notNan,2)' - squeeze(yMean(fID, notNan,:));
    %             thError = vidParams.fishCen( find(~isnan(vidParams.fishTheta(:,1))),2)' - squeeze(yMean(fID, find(~isnan(vidParams.fishCen(:,1))),:));

%                 dCenElec = abs((vidParams.fishCen(notNan,1)' - vidParams.gridcen(5,1)) ...
%                               +1i*(vidParams.fishCen(notNan,2)' - vidParams.gridcen(5,2)));

                xMSE = mean(xError.^2)/length(timeIdx);
                yMSE = mean(yError.^2)/length(timeIdx);

        elseif ndims(vidParams.fishCen) == 3
                notNan = ~isnan(vidParams.fishCen(:,1,fishMap(file_idx,fID)));
                xError(fID,:) = vidParams.fishCen(notNan,1,fishMap(file_idx,fID))' - squeeze(xMean(fID,notNan,:));
                yError(fID,:) = vidParams.fishCen(notNan,2,fishMap(file_idx,fID))' - squeeze(yMean(fID,notNan,:));

    %             thError = vidParams.fishCen( find(~isnan(vidParams.fishTheta(:,1))),2)' - squeeze(yMean(fID, find(~isnan(vidParams.fishCen(:,1))),:));

                xMSE(fID) = mean((vidParams.fishCen(notNan,1,fishMap(file_idx,fID))' - squeeze(xMean(fID,notNan,:))).^2)/length(timeIdx);
                yMSE(fID) = mean((vidParams.fishCen(notNan,2,fishMap(file_idx,fID))' - squeeze(yMean(fID,notNan,:))).^2)/length(timeIdx);
        end
    end
%     save(dataFileName,'xError','yError','dCenElec', 'xMSE', 'yMSE','rConv','xMean', 'xStd', 'yMean', 'yStd','thMean', 'thStd', 'ampMean', 'xPart', 'xFishIter','xFish', 'xAmp', 'xWeight', 'xIdxDesc', 'fishHist','fishTime','vidParams','wildTag','tankCoord','gridCoord','ampActNormed','dataType','ampAll','nFish','freqCell','timeIdx','-v7.3');
%     save(dataFileName,'xError','yError', 'xMSE', 'yMSE','xMean', 'xStd', 'yMean', 'yStd','zMean','zStd','thMean', 'thStd', 'ampMean', 'xPart', 'xFishIter', 'xWeight','fishTime','vidParams','wildTag','tankCoord','gridCoord','ampActNormed','dataType','ampAll','nFish','freqCell','timeIdx','convVol','convVolVid','-v6');
%     save(dataFileName,'xError','yError', 'xMSE', 'yMSE','xMean', 'xStd', 'yMean', 'yStd','zMean','zStd','thMean', 'thStd', 'ampMean', 'xFishIter','fishTime','vidParams','wildTag','tankCoord','gridCoord','ampActNormed','dataType','ampAll','nFish','freqCell','timeIdx','convVol','convVolVid','xPart','xPartRev','-v6');
    save(dataFileName,'xError','yError', 'xMSE', 'yMSE','xMean', 'xStd', 'yMean', 'yStd','zMean','zStd','thMean', 'thStd', 'ampMean', 'xFishIter','fishTime','vidParams','wildTag','tankCoord','gridCoord','ampActNormed','dataType','ampAll','nFish','freqCell','timeIdx','varObs','nPart','-v6');


end
progressbar(1)
display('Done!')