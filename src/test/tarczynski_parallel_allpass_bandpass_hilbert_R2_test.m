% tarczynski_parallel_allpass_bandpass_hilbert_R2_test.m
% Copyright (C) 2026 Robert G. Jenssen
%
% Use the method of Tarczynski et al to design a bandpass Hilbert filter
% as the difference of two doubly-pipelined parallel all-pass filters
% with anti-aliasing.
%
% See: "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

strf="tarczynski_parallel_allpass_bandpass_hilbert_R2_test";

delete(strcat(strf,".diary",strf));
delete(strcat(strf,".diary.tmp",strf));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Band-pass Hilbert filter specification 
R=2;
polyphase=false;
difference=true;
Ni=5; % Initial low-pass filter order
fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25
Wasl=200,Watl=0.01,Wap=1,Watu=0.01,Wasu=200
ftpl=0.1,ftpu=0.2,tp=16,Wtp=10
fppl=0.1,fppu=0.2,pp=3.5,Wpp=10

% Anti-aliasing filter
maa=11;
faap=0.25;

% Frequency points
n=1000;
w=pi*(0:(n-1))'/n;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;

% Anti-aliasing filter
[Naa,Daa]=butter(maa,faap*2);
[Aaa1,Aaa2]=tf2pa(Naa,Daa);
Aaa1=Aaa1(:)';
Aaa2=Aaa2(:)';
Aaa1(2:2:end)=0;
Aaa2(2:2:end)=0;
Daa=conv(Aaa1,Aaa2);
Naa=(conv(fliplr(Aaa1),Aaa2)+conv(fliplr(Aaa2),Aaa1))/2;
Haa=freqz(Naa,Daa,w);
Aaa=abs(Haa);
Paa=unwrap(arg(Haa));
Taa=delayz(Naa,Daa,w);

% Initial filter for parallel doubly-pipelined all-pass filter
% Half-band Butterworth
[Nlp,Dlp]=butter(Ni,0.5);
% Convert to parallel all-pass
[A1lp,A2lp]=tf2pa(Nlp,Dlp);
% Find frequency transformation to band-pass prototype
pbp=phi2p([fapl,fapu]*2);
% Find parallel all-pass filters after frequency transformation
[~,A1]=tfp2g(fliplr(A1lp),A1lp,pbp,-1);
[~,A2]=tfp2g(fliplr(A2lp),A2lp,pbp,-1);

% Unconstrained minimisation
tol=1e-10;
maxiter=20000
m1=length(A1)-1;
m2=length(A2)-1;
abi=[A1(2:end),A2(2:end)];
abi=abi(:);
Ad=[zeros(napl-1,1);ones(napu-napl+1,1)./Aaa(napl:napu);zeros(n-napu,1)];
Wa=[Wasl*ones(napl-1,1);Wap*ones(napu-napl+1,1);Wasu*ones(n-napu,1)];
Pd=(pp*pi)-(w*tp)-Paa;
Wp=[zeros(nppl-1,1);Wpp*ones(nppu-nppl+1,1);zeros(n-nppu,1)];
Td=(tp*ones(size(w)))-Taa;
Wt=[zeros(ntpl-1,1);Wtp*ones(ntpu-ntpl+1,1);zeros(n-ntpu,1)];
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
WISEJ_PA([],m1,m2,R,polyphase,difference,Ad,Wa,Td,Wt,Pd,Wp);
[ab0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_PA,abi,opt);
if (INFO == 1)
  printf("Converged to a solution point.\n");
elseif (INFO == 2)
  printf("Last relative step size was less that TolX.\n");
elseif (INFO == 3)
  printf("Last relative decrease in function value was less than TolF.\n");
elseif (INFO == 0)
  printf("Iteration limit exceeded.\n");
elseif (INFO == -1)
  printf("Algorithm terminated by OutputFcn.\n");
elseif (INFO == -3)
  printf("The trust region radius became excessively small.\n");
else
  error("Unknown INFO value.\n");
endif
printf("Function value=%f\n", FVEC);
printf("fminunc iterations=%d\n", OUTPUT.iterations);
printf("fminunc successful=%d??\n", OUTPUT.successful);
printf("fminunc funcCount=%d\n", OUTPUT.funcCount);

% Extract the parallel denominator polynomials
ab0=ab0(:)';
Da0=[1,ab0(1:m1)];
Db0=[1,ab0((m1+1):end)];
Da0R=[1,kron(Da0(2:end),[zeros(R-1,1),1])];
Db0R=[1,kron(Db0(2:end),[zeros(R-1,1),1])];
D0R=conv(Da0R,Db0R);
N0R=(conv(fliplr(Da0R),Db0R)-conv(fliplr(Db0R),Da0R))/2;

% Calculate initial response
Ha0=freqz(fliplr(Da0R),Da0R,w);
Hb0=freqz(fliplr(Db0R),Db0R,w);
H0c=(Ha0-Hb0)/2;
A0=abs(H0c).*Aaa;
P0=unwrap(arg(H0c))+Paa;
Ta0=delayz(fliplr(Da0R),Da0R,w);
Tb0=delayz(fliplr(Db0R),Db0R,w);
T0c=(Ta0+Tb0)/2;
T0=T0c+Taa;

% Plot initial response
subplot(311)
plot(w*0.5/pi,20*log10(A0));
axis([0 0.5 -30 1]);
tstr=sprintf(["Band-pass Hilbert R=2 response : ", ...
              "fasl=%g,fapl=%g,fapu=%g,fasu=%g,tp=%g,pp=%g"],...
             fasl,fapl,fapu,fasu,tp,pp);
grid("on")
title(tstr);
ylabel("Amplitude(dB)");
zticks([]);
subplot(312)
plot(w*0.5/pi,mod((P0+(w*tp))/pi,2));
axis([0 0.5 mod(pp,2)+[-1,1]])
grid("on")
ylabel("Phase(rad./$\\pi$)");
zticks([]);
subplot(313)
plot(w*0.5/pi,T0)
axis([0 0.5,0 20])
grid("on")
ylabel("Delay(samples)");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Save the result
print_polynomial(Aaa1,"Aaa1");
print_polynomial(Aaa1,"Aaa1",strcat(strf,"_Aaa1_coef.m"));
print_polynomial(Aaa2,"Aaa2");
print_polynomial(Aaa2,"Aaa2",strcat(strf,"_Aaa2_coef.m"));
print_polynomial(Naa,"Naa");
print_polynomial(Naa,"Naa",strcat(strf,"_Naa_coef.m"));
print_polynomial(Daa,"Daa");
print_polynomial(Daa,"Daa",strcat(strf,"_Daa_coef.m"));
print_polynomial(Da0,"Da0");
print_polynomial(Da0,"Da0",strcat(strf,"_Da0_coef.m"));
print_polynomial(Db0,"Db0");
print_polynomial(Db0,"Db0",strcat(strf,"_Db0_coef.m"));
print_polynomial(N0R,"N0R");
print_polynomial(N0R,"N0R",strcat(strf,"_N0R_coef.m"));
print_polynomial(D0R,"D0R");
print_polynomial(D0R,"D0R",strcat(strf,"_D0R_coef.m"));

eval(sprintf(["save %s.mat tol maxiter polyphase difference R Ni ", ...
              " faap fasl fapl fapu fasu Wasl Watl Wap Watu Wasu ", ...
              " ftpl ftpu tp Wtp fppl fppu pp Wpp ", ...
              " maa m1 m2 abi ab0 Da0 Db0 Naa Daa N0R D0R"], ...
             strf));

% Done
toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
