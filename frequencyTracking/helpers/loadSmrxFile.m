function elec = loadSmrxFile(dataFolder,smrxFile,prefix)
% LOADSMRFILE Loads Spike2 smrx raw data file
%
% Uses the CEDS64 library to attempt to load the *.smrx file smrxFile. Uses the
% string variable prefix to look for Channel names in the file. Will only
% work on Windows.
%
% Manu S. Madhav
% 2016

CEDS64LoadLib(fileparts(which('CEDS64LoadLib.m')));

fhand = CEDS64Open(fullfile(dataFolder,smrxFile));
if (fhand <= 0); unloadlibrary ceds64int; return; end

maxchans = CEDS64MaxChan(fhand);
int = double(CEDS64ChanDiv(fhand,1)*CEDS64TimeBase(fhand));

%% Find which channels are A/D and have the right prefix
C = [];
for m = 1:maxchans
    chan.type = CEDS64ChanType( fhand, m );
    [~,chan.title] = CEDS64ChanTitle(fhand,m);
    C = [C;chan];
end

M = regexp({C.title},['^' prefix '(?<ch>\d+)'],'names');
elecChan = find(~cellfun('isempty',M) & [C.type]==1);
M = [M{elecChan}];
C = C(elecChan);

%% Load all relevant channels
for k = 1:length(elecChan)
    [~,C(k).wave] = CEDS64ReadWaveF(fhand,elecChan(k),1e8,0);
    L = length(C(k).wave);
    if k == 1 || L < N
        N = L;
    end
end

%%
elec.meta.int = int;
elec.meta.Fs = 1/int;
elec.meta.nCh = length(M);
elec.meta.N = N;
elec.meta.chNum = arrayfun(@(x) str2double(x.ch),M);
elec.meta.chNumOrig = elec.meta.chNum;
elec.meta.chPrefix = prefix;
elec.meta.sourceFile = smrxFile;

elec.t = (1:N)*int;
elec.data = zeros(N,elec.meta.nCh);
for k = 1:elec.meta.nCh
    elec.data(:,k) = double(C(k).wave(1:N));
end

%%
unloadlibrary ceds64int;