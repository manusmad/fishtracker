function [nx,sys] = FS_processEq(motion)

%% Description: 
% Process equation defining random motion model
% x[k] = sys(k, x[k-1], u[k]);
%
% Author: Ravikrishnan Perur Jayakumar
%%
if strcmp(motion,'random')
    nx = 3; % Random - number of states
    sys = @(xk, uk) xk + uk;
elseif strcmp(motion,'random3D')
    nx = 4; % Random - number of states
    sys = @(xk, uk) xk + uk;
end