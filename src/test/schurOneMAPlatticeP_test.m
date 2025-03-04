% schurOneMAPlatticeP_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurOneMAPlatticeP_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;
tol=1e-6;

for x=1:2
  if x==1
    N=3;
    ftpl=0.1;
    [n,d]=butter(N,ftpl*2);
    R=2;
  else
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
    R=1;
  endif

  nplot=1024;
  ntpl=floor(nplot*ftpl/0.5);
  fplot=(0:(nplot/2))'/nplot;
  wplot=pi*fplot;

  % Convert filter transfer function to Schur 1-multiplier lattice form
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  Nk=length(k);

  %
  % Check the phase response
  %
  P=schurOneMAPlatticeP(wplot,k,epsilon,p,R);
  hap=freqz(flipud(d(:)),d(:),wplot*R);
  max_abs_diff_P=max(abs(unwrap(arg(hap))-P));
  if verbose
    printf("max_abs_diff_P = %g*eps\n",
           max_abs_diff_P/eps);
  endif
  if max_abs_diff_P > 40*eps
    error("max_abs_diff_P > 40*eps");
  endif

  %
  % Check the gradients of the phase
  %
  [P,gradP]=schurOneMAPlatticeP(wplot,k,epsilon,p);
  del=tol;
  wtpl=wplot(ntpl);
  est_dPdk=zeros(1,Nk);
  % Check the gradients of the phase wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    PkP=schurOneMAPlatticeP(wtpl,k+delk,epsilon,p);
    PkM=schurOneMAPlatticeP(wtpl,k-delk,epsilon,p);
    delk=circshift(delk,1);
    est_dPdk(l)=(PkP-PkM)/del;
  endfor
  max_abs_diff_dPdk = max(abs(est_dPdk-gradP(ntpl,:)));
  if verbose
    printf("max_abs_diff_dPdk = del/%g\n", del/max_abs_diff_dPdk);
  endif
  if max_abs_diff_dPdk> del/1000
    error("max_abs_diff_dPdk > del/1000");
  endif

  %
  % Check the diagonal of the Hessian of the phase
  %
  [P,gradP,diagHessP]=schurOneMAPlatticeP(wplot,k,epsilon);
  del=tol;
  wtpl=wplot(ntpl);
  est_diagd2Pdk2=zeros(1,Nk);
  % Check the diagonal of the Hessian of the phase wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    [PkP,gradPkP]=schurOneMAPlatticeP(wtpl,k+delk,epsilon);
    [PkM,gradPkM]=schurOneMAPlatticeP(wtpl,k-delk,epsilon);
    delk=circshift(delk,1);
    est_diagd2Pdk2(l)=(gradPkP(l)-gradPkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the phase
  max_abs_diff_diagd2Pdk2 = ...
    max(abs(est_diagd2Pdk2-diagHessP(ntpl,:)));
  if verbose
    printf("max_abs_diff_diagd2Pdk2 = del/%g\n",
           del/max_abs_diff_diagd2Pdk2);
  endif
  if max_abs_diff_diagd2Pdk2 > del/100
    error("max_abs_diff_diagd2Pdk2 > del/100");
  endif

  %
  % Check the Hessian of the phase
  %
  [P,gradP,diagHessP,hessP]=schurOneMAPlatticeP(wplot,k);
  del=tol;
  wtpl=wplot(ntpl);
  est_d2Pdydx=zeros(Nk,Nk);
  % Check the Hessian of the phase wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    for m=1:Nk
      [PkP,gradPkP]=schurOneMAPlatticeP(wtpl,k+delk);
      [PkM,gradPkM]=schurOneMAPlatticeP(wtpl,k-delk);
      delk=circshift(delk,1);
      est_d2Pdydx(l,m)=(gradPkP(l)-gradPkM(l))/del;
    endfor
  endfor
  % Check the Hessian
  max_abs_diff_d2Pdydx = ...
    max(max(abs(est_d2Pdydx-squeeze(hessP(ntpl,:,:)))));
  if verbose
    printf("max_abs_diff_d2Pdydx = del/%g\n",del/max_abs_diff_d2Pdydx);
  endif
  if max_abs_diff_d2Pdydx > del/100
    error("max_abs_diff_d2Pdydx > del/100");
  endif
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
