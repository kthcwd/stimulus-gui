function [presInfo] = prepPresInfo(handles)
global pm nc

read_dur = nc.read_dur;

% Get info to save to recording file
fs = str2double(get(handles.samplerate,'String'));
presInfo.fs = fs;
presInfo.FILT = get(handles.filterfile,'String');
presInfo.mouse = pm.mouse;


%% Prepare info for presenting the stimuli

% get names of stim files from GUI
contents = cellstr(get(handles.stimselectlist,'String'));
sf = strcat(pm.wavFolders,contents); 

% get info from GUI about which block stimuli are in and number of repeats
d = get(handles.blocktable,'Data');
if ~iscell(d)
    d = num2cell(d); % blocks and repeats
end
if ~isempty(d)
    blocks = [d{:,1}];
    reps = [d{:,2}];
    stimFiles = cell(sum(reps),1); 
    b = zeros(sum(reps),1);
    ind = 1;
    if any(reps>1)
        for ii=1:length(reps)
            for jj=1:reps(ii)
                stimFiles(ind,1) = sf(ii);
                b(ind,1) = blocks(ii);
                ind = ind+1;
            end
        end
    else
        stimFiles = sf;
        b = blocks;
    end
    
    % sort by block
    [b,blockOrder] = sort(b);
    stimFiles = stimFiles(blockOrder);
    presInfo.blocks = b;
    presInfo.nBlocks = length(unique(b));
    presInfo.preStimSilence = str2double(get(handles.baselinetime,'String'));
    presInfo.stimFiles = stimFiles;
    
    % Work out how long your recording will be - so we know how many frames to
    % acquire - this was for the 2P but is still useful to know
    stimDur = cell(1,presInfo.nBlocks);
    for bb = 1:presInfo.nBlocks
        ind = find(b==bb);
        for ff = 1:length(ind)
            stimInfo = audioinfo(stimFiles{ind(ff)});
            set(handles.samplerate,'String',num2str(stimInfo.SampleRate))
            fs = str2double(get(handles.samplerate,'String'));
            presInfo.fs = fs;
            if stimInfo.SampleRate~=fs
                disp('STIM AT WRONG SAMPLE RATE!!')
                keyboard
            end
            stimDur{bb}(ff) = stimInfo.TotalSamples;
        end
        
        
        %  pad with zeros at the end if not a whole number of seconds for each block
        % (easier if whole number)
        wn = fs-mod(sum(stimDur{bb}),fs);
        if wn~=fs
            zeroPad = zeros(wn,2);
        else
            zeroPad=[];
        end
        
        presInfo.nChunks(bb) = (sum(stimDur{bb})+length(zeroPad))/fs;
        
    end
    
    presInfo.stimDur = stimDur;
    
    [~,chanOut] = getNidaqSettings(handles);
    
    % Add trigger to start recording
    if presInfo.preStimSilence > 0
        nChannels = length(chanOut);
        triggerDuration = 0.1*fs; % in samples
        presInfo.triggerAcquisition = [zeros(presInfo.preStimSilence*fs,nChannels-1),...
            [ones(triggerDuration,1)*5;...
            zeros((presInfo.preStimSilence*fs)-triggerDuration,1)]]; % Initial trigger event to the 2P microscope
    else
        presInfo.triggerAcquisition = [];
    end      
    
    presInfo.stimD = ceil((sum(presInfo.nChunks)*fs+...
        (presInfo.preStimSilence*fs*presInfo.nBlocks)+...
        5*fs*presInfo.nBlocks)/fs); % total stimulus duration
end