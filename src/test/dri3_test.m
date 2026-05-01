pkg load signal
[N0,D0]=butter(6,0.1);
[H,w]=freqz(N0,D0,100);
subplot(211)
plot(w*0.5/pi,abs(H))
title("dri3\\_test");
subplot(212)
plot(w*0.5/pi,unwrap(arg(H))/pi)
print("dri3_test","-dpdflatex");
close
