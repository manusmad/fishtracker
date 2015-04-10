function [nx,sys] = FS_processEq(motion)

%% Process equation x[k] = sys(k, x[k-1], u[k]);
if strcmp(motion,'random')
    nx = 3; % Random - number of states
    sys = @(xk, uk) xk + uk;
elseif strcmp(motion,'randomLineCharge')
    nx = 4;
    sys = @(xk, uk) xk + uk;
elseif strcmp(motion, 'uni')
    nx = 5;  % Unicycle - number of states: X, Y, Theta, Linear Velocity, Angular Velocity
    sys = @(xk, uk) xk + [xk(4,:).*cos(xk(3,:)) ; xk(4,:).*sin(xk(3,:)) ; xk(5,:) ; zeros(nx-3 , size(xk,2))] + uk;
end