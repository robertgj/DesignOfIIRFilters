% schurOneMAPlattice2H_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

delete("schurOneMAPlattice2H_test.diary");
delete("schurOneMAPlattice2H_test.diary.tmp");
diary schurOneMAPlattice2H_test.diary.tmp

check_octave_file("schurOneMAPlattice2H");

verbose=false;

% Low pass filter
for norder=3:2:7,

  % Design filter
  fpass=0.125;
  [n,d]=butter(norder,2*fpass);

  % Calculate response
  nplot=1024;
  npass=floor(nplot*fpass/0.5);
  Nw=300;
  wplot=(0:(Nw-1))'*pi/nplot;
  h=freqz(n,d,wplot);
  
  % Alternative calculation
  [Aap1,Aap2]=tf2pa(n,d);
  hAap1=freqz(fliplr(Aap1),Aap1,wplot);
  hAap2=freqz(fliplr(Aap2),Aap2,wplot);
  hAap12=(hAap1+hAap2)/2;

  % Lattice decomposition
  [A1k,A1epsilon,A1p,A1c] = tf2schurOneMlattice(fliplr(Aap1),Aap1);
  [A2k,A2epsilon,A2p,A2c] = tf2schurOneMlattice(fliplr(Aap2),Aap2);

  % State variable form
  [A1A,A1B,~,~,A1Cap,A1Dap]=schurOneMlattice2Abcd(A1k,A1epsilon,A1p,A1c);
  [A2A,A2B,~,~,A2Cap,A2Dap]=schurOneMlattice2Abcd(A2k,A2epsilon,A2p,A2c);

  % Check the A1 response
  A1H=schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap);
  if verbose
    printf("max(abs(hAap1-A1H)) = %g*eps\n",max(abs(hAap1-A1H))/eps);
  endif
  if max(abs(hAap1-A1H)) > 50*eps
    error("max(abs(hAap1-A1H)) > 50*eps");
  endif
  H1Abcd=Abcd2H(wplot,A1A,A1B,A1Cap,A1Dap);
  if verbose
    printf("max(abs(H1Abcd-A1H)) = %g*eps\n",max(abs(H1Abcd-A1H))/eps);
  endif
  if max(abs(H1Abcd-A1H)) > 10*eps
    error("max(abs(H1Abcd-A1H)) > 10*eps");
  endif
  
  % Check the A2 response
  A2H=schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap);
  if verbose
    printf("max(abs(hAap2-A2H)) = %g*eps\n",max(abs(hAap2-A2H))/eps);
  endif
  if max(abs(hAap2-A2H)) > 50*eps
    error("max(abs(hAap2-A2H)) > 50*eps");
  endif
  H2Abcd=Abcd2H(wplot,A2A,A2B,A2Cap,A2Dap);
  if verbose
    printf("max(abs(H2Abcd-A2H)) = %g*eps\n",max(abs(H2Abcd-A2H))/eps);
  endif
  if max(abs(H2Abcd-A2H)) > 10*eps
    error("max(abs(H2Abcd-A2H)) > 10*eps");
  endif
 
  % Check the gradient of A1H wrt w
  [A1H,A1dHdw]=schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap);
  [H1Abcd,dH1dwAbcd]=Abcd2H(wplot,A1A,A1B,A1Cap,A1Dap);
  if verbose
    printf("max(abs(dH1dwAbcd-A1dHdw)) = %g*eps\n",
           max(abs(dH1dwAbcd-A1dHdw))/eps);
  endif
  if max(abs(dH1dwAbcd-A1dHdw)) > 200*eps
    error("max(abs(dH1dwAbcd-A1dHdw)) > 200*eps");
  endif
  delw=1e-6;
  wpass=wplot(npass);
  A1HwPdelw2=schurOneMAPlattice2H(wpass+delw/2,A1A,A1B,A1Cap,A1Dap);
  A1HwMdelw2=schurOneMAPlattice2H(wpass-delw/2,A1A,A1B,A1Cap,A1Dap);
  est_A1dHdw=(A1HwPdelw2-A1HwMdelw2)/delw;
  if verbose
    printf("abs(est_A1dHdw-A1dHdw(npass)) = delw/%g\n",
           delw/abs(est_A1dHdw-A1dHdw(npass)));
  endif
  if abs(est_A1dHdw-A1dHdw(npass)) > delw/400
    error("abs(est_A1dHdw-A1dHdw(npass)) > delw/400");
  endif

  % Check the gradient of A2H wrt w
  [A2H,A2dHdw]=schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap);
  [H2Abcd,dH2dwAbcd]=Abcd2H(wplot,A2A,A2B,A2Cap,A2Dap);
  if verbose
    printf("max(abs(dH2dwAbcd-A2dHdw)) = %g*eps\n",
           max(abs(dH2dwAbcd-A2dHdw))/eps);
  endif
  if max(abs(dH2dwAbcd-A2dHdw)) > 100*eps
    error("max(abs(dH2dwAbcd-A2dHdw)) > 100*eps");
  endif
  delw=1e-6;
  wpass=wplot(npass);
  A2HwPdelw2=schurOneMAPlattice2H(wpass+delw/2,A2A,A2B,A2Cap,A2Dap);
  A2HwMdelw2=schurOneMAPlattice2H(wpass-delw/2,A2A,A2B,A2Cap,A2Dap);
  est_A2dHdw=(A2HwPdelw2-A2HwMdelw2)/delw;
  if abs(est_A2dHdw-A2dHdw(npass)) > delw/500
    error("abs(est_A2dHdw-A2dHdw(npass)) > delw/500");
  endif
  if verbose
    printf("abs(est_A2dHdw-A2dHdw(npass)) = delw/%g\n",
           delw/abs(est_A2dHdw-A2dHdw(npass)));
  endif

  % Check the gradients of A1H wrt A1k
  [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk]= ...
    schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
  [A1H,A1dHdw,A1dHdk]=schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap, ...
                                           A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
  [H1Abcd,dH1dwAbcd,dH1dkAbcd]=Abcd2H(wplot,A1A,A1B,A1Cap,A1Dap, ...
                                      A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
  if verbose
    printf("max(max(abs(dH1dkAbcd-A1dHdk))) = %g*eps\n",
           max(max(abs(dH1dkAbcd-A1dHdk)))/eps);
  endif
  if max(max(abs(dH1dkAbcd-A1dHdk))) > 200*eps
    error("max(max(abs(dH1dkAbcd-A1dHdk))) > 200*eps");
  endif
  del=1e-6;
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  wpass=wplot(npass);
  est_A1dHdk=zeros(size(A1k));
  for l=1:length(A1k)
    [A1AP,A1BP,A1CapP,A1DapP]=schurOneMAPlattice2Abcd(A1k+delA1k,A1epsilon,A1p);
    A1HkPdel2=schurOneMAPlattice2H(wpass,A1AP,A1BP,A1CapP,A1DapP);
    [A1AM,A1BM,A1CapM,A1DapM]=schurOneMAPlattice2Abcd(A1k-delA1k,A1epsilon,A1p);
    A1HkMdel2=schurOneMAPlattice2H(wpass,A1AM,A1BM,A1CapM,A1DapM);
    est_A1dHdk(l)=(A1HkPdel2-A1HkMdel2)/del;
    delA1k=circshift(delA1k,1);
  endfor
  if verbose
    printf("max(abs(est_A1dHdk-A1dHdk(npass,:))) = del/%g\n",
           del/max(abs(est_A1dHdk-A1dHdk(npass,:))));
  endif
  if max(abs(est_A1dHdk-A1dHdk(npass,:))) > del/400
    error("max(abs(est_A1dHdk-A1dHdk(npass,))) > del/400");
  endif

  % Check the gradients of A2H wrt A2k
  [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk] = ...
    schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
  [A2H,A2dHdw,A2dHdk]=schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap, ...
                                           A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);
  [H2Abcd,dH2dwAbcd,dH2dkAbcd]=Abcd2H(wplot,A2A,A2B,A2Cap,A2Dap, ...
                                      A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);
  if verbose
    printf("max(max(abs(dH2dkAbcd-A2dHdk))) > %g*eps\n",
           max(max(abs(dH2dkAbcd-A2dHdk)))/eps);
  endif
  if max(max(abs(dH2dkAbcd-A2dHdk))) > 100*eps
    error("max(max(abs(dH2dkAbcd-A2dHdk))) > 100*eps");
  endif
  del=1e-6;
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  wpass=wplot(npass);
  est_A2Hk=zeros(size(A2k));
  for l=1:length(A2k)
    [A2AP,A2BP,A2CapP,A2DapP]=schurOneMAPlattice2Abcd(A2k+delA2k,A2epsilon,A2p);
    A2HkPdel2=schurOneMAPlattice2H(wpass,A2AP,A2BP,A2CapP,A2DapP);
    [A2AM,A2BM,A2CapM,A2DapM]=schurOneMAPlattice2Abcd(A2k-delA2k,A2epsilon,A2p);
    A2HkMdel2=schurOneMAPlattice2H(wpass,A2AM,A2BM,A2CapM,A2DapM);
    est_A2dHdk(l)=(A2HkPdel2-A2HkMdel2)/del;
    delA2k=circshift(delA2k,1);
  endfor
  if verbose
    printf("max(abs(est_A2dHdk-A2dHdk(npass,:))) = del/%g\n",
           del/max(abs(est_A2dHdk-A2dHdk(npass,:))));
  endif
  if max(abs(est_A2dHdk-A2dHdk(npass,:))) > del/200
    error("max(abs(est_A2dHdk-A2dHdk(npass,))) > del/200");
  endif

  % Check the gradient of A1H wrt w and A1k
  [A1H,A1dHdw,A1dHdk,A1d2Hdwdk] = ...
    schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap, ...
                         A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
  [H1Abcd,dH1dwAbcd,dH1dkAbcd,d2H1dwdkAbcd]= ...
    Abcd2H(wplot,A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
  if verbose
    printf("max(max(abs(d2H1dwdkAbcd-A1d2Hdwdk))) = %g*eps\n",
           max(max(abs(d2H1dwdkAbcd-A1d2Hdwdk)))/eps);
  endif
  if max(max(abs(d2H1dwdkAbcd-A1d2Hdwdk))) > 5000*eps
    error("max(max(abs(d2H1dwdkAbcd-A1d2Hdwdk))) > 5000*eps");
  endif
  delw=1e-6;
  wpass=wplot(npass);
  est_A1d2Hdwdk=zeros(1,columns(A1dHdk));
  [A1HwPdelw2,A1dHwPdw,A1dHwPdk] = ...
    schurOneMAPlattice2H(wpass+delw/2,A1A,A1B,A1Cap,A1Dap, ...
                         A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
  [A1HwMdelw2,A1dHwMdw,A1dHwMdk] = ...
    schurOneMAPlattice2H(wpass-delw/2,A1A,A1B,A1Cap,A1Dap, ...
                         A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
  est_A1d2Hdwdk=(A1dHwPdk-A1dHwMdk)/del;
  if verbose
    printf("max(abs(est_A1d2Hdwdk-A1d2Hdwdk(npass,:))) = del/%g\n",
           del/max(abs(est_A1d2Hdwdk-A1d2Hdwdk(npass,:))));
  endif
  if max(abs(est_A1d2Hdwdk-A1d2Hdwdk(npass,:))) > del/20
    error("max(abs(est_A1d2Hdwdk-A1d2Hdwdk(npass,))) > del/20");
  endif

  % Check the gradient of A2H wrt w and A2k
  [A2H,A2dHdw,A2dHdk,A2d2Hdwdk] = ...
    schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap, ...
                         A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);
  [H2Abcd,dH2dwAbcd,dH2dkAbcd,d2H2dwdkAbcd] = ...
    Abcd2H(wplot,A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);
  if max(max(abs(d2H2dwdkAbcd-A2d2Hdwdk))) > 2000*eps
    error("max(max(abs(d2H2dwdkAbcd-A2d2Hdwdk))) > 2000*eps");
  endif
  if verbose
    printf("max(max(abs(d2H2dwdkAbcd-A2d2Hdwdk))) = %g*eps\n",
           max(max(abs(d2H2dwdkAbcd-A2d2Hdwdk)))/eps);
  endif
  delw=1e-6;
  wpass=wplot(npass);
  [A2HwPdelw2,A2dHwPdw,A2dHwPdk] = ...
    schurOneMAPlattice2H(wpass+delw/2,A2A,A2B,A2Cap,A2Dap, ...
                         A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);
  [A2HwMdelw2,A2dHwMdw,A2dHwMdk] = ...
    schurOneMAPlattice2H(wpass-delw/2,A2A,A2B,A2Cap,A2Dap, ...
                         A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);
  est_A2d2Hdwdk=(A2dHwPdk-A2dHwMdk)/del;
  if verbose
    printf("max(abs(est_A2d2Hdwdk-A2d2Hdwdk(npass,:))) > del/%g\n",
           del/max(abs(est_A2d2Hdwdk-A2d2Hdwdk(npass,:))));
  endif
  if max(abs(est_A2d2Hdwdk-A2d2Hdwdk(npass,:))) > del/20
    error("max(abs(est_A2d2Hdwdk-A2d2Hdwdk(npass,))) > del/20");
  endif

  % Check the diagonal of the Hessian of A1H wrt A1k
  [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
   A1d2Adydx,A1d2Bdydx,A1d2Capdydx,A1d2Dapdydx] = ...
    schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
  [A1H,A1dHdw,A1dHdk,A1d2Hdwdk,A1diagd2Hdk2]=...
    schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap, ...
                         A1dAdk,A1dBdk,A1dCapdk,A1dDapdk,A1d2Adydx);
  [H1Abcd,dH1dwAbcd,dH1dkAbcd,d2H1dwdkAbcd,diagd2H1dk2Abcd]= ...
    Abcd2H(wplot,A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
           A1d2Adydx,A1d2Bdydx,A1d2Capdydx,A1d2Dapdydx);
  if verbose
    printf("max(max(abs(diagd2H1dk2Abcd-A1diagd2Hdk2))) = %g*eps\n",
           max(max(abs(diagd2H1dk2Abcd-A1diagd2Hdk2)))/eps);
  endif
  if max(max(abs(diagd2H1dk2Abcd-A1diagd2Hdk2))) > 10000*eps
    error("max(max(abs(diagd2H1dk2Abcd-A1diagd2Hdk2))) > 10000*eps");
  endif
  del=1e-6;
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  wpass=wplot(npass);
  est_A1diagd2Hdk2=zeros(size(A1k));
  for l=1:length(A1k)
    [A1AP,A1BP,A1CapP,A1DapP,A1dAdkP,A1dBdkP,A1dCapdkP,A1dDapdkP]=...
      schurOneMAPlattice2Abcd(A1k+delA1k,A1epsilon,A1p);
    [A1HP,A1dHdwP,A1dHdkP]=...
      schurOneMAPlattice2H(wpass,A1AP,A1BP,A1CapP,A1DapP,...
                           A1dAdkP,A1dBdkP,A1dCapdkP,A1dDapdkP);
    [A1AM,A1BM,A1CapM,A1DapM,A1dAdkM,A1dBdkM,A1dCapdkM,A1dDapdkM]=...
      schurOneMAPlattice2Abcd(A1k-delA1k,A1epsilon,A1p);
    [A1HM,A1dHdwM,A1dHdkM]=...
      schurOneMAPlattice2H(wpass,A1AM,A1BM,A1CapM,A1DapM,...
                           A1dAdkM,A1dBdkM,A1dCapdkM,A1dDapdkM);
    est_A1diagd2Hdk2(l)=(A1dHdkP(l)-A1dHdkM(l))/del;
    delA1k=circshift(delA1k,1);
  endfor
  if verbose
    printf("max(abs(est_A1diagd2Hdk2-A1diagd2Hdk2(npass,:))) > del/%g\n",
           del/max(abs(est_A1diagd2Hdk2-A1diagd2Hdk2(npass,:))));
  endif
  if max(abs(est_A1diagd2Hdk2-A1diagd2Hdk2(npass,:))) > del/10
    error("max(abs(est_A1diagd2Hdk2-A1diagd2Hdk2(npass,)))>del/10");
  endif

  % Check the diagonal of the Hessian of A2H wrt A2k
  [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
   A2d2Adydx,A2d2Bdydx,A2d2Capdydx,A2d2Dapdydx]=...
    schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
  [A2H,A2dHdw,A2dHdk,A2d2Hdwdk,A2diagd2Hdk2]=...
    schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap, ...
                         A2dAdk,A2dBdk,A2dCapdk,A2dDapdk,A2d2Adydx);
  [H2Abcd,dH2dwAbcd,dH2dkAbcd,d2H2dwdkAbcd,diagd2H2dk2Abcd]= ...
    Abcd2H(wplot,A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
           A2d2Adydx,A2d2Bdydx,A2d2Capdydx,A2d2Dapdydx);
  if verbose
    printf("max(max(abs(diagd2H2dk2Abcd-A2diagd2Hdk2))) = %g*eps\n",
           max(max(abs(diagd2H2dk2Abcd-A2diagd2Hdk2)))/eps);
  endif
  if max(max(abs(diagd2H2dk2Abcd-A2diagd2Hdk2))) > 2000*eps
    error("max(max(abs(diagd2H2dk2Abcd-A2diagd2Hdk2))) > 2000*eps");
  endif
  del=1e-6;
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  wpass=wplot(npass);
  est_A2diagd2Hdk2=zeros(size(A2k));
  for l=1:length(A2k)
    [A2AP,A2BP,A2CapP,A2DapP,A2dAdkP,A2dBdkP,A2dCapdkP,A2dDapdkP]=...
      schurOneMAPlattice2Abcd(A2k+delA2k,A2epsilon,A2p);
    [A2HP,A2dHdwP,A2dHdkP]=...
      schurOneMAPlattice2H(wpass,A2AP,A2BP,A2CapP,A2DapP,...
                           A2dAdkP,A2dBdkP,A2dCapdkP,A2dDapdkP);
    [A2AM,A2BM,A2CapM,A2DapM,A2dAdkM,A2dBdkM,A2dCapdkM,A2dDapdkM]=...
      schurOneMAPlattice2Abcd(A2k-delA2k,A2epsilon,A2p);
    [A2HM,A2dHdwM,A2dHdkM]=...
      schurOneMAPlattice2H(wpass,A2AM,A2BM,A2CapM,A2DapM,...
                           A2dAdkM,A2dBdkM,A2dCapdkM,A2dDapdkM);
    est_A2diagd2Hdk2(l)=(A2dHdkP(l)-A2dHdkM(l))/del;
    delA2k=circshift(delA2k,1);
  endfor
  if verbose
    printf("max(abs(est_A2diagd2Hdk2-A2diagd2Hdk2(npass,:))) = del/%g\n",
           del/max(abs(est_A2diagd2Hdk2-A2diagd2Hdk2(npass,:))));
  endif
  if max(abs(est_A2diagd2Hdk2-A2diagd2Hdk2(npass,:))) > del/20
    error("max(abs(est_A2diagd2Hdk2-A2diagd2Hdk2(npass,))) > del/20");
  endif

  % Check the diagonal of the Hessian of A1H wrt w and A1k
  [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
   A1d2Adydx,A1d2Bdydx,A1d2Capdydx,A1d2Dapdydx]=...
    schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
  [A1H,A1dHdw,A1dHdk,A1d2Hdwdk,A1diagd2Hdk2,A1diagd3Hdwdk2] = ...
    schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap, ...
                         A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
  [H1Abcd,dH1dwAbcd,dH1dkAbcd,d2H1dwdkAbcd,diagd2H1dk2Abcd,diagd3H1dwdk2Abcd]=...
    Abcd2H(wplot,A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
  if verbose
    printf("max(max(abs(diagd3H1dwdk2Abcd-A1diagd3Hdwdk2))) = %g*eps\n",
           max(max(abs(diagd3H1dwdk2Abcd-A1diagd3Hdwdk2)))/eps);
  endif
  if max(max(abs(diagd3H1dwdk2Abcd-A1diagd3Hdwdk2))) > 2e5*eps
    error("max(max(abs(diagd3H1dwdk2Abcd-A1diagd3Hdwdk2))) > 2e5*eps");
  endif
  delw=1e-6;
  wpass=wplot(npass);
  est_A1diagd3Hdwdk2=zeros(1,columns(A1diagd2Hdk2));
  [A1HP,A1dHdwP,A1dHdkP,A1d2HdwdkP,A1diagd2Hdk2P] = ...
    schurOneMAPlattice2H(wpass+(delw/2),A1A,A1B,A1Cap,A1Dap, ...
                         A1dAdk,A1dBdk,A1dCapdk,A1dDapdk,A1d2Adydx);
  [A1HM,A1dHdwM,A1dHdkM,A1d2HdwdkM,A1diagd2Hdk2M] = ...
    schurOneMAPlattice2H(wpass-(delw/2),A1A,A1B,A1Cap,A1Dap, ...
                         A1dAdk,A1dBdk,A1dCapdk,A1dDapdk,A1d2Adydx);
  est_A1diagd3Hdwdk2=(A1diagd2Hdk2P-A1diagd2Hdk2M)/delw;
  if verbose
    printf("max(abs(est_A1diagd3Hdwdk2-A1diagd3Hdwdk2(npass,:))) = %g*delw\n",
           max(abs(est_A1diagd3Hdwdk2-A1diagd3Hdwdk2(npass,:)))/delw);
  endif
  if max(abs(est_A1diagd3Hdwdk2-A1diagd3Hdwdk2(npass,:))) > 2*delw
    error("max(abs(est_A1diagd3Hdwdk2-A1diagd3Hdwdk2(npass,))) > 2*delw");
  endif

  % Check the diagonal of the Hessian of A2dHdw wrt A2k
  [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
   A2d2Adydx,A2d2Bdydx,A2d2Capdydx,A2d2Dapdydx]=...
    schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
  [A2H,A2dHdw,A2dHdk,A2d2Hdwdk,A2diagd2Hdk2,A2diagd3Hdwdk2] = ...
    schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap, ...
                         A2dAdk,A2dBdk,A2dCapdk,A2dDapdk,A2d2Adydx);
  [H2Abcd,dH2dwAbcd,dH2dkAbcd,d2H2dwdkAbcd,diagd2H2dk2Abcd,diagd3H2dwdk2Abcd]=...
    Abcd2H(wplot,A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
           A2d2Adydx,A2d2Bdydx,A2d2Capdydx,A2d2Dapdydx);
  if verbose
    printf("max(max(abs(diagd3H2dwdk2Abcd-A2diagd3Hdwdk2))) = %g*eps\n",
            max(max(abs(diagd3H2dwdk2Abcd-A2diagd3Hdwdk2)))/eps);
  endif
  if max(max(abs(diagd3H2dwdk2Abcd-A2diagd3Hdwdk2))) > 50000*eps
    error("max(max(abs(diagd3H2dwdk2Abcd-A2diagd3Hdwdk2))) > 50000*eps");
  endif
  delw=1e-6;
  wpass=wplot(npass);
  est_A2diagd3Hdwdk2=zeros(1,columns(A2diagd2Hdk2));
  [A2HP,A2dHdwP,A2dHdkP,A2d2HdwdkP,A2diagd2Hdk2P] = ...
    schurOneMAPlattice2H(wpass+(delw/2),A2A,A2B,A2Cap,A2Dap, ...
                         A2dAdk,A2dBdk,A2dCapdk,A2dDapdk,A2d2Adydx);
  [A2HM,A2dHdwM,A2dHdkM,A2d2HdwdkM,A2diagd2Hdk2M] = ...
    schurOneMAPlattice2H(wpass-(delw/2),A2A,A2B,A2Cap,A2Dap, ...
                         A2dAdk,A2dBdk,A2dCapdk,A2dDapdk,A2d2Adydx);
  est_A2diagd3Hdwdk2=(A2diagd2Hdk2P-A2diagd2Hdk2M)/delw;
  if verbose
    printf("max(abs(est_A2diagd3Hdwdk2-A2diagd3Hdwdk2(npass,:))) = delw/%g\n",
           delw/max(abs(est_A2diagd3Hdwdk2-A2diagd3Hdwdk2(npass,:))));
  endif
  if max(abs(est_A2diagd3Hdwdk2-A2diagd3Hdwdk2(npass,:))) > delw
    error("max(abs(est_A2diagd3Hdwdk2-A2diagd3Hdwdk2(npass,))) > delw");
  endif

  % Check the Hessian of A1H wrt A1k
  [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
   A1d2Adydx,A1d2Bdydx,A1d2Capdydx,A1d2Dapdydx] = ...
    schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
  [A1H,A1dHdw,A1dHdk,A1d2Hdwdk,A1diagd2Hdk2,A1diagd3Hdwdk2,A1d2Hdydx]=...
    schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap, ...
                         A1dAdk,A1dBdk,A1dCapdk,A1dDapdk,A1d2Adydx,A1d2Capdydx);
  [~,~,~,~,~,~,d2H1dydxAbcd]= ...
    Abcd2H(wplot,A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
           A1d2Adydx,A1d2Bdydx,A1d2Capdydx,A1d2Dapdydx);
  if verbose
    printf("max(max(max(abs(d2H1dydxAbcd-A1d2Hdydx)))) = %g*eps\n",
           max(max(max(abs(d2H1dydxAbcd-A1d2Hdydx))))/eps);
  endif
  if max(max(max(abs(d2H1dydxAbcd-A1d2Hdydx)))) > 10000*eps
    error("max(max(max(abs(d2H1dydxAbcd-A1d2Hdydx)))) > 10000*eps");
  endif
  del=1e-6;
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  wpass=wplot(npass);
  est_A1d2Hdydx=zeros(length(A1k),length(A1k));
  for m=1:length(A1k)
    for n=1:length(A1k)
      [A1AP,A1BP,A1CapP,A1DapP,A1dAdkP,A1dBdkP,A1dCapdkP,A1dDapdkP]=...
          schurOneMAPlattice2Abcd(A1k+delA1k,A1epsilon,A1p);
      [A1AM,A1BM,A1CapM,A1DapM,A1dAdkM,A1dBdkM,A1dCapdkM,A1dDapdkM]=...
        schurOneMAPlattice2Abcd(A1k-delA1k,A1epsilon,A1p);
      delA1k=circshift(delA1k,1);

      [A1HP,A1dHdwP,A1dHdkP]=...
        schurOneMAPlattice2H(wpass,A1AP,A1BP,A1CapP,A1DapP,...
                              A1dAdkP,A1dBdkP,A1dCapdkP,A1dDapdkP);
      [A1HM,A1dHdwM,A1dHdkM]=...
        schurOneMAPlattice2H(wpass,A1AM,A1BM,A1CapM,A1DapM,...
                             A1dAdkM,A1dBdkM,A1dCapdkM,A1dDapdkM);

      est_A1d2Hdydx(m,n)=(A1dHdkP(m)-A1dHdkM(m))/del;
    endfor
  endfor
  if verbose
    printf("max(max(abs(est_A1d2Hdydx-squeeze(A1d2Hdydx(npass,:,:)))))=del/%g\n",
           del/max(max(abs(est_A1d2Hdydx-squeeze(A1d2Hdydx(npass,:,:))))));
  endif
  if max(max(abs(est_A1d2Hdydx-squeeze(A1d2Hdydx(npass,:,:))))) > del/10
    error("max(max(abs(est_A1d2Hdydx-squeeze(A1d2Hdydx(npass,,)))))>del/10");
  endif

  % Check the Hessian of A2H wrt A2k
  [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
   A2d2Adydx,A2d2Bdydx,A2d2Capdydx,A2d2Dapdydx] = ...
    schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
  [A2H,A2dHdw,A2dHdk,A2d2Hdwdk,A2diagd2Hdk2,A2diagd3Hdwdk2,A2d2Hdydx]=...
    schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap, ...
                         A2dAdk,A2dBdk,A2dCapdk,A2dDapdk,A2d2Adydx,A2d2Capdydx);
  [~,~,~,~,~,~,d2H2dydxAbcd]= ...
    Abcd2H(wplot,A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
           A2d2Adydx,A2d2Bdydx,A2d2Capdydx,A2d2Dapdydx);
  if verbose
    printf("max(max(max(abs(d2H2dydxAbcd-A2d2Hdydx)))) = %g*eps\n",
           max(max(max(abs(d2H2dydxAbcd-A2d2Hdydx))))/eps);
  endif
  if max(max(max(abs(d2H2dydxAbcd-A2d2Hdydx)))) > 10000*eps
    error("max(max(max(abs(d2H2dydxAbcd-A2d2Hdydx)))) > 10000*eps");
  endif
  del=1e-6;
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  wpass=wplot(npass);
  est_A2d2Hdydx=zeros(length(A2k),length(A2k));
  for m=1:length(A2k)
    for n=1:length(A2k)
      [A2AP,A2BP,A2CapP,A2DapP,A2dAdkP,A2dBdkP,A2dCapdkP,A2dDapdkP]=...
          schurOneMAPlattice2Abcd(A2k+delA2k,A2epsilon,A2p);
      [A2AM,A2BM,A2CapM,A2DapM,A2dAdkM,A2dBdkM,A2dCapdkM,A2dDapdkM]=...
        schurOneMAPlattice2Abcd(A2k-delA2k,A2epsilon,A2p);
      delA2k=circshift(delA2k,1);

      [A2HP,A2dHdwP,A2dHdkP]=...
        schurOneMAPlattice2H(wpass,A2AP,A2BP,A2CapP,A2DapP,...
                              A2dAdkP,A2dBdkP,A2dCapdkP,A2dDapdkP);
      [A2HM,A2dHdwM,A2dHdkM]=...
        schurOneMAPlattice2H(wpass,A2AM,A2BM,A2CapM,A2DapM,...
                             A2dAdkM,A2dBdkM,A2dCapdkM,A2dDapdkM);

      est_A2d2Hdydx(m,n)=(A2dHdkP(m)-A2dHdkM(m))/del;
    endfor
  endfor
  if verbose
    printf("max(max(abs(est_A2d2Hdydx-squeeze(A2d2Hdydx(npass,:,:)))))=del/%g\n",
           del/max(max(abs(est_A2d2Hdydx-squeeze(A2d2Hdydx(npass,:,:))))));
  endif
  if max(max(abs(est_A2d2Hdydx-squeeze(A2d2Hdydx(npass,:,:))))) > del/10
    error("max(max(abs(est_A2d2Hdydx-squeeze(A2d2Hdydx(npass,,)))))>del/10");
  endif

  % Check the gradient of A1d2Hdydx wrt w
  [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
   A1d2Adydx,A1d2Bdydx,A1d2Capdydx,A1d2Dapdydx] = ...
    schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
  [A1H,A1dHdw,A1dHdk,A1d2Hdwdk,A1diagd2Hdk2,A1diagd3Hdwdk2, ...
   A1d2Hdydx,A1d3Hdwdydx]=...
    schurOneMAPlattice2H(wplot,A1A,A1B,A1Cap,A1Dap, ...
                         A1dAdk,A1dBdk,A1dCapdk,A1dDapdk,A1d2Adydx,A1d2Capdydx);
  [~,~,~,~,~,~,~,d3H1dwdydxAbcd]= ...
    Abcd2H(wplot,A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
           A1d2Adydx,A1d2Bdydx,A1d2Capdydx,A1d2Dapdydx);
  max_abs_diff_d3H1dwdydxAbcd = ...
    max(max(max(abs(squeeze(d3H1dwdydxAbcd - A1d3Hdwdydx)))));
  if verbose
    printf ("max_abs_diff_d3H1dwdydxAbcd=%g*eps\n",
            max_abs_diff_d3H1dwdydxAbcd/eps);
  endif
  if max_abs_diff_d3H1dwdydxAbcd > 200000*eps
    error("max_abs_diff_d3H1dwdydxAbcd > 200000*eps");
  endif
  delw=1e-6;
  wpass=wplot(npass);
  est_A1d3Hdwdydx=zeros(length(A1k),length(A1k));
  [A1HwPdelw2,A1dHwPdw,A1dHwPdk,A1d2HwPdwdk, ...
   A1diagd2HwPdk2,A1diagd3HwPdwdk2,A1d2HwPdydx]=...
    schurOneMAPlattice2H(wpass+delw/2,A1A,A1B,A1Cap,A1Dap, ...
                         A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
                         A1d2Adydx,A1d2Capdydx);
  [A1HwMdelw2,A1dHwMdw,A1dHwMdk,A1d2HwMdwdk, ...
   A1diagd2HwMdk2,A1diagd3HwMdwdk2,A1d2HwMdydx]=...
    schurOneMAPlattice2H(wpass-delw/2,A1A,A1B,A1Cap,A1Dap, ...
                         A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
                         A1d2Adydx,A1d2Capdydx);
  est_A1d3Hdwdydx=(A1d2HwPdydx-A1d2HwMdydx)/del;
  max_abs_diff_A1d3Hdwdydx = ...
    max(max(abs(squeeze(est_A1d3Hdwdydx(1,:,:)-A1d3Hdwdydx(npass,:,:)))));
  if verbose
    printf("max_abs_diff_A1d3Hdwdydx = del*%g\n",max_abs_diff_A1d3Hdwdydx/del);
  endif
  if max_abs_diff_A1d3Hdwdydx > 2*del
    error("max_abs_diff_A1d3Hdwdydx > 2*del");
  endif
  % Check the Hessian of A1dHdw wrt A1k
  del=1e-6;
  delA1k=zeros(size(A1k));
  delA1k(1)=del/2;
  wpass=wplot(npass);
  est_A1d3Hdwdydx=zeros(length(A1k),length(A1k));
  for m=1:length(A1k)
    for n=1:length(A1k)
      [A1AP,A1BP,A1CapP,A1DapP,A1dAdkP,A1dBdkP,A1dCapdkP,A1dDapdkP]=...
          schurOneMAPlattice2Abcd(A1k+delA1k,A1epsilon,A1p);
      [A1AM,A1BM,A1CapM,A1DapM,A1dAdkM,A1dBdkM,A1dCapdkM,A1dDapdkM]=...
        schurOneMAPlattice2Abcd(A1k-delA1k,A1epsilon,A1p);
      delA1k=circshift(delA1k,1);

      [A1HP,A1dHdwP,A1dHdkP,A1d2HdwdkP]=...
        schurOneMAPlattice2H(wpass,A1AP,A1BP,A1CapP,A1DapP,...
                              A1dAdkP,A1dBdkP,A1dCapdkP,A1dDapdkP);
      [A1HM,A1dHdwM,A1dHdkM,A1d2HdwdkM]=...
        schurOneMAPlattice2H(wpass,A1AM,A1BM,A1CapM,A1DapM,...
                             A1dAdkM,A1dBdkM,A1dCapdkM,A1dDapdkM);

      est_A1d3Hdwdydx(m,n)=(A1d2HdwdkP(m)-A1d2HdwdkM(m))/del;
    endfor
  endfor 
  max_abs_diff_A1d3Hdwdydx=max(max(abs(est_A1d3Hdwdydx ...
                                       -squeeze(A1d3Hdwdydx(npass,:,:)))));
  if verbose
    printf("max_abs_diff_A1d3Hdwdydx = del*%g\n",max_abs_diff_A1d3Hdwdydx/del);
  endif
  if max_abs_diff_A1d3Hdwdydx > del*2
    error("max_abs_diff_A1d3Hdwdydx > del*2");
  endif

  % Check the gradient of A2d2Hdydx wrt w
  [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
   A2d2Adydx,A2d2Bdydx,A2d2Capdydx,A2d2Dapdydx] = ...
    schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
  [A2H,A2dHdw,A2dHdk,A2d2Hdwdk,A2diagd2Hdk2,A2diagd3Hdwdk2, ...
   A2d2Hdydx,A2d3Hdwdydx]=...
    schurOneMAPlattice2H(wplot,A2A,A2B,A2Cap,A2Dap, ...
                         A2dAdk,A2dBdk,A2dCapdk,A2dDapdk,A2d2Adydx,A2d2Capdydx);
  [~,~,~,~,~,~,~,d3H2dwdydxAbcd]= ...
    Abcd2H(wplot,A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
           A2d2Adydx,A2d2Bdydx,A2d2Capdydx,A2d2Dapdydx);
  max_abs_diff_d3H2dwdydxAbcd = ...
    max(max(max(abs(squeeze(d3H2dwdydxAbcd - A2d3Hdwdydx)))));
  if verbose
    printf("max_abs_diff_d3H2dwdydxAbcd=%g*eps\n",
           max_abs_diff_d3H2dwdydxAbcd/eps);
  endif
  if max_abs_diff_d3H2dwdydxAbcd > 40000*eps
    error("max_abs_diff_d3H2dwdydxAbcd > 40000*eps");
  endif
  delw=1e-6;
  wpass=wplot(npass);
  est_A2d3Hdwdydx=zeros(length(A2k),length(A2k));
  [A2HwPdelw2,A2dHwPdw,A2dHwPdk,A2d2HwPdwdk, ...
   A2diagd2HwPdk2,A2diagd3HwPdwdk2,A2d2HwPdydx]=...
    schurOneMAPlattice2H(wpass+delw/2,A2A,A2B,A2Cap,A2Dap, ...
                         A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
                         A2d2Adydx,A2d2Capdydx);
  [A2HwMdelw2,A2dHwMdw,A2dHwMdk,A2d2HwMdwdk, ...
   A2diagd2HwMdk2,A2diagd3HwMdwdk2,A2d2HwMdydx]=...
    schurOneMAPlattice2H(wpass-delw/2,A2A,A2B,A2Cap,A2Dap, ...
                         A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
                         A2d2Adydx,A2d2Capdydx);
  est_A2d3Hdwdydx=(A2d2HwPdydx-A2d2HwMdydx)/del;
  max_abs_diff_A2d3Hdwdydx = ...
    max(max(abs(squeeze(est_A2d3Hdwdydx(1,:,:)-A2d3Hdwdydx(npass,:,:)))));
  if verbose
    printf("max_abs_diff_A2d3Hdwdydx = del/%g\n",del/max_abs_diff_A2d3Hdwdydx);
  endif
  if max_abs_diff_A2d3Hdwdydx > del
    error("max_abs_diff_A2d3Hdwdydx > del");
  endif
  % Check the Hessian of A2dHdw wrt A2k
  del=1e-6;
  delA2k=zeros(size(A2k));
  delA2k(1)=del/2;
  wpass=wplot(npass);
  est_A2d3Hdwdydx=zeros(length(A2k),length(A2k));
  for m=1:length(A2k)
    for n=1:length(A2k)
      [A2AP,A2BP,A2CapP,A2DapP,A2dAdkP,A2dBdkP,A2dCapdkP,A2dDapdkP]=...
          schurOneMAPlattice2Abcd(A2k+delA2k,A2epsilon,A2p);
      [A2AM,A2BM,A2CapM,A2DapM,A2dAdkM,A2dBdkM,A2dCapdkM,A2dDapdkM]=...
        schurOneMAPlattice2Abcd(A2k-delA2k,A2epsilon,A2p);
      delA2k=circshift(delA2k,1);

      [A2HP,A2dHdwP,A2dHdkP,A2d2HdwdkP]=...
        schurOneMAPlattice2H(wpass,A2AP,A2BP,A2CapP,A2DapP,...
                              A2dAdkP,A2dBdkP,A2dCapdkP,A2dDapdkP);
      [A2HM,A2dHdwM,A2dHdkM,A2d2HdwdkM]=...
        schurOneMAPlattice2H(wpass,A2AM,A2BM,A2CapM,A2DapM,...
                             A2dAdkM,A2dBdkM,A2dCapdkM,A2dDapdkM);

      est_A2d3Hdwdydx(m,n)=(A2d2HdwdkP(m)-A2d2HdwdkM(m))/del;
    endfor
  endfor 
  max_abs_diff_A2d3Hdwdydx=max(max(abs(est_A2d3Hdwdydx ...
                                       -squeeze(A2d3Hdwdydx(npass,:,:)))));
  if verbose
    printf("max_abs_diff_A2d3Hdwdydx = del/%g\n",del/max_abs_diff_A2d3Hdwdydx);
  endif
  if max_abs_diff_A2d3Hdwdydx > del/2
    error("max_abs_diff_A2d3Hdwdydx > del/2");
  endif
  
endfor

% Done
diary off
movefile schurOneMAPlattice2H_test.diary.tmp schurOneMAPlattice2H_test.diary;
