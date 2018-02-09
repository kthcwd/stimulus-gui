clear all
close all

% specify file name
files = dir('*noise.wav');
fs = 192e3;

% chunk duration (how much data is added at a time)
%chunkDur = 1;

% refresh time (how long until the next chunk is queued to the schedule)
%refTime = .5;

% number of chunks per file
%nChunks = ceil(info.TotalSamples / (chunkDur * fs));

% start psychsound
InitializePsychSound(1);

% % load each file into an audio buffer
% soundBuffer = [];
% for i = 1:length(files)
%     fprintf('Loading sound file %s... ',files(i).name);
%     tic;
%     y = audioread(files(i).name)';
%     toc;
% 
%     fprintf('Adding to buffer...');
%     tic;
%     soundBuffer(end+1) = PsychPortAudio('CreateBuffer',[],y/20);
%     toc;
% end


% get the Lynx soundcard
d = PsychPortAudio('GetDevices');
ind = find(strcmp({d.DeviceName},'ASIO Lynx'));
devID = d(ind).DeviceIndex;

% open the card
s = PsychPortAudio('Open',devID,1,3,fs,1,[],[],0);
status = PsychPortAudio('GetStatus',s);

fprintf('Loading sound file %s... ',files(1).name);
tic; y = audioread(files(1).name)'; toc;
%y = randn(1,fs);
fprintf('Adding to buffer...');
tic; PsychPortAudio('FillBuffer',s,y/500); toc;

% % add to schedule
% PsychPortAudio('UseSchedule',s, 1);
% for i = 1:length(files)
%     PsychPortAudio('AddToSchedule',s, soundBuffer(i), 1);
% end

% start playback
PsychPortAudio('Start', s, 1);

status = PsychPortAudio('GetStatus', s);
while status.Active
    status = PsychPortAudio('GetStatus', s);
    fprintf('%3.2f/%d seconds elapsed\n',status.PositionSecs,length(y)/fs);
    WaitSecs(10);
end
    


