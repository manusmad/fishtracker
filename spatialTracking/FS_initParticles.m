function [particles,w] = FS_initParticles(Ns, nx, motion,tankCoord)

% init_x = 90;
% init_y = 90;
% init_th = 1.5*pi;
% 
% init_L = 2.5;
% init_V = 2;
% init_Vth = 0.01;
% init_f = 2*pi*200;
% init_A = 100;
% init_B = 100;
% init_C = 100;
% init_D = 100;


% init_pos = [init_x; init_y;init_th];
% init_sigParam = [init_V; init_Vth];
% init_sigParam = [init_f; init_A; init_B; init_C; init_D];

% if strcmp(motion, 'uni')
%     init_u = [init_pos;...
%          init_sigParam];
% elseif strcmp(motion, 'random')
%     init_u = [init_pos];
% elseif strcmp(motion, 'randomLineCharge')
%     init_u = [init_pos; init_L];
% end
% init_mean = zeros(nx,1);
% init_mean(4,1) = 2*pi*400;


% gen_x0 = @(rw,clmn) [normrnd(repmat(init_mean,1,clmn), repmat(init_u, 1, clmn), rw, clmn); ones(1,clmn)];  
%  
% tankDepth = (tankCoord(2,1)-tankCoord(1,1))/6;

particles = zeros(nx,Ns);
if strcmp(motion,'random')
    particles(1,:) = rand(1,Ns)*(tankCoord(2,1)-tankCoord(1,1)) + tankCoord(1,1);
    particles(2,:) = rand(1,Ns)*(tankCoord(4,2)-tankCoord(1,2)) + tankCoord(1,2);
%     particles(3,:) = rand(1,Ns)*tankDepth;
%     particles(3,:) = rand(1,Ns)*2*pi - pi;
     particles(3,:) = rand(1,Ns)*2*pi;
end

%% Initialize variables

% particles = gen_x0(nx,Ns);          % simulate initial particles     
w = repmat(1/Ns, Ns, 1);            % all particles have the same weight
