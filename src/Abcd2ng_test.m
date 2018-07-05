% Abcd2ng_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

unlink("Abcd2ng_test.diary");
unlink("Abcd2ng_test.diary.tmp");
diary Abcd2ng_test.diary.tmp

% Input signal
nbits=10;
nscale=2^(nbits-1);
nsamples=2^15;
rand("seed",0xdeadbeef);
u=(rand(nsamples,1)-0.5);
u=round(nscale*u/(2*std(u)));

% 1
printf("Test 1:\n");
[b,a]=butter(1,0.1);
[A,B,C,D]=tf2Abcd(b,a);
[ng,As,Bs,Cs,Ds,Ts]=Abcd2ng(A,B,C,D)
y=filter(b,a,u);
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
[yABCDf,xxABCDf]=svf(As,Bs,Cs,Ds,u,"round");
ng
est_varyd=(1+ng)/12
varyd=var(yABCD-yABCDf)

% 1a
printf("Test 1a:\n");
[b,a]=butter(1,0.1);
[A,B,C,D]=tf2Abcd(b,a);
[ng,As,Bs,Cs,Ds]=Abcd2ng(A,B,C,D)
y=filter(b,a,u);
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
[yABCDf,xxABCDf]=svf(As,Bs,Cs,Ds,u,"round");
ng
est_varyd=(1+ng)/12
varyd=var(yABCD-yABCDf)

% 1b
printf("Test 1b:\n");
[b,a]=butter(1,0.1);
[A,B,C,D]=tf2Abcd(b,a);
ng=Abcd2ng(A,B,C,D)

% 2
printf("Test 2:\n");
[b,a]=butter(3,0.1);
[A,B,C,D]=tf2Abcd(b,a);
[ng,As,Bs,Cs,Ds]=Abcd2ng(A,B,C,D,1,1e-6)
y=filter(b,a,u);
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
[yABCDf,xxABCDf]=svf(As,Bs,Cs,Ds,u,"round");
ng
est_varyd=(1+ng)/12
varyd=var(yABCD-yABCDf)

% 2a
printf("Test 2a:\n");
[b,a]=butter(3,0.1);
[A,B,C,D]=tf2Abcd(b,a);
[ng,As,Bs,Cs,Ds,Ts]=Abcd2ng(A,B,C,D)
y=filter(b,a,u);
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
[yABCDf,xxABCDf]=svf(As,Bs,Cs,Ds,u,"round");
ng
est_varyd=(1+ng)/12
varyd=var(yABCD-yABCDf)

% 2b
printf("Test 2b:\n");
[b,a]=butter(3,0.1);
[A,B,C,D]=tf2Abcd(b,a);
[ng,As,Bs,Cs,Ds,Ts]=Abcd2ng(A,B,C,D,2)
y=filter(b,a,u);
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
[yABCDf,xxABCDf]=svf(As,Bs,Cs,Ds,u,"round");
ng
est_varyd=(1+ng)/12
varyd=var(yABCD-yABCDf)

% 3
printf("Test 3:\n");
[b,a]=butter(4,0.2);
b=[b(1),kron(b(2:end),[0,1])];
a=[a(1),kron(a(2:end),[0,1])];
[A,B,C,D]=tf2Abcd(b,a);
[ng,As,Bs,Cs,Ds]=Abcd2ng(A,B,C,D,1,1e-6);
y=filter(b,a,u);
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
[yABCDf,xxABCDf]=svf(As,Bs,Cs,Ds,u,"round");
ng
est_varyd=(1+ng)/12
varyd=var(yABCD-yABCDf)

% 3a
printf("Test 3a:\n");
[b,a]=butter(4,0.2);
b=[b(1),kron(b(2:end),[0,1])];
a=[a(1),kron(a(2:end),[0,1])];
[A,B,C,D]=tf2Abcd(b,a);
[ng,As,Bs,Cs,Ds]=Abcd2ng(A,B,C,D,1,0);
y=filter(b,a,u);
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
[yABCDf,xxABCDf]=svf(As,Bs,Cs,Ds,u,"round");
ng
est_varyd=(1+ng)/12
varyd=var(yABCD-yABCDf)

% 4
printf("Test 4:\n");
[b,a]=butter(5,0.2);
b=[b(1),kron(b(2:end),[0,1])];
a=[a(1),kron(a(2:end),[0,1])];
[A,B,C,D]=tf2Abcd(fliplr(a),a);
[ng,As,Bs,Cs,Ds]=Abcd2ng(A,B,C,D,1,1e-6);
y=filter(b,a,u);
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
[yABCDf,xxABCDf]=svf(As,Bs,Cs,Ds,u,"round");
ng
est_varyd=(1+ng)/12
varyd=var(yABCD-yABCDf)

% Done
diary off
movefile Abcd2ng_test.diary.tmp Abcd2ng_test.diary;
