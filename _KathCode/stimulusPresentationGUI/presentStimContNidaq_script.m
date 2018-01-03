function presentStimContNidaq_script(src, event)
%
global nc
try
    [~,chanOut] = getNidaqSettings(handles);
catch
    chanOut = nc.nidaq.output;
end

if nc.firstChunk==1
    nc.ff=1; % file counter
    nc.jj=1; % chunk counter (gets reset per file?)
    nc.rm=[]; % chunk of stimulus after mod by chunk size 
    nc.sv=0; % length of mod remainder
    nc.firstChunk=0; % so this if statement only fires once
end

if nc.counter <= nc.nChunks
%     sprintf('%d/%d\n',nc.counter,nc.nChunks);
    nfc = floor((nc.stimDur(nc.ff)+nc.sv)/nc.fs); % number of file chunks
    disp(nc.jj)
    % if no remainder
    if isempty(nc.rm)
        % load chunk
        stim = audioread(nc.stimFiles{nc.ff},...
            [((nc.jj-1)*nc.fs+1)-nc.sv,nc.jj*nc.fs-nc.sv]); % read in 1 second chunks
        % load triggers here
        if length(chanOut)==3
            stim(:,3) = audioread('temp_motionCamTrigger.wav',...
                [((nc.jj-1)*nc.fs+1)-nc.sv,nc.jj*nc.fs-nc.sv]); % read in 1 second chunks
        end
        nc.jj=nc.jj+1;
    else
        % if there is a remainder, load some part of the stimulus before it???
        indexing = [(nc.jj-1)*nc.fs+1,nc.jj*nc.fs-nc.sv];
        stim = audioread(nc.stimFiles{nc.ff},indexing); % read in 1 second chunks
        if length(chanOut)==3
            stim(:,3) = audioread('temp_motionCamTrigger.wav',indexing);
        end
        nc.jj=nc.jj+1;
        nc.rm=[];
    end
    stim=[nc.rm;stim];
    stim = stim*10; % Get back to full level (.wav files are saved as stim/10 so need to *10)
    
    % queue outputs
    queueOutputData(nc.s,stim);
    nc.counter=nc.counter+1; % chunk counter, does not reset for each file?
    
    % once you get to the last chunk
    if nc.jj>nfc
        % check for remainder
        x=mod((nc.stimDur(nc.ff)+nc.sv),nc.fs);
        if x~=0
            rm2 = audioread(nc.stimFiles{nc.ff},...
                [nc.stimDur(nc.ff)-x+1,nc.stimDur(nc.ff)]);
        else
            rm2=[];
        end
        nc.rm=rm2;
        nc.sv = length(nc.rm);
        nc.ff=nc.ff+1;
        % reset jj
        nc.jj=1;
        % on the last file
        if nc.ff>nc.nFiles
            % pad with 6s of silence and some other stuff??
            endPadding = zeros(nc.fs*6,2);
            stim=[nc.rm*10;zeros(nc.fs-nc.sv,2);endPadding];
            if length(chanOut)==3 % add in the motion cammera
                pulse = [ones(0.001*nc.fs,1)*3;zeros(0.049*nc.fs,1)]; % 20 Hz frame rate
                dur = round(length(stim)/nc.fs);
                stim(:,3) = repmat(pulse,20*dur,1);
            end
            queueOutputData(nc.s,stim);
            nc.counter=nc.counter+1;
        end
    end
    
else
    % after the last block, stop the nidaq, close the listeners, etc.
    nc.blockN = nc.blockN+1;
    stop(nc.s);
    delete(nc.lh);
    delete(nc.la);
    fclose(nc.fid);
    fclose('all');
    % save everything
%     set(handles.text35,'String',['Saving block ' num2str(nc.blockN)])
    exptInfo.mouse = nc.mouse;
    exptInfo.stimFiles = nc.stimFiles;
    b = unique(exptInfo.stimFiles);
    for ii=1:length(b)
        a = load([b{ii}(1:end-4) '_stimInfo.mat']);
        exptInfo.stimInfo{ii} = a;%.stimInfo;
    end
    exptInfo.preStimSilence = nc.preStimSil;
    exptInfo.fsStim = nc.fs;
    exptInfo.yaw = nc.yaw;
    exptInfo.pitch = nc.pitch;
%     fn = get(handles.edit7,'String');
%     if nc.playbackOnly==0
%         save([fn(1:end-4) '_exptInfo.mat'],'exptInfo')
%     end
    disp('FINISHED PRESENTING')
%      set(handles.text35,'String',['Block ' num2str(nc.blockN-1) ' of ' num2str(nc.nBlocks) ' saved'])
    
    %% NOW ADD IN A NEW FUNCTION, 'PLAYNEXTBLOCK'
%     if nc.blockN<=nc.nBlocks
%         playNextBlock(handles);
%     end
%     
end



