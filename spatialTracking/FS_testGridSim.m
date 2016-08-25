function [xD,yD] = FS_testGridSim(wild)

if ~wild
% Lab Grid begin    
    dD = 30;
    [yD,xD] = meshgrid(dD:-dD:-dD,-dD:dD:dD);
    xD = xD(:);
    yD = yD(:);
% Lab Grid end
else
    %% Wild Electrode
    % ... begin    
    %     dD = 50;
    %     [yD,xD] = meshgrid(1.5*dD:-dD:-1.5*dD,-1.5*dD:dD:1.5*dD);
    %     xD = xD(:);
    %     yD = yD(:);
    % ... begin

% Terraronca Begin
    scaleFact      = 23.8;
    xD = 1.0e+03 *[3.2516;
                   1.9349;
                   0.7205;
                   2.5974;
                   1.3298;
                   3.1903;
                   1.9963;
                   0.8064];


    yD = 1.0e+03 *[2.6021;
                   2.5776;
                   2.5572;
                   1.4449;
                   1.4572;
                   0.3491;
                   0.3818;
                   0.3941];

    xD = (xD - 1983)/scaleFact;
    yD = (yD - 1452)/scaleFact;
% Terraronca End
end