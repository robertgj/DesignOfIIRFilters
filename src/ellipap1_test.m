% ellipap1_test.m

test_common;

unlink("ellipap1_test.diary");
unlink("ellipap1_test.diary.tmp");
diary ellipap1_test.diary.tmp

format short e

w=2*pi*linspace(0,1,2048);
w=w(:);

n=6
rp=0.5
rs=40
[Za,Pa,Ka]=ellipap(n,rp,rs)
[Na,Da]=zp2tf(Za,Pa,Ka);
[Zb,Pb,Kb]=ellipap1(n,rp,rs)
[Nb,Db]=zp2tf(Zb,Pb,Kb);
Ha=freqs(Na,Da,w);
Hb=freqs(Nb,Db,w);
if 20*log10(max(abs(Ha-Hb))) > -87
  error("20*log10(max(abs(Ha-Hb))) > -87");
endif
ax = plotyy(w*0.5/pi,20*log10(abs(Hb)),w*0.5/pi,20*log10(abs(Hb)));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 1 -1 1]);
axis(ax(2),[0 1 -50 -30]);
xlabel("Frequency")
ylabel("Amplitude(dB)")
grid("on");
print("ellipap1_test_n6_response","-dpdflatex");
close

n=7
rp=0.1
rs=55.43
[Zc,Pc,Kc]=ellipap(n,rp,rs)
[Nc,Dc]=zp2tf(Zc,Pc,Kc);
[Zd,Pd,Kd]=ellipap1(n,rp,rs)
[Nd,Dd]=zp2tf(Zd,Pd,Kd);
Hc=freqs(Nc,Dc,w);
Hd=freqs(Nd,Dd,w);
if 20*log10(max(abs(Hc-Hd))) > -119
  error("20*log10(max(abs(Hc-Hd))) > -119");
endif
ax = plotyy(w*0.5/pi,20*log10(abs(Hd)),w*0.5/pi,20*log10(abs(Hd)));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 1 -0.2 0.2]);
axis(ax(2),[0 1 -65 -45]);
xlabel("Frequency")
ylabel("Amplitude(dB)")
grid("on");
print("ellipap1_test_n7_response","-dpdflatex");
close

% Done
diary off
movefile ellipap1_test.diary.tmp ellipap1_test.diary;
