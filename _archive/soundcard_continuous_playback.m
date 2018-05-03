%% objective: build continuous playback using the soundcard
% play 1s chunks of sound, preallocating 20s? first and adding another
% second after each playback

% make some sounds to put out
fs = 192e3; 
duration = 10.2;
squareWave = repmat([ones(1,fs*.1) zeros(1,fs*.1)],1,round(duration/.1)/2);
a(1,:) = [envelopeKCW(tone(150,0,duration,fs),5,fs)/11 0];
a(2,:) = [envelopeKCW(tone(300,0,duration,fs),5,fs)/11 0];
a(3,:) = squareWave/11;
a(4,:) = squareWave'/11;
audiowrite('a.wav',a',fs);

b(1,:) = [envelopeKCW(tone(300,0,duration,fs),5,fs)/11 0];
b(2,:) = [envelopeKCW(tone(150,0,duration,fs),5,fs)/11 0];
b(3,:) = squareWave'/11;
b(4,:) = squareWave/11;
audiowrite('b.wav',b',fs);

% psychportaudio setup
InitializePsychSound(1);
devName = 'ASIO Lynx';
devices = PsychPortAudio('GetDevices',3);
devID = devices(strcmp({devices.DeviceName},devName)).DeviceIndex;

% chunky stuff
chunkSamps = fs;
fileCnt = 1;
nFiles = length(fileList);

% find samples and chunk counts
fileList = {'a.wav','b.wav'};
for i = 1:length(fileList)
    ai = audioinfo(fileList{i});
    nSamps(i) = ai.TotalSamples;
    nCh(i) = ai.NumChannels;
end
nChunks = floor(nSamps/chunkSamps);
if any(diff(nCh) ~= 0)
    error('All files must have the same number of channels');
    keyboard
end



% add the first 11 chunks to the buffer
buffer = [];
for i = 1:11
    index = [fs*(i-1)+1 (i*fs)];
    stim = audioread(fileList{fileCnt},index);
    
    buffer(end+1) = PsychPortAudio('CreateBuffer',[],stim);
end

% open the sound card and enable scheduling with 10 slots
s = PsychPortAudio('Open',[],1,3,fs,nCh(1));
PsychPortAudio('UseSchedule',s,1,10);

% add the first 10 buffers to the schedule
for i = 1:10
    PsychPortAudio('AddToSchedule',s,buffer(i));
end

% start playback
PsychPortAudio('Start',s,[],0,1);

% loop to check the current progress
chunkCounter = 11;
while 1
    % try to add the next chunk
    [success, freeslots] = PsychPortAudio('AddToSchedule',s,buffer(end));
    
    % if successfully added
    if success
        % get the next chunk into the buffer and add to the schedule
        chunkCounter = chunkCounter + 1;
        index = [fs*(chunkCounter-1)+1 (chunkCounter*fs)];
        stim = audioread(fileList{fileCnt},index);  
        buffer(end+1) = PsychPortAudio('CreateBuffer',[],stim);
        PsychPortAudio('AddToSchedule',s,buffer(chunkCounter))
        
        % remove the first item from the buffer, to keep the size down
        PsychPortAudio('DeleteBuffer',buffer(1));
    end
    
    % wait for a little while before checking, to keep down CPU use
    WaitSecs('YieldSecs', 0.05);
end
        
    
    
    




