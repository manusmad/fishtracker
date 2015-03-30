function [xD,yD] = FS_testGridSim(wild)

if ~wild
    dD = 30;
    [yD,xD] = meshgrid(dD:-dD:-dD,-dD:dD:dD);
    % xD = xD';
    % yD = yD';
    xD = xD(:);
    yD = yD(:);

else
    %% Wild Electrode
    dD = 50;
    [yD,xD] = meshgrid(1.5*dD:-dD:-1.5*dD,-1.5*dD:dD:1.5*dD);
    % xD = xD';
    % yD = yD';
    xD = xD(:);
    yD = yD(:);
end
%%
% dD = 30;
% [xD,yD] = meshgrid(dD:-dD:-dD,0:dD:dD);
% xD = xD';
% yD = yD';
% xD = xD(:);
% yD = yD(:);
% 
% % xD(1) = [];
% % yD(1) = [];
% 
% % 8 electrode
% xD = [0;-dD; xD];         
% yD = [-dD;-dD; yD;];
% 
% dWild = 50;
% [xDWild,yDWild] = meshgrid(-dWild-dWild/2:dWild:dWild + dWild/2,-dWild-dWild/2:dWild:dWild + dWild/2);
%Wild Grid
% xDWild = [
% yDWild = 

%   testData
% xD = [-dD; xD];
% yD = [-dD; yD;];

% dD = 30;
% [xD,yD] = meshgrid(-dD:dD:dD,0:dD:dD);
% xD = xD';
% yD = yD';
% xD = xD(:);
% yD = yD(:);
% 
% % xD(1) = [];
% % yD(1) = [];
% xD = [0;-dD; xD];
% yD = [-dD;-dD; yD;];