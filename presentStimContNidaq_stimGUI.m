function presentStimContNidaq_stimGUI(src, event, handles)
%

[~,chanOut] = getNidaqSettings(handles);

global nc pm

if nc.firstChunk == 1
    nc.ff = 1; nc.jj = 1; nc.rm = []; nc.sv = 0;
    nc.firstChunk = 0;
end

if nc.counter <= nc.nChunks
    %     sprintf('%d/%d\n',nc.counter,nc.nChunks);
    nfc = floor((nc.stimDur(nc.ff)+nc.sv)/nc.fs);
    str = sprintf('Block %02d/%02d - File %02d/%02d - Chunk %04d/%04d...\n',nc.blockN,nc.nBlocks,nc.ff,nc.nFiles,nc.jj,nfc);
    fprintf(str);
    if isempty(nc.rm)
        stim = audioread(nc.stimFiles{nc.ff},...
            [((nc.jj-1)*nc.fs+1)-nc.sv,nc.jj*nc.fs-nc.sv]); % read in 1 second chunks
        if length(chanOut)>2
            % check for laser stim
            if size(stim,2) < 3
                % if no laser stim, just add zeros
                handles.status.String = 'No laser stimuli found!\nLaser will not activate!';
                stim(:,3:length(chanOut)) = zeros(length(chanOut)-2,nc.fs-nc.sv);
            elseif size(stim,2) == 3
                % if there is laser stim, add laser events to channel 4
                stim(:,4) = (stim(:,3) > 0) * .5;               
            end
        end
        nc.jj = nc.jj+1;
    else
        indexing = [(nc.jj-1)*nc.fs+1,nc.jj*nc.fs-nc.sv];
        stim = audioread(nc.stimFiles{nc.ff},indexing); % read in 1 second chunks
        %% chris note: add in sync signal here
        if length(chanOut)>2
            % check for laser stim
            if size(stim,2) < 3
                % if no laser stim, just add zeros
                handles.status.String = 'No laser stimuli found!\nLaser will not activate!';
                stim(:,3:length(chanOut)) = zeros(length(chanOut)-2,nc.fs-nc.sv);
            elseif size(stim,2) == 3
                % if there is laser stim, add laser events to channel 4
                stim(:,4) = (stim(:,3) > 0) * .5;
            end
        end
        nc.jj = nc.jj+1;
        nc.rm = [];
    end
    stim = [nc.rm;stim];
    stim = stim*10; % Get back to full level (.wav files are saved as stim/10 so need to *10)
    
    % queueOutputData(nc.s,stim);
    write(nc.s,stim);
    nc.counter=nc.counter+1;
    
    if nc.jj>nfc
        x=mod((nc.stimDur(nc.ff)+nc.sv),nc.fs);
        if x~=0
            rm2 = audioread(nc.stimFiles{nc.ff},...
                [nc.stimDur(nc.ff)-x+1,nc.stimDur(nc.ff)]);
            if length(chanOut)>2
                % check for laser stim
                if size(rm2,2) < 3
                    % if no laser stim, just add zeros
                    handles.status.String = 'No laser stimuli found!\nLaser will not activate!';
                    rm2(:,3:length(chanOut)) = zeros(length(chanOut)-2,nc.fs-nc.sv);
                elseif size(rm2,2) == 3
                    % if there is laser stim, add laser events to channel 4
                    rm2(:,4) = (rm2(:,3) > 0) * .5;
                end
            end
        else
            rm2=[];
        end
        nc.rm=rm2;
        
        % padd rm
        
        nc.sv = length(nc.rm);
        nc.ff = nc.ff+1;
        nc.jj = 1;
        if nc.ff > nc.nFiles
            endPadding = zeros(nc.fs*6,length(chanOut));
            stim=[nc.rm*10;zeros(nc.fs-nc.sv,length(chanOut));endPadding];
            %% chris note: add in sync signal here????
            if length(chanOut)>2 % add in the motion cammera
                % check for laser stim
                
                if size(stim,2) < 3
                    % if no laser stim, just add zeros
                    handles.status.String = 'No laser stimuli found!\nLaser will not activate!';
                    stim(:,3:length(chanOut)) = zeros(length(chanOut)-2,nc.fs-nc.sv);
                elseif size(rm2,2) == 3
                    % if there is laser stim, add laser events to channel 4
                    stim(:,4) = (stim(:,3) > 0) * .5;
                end
            end
            % queueOutputData(nc.s,stim);
            write(nc.s,stim)
            nc.counter = nc.counter+1;
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
    b = unique(exptInfo.stimFiles);
    for ii=1:length(b)
        try
            a = load([b{ii}(1:end-4) '_stimInfo.mat']);
            exptInfo.stimInfo{ii} = a;%.stimInfo;
        catch
            exptInfo.stimInfo{ii} = 'Could not find stimInfo';
        end
    end
    exptInfo.preStimSilence = nc.preStimSil;
    exptInfo.fsStim = nc.fs;
    exptInfo.presParams = nc;
    exptInfo.presDirs = pm;
    if isfield(pm,'saveFolder')
        fn = fullfile(pm.saveFolder,[datestr(now,'YYmmdd_HHMMSS') '_exptInfo.mat']);
        save(fn,'exptInfo');
    else
        warning('WARNING: no save folder specified, saving in default location: _M001\n');
        fn = fullfile('D:\data\_M001',[datestr(now,'YYmmdd_HHMMSS') '_exptInfo.mat']);
    end
    set(handles.status,'String',['Block ' num2str(nc.blockN) ' of ' num2str(nc.nBlocks) ' saved'])
    nc.blockN = nc.blockN+1;
    %% NOW ADD IN A NEW FUNCTION, 'PLAYNEXTBLOCK'
    if nc.blockN<=nc.nBlocks
        disp('Press enter to start the next block...');
        pause();
        %         nc.blockN = nc.blockN+1;
        playNextBlock(handles);
    end
    
end



