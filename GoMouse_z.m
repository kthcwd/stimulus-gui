function varargout = GoMouse_z(varargin)
% GOMOUSE_Z MATLAB code for GoMouse_z.fig
%      GOMOUSE_Z, by itself, creates a new GOMOUSE_Z or ra-`    ises the existing
%      singleton*.
%
%      H = GOMOUSE_Z returns the handle to a new GOMOUSE_Z or the handle to
%      the existing singleton*.
%
%      GOMOUSE_Z('CALLBACK',hObjec  t,eventData,handles,...) calls the local
%      function named CALLBACK in GOMOUSE_Z.M with the given input arguments.
%
%      GOMOUSE_Z('Property','Value',...) creates a new GOMOUSE_Z or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GoMouse_z_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GoMouse_z_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GoMouse_z

% Last Modified by GUIDE v2.5 13-Dec-2019 12:32:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GoMouse_z_OpeningFcn, ...
    'gui_OutputFcn',  @GoMouse_z_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



%% SET VARIABLES
global pm
pm.stimFolder = 'D:\stimuli\';
pm.mouseFolder = 'D:\data\';
pm.filterFolder = 'D:\GitHub\filters\';


% --- Executes just before GoMouse_z is made visible.
function GoMouse_z_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GoMouse_z (see VARARGIN)

% Choose default command line output for GoMouse_z
handles.output = hObject;

% Update handles structure
global pm
guidata(hObject, handles);
set(hObject,'Name','GoMouse!')
pm.wavFolders = [];
set(handles.blocktable,'Data',[])

% UIWAIT makes GoMouse_z wait for user response (see UIRESUME)
% uiwait(handles.figure1);




% --- Outputs from this function are returned to the command line.
function varargout = GoMouse_z_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;






%% SELECT YOUR BEAST
function mouselist_Callback(hObject, eventdata, handles) %#ok<*INUSD>
global pm
contents = cellstr(get(hObject,'String'));
pm.mouse = contents{get(hObject,'Value')};
handles.status.String = sprintf('Mouse selected: %s',pm.mouse);
pm.saveFolder = [pm.mouseFolder pm.mouse '\'];


% POPULATE SELECT YOUR BEAST
function mouselist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Populate the listbox
global pm
f = dir(pm.mouseFolder);
f(strcmp({f.name},'.'))=[]; f(strcmp({f.name},'..'))=[]; f(strcmp({f.name},'zippedEventTraces'))=[];
f = {f.name};
set(hObject,'string',f);
set(hObject,'Value',length(f));
contents = cellstr(get(hObject,'String'));
pm.mouse = contents{get(hObject,'Value')};




%% SELECT FOLDER
function folderlist_Callback(hObject, eventdata, handles)
global pm
contents = cellstr(get(hObject,'String'));
pm.person = contents{get(hObject,'Value')};

% Populate the PROJECT listbox
populateProjectFolderListbox(handles)




% POPULATE SELECT FOLDER
function folderlist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Populate the listbox
global pm
f = dir(pm.stimFolder);
f(strcmp({f.name},'.'))=[]; f(strcmp({f.name},'..'))=[];
f = {f.name};
set(hObject,'string',f);
hObject.Value = 1;
contents = cellstr(get(hObject,'String'));
pm.person = contents{get(hObject,'Value')};




%% SELECT PROJECT FOLDER
function projectlist_Callback(hObject, eventdata, handles)
populateSelectStimListbox(handles);


% POPULATE PROJECT FOLDER
function projectlist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% SELECT STIMULI LISTBOX
function stimlist_Callback(hObject, eventdata, handles)

% POPULATE SELECT STIMULI
function stimlist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% EDIT BLOCKS NUMBERS
function blocktable_ButtonDownFcn(hObject, eventdata, handles)
wavs = cellstr(get(handles.stimselectlist,'String'));
d = get(handles.blocktable,'Data');
editBlockNumbers(wavs,d,handles);


%% ADD PUSH BUTTON
function addstim_Callback(hObject, eventdata, handles)
global pm
contents = cellstr(get(handles.stimselectlist,'String'));
wavSel = get(handles.stimlist,'Value');
wavsToAdd = cellstr(get(handles.stimlist,'String'));
wavsToAdd = wavsToAdd(wavSel);
if strcmp(contents,'Listbox')
    contents=wavsToAdd;
else
    contents(length(contents)+1:length(contents)+length(wavsToAdd)) = wavsToAdd;
end
%  pm.wavsToPresent
set(handles.stimselectlist,'String',contents)
set(handles.stimselectlist,'Max',length(contents),'Min',1);
for ii=1:length(wavsToAdd)
    pm.wavFolders{length(pm.wavFolders)+1,1} = pm.wavDir;
end
% edit block numbers
d = get(handles.blocktable,'Data');
a = get(handles.stimselectlist,'Value');
if ~iscell(d)
    d=num2cell(d);
end
if ~isempty(d)
    nd = cat(1,d,cat(2,repmat(d(a,1),length(wavsToAdd),1),num2cell(ones(length(wavsToAdd),1))));
else
    nd = ones(length(wavsToAdd),2);
end
set(handles.blocktable,'Data',nd)



%% REMOVE PUSH BUTTON
function removestim_Callback(hObject, eventdata, handles)
global pm
contents = cellstr(get(handles.stimselectlist,'String'));
if length(contents)==1
    contents{1} = 'Listbox';
else
    rm = get(handles.stimselectlist,'Value');
    if rm(1)-1<1
        set(handles.stimselectlist,'Value',1);
    else
        set(handles.stimselectlist,'Value',rm(1)-1);
    end
    contents(rm)=[];
    if isempty(contents)
        contents{1} = 'Listbox';
    end
end
pm.wavFolders(rm)=[];
set(handles.stimselectlist,'String',contents) 
set(handles.stimselectlist,'Max',length(contents),'Min',1);

d = get(handles.blocktable,'Data');
if ~isempty(d)
    d(rm,:)=[]; nd=d;
end
set(handles.blocktable,'Data',nd)




%% CLEAR ALL PUSH BUTTON
function clearstim_Callback(hObject, eventdata, handles)
global pm
set(handles.stimselectlist,'Value',1)
set(handles.stimselectlist,'String','Listbox')
pm.wavFolders=[];
set(handles.blocktable,'Data',[]);



%% STIMULI SELECTED LISTBOX
function stimselectlist_Callback(hObject, eventdata, handles)
% POPULATE STIMULI SELECTED
function stimselectlist_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% MOVE UP PUSH BUTTON
function movestimup_Callback(hObject, eventdata, handles)
global pm
contents = cellstr(get(handles.stimselectlist,'String'));
mu = get(handles.stimselectlist,'Value');
d = get(handles.blocktable,'Data');
if mu~=1
    newContents = [contents(1:mu(1)-2);contents(mu);contents(mu(1)-1);contents(mu(end)+1:end)];
    pm.wavFolders = cat(1,pm.wavFolders(1:mu(1)-2),pm.wavFolders(mu),pm.wavFolders(mu(1)-1),pm.wavFolders(mu(end)+1:end));
    d = cat(1,d(1:mu(1)-2,:),d(mu,:),d(mu(1)-1,:),d(mu(end)+1:end,:));
    set(handles.stimselectlist,'String',newContents)
    set(handles.stimselectlist,'Value',mu-1)
    set(handles.blocktable,'Data',d)
end



%% MOVE DOWN PUSH BUTTON
function movestimdown_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
global pm
contents = cellstr(get(handles.stimselectlist,'String'));
mu = get(handles.stimselectlist,'Value');
d = get(handles.blocktable,'Data');
if mu~=length(contents)
    newContents = [contents(1:mu(1)-1);contents(mu(end)+1);contents(mu);contents(mu(end)+2:end)];
    pm.wavFolders = cat(1,pm.wavFolders(1:mu(1)-1),pm.wavFolders(mu(end)+1),pm.wavFolders(mu),pm.wavFolders(mu(end)+2:end));
    d = cat(1,d(1:mu(1)-1,:),d(mu(end)+1,:),d(mu,:),d(mu(end)+2:end,:));
    set(handles.stimselectlist,'String',newContents)
    set(handles.stimselectlist,'Value',mu+1)
    set(handles.blocktable,'Data',d)
end


%% RANDOMISE STIMULI ORDER
function randstim_Callback(hObject, eventdata, handles)
global pm
contents = cellstr(get(handles.stimselectlist,'String'));
d = get(handles.blocktable,'Data');
r = randperm(length(contents));
contents = contents(r);
pm.wavFolders = pm.wavFolders(r);
set(handles.stimselectlist,'String',contents)
set(handles.blocktable,'Data',d(r,:));







%% NOISE CLICKS TOGGLE BUTTON
function noiseclicks_Callback(hObject, eventdata, handles)
global nc
% clear -global nc
state = logical(get(hObject,'Value'));
if state
    % noise click stats
    dur = .5; % time in secs of click train
    duty = .25; % percentage of time the click will be on during rate cycle
    rate = 10; % number of times a click will play per second
    ISI = .5; % time in secs between click trains
    reps = 2; % number of click trains per event
    fs = str2double(get(handles.samplerate,'String'));
    filtName = get(handles.filterfile,'String');
    load(filtName);
    noise = makeClicks(fs,duty,rate,dur,ISI,reps,FILT); % duration, ISI and sample rate
    set(handles.status,'String','Connecting to NIDAQ card');
    nc.s = connectToNidaq(fs,[],[0,1]);
    set(handles.status,'String','NIDAQ connected');
    nc.lh = addlistener(nc.s,'DataRequired',@(src,event)nc.s.queueOutputData(10*noise));
    nc.s.IsContinuous = true;
    nc.s.queueOutputData(noise);
    nc.s.startBackground();
    set(handles.status,'String','Presenting noise clicks');
    disp('Presenting noise clicks')
else
    stop(nc.s);
    delete(nc.lh);
    nc.s.IsContinuous = false;
    clear -global nc
    set(handles.status,'String','Stopped noise clicks, now nothing happening');
    disp('Stopped noise clicks')
end











%% BASELINE DURATION
function baselinetime_Callback(hObject, eventdata, handles)
%
function baselinetime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% RESET NIDAQ
function reset_Callback(hObject, eventdata, handles)
daqreset
delete(instrfindall)



%% PRESENT SOUND ONLY
function startbutton_Callback(hObject, eventdata, handles)
clear -global nc
global nc pm
nc.blockN = 1;
nc.mouse = pm.mouse;
nc.stimFolder = pm.stimFolder;
playNextBlock(handles)



%% SAMPLE RATE
function samplerate_Callback(hObject, eventdata, handles)

function samplerate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% FILTER SELECTION
function filterfile_Callback(hObject, eventdata, handles)

function filterfile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global pm
set(hObject,'String',[pm.filterFolder '180516_blueAcuteSpeaker_NIDAQ_3k-80k_fs200k.mat'])
pm.filter = get(hObject,'value');

function filterfile_ButtonDownFcn(hObject, eventdata, handles)
global pm
[FileName,PathName] = uigetfile([pm.filterFolder '*.mat'],'Select filter');
if FileName~=0
    set(handles.filterfile,'String',[PathName,FileName]);
end
pm.filter = get(hObject,'value');



%% NIDAQ SETTINGS
function inputN_Callback(hObject, eventdata, handles) % NUMBER OF INPUT CHANNELS
% Hints: get(hObject,'String') returns contents of inputN as text
%        str2double(get(hObject,'String')) returns contents of inputN as a double
function inputN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function outputN_Callback(hObject, eventdata, handles) % NUMBER OF OUTPUT CHANNELS
function outputN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function input1_Callback(hObject, eventdata, handles) % 1ST INPUT CHANNEL
function input1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function output1_Callback(hObject, eventdata, handles)% 1ST OUTPUT CHANNEL
function output1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function input2_Callback(hObject, eventdata, handles) % 2ND INPUT CHANNEL
function input2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function output2_Callback(hObject, eventdata, handles) % 2ND OUTPUT CHANNEL
function output2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function input3_Callback(hObject, eventdata, handles)% 3RD INPUT CHANNEL
function input3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function output3_Callback(hObject, eventdata, handles)% 3RD OUTPUT CHANNEL
function output3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% QUIT BUTTON
function quitbutton_Callback(hObject, eventdata, handles)
fclose('all');
clear
clear global
close all


%% SAVE CONFIG
function saveconfig_Callback(hObject, eventdata, handles)
global pm
c = cellstr(get(handles.mouselist,'String'));
GUIdata.mouse = c{get(handles.mouselist,'Value')}; % mouse
c = cellstr(get(handles.folderlist,'String'));
GUIdata.person = c{get(handles.folderlist,'Value')}; % person folder
c = cellstr(get(handles.projectlist,'String'));
GUIdata.project = c{get(handles.projectlist,'Value')}; % project folder
c = cellstr(get(handles.stimselectlist,'String'));
GUIdata.stimuli = c;
GUIdata.stimuliFolders = pm.wavFolders; % stimuli full filename
%GUIdata.yaw = get(handles.edit2,'String'); % yaw
%GUIdata.pitch = get(handles.edit1,'String'); % pitch
GUIdata.blockReps = get(handles.blocktable,'Data'); % blocks and repeats
[chanIn,chanOut,nIn,nOut] = getNidaqSettings(handles);
GUIdata.nidaqInfo = {chanIn,chanOut,nIn,nOut};
%GUIdata.recType(1) = get(handles.checkbox1,'Value'); % widefield
%GUIdata.recType(2) = get(handles.checkbox2,'Value'); % 2P
%GUIdata.recType(3) = get(handles.checkbox3,'Value'); % electrophys
GUIdata.baselineDur = get(handles.baselinetime,'String');
%GUIdata.opticalZoom = get(handles.text34,'String');
GUIdata.fs = get(handles.samplerate,'String');
[filename,pathname] = uiputfile([pm.stimFolder GUIdata.person '\' GUIdata.project '\*.mat'],'save configuration');
if ~isempty(pathname)
    save([pathname filename],'GUIdata');
    set(handles.status,'String','Configuration saved');
end





%% LOAD CONFIG
function loadconfig_Callback(hObject, eventdata, handles)
global pm
[filename,pathname]=uigetfile(pm.stimFolder);
load([pathname filename]);
c = cellstr(get(handles.mouselist,'String'));
set(handles.mouselist,'Value',find(strcmp(c,GUIdata.mouse))); % mouse
pm.mouse = GUIdata.mouse;
pm.saveFolder = [pm.mouseFolder pm.mouse '\'];
c = cellstr(get(handles.folderlist,'String'));
set(handles.folderlist,'Value',find(strcmp(c,GUIdata.person))); % person folder
projects = populateProjectFolderListbox(handles);
set(handles.projectlist,'Value',find(strcmp(projects,GUIdata.project))); % project folder
populateSelectStimListbox(handles);
pm.wavFolders = GUIdata.stimuliFolders; % stimuli full filename
set(handles.stimselectlist,'String',GUIdata.stimuli);
set(handles.blocktable,'Data',GUIdata.blockReps); % blocks and repeats
set(handles.inputN,'String',GUIdata.nidaqInfo{3}); % set n channels in
chIn = [13,15,17];
for ii=1:GUIdata.nidaqInfo{3}
    eval(sprintf('set(handles.edit%d,''String'',%d);',chIn(ii),GUIdata.nidaqInfo{1}(ii)))
end
set(handles.outputN,'String',GUIdata.nidaqInfo{4}); % set n channels out
chOut = [14,16,18];
for ii=1:GUIdata.nidaqInfo{4}
    eval(sprintf('set(handles.edit%d,''String'',%d);',chOut(ii),GUIdata.nidaqInfo{2}(ii)))
end


set(handles.baselinetime,'String',GUIdata.baselineDur);
set(handles.samplerate,'String',GUIdata.fs);


%% ABORT BUTTON
function abortbutton_Callback(hObject, eventdata, handles)
global nc pm
% keyboard
if ~isempty(nc)
    if isfield(nc,'s')
        
        stop(nc.s);
        
        % flush current state of card
        nChans = max(size(nc.s.Channels));
        clearStim = zeros(nc.fs*1,nChans);
        queueOutputData(nc.s,clearStim);
        nc.s.startBackground();
        stop(nc.s);
        
        % clear listeners
        if isfield(nc,'lh')
            delete(nc.lh);
        end
        if isfield(nc,'la')
            delete(nc.la);
        end
        
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
        exptInfo.status = 'ABORTED'; %#ok<STRNU>
        fn = fullfile(pm.saveFolder,[datestr(now,'YYmmdd_HHMMSS') '_exptInfo.mat']);
        save(fn,'exptInfo');
        set(handles.status,'String',['Block ' num2str(nc.blockN) ' of ' num2str(nc.nBlocks) ' saved'])
        
        clear -global nc
        fclose('all');
        set(handles.status,'String','Presentation aborted, nothing happening now');
    else
        set(handles.status,'String','NIDAQ card not initialized, can''t abort!');
    end
end



% --- Executes on button press in bluelaser_button.
function bluelaser_button_Callback(hObject, eventdata, handles)
% hObject    handle to bluelaser_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pm exptInfo

% Hint: get(hObject,'Value') returns toggle state of bluelaser_button
pm.laser = 'blue';
exptInfo.laser = 'blue';
% if this is selected, turn off green
handles.greenlaser_button.Value = 0;
handles.status.String = 'Laser output ON.';
getNidaqSettings(handles);



function input4_Callback(hObject, eventdata, handles)
% hObject    handle to input4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input4 as text
%        str2double(get(hObject,'String')) returns contents of input4 as a double


% --- Executes during object creation, after setting all properties.
function input4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function output4_Callback(hObject, eventdata, handles)
% hObject    handle to output4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of output4 as text
%        str2double(get(hObject,'String')) returns contents of output4 as a double


% --- Executes during object creation, after setting all properties.
function output4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
