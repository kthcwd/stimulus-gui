function [chanIn,chanOut] = getNidaqSettings(handles) %#ok<STOUT>

chanIn = {};
chanOut = [];

% check laser box
if handles.bluelaser_button.Value == 1
    % if laser is on
    % set output to 4 channels
    handles.outputN.String = '4';
    % set 3rd nidaq channel for the laser (channel index 2)
    handles.output3.String = '2';
    % set 4th nidaq channel for the laser events (channel index 3)
    handles.output4.String = '3';
end

nIn = str2double(get(handles.inputN,'String'));
for ii = 1:nIn
    it = get(handles.input1,'String');
    if contains(it,'.')
        chanIn{ii} = it; %#ok<*AGROW>
    else
        eval(sprintf('chanIn{%d} = str2double(get(handles.input%d,''String''));',ii,ii))
    end
end

if nIn == 0 
elseif nIn ~= length(chanIn)
    warndlg('Your NIDAQ input channels are not right, check number of channels and channel definitions in the NIDAQ settings panel','You need to fix something')
end

nOut = str2double(get(handles.outputN,'String'));

for ii=1:nOut
    eval(sprintf('chanOut(%d) = str2double(get(handles.output%d,''String''));',ii,ii))
end

if nOut~=sum(~isnan(chanOut))
     warndlg('Your NIDAQ output channels are not right, check number of channels and channel definitions in the NIDAQ settings panel','You need to fix something')
end
