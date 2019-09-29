% complementaryFIRlatticeT_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("complementaryFIRlatticeT_test.diary");
unlink("complementaryFIRlatticeT_test.diary.tmp");
diary complementaryFIRlatticeT_test.diary.tmp

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
[H,wplot]=grpdelay(b,1,nplot);
[T,gradT]=complementaryFIRlatticeT(wplot,k,khat);
tol=25*eps;
if max(abs(H(ntpl:ntph)-T(ntpl:ntph))) > tol
  error("max(abs(H(ntpl:ntph)-T(ntpl:ntph)))(%g*eps) > %g*eps", ...
        max(abs(H(ntpl:ntph)-T(ntpl:ntph)))/eps,tol/eps);
endif

% Check the gradients of the squared-magnitude wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
diff_Tk=zeros(1,Nk);
wtpl=wplot(ntpl);
for l=1:Nk
  TkPdel2=complementaryFIRlatticeT(wtpl,k+delk,khat);
  TkMdel2=complementaryFIRlatticeT(wtpl,k-delk,khat);
  delk=shift(delk,1);
  diff_Tk(l)=(TkPdel2-TkMdel2)/del;
endfor
if max(abs(diff_Tk-gradT(ntpl,1:Nk))) > del/280
  error("max(abs(diff_Tk-gradT(ntpl,1:Nk))) > del/280");
endif

% Check the gradient of the squared-magnitude response wrt khat
del=1e-6;
delkhat=zeros(size(khat));
delkhat(1)=del/2;
diff_Tkhat=zeros(1,Nk);
for l=1:Nk
  TkhatPdel2=complementaryFIRlatticeT(wtpl,k,khat+delkhat);
  TkhatMdel2=complementaryFIRlatticeT(wtpl,k,khat-delkhat);
  delkhat=shift(delkhat,1);
  diff_Tkhat(l)=(TkhatPdel2-TkhatMdel2)/del;
endfor
if max(abs(diff_Tkhat-gradT(ntpl,(Nk+1):(2*Nk)))) > del/400
  error("max(abs(diff_Tkhat-gradT(ntpl,(Nk+1):(2*Nk)))) > del/400");
endif

% Done
diary off
movefile complementaryFIRlatticeT_test.diary.tmp ...
         complementaryFIRlatticeT_test.diary;
