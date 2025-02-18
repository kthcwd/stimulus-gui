function s = connectToNidaq(fs,channelsIn,channelsOut)
% out speaker = ch 0
% out events = ch 1
% frame events IN = ch 1
% stimulus events IN = ch 8

% channelsIn = [0 8];
% channelsOut = [0 1 2];
% fs = 400000;

% delete(instrfindall)
% daqreset
% disp('Initialising NIDAQ card')
d = daqlist("ni"); % list nidaq devices
deviceInfo = d{1, "DeviceInfo"};
s = daq('ni');
s.Rate = fs;

for ii = 1:length(channelsOut)
    addoutput(s, deviceInfo.ID, channelsOut(ii), "Voltage") % sound output
end
for ii = 1:length(channelsIn)
    if ischar(channelsIn{ii})
        dot = strfind(channelsIn{ii},'.');
        port = strcat('port',channelsIn{ii}(1:dot-1));
        line = strcat('line',channelsIn{ii}(dot+1:end));
        addinput(s, deviceInfo.ID, strcat(port, '/', line),'Digital')
    else
        addinput(s, deviceInfo.ID, channelsIn{ii}, "Voltage"); % frame events input
        s.Channels(ii).TerminalConfig = 'SingleEnded';
    end
end
% s.ExternalTriggerTimeout = 15;
% s.NotifyWhenScansQueuedBelow = fs*.8; % samples remaining in buffer to
%trigger the next addition to the buffer
fs_check = s.Rate; % check sample rate
if fs ~= fs_check
    disp('Sample rate not available!!!!')
    keyboard
    return
end

% disp('Connected to NIDAQ');
