function createGridConfig()

%% Description: 
% Creates a text file that specifies the (x,y,z) coordinates of the
% electrodes in the grid.
% - The units of the coordinates can be arbitrary - the output of the spatial
% tracking will be in the same units
% - Enter the electrodes in the same order as what was used for
% recording the data. 
%
% Author: Ravikrishnan Perur Jayakumar

%% Enter the grid configuration details. 

prompt = 'Number of electrodes? : '; % Numerical entry
nElec = input(prompt);
doneFlag = 0;
xD = zeros(nElec,1);
yD = zeros(nElec,1);
zD = zeros(nElec,1);
str = cell(nElec,1);
figure();
prompt = 'Grid descriptor text? : '; % Details like what dataset is this associated with e.g. Lab data, Terraronca
gridText = input(prompt,'s');
while ~doneFlag
    
    nElecFlag = 0;
    while ~nElecFlag 
        display('Enter each X coord separated by a comma and in the same order as in the Spike2 recordings')
        prompt  = 'Electrode X-coord : ';
        xDStr   = input(prompt,'s');
        xDSplit = strsplit(xDStr,',');
        xD      =  cellfun(@str2num, xDSplit);

        prompt = 'Electrode Y-coord : ';
        yDStr   = input(prompt,'s');
        yDSplit = strsplit(yDStr,',');
        yD      =  cellfun(@str2num, yDSplit);
        
        prompt = 'Electrode Z-coord : ';
        zDStr   = input(prompt,'s');
        zDSplit = strsplit(zDStr,',');
        zD      =  cellfun(@str2num, zDSplit);
        if length(xD) == nElec && length(yD) == nElec && length(zD) == nElec
            nElecFlag = 1;
        else
            display('The length of the x-coord vector and/or y-coord vector and/or z-coord vector is not equal to the total number  of required electrodes. Please re-enter');
        end
    end
    
    for i = 1:nElec
        str{i} = ['Elec ' num2str(i) ': ' num2str(xD(i)) ', ' num2str(yD(i)) ', ' num2str(zD(i))];
    end
    
    scatter(gca,xD,yD,20,'k','filled')
    text(xD,yD,str)
    xlim([(min(xD) - 20) (max(xD) + 20)])
    ylim([(min(yD) - 20) (max(yD) + 20)])
    
    validStr = 0;
    while ~validStr
        prompt = 'Done? (y/n) : ';
        doneStr = input(prompt,'s');
        if strcmp(doneStr,'y')
            doneFlag = 1;
            validStr = 1;
        elseif strcmp(doneStr,'n')
            doneFlag = 0;
            validStr = 1;
        else
            display('Invalid entry. Please enter "y" or "n".');
        end
    end        
end

%% Save grid configuration text file

% Note: Select base directory of dataset (the one containing the folders freqtracks,specs,
% raw etc). 
% spatialTracking.m will look for gridConfig.txt in this folder. 

folder_name = uigetdir(pwd,'Save grid config file in ...');

fileID = fopen(fullfile(folder_name,'gridConfig.txt'),'w');
fprintf(fileID,'%6s \n',gridText);
fprintf(fileID,'%6s %12s %18s \n','X-Coord','Y-Coord','Z-Coord');
fprintf(fileID,'%6.1f %12.1f %18.1f \n',[xD; yD; zD]);
fclose(fileID);