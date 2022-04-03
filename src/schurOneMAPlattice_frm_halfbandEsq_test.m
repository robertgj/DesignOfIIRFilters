% schurOneMAPlattice_frm_halfbandEsq_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

delete("schurOneMAPlattice_frm_halfbandEsq_test.diary");
delete("schurOneMAPlattice_frm_halfbandEsq_test.diary.tmp");
diary schurOneMAPlattice_frm_halfbandEsq_test.diary.tmp

%
% Initial filter is found by tarczynski_frm_halfband_test.m
%
r0 = [   1.0000000000,   0.4654027371,  -0.0749201995,   0.0137121216, ... 
         0.0035706175,  -0.0098219303   ]';
aa0 = [ -0.0019232288,   0.0038703625,   0.0038937068,  -0.0055310972, ... 
        -0.0073554558,   0.0065538587,   0.0124707197,   0.0002190941, ... 
        -0.0274067156,  -0.0109227368,   0.0373112692,   0.0338245953, ... 
        -0.0500281266,  -0.0817426036,   0.0547645647,   0.3116242327, ... 
         0.4439780707,   0.3116242327,   0.0547645647,  -0.0817426036, ... 
        -0.0500281266,   0.0338245953,   0.0373112692,  -0.0109227368, ... 
        -0.0274067156,   0.0002190941,   0.0124707197,   0.0065538587, ... 
        -0.0073554558,  -0.0055310972,   0.0038937068,   0.0038703625, ... 
        -0.0019232288  ]';

%
% Filter specification
%
n=1000;
R=2; % Model filter all-pass filter decimation
mr=length(r0)-1; % Allpass model filter order
Mmodel=7; % Model filter FRM decimation
Dmodel=9; % Desired model filter passband delay
na=length(aa0); % FIR masking filter length
dmask=(na-1)/2; % FIR masking filter delay
fap=0.24; % Pass band edge
Wap=1; % Pass band amplitude weight
Wtp=0.1; % Pass band delay weight
fas=0.26; % Stop band edge
Was=10; % Stop band amplitude weight

%
% Extract FRM filters
%
[k,epsilon,p,~]=tf2schurOneMlattice(flipud(r0),r0);
u=aa0(1:2:(dmask+1));
v=aa0(2:2:dmask);
Nk=length(k);
Nu=length(u);
Nv=length(v);

%
% Frequency vectors
%
w=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
wa=w;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
wt=w(1:nap);
Td=zeros(nap,1);
Wt=Wtp*ones(nap,1);

% Check the squared-error response
[Esq,gradEsq] = ...
  schurOneMAPlattice_frm_halfbandEsq(k,epsilon,p,u,v,Mmodel,Dmodel, ...
                                     wa,Asqd,Wa,wt,Td,Wt);
Asq=schurOneMAPlattice_frm_halfbandAsq(wa,k,epsilon,p,u,v,Mmodel,Dmodel);
AsqErr=Wa.*((Asq-Asqd).^2);
AsqErrSum=sum(diff(wa).*(AsqErr(1:(length(wa)-1))+AsqErr(2:end)))/2;
T=schurOneMAPlattice_frm_halfbandT(wt,k,epsilon,p,u,v,Mmodel,Dmodel);
TErr=Wt.*((T-Td).^2);  
TErrSum=sum(diff(wt).*(TErr(1:(length(wt)-1))+TErr(2:end)))/2;
if abs(AsqErrSum+TErrSum-Esq) > eps
  error("abs(AsqErrSum+TErrSum-Esq) > eps");
endif

% Check the gradient of the squared-error wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
diff_Esqk=zeros(1,size(k));
for l=1:Nk
  EsqPk=schurOneMAPlattice_frm_halfbandEsq(k+delk,epsilon,p,u,v,Mmodel,Dmodel,...
                                           wa,Asqd,Wa,wt,Td,Wt);
  EsqMk=schurOneMAPlattice_frm_halfbandEsq(k-delk,epsilon,p,u,v,Mmodel,Dmodel,...
                                           wa,Asqd,Wa,wt,Td,Wt);
  delk=circshift(delk,1);
  diff_Esqk(l)=(EsqPk-EsqMk)/del;
endfor
if max(abs(diff_Esqk-gradEsq(1:Nk))) > del/46874
  error("max(abs(diff_Esqk-gradEsq(1:Nk))) > del/46874");
endif

% Check the gradient of the squared-error wrt u
del=1e-6;
delu=zeros(size(u));
delu(1)=del/2;
diff_Esqu=zeros(1,size(k));
for l=1:Nu
  EsqPu=schurOneMAPlattice_frm_halfbandEsq(k,epsilon,p,u+delu,v,Mmodel,Dmodel,...
                                           wa,Asqd,Wa,wt,Td,Wt);
  EsqMu=schurOneMAPlattice_frm_halfbandEsq(k,epsilon,p,u-delu,v,Mmodel,Dmodel,...
                                           wa,Asqd,Wa,wt,Td,Wt);
  delu=circshift(delu,1);
  diff_Esqu(l)=(EsqPu-EsqMu)/del;
endfor
if max(abs(diff_Esqu-gradEsq((Nk+1):(Nk+Nu)))) > del/321538
  error("max(abs(diff_Esqu-gradEsq((Nk+1):(Nk+Nu)))) > del/321538");
endif

% Check the gradient of the squared-error wrt v
del=1e-6;
delv=zeros(size(v));
delv(1)=del/2;
diff_Esqv=zeros(1,size(k));
for l=1:Nv
  EsqPv=schurOneMAPlattice_frm_halfbandEsq(k,epsilon,p,u,v+delv,Mmodel,Dmodel,...
                                           wa,Asqd,Wa,wt,Td,Wt);
  EsqMv=schurOneMAPlattice_frm_halfbandEsq(k,epsilon,p,u,v-delv,Mmodel,Dmodel,...
                                           wa,Asqd,Wa,wt,Td,Wt);
  delv=circshift(delv,1);
  diff_Esqv(l)=(EsqPv-EsqMv)/del;
endfor
if max(abs(diff_Esqv-gradEsq((Nk+Nu+1):end))) > del/189763
  error("max(abs(diff_Esqv-gradEsq((Nk+Nu+1):end))) > del/189763");
endif

% Done
diary off
movefile schurOneMAPlattice_frm_halfbandEsq_test.diary.tmp ...
         schurOneMAPlattice_frm_halfbandEsq_test.diary;
