% complementaryFIRlatticeAsq_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("complementaryFIRlatticeAsq_test.diary");
unlink("complementaryFIRlatticeAsq_test.diary.tmp");
diary complementaryFIRlatticeAsq_test.diary.tmp

% Bandpass minimum-phase filter specification
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
[Asq,gradAsq]=complementaryFIRlatticeAsq(wplot,k,khat);
tol=20*eps;
if max(abs((abs(H).^2)-Asq)) > tol
  error("max(abs((abs(H).^2)-Asq))(%g*eps) > %g*eps", ...
        max(abs((abs(H).^2)-Asq))/eps,tol/eps);
endif

% Check the gradients of the squared-magnitude wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
ntpl=200;
wtpl=wplot(ntpl);
diff_Asqk=zeros(1,Nk);
for l=1:Nk
  AsqkPdel2=complementaryFIRlatticeAsq(wtpl,k+delk,khat);
  AsqkMdel2=complementaryFIRlatticeAsq(wtpl,k-delk,khat);
  delk=shift(delk,1);
  diff_Asqk(l)=(AsqkPdel2-AsqkMdel2)/del;
endfor
if max(abs(diff_Asqk-gradAsq(ntpl,1:Nk))) > del/1993
  error("max(abs(diff_Asqk-gradAsq(ntpl,1:Nk))) > del/1993");
endif

% Check the gradient of the squared-magnitude response wrt khat
del=1e-6;
delkhat=zeros(size(khat));
delkhat(1)=del/2;
diff_Asqkhat=zeros(1,Nk);
for l=1:Nk
  AsqkhatPdel2=complementaryFIRlatticeAsq(wtpl,k,khat+delkhat);
  AsqkhatMdel2=complementaryFIRlatticeAsq(wtpl,k,khat-delkhat);
  delkhat=shift(delkhat,1);
  diff_Asqkhat(l)=(AsqkhatPdel2-AsqkhatMdel2)/del;
endfor
if max(abs(diff_Asqkhat-gradAsq(ntpl,(Nk+1):(2*Nk)))) > del/2230
  error("max(abs(diff_Asqkhat-gradAsq(ntpl,(Nk+1):(2*Nk)))) > del/2230");
endif

% Done
diary off
movefile complementaryFIRlatticeAsq_test.diary.tmp ...
         complementaryFIRlatticeAsq_test.diary;
