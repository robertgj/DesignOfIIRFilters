% spectralfactor_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the spectral factor 

test_common;

unlink("spectralfactor_test.diary");
unlink("spectralfactor_test.diary.tmp");
diary spectralfactor_test.diary.tmp

format short e

strf="spectralfactor_test";

fc=0.05;
[n,d]=ellip(13,0.0005,40,2*fc);
q=spectralfactor(n,d);
[g,w]=freqz(n,d,4096);
[h,w]=freqz(q,d,w);
plot(0.5*w/pi,20*log10(abs(g)),0.5*w/pi,20*log10(abs(h)))
legend("G","H","location","southeast");
legend("boxoff");
legend("left");
axis([0 0.5 -50 2]);
grid("on");
xlabel("Normalised Frequency")
ylabel("Amplitude(dB)")
print(strcat(strf,"_ellip13_0_05"),"-dpdflatex");
close
plot(0.5*w/pi,20*log10(abs(g)),"--", ...
     0.5*w/pi,20*log10(abs(h)),"--", ...
     0.5*w/pi,20*log10(abs(g+h)),"-");
legend("G","H","G+H","location","southeast");
legend("boxoff");
legend("left");
axis([0.046 0.054 -3 3]);
grid("on");
xlabel("Normalised Frequency")
ylabel("Amplitude(dB)")
print(strcat(strf,"_ellip13_0_05_detail"),"-dpdflatex");
close

print_polynomial(q,"q",strcat(strf,"_q_coef.m"));
diary off
movefile spectralfactor_test.diary.tmp spectralfactor_test.diary;
