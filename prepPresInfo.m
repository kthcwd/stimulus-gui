function [presInfo] = prepPresInfo(handles)
global pm nc

%% to do list
% 1. log file -- each time something is played, get a timestamp
% (approximate) and save some information about what was played when, and
% the order, if it was aborted, etc.
% 2. stimInfo -- check stimfiles BEFORE presentation to get information
% about the stimulus (should we save them with a different extension to
% make it easier to find??)
% 3. sync pulses -- Maria would like us to have event pulses every second,
% add this in as a third channel which will be the default for each
% recording (need to swap out NIDAQ cards in this case... need another
% output channel)

% Get info to save to recording file
fs = str2double(get(handles.samplerate,'String'));
presInfo.fs = fs;
presInfo.FILT = get(handles.filterfile,'String');
presInfo.mouse = pm.mouse;


% Prepare info for presenting the stimuli
contents = cellstr(get(handles.stimselectlist,'String'));
sf = strcat(pm.wavFolders,contents);
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
    presInfo.preStimSil = str2double(get(handles.baselinetime,'String'));
    presInfo.stimFiles = stimFiles;
    
    % Work out how long your recording will be - so we know how many frames to
    % acquire
    stimDur = cell(1,presInfo.nBlocks);
    for bb=1:presInfo.nBlocks
        ind = find(b==bb);
        for ff = 1:length(ind)
            stimInf = audioinfo(stimFiles{ind(ff)});
            set(handles.samplerate,'String',num2str(stimInf.SampleRate))
            fs = str2double(get(handles.samplerate,'String'));
            presInfo.fs = fs;
            if stimInf.SampleRate~=fs
                disp('STIM AT WRONG SAMPLE RATE!!')
                keyboard
            end
            stimDur{bb}(ff) = stimInf.TotalSamples;
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
    if presInfo.preStimSil > 0
        nChannels = length(chanOut);
        triggerDuration = 0.1*fs; % in samples
        presInfo.triggerAcquisition = [[ones(triggerDuration,1)*5;...
            zeros((presInfo.preStimSil*fs)-triggerDuration,1)],...
            zeros(presInfo.preStimSil*fs,nChannels-1)]; % Initial trigger event to the 2P microscope
    else
        presInfo.triggerAcquisition = [];
    end
    
%     if length(chanOut)>=3
% %         pulse = [zeros(0.001*fs,1)*3;zeros(0.049*fs,1)]; % 20 Hz frame rate
% %         dur = round(length(presInfo.triggerAcquisition)/fs);
%         presInfo.triggerAcquisition(:,3:4) = zeros(length(presInfo.triggerAcquisition),2);
%     end
        
    
    presInfo.stimD = ceil((sum(presInfo.nChunks)*fs+...
        (presInfo.preStimSil*fs*presInfo.nBlocks)+...
        5*fs*presInfo.nBlocks)/fs); % total stimulus duration
end