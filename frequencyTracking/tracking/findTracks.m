function fish = findTracks(S,F,T,thresh)

dF = F(2)-F(1);
dT = T(2)-T(1);

normSmag = normSpecMag(S);
Smag = abs(S);
Sphs = angle(S);
[~,nT,nCh] = size(S);

progressbar('Finding Signatures...','Clustering Candidates...','Tracing Tracks...');

%% Sigmatures and candidates by edge detection

% minf1 = 290;
% maxf1 = 450;
% [~,minf1idx] = min(abs(F-minf1));
% [~,maxf1idx] = min(abs(F-maxf1));
% minf1 = F(minf1idx);
% maxf1 = F(maxf1idx);
% [~,minf2idx] = min(abs(F-2*minf1));
% [~,maxf2idx] = min(abs(F-2*maxf1));
% 
% normSmag1 = normSpecMag(S(minf1idx:maxf1idx,:,:));
% normSmag2 = normSpecMag(S(minf2idx:2:maxf2idx,:,:));
% 
% [BW1,BW2] = deal(zeros(size(normSmag1)));
% for c = 1:nCh
%     BW1(:,:,c) = edge(normSmag1(:,:,c),'canny',[],1);
%     BW2(:,:,c) = edge(normSmag2(:,:,c),'canny',[],1);
% end
% 
% Sthresh = zeros(size(S));
% Sthresh(minf1idx:maxf1idx,:,:) = BW1 & BW2;
% 
% Scand = sum(Sthresh,3)>2;
% 
% figure,clf, hold on;
% 
% imagesc(T,F(minf1idx:maxf1idx),Scand(minf1idx:maxf1idx,:));
% 
% xlim([T(1),T(end)]);
% ylim([minf1,maxf1]);
% set(gca, 'YDir', 'normal');
% hold off;


%% Find signatures (electrode-by-electrode fft peak analysis)
tic;
% Parameters
ratio12 = 8;
Fsep = dF;
minf1 = 290;
maxf1 = 450;

sigs = cell(nT,1);
parfor_progress(nT);
parfor tstep = 1:nT    
    tSigs = struct('ch',cell(1),'t',cell(1),'f1',cell(1),...
    'a1',cell(1),'a2',cell(1),...
    'p1',cell(1),'p2',cell(1));
    nSigs = 0;
    
    za = squeeze(normSmag(:,tstep,:));
    zm = squeeze(Smag(:,tstep,:));
    zp = squeeze(Sphs(:,tstep,:));
  
    for c = 1:nCh       
        % Find peaks of all above third harmonic range
        %[pks,locs] = findpeaks(za(:,c),'SORTSTR','descend','MINPEAKHEIGHT',thresh/ratio13,'THRESHOLD',thresh/(ratio13*10));
        [pks,locs] = findpeaks(za(:,c),'SORTSTR','descend','MINPEAKHEIGHT',thresh/ratio12,'MINPEAKPROMINENCE',thresh/(ratio12*2));
        
        % Eliminate 60-cycle and harmonics
%         elimIdx = zeros(size(pks));
%         for k = 1:ceil(2000/60)
%             elimIdx = elimIdx | abs(F(locs)-60*k)<1;
%         end
%         pks(elimIdx) = [];
%         locs(elimIdx) = [];
       
        % Sort by frequency
        [locs,idx] = sort(locs,'ascend');
        pks = pks(idx);

        % Locate fundamentals with significant second harmonics
        while(~isempty(locs))
            % If this is the fundamental, find all the peaks at harmonics
            f1 = F(locs(1));
            nHarm = 3;%floor(F(end)/f1);
            harmIdx = false(length(locs),nHarm);
            for harm = 1:nHarm             
                harmIdx(:,harm) = abs(F(locs)-harm*f1) <= Fsep;
            end
            
            if f1>minf1 && f1<maxf1 && nHarm>=3
                f1pks = pks(harmIdx(:,1));
                f1locs = locs(harmIdx(:,1));
                [a1,a1idx] = max(f1pks);
                
                f2pks = pks(harmIdx(:,2));
                f2locs = locs(harmIdx(:,2));
                [a2,a2idx] = max(f2pks);
                
                f3pks = pks(harmIdx(:,3));
                f3locs = locs(harmIdx(:,3));
                [a3,a3idx] = max(f3pks);

                if ~isempty(a2) && ~isempty(a3)
                    if  a1>=thresh && a2>=(thresh/ratio12)
                        nSigs = nSigs+1;

                        tSigs(nSigs).f1 = F(f1locs(a1idx));

                        tSigs(nSigs).a1 = zm(f1locs(a1idx),c);
                        tSigs(nSigs).p1 = zp(f1locs(a1idx),c);

                        tSigs(nSigs).a2 = zm(f2locs(a2idx),c);
                        tSigs(nSigs).p2 = zp(f2locs(a2idx),c);

                        tSigs(nSigs).a3 = zm(f3locs(a3idx),c);
                        tSigs(nSigs).p3 = zp(f3locs(a3idx),c);
% 
                        tSigs(nSigs).ch = c;
                        tSigs(nSigs).t = T(tstep);                
                    end
                end
            end
            
            elimIdx = logical(sum(harmIdx,2));
            pks(elimIdx) = [];
            locs(elimIdx) = []; 
        end
    end
    if length(tSigs)~=1 || ~isempty(tSigs.t)
        sigs{tstep} = tSigs;
    end
    parfor_progress;
end

sigs = [sigs{:}];
nSigs = length(sigs);
parfor_progress(0);
progressbar(1,[],[]);

toc;

if isempty(sigs)
    warning('No signatures found')
    return;
end

%% Plot all signatures
% figure,clf, hold on;
% colormap('hot');
% caxis([0,1]);
% 
% imagesc(T,F,normSmag(:,:,1));
% plot([sigs.t],[sigs.f1],'.g');
% 
% xlim([T(1),T(end)]);
% ylim([minf1,maxf1]);
% set(gca, 'YDir', 'normal');
% hold off;


%% Find candidates

tic;
cand = cell(nT,1);
   
parfor_progress(nT);
parfor tstep = 1:nT
    tCand = struct('t',cell(1),'f1',cell(1),...
        'a1',cell(1),'a2',cell(1),'a3',cell(1),...
        'p1',cell(1),'p2',cell(1),'p3',cell(1));
    nCand = 0;
    zm = squeeze(Smag(:,tstep,:));
    zp = squeeze(Sphs(:,tstep,:));
    
%     progressbar([],tstep/nT,[]);
    tSigs = sigs([sigs.t]==T(tstep));

    if ~isempty([tSigs.f1])
        uF1 = unique([tSigs.f1]);
        
        for k = 1:length(uF1)
            if sum([tSigs.f1]==uF1(k))>1
                nCand = nCand+1;
                tCand(nCand).t = T(tstep);
                tCand(nCand).f1 = uF1(k);

                [~,f1idx] = min(abs(F-tCand(nCand).f1));
                [~,f2idx] = min(abs(F-tCand(nCand).f1*2));
                [~,f3idx] = min(abs(F-tCand(nCand).f1*3));
                
                tCand(nCand).a1 = squeeze(zm(f1idx,:))';
                tCand(nCand).a2 = squeeze(zm(f2idx,:))';
                tCand(nCand).a3 = squeeze(zm(f3idx,:))';
                
                tCand(nCand).p1 = squeeze(zp(f1idx,:))';
                tCand(nCand).p2 = squeeze(zp(f2idx,:))';
                tCand(nCand).p3 = squeeze(zp(f3idx,:))';
            end
        end
    else
        fprintf('No signatures at time %2.2f\n',T(tstep));
    end   
    
    if length(tCand)~=1 || ~isempty(tCand.t)
        cand{tstep} = tCand;
    end
    parfor_progress;
end

cand = [cand{:}];
nCand = length(cand);

parfor_progress(0);
progressbar([],1,[]);
toc;

if isempty(cand)
    warning('No candidates found')
    return;
end

%% Plot all candidates
% figure,clf, hold on;
% colormap('hot');
% caxis([0,1]);
% 
% imagesc(T,F,normSmag(:,:,1));
% plot([sigs.t],[sigs.f1],'.g');
% 
% plot([cand.t],[cand.f1],'.m');
% 
% xlim([T(1),T(end)]);
% ylim([minf1,maxf1]);
% set(gca, 'YDir', 'normal');
% hold off;
    
%% Step 1: Find all 1-step connections between candidates and add them as tracks
disp('Finding fish...');
tic;

cand = computeComparisonVec(cand);
thresh = 30;
tracks = [];

n = round(5/dT);

tCandIdx = cell(nT,1);
for k = 1:nT
    tCandIdx{k} = find([cand.t]==T(k));
end

for j = 1:n
    fprintf('\nLooking for %d-connected tracks\n',j);
    tic;
    for k = 1:(nT-j)
        cand1idx = tCandIdx{k};
        cand2idx = tCandIdx{k+j};

        if ~isempty(tracks)
            cand1idx = cand1idx(~ismember(cand1idx,tracks(1,:)));
            cand2idx = cand2idx(~ismember(cand2idx,tracks(2,:)));
        end
        
        if ~isempty(cand1idx) && ~isempty(cand2idx)
            [R,C] = matchHungarian(cand(cand1idx),cand(cand2idx),thresh);
            
            tracks = [tracks,[cand1idx(R);cand2idx(C)]];
        end
    end
    toc;
    fprintf('%d tracks found so far\n',length(tracks))
end


%% Step 2: Join all the tracks with the same end points
tracks2 = mat2cell(tracks,2,ones(1,size(tracks,2)));

k = 1;
flag = 1;

trackStart = cellfun(@(x) x(1),tracks2);

while k<length(tracks2)
    while flag
        nextIdx = find(tracks2{k}(end)==trackStart(k+1:end),1);
        flag = ~isempty(nextIdx);
        if flag
            tracks2{k} = [tracks2{k}(1:end-1);tracks2{nextIdx+k}];
            tracks2(nextIdx+k) = [];
            trackStart(nextIdx+k) = [];
        end
    end
    k = k+1;
    flag = 1;
end

%% Step3: Try to combine tracks together with distance metric
tracks3 = tracks2;

k = 1;
flag = 1;

while k<length(tracks3)
    while flag
        dist = cellfun(@(x) pdist2(cand(tracks3{k}(end)).vec',cand(x(1)).vec') + (0.1/dT)*abs(cand(tracks3{k}(end)).t - cand(x(1)).t),tracks3(k+1:end));
        lt = cellfun(@(x) cand(tracks3{k}(end)).t < cand(x(1)).t,tracks3(k+1:end));
        nextIdx = find(dist<thresh & lt,1);
        flag = ~isempty(nextIdx);
        if flag
            tracks3{k} = [tracks3{k}(1:end-1);tracks3{nextIdx+k}];
            tracks3(nextIdx+k) = [];
        end
    end
    k = k+1;
    flag = 1;
end

len = cellfun(@(x) length(x),tracks3);
tracks3(len<(1/dT)) = [];

%% Arrange into structure

fish = [];
for k = 1:length(tracks3)
    trackCands = cand(tracks3{k});
    [trackCands.id] = deal(k);
    [trackCands.conf] = deal(length(trackCands));
    fish = [fish,trackCands];
end


%% Plot all tracks
% figure,clf, hold on;
% colormap('hot');
% caxis([0,1]);
% 
% imagesc(T,F,normSmag(:,:,1));
% 
% % col = distinguishable_colors(length(tracks2),'k');
% % for k = 1:length(tracks2)
% %     plot([cand(tracks2{k}).t],[cand(tracks2{k}).f1],'.-','MarkerSize',20,'LineWidth',1,'Color',col(k,:));
% % end
% 
% col = distinguishable_colors(length(tracks3),'k');
% for k = 1:length(tracks3)
%     plot([cand(tracks3{k}).t],[cand(tracks3{k}).f1],'.-','MarkerSize',20,'LineWidth',1,'Color',col(k,:));
% end
% 
% xlim([T(1),T(end)]);
% ylim([minf1,maxf1]);
% set(gca, 'YDir', 'normal');
% hold off;


%% Find fish (assign id to each candidate)
% disp('Finding fish...');
% tic;
% 
% fish = [];
% stray = [];
% 
% cand = computeComparisonVec(cand);
% thresh = 30;%3*(nCh*0.1+22)/(T(2)-T(1));  % nCh*0.1/dT is for a1s, 10/dT for f1, 2/dT 
% 
% activeFish = [];
% activeConfMin = 0;
% 
% strayFish = [];
% strayConfMax = 30;
% strayConfMin = -50;
% 
% nFish = 0;
% 
% for tstep = 1:nT
%     progressbar([],[],tstep/nT);
%     tCand = cand([cand.t]==T(tstep));
%     
%     % If there are candidates at this timestep
%     if ~isempty(tCand)
%         % If there are active fish, match candidates with them
%         if ~isempty(activeFish)
%             % Match with activeFish
%             [R,C] = matchHungarian(activeFish,tCand,thresh);
%             activeFish(R) = updateFishWithCandidate(activeFish(R),tCand(C));
%             activeFish(R) = increaseConfidence(activeFish(R));
%             NR = find(~ismember(1:length(activeFish),R));
%             activeFish(NR) = decreaseConfidence(activeFish(NR));
%             
%             % Add to fish list and eliminate those candidates
%             fish = [fish activeFish(R)];
%             tCand(C) = [];
%             
%             % Discard bad active
%             activeFish([activeFish.conf]<activeConfMin) = [];
%         end
%     end
%         
%     % Match remaining candidates with strays
%     if ~isempty(tCand)
%         if ~isempty(strayFish)
%             % Match with strays
%             [R,C] = matchHungarian(strayFish,tCand,thresh);
% 
%             strayFish(R) = updateFishWithCandidate(strayFish(R),tCand(C));
%             strayFish(R) = increaseConfidence(strayFish(R));
%             NR = find(~ismember(1:length(strayFish),R));
%             strayFish(NR) = decreaseConfidence(strayFish(NR));
% 
%             stray = [stray strayFish(R)]; 
%             tCand(C) = [];
%         else
%             strayFish = fishFromCandidate(tCand,nFish+1:nFish+length(tCand),zeros(1,length(tCand)));
%             nFish = nFish + length(tCand);
%             
%             tCand = [];
%         end
%     end  
%         
%     % Still remaining, add all to stray
%     if ~isempty(tCand)
%         newStrays = fishFromCandidate(tCand,nFish+1:nFish+length(tCand),zeros(1,length(tCand)));
%         nFish = nFish + length(tCand);
%         strayFish = [strayFish newStrays];
%     end
%          
%     if ~isempty(strayFish)
%         % Integrate good strays into active
%         goodIdx = find([strayFish.conf]>=strayConfMax);
%         for g = 1:length(goodIdx)
%             idx = [stray.id]==strayFish(goodIdx(g)).id;
%             fish = [fish stray(idx)];
%             stray(idx) = [];
%         end
%         activeFish = [activeFish strayFish(goodIdx)];
%         strayFish(goodIdx) = [];
% 
%         % Discard bad strays
%         badIdx = [strayFish.conf]<=strayConfMin;
%         strayFish(badIdx) = [];
%     end
%     
%     % Plot all fish
% %     figure(1),clf, hold on;
% %     colormap('hot');
% %     caxis([0,1]);
% %     col = distinguishable_colors(nFish,[0,0,0]);
% % 
% %     imagesc(T,F,normSmag(:,:,1));
% %     
% %     if ~isempty(stray)
% %         for f = unique([stray.id])
% %             idx = [stray.id]==f;
% %             plot([stray(idx).t],[stray(idx).f1],'.','Color','w','MarkerSize',25);
% %         end
% %     end
% %     
% %     if ~isempty(fish)
% %         for f = unique([fish.id])
% %             idx = [fish.id]==f;
% %             plot([fish(idx).t],[fish(idx).f1],'.','Color',col(f,:),'MarkerSize',25);
% %         end
% %     end
% %     
% %     xlim([T(1),T(end)]);
% %     ylim([minf1,maxf1]);
% %     set(gca, 'YDir', 'normal');
% %     hold off;
% %     waitforbuttonpress;
% end

%%
% Before returning, re-assign and sort ids by mean frequency
if ~isempty(fish)
    uId = unique([fish.id]);
    nId = length(uId);
    meanF = zeros(nId,1);

    for k = 1:nId
        idx = [fish.id]==uId(k);
        meanF(k) = mean([fish(idx).f1]);
    end

    [~,fidx] = sort(meanF,'descend');
    fish2 = fish;
    for k = 1:nId
        idx = [fish2.id]==uId(fidx(k));
        [fish(idx).id] = deal(k);
    end
end

toc;
progressbar(1);

if isempty(fish)
    warning('No fish found')
    return;
end

%% Plot all fish
% figure,clf, hold on;
% colormap('hot');
% caxis([0,1]);
% col = distinguishable_colors(nFish,[0,0,0]);
% 
% % imagesc(T,F,normSmag(:,:,1));
% 
% % plot([fish.t],[fish.f1],'.m');
% for f = 1:nFish
%     idx = [fish.id]==f;
%     plot([fish(idx).t],[fish(idx).f1],'.','Color',col(f,:));
% end
% 
% xlim([T(1),T(end)]);
% ylim([minf1,maxf1]);
% set(gca, 'YDir', 'normal');
% hold off;

