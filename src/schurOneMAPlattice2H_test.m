% schurOneMAPlattice2H_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("schurOneMAPlattice2H_test.diary");
delete("schurOneMAPlattice2H_test.diary.tmp");
diary schurOneMAPlattice2H_test.diary.tmp

check_octave_file("schurOneMAPlattice2H");

verbose=true;

% Low pass filter
norder=5;
fpass=0.125;
[n,d]=butter(norder,2*fpass);
nplot=1024;
npass=floor(nplot*fpass/0.5);
[h,wplot]=freqz(n,d,nplot);
% Alternative calculation
[Aap1,Aap2]=tf2pa(n,d);
hAap1=freqz(fliplr(Aap1),Aap1,nplot);
hAap2=freqz(fliplr(Aap2),Aap2,nplot);
hAap12=(hAap1+hAap2)/2;

% Lattice decomposition
[A1k,A1epsilon,A1p,A1c] = tf2schurOneMlattice(fliplr(Aap1),Aap1);
[A2k,A2epsilon,A2p,A2c] = tf2schurOneMlattice(fliplr(Aap2),Aap2);

% State variable form
[A1A,A1B,A1C,A1D,A1Cap,A1Dap]=schurOneMlattice2Abcd(A1k,A1epsilon,A1p,A1c);
[A2A,A2B,A2C,A2D,A2Cap,A2Dap]=schurOneMlattice2Abcd(A2k,A2epsilon,A2p,A2c);
A1H=schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap);
A2H=schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap);

% Check the responses
if max(abs(hAap1-A1H)) > 9.1002*eps
  error("max(abs(hAap1-A1H)) > 9.1002*eps");
endif
if max(abs(hAap2-A2H)) > 23.2*eps
  error("max(abs(hAap2-A2H)) > 23.2*eps");
endif

% Check the gradient of A1H wrt w
[A1H,A1dHdw]=schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap);
delw=1e-6;
wpass=wplot(npass);
diff_A1Hw=0;
A1HwPdelw2=schurOneMAPlattice2H(wpass+delw/2,A1A,A1B,A1Cap,A1Dap);
A1HwMdelw2=schurOneMAPlattice2H(wpass-delw/2,A1A,A1B,A1Cap,A1Dap);
diff_A1Hw=(A1HwPdelw2-A1HwMdelw2)/delw;
if abs(diff_A1Hw-A1dHdw(npass)) > delw/1723
  error("abs(diff_A1Hw-A1dHdw(npass)) > delw/1723");
endif

% Check the gradient of A2H wrt w
[A2H,A2dHdw]=schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap);
delw=1e-6;
wpass=wplot(npass);
diff_A2Hw=0;
A2HwPdelw2=schurOneMAPlattice2H(wpass+delw/2,A2A,A2B,A2Cap,A2Dap);
A2HwMdelw2=schurOneMAPlattice2H(wpass-delw/2,A2A,A2B,A2Cap,A2Dap);
diff_A2Hw=(A2HwPdelw2-A2HwMdelw2)/delw;
if abs(diff_A2Hw-A2dHdw(npass)) > delw/673.5
  error("abs(diff_A2Hw-A2dHdw(npass)) > delw/673.5");
endif

% Check the gradients of A1H wrt A1k
[A1A,A1B,A1C,A1D,A1Cap,A1Dap, ...
 A1dAdkc,A1dBdkc,A1dCdkc,A1dDdkc,A1dCapdkc,A1dDapdkc]=...
  schurOneMlattice2Abcd(A1k,A1epsilon,A1p,A1c);
[A1H,A1dHdw,A1dHdk]=schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap, ...
                                         A1dAdkc,A1dBdkc,A1dCapdkc,A1dDapdkc);
del=1e-6;
delA1k=zeros(size(A1k));
delA1k(1)=del/2;
wpass=wplot(npass);
diff_A1Hk=zeros(size(A1k));
for l=1:length(A1k)
  [A1A,A1B,A1C,A1D,A1Cap,A1Dap] = ...
    schurOneMlattice2Abcd(A1k+delA1k,A1epsilon,A1p,A1c);
  A1HkPdel2=schurOneMAPlattice2H(wpass,A1A,A1B,A1Cap,A1Dap);
  [A1A,A1B,A1C,A1D,A1Cap,A1Dap] = ...
    schurOneMlattice2Abcd(A1k-delA1k,A1epsilon,A1p,A1c);
  A1HkMdel2=schurOneMAPlattice2H(wpass,A1A,A1B,A1Cap,A1Dap);
  diff_A1Hk(l)=(A1HkPdel2-A1HkMdel2)/del;
  delA1k=shift(delA1k,1);
endfor
if max(abs(diff_A1Hk-A1dHdk(npass,1:length(A1k)))) > del/1807.1
  error("max(abs(diff_A1Hk-A1dHdk(npass,1:length(A1k)))) > del/1807.1");
endif

% Check the gradients of A2H wrt A2k
[A2A,A2B,A2C,A2D,A2Cap,A2Dap, ...
 A2dAdkc,A2dBdkc,A2dCdkc,A2dDdkc,A2dCapdkc,A2dDapdkc] = ...
  schurOneMlattice2Abcd(A2k,A2epsilon,A2p,A2c);
[A2H,A2dHdw,A2dHdk]=schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap, ...
                                         A2dAdkc,A2dBdkc,A2dCapdkc,A2dDapdkc);
del=1e-6;
delA2k=zeros(size(A2k));
delA2k(1)=del/2;
wpass=wplot(npass);
diff_A2Hk=zeros(size(A2k));
for l=1:length(A2k)
  [A2A,A2B,A2C,A2D,A2Cap,A2Dap] = ...
    schurOneMlattice2Abcd(A2k+delA2k,A2epsilon,A2p,A2c);
  A2HkPdel2=schurOneMAPlattice2H(wpass,A2A,A2B,A2Cap,A2Dap);
  [A2A,A2B,A2C,A2D,A2Cap,A2Dap] = ...
    schurOneMlattice2Abcd(A2k-delA2k,A2epsilon,A2p,A2c);
  A2HkMdel2=schurOneMAPlattice2H(wpass,A2A,A2B,A2Cap,A2Dap);
  diff_A2Hk(l)=(A2HkPdel2-A2HkMdel2)/del;
  delA2k=shift(delA2k,1);
endfor
if max(abs(diff_A2Hk-A2dHdk(npass,1:length(A2k)))) > del/384.37
  error("max(abs(diff_A2Hk-A2dHdk(npass,1:length(A2k)))) > del/384.37");
endif

% Check the gradient of A1H wrt w and A1k
[A1H,A1dHdw,A1dHdk,A1d2Hdwdk] = ...
  schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap, ...
                       A1dAdkc,A1dBdkc,A1dCapdkc,A1dDapdkc);
delw=1e-6;
wpass=wplot(npass);
diff_A1Hwk=zeros(1,columns(A1dHdk));
[A1HwPdelw2,A1dHwPdw,A1dHwPdk] = ...
  schurOneMAPlattice2H(wpass+delw/2,A1A,A1B,A1Cap,A1Dap, ...
                       A1dAdkc,A1dBdkc,A1dCapdkc,A1dDapdkc);
[A1HwMdelw2,A1dHwMdw,A1dHwMdk] = ...
  schurOneMAPlattice2H(wpass-delw/2,A1A,A1B,A1Cap,A1Dap, ...
                       A1dAdkc,A1dBdkc,A1dCapdkc,A1dDapdkc);
diff_A1Hwk=(A1dHwPdk-A1dHwMdk)/del;
if max(abs(diff_A1Hwk-A1d2Hdwdk(npass,:))) > del/392.9
  error("max(abs(diff_A1Hwk-A1d2Hdwdk(npass,:))) > del/392.9");
endif

% Check the gradient of A2H wrt w and A2k
[A2H,A2dHdw,A2dHdk,A2d2Hdwdk] = ...
  schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap, ...
                       A2dAdkc,A2dBdkc,A2dCapdkc,A2dDapdkc);
delw=1e-6;
wpass=wplot(npass);
diff_A2Hwk=zeros(1,columns(A2dHdk));
[A2HwPdelw2,A2dHwPdw,A2dHwPdk] = ...
  schurOneMAPlattice2H(wpass+delw/2,A2A,A2B,A2Cap,A2Dap, ...
                       A2dAdkc,A2dBdkc,A2dCapdkc,A2dDapdkc);
[A2HwMdelw2,A2dHwMdw,A2dHwMdk] = ...
  schurOneMAPlattice2H(wpass-delw/2,A2A,A2B,A2Cap,A2Dap, ...
                       A2dAdkc,A2dBdkc,A2dCapdkc,A2dDapdkc);
diff_A2Hwk=(A2dHwPdk-A2dHwMdk)/del;
if max(abs(diff_A2Hwk-A2d2Hdwdk(npass,:))) > del/38.05
  error("max(abs(diff_A2Hwk-A2d2Hdwdk(npass,:))) > del/38.05");
endif

% Check the diagonal of the Hessian of A1H wrt A1k
[A1A,A1B,A1C,A1D,A1Cap,A1Dap, ...
 A1dAdkc,A1dBdkc,A1dCdkc,A1dDdkc,A1dCapdkc,A1dDapdkc]=...
  schurOneMlattice2Abcd(A1k,A1epsilon,A1p,A1c);
[A1H,A1dHdw,A1dHdk,A1d2Hdwdk,A1diagd2Hdk2]=...
  schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap, ...
                       A1dAdkc,A1dBdkc,A1dCapdkc,A1dDapdkc);
del=1e-6;
delA1k=zeros(size(A1k));
delA1k(1)=del/2;
wpass=wplot(npass);
diff_dA1Hdk=zeros(size(A1k));
for l=1:length(A1k)
  [A1A,A1B,A1C,A1D,A1Cap,A1Dap,...
   A1dAdkc,A1dBdkc,A1dCdkc,A1dDdkc,A1dCapdkc,A1dDapdkc]=...
    schurOneMlattice2Abcd(A1k+delA1k,A1epsilon,A1p,A1c);
  [A1HP,A1dHdwP,A1dHdkP]=...
    schurOneMAPlattice2H(wpass,A1A,A1B,A1Cap,A1Dap,...
                         A1dAdkc,A1dBdkc,A1dCapdkc,A1dDapdkc);
  [A1A,A1B,A1C,A1D,A1Cap,A1Dap,...
   A1dAdkc,A1dBdkc,A1dCdkc,A1dDdkc,A1dCapdkc,A1dDapdkc]=...
    schurOneMlattice2Abcd(A1k-delA1k,A1epsilon,A1p,A1c);
  [A1HM,A1dHdwM,A1dHdkM]=...
    schurOneMAPlattice2H(wpass,A1A,A1B,A1Cap,A1Dap,...
                         A1dAdkc,A1dBdkc,A1dCapdkc,A1dDapdkc);
  diff_A1dHdk(l)=(A1dHdkP(l)-A1dHdkM(l))/del;
  delA1k=shift(delA1k,1);
endfor
if max(abs(diff_A1dHdk-A1diagd2Hdk2(npass,1:length(A1k)))) > del/265.6
  error("max(abs(diff_A1dHdk-A1diagd2Hdk2(npass,1:length(A1k)))) > del/265.6");
endif

% Check the diagonal of the Hessian of A2H wrt A2k
[A2A,A2B,A2C,A2D,A2Cap,A2Dap, ...
 A2dAdkc,A2dBdkc,A2dCdkc,A2dDdkc,A2dCapdkc,A2dDapdkc]=...
  schurOneMlattice2Abcd(A2k,A2epsilon,A2p,A2c);
[A2H,A2dHdw,A2dHdk,A2d2Hdwdk,A2diagd2Hdk2]=...
  schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap, ...
                       A2dAdkc,A2dBdkc,A2dCapdkc,A2dDapdkc);
del=1e-6;
delA2k=zeros(size(A2k));
delA2k(1)=del/2;
wpass=wplot(npass);
diff_dA2Hdk=zeros(size(A2k));
for l=1:length(A2k)
  [A2A,A2B,A2C,A2D,A2Cap,A2Dap,...
   A2dAdkc,A2dBdkc,A2dCdkc,A2dDdkc,A2dCapdkc,A2dDapdkc]=...
    schurOneMlattice2Abcd(A2k+delA2k,A2epsilon,A2p,A2c);
  [A2HP,A2dHdwP,A2dHdkP]=...
    schurOneMAPlattice2H(wpass,A2A,A2B,A2Cap,A2Dap,...
                         A2dAdkc,A2dBdkc,A2dCapdkc,A2dDapdkc);
  [A2A,A2B,A2C,A2D,A2Cap,A2Dap, ...
   A2dAdkc,A2dBdkc,A2dCdkc,A2dDdkc,A2dCapdkc,A2dDapdkc]=...
    schurOneMlattice2Abcd(A2k-delA2k,A2epsilon,A2p,A2c);
  [A2HM,A2dHdwM,A2dHdkM]=...
    schurOneMAPlattice2H(wpass,A2A,A2B,A2Cap,A2Dap,...
                         A2dAdkc,A2dBdkc,A2dCapdkc,A2dDapdkc);
  diff_A2dHdk(l)=(A2dHdkP(l)-A2dHdkM(l))/del;
  delA2k=shift(delA2k,1);
endfor
if max(abs(diff_A2dHdk-A2diagd2Hdk2(npass,1:length(A2k)))) > del/21.41
  error("max(abs(diff_A2dHdk-A2diagd2Hdk2(npass,1:length(A2k)))) > del/21.41");
endif

% Check the Hessian of A1H wrt w and A1k
[A1A,A1B,A1C,A1D,A1Cap,A1Dap, ...
 A1dAdkc,A1dBdkc,A1dCdkc,A1dDdkc,A1dCapdkc,A1dDapdkc]=...
schurOneMlattice2Abcd(A1k,A1epsilon,A1p,A1c);
[A1H,A1dHdw,A1dHdk,A1d2Hdwdk,A1diagd2Hdk2,A1diagd3Hdwdk2] = ...
  schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap, ...
                       A1dAdkc,A1dBdkc,A1dCapdkc,A1dDapdkc);
delw=1e-6;
wpass=wplot(npass);
diff_A1diagd2Hdk2=zeros(1,columns(A1diagd2Hdk2));
[A1HP,A1dHdwP,A1dHdkP,A1d2HdwdkP,A1diagd2Hdk2P] = ...
  schurOneMAPlattice2H(wpass+(delw/2),A1A,A1B,A1Cap,A1Dap, ...
                       A1dAdkc,A1dBdkc,A1dCapdkc,A1dDapdkc);
[A1HM,A1dHdwM,A1dHdkM,A1d2HdwdkM,A1diagd2Hdk2M] = ...
  schurOneMAPlattice2H(wpass-(delw/2),A1A,A1B,A1Cap,A1Dap, ...
                       A1dAdkc,A1dBdkc,A1dCapdkc,A1dDapdkc);
diff_A1diagd2Hdk2=(A1diagd2Hdk2P-A1diagd2Hdk2M)/delw;
if max(abs(diff_A1diagd2Hdk2-A1diagd3Hdwdk2(npass,:))) > delw/38.014
  error("max(abs(diff_A1diagd2Hdk2-A1diagd3Hdwdk2(npass,:))) > delw/38.014");
endif

% Check the Hessian of A2H wrt w and A2k
[A2A,A2B,A2C,A2D,A2Cap,A2Dap, ...
 A2dAdkc,A2dBdkc,A2dCdkc,A2dDdkc,A2dCapdkc,A2dDapdkc]=...
schurOneMlattice2Abcd(A2k,A2epsilon,A2p,A2c);
[A2H,A2dHdw,A2dHdk,A2d2Hdwdk,A2diagd2Hdk2,A2diagd3Hdwdk2] = ...
  schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap, ...
                       A2dAdkc,A2dBdkc,A2dCapdkc,A2dDapdkc);
delw=1e-6;
wpass=wplot(npass);
diff_A2diagd2Hdk2=zeros(1,columns(A2diagd2Hdk2));
[A2HP,A2dHdwP,A2dHdkP,A2d2HdwdkP,A2diagd2Hdk2P] = ...
  schurOneMAPlattice2H(wpass+(delw/2),A2A,A2B,A2Cap,A2Dap, ...
                       A2dAdkc,A2dBdkc,A2dCapdkc,A2dDapdkc);
[A2HM,A2dHdwM,A2dHdkM,A2d2HdwdkM,A2diagd2Hdk2M] = ...
  schurOneMAPlattice2H(wpass-(delw/2),A2A,A2B,A2Cap,A2Dap, ...
                       A2dAdkc,A2dBdkc,A2dCapdkc,A2dDapdkc);
diff_A2diagd2Hdk2=(A2diagd2Hdk2P-A2diagd2Hdk2M)/delw;
if max(abs(diff_A2diagd2Hdk2-A2diagd3Hdwdk2(npass,:))) > delw/1.506
  error("max(abs(diff_A2diagd2Hdk2-A2diagd3Hdwdk2(npass,:))) > delw/1.506");
endif

% Done
diary off
movefile schurOneMAPlattice2H_test.diary.tmp schurOneMAPlattice2H_test.diary;
