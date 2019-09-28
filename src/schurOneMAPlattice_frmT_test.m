% schurOneMAPlattice_frmT_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("schurOneMAPlattice_frmT_test.diary");
unlink("schurOneMAPlattice_frmT_test.diary.tmp");
diary schurOneMAPlattice_frmT_test.diary.tmp

verbose=false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Use the filters found by tarczynski_frm_allpass_test.m
%
r0 = [   1.0000000000,   0.2459795566,   0.4610947857,  -0.1206398420, ... 
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
rM=zeros((Mmodel*mr)+1,1);
rM(1:Mmodel:end)=r0;
n0=0.5*([conv(flipud(rM),aa0+ac0);zeros(Mmodel*Dmodel,1)] + ...
        [zeros(Mmodel*Dmodel,1);conv(aa0-ac0,rM)]);

% Frequency vector
nplot=1000;
w=((0:(nplot-1))'*pi/nplot);
fap=0.30;
nap=(ceil(fap*nplot/0.5)+1);
wap=w(1:nap);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check empty frequency
%
[T,gradT]=schurOneMAPlattice_frmT([],k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
if ~isempty(T) || ~isempty(gradT)
  error("~isempty(T) || ~isempty(gradT)");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare T response with freqz
%
Tp=grpdelay(n0,rM,w)-((Dmodel*Mmodel)+dmask);
T=schurOneMAPlattice_frmT(w,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
% Pass band
if max(abs(T(1:nap)-Tp(1:nap))) > 5000*eps
  error("Pass band max(abs(T-Tp))>5000*eps (%d*eps)", ...
        ceil(max(abs(T(1:nap)-Tp(1:nap)))/eps));
endif
% Whole band
if max(abs(T-Tp)) > 1e10*eps
  error("Whole band max(abs(T-Tp))>1e10*eps (%d*eps)", ...
        ceil(max(abs(T-Tp))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of T for k0
%
del=1e-6;
[T,gradT]=schurOneMAPlattice_frmT(w,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
Nk=length(k0);
delkon2=zeros(size(k0));
delkon2(1)=del/2;
approx_gradT=zeros(nplot,Nk);
for l=1:Nk
  % Test gradient of amplitude response with respect to k0 coefficients 
  TP=schurOneMAPlattice_frmT(w,k0+delkon2,epsilon0,p0,u0,v0,Mmodel,Dmodel);
  TM=schurOneMAPlattice_frmT(w,k0-delkon2,epsilon0,p0,u0,v0,Mmodel,Dmodel);
  approx_gradT(:,l)=(TP-TM)/del;
  delkon2=shift(delkon2,1);
endfor
diff_gradT=gradT(:,1:Nk)-approx_gradT;
% Pass band
if verbose
  printf("Pass band k0 max(max(abs(diff_gradT(1:nap,:))))=%g*del\n", ...
         max(max(abs(diff_gradT(1:nap,:))))/del);
endif
if max(max(abs(diff_gradT(1:nap,:)))) > del/4;
  error("Pass band k0 max(max(abs(diff_gradT)))(%g*del) > del/4", ...
        max(max(abs(diff_gradT(1:nap,:))))/del);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of T for u0
%
del=1e-6;
[T,gradT]=schurOneMAPlattice_frmT(w,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
Nu=length(u0);
deluon2=zeros(size(u0));
deluon2(1)=del/2;
approx_gradT=zeros(nplot,Nu);
for l=1:Nu
  % Test gradient of amplitude response with respect to u0 coefficients 
  TP=schurOneMAPlattice_frmT(w,k0,epsilon0,p0,u0+deluon2,v0,Mmodel,Dmodel);
  TM=schurOneMAPlattice_frmT(w,k0,epsilon0,p0,u0-deluon2,v0,Mmodel,Dmodel);
  approx_gradT(:,l)=(TP-TM)/del;
  deluon2=shift(deluon2,1);
endfor
diff_gradT=gradT(:,(Nk+1):(Nk+Nu))-approx_gradT;
% Pass band
if verbose
  printf("Pass band u0 max(max(abs(diff_gradT(1:nap,:))))=%g*del\n", ...
         max(max(abs(diff_gradT(1:nap,:))))/del);
endif
if max(max(abs(diff_gradT(1:nap,:)))) > del/100;
  error("Pass band u0 max(max(abs(diff_gradT)))(%g*del) > del/100", ...
        max(max(abs(diff_gradT(1:nap,:))))/del);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of T for v0
%
del=1e-6;
[T,gradT]=schurOneMAPlattice_frmT(w,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
Nv=length(v0);
delvon2=zeros(size(v0));
delvon2(1)=del/2;
approx_gradT=zeros(nplot,Nv);
for l=1:Nv
  % Test gradient of amplitude response with respect to v0 coefficients 
  TP=schurOneMAPlattice_frmT(w,k0,epsilon0,p0,u0,v0+delvon2,Mmodel,Dmodel);
  TM=schurOneMAPlattice_frmT(w,k0,epsilon0,p0,u0,v0-delvon2,Mmodel,Dmodel);
  approx_gradT(:,l)=(TP-TM)/del;
  delvon2=shift(delvon2,1);
endfor
diff_gradT=gradT(:,(Nk+Nu+1):(Nk+Nu+Nv))-approx_gradT;
% Pass band
if verbose
  printf("Pass band v0 max(max(abs(diff_gradT(1:nap,:))))=%g*del\n", ...
         max(max(abs(diff_gradT(1:nap,:))))/del);
endif
if max(max(abs(diff_gradT(1:nap,:)))) > del/100;
  error("Pass band v0 max(max(abs(diff_gradT)))(%g*del) > del/100", ...
        max(max(abs(diff_gradT(1:nap,:))))/del);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Done
%
diary off
movefile schurOneMAPlattice_frmT_test.diary.tmp ...
         schurOneMAPlattice_frmT_test.diary;
