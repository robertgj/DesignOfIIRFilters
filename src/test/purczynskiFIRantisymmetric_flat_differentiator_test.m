% purczynskiFIRantisymmetric_flat_differentiator_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

delete("purczynskiFIRantisymmetric_flat_differentiator_test.diary");
delete("purczynskiFIRantisymmetric_flat_differentiator_test.diary.tmp");
diary purczynskiFIRantisymmetric_flat_differentiator_test.diary.tmp

strf="purczynskiFIRantisymmetric_flat_differentiator_test";

N=85;
h2=purczynskiFIRantisymmetric_flat_differentiator(N,2);
h4=purczynskiFIRantisymmetric_flat_differentiator(N,4);
h8=purczynskiFIRantisymmetric_flat_differentiator(N,8);
h16=purczynskiFIRantisymmetric_flat_differentiator(N,16);

%
% Plot
%
nplot=1024;
f=((0:(nplot-1))')*0.5/nplot;
w=2*pi*f;
H2=freqz(h2,1,w);
H4=freqz(h4,1,w);
H8=freqz(h8,1,w);
H16=freqz(h16,1,w);
% Plot response
plot(w*0.5/pi,abs([H2,H4,H8,H16]))
xlabel("Frequency");
ylabel("Amplitude");
tstr=sprintf("Kumar et al. maximally linear FIR differentiator amplitude \
response : N=%d, p=2,4,8,16",N);
title(tstr);
axis([0 0.5 0 3]);
grid("on");
legend("p=2","p=4","p=8","p=16");
legend("location","northwest");
legend("boxoff");
legend("right");
print(strcat(strf,"_response"),"-dpdflatex");
close
% Plot error
plot(w*0.5/pi,20*log10(abs(abs([H2,H4,H8,H16])-w)))
xlabel("Frequency");
ylabel("Amplitude error (dB)");
tstr=sprintf("Kumar et al. maximally linear FIR differentiator amplitude \
error $(|H_{p}(\\omega)|-\\omega)$ : N=%d, p=2,4,8,16",N);
title(tstr);
axis([0 0.5 -300 30]);
grid("on");
legend("p=2","p=4","p=8","p=16");
legend("location","southeast");
legend("boxoff");
legend("right");
print(strcat(strf,"_error"),"-dpdflatex");
close

%
% Save results
%
print_polynomial(h2,"h2","%15.12f");
print_polynomial(h2,"h2",sprintf("%s_h2_coef.m",strf),"%15.12f");

print_polynomial(h4,"h4","%15.12f");
print_polynomial(h4,"h4",sprintf("%s_h4_coef.m",strf),"%15.12f");

print_polynomial(h8,"h8","%15.12f");
print_polynomial(h8,"h8",sprintf("%s_h8_coef.m",strf),"%15.12f");

print_polynomial(h16,"h16","%15.12f");
print_polynomial(h16,"h16",sprintf("%s_h16_coef.m",strf),"%15.12f");

save purczynskiFIRantisymmetric_flat_differentiator_test.mat N h2 h4 h8 h16

%
% Done
%
diary off
movefile purczynskiFIRantisymmetric_flat_differentiator_test.diary.tmp ...
         purczynskiFIRantisymmetric_flat_differentiator_test.diary;

