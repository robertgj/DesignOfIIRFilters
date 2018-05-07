% schurOneMlattice2H_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("schurOneMlattice2H_test.diary");
unlink("schurOneMlattice2H_test.diary.tmp");
diary schurOneMlattice2H_test.diary.tmp

clear schurOneMlattice2H

format long e
tic;

verbose=true;

% R=2 bandpass filter
fapl=0.1;fapu=0.2;fasl=0.05;ftpl=0.09;ftpu=0.21;
n = [   0.0127469845,   0.0032780608,   0.0285568297,   0.0217618336, ... 
        0.0543730436,   0.0291811860,   0.0325479489,  -0.0069026091, ... 
       -0.0040414137,  -0.0430974012,  -0.0720651216,  -0.1000828758, ... 
       -0.0551462733,   0.0517204345,   0.1392956867,   0.1495935341, ... 
        0.0498555510,  -0.0445198094,  -0.1009805373,  -0.0681447152, ... 
       -0.0338056405 ]';
d = [   1.0000000000,   0.0000000000,   1.8632536514,   0.0000000000, ... 
        2.2039281157,   0.0000000000,   2.2677909197,   0.0000000000, ... 
        2.0451496224,   0.0000000000,   1.5409563677,   0.0000000000, ... 
        1.0011650113,   0.0000000000,   0.5514123431,   0.0000000000, ... 
        0.2533493166,   0.0000000000,   0.0849599294,   0.0000000000, ... 
        0.0186365784 ]';
nplot=1024;
ntpl=floor(nplot*ftpl/0.5);
ntpu=ceil(nplot*ftpu/0.5);
[h,wplot]=freqz(n,d,nplot);
hap=freqz(flipud(d(:)),d(:),nplot);

% Convert filter transfer function to Schur 1-multiplier lattice form
[k,epsilon,p,c]=tf2schurOneMlattice(n,d);
Nk=length(k);
Nc=length(c);
Nkc=Nk+Nc;
[A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c);
H=schurOneMlattice2H(wplot,A,B,C,D);
% Check the magnitude-squared response
if max(abs(h-H))/eps > 23.39
  error("max(abs(h-H))/eps > 23.39");
endif
Hap=schurOneMlattice2H(wplot,A,B,Cap,Dap);
% Check the magnitude-squared response of the allpass filter
if max(abs(hap-Hap))/eps > 54.7
  error("max(abs(hap-Hap))/eps > 54.7");
endif

% Check the gradient of H wrt w
[A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc]=schurOneMlattice2Abcd(k,epsilon,p,c);
[H,dHdw]=schurOneMlattice2H(wplot,A,B,C,D);
delw=1e-6;
wtpl=wplot(ntpl);
diff_Hw=0;
HwPdelw2=schurOneMlattice2H(wtpl+delw/2,A,B,C,D);
HwMdelw2=schurOneMlattice2H(wtpl-delw/2,A,B,C,D);
diff_Hw=(HwPdelw2-HwMdelw2)/delw;
rel_diff_Hw=(diff_Hw-dHdw(ntpl))/dHdw(ntpl);
if abs(rel_diff_Hw) > delw/6676.5
  error("abs(rel_diff_Hw) > delw/6676.5");
endif

% Check the gradients of H wrt k
[A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc]=schurOneMlattice2Abcd(k,epsilon,p,c);
[H,dHdw,dHdkc]=schurOneMlattice2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_Hk=zeros(size(k));
for l=1:Nk
  [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc] = ...
    schurOneMlattice2Abcd(k+delk,epsilon,p,c);
  HkPdel2=schurOneMlattice2H(wtpl,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc] = ...
    schurOneMlattice2Abcd(k-delk,epsilon,p,c);
  HkMdel2=schurOneMlattice2H(wtpl,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  delk=shift(delk,1);
  diff_Hk(l)=(HkPdel2-HkMdel2)/del;
endfor
rel_diff_Hk=(diff_Hk-dHdkc(ntpl,1:Nk))./dHdkc(ntpl,1:Nk);
if max(abs(rel_diff_Hk)) > del/154.9
  error("max(abs(rel_diff_Hk)) > del/154.9");
endif

% Check the gradient of H wrt c
del=1e-6;
delc=zeros(size(c));
delc(1)=del/2;
wtpl=wplot(ntpl);
diff_Hc=zeros(size(c));
for l=1:Nc
  [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc] = ...
    schurOneMlattice2Abcd(k,epsilon,p,c+delc);
  HcPdel2=schurOneMlattice2H(wtpl,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc] = ...
    schurOneMlattice2Abcd(k,epsilon,p,c-delc);
  HcMdel2=schurOneMlattice2H(wtpl,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  delc=shift(delc,1);
  diff_Hc(l)=(HcPdel2-HcMdel2)/del;
endfor
rel_diff_Hc=(diff_Hc-dHdkc(ntpl,(Nk+1):end))./dHdkc(ntpl,(Nk+1):end);
if max(abs(rel_diff_Hc)) > del/2556.4
  error("max(abs(rel_diff_Hc)) > del/2556.4");
endif

% Check the gradient of H wrt w and k and c
[A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc]=schurOneMlattice2Abcd(k,epsilon,p,c);
[H,dHdw,dHdkc,d2Hdwdkc]=schurOneMlattice2H(wplot,A,B,C,D, ...
                                           dAdkc,dBdkc,dCdkc,dDdkc);
delw=1e-6;
wtpl=wplot(ntpl);
diff_Hwkc=zeros(1,columns(dHdkc));
[HwPdelw2,dHwPdw,dHwPdkc]=schurOneMlattice2H(wtpl+delw/2,A,B,C,D, ...
                                             dAdkc,dBdkc,dCdkc,dDdkc);
[HwMdelw2,dHwMdw,dHwMdkc]=schurOneMlattice2H(wtpl-delw/2,A,B,C,D, ...
                                             dAdkc,dBdkc,dCdkc,dDdkc);
diff_Hwkc=(dHwPdkc-dHwMdkc)/delw;
if diff_Hwkc(end) > eps
  error("diff_Hwkc(end) > eps");
endif
rel_diff_Hwkc=(diff_Hwkc(1:(Nkc-1))-d2Hdwdkc(ntpl,1:(Nkc-1))) ...
              ./d2Hdwdkc(ntpl,(1:Nkc-1));
if max(abs(rel_diff_Hwkc)) > delw/534
  error("max(abs(rel_diff_Hwkc)) > delw/534");
endif

% Check the diagonal of the Hessian of H wrt k
[H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2]=schurOneMlattice2H(wplot,A,B,C,D, ...
                                                       dAdkc,dBdkc,dCdkc,dDdkc);
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_dHdkc=zeros(1,Nk);
for l=1:Nk
  [AkP,BkP,CkP,DkP,CapkP,DapkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
    schurOneMlattice2Abcd(k+delk,epsilon,p,c);
  [HkP,dHdwP,dHdkcP]=schurOneMlattice2H(wtpl,AkP,BkP,CkP,DkP, ...
                                        dAdkcP,dBdkcP,dCdkcP,dDdkcP);
  [AkM,BkM,CkM,DkM,CapkM,DapkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
    schurOneMlattice2Abcd(k-delk,epsilon,p,c);
  [HkM,dHdwM,dHdkcM]=schurOneMlattice2H(wtpl,AkM,BkM,CkM,DkM, ...
                                        dAdkcM,dBdkcM,dCdkcM,dDdkcM);
  diff_dHdkc(l)=(dHdkcP(l)-dHdkcM(l))/del;
  delk=shift(delk,1);
endfor
rel_diff_dHdkc=(diff_dHdkc-diagd2Hdkc2(ntpl,1:Nk))./diagd2Hdkc2(ntpl,1:Nk);
if max(abs(rel_diff_dHdkc)) > del/55.6
  error("max(abs(rel_diff_dHdkc)) > del/55.6");
endif

% Check the diagonal of the Hessian of H wrt c
del=1e-6;
delc=zeros(size(c));
delc(1)=del/2;
wtpl=wplot(ntpl);
diff_dHdc=zeros(1,Nc);
for l=1:Nc
  [AcP,BcP,CcP,DcP,CapcP,DapcP,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
    schurOneMlattice2Abcd(k,epsilon,p,c+delc);
  [HcP,dHdwP,dHdkcP]=schurOneMlattice2H(wtpl,AcP,BcP,CcP,DcP, ...
                                        dAdkcP,dBdkcP,dCdkcP,dDdkcP);
  [AcM,BcM,CcM,DcM,CapcM,DapcM,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
    schurOneMlattice2Abcd(k,epsilon,p,c-delc);
  [HcM,dHdwM,dHdkcM]=schurOneMlattice2H(wtpl,AcM,BcM,CcM,DcM, ...
                                        dAdkcM,dBdkcM,dCdkcM,dDdkcM);
  diff_dHdc(l)=(dHdkcP(Nk+l)-dHdkcM(Nk+l))/del;
  delc=shift(delc,1);
endfor
if max(abs(diagd2Hdkc2(ntpl,(Nk+1):end))) > eps
  error("max(abs(diagd2Hdkc2(ntpl,(Nk+1):end))) > eps");
endif
if max(abs(diff_dHdc)) > eps
  error("max(abs(diff_dHdc)) > eps");
endif

% Check the diagonal of the second partial derivative of dHdw wrt k and c
[H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2] = ...
  schurOneMlattice2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
wtpl=wplot(ntpl);
diff_d2Hdwdkc=zeros(1,columns(d2Hdwdkc));
for l=1:Nk
  [AkP,BkP,CkP,DkP,CapkP,DapkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
    schurOneMlattice2Abcd(k+delk,epsilon,p,c);
  [HkP,dHdwP,dHdkcP,d2HdwdkcP] = ...
    schurOneMlattice2H(wtpl,AkP,BkP,CkP,DkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP);
  [AkM,BkM,CkM,DkM,CapkM,DapkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
    schurOneMlattice2Abcd(k-delk,epsilon,p,c);
  [HkM,dHdwM,dHdkcM,d2HdwdkcM] = ...
    schurOneMlattice2H(wtpl,AkM,BkM,CkM,DkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM);
  diff_d2Hdwdkc(l)=(d2HdwdkcP(l)-d2HdwdkcM(l))/del;
  delk=shift(delk,1);
endfor
delc=zeros(size(c));
delc(1)=del/2;
for l=1:Nc
  [AkP,BkP,CkP,DkP,CapkP,DapkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
    schurOneMlattice2Abcd(k,epsilon,p,c+delc);
  [HkP,dHdwP,dHdkcP,d2HdwdkcP] = ...
    schurOneMlattice2H(wtpl,AkP,BkP,CkP,DkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP);
  [AkM,BkM,CkM,DkM,CapkM,DapkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
    schurOneMlattice2Abcd(k,epsilon,p,c-delc);
  [HkM,dHdwM,dHdkcM,d2HdwdkcM] = ...
    schurOneMlattice2H(wtpl,AkM,BkM,CkM,DkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM);
  diff_d2Hdwdkc(Nk+l)=(d2HdwdkcP(Nk+l)-d2HdwdkcM(Nk+l))/del;
  delc=shift(delc,1);
endfor
rel_diff_d2Hdwdkc=(diff_d2Hdwdkc-diagd3Hdwdkc2(ntpl,:))./diagd3Hdwdkc2(ntpl,:);
if max(abs(rel_diff_d2Hdwdkc)) > del/30.4
  error("max(abs(rel_diff_d2Hdwdkc)) > del/30.4");
endif

% Check the diagonal of the partial derivative of d2Hdkc2 wrt w
[H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2] = ...
  schurOneMlattice2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
del=1e-6;
delw=del/2;
wtpl=wplot(ntpl);
[HkP,dHdwP,dHdkcP,d2HdwdkcP,diagd2Hdkc2P] = ...
  schurOneMlattice2H(wtpl+delw,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
[HkM,dHdwM,dHdkcM,d2HdwdkcM,diagd2Hdkc2M] = ...
  schurOneMlattice2H(wtpl-delw,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
diff_d2Hdkc2=(diagd2Hdkc2P-diagd2Hdkc2M)/del;
rel_diff_d2Hdkc2=(diff_d2Hdkc2-diagd3Hdwdkc2(ntpl,:))./diagd3Hdwdkc2(ntpl,:);
if max(abs(rel_diff_d2Hdkc2)) > del/792
  error("max(abs(rel_diff_d2Hdkc2)) > del/792");
endif

% Done
toc;
if verbose
endif
diary off
movefile schurOneMlattice2H_test.diary.tmp schurOneMlattice2H_test.diary;
