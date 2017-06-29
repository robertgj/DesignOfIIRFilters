% complementaryFIRlatticeP_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("complementaryFIRlatticeP_test.diary");
unlink("complementaryFIRlatticeP_test.diary.tmp");
diary complementaryFIRlatticeP_test.diary.tmp

tic;
verbose=true;

% Bandpass minimum-phase filter specification
ftpl=0.1;
ftph=0.2;
nplot=1024;
ntpl=floor(nplot*ftpl/0.5)+1;
ntph=ceil(nplot*ftph/0.5)+1;
Ud1=2;Vd1=0;Md1=14;Qd1=0;Rd1=1;
d1 = [   0.0920209477, ...
         0.9990000000,   0.5128855702, ...
         0.7102414018,   0.9990000000,   0.9990000000,   0.9990000000, ... 
         0.9990000000,   0.9990000000,   0.9990000000, ...
        -0.9667931503,   0.2680255295,   2.2176753593,   3.3280228348, ... 
         3.7000375301,   4.4072989555,   4.6685041037 ]';
[b1,~]=x2tf(d1,Ud1,Vd1,Md1,Qd1,Rd1);
% Find lattice coefficients (b1 is scaled to |H|<=1 and returned as b)
[b,bc,k,khat]=complementaryFIRlattice(b1(:));
Nk=length(k);

% Check the magnitude-squared response
nplot=1024;
[H,wplot]=freqz(b,1,nplot);
[P,gradP]=complementaryFIRlatticeP(wplot,k,khat);
tol=10*eps;
if max(abs(arg(H(ntpl:ntph))-P(ntpl:ntph))) > tol
  error("max(abs(arg(H(ntpl:ntph))-P(ntpl:ntph))) > %g*eps", ...
        max(abs(arg(H(ntpl:ntph))-P(ntpl:ntph))),tol/eps);
endif

% Check the gradients of the squared-magnitude wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
diff_Pk=zeros(1,Nk);
wtpl=wplot(ntpl);
for l=1:Nk
  PkPdel2=complementaryFIRlatticeP(wtpl,k+delk,khat);
  PkMdel2=complementaryFIRlatticeP(wtpl,k-delk,khat);
  delk=shift(delk,1);
  diff_Pk(l)=(PkPdel2-PkMdel2)/del;
endfor
if max(abs(diff_Pk-gradP(ntpl,1:Nk))) > del/3447
  error("max(abs(diff_Pk-gradP(ntpl,1:Nk))) > del/3447");
endif

% Check the gradient of the squared-magnitude response wrt khat
del=1e-6;
delkhat=zeros(size(khat));
delkhat(1)=del/2;
diff_Pkhat=zeros(1,Nk);
for l=1:Nk
  PkhatPdel2=complementaryFIRlatticeP(wtpl,k,khat+delkhat);
  PkhatMdel2=complementaryFIRlatticeP(wtpl,k,khat-delkhat);
  delkhat=shift(delkhat,1);
  diff_Pkhat(l)=(PkhatPdel2-PkhatMdel2)/del;
endfor
if max(abs(diff_Pkhat-gradP(ntpl,(Nk+1):(2*Nk)))) > del/2619
  error("max(abs(diff_Pkhat-gradP(ntpl,(Nk+1):(2*Nk)))) > del/2619");
endif

% Done
toc;
diary off
movefile complementaryFIRlatticeP_test.diary.tmp ...
         complementaryFIRlatticeP_test.diary;
