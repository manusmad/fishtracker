function [xk, xhk, wk,idxDesc,yk,ahk] = FS_filter(pf, sys, gAmp, motion, gridcoord, tankcoord, tInt)
yk = gAmp - min(gAmp);
[nx,Ns] = size(pf.x(1:(end-1),:));  

%% Separate memory
xkm1 = pf.x; % extract particles from last iteration;
wkm1 = pf.w;

%% Algorithm 3 of Ref [1]
xkm1(3,:) = wrapTo2Pi(xkm1(3,:));
% xkm1(3,:) = circ_mean(xkm1(3,:));

xk = sys(xkm1, FS_gen_sysv_noise(nx,Ns,motion,tInt));

TruncElecList = ~isnan(yk); 
ykTrunc = yk(TruncElecList, :);
% offsetC = 0.01; %140625 - 0.05
offsetC = 0.00; %Sim
if sum(TruncElecList)
    aXk = FS_ObsvModel(xk, gridcoord, tankcoord, motion)';
    aXkTrunc = aXk(:,TruncElecList);
    InvKLDist = 1./(offsetC + abs(KLDiv(repmat(ykTrunc',Ns,1), aXkTrunc)));
%     wk = InvKLDist;
    wk = wkm1.* InvKLDist;

%      wk = (1./(sum((repmat(ykTrunc',Ns,1)- aXkTrunc).^2,2)));  %% Sum of sqrared errors - doesn't work well
%      wk = 1./acos(abs((dot(aXkTrunc,repmat(ykTrunc',Ns,1))./(sqrt(sum(aXkTrunc.^2,1)).*sqrt(sum(repmat(ykTrunc',Ns,1).^2,1))))));
else
    wk = wkm1;
end

%% Normalize weight vector
if sum(wk) == 0 || any(isinf(wk)) || any(isnan(wk))
%        wk = repmat(1/Ns, Ns,1); 
     wk = wkm1;
end
wk = wk./sum(wk);

%% Compute estimated state

% xhk = sum((repmat(wk(wIdx(1:effPart))',nx,1).*xk(:,wIdx(1:effPart))),2);
% xhk = sum((repmat(wk(wIdx(1:Neff))',nx,1).*xk(:,wIdx(1:Neff))),2);

age_thresh = 3; %140625 - 6
idx = find(xk(end,:) >= age_thresh); 
idxm1 = find(xkm1(end,:) >= age_thresh); 

xhk(1:2,1) = sum((repmat(wk(idx)',nx-1,1).*xk(1:2,idx)),2);
% xhk(3,1)   = wrapTo2Pi(circ_mean(2*wrapTo2Pi(xk(3,idx)),wk(idx)',2));
xhk(3,1)   = wrapTo2Pi(circ_mean(acos(cos(2*wrapTo2Pi(xk(3,idx))))/2,wk(idx)',2));

xhkm1(1:2,1) = sum((repmat(wkm1(idxm1)',nx-1,1).*xkm1(1:2,idxm1)),2);
xhkm1(3,1)   = wrapTo2Pi(circ_mean(acos(cos(2*wrapTo2Pi((xkm1(3,idxm1)))))/2,wkm1(idxm1)',2));

% figure(5)
% hist(wrapTo2Pi(xk(3,idx)),100)

ahk = FS_ObsvModel(xhk, gridcoord, tankcoord, motion)';
% rX = sqrt((xhk(1)-xhkm1(1))^2 + (xhk(2)-xhkm1(2))^2);
% threshD = 1;
% if rX > threshD*tInt
% %     w1 = rX/(rX+threshD*tInt);
%     xhk = xhkm1;
% end
% 
% % xhk = mean([xhk xhkm1],2);
        
%% Resampling

% % Calculate effective sample size: eq 48, Ref 1
% resample_percentaje = 0.5;
% Neff = floor(1/sum(wk.^2));
Ns = length(wk);  % Ns = number of particles
% Neff = floor(0.95*Ns); % Static
% Neff = floor(0.95*Ns); % Moving 40 - 0.95 %140625.95 .99
resampled_ratio = 1;

Neff = floor(resampled_ratio*Ns); % SIm
%     if Neff < resample_percentaje*Ns;
%        disp('Resampling ...')
       [xk, wk] = resample(xk, wk, xhk, nx, motion, tInt,tankcoord, Neff);
%        {xk, wk} is an approximate discrete representation of p(x_k | y_{1:k})
%     end

[~,idxDesc] = sort(wk,'descend');    
return; %

%% Resampling function
function [xk, wk] = resample(xk, wk, xhk, nx, motion, tInt,tankcoord, Neff)
Ns = length(wk);  % Ns = number of particles
centered_ratio = 1;

idx = randsample(1:Ns, Neff, 1, wk);
xk  = xk(:,idx);    % extract new particles
wxk = wk(idx);
xk(end,:) = xk(end,:) + 1;
% wxk = repmat(mean(wk(idx,1)),Neff,1); 

% centered_particles = floor(1*(Ns - Neff));    % Static
centered_particles = floor(centered_ratio*(Ns - Neff));    %0.9 & Moving 40 -1 %140625 - 0.99
random_particles   = (Ns - Neff) - centered_particles;

if strcmp(motion, 'uni')
    % Unicycle 
    %     xNew_centered = [(xhk(1,1)+ 5*randn(1,centered_particles)); (xhk(2,1)+ 5*randn(1,centered_particles)); wrapToPi(xhk(3,1)+ 1*randn(1,centered_particles));repmat(xhk(4:end,1), 1, centered_particles)] + FS_gen_sysv_noise(nx, centered_particles, motion);
%     xNew_centered = [(xhk(1,1)+ 5*randn(1,centered_particles)); (xhk(2,1)+ 5*randn(1,centered_particles)); wrapToPi(xhk(3,1)+ 1*randn(1,centered_particles));xhk(4,1) + 0.1*randn(1,centered_particles); xhk(5,1) + 0.05*randn(1,centered_particles)];
    xNew_centered = [(xhk(1,1)+ 2.5*randn(1,centered_particles)); (xhk(2,1)+ 2.5*randn(1,centered_particles)); wrapToPi(xhk(3,1)+ 0.2*randn(1,centered_particles));xhk(4,1) + 0.1*randn(1,centered_particles); xhk(5,1) + 0.01*randn(1,centered_particles)];
    %     xNew_centered = repmat(xhk, 1, centered_particles) + repmat(wMatrix, 1, centered_particles).*FS_gen_sysv_noise(nx, centered_particles, motion, tInt);
elseif strcmp(motion, 'random')
    % Random
    %{
    xNew_centered   = [];
    pkL             = size(pkList,2);
%     nPartDistr = floor(centered_particles*pkList(3,:));
    nPartDistr = floor(centered_particles*(1/pkL)*ones(1,pkL));
    nPartDistr(end) = nPartDistr(end) + (centered_particles -sum(nPartDistr));
    for nPeaks = 1:size(pkList,2)
        xNew_centered = [xNew_centered [(pkList(1,nPeaks)+ 10*randn(1,nPartDistr(nPeaks))); (pkList(2,nPeaks)+ 10*randn(1,nPartDistr(nPeaks))); wrapToPi(xhk(3,1)+ 1*randn(1,nPartDistr(nPeaks)))]] ;
    end
    %}

    % xNew_centered = repmat(xhk, 1, centered_particles) + repmat(wMatrix, 1, centered_particles).*FS_gen_sysv_noise(nx, centered_particles, motion, tInt);
%     xNew_centered = [(xhk(1,1)+ 10*tInt*randn(1,centered_particles)); (xhk(2,1)+ 10*tInt*randn(1,centered_particles)); wrapToPi(xhk(3,1)+ 1*tInt*randn(1,centered_particles))];
    xNew_centered = [(xhk(1,1)+ 5*randn(1,centered_particles)); (xhk(2,1)+ 5*randn(1,centered_particles)); wrapTo2Pi(xhk(3,1)+ .05*randn(1,centered_particles)); zeros(1,centered_particles)] ;
    % 3.5 Static
    %4.5Moving
elseif strcmp(motion, 'randomLineCharge')
    % Random
    %{
     xNew_centered   = [];
    pkL             = size(pkList,2);
    nPartDistr = floor(centered_particles*pkList(3,:));
%     nPartDistr = floor(centered_particles*(1/pkL)*ones(1,pkL));
    nPartDistr(end) = nPartDistr(end) + (centered_particles -sum(nPartDistr));
    for nPeaks = 1:size(pkList,2)
        xNew_centered = [xNew_centered [(pkList(1,nPeaks)+ 10*randn(1,nPartDistr(nPeaks))); (pkList(2,nPeaks)+ 10*randn(1,nPartDistr(nPeaks))); wrapToPi(xhk(3,1)+ 1*randn(1,nPartDistr(nPeaks))); (xhk(4,1)+ 0.1*randn(1,nPartDistr(nPeaks)))]] ;
    end
    %}
    xNew_centered = [(xhk(1,1)+ 2*randn(1,centered_particles)); (xhk(2,1)+ 2*randn(1,centered_particles)); wrapToPi(xhk(3,1)+ 1*randn(1,centered_particles)); (xhk(4,1)+ 0.1*randn(1,centered_particles))] ;
end

% New Particles with random x, y and th 
[xNew_random, ~] = FS_initParticles(random_particles, nx+1, motion,tankcoord);
%     size(xNew_random)

xk      = [xk xNew_centered xNew_random];

% percNeff = 0.9;  % 0.70 Moving 40
% wxk     = repmat(percNeff/Neff,Neff,1);
% centPerc = 0.89;  % 0.89 Moving 40

% percNeff = sum(wxk);
% centPerc = (1-percNeff)/centered_particles;
% 
% wcentered = repmat(centPerc*(1-percNeff)/centered_particles,centered_particles,1);
% wknew     = repmat((1-centPerc)*(1-percNeff)/random_particles,random_particles,1);
% wk      = [wxk;wcentered;wknew];

wk      = repmat(1/Ns, Ns,1);          % now all particles have the same weight

% wknew   = repmat((1-sum(wxk))/(Ns-Neff), (Ns-Neff),1);
% wk      = [wxk;wknew];
% wk = [wk_resample wk_new]';

return;  % bye, bye!!!
