function sysv_noise = FS_gen_sysv_noise(rw, clmn, motion, tInt)
sig_x = (tInt/3.02)^0.0001;
sig_y = (tInt/3.02)^0.0001;
sig_th = (tInt*pi/(.5));
sig_z = (tInt/3.02)^0.0001;

sig_L = 0.0;

sig_V = tInt;
sig_Vth = tInt/5;
% sig_V = tInt/8.5;
% sig_Vth = tInt/18;


sig_pos = [sig_x; sig_y;sig_th];
sig_pos3D = [sig_x; sig_y;sig_th;sig_z];
sig_sigParam = [sig_V; sig_Vth];
% sig_sigParam = [sig_f; sig_A; sig_B; sig_C; sig_D];

if strcmp(motion, 'uni')
sig_u = [sig_pos;...
         sig_sigParam];
elseif strcmp(motion, 'random')
     sig_u = [sig_pos];
 elseif strcmp(motion, 'random3D')
     sig_u = sig_pos3D;
elseif strcmp(motion, 'randomLineCharge')
     sig_u = [sig_pos; sig_L];
end
sig_mean = zeros(rw,1);


% p_sys_noise   = @(u) normpdf(u, zeros(nu,1), sigma_u);
% sample from p_sys_noise (returns column vector)
sysv_noise = [normrnd(repmat(sig_mean,1,clmn), repmat(sig_u,1,clmn), rw,clmn); zeros(1,clmn)];