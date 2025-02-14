function playNextBlock(handles)

global nc pm %#ok<NUSED>

% nc.playbackOnly = 0;
% Connect to the NIDAQ
[chanIn,chanOut] = getNidaqSettings(handles);
nc.fs = str2double(get(handles.samplerate,'String'));
set(handles.status,'String',sprintf('Connecting to NIDAQ card...\nOutput Channels: %s',chanOut));
nc.s = connectToNidaq(nc.fs,chanIn,chanOut);
set(handles.status,'String','NIDAQ connected');

% Add the listeners for continuous playback/acquisition
if ~isempty(chanOut)
    nc.lh = addlistener(nc.s,'DataRequired',@(src,event)presentStimContNidaq_stimGUI(src,event,handles));
end
if ~isempty(chanIn)
    nc.la = addlistener(nc.s,'DataAvailable',@(src,event)acquireContNidaq_stimGUI(src,event,handles));
end
nc.s.IsContinuous = true; % set nidaq to continuous mode

% start counters
nc.counter=1; 

% Get info about what to present
presInfo = prepPresInfo(handles);
nc.firstChunk = 1; % we have to do the first chunk separately to initiate the listener
nc.nBlocks = presInfo.nBlocks;
nc.nChunks = presInfo.nChunks(nc.blockN);
nc.stimFiles = presInfo.stimFiles(presInfo.blocks==nc.blockN);
nc.nFiles = length(nc.stimFiles);
nc.stimDur = presInfo.stimDur{nc.blockN};
nc.preStimSil = presInfo.preStimSil;

% create acquisition file
if ~isempty(chanIn)
    contents = cellstr(get(handles.projectlist,'String'));
    projectSel = contents{get(handles.projectlist,'Value')}; %#ok<NASGU>
    eval(sprintf('fn = [pm.saveFolder datestr(now,''yymmdd_HHMMSS'') ''_'' pm.mouse ''_'' projectSel ''_block%02d.txt''];',nc.blockN))
    nc.fid = fopen(fn,'a'); % open file for acquired data
    if ~exist(fn,'file')
        set(handles.text35,'String',['File not opened!!!'])
        keyboard
    end
    set(handles.edit7,'String',fn)
else
    set(handles.edit7,'String','No acquisition initiated.')
end

queueOutputData(nc.s,presInfo.triggerAcquisition);
% Initialise the presentation/acquisition (the listeners take over after
% triggerAcquisition has been presented
nc.s.startBackground();
set(handles.status,'String',sprintf('Presenting block %02d/%02d',nc.blockN,nc.nBlocks));
clear presInfo