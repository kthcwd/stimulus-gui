function continuousGenPlay(src,event,genFcn)

sound = eval(genFcn);
src.queueOutputData(sound);