function [particles,w] = FS_initParticles(Ns, nx, motion, partStart, partRange)

particles = zeros(nx,Ns);
if strcmp(motion,'random')
    particles(1,:) = rand(1,Ns)*(partRange(1)) + partStart(1);
    particles(2,:) = rand(1,Ns)*(partRange(2)) + partStart(2);
    particles(3,:) = rand(1,Ns)*2*pi;
elseif strcmp(motion,'random3D')
    particles(1,:) = rand(1,Ns)*(partRange(1)) + partStart(1);
    particles(2,:) = rand(1,Ns)*(partRange(2)) + partStart(2);
    particles(3,:) = rand(1,Ns)*2*pi;
    particles(4,:) = rand(1,Ns)*(partRange(3)) + partStart(3);
end

%% Initialize variables

% particles = gen_x0(nx,Ns);          % simulate initial particles     
w = repmat(1/Ns, Ns, 1);            % all particles have the same weight
