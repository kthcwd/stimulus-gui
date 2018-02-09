fs = 192e3;
y = rand(1,fs*60*90);
audiowrite('noise-90min.wav',y,fs);