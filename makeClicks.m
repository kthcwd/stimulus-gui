function out = makeClicks(fs,duty,rate,dur,ISI,reps,FILT)

noise = randn(1,fs*duty/rate);
noise = noise - mean(noise);
noise = envelopeKCW(noise,5,fs) .*10 ^ (-(10/20));
% noise = conv(noise,FILT,'same');
noise = [noise zeros(1,round(fs*(1/rate*(1-duty))))];
noise = [repmat(noise,1,dur*rate) zeros(1,ISI*fs)];

ch1 = repmat(noise,1,reps);
ch2 = [ones(1,.005*fs)*.5 zeros(1,(reps*(dur+ISI)-.005)*fs)];

out = [ch1' ch2'];



