function [xk, xhk, wk,yk,ahk,wkPriorResample,xkPriorResamp] = FS_filter(pf, sys, gAmp, motion, gridcoord, tankcoord, tInt,minElecIdx)

yk                  = gAmp - gAmp(minElecIdx);
[nx,Ns]             = size(pf.x(1:(end-1),:));  

%% Separate memory
xkm1                = pf.x; 
wkm1                = pf.w;

%% Algorithm 3 of Ref [1]
xkm1(3,:)           = wrapTo2Pi(xkm1(3,:));
TruncElecList       = ~isnan(yk); 
if sum(TruncElecList)
    xk              = sys(xkm1, FS_gen_sysv_noise(nx,Ns,motion,tInt));
else 
    xk              = xkm1;
end
xhkm1(1:2,1)        = sum((repmat(wkm1',2,1).*xkm1(1:2,:)),2);
withinGridIdx       = (xhkm1(1,:) < (max(gridcoord(:,1))) & (xhkm1(1,:) > min(gridcoord(:,1))) ...
                                    & xhkm1(2,:) < (max(gridcoord(:,2))) & xhkm1(2,:) > (min(gridcoord(:,2))));

ykTrunc             = yk(TruncElecList, :);
if sum(TruncElecList)
    aXk             = FS_ObsvModel(xk, gridcoord, minElecIdx)';
    aXkTrunc        = aXk(:,TruncElecList);
    wk              = wkm1 .* pf.p_yk_given_xk(repmat(normr(ykTrunc'),Ns,1), normr(aXkTrunc),TruncElecList,withinGridIdx);
else
    wk              = wkm1;
end

%% Normalize weight vector
if sum(wk) == 0 || any(isinf(wk)) || any(isnan(wk))
     wk             = wkm1;
end
wk                  = wk./sum(wk);
wkPriorResample     = wk;

%% Compute estimated state

xhk(1:2,1)          = sum((repmat(wk',2,1).*xk(1:2,:)),2);
xhk(3,1)            = wrapTo2Pi(circ_mean(atan(tan(wrapTo2Pi((xk(3,:))))),wk',2));
if strcmp(motion,'random3D')
    xhk(4,1)        = sum((wk'.*xk(4,:)),2);
end    
ahk                 = FS_ObsvModel(xhk, gridcoord, minElecIdx)';
        
%% Resampling
resample_percentage = 0.5;
Neff                = floor(1/sum(wk.^2));
Ns                  = length(wk);

xkPriorResamp       = xk;
if Neff < resample_percentage*Ns;
   [xk, wk]         = resample(xk, wk, xhk, nx, motion,tankcoord, Neff, Ns);
end
return;

%% Resampling function
function [xk, wk]   = resample(xk, wk, xhk, nx, motion,tankcoord, Neff, Ns)
    centered_ratio      = 0.9;
    idx                 = randsample(1:Ns, Neff, 1, wk);
    xk                  = xk(:,idx);
    xk(end,:)           = xk(end,:) + 1;
    centered_particles  = floor(centered_ratio*(Ns - Neff));
    random_particles    = (Ns - Neff) - centered_particles;
    xNew_centered       = [(xhk(1,1)+ 5*randn(1,centered_particles)); (xhk(2,1)+ 5*randn(1,centered_particles)); wrapTo2Pi(xhk(3,1)+ .05*randn(1,centered_particles)); (xhk(4,1)+ 5*randn(1,centered_particles)); zeros(1,centered_particles)] ;
    tankStart           = [tankcoord(1,1);tankcoord(1,2);0];
    tankRange           = [(tankcoord(2,1)-tankcoord(1,1));(tankcoord(4,2)-tankcoord(1,2));200];
    [xNew_random, ~]    = FS_initParticles(random_particles, nx+1,motion, tankStart,tankRange);
    xk                  = [xk xNew_centered xNew_random];
    wk                  = repmat(1/Ns, Ns,1);
return; 
