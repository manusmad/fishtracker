function elec = loadSmrFile(dataFolder,smrFile,prefix)

% dataFolder = '../../Field2014/data';
% smrFile = 'machete_2.smr';
% prefix = 'Ch';

% Open Spike2 file
fid = fopen(fullfile(dataFolder,smrFile));
C = SONChanList(fid);

m=regexp({C.title},['^' prefix '(?<ch>\d+)'],'names');
elecChan = find(~cellfun('isempty',m));
M = [m{elecChan}];
nCh = length(M);

if nCh==0
    error('No channels found');
end

progressbar('Loading smr file');

% Load channels
estr(1:nCh) = struct('values',[],'header',[]);
for k = 1:nCh
    progressbar(k/nCh);
    [estr(k).values,estr(k).header] = SONGetChannel(fid,elecChan(k));
    [estr(k).values,estr(k).header] = SONADCToDouble(estr(k).values,estr(k).header);
    
    if k == 1 || length(estr(k).values)<N
        N = length(estr(k).values);
    end
end

int = estr(1).header.sampleinterval;
elec.meta.int = int;
elec.meta.Fs = 1/int;
elec.meta.nCh = nCh;
elec.meta.N = N;
elec.meta.chNum = arrayfun(@(x) str2double(x.ch),M);
elec.meta.chPrefix = prefix;
elec.meta.sourceFile = smrFile;

elec.t = int:int:N*int;
elec.data = zeros(N,nCh);
for k = 1:nCh
    elec.data(:,k) = estr(k).values(1:N);
end