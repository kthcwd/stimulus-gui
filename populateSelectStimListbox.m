function stimuli = populateSelectStimListbox(handles)
global pm
contents = cellstr(get(handles.projectlist,'String'));
projectSel = contents{get(handles.projectlist,'Value')};
handles.projectlist.Value = 1;
pm.wavDir = [pm.stimFolder pm.person '\' projectSel '\'];
% POPULATE SELECT STIMULI LISTBOX
pm.wavFiles = dir([pm.wavDir '*.wav']);
pm.wavFiles = {pm.wavFiles.name};
set(handles.stimlist,'Value',1);
set(handles.stimlist,'String',pm.wavFiles);
set(handles.stimlist,'Max',length(pm.wavFiles),'Min',1);
stimuli = pm.wavFiles;