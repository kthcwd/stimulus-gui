fs = 200e3;

d = 10;
stim = (rand(1,fs*d)/100);
stim = stim-mean(stim);
idx = [zeros(1,fs) ones(1,fs)];
idx = logical(repmat(idx,1,d/2));
stim(idx) = stim(idx) * .5;
events = zeros(1,fs);
events(1:.01*fs) = .5;
events = repmat(events,1,10);
laser = zeros(1,fs);
laser(1:.05*fs) = .5;
laser = repmat(laser,1,10);

sound(1,:) = stim;
sound(2,:) = events;
sound(3,:) = laser;
plot(sound')

audiowrite('laser_test.wav',sound',fs)
