clear all
close all

%% params
fs = 192e3;
len = fs*60*60;
y = zeros(2,len);
dEv = 1 * fs;
lEv = .005 * fs;
ev = zeros(1,dEv);
ev(1:lEv) = 1;

%% make sound and events
tic;
y(1,:) = rand(1,len);
y(2,:) = repmat(ev,1,len/dEv);
toc;
fprintf('Writing long noise file... ');
%tic;
%audiowrite('noise-60min.wav',y',fs);
%toc;

% append a wav file
tic;
wavwrite_append(y','noise-60min.wav',[],fs,16);
toc;