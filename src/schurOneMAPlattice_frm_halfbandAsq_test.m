% schurOneMAPlattice_frm_halfbandAsq_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("schurOneMAPlattice_frm_halfbandAsq_test.diary");
delete("schurOneMAPlattice_frm_halfbandAsq_test.diary.tmp");
diary schurOneMAPlattice_frm_halfbandAsq_test.diary.tmp

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
[Asq,gradAsq] = ...
  schurOneMAPlattice_frm_halfbandAsq([],k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
if ~isempty(Asq) || ~isempty(gradAsq)
  error("~isempty(Asq) || ~isempty(gradAsq)");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare Asq response with freqz
%
Hp=freqz(n0,r2M,w);
Asq=schurOneMAPlattice_frm_halfbandAsq(w,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
Asqp=abs(Hp).^2;
if max(abs(Asq-Asqp)) > 120*eps
  error("max(abs(Asq-Asqp))>120*eps (%d*eps)",ceil(max(abs(Asq-Asqp))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of Asq for k0
%
del=1e-6;
[Asq,gradAsq]=schurOneMAPlattice_frm_halfbandAsq(w,k0,epsilon0,p0, ...
                                                 u0,v0,Mmodel,Dmodel);
Nk=length(k0);
delkon2=zeros(size(k0));
delkon2(1)=del/2;
approx_gradAsq=zeros(nplot,Nk);
for l=1:Nk
  % Test gradient of amplitude response with respect to k0 coefficients 
  AsqP=schurOneMAPlattice_frm_halfbandAsq(w,k0+delkon2,epsilon0,p0,...
                                          u0,v0,Mmodel,Dmodel);
  AsqM=schurOneMAPlattice_frm_halfbandAsq(w,k0-delkon2,epsilon0,p0,...
                                          u0,v0,Mmodel,Dmodel);
  approx_gradAsq(:,l)=(AsqP-AsqM)/del;
  delkon2=shift(delkon2,1);
endfor
diff_gradAsq=gradAsq(:,1:Nk)-approx_gradAsq;
% Passband
if verbose
  printf("max(max(abs(diff_gradAsq(1:nap,:))))=%g*del\n", ...
         max(max(abs(diff_gradAsq(1:nap,:))))/del);
endif
if max(max(abs(diff_gradAsq(1:nap,:)))) > del/3182;
  error("max(max(abs(diff_gradAsq(1:nap,:))))(%g*del) > del/3182", ...
        max(max(abs(diff_gradAsq(1:nap,:))))/del);
endif
% Whole band
if verbose
  printf("max(max(abs(diff_gradAsq)))=%g*del\n",
         max(max(abs(diff_gradAsq)))/del);
endif
if max(max(abs(diff_gradAsq))) > del/188;
  error("max(max(abs(diff_gradAsq)))(%g*del) > del/188",
        max(max(abs(diff_gradAsq)))/del);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of Asq for u0
%
del=1e-6;
[Asq,gradAsq]=schurOneMAPlattice_frm_halfbandAsq(w,k0,epsilon0,p0, ...
                                                 u0,v0,Mmodel,Dmodel);
Nu=length(u0);
deluon2=zeros(size(u0));
deluon2(1)=del/2;
approx_gradAsq=zeros(nplot,Nu);
for l=1:Nu
  % Test gradient of amplitude response with respect to u0 coefficients 
  AsqP=schurOneMAPlattice_frm_halfbandAsq(w,k0,epsilon0,p0,...
                                          u0+deluon2,v0,Mmodel,Dmodel);
  AsqM=schurOneMAPlattice_frm_halfbandAsq(w,k0,epsilon0,p0,...
                                          u0-deluon2,v0,Mmodel,Dmodel);
  approx_gradAsq(:,l)=(AsqP-AsqM)/del;
  deluon2=shift(deluon2,1);
endfor
diff_gradAsq=gradAsq(:,(Nk+1):(Nk+Nu))-approx_gradAsq;
% Passband
if verbose
  printf("max(max(abs(diff_gradAsq(1:nap,:))))=%g*del\n", ...
         max(max(abs(diff_gradAsq(1:nap,:))))/del);
endif
if max(max(abs(diff_gradAsq(1:nap,:)))) > del/2437;
  error("max(max(abs(diff_gradAsq(1:nap,:))))(%g*del) > del/2437", ...
        max(max(abs(diff_gradAsq(1:nap,:))))/del);
endif
% Whole band
if verbose
  printf("max(max(abs(diff_gradAsq)))=%g*del\n",
         max(max(abs(diff_gradAsq)))/del);
endif
if max(max(abs(diff_gradAsq))) > del/2437;
  error("max(max(abs(diff_gradAsq)))(%g*del) > del/2437",
        max(max(abs(diff_gradAsq)))/del);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of Asq for v0
%
del=1e-6;
[Asq,gradAsq]=schurOneMAPlattice_frm_halfbandAsq(w,k0,epsilon0,p0, ...
                                                 u0,v0,Mmodel,Dmodel);
Nv=length(v0);
delvon2=zeros(size(v0));
delvon2(1)=del/2;
approx_gradAsq=zeros(nplot,Nv);
for l=1:Nv
  % Test gradient of amplitude response with respect to v0 coefficients 
  AsqP=schurOneMAPlattice_frm_halfbandAsq(w,k0,epsilon0,p0,...
                                          u0,v0+delvon2,Mmodel,Dmodel);
  AsqM=schurOneMAPlattice_frm_halfbandAsq(w,k0,epsilon0,p0,...
                                          u0,v0-delvon2,Mmodel,Dmodel);
  approx_gradAsq(:,l)=(AsqP-AsqM)/del;
  delvon2=shift(delvon2,1);
endfor
diff_gradAsq=gradAsq(:,(Nk+Nu+1):(Nk+Nu+Nv))-approx_gradAsq;
% Passband
if verbose
  printf("max(max(abs(diff_gradAsq(1:nap,:))))=%g*del\n", ...
         max(max(abs(diff_gradAsq(1:nap,:))))/del);
endif
if max(max(abs(diff_gradAsq(1:nap,:)))) > del/1273;
  error("max(max(abs(diff_gradAsq(1:nap,:))))(%g*del) > del/1273", ...
        max(max(abs(diff_gradAsq(1:nap,:))))/del);
endif
% Whole band
if verbose
  printf("max(max(abs(diff_gradAsq)))=%g*del\n",
         max(max(abs(diff_gradAsq)))/del);
endif
if max(max(abs(diff_gradAsq))) > del/1273;
  error("max(max(abs(diff_gradAsq)))(%g*del) > del/1273",
        max(max(abs(diff_gradAsq)))/del);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Done
%
diary off
movefile schurOneMAPlattice_frm_halfbandAsq_test.diary.tmp ...
       schurOneMAPlattice_frm_halfbandAsq_test.diary;
