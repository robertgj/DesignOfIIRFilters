% svcascf_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("svcascf_test.diary");
unlink("svcascf_test.diary.tmp");
diary svcascf_test.diary.tmp

format short e

% Some housekeeping
N=19;
fc=0.1;
bits=10;
scale=2^(bits-1);
delta=4;
nfpts=1024;
nppts=(0:511);
name=sprintf("butt%d",N);

% Find the state variable equations of a 19th order Butterworth
% lowpass filter implemented as a cascade of second order sections.
% butter2pq() finds the second order sections in d-p-q format
% directly from the Butterworth poles. 
[dd,p1,p2,q1,q2]=butter2pq(N,fc);

% Find the state variable equations of the example filter
% implemented as a cascade of second order sections.
[a11,a12,a21,a22,b1,b2,c1,c2] = pq2blockKWopt(dd,p1,p2,q1,q2,delta);

% Round the coefficients
a11f=round(a11*scale)/scale;
a12f=round(a12*scale)/scale;
a21f=round(a21*scale)/scale;
a22f=round(a22*scale)/scale;
b1f=round(b1*scale)/scale;
b2f=round(b2*scale)/scale;
c1f=round(c1*scale)/scale;
c2f=round(c2*scale)/scale;
ddf=round(dd*scale)/scale;

% Estimate the noise performance
[ngcascf,Hl2f,xbitsf]=svcasc2noise(a11f,a12f,a21f,a22f,b1f,b2f,c1f,c2f,ddf);

%
% Run the cascade filter for floating and fixed point registers and
% compare it with the overall state-variable filter

% Input waveform
rand("seed",0xdeadbeef)
u=rand(2^14,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);

% Run svf with exact arithmetic
[Af,Bf,Cf,Df] = svcasc2Abcd(a11f,a12f,a21f,a22f, b1f,b2f,c1f,c2f,ddf);
[svf_y,svf_xx] = svf(Af,Bf,Cf,Df,u,"none");

% Run svcascf with exact arithmetic, rounding and extra bits
[y,xx1,xx2] = svcascf(a11f,a12f,a21f,a22f,b1f,b2f,c1f,c2f,ddf,u,"none");
[yf,xx1f,xx2f] = svcascf(a11f,a12f,a21f,a22f,b1f,b2f,c1f,c2f,ddf,u,"round");
xbits=[1,1,1,1,1,1,0,0,0,0];
[yfx,xx1fx,xx2fx] = svcascf(a11f,a12f,a21f,a22f,b1f,b2f,c1f,c2f,ddf,u,...
                            "round",xbits);

% Compare svf to svcascf
if std(svf_y-y(:,end)) > 219*eps
  error("std(svf_y-y(:,end)) > 219*eps");
endif
 
% Compare noise performance of svfcascf and svcascf with extra bits
printf("est_varydf=%8.3f, ",sum((delta*delta*ngcascf)+Hl2f)/12);
printf("varydf=%8.3f\n",var(y(:,end)-yf(:,end)));
printf("est_varydfx=%8.3f, ",
       sum(((2.^(-2*xbits).*ngcascf)*delta*delta)+Hl2f)/12);
printf("varydfx=%8.3f\n",var(y(:,end)-yfx(:,end)));

% Standard deviations of states and section outputs
printf("std(xx1)=[ ");printf("%5.1f ",std(xx1));printf("]\n");
printf("std(xx2)=[ ");printf("%5.1f ",std(xx2));printf("]\n");
printf("std(y)=[ ");printf("%5.1f ",std(y));printf("]\n");
printf("std(xx1f)=[ ");printf("%5.1f ",std(xx1f));printf("]\n");
printf("std(xx2f)=[ ");printf("%5.1f ",std(xx2f));printf("]\n");
printf("std(yf)=[ ");printf("%5.1f ",std(yf));printf("]\n");
printf("std(xx1fx)=[ ");printf("%5.1f ",std(xx1fx));printf("]\n");
printf("std(xx2fx)=[ ");printf("%5.1f ",std(xx2fx));printf("]\n");
printf("std(yfx)=[ ");printf("%5.1f ",std(yfx));printf("]\n");

diary off
movefile svcascf_test.diary.tmp svcascf_test.diary;
