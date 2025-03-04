% spectralfactor_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the spectral factor 

test_common;

strf="spectralfactor_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

check_octave_file("spectralfactor");

N=13;
fc=0.05;
dBap=0.0005;
dBas=40;
[n,d]=ellip(N,dBap,dBas,2*fc);
q=spectralfactor(n,d);
[g,w]=freqz(n,d,4096);
[h,w]=freqz(q,d,w);
plot(0.5*w/pi,20*log10(abs(g)),0.5*w/pi,20*log10(abs(h)))
strt=sprintf("Spectral factors of an elliptic filter : N=%d, fc=%4.2g",N,fc);
title(strt);
legend("G","H","location","southeast");
legend("boxoff");
legend("left");
axis([0 0.5 -50 2]);
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
print(strcat(strf,"_ellip13_0_05"),"-dpdflatex");
close
plot(0.5*w/pi,20*log10(abs(g)),"--", ...
     0.5*w/pi,20*log10(abs(h)),"-.", ...
     0.5*w/pi,20*log10(abs(g+h)),"-");
title(strt);
legend("G","H","$|G+H|$")
legend("location","southeast");
legend("boxoff");
legend("left");
axis([0.046 0.054 -3 3]);
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
print(strcat(strf,"_ellip13_0_05_detail"),"-dpdflatex");
close

print_polynomial(q,"q",strcat(strf,"_q_coef.m"));

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
