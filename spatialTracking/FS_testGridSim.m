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
%     dD = 50;
%     [yD,xD] = meshgrid(1.5*dD:-dD:-1.5*dD,-1.5*dD:dD:1.5*dD);
%     % xD = xD';
%     % yD = yD';
%     xD = xD(:);
%     yD = yD(:);
    % Eric Brazil Grid - 505 pixels corresponds 20cm 
%     xD = [-1120; 0   ; 1228; -640; 680; -1212;     0; 1312]/25;
%     yD = [1068;  1068; 1128;    0;   0; -1065; -1140;-1148]/25;


scaleFact = 23.8;
xD = 1.0e+03 *[3.2516;
    1.9349;
    0.7205;
    2.5974;
    1.3298;
    3.1903;
    1.9963;
    0.8064];


yD =1.0e+03 *[2.6021;
    2.5776;
    2.5572;
    1.4449;
    1.4572;
    0.3491;
    0.3818;
    0.3941];

xD = (xD - 1983)/scaleFact;
yD = (yD - 1452)/scaleFact;
%}  
% xD = [50;0;-50;25;-25;50;0;-50];
% yD = [50;50;50;0;0;-50;-50;-50];
    
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