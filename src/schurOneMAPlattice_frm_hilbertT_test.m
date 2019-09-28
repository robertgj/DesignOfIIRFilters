% schurOneMAPlattice_frm_hilbertT_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("schurOneMAPlattice_frm_hilbertT_test.diary");
unlink("schurOneMAPlattice_frm_hilbertT_test.diary.tmp");
diary schurOneMAPlattice_frm_hilbertT_test.diary.tmp

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

% Calculate Schur one-multiplier lattice FRM Hilbert filter coefficients
rm1=ones(mr+1,1);
rm1(2:2:end)=-1;
[k0,epsilon0,p0,~] = tf2schurOneMlattice(flipud(r0).*rm1,r0.*rm1);

% Find the FRM Hilbert filter FIR masking filter coefficients
dm1=ones((dmask/2)+1,1);
dm1(2:2:end)=-1;
u0=aa0(1:2:dmask+1).*dm1;
v0=aa0(2:2:dmask).*dm1(1:(end-1));

% Frequency vector
nplot=1024;
w=(0:(nplot-1))'*pi/nplot;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check empty frequency
%
[T,gradT] = ...
  schurOneMAPlattice_frm_hilbertT([],k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
if ~isempty(T) || ~isempty(gradT)
  error("~isempty(T) || ~isempty(gradT)");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare T response with freqz
%

% Halfband model filter
r2M0=zeros((2*Mmodel*mr)+1,1);
r2M0(1:(2*Mmodel):end)=r0;

% Halfband polyphase masking filters
au0=zeros(size(aa0));
au0(1:2:end)=aa0(1:2:end);
av0=zeros(size(aa0));
av0(2:2:end)=aa0(2:2:end);
zdmask=[zeros(dmask,1);1;zeros(dmask,1)];
zDM=zeros(Dmodel*Mmodel,1);

% Halfband filter branch denominator polynomial
q0=[conv(flipud(r2M0),(2*au0)-zdmask);zDM]+[zDM;conv(r2M0,2*av0)];

% Convert response to Hilbert with -z^2
r2Mm1=zeros((2*mr*Mmodel)+1,1);
r2Mm1(1:(4*Mmodel):end)=1;
r2Mm1(((2*Mmodel)+1):(4*Mmodel):end)=-1;
qm1=zeros((((2*mr)+Dmodel)*Mmodel)+(2*dmask)+1,1);
qm1(1:4:end)=1;
qm1(3:4:end)=-1;
Tp=grpdelay(q0.*qm1,r2M0.*r2Mm1,((0:(nplot-1))')*pi/nplot);
Tp=Tp(1:length(w));

% Check schurOneMAPlattice_frm_hilbertT
T=schurOneMAPlattice_frm_hilbertT(w,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
if max(abs(T+((Dmodel*Mmodel)+dmask)-Tp)) > 3712*eps
  error("max(abs(T+((Dmodel*Mmodel)+dmask)-Tp))>3712*eps (%d*eps)", ...
        ceil(max(abs(T+((Dmodel*Mmodel)+dmask)-Tp))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of T for k0
%
del=1e-6;
[T,gradT]=schurOneMAPlattice_frm_hilbertT(w,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
Nw=length(w);
Nk=length(k0);
delkon2=zeros(size(k0));
delkon2(1)=del/2;
approx_gradT=zeros(Nw,Nk);
for l=1:Nk
  % Test gradient of amplitude response with respect to k0 coefficients 
  TP=schurOneMAPlattice_frm_hilbertT(w,k0+delkon2,epsilon0,p0,...
                                          u0,v0,Mmodel,Dmodel);
  TM=schurOneMAPlattice_frm_hilbertT(w,k0-delkon2,epsilon0,p0,...
                                          u0,v0,Mmodel,Dmodel);
  approx_gradT(:,l)=(TP-TM)/del;
  delkon2=shift(delkon2,1);
endfor
diff_gradT=gradT(:,1:Nk)-approx_gradT;
max_diff=del/max(max(abs(diff_gradT)));
if verbose
  printf("max(max(abs(diff_gradT)))=del/%g\n",max_diff);
endif
if max(max(abs(diff_gradT))) > del/6.572;
  error("max(max(abs(diff_gradT)))(del/%g) > del/6.572",max_diff);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of T for u0
%
del=1e-6;
[T,gradT]=schurOneMAPlattice_frm_hilbertT(w,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
Nw=length(w);
Nu=length(u0);
deluon2=zeros(size(u0));
deluon2(1)=del/2;
approx_gradT=zeros(Nw,Nu);
for l=1:Nu
  % Test gradient of amplitude response with respect to u0 coefficients 
  TP=schurOneMAPlattice_frm_hilbertT(w,k0,epsilon0,p0,...
                                     u0+deluon2,v0,Mmodel,Dmodel);
  TM=schurOneMAPlattice_frm_hilbertT(w,k0,epsilon0,p0,...
                                     u0-deluon2,v0,Mmodel,Dmodel);
  approx_gradT(:,l)=(TP-TM)/del;
  deluon2=shift(deluon2,1);
endfor
diff_gradT=gradT(:,(Nk+1):(Nk+Nu))-approx_gradT;
max_diff=del/max(max(abs(diff_gradT)));
if verbose
  printf("max(max(abs(diff_gradT)))=del/%g\n",max_diff);
endif
if max(max(abs(diff_gradT))) > del/54.61;
  error("max(max(abs(diff_gradT)))(del/%g) > del/54.61",max_diff);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check gradients of T for v0
%
del=1e-6;
[T,gradT]=schurOneMAPlattice_frm_hilbertT(w,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
Nw=length(w);
Nv=length(v0);
delvon2=zeros(size(v0));
delvon2(1)=del/2;
approx_gradT=zeros(Nw,Nv);
for l=1:Nv
  % Test gradient of amplitude response with respect to v0 coefficients 
  TP=schurOneMAPlattice_frm_hilbertT(w,k0,epsilon0,p0,...
                                     u0,v0+delvon2,Mmodel,Dmodel);
  TM=schurOneMAPlattice_frm_hilbertT(w,k0,epsilon0,p0,...
                                     u0,v0-delvon2,Mmodel,Dmodel);
  approx_gradT(:,l)=(TP-TM)/del;
  delvon2=shift(delvon2,1);
endfor
diff_gradT=gradT(:,(Nk+Nu+1):(Nk+Nu+Nv))-approx_gradT;
% Passband
if verbose
  printf("max(max(abs(diff_gradT)))=del/%g\n",max_diff);
endif
if max(max(abs(diff_gradT))) > del/58.969;
  error("max(max(abs(diff_gradT)))(del/%g) > del/58.969",max_diff);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Done
%
diary off
movefile schurOneMAPlattice_frm_hilbertT_test.diary.tmp ...
       schurOneMAPlattice_frm_hilbertT_test.diary;
