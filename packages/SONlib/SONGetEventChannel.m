function[data,h]=SONGetEventChannel(fid,chan)
% Reads an event channel form a SON file.
%

% Malcolm Lidierth 02/02


Info=SONChannelInfo(fid,chan);
if(Info.kind==0) 
    warning('SONGetEventChannel: No data on that channel');
    return;
end;

FileH=SONFileHeader(fid);
SizeOfHeader=20;                                            % Block header is 20 bytes long
header=SONGetBlockHeaders(fid,chan);

NumberOfSamples=sum(header(5,:));                           % Sum of samples in all blocks

data=zeros(NumberOfSamples,1);                              % Pre-allocate memory for data
pointer=1;
for i=1:Info.blocks                                         
    fseek(fid,header(1,i)+SizeOfHeader,'bof');
    data(pointer:pointer+header(5,i)-1)=fread(fid,header(5,i),'int32=>single');
    pointer=pointer+header(5,i);
end;

data=SONTicksToSeconds(fid,data);                              % Convert to seconds

if(nargout>1)
    h.FileName=Info.FileName;                                   % Set up the header information to return
    h.system=['SON' num2str(FileH.systemID)];                   % if it's been requested
    h.FileChannel=chan;
    h.phyChan=Info.phyChan;
    h.kind=Info.kind;
    h.comment=Info.comment;
    h.title=Info.title;
    if (Info.kind==4)
        h.initLow=Info.initLow;
%         h.initMax=Info.initMax;
    end;
end;