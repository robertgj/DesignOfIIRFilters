% johanssonOneMlatticeEsq_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("johanssonOneMlatticeEsq_test.diary");
unlink("johanssonOneMlatticeEsq_test.diary.tmp");
diary johanssonOneMlatticeEsq_test.diary.tmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Band-stopfilter specification
fapl=0.15,fasl=0.2,fasu=0.25,fapu=0.3,Wap=1,Was=1

% Band-stop filter from johansson_cascade_allpass_bandstop_test.m
fM = [  -0.0314881200,  -0.0000085599,   0.2814857078,   0.5000169443 ];
a0 = [   1.0000000000,  -0.5650802796,   1.6504647259,  -0.4790659039, ... 
         0.7284633026 ];
a1 = [   1.0000000000,  -0.2594839587,   0.6383172372 ];

% Convert all-pass filter transfer functions to Schur 1-multiplier lattice
[k0,epsilon0,~,~]=tf2schurOneMlattice(fliplr(a0),a0);
[k1,epsilon1,~,~]=tf2schurOneMlattice(fliplr(a1),a1);

% Frequencies
nf=500;
wa=(0:nf)'*pi/nf;
napl=ceil(fapl*nf/0.5)+1;
nasl=floor(fasl*nf/0.5)+1;
nasu=ceil(fasu*nf/0.5)+1;
napu=floor(fapu*nf/0.5)+1;
Ad=[ones(napl,1);zeros(napu-napl-1,1);ones(nf-napu+2,1)];
Wa=[Wap*ones(napl,1); ...
    zeros(nasl-napl-1,1); ...
    Was*ones(nasu-nasl+1,1); ...
    zeros(napu-nasu-1,1); ...
    Wap*ones(nf-napu+2,1)];
nchk=[1, napl-1,napl,napl+1,nasl-1,nasl,nasl+1, ...
         nasu-1,nasu,nasu+1,napu-1,napu,napu+1,nf+1];
printf("nchk=[1, napl-1,napl,napl+1,nasl-1,nasl,nasl+1, ...\n");
printf("       nasu-1,nasu,nasu+1,napu-1,napu,napu+1,nf+1];\n");
printf("nchk=[ ");printf("%d ",nchk(1:7));printf(" ... \n");
printf("         ");printf("%d ",nchk(8:end));printf("];\n");
printf("wa(nchk)=[ ");printf("%g ",wa(nchk(1:7))*0.5/pi);printf(" ... \n");
printf("             ");printf("%g ",wa(nchk(8:end))*0.5/pi);printf("]*2*pi;\n");
printf("Ad(nchk)=[ ");printf("%d ",Ad(nchk(1:7)));printf(" ... \n");
printf("             ");printf("%d ",Ad(nchk(8:end)));printf("];\n");
printf("Wa(nchk)=[ ");printf("%d ",Wa(nchk(1:7)));printf(" ... \n");
printf("             ");printf("%d ",Wa(nchk(8:end)));printf("];\n");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check the zero-phase response
Azp=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1);
dwa=diff(wa);
EAzp=Wa.*(Azp-Ad);
sqEAzp=EAzp.*(Azp-Ad);
EsqAzp=sum(dwa.*(sqEAzp(1:(end-1))+sqEAzp(2:end)))/2;
Esq=johanssonOneMlatticeEsq(fM,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);
if max(abs(Esq-EsqAzp)) > eps
  error("max(abs(Esq-EsqAzp))(%g*eps) > eps", max(abs(Esq-EsqAzp))/eps);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate gradients
[Esq,gradEsq]=johanssonOneMlatticeEsq(fM,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);

% Check the gradients of the squared-error response wrt fM
RfM=1:length(fM);
del=1e-6;
delf=zeros(size(fM));
delf(1)=del/2;
diff_Esqf=zeros(size(fM));
for l=1:length(fM)
  EsqfPdel2=johanssonOneMlatticeEsq(fM+delf,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);
  EsqfMdel2=johanssonOneMlatticeEsq(fM-delf,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);
  delf=shift(delf,1);
  diff_Esqf(l)=(EsqfPdel2-EsqfMdel2)/del;
endfor
if max(abs(diff_Esqf-gradEsq(RfM))) > del/50e6
  error("max(abs(diff_Esqf-gradEsq(RfM))) > del/50e6");
endif

% Check the gradients of the zero-phase response wrt k0
Rk0=(1+length(fM)):(length(fM)+length(k0));
del=1e-6;
delk=zeros(size(k0));
delk(1)=del/2;
diff_Esqk0=zeros(size(k0));
for l=1:length(k0)
  Esqk0Pdel2=johanssonOneMlatticeEsq(fM,k0+delk,epsilon0,k1,epsilon1,wa,Ad,Wa);
  Esqk0Mdel2=johanssonOneMlatticeEsq(fM,k0-delk,epsilon0,k1,epsilon1,wa,Ad,Wa);
  delk=shift(delk,1);
  diff_Esqk0(l)=(Esqk0Pdel2-Esqk0Mdel2)/del;
endfor
if max(abs(diff_Esqk0-gradEsq(Rk0))) > del/5e5
  error("max(abs(diff_Esqk0-gradEsq(Rk0))) > del/5e5");
endif

% Check the gradients of the zero-phase response wrt k1
Rk1=(1+length(fM)+length(k0)):(length(fM)+length(k0)+length(k1));
del=1e-6;
delk=zeros(size(k1));
delk(1)=del/2;
diff_Esqk1=zeros(size(k1));
for l=1:length(k1)
  Esqk1Pdel2=johanssonOneMlatticeEsq(fM,k0,epsilon0,k1+delk,epsilon1,wa,Ad,Wa);
  Esqk1Mdel2=johanssonOneMlatticeEsq(fM,k0,epsilon0,k1-delk,epsilon1,wa,Ad,Wa);
  delk=shift(delk,1);
  diff_Esqk1(l)=(Esqk1Pdel2-Esqk1Mdel2)/del;
endfor
if max(abs(diff_Esqk1-gradEsq(Rk1))) > del/1e6
  error("max(abs(diff_Esqk1-gradEsq(Rk1))) > del/1e6");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate diagonal of Hessian
[Esq,gradEsq,diagHessEsq]=...
  johanssonOneMlatticeEsq(fM,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);

% Check the diagonal of the Hessian of the phase response wrt fM
RfM=1:length(fM);
del=1e-6;
delf=zeros(size(fM));
delf(1)=del/2;
diff_gradEsqf=zeros(size(fM));
for l=1:length(fM)
  [~,gradEsqfPdel2]= ...
    johanssonOneMlatticeEsq(fM+delf,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);
  [~,gradEsqfMdel2]= ...
    johanssonOneMlatticeEsq(fM-delf,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);
  delf=shift(delf,1);
  diff_gradEsqf(l)=(gradEsqfPdel2(l)-gradEsqfMdel2(l))/del;
endfor
if max(max(abs(diff_gradEsqf-diagHessEsq(RfM)))) > del/1e3
  error("max(abs(diff_gradEsqf-diagHessEsq(RfM))) > del/1e3");
endif

% Check the diagonal of the Hessian of the zero-phase response wrt k0
Rk0=(length(fM)+1):(length(fM)+length(k0));
del=1e-6;
delk=zeros(size(k0));
delk(1)=del/2;
diff_gradEsqk0=zeros(size(k0));
for l=1:length(k0)
  [~,gradEsqk0Pdel2]= ...
    johanssonOneMlatticeEsq(fM,k0+delk,epsilon0,k1,epsilon1,wa,Ad,Wa);
  [~,gradEsqk0Mdel2]= ...
    johanssonOneMlatticeEsq(fM,k0-delk,epsilon0,k1,epsilon1,wa,Ad,Wa);
  delk=shift(delk,1);
  diff_gradEsqk0(l)=(gradEsqk0Pdel2(Rk0(l))-gradEsqk0Mdel2(Rk0(l)))/del;
endfor
if max(abs(diff_gradEsqk0-diagHessEsq(Rk0))) > del/2e3
  error("max(abs(diff_gradEsqk0-diagHessEsq(Rk0)))(%g) > del/2e3", ...
        max(abs(diff_gradEsqk0-diagHessEsq(Rk0))));
endif

% Check the diagonal of the Hessian of the zero-phase response wrt k1
Rk1=(length(fM)+length(k0)+1):(length(fM)+length(k0)+length(k1));
del=1e-6;
delk=zeros(size(k1));
delk(1)=del/2;
diff_gradEsqk1=zeros(size(k1));
for l=1:length(k1)
  [~,gradEsqk1Pdel2]= ...
    johanssonOneMlatticeEsq(fM,k0,epsilon0,k1+delk,epsilon1,wa,Ad,Wa);
  [~,gradEsqk1Mdel2]= ...
    johanssonOneMlatticeEsq(fM,k0,epsilon0,k1-delk,epsilon1,wa,Ad,Wa);
  delk=shift(delk,1);
  diff_gradEsqk1(l)=(gradEsqk1Pdel2(Rk1(l))-gradEsqk1Mdel2(Rk1(l)))/del;
endfor
if max(abs(diff_gradEsqk1-diagHessEsq(Rk1))) > del/3e5
  error("max(abs(diff_gradEsqk1-diagHessEsq(Rk1)))(%g) > del/3e5", ...
        max(abs(diff_gradEsqk1-diagHessEsq(Rk1))));
endif

% Done
diary off
movefile johanssonOneMlatticeEsq_test.diary.tmp ...
         johanssonOneMlatticeEsq_test.diary;
