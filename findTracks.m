function fish = findTracks(S,F,T,thresh)

Smag = normSpecMag(S);
Sphs = angle(S);
[~,nT,nCh] = size(S);

progressbar('Finding Signatures...','Clustering Candidates...','Tracing Tracks...');

%% Find signatures (electrode-by-electrode fft peak analysis)

% Parameters
ratio12 = 8;
dF = diff(F(1:2));
Fsep = dF*2;
minf1 = 200;
maxf1 = 800;

sigs = struct('ch',cell(1),'t',cell(1),'f1',cell(1),...
    'a1',cell(1),'a2',cell(1),...
    'p1',cell(1),'p2',cell(1));
nSigs = 0;

for tstep = 1:nT
    progressbar(tstep/nT,[],[]);
    za = squeeze(Smag(:,tstep,:));
    zp = squeeze(Sphs(:,tstep,:));

    for c = 1:nCh
        % Find peaks of all above third harmonic range
        %[pks,locs] = findpeaks(za(:,c),'SORTSTR','descend','MINPEAKHEIGHT',thresh/ratio13,'THRESHOLD',thresh/(ratio13*10));
        [pks,locs] = findpeaks(za(:,c),'SORTSTR','descend','MINPEAKHEIGHT',thresh/ratio12,'MINPEAKPROMINENCE',thresh/(ratio12*2));
        
        % Eliminate 60-cycle and harmonics
        elimIdx = zeros(size(pks));
        for k = 1:ceil(2000/60)
            elimIdx = elimIdx | abs(F(locs)-60*k)<1;
        end
        pks(elimIdx) = [];
        locs(elimIdx) = [];
       
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
                    if  a1>=thresh && a2>=thresh/ratio12
                        nSigs = nSigs+1;

                        sigs(nSigs).a1 = a1;
                        sigs(nSigs).f1 = F(f1locs(a1idx));
                        sigs(nSigs).p1 = zp(f1locs(a1idx),c);

                        sigs(nSigs).a2 = a2;
                        sigs(nSigs).p2 = zp(f2locs(a2idx),c);

                        sigs(nSigs).a3 = a3;
                        sigs(nSigs).p3 = zp(f3locs(a3idx),c);

                        sigs(nSigs).ch = c;
                        sigs(nSigs).t = T(tstep);                
                    end
                end
            end    
            
            elimIdx = logical(sum(harmIdx,2));
            pks(elimIdx) = [];
            locs(elimIdx) = []; 
        end
    end
end

%% Plot all signatures
% clf, hold on;
% colormap('hot');
% caxis([0,1]);
% 
% imagesc(T,F,Smag(:,:,1));
% plot([sigs.t],[sigs.f1],'.g');
% 
% xlim([T(1),T(end)]);
% ylim([500,maxf1]);
% set(gca, 'YDir', 'normal');
% hold off;


%% Find candidates
cand = struct('t',cell(1),'f1',cell(1),...
        'a1',cell(1),'a2',cell(1),'a3',cell(1),...
        'p1',cell(1),'p2',cell(1),'p3',cell(1));
nCand = 0;
    
for tstep = 1:nT
    progressbar([],tstep/nT,[]);
    tsigs = sigs([sigs.t]==T(tstep));

    if ~isempty([tsigs.f1])
        % Sort by frequency
        [~,idx] = sort([tsigs.f1]);
        tsigs = tsigs(idx);
        
        % Find breaks in frequency and bin
        binIdx = find(diff([tsigs.f1])>Fsep);
        binIdx = [0 binIdx length(tsigs)];
        nNewCand = length(binIdx)-1;
        
        for k = 1:nNewCand
            binSigs = tsigs(binIdx(k)+1:binIdx(k+1));
            
            cand(nCand+k).t = T(tstep);
            cand(nCand+k).f1 = mean([binSigs.f1]);

            [cand(nCand+k).a1,cand(nCand+k).a2,cand(nCand+k).a3,...
            cand(nCand+k).p1,cand(nCand+k).p2,cand(nCand+k).p3] = deal(NaN(nCh,1));
 
            for c = 1:nCh
                cidx = find([binSigs.ch] == c);
                lc = length(cidx);
                
                if lc>0
                    if lc>1
                        [~,midx] = max([binSigs(cidx).a1]);
                        cidx = cidx(midx);
                    end
                    
                    cand(nCand+k).a1(binSigs(cidx).ch) = binSigs(cidx).a1;
                    cand(nCand+k).a2(binSigs(cidx).ch) = binSigs(cidx).a2;
                    cand(nCand+k).a3(binSigs(cidx).ch) = binSigs(cidx).a3;
                    
                    cand(nCand+k).p1(binSigs(cidx).ch) = binSigs(cidx).p1;
                    cand(nCand+k).p2(binSigs(cidx).ch) = binSigs(cidx).p2;
                    cand(nCand+k).p3(binSigs(cidx).ch) = binSigs(cidx).p3;
                end
            end
               
        end
        nCand = nCand + nNewCand;
    else
        fprintf('No signatures at time %2.2f\n',T(tstep));
    end
                
end

%% Plot all candidates
% clf, hold on;
% colormap('hot');
% caxis([0,1]);
% 
% imagesc(T,F,Smag(:,:,1));
% plot([sigs.t],[sigs.f1],'.g');
% 
% plot([cand.t],[cand.f1],'.m');
% 
% xlim([T(1),T(end)]);
% ylim([500,maxf1]);
% set(gca, 'YDir', 'normal');
% hold off;


%% Find fish (assign id to each candidate)
disp('Finding fish...');

fish = [];
stray = [];

activeFish = [];
activeConfMax = 20;
activeConfMin = 0;

strayFish = [];
strayConfMax = 10;
strayConfMin = -5;

nFish = 0;

for tstep = 1:nT
    progressbar([],[],tstep/nT);
    tCand = cand([cand.t]==T(tstep));
    
    % If there are candidates at this timestep
    if ~isempty(tCand)
        % If there are active fish, match candidates with them
        if ~isempty(activeFish)
            % Match with activeFish
            [R,C] = matchHungarian(activeFish,tCand,5);
            activeFish(R) = updateFishWithCandidate(activeFish(R),tCand(C));
            activeFish(R) = increaseConfidence(activeFish(R));
            NR = find(~ismember(1:length(activeFish),R));
            activeFish(NR) = decreaseConfidence(activeFish(NR));
            
            % Add to fish list and eliminate those candidates
            fish = [fish activeFish(R)];
            tCand(C) = [];
            
            % Discard bad active
            activeFish([activeFish.conf]<activeConfMin) = [];
        end
    end
        
    % Match remaining candidates with strays
    if ~isempty(tCand)
        if ~isempty(strayFish)
            % Match with strays
            [R,C] = matchHungarian(strayFish,tCand,5);

            strayFish(R) = updateFishWithCandidate(strayFish(R),tCand(C));
            strayFish(R) = increaseConfidence(strayFish(R));
            NR = find(~ismember(1:length(strayFish),R));
            strayFish(NR) = decreaseConfidence(strayFish(NR));

            stray = [stray strayFish(R)]; 
            tCand(C) = [];
        else
            strayFish = fishFromCandidate(tCand,nFish+1:nFish+length(tCand),zeros(1,length(tCand)));
            nFish = nFish + length(tCand);
            
            tCand = [];
        end
    end  
        
    % Still remaining, add all to stray
    if ~isempty(tCand)
        newStrays = fishFromCandidate(tCand,nFish+1:nFish+length(tCand),zeros(1,length(tCand)));
        nFish = nFish + length(tCand);
        strayFish = [strayFish newStrays];
    end
         
    if ~isempty(strayFish)
        % Integrate good strays into active
        goodIdx = find([strayFish.conf]>=strayConfMax);
        for g = 1:length(goodIdx)
            idx = [stray.id]==strayFish(goodIdx(g)).id;
            fish = [fish stray(idx)];
            stray(idx) = [];
        end
        activeFish = [activeFish strayFish(goodIdx)];
        strayFish(goodIdx) = [];

        % Discard bad strays
        badIdx = [strayFish.conf]<=strayConfMin;
        strayFish(badIdx) = [];
    end
end

% Before returning, re-assign and sort ids by mean frequency
uId = unique([fish.id]);
nId = length(uId);
meanF = zeros(nId,1);

for k = 1:nId
    idx = [fish.id]==uId(k);
    meanF(k) = mean([fish(idx).f1])
end

[~,fidx] = sort(meanF,'descend');
fish2 = fish;
for k = 1:nId
    idx = [fish2.id]==uId(fidx(k));
    [fish(idx).id] = deal(k);
end

progressbar(1);

% Plot all fish
% clf, hold on;
% colormap('hot');
% caxis([0,1]);
% col = distinguishable_colors(nFish,[0,0,0]);
% 
% imagesc(T,F,Smag(:,:,1));
% 
% % plot([fish.t],[fish.f1],'.m');
% for f = 1:nFish
%     idx = [fish.id]==f;
%     plot([fish(idx).t],[fish(idx).f1],'.','Color',col(f,:));
% end
% 
% xlim([T(1),T(end)]);
% ylim([500,maxf1]);
% set(gca, 'YDir', 'normal');
% hold off;

