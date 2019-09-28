% compare_fir_iir_socp_slb_lowpass_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

unlink("compare_fir_iir_socp_slb_lowpass_test.diary");
unlink("compare_fir_iir_socp_slb_lowpass_test.diary.tmp");
diary compare_fir_iir_socp_slb_lowpass_test.diary.tmp


% Import coefficients
fir_socp_slb_lowpass_test_d1_coef;
U_fir=Ud1;V_fir=Vd1;M_fir=Md1;Q_fir=Qd1;R_fir=1;d1_fir=d1;
iir_socp_slb_lowpass_test_d1_coef;
U_iir=Ud1;V_iir=Vd1;M_iir=Md1;Q_iir=Qd1;R_iir=1;d1_iir=d1;

% Common strings for output plots
strf="compare_fir_iir_socp_slb_lowpass_test";

% Calculate response
n=1000;
f=(0:(n-1))'/(2*n);
w=2*pi*f;
A_fir=iirA(w,d1_fir,U_fir,V_fir,M_fir,Q_fir,R_fir);
T_fir=iirT(w,d1_fir,U_fir,V_fir,M_fir,Q_fir,R_fir);
A_iir=iirA(w,d1_iir,U_iir,V_iir,M_iir,Q_iir,R_iir);
T_iir=iirT(w,d1_iir,U_iir,V_iir,M_iir,Q_iir,R_iir);

% Define desired response
fap=0.15 % Pass band amplitude response edge
nap=ceil((n*fap)/0.5)+1;
ftp=0.15 % Pass band group-delay response edge
ntp=ceil((n*ftp)/0.5)+1;
td=10 % Pass band group-delay
fas=0.2 % Stop band amplitude response edge
nas=floor((n*fas)/0.5)+1;

% Symmetric FIR filter with delay td
d_sfir=remez(2*td,[0 fap fas 0.5]*2,[1 1 0 0],[1 7]);
H_sfir=freqz(d_sfir,1,w);
A_sfir=abs(H_sfir);
T_sfir=td*ones(size(A_sfir));

% Symmetric FIR filter with delay equal to (number_of_IIR_coefficients-1)/2
N_iir=(1+U_iir+V_iir+M_iir+Q_iir);
d_lsfir=remez(N_iir-1,[0 fap fas 0.5]*2,[1 1 0 0],[1 50]);
H_lsfir=freqz(d_lsfir,1,w);
A_lsfir=abs(H_lsfir);
T_lsfir=((N_iir-1)/2)*ones(size(A_sfir));

% Plot amplitude response
Rnap=1:nap;
Rnas=nas:length(f);
[ax,h1,h2]= ...
  plotyy(f(Rnap), ...
         20*log10([A_fir(Rnap),A_iir(Rnap),A_sfir(Rnap),A_lsfir(Rnap)]), ...
         f(Rnas), ...
         20*log10([A_fir(Rnas),A_iir(Rnas),A_sfir(Rnas),A_lsfir(Rnas)]));
h1c=get(h1,"color");
for k=1:4
  set(h2(k),"color",h1c{k});
endfor
set(h1(1),"linestyle","--");
set(h1(2),"linestyle","-");
set(h1(3),"linestyle","-.");
set(h1(4),"linestyle",":");
set(h2(1),"linestyle","--");
set(h2(2),"linestyle","-");
set(h2(3),"linestyle","-.");
set(h2(4),"linestyle",":");
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
if 0
  ylabel(ax(1),"Pass-band amplitude(dB)");
  ylabel(ax(2),"Stop-band amplitude(dB)");
else
  ylabel(ax(1),"Amplitude(dB)");
endif
% End of hack
axis(ax(1),[0 0.5 -5, 2]);
axis(ax(2),[0 0.5 -60 -30]);
grid("on");
strt=sprintf("Amplitude response");
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
legend("FIR","IIR","Symmetric FIR(21 coef.)","Symmetric FIR(31 coef.)");
legend("boxoff");
legend("location","southwest");
print(strcat(strf,"_A"),"-dpdflatex");
close

% Plot group delay response
Rntp=1:ntp;
plot(f(Rntp),T_fir(Rntp),"linestyle","--", ...
     f(Rntp),T_iir(Rntp),"linestyle","-", ...
     f(Rntp),T_sfir(Rntp),"linestyle","-.");
axis([0 ftp 9.6, 10.4]);
grid("on");
strt=sprintf("Group delay response");
title(strt);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
legend("FIR","IIR","Symmetric FIR(21 coef.)");
legend("boxoff");
legend("location","southwest");
print(strcat(strf,"_T"),"-dpdflatex");
close

% Done
diary off
movefile compare_fir_iir_socp_slb_lowpass_test.diary.tmp ...
         compare_fir_iir_socp_slb_lowpass_test.diary;

