% schurOneMAPlatticeDoublyPipelined2H_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMAPlatticeDoublyPipelined2H";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=true;

% Low pass filter
norder=9;
fpass=0.125;
[n,d]=butter(norder,2*fpass);
nplot=1000;
npass=floor(nplot*fpass/0.5)+1;
[h,wplot]=freqz(n,d,nplot);
% Alternative calculation
[Aap1,Aap2]=tf2pa(n,d);
hAap1=freqz(fliplr(Aap1),Aap1,nplot);
hAap2=freqz(fliplr(Aap2),Aap2,nplot);
hAap12=(hAap1+hAap2)/2;

% Lattice decomposition
[A1k,~,~,~] = tf2schurOneMlattice(fliplr(Aap1),Aap1);
[A2k,~,~,~] = tf2schurOneMlattice(fliplr(Aap2),Aap2);

% Doubly pipelined state variable form where the Schur one-multiplier
% lattice has z^-1 replaced by z^-2 with an extra z^-2 delay. In other
% words, the response of the doubly pipelined filter is scaled by two
% in frequency.
[A1A,A1B,A1Cap,A1Dap,~,A1dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
[A2A,A2B,A2Cap,A2Dap,~,A2dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A2k);
A1H=schurOneMAPlatticeDoublyPipelined2H(wplot/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
A2H=schurOneMAPlatticeDoublyPipelined2H(wplot/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
A12H=(A1H+A2H)/2;

% Adjust for the extra z^-2 delay in the doubly pipelined implementation
A12H=A12H.*exp(j*wplot);

% Check the response
if max(abs(hAap12-A12H)) > 100*eps
  error("max(abs(hAap12-A12H)) > 100*eps");
endif

% Check the gradient of A1H wrt w
[A1A,A1B,A1Cap,A1Dap,~,A1dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
[~,A1dHdw]= ...
  schurOneMAPlatticeDoublyPipelined2H(wplot/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
delw=1e-6;
wpass=wplot(npass);
diff_A1Hw=0;
A1HwPdelw2= ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2+delw/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
A1HwMdelw2= ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2-delw/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
diff_A1Hw=(A1HwPdelw2-A1HwMdelw2)/delw;
if abs(diff_A1Hw-A1dHdw(npass)) > delw/100
  error("abs(diff_A1Hw-A1dHdw(npass)) > delw/100");
endif

% Check the gradient of A2H wrt w
[A2A,A2B,A2Cap,A2Dap,~,A2dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A2k);
[~,A2dHdw]= ...
  schurOneMAPlatticeDoublyPipelined2H(wplot/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
delw=1e-6;
wpass=wplot(npass);
diff_A2Hw=0;
A2HwPdelw2= ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2+delw/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
A2HwMdelw2= ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2-delw/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
diff_A2Hw=(A2HwPdelw2-A2HwMdelw2)/delw;
if abs(diff_A2Hw-A2dHdw(npass)) > delw/100
  error("abs(diff_A2Hw-A2dHdw(npass)) > delw/100");
endif

% Check the gradients of A1H wrt A1k
[A1A,A1B,A1Cap,A1Dap,~,A1dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
[~,~,A1dHdk]= ...
  schurOneMAPlatticeDoublyPipelined2H(wplot/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
del=1e-6;
delA1k=zeros(size(A1k));
delA1k(1)=del/2;
wpass=wplot(npass);
diff_A1Hk=zeros(size(A1k));
for l=1:length(A1k)
  [A1A,A1B,A1Cap,A1Dap,~,A1dAdk]= ...
      schurOneMAPlatticeDoublyPipelined2Abcd(A1k+delA1k);
  A1HkPdel2= ...
    schurOneMAPlatticeDoublyPipelined2H(wpass/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  [A1A,A1B,A1Cap,A1Dap,~,A1dAdk]= ...
      schurOneMAPlatticeDoublyPipelined2Abcd(A1k-delA1k);
  A1HkMdel2= ...
    schurOneMAPlatticeDoublyPipelined2H(wpass/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  diff_A1Hk(l)=(A1HkPdel2-A1HkMdel2)/del;
  delA1k=circshift(delA1k,1);
endfor
if max(abs(diff_A1Hk-A1dHdk(npass,1:length(A1k)))) > del/100
  error("max(abs(diff_A1Hk-A1dHdk(npass,))) > del/100");
endif

% Check the gradients of A2H wrt A2k
[A2A,A2B,A2Cap,A2Dap,~,A2dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A2k);
[~,~,A2dHdk]= ...
  schurOneMAPlatticeDoublyPipelined2H(wplot/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
del=1e-6;
delA2k=zeros(size(A2k));
delA2k(1)=del/2;
wpass=wplot(npass);
diff_A2Hk=zeros(size(A2k));
for l=1:length(A2k)
  [A2A,A2B,A2Cap,A2Dap,~,A2dAdk]= ...
      schurOneMAPlatticeDoublyPipelined2Abcd(A2k+delA2k);
  A2HkPdel2= ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
  [A2A,A2B,A2Cap,A2Dap,~,A2dAdk]= ...
      schurOneMAPlatticeDoublyPipelined2Abcd(A2k-delA2k);
  A2HkMdel2= ...
    schurOneMAPlatticeDoublyPipelined2H(wpass/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
  diff_A2Hk(l)=(A2HkPdel2-A2HkMdel2)/del;
  delA2k=circshift(delA2k,1);
endfor
if max(abs(diff_A2Hk-A2dHdk(npass,1:length(A2k)))) > del/100
  error("max(abs(diff_A2Hk-A2dHdk(npass,))) > del/100");
endif

% Check the gradient of A1H wrt w and A1k
[A1A,A1B,A1Cap,A1Dap,~,A1dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
[~,~,~,A1d2Hdwdk] = ...
  schurOneMAPlatticeDoublyPipelined2H(wplot/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
delw=1e-6;
wpass=wplot(npass);
diff_A1Hwk=zeros(1,columns(A1dHdk));
[~,~,A1dHwPdk] = ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2+delw/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
[~,~,A1dHwMdk] = ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2-delw/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
diff_A1Hwk=(A1dHwPdk-A1dHwMdk)/del;
if max(abs(diff_A1Hwk-A1d2Hdwdk(npass,:))) > del/10
  error("max(abs(diff_A1Hwk-A1d2Hdwdk(npass,))) > del/10");
endif

% Check the gradient of A2H wrt w and A2k
[A2A,A2B,A2Cap,A2Dap,~,A2dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A2k);
[~,~,~,A2d2Hdwdk] = ...
  schurOneMAPlatticeDoublyPipelined2H(wplot/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
delw=1e-6;
wpass=wplot(npass);
diff_A2Hwk=zeros(1,columns(A2dHdk));
[~,~,A2dHwPdk] = ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2+delw/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
[~,~,A2dHwMdk] = ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2-delw/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
diff_A2Hwk=(A2dHwPdk-A2dHwMdk)/del;
if max(abs(diff_A2Hwk-A2d2Hdwdk(npass,:))) > del
  error("max(abs(diff_A2Hwk-A2d2Hdwdk(npass,))) > del");
endif

% Check the diagonal of the Hessian of A1H wrt A1k
[A1A,A1B,A1Cap,A1Dap,~,A1dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
[~,~,~,~,A1diagd2Hdk2]=...
  schurOneMAPlatticeDoublyPipelined2H(wplot/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
del=1e-6;
delA1k=zeros(size(A1k));
delA1k(1)=del/2;
wpass=wplot(npass);
diff_dA1Hdk=zeros(size(A1k));
for l=1:length(A1k)
  [A1A,A1B,A1Cap,A1Dap,~,A1dAdk]= ...
    schurOneMAPlatticeDoublyPipelined2Abcd(A1k+delA1k);
  [~,~,A1dHdkP]=...
    schurOneMAPlatticeDoublyPipelined2H(wpass/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  [A1A,A1B,A1Cap,A1Dap,~,A1dAdk]= ...
    schurOneMAPlatticeDoublyPipelined2Abcd(A1k-delA1k);
  [~,~,A1dHdkM]=...
    schurOneMAPlatticeDoublyPipelined2H(wpass/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  diff_A1dHdk(l)=(A1dHdkP(l)-A1dHdkM(l))/del;
  delA1k=circshift(delA1k,1);
endfor
if max(abs(diff_A1dHdk-A1diagd2Hdk2(npass,1:length(A1k)))) > del/10
  error("max(abs(diff_A1dHdk-A1diagd2Hdk2(npass,))) > del/10");
endif

% Check the diagonal of the Hessian of A2H wrt A2k
[A2A,A2B,A2Cap,A2Dap,~,A2dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A2k);
[~,~,~,~,A2diagd2Hdk2]=...
  schurOneMAPlatticeDoublyPipelined2H(wplot/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
del=1e-6;
delA2k=zeros(size(A2k));
delA2k(1)=del/2;
wpass=wplot(npass);
diff_dA2Hdk=zeros(size(A2k));
for l=1:length(A2k)
  [A2A,A2B,A2Cap,A2Dap,~,A2dAdk]= ...
    schurOneMAPlatticeDoublyPipelined2Abcd(A2k+delA2k);
  [~,~,A2dHdkP]=...
    schurOneMAPlatticeDoublyPipelined2H(wpass/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
  [A2A,A2B,A2Cap,A2Dap,~,A2dAdk]= ...
    schurOneMAPlatticeDoublyPipelined2Abcd(A2k-delA2k);
  [~,~,A2dHdkM]=...
    schurOneMAPlatticeDoublyPipelined2H(wpass/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
  diff_A2dHdk(l)=(A2dHdkP(l)-A2dHdkM(l))/del;
  delA2k=circshift(delA2k,1);
endfor
if max(abs(diff_A2dHdk-A2diagd2Hdk2(npass,1:length(A2k)))) > del
  error("max(abs(diff_A2dHdk-A2diagd2Hdk2(npass,))) > del");
endif

% Check the diagonal of the Hessian of A1H wrt w and A1k
[A1A,A1B,A1Cap,A1Dap,~,A1dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
[~,~,~,~,~,A1diagd3Hdwdk2]=...
  schurOneMAPlatticeDoublyPipelined2H(wplot/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
delw=1e-6;
wpass=wplot(npass);
diff_A1diagd2Hdk2=zeros(1,columns(A1diagd2Hdk2));
[~,~,~,~,A1diagd2Hdk2P] = ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2+delw/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
[~,~,~,~,A1diagd2Hdk2M] = ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2-delw/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
diff_A1diagd2Hdk2=(A1diagd2Hdk2P-A1diagd2Hdk2M)/delw;
if max(abs(diff_A1diagd2Hdk2-A1diagd3Hdwdk2(npass,:))) > delw
  error("max(abs(diff_A1diagd2Hdk2-A1diagd3Hdwdk2(npass,))) > delw");
endif

% Check the diagonal of the Hessian of A2H wrt w and A2k
[A2A,A2B,A2Cap,A2Dap,~,A2dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A2k);
[~,~,~,~,~,A2diagd3Hdwdk2]=...
  schurOneMAPlatticeDoublyPipelined2H(wplot/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
delw=1e-6;
wpass=wplot(npass);
diff_A2diagd2Hdk2=zeros(1,columns(A2diagd2Hdk2));
[~,~,~,~,A2diagd2Hdk2P] = ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2+delw/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
[~,~,~,~,A2diagd2Hdk2M] = ...
  schurOneMAPlatticeDoublyPipelined2H(wpass/2-delw/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
diff_A2diagd2Hdk2=(A2diagd2Hdk2P-A2diagd2Hdk2M)/delw;
if max(abs(diff_A2diagd2Hdk2-A2diagd3Hdwdk2(npass,:))) > 20*delw
  error("max(abs(diff_A2diagd2Hdk2-A2diagd3Hdwdk2(npass,))) > 20*delw");
endif

% Check the Hessian of A1H wrt A1k
[A1A,A1B,A1Cap,A1Dap,~,A1dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
[~,~,~,~,~,~,A1d2Hdk2]=...
  schurOneMAPlatticeDoublyPipelined2H(wplot/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
del=1e-6;
delA1k=zeros(size(A1k));
delA1k(1)=del/2;
wpass=wplot(npass);
diff_dA1Hdk=zeros(length(A1k),length(A1k));
for l=1:length(A1k)
  [A1A,A1B,A1Cap,A1Dap,~,A1dAdk]= ...
      schurOneMAPlatticeDoublyPipelined2Abcd(A1k+delA1k);
  [~,~,A1dHdkP]=...
    schurOneMAPlatticeDoublyPipelined2H(wpass/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  
  [A1A,A1B,A1Cap,A1Dap,~,A1dAdk]= ...
    schurOneMAPlatticeDoublyPipelined2Abcd(A1k-delA1k);
  [~,~,A1dHdkM]=...
    schurOneMAPlatticeDoublyPipelined2H(wpass/2,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  
  diff_A1dHdk(l,:)=(A1dHdkP-A1dHdkM)/del;
  delA1k=circshift(delA1k,1);
endfor
if max(max(abs(diff_A1dHdk-squeeze(A1d2Hdk2(npass,:,:))))) > del/10
  error("max(max(abs(diff_A1dHdk-squeeze(A1d2Hdk2(npass,,)))))) > del/10");
endif
if max(abs(A1diagd2Hdk2(npass,:) - ...
           transpose(diag(squeeze(A1d2Hdk2(npass,:,:)))))) > eps
  error(["max(abs(A1diagd2Hdk2(npass,:) - ...\n", ...
 "           transpose(diag(squeeze(A1d2Hdk2(npass,,)))))) > eps"]);
endif

% Check the Hessian of A2H wrt A2k
[A2A,A2B,A2Cap,A2Dap,~,A2dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A2k);
[~,~,~,~,~,~,A2d2Hdk2]=...
  schurOneMAPlatticeDoublyPipelined2H(wplot/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
del=1e-6;
delA2k=zeros(size(A2k));
delA2k(1)=del/2;
wpass=wplot(npass);
diff_dA2Hdk=zeros(length(A2k),length(A2k));
for l=1:length(A2k)
  [A2A,A2B,A2Cap,A2Dap,~,A2dAdk]= ...
      schurOneMAPlatticeDoublyPipelined2Abcd(A2k+delA2k);
  [~,~,A2dHdkP]=...
    schurOneMAPlatticeDoublyPipelined2H(wpass/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
  
  [A2A,A2B,A2Cap,A2Dap,~,A2dAdk]= ...
    schurOneMAPlatticeDoublyPipelined2Abcd(A2k-delA2k);
  [~,~,A2dHdkM]=...
    schurOneMAPlatticeDoublyPipelined2H(wpass/2,A2A,A2B,A2Cap,A2Dap,A2dAdk);
  
  diff_A2dHdk(l,:)=(A2dHdkP-A2dHdkM)/del;
  delA2k=circshift(delA2k,1);
endfor
if max(max(abs(diff_A2dHdk-squeeze(A2d2Hdk2(npass,:,:))))) > del
  error("max(max(abs(diff_A2dHdk-squeeze(A2d2Hdk2(npass,,)))))) > del");
endif
if max(abs(A2diagd2Hdk2(npass,:) - ...
           transpose(diag(squeeze(A2d2Hdk2(npass,:,:)))))) > eps
  error(["max(abs(A2diagd2Hdk2(npass,:) - ...\n", ...
 "           transpose(diag(squeeze(A2d2Hdk2(npass,,)))))) > eps"]);
endif
                                                                  
% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
