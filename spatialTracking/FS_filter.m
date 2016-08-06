function [xk, xhk, wk,idxDesc,yk,ahk,wkPriorResample,xkPriorResamp] = FS_filter(pf, sys, gAmp, motion, gridcoord, tankcoord, tInt, genLoop,fittedExpModel,minElecIdx)

yk = gAmp - gAmp(minElecIdx);
[nx,Ns] = size(pf.x(1:(end-1),:));  

%% Separate memory
xkm1 = pf.x; % extract particles from last iteration;
wkm1 = pf.w;

%% Algorithm 3 of Ref [1]
xkm1(3,:) = wrapTo2Pi(xkm1(3,:));
% xkm1(3,:) = circ_mean(xkm1(3,:));
TruncElecList = ~isnan(yk); 
if sum(TruncElecList)
    xk = sys(xkm1, FS_gen_sysv_noise(nx,Ns,motion,tInt));
else 
    xk = xkm1;
end
xhkm1(1:2,1) = sum((repmat(wkm1',2,1).*xkm1(1:2,:)),2);
withinGridIdx = (xhkm1(1,:) < (max(gridcoord(:,1))) & (xhkm1(1,:) > min(gridcoord(:,1))) ...
                                    & xhkm1(2,:) < (max(gridcoord(:,2))) & xhkm1(2,:) > (min(gridcoord(:,2))));
                                
distVar = abs(xhkm1(1:2,1)' - repmat(gridcoord(5,:),size(xhkm1,2),1));
distCen = sqrt(distVar(:,1).^2 + distVar(:,2).^2);

maxTankDist = sqrt(max(abs(tankcoord(:,1)))^2+max(abs(tankcoord(:,2)))^2);
distFrac = (distCen/maxTankDist)^5;


% nTruncElec = length(find(TruncElecList == 1));
% wGMat(1,1,1:size(withinGridIdx,2)) = withinGridIdx;
% wGMatList = repmat(wGMat,[nTruncElec nTruncElec,1]);

ykTrunc = yk(TruncElecList, :);
% offsetC = 0.01; %140625 - 0.05
offsetC = 0.00; %Sim
if sum(TruncElecList)
    aXk = FS_ObsvModel(xk, gridcoord, tankcoord, motion,fittedExpModel,minElecIdx)';
    aXkTrunc = aXk(:,TruncElecList);
    
%     aXkm1 = FS_ObsvModel(xkm1, gridcoord, tankcoord, motion,fittedExpModel)';
%     aXkm1Trunc = aXkm1(:,TruncElecList);
    
%     InvKLDist = 1./(offsetC + abs(KLDiv(repmat(ykTrunc',Ns,1), aXkTrunc)));
%     wk = wkm1.* InvKLDist;

    wk = wkm1 .* pf.p_yk_given_xk(repmat(normr(ykTrunc'),Ns,1), normr(aXkTrunc),TruncElecList,withinGridIdx);
    
%      wk = (1./(sum((repmat(ykTrunc',Ns,1)- aXkTrunc).^2,2)));  %% Sum of sqrared errors - doesn't work well
%      wk = wkm1.*(1./acos(abs((dot(aXkTrunc',repmat(ykTrunc',Ns,1)')'./(sqrt(sum(aXkTrunc.^2,2)).*sqrt(sum(repmat(ykTrunc',Ns,1).^2,2)))))));
else
    wk = wkm1;
end

%% Normalize weight vector
if sum(wk) == 0 || any(isinf(wk)) || any(isnan(wk))
%        wk = repmat(1/Ns, Ns,1); 
     wk = wkm1;
end
wk = wk./sum(wk);
[~,idxDesc] = sort(wk,'descend'); 
wkPriorResample = wk;

%% Compute estimated state

age_thresh = 0; %140625 - 6
idx = find(xk(end,:) >= age_thresh); 
% idxm1 = find(xkm1(end,:) >= age_thresh); 

% if sum(TruncElecList)
    xhk(1:2,1) = sum((repmat(wk(idx)',2,1).*xk(1:2,idx)),2);

    % xhk(3,1)   = wrapTo2Pi(circ_mean(xk(3,idx),wk(idx)',2));
    xhk(3,1)   = wrapTo2Pi(circ_mean(atan(tan(wrapTo2Pi((xk(3,idx))))),wk(idx)',2));


    if strcmp(motion,'random3D')
        xhk(4,1) = sum((wk(idx)'.*xk(4,idx)),2);
    end
% else
%     xhk = xkm1;
% end
    
ahk = FS_ObsvModel(xhk, gridcoord, tankcoord, motion,fittedExpModel,minElecIdx)';
        
%% Resampling

% % Calculate effective sample size: eq 48, Ref 1
resample_percentage = 0.5;
Neff = floor(1/sum(wk.^2));
Ns = length(wk);  % Ns = number of particles
% Neff = floor(0.95*Ns); % Static
% Neff = floor(0.95*Ns); % Moving 40 - 0.95 %140625.95 .99

if genLoop < 3
    resampled_ratio = 0.9 ;
else
    resampled_ratio = 1 ;
end

% Neff = floor(resampled_ratio*Ns); % SIm
xkPriorResamp = xk;
    if Neff < resample_percentage*Ns;
%        disp('Resampling ...')
%        Neff/Ns
% xkPriorResamp = xk;
       [xk, wk] = resample(xk, wk, xhk, nx, motion, tInt,tankcoord, Neff);
%        {xk, wk} is an approximate discrete representation of p(x_k | y_{1:k})
    end

% [~,idxDesc] = sort(wk,'descend');    
return; %

%% Resampling function
function [xk, wk] = resample(xk, wk, xhk, nx, motion, tInt,tankcoord, Neff)
Ns = length(wk);  % Ns = number of particles
centered_ratio = 0.9;

idx = randsample(1:Ns, Neff, 1, wk);
xk  = xk(:,idx);    % extract new particles
% wxk = wk(idx);
xk(end,:) = xk(end,:) + 1;

centered_particles = floor(centered_ratio*(Ns - Neff));    %0.9 & Moving 40 -1 %140625 - 0.99
random_particles   = (Ns - Neff) - centered_particles;

if strcmp(motion, 'uni')
    xNew_centered = [(xhk(1,1)+ 2.5*randn(1,centered_particles)); (xhk(2,1)+ 2.5*randn(1,centered_particles)); wrapToPi(xhk(3,1)+ 0.2*randn(1,centered_particles));xhk(4,1) + 0.1*randn(1,centered_particles); xhk(5,1) + 0.01*randn(1,centered_particles)];
elseif strcmp(motion, 'random')
    xNew_centered = [(xhk(1,1)+ 5*randn(1,centered_particles)); (xhk(2,1)+ 5*randn(1,centered_particles)); wrapTo2Pi(xhk(3,1)+ .05*randn(1,centered_particles)); zeros(1,centered_particles)] ;
elseif strcmp(motion, 'random3D')
    xNew_centered = [(xhk(1,1)+ 5*randn(1,centered_particles)); (xhk(2,1)+ 5*randn(1,centered_particles)); wrapTo2Pi(xhk(3,1)+ .05*randn(1,centered_particles)); (xhk(4,1)+ 5*randn(1,centered_particles)); zeros(1,centered_particles)] ;
elseif strcmp(motion, 'randomLineCharge')
    xNew_centered = [(xhk(1,1)+ 2*randn(1,centered_particles)); (xhk(2,1)+ 2*randn(1,centered_particles)); wrapToPi(xhk(3,1)+ 1*randn(1,centered_particles)); (xhk(4,1)+ 0.1*randn(1,centered_particles))] ;
end

% New Particles with random x, y and th 
scoutRange = [10;10];
tankStart = [tankcoord(1,1);tankcoord(1,2);0];
tankRange = [(tankcoord(2,1)-tankcoord(1,1));(tankcoord(4,2)-tankcoord(1,2));200];

% [xNew_random, ~] = FS_initParticles(random_particles, nx+1, motion,xhk(1:2) - scoutRange/2,scoutRange);
[xNew_random, ~] = FS_initParticles(random_particles, nx+1,motion, tankStart,tankRange);
xk      = [xk xNew_centered xNew_random];
% percNeff = sum(wxk);
% centPerc = (1-percNeff)/centered_particles;
wk      = repmat(1/Ns, Ns,1);          % now all particles have the same weight

return; 
