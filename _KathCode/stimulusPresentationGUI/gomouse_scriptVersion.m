%% GO MOUSE SCRIPT VERSION
clear
delete(instrfindall)
% EXPT info
global nc 
nc.mouse            = 'test';
nc.investigator     = 'Kath';
nc.project          = '2P_FRA';
nc.stimuli          = '20171122_pureTones_100ms_5k-32k_70dB_462.wav';
nc.yaw             	= 5;
nc.pitch            = 55;
nc.fs               = 400000;

% Presentation info
frameRate           = 29.874;
opticalZoom         = 1.5;
preStimSil          = 1;
nc.nidaq.input      = [1,8];
nc.nidaq.output     = [0,1];

% 

cd('E:\GitHub\Kath\2P_stim_PC\stimulusPresentationGUI\')

nc.blockN = 1;
nc.stimFolder = 'E:\stimuli\';
nc.saveFolder = ['C:\data\' nc.mouse filesep];

% connect to nidaq
nc.s = connectToNidaq(nc.fs,nc.nidaq.input,nc.nidaq.output);
nc.lh = addlistener(nc.s,'DataRequired',@(src,event)presentStimContNidaq_script(src,event));
nc.la = addlistener(nc.s,'DataAvailable',@(src,event)acquireContNidaq_script(src,event));
nc.s.IsContinuous = true; % set nidaq to continuous mode

% start counters
nc.counter=1; 
stimFiles = [nc.stimFolder nc.investigator filesep nc.project filesep nc.stimuli];
blocks = 1;
stimInf = audioinfo(stimFiles);
stimDur = stimInf.TotalSamples;
wn = nc.fs-mod(sum(stimDur),nc.fs);
if wn~=nc.fs
    zeroPad = zeros(wn,2);
else
    zeroPad=[];
end

nChunks = (sum(stimDur)+length(zeroPad))/nc.fs;

% Add trigger to start recording
triggerDuration = 0.1*nc.fs; % in samples
triggerAcquisition = [zeros(preStimSil*nc.fs,1),...
    [ones(triggerDuration,1)*5;zeros((preStimSil*nc.fs)...
    -triggerDuration,1)]]; % Initial trigger event to the 2P microscope

if length(nc.nidaq.output)==3
    pulse = [ones(0.001*nc.fs,1)*3;zeros(0.049*nc.fs,1)]; % 20 Hz frame rate
    pdur = round(length(presInfo.triggerAcquisition)/nc.fs);
    triggerAcquisition(:,3) = repmat(pulse,20*pdur,1);
end


stimD = ceil((sum(nChunks)*nc.fs+...
    (preStimSil*nc.fs*blocks)+...
    5*nc.fs*blocks)/nc.fs/60); % total stimulus duration
disp(['Total length: ' num2str(stimD) ' mins'])

% Start the playback/acquisition
nc.firstChunk = 1; % we have to do the first chunk separately to initiate the listener
nc.nBlocks = 1;
nc.nChunks = nChunks;
nc.stimFiles = {stimFiles};
nc.nFiles = length(stimFiles);
nc.stimDur = stimDur;
nc.preStimSil = preStimSil;

% make file for saving inputs
fn = [nc.saveFolder datestr(now,'yymmdd_HHMMSS') '_' nc.mouse '_' nc.project '_block01.txt'];
nc.fid = fopen(fn,'a'); % open file for acquired data
if ~exist(fn,'file')
    disp('File not opened!!!')
    keyboard
end
disp(fn)
queueOutputData(nc.s,triggerAcquisition);
% Initialise the presentation/acquisition (the listeners take over after
% triggerAcquisition has been presented
nc.s.startBackground();


