function presentStimContNidaq_stimGUI(src, event, handles)
%

[~,chanOut] = getNidaqSettings(handles);

global nc pm
if nc.firstChunk==1
    nc.ff=1; nc.jj=1; nc.rm=[]; nc.sv=0;
    nc.firstChunk=0;
end

if nc.counter <= nc.nChunks
    %     sprintf('%d/%d\n',nc.counter,nc.nChunks);
    nfc = floor((nc.stimDur(nc.ff)+nc.sv)/nc.fs);
    str = sprintf('Block %02d/%02d - File %02d/%02d - Chunk %04d/%04d...\n',nc.blockN,nc.nBlocks,nc.ff,nc.nFiles,nc.jj,nfc);
    fprintf(str);
    if isempty(nc.rm)
        stim = audioread(nc.stimFiles{nc.ff},...
            [((nc.jj-1)*nc.fs+1)-nc.sv,nc.jj*nc.fs-nc.sv]); % read in 1 second chunks
        if length(chanOut)==3
            stim(:,3) = audioread('temp_motionCamTrigger.wav',...
                [((nc.jj-1)*nc.fs+1)-nc.sv,nc.jj*nc.fs-nc.sv]); % read in 1 second chunks
        end
        nc.jj=nc.jj+1;
    else
        indexing = [(nc.jj-1)*nc.fs+1,nc.jj*nc.fs-nc.sv];
        stim = audioread(nc.stimFiles{nc.ff},indexing); % read in 1 second chunks
        %% chris note: add in sync signal here
        if length(chanOut)==3
            stim(:,3) = audioread('temp_motionCamTrigger.wav',indexing);
        end
        nc.jj=nc.jj+1;
        nc.rm=[];
    end
    stim=[nc.rm;stim];
    stim = stim*10; % Get back to full level (.wav files are saved as stim/10 so need to *10)
    
    queueOutputData(nc.s,stim);
    nc.counter=nc.counter+1;
    
    if nc.jj>nfc
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
        nc.jj=1;
        if nc.ff>nc.nFiles
            endPadding = zeros(nc.fs*6,2);
            stim=[nc.rm*10;zeros(nc.fs-nc.sv,2);endPadding];
            %% chris note: add in sync signal here????
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
    % wrap up this block
    disp('FINISHED PRESENTING')
    stop(nc.s);
    if isfield(nc,'lh')
        delete(nc.lh);
    elseif isfield(nc,'la')
        delete(nc.la);
    elseif isfield(nc,'s')
        delete(nc.s);
    elseif isfield(nc,'fid')
        fclose(nc.fid);
    end
    fclose('all');
    
    % save everything
    exptInfo.mouse = nc.mouse;
    exptInfo.stimFiles = nc.stimFiles;
    %     b = unique(exptInfo.stimFiles);
    %     for ii=1:length(b)
    %         a = load([nc.stimFolder '*stimInfo.mat']);
    %         exptInfo.stimInfo{ii} = a;%.stimInfo;
    %     end
    exptInfo.preStimSilence = nc.preStimSil;
    exptInfo.fsStim = nc.fs;
    exptInfo.presParams = nc;
    exptInfo.presDirs = pm;
    fn = fullfile(saveFolder,[datestr(now,'YYmmdd_HHMMSS') '_exptInfo.mat']);
    save(fn,'exptInfo');
    set(handles.text35,'String',['Block ' num2str(nc.blockN) ' of ' num2str(nc.nBlocks) ' saved'])
    
    %% NOW ADD IN A NEW FUNCTION, 'PLAYNEXTBLOCK'
    if nc.blockN<=nc.nBlocks
        disp('Press enter to start the next block...');
        pause();
        nc.blockN = nc.blockN+1;
        playNextBlock(handles);
    end
    
end



