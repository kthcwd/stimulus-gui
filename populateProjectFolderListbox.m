function projects = populateProjectFolderListbox(handles)
global pm
contents = cellstr(get(handles.folderlist,'String'));
pm.person = contents{get(handles.folderlist,'Value')};
% Populate the PROJECT listbox
projects  = dir([pm.stimFolder pm.person '\']);
projects(strcmp({projects.name},'.'))=[]; projects(strcmp({projects.name},'..'))=[];
projects = {projects.name};
set(handles.projectlist,'String',projects);