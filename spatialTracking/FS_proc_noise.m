function sysv_noise = FS_proc_noise(rw, clmn, motion, tInt)

%% Description: 
% Generating process noise. The noise statistics are tuned for a sampling
% rate of 20Hz
% Input variables: 
%     rw: no. of rows of noise matrix; corresponds to number of states
%     clmn: no. of columns of noise matrix; corresponds to no. of particles
%     motion: type of mition
%     tInt: mean sampling interval
%
% Author: Ravikrishnan Perur Jayakumar
%%

sig_x   = (tInt/3.02)^0.0001;
sig_y   = (tInt/3.02)^0.0001;
sig_th  = (tInt*pi/(.5));
sig_z   = (tInt/3.02)^0.0001;

sig_pos         = [sig_x; sig_y;sig_th];
sig_pos3D       = [sig_x; sig_y;sig_th;sig_z];

if strcmp(motion, 'random')
    sig_u = sig_pos;
elseif strcmp(motion, 'random3D')
    sig_u = sig_pos3D;
end

sig_mean    = zeros(rw,1);
sysv_noise  = [normrnd(repmat(sig_mean,1,clmn), repmat(sig_u,1,clmn), rw,clmn); zeros(1,clmn)];