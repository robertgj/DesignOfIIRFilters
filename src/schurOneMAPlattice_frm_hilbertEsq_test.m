% schurOneMAPlattice_frm_hilbertEsq_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMAPlattice_frm_hilbertEsq_test.diary");
unlink("schurOneMAPlattice_frm_hilbertEsq_test.diary.tmp");
diary schurOneMAPlattice_frm_hilbertEsq_test.diary.tmp

format compact
verbose=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Use the filters found by tarczynski_frm_halfband_test.m
%
r0 = [    1.0000000000,   0.4654027371,  -0.0749201995,   0.0137121216, ... 
          0.0035706175,  -0.0098219303 ]';
aa0 = [  -0.0019232288,   0.0038703625,   0.0038937068,  -0.0055310972, ... 
         -0.0073554558,   0.0065538587,   0.0124707197,   0.0002190941, ... 
         -0.0274067156,  -0.0109227368,   0.0373112692,   0.0338245953, ... 
         -0.0500281266,  -0.0817426036,   0.0547645647,   0.3116242327, ... 
          0.4439780707,   0.3116242327,   0.0547645647,  -0.0817426036, ... 
         -0.0500281266,   0.0338245953,   0.0373112692,  -0.0109227368, ... 
         -0.0274067156,   0.0002190941,   0.0124707197,   0.0065538587, ... 
         -0.0073554558,  -0.0055310972,   0.0038937068,   0.0038703625, ... 
         -0.0019232288 ]';
Mmodel=7; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
mr=length(r0)-1; % Model filter order
na=length(aa0);  % FIR masking filter length
dmask=(na-1)/2; % FIR masking filter delay
fap=0.01 % Amplitude pass band edge
fas=0.49 % Amplitude stop band edge
dBap=0.05 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
fpp=0.01 % Phase pass band edge
fps=0.49 % Phase stop band edge
pp=-pi/2 % Nominal passband phase (adjusted for delay)
ppr=0.002*pi % Peak-to-peak pass band phase ripple
Wpp=2 % Pass band phase weight
ftp=0.05 % Delay pass band edge
fts=0.45 % Delay stop band edge
tp=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay
tpr=0.4 % Peak-to-peak pass band delay ripple
Wtp=3 % Pass band delay weight

% Calculate Schur one-multiplier lattice FRM Hilbert filter coefficients
rm1=ones(mr+1,1);
rm1(2:2:end)=-1;
[k0,epsilon0,p0,~] = tf2schurOneMlattice(flipud(r0).*rm1 ,r0.*rm1);
p0=ones(size(k0));

% Find the FRM Hilbert filter FIR masking filter coefficients
dm1=ones((dmask/2)+1,1);
dm1(2:2:end)=-1;
u0=aa0(1:2:dmask+1).*dm1;
v0=aa0(2:2:dmask).*dm1(1:(end-1));

% Frequency vectors
nplot=1000;
w=((0:(nplot-1))')*pi/nplot;

% Amplitude constraints
nap=floor(fap*nplot/0.5)+1;
nas=ceil(fas*nplot/0.5)+1;
wa=w(nap:nas);
Asqd=ones(size(wa));
Wa=Wap*ones(size(wa));

% Group delay constraints
ntp=floor(ftp*nplot/0.5)+1;
nts=ceil(fts*nplot/0.5)+1;
wt=w(ntp:nts);
Td=zeros(size(wt));
Wt=Wtp*ones(size(wt));

% Phase constraints
npp=floor(fpp*nplot/0.5)+1;
nps=ceil(fps*nplot/0.5)+1;
wp=w(npp:nps);
Pd=pp*ones(size(wp));
Wp=Wpp*ones(size(wp));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check empty frequency
%
[Esq,gradEsq] = ...
  schurOneMAPlattice_frm_hilbertEsq(k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                                    [],Asqd,Wa,[],Td,Wt,[],Pd,Wp);
if any([Esq, gradEsq])
  error("any([Esq,gradEsq])");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check Esq 
%
Asq=schurOneMAPlattice_frm_hilbertAsq(wa,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
AsqErr=Wa.*((Asq-Asqd).^2);
AsqErrSum=sum(diff(wa).*(AsqErr(1:(length(wa)-1))+AsqErr(2:end)))/2;
T=schurOneMAPlattice_frm_hilbertT(wt,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
TErr=Wt.*((T-Td).^2);  
TErrSum=sum(diff(wt).*(TErr(1:(length(wt)-1))+TErr(2:end)))/2;
P=schurOneMAPlattice_frm_hilbertP(wp,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
PErr=Wp.*((P-Pd).^2);  
PErrSum=sum(diff(wp).*(PErr(1:(length(wp)-1))+PErr(2:end)))/2;
Esq=schurOneMAPlattice_frm_hilbertEsq(k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                                      wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
if abs(AsqErrSum+TErrSum+PErrSum-Esq) > eps
  error("abs(AsqErrSum+TErrSum+PErrSum-Esq) > eps");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of Esq for k0
%
del=1e-6;
[Esq,gradEsq]=schurOneMAPlattice_frm_hilbertEsq ...
                (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
Nk=length(k0);
delkon2=zeros(size(k0));
delkon2(1)=del/2;
approx_gradEsq=zeros(1,Nk);
for l=1:Nk
  % Test gradient of amplitude response with respect to k0 coefficients 
  EsqP=schurOneMAPlattice_frm_hilbertEsq ...
         (k0+delkon2,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqM=schurOneMAPlattice_frm_hilbertEsq ...
         (k0-delkon2,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  approx_gradEsq(l)=(EsqP-EsqM)/del;
  delkon2=shift(delkon2,1);
endfor
diff_gradEsq=gradEsq(1:Nk)-approx_gradEsq;
max_diff=del/max(abs(diff_gradEsq));
if verbose
  printf("max(abs(diff_gradEsq))=del/%g\n",max_diff);
endif
if max(abs(diff_gradEsq)) > del/1949.75;
  error("max(abs(diff_gradEsq))(del/%g) > del/1949.75",max_diff);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of Esq for u0
%
del=1e-6;
[Esq,gradEsq]=schurOneMAPlattice_frm_hilbertEsq ...
                (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
Nu=length(u0);
deluon2=zeros(size(u0));
deluon2(1)=del/2;
approx_gradEsq=zeros(1,Nu);
for l=1:Nu
  % Test gradient of amplitude response with respect to u0 coefficients 
  EsqP=schurOneMAPlattice_frm_hilbertEsq ...
         (k0,epsilon0,p0,u0+deluon2,v0,Mmodel,Dmodel, ...
          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqM=schurOneMAPlattice_frm_hilbertEsq ...
         (k0,epsilon0,p0,u0-deluon2,v0,Mmodel,Dmodel, ...
          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  approx_gradEsq(l)=(EsqP-EsqM)/del;
  deluon2=shift(deluon2,1);
endfor
diff_gradEsq=gradEsq((Nk+1):(Nk+Nu))-approx_gradEsq;
max_diff=del/max(abs(diff_gradEsq));
if verbose
  printf("max(abs(diff_gradEsq))=del/%g\n",max_diff);
endif
if max(abs(diff_gradEsq)) > del/965.57;
  error("max(abs(diff_gradEsq))(del/%g) > del/965.57",max_diff);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of Esq for v0
%
del=1e-6;
[Esq,gradEsq]=schurOneMAPlattice_frm_hilbertEsq ...
                (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
Nv=length(v0);
delvon2=zeros(size(v0));
delvon2(1)=del/2;
approx_gradEsq=zeros(1,Nv);
for l=1:Nv
  % Test gradient of amplitude response with respect to v0 coefficients 
  EsqP=schurOneMAPlattice_frm_hilbertEsq ...
         (k0,epsilon0,p0,u0,v0+delvon2,Mmodel,Dmodel, ...
          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqM=schurOneMAPlattice_frm_hilbertEsq ...
         (k0,epsilon0,p0,u0,v0-delvon2,Mmodel,Dmodel, ...
          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  approx_gradEsq(l)=(EsqP-EsqM)/del;
  delvon2=shift(delvon2,1);
endfor
diff_gradEsq=gradEsq((Nk+Nu+1):(Nk+Nu+Nv))-approx_gradEsq;
max_diff=del/max(abs(diff_gradEsq));
if verbose
     printf("max(abs(diff_gradEsq))=del/%g\n",max_diff);
endif
if max(abs(diff_gradEsq)) > del/5601.27;
  error("max(abs(diff_gradEsq))(del/%g) > del/5601.27",max_diff);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Done
%
diary off
movefile schurOneMAPlattice_frm_hilbertEsq_test.diary.tmp ...
       schurOneMAPlattice_frm_hilbertEsq_test.diary;
