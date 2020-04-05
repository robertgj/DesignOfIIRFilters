% schurOneMAPlattice_frmEsq_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("schurOneMAPlattice_frmEsq_test.diary");
delete("schurOneMAPlattice_frmEsq_test.diary.tmp");
diary schurOneMAPlattice_frmEsq_test.diary.tmp

verbose=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Use the filters found by tarczynski_frm_allpass_test.m
%
%
% Initial filter is based on the filters found by tarczynski_frm_allpass_test.m
%
r0 = [    1.0000000000,   0.2459795566,   0.4610947857,  -0.1206398420, ... 
         -0.0518355550,   0.0567634483,  -0.0264386549,   0.0246267271, ... 
         -0.0176437270,  -0.0008974729,   0.0056956381 ]';
aa0 = [  -0.0216588504,  -0.0114618315,   0.0302611209,  -0.0043408321, ... 
         -0.0274279593,   0.0062386856,   0.0166035962,  -0.0208670992, ... 
         -0.0036770815,   0.0566015372,   0.0039899993,  -0.0683299841, ... 
          0.0358708912,   0.0511704141,  -0.0490317610,  -0.0006425193, ... 
          0.0797439710,  -0.0690263959,  -0.1272015380,   0.2921723028, ... 
          0.6430650464,   0.2921723028,  -0.1272015380,  -0.0690263959, ... 
          0.0797439710,  -0.0006425193,  -0.0490317610,   0.0511704141, ... 
          0.0358708912,  -0.0683299841,   0.0039899993,   0.0566015372, ... 
         -0.0036770815,  -0.0208670992,   0.0166035962,   0.0062386856, ... 
         -0.0274279593,  -0.0043408321,   0.0302611209,  -0.0114618315, ... 
         -0.0216588504 ]';
ac0 = [  -0.0181078194,   0.0563970997,   0.1769164319,   0.0607733538, ... 
         -0.0221620117,  -0.0050415353,   0.0112963303,  -0.0009704899, ... 
         -0.0074583106,  -0.0391109460,   0.1410234146,   0.4815173162, ... 
          0.1799696079,  -0.0814357412,  -0.0115214971,   0.0590494998, ... 
         -0.0510521399,  -0.0105302211,   0.0627620289,  -0.0675640305, ... 
         -0.0255600918,  -0.0675640305,   0.0627620289,  -0.0105302211, ... 
         -0.0510521399,   0.0590494998,  -0.0115214971,  -0.0814357412, ... 
          0.1799696079,   0.4815173162,   0.1410234146,  -0.0391109460, ... 
         -0.0074583106,  -0.0009704899,   0.0112963303,  -0.0050415353, ... 
         -0.0221620117,   0.0607733538,   0.1769164319,   0.0563970997, ... 
         -0.0181078194 ]';
Mmodel=9; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
mr=length(r0)-1; % Model filter order
na=length(aa0);  % FIR masking filter length
dmask=(na-1)/2; % FIR masking filter delay

% Calculate Schur one-multiplier lattice FRM filter coefficients
[k0,epsilon0,p0,~] = tf2schurOneMlattice(flipud(r0),r0);
u0=aa0((dmask+1):end);
v0=ac0((dmask+1):end);

%
% Filter specification
%
n=1000;
tol=1e-6;
ctol=tol/10;
fap=0.30; % Pass band edge
Wap=1; % Pass band amplitude weight
Wat=1; % Transition band amplitude weight
fas=0.3125; % Stop band edge
Was=50; % Stop band amplitude weight
tp=(Mmodel*Dmodel)+dmask;
Wtp=0.05; % Pass band delay weight
pp=0; % Pass band zero-phase phase
Wpp=0.01; % Pass band phase weight

%
% Frequency vectors
%
w=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
wa=w;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
wt=w(1:nap);
Td=zeros(nap,1);
Wt=Wtp*ones(nap,1);

% Phase constraints
wp=w(1:nap);
Pd=zeros(nap,1);
Wp=Wpp*ones(nap,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check empty frequency
%
[Esq,gradEsq] = ...
  schurOneMAPlattice_frmEsq(k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                            [],Asqd,Wa,[],Td,Wt,[],Pd,Wp);
if any([Esq, gradEsq])
  error("any([Esq,gradEsq])");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check Esq 
%
Asq=schurOneMAPlattice_frmAsq(wa,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
AsqErr=Wa.*((Asq-Asqd).^2);
AsqErrSum=sum(diff(wa).*(AsqErr(1:(length(wa)-1))+AsqErr(2:end)))/2;
T=schurOneMAPlattice_frmT(wt,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
TErr=Wt.*((T-Td).^2);  
TErrSum=sum(diff(wt).*(TErr(1:(length(wt)-1))+TErr(2:end)))/2;
P=schurOneMAPlattice_frmP(wp,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
PErr=Wp.*((P-Pd).^2);  
PErrSum=sum(diff(wp).*(PErr(1:(length(wp)-1))+PErr(2:end)))/2;
Esq=schurOneMAPlattice_frmEsq(k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                                      wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
if abs(AsqErrSum+TErrSum+PErrSum-Esq) > eps
  error("abs(AsqErrSum+TErrSum+PErrSum-Esq) > eps");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of Esq for k0
%
del=1e-6;
[Esq,gradEsq]=schurOneMAPlattice_frmEsq ...
                (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
Nk=length(k0);
delkon2=zeros(size(k0));
delkon2(1)=del/2;
approx_gradEsq=zeros(1,Nk);
for l=1:Nk
  % Test gradient of amplitude response with respect to k0 coefficients 
  EsqP=schurOneMAPlattice_frmEsq ...
         (k0+delkon2,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqM=schurOneMAPlattice_frmEsq ...
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
if max(abs(diff_gradEsq)) > del/500;
  error("max(abs(diff_gradEsq))(del/%g) > del/500",max_diff);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of Esq for u0
%
del=1e-6;
[Esq,gradEsq]=schurOneMAPlattice_frmEsq ...
                (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
Nu=length(u0);
deluon2=zeros(size(u0));
deluon2(1)=del/2;
approx_gradEsq=zeros(1,Nu);
for l=1:Nu
  % Test gradient of amplitude response with respect to u0 coefficients 
  EsqP=schurOneMAPlattice_frmEsq ...
         (k0,epsilon0,p0,u0+deluon2,v0,Mmodel,Dmodel, ...
          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqM=schurOneMAPlattice_frmEsq ...
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
if max(abs(diff_gradEsq)) > del/500;
  error("max(abs(diff_gradEsq))(del/%g) > del/500",max_diff);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of Esq for v0
%
del=1e-6;
[Esq,gradEsq]=schurOneMAPlattice_frmEsq ...
                (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
Nv=length(v0);
delvon2=zeros(size(v0));
delvon2(1)=del/2;
approx_gradEsq=zeros(1,Nv);
for l=1:Nv
  % Test gradient of amplitude response with respect to v0 coefficients 
  EsqP=schurOneMAPlattice_frmEsq ...
         (k0,epsilon0,p0,u0,v0+delvon2,Mmodel,Dmodel, ...
          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqM=schurOneMAPlattice_frmEsq ...
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
if max(abs(diff_gradEsq)) > del/2000;
  error("max(abs(diff_gradEsq))(del/%g) > del/2000",max_diff);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Done
%
diary off
movefile schurOneMAPlattice_frmEsq_test.diary.tmp ...
         schurOneMAPlattice_frmEsq_test.diary;
