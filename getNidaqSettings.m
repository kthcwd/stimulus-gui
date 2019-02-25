function [chanIn,chanOut,nIn,nOut] = getNidaqSettings(handles) %#ok<STOUT>

chanIn = [];
chanOut = [];
nIn = [];
nOut = [];

% check laser boxes
if handles.bluelaser_button.Value == 0 && handles.greenlaser_button.Value == 0
    % if neither laser is activated, do nothing
elseif handles.bluelaser_button.Value == 1 && handles.greenlaser_button.Value == 1
    % if they're both on
    warndlg('Can''t use both lasers simultaneously.');
elseif handles.bluelaser_button.Value == 1 && handles.greenlaser_button.Value == 0
    % if blue laser is on
    % set output to 3 channels
    handles.outputN.String = '3';
    % set 3rd nidaq channel for the blue laser (channel 2)
    handles.output3.String = '2';
elseif handles.bluelaser_button.Value == 0 && handles.greenlaser_button.Value == 1
    % if green laser is on
    % set output to 3 channels
    handles.outputN.String = '3';
    % set 34d output channel for blue laser channel (channel 3)
    handles.output3.String = '3';
end

nIn = str2double(get(handles.inputN,'String'));
for ii=1:nIn
    eval(sprintf('chanIn(%d) = str2double(get(handles.input%d,''String''));',ii,ii))
end
if nIn == 0 
elseif nIn~=sum(~isnan(chanIn))
    warndlg('Your NIDAQ input channels are not right, check number of channels and channel definitions in the NIDAQ settings panel','You need to fix something')
end
nOut = str2double(get(handles.outputN,'String'));
for ii=1:nOut
    eval(sprintf('chanOut(%d) = str2double(get(handles.output%d,''String''));',ii,ii))
end
if nOut~=sum(~isnan(chanOut))
     warndlg('Your NIDAQ output channels are not right, check number of channels and channel definitions in the NIDAQ settings panel','You need to fix something')
end
