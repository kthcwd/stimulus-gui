files = dir('D:\stimuli\_chris\contrastGain\*contrastGain*.wav');

fs = 400000;
pulse = fs * .005;
event = [ones(pulse,1)*.5; zeros((3*fs)-pulse,1)];

for i = 1:length(files)
    disp(i);
    fn = [files(i).folder filesep files(i).name];
    [y,fs] = audioread(fn);
    y = [y repmat(event,100,1)];
    audiowrite(fn,y,fs);
end