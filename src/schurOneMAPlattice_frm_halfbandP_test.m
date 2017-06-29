% schurOneMAPlattice_frm_halfbandP_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMAPlattice_frm_halfbandP_test.diary");
unlink("schurOneMAPlattice_frm_halfbandP_test.diary.tmp");
diary schurOneMAPlattice_frm_halfbandP_test.diary.tmp

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

% Calculate Schur one-multiplier lattice FRM filter coefficients
[k0,epsilon0,p0,~] = tf2schurOneMlattice(flipud(r0),r0);
u0=aa0(1:2:dmask+1);
v0=aa0(2:2:dmask);
r2M=zeros((2*Mmodel*mr)+1,1);
r2M(1:(2*Mmodel):end)=r0;
ac0=aa0.*((-ones(na,1)).^((0:(na-1))'))-[zeros(dmask,1);1;zeros(dmask,1)];
n0=0.5*([conv(flipud(r2M),aa0+ac0);zeros(Mmodel*Dmodel,1)] + ...
        [zeros(Mmodel*Dmodel,1);conv(aa0-ac0,r2M)]);

% Frequency vector
nplot=1024;
w=((0:(nplot-1))'*pi/nplot);
fap=0.24;
nap=(ceil(fap*nplot/0.5)+1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check empty frequency
%
[P,gradP] = ...
  schurOneMAPlattice_frm_halfbandP([],k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
if ~isempty(P) || ~isempty(gradP)
  error("~isempty(P) || ~isempty(gradP)");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare P response with freqz over the passband
%
Hp=freqz(n0,r2M,w);
Pp=unwrap(arg(Hp))+(w*((Dmodel*Mmodel)+dmask));
P=schurOneMAPlattice_frm_halfbandP(w,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
if max(abs(P(1:nap)-Pp(1:nap))) > 231*eps
  error("max(abs(P(1:nap)-Pp(1:nap))) > 231*eps (%d*eps)", ...
        ceil(max(abs(P(1:nap)-Pp(1:nap)))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of P for k0 over the passband
%
del=1e-6;
[P,gradP]=schurOneMAPlattice_frm_halfbandP(w,k0,epsilon0,p0, ...
                                           u0,v0,Mmodel,Dmodel);
Nk=length(k0);
delkon2=zeros(size(k0));
delkon2(1)=del/2;
approx_gradP=zeros(nplot,Nk);
for l=1:Nk
  % Test gradient of amplitude response with respect to k0 coefficients 
  PP=schurOneMAPlattice_frm_halfbandP(w,k0+delkon2,epsilon0,p0,...
                                      u0,v0,Mmodel,Dmodel);
  PM=schurOneMAPlattice_frm_halfbandP(w,k0-delkon2,epsilon0,p0,...
                                      u0,v0,Mmodel,Dmodel);
  approx_gradP(:,l)=(PP-PM)/del;
  delkon2=shift(delkon2,1);
endfor
diff_gradP=gradP(:,1:Nk)-approx_gradP;
% Passband
if verbose
  printf("max(max(abs(diff_gradP(1:nap,:))))=%g*del\n", ...
         max(max(abs(diff_gradP(1:nap,:))))/del);
endif
if max(max(abs(diff_gradP(1:nap,:)))) > del/197.6;
  error("max(max(abs(diff_gradP(1:nap,:))))(%g*del) > del/197.6", ...
        max(max(abs(diff_gradP(1:nap,:))))/del);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of P for u0 over the passband
%
del=1e-6;
[P,gradP]=schurOneMAPlattice_frm_halfbandP(w,k0,epsilon0,p0, ...
                                           u0,v0,Mmodel,Dmodel);
Nu=length(u0);
deluon2=zeros(size(u0));
deluon2(1)=del/2;
approx_gradP=zeros(nplot,Nu);
for l=1:Nu
  % Test gradient of amplitude response with respect to u0 coefficients 
  PP=schurOneMAPlattice_frm_halfbandP(w,k0,epsilon0,p0,...
                                      u0+deluon2,v0,Mmodel,Dmodel);
  PM=schurOneMAPlattice_frm_halfbandP(w,k0,epsilon0,p0,...
                                      u0-deluon2,v0,Mmodel,Dmodel);
  approx_gradP(:,l)=(PP-PM)/del;
  deluon2=shift(deluon2,1);
endfor
diff_gradP=gradP(:,(Nk+1):(Nk+Nu))-approx_gradP;
% Passband
if verbose
  printf("max(max(abs(diff_gradP(1:nap,:))))=%g*del\n", ...
         max(max(abs(diff_gradP(1:nap,:))))/del);
endif
if max(max(abs(diff_gradP(1:nap,:)))) > del/7317.4;
  error("max(max(abs(diff_gradP(1:nap,:))))(%g*del) > del/7317.4", ...
        max(max(abs(diff_gradP(1:nap,:))))/del);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of P for v0 over the passband
%
del=1e-6;
[P,gradP]=schurOneMAPlattice_frm_halfbandP(w,k0,epsilon0,p0, ...
                                           u0,v0,Mmodel,Dmodel);
Nv=length(v0);
delvon2=zeros(size(v0));
delvon2(1)=del/2;
approx_gradP=zeros(nplot,Nv);
for l=1:Nv
  % Test gradient of amplitude response with respect to v0 coefficients 
  PP=schurOneMAPlattice_frm_halfbandP(w,k0,epsilon0,p0,...
                                      u0,v0+delvon2,Mmodel,Dmodel);
  PM=schurOneMAPlattice_frm_halfbandP(w,k0,epsilon0,p0,...
                                      u0,v0-delvon2,Mmodel,Dmodel);
  approx_gradP(:,l)=(PP-PM)/del;
  delvon2=shift(delvon2,1);
endfor
diff_gradP=gradP(:,(Nk+Nu+1):(Nk+Nu+Nv))-approx_gradP;
% Passband
if verbose
  printf("max(max(abs(diff_gradP(1:nap,:))))=%g*del\n", ...
         max(max(abs(diff_gradP(1:nap,:))))/del);
endif
if max(max(abs(diff_gradP(1:nap,:)))) > del/604890;
  error("max(max(abs(diff_gradP(1:nap,:))))(%g*del) > del/604890", ...
        max(max(abs(diff_gradP(1:nap,:))))/del);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Done
%
diary off
movefile schurOneMAPlattice_frm_halfbandP_test.diary.tmp ...
       schurOneMAPlattice_frm_halfbandP_test.diary;
