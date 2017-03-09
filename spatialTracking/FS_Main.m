function [handles, dataFileName] = FS_Main(handles)

%% Description: 
% This function is the precursor to the particle filter function FS_filter.
% - Parses data sent in via GUI
% - Initializes variables
% - Sets up required probablity distribution functions (PDF)
% - For each fish, preprocesses the frequency amplitude and phase info from
% freqtracks to actual voltage values. 
% - For each fish, interates through particle filter algorithm 
% - Saves the output of the particle filter in a temporary mat mat file and
% passes it back to the calling function

% Author: Ravikrishnan Perur Jayakumar
%%

wildTag     = get(handles.Wild,'Value');  % Value 1 or 0; denotes if the dataset was collected in the wild or lab
tankCoord   = handles.tankCoord; % Boundary of tank (x-y coordinate)
gridCoord   = handles.gridCoord; % Electrode locations (x-y-z coordinate)
fishHist    = handles.elecTracked.tracks; % Frequecny tracked data
nPart       = handles.nPart; % Number of particles 
fishID      = unique([fishHist.id]); % List of identifiers of unique frequency tracks 
nFish       = length(fishID); % Number of unique frequency tracks
nCh         = size(fishHist(1).a1,1); % Number of electrodes used
fishTime    = sort(unique([fishHist.t]),'ascend'); % Time vector from frequency tracks
[~,sortIdx] = sort([fishHist.t],'ascend'); 
fishHist    = fishHist(sortIdx);
tInt        = mean(diff(fishTime)); % Mean sampling interval
nTime       = length(fishTime); % Length of time vector

%% PDF of observation noise

varObs      = 0.001; % Variance of observation noise
f_obs_noise = @(v,truncList,withinGridIdx) mvnpdf(v, zeros(1,length(find(truncList == 1))), varObs*eye(length(find(truncList == 1))));

%% Observation likelihood PDF p(y[k] | ykHat[k])
% (under the suposition of additive process noise)
p_yk_given_ykHat = @(yk, ykHat,truncList,withinGridIdx) f_obs_noise(yk - ykHat,truncList,withinGridIdx);

%% Particle filter
[nx,sys]    = FS_processEq(handles.motion);
minAmpIdx   = zeros(nFish,nTime);
angThresh   = 0;
tankStart   = [tankCoord(1,1);tankCoord(1,2); 0];
tankRange   = [(tankCoord(2,1)-tankCoord(1,1));(tankCoord(4,2)-tankCoord(1,2)); 200];

parfor_progress(nFish);

for id = 1:nFish
    display(sprintf('\nFish  %d  of  %d',id,nFish));
    ahk                     = zeros(nCh,nTime);
    xFish                   = zeros(nTime,nx);
    xAmp                    = zeros(nTime,nCh, 2);
    ampAll                  = zeros(nFish,nCh,nTime);
    xh                      = zeros(nx,nTime);
    xhRev                   = zeros(nx,nTime);
    pf                      = struct;
    pfRev                   = struct;
    [pf.x ,pf.w]            = FS_initParticles(nPart, nx+1, handles.motion, tankStart, tankRange);
    [pfRev.x ,pfRev.w]      = FS_initParticles(nPart, nx+1, handles.motion, tankStart, tankRange);
    pf.p_yk_given_xk        = p_yk_given_ykHat;
    pfRev.p_yk_given_xk     = p_yk_given_ykHat;
    
    p1          = [fishHist(find([fishHist.id] == fishID(id))).p1];
    if ~isfield(fishHist,'dataType')
        for i = 1:nTime
            p2              = p1(:,i);
            if sum(isnan(p1(:,i))) < (nCh - 4)                           
                nanVec      = isnan(p1(:,i));
                p1Def       = p1(~nanVec,i);
                clustVec    = circ_clust(p1Def',2);

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
                p2(nanVec)  = NaN;
            end 
            p1(:,i)         = p2;            
        end
    end
    
    ampMagn                 = ([fishHist([fishHist.id] == fishID(id)).a1]);
    for i = 1:nCh
         ampMagn(i,:)       = ndnanfilter(ampMagn(i,:),'rectwin',3);
    end
    amp                     = ampMagn.*sign(cos(p1));
    freqTrack               = [[fishHist([fishHist.id] == fishID(id)).t]' ... 
                            [fishHist([fishHist.id] == fishID(id)).f1]'];
    
    % Make maximum amplitude positive
    [~,Midx]                = max(abs(amp));
    amp                     = amp.*repmat(sign(amp(sub2ind(size(amp),Midx,1:size(amp,2)))),size(amp,1),1);
    [~,subAmpIdxIndiv]      = max(abs(amp),[],1);
    
    for t = 1:nTime 
        [pf.x, xh(:,t), pf.w,ahk(:,t)] = FS_filter(pf, sys, amp(:,t),...
            handles.motion, gridCoord, tankCoord, tInt, subAmpIdxIndiv(t));

        [pfRev.x, xhRev(:,nTime-t+1), pfRev.w,~] = FS_filter(pfRev, sys, amp(:,nTime-t+1),...
            handles.motion, gridCoord, tankCoord, tInt, subAmpIdxIndiv(nTime-t+1));
    end
    
    if strcmp(handles.motion,'random')
        thForwBack_Mean     = wrapTo2Pi(circ_mean(atan(tan(wrapTo2Pi([xh(3,:);xhRev(3,:)])))))';
        xFish(:,:)          = [((xh(1:2,:)' + xhRev(1:2,:)')/2) thForwBack_Mean ];
    elseif strcmp(handles.motion,'random3D')
        thForwBack_Mean     = wrapTo2Pi(circ_mean(atan(tan(wrapTo2Pi([xh(3,:);(xhRev(3,:))])))))';
        xFish(:,:)          = [((xh(1:2,:)' + xhRev(1:2,:)')/2) thForwBack_Mean ((xh(4,:)' + xhRev(4,:)')/2)];
    end
    
    minAmpIdx(id,:)         = subAmpIdxIndiv;
    
    fish(id).id             = fishID(id);
    fish(id).freq           = freqTrack;
    fish(id).x              = xFish(:,1);
    fish(id).y              = xFish(:,2);
    fish(id).z              = xFish(:,4);
    fish(id).theta          = xFish(:,3);
    fish(id).ampAct         = amp;
    fish(id).ampTheor       = ahk;
    
    parfor_progress;
end
parfor_progress(0);
delete(gcp)

%% Save all data
particle.tankCoord      = tankCoord;
particle.gridCoord      = gridCoord;
particle.wildTag        = wildTag;
particle.fish           = fish;
particle.t              = fishTime;
particle.nPart          = nPart;
particle.varObs         = varObs;
particle.nFish          = nFish;
particle.nChannels      = nCh;

tempCell                = strsplit(handles.elecFile,'.');
particle.freqTrackFile  = tempCell{1};

dataFileName            = fullfile(handles.dir_path,'temp.mat');
save(dataFileName,'particle','-v6');