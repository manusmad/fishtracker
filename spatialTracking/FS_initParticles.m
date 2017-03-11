function [particles,w] = FS_initParticles(Ns, nx, motion, partStart, partRange)

%% Description: 
% Generates randomly distributed particles over a specified range around an
% initial point. 
% Input: 
%     Ns        : No. of particles 
%     nx        : No. of states (random=(x,y,theta);random3D =(x,y,theta,z)
%     motion    : Type of motion (random or random3D, unicycle not
%                                 implemented)
%     partStart : Initial offset added to particles
%     partRange : Range around initial offset in (x,y,theta and/or z) space

% Input: 
%     particles : Ns particles uniformly randomly distributed over the
%     region partStart (initial offset) + partRange (range of state space)
%     w         : initial weight associated with particles
%
% Author: Ravikrishnan Perur Jayakumar
%%

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

w = repmat(1/Ns, Ns, 1);            % all particles have the same weight
