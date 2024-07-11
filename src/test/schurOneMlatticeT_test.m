% schurOneMlatticeT_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMlatticeT_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2
  if x==1
    N=3;
    ftpl=0.1;
    [n,d]=butter(N,ftpl*2);
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
  endif

  nplot=1024;
  ntpl=floor(nplot*ftpl/0.5);
  fplot=(0:(nplot/2))'/nplot;
  wplot=pi*fplot;
  t=delayz(n,d,wplot);

  % Convert filter transfer function to Schur 1-multiplier lattice form
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  Nk=length(k);
  Nc=length(c);
  Nkc=length(k)+Nc;
  [T,gradT,diagHessT,hessT]=schurOneMlatticeT(wplot,k,epsilon,p,c);

  %
  % Check the group-delay response
  %
  max_abs_diff_T=max(abs(t-T));
  if verbose
    printf("max_abs_diff_T = %g*eps\n",
           max_abs_diff_T/eps);
  endif
  if max_abs_diff_T > 2e5*eps
    error("max_abs_diff_T > 2e5*eps");
  endif

  %
  % Check the gradients of the group-delay
  %
  del=1e-6;
  wtpl=wplot(ntpl);
  est_dTdkc=zeros(1,Nkc);
  % Check the gradients of the group-delay wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    TkP=schurOneMlatticeT(wtpl,k+delk,epsilon,p,c);
    TkM=schurOneMlatticeT(wtpl,k-delk,epsilon,p,c);
    delk=circshift(delk,1);
    est_dTdkc(l)=(TkP-TkM)/del;
  endfor
  % Check the gradient of the group-delay response wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    TcP=schurOneMlatticeT(wtpl,k,epsilon,p,c+delc);
    TcM=schurOneMlatticeT(wtpl,k,epsilon,p,c-delc);
    delc=circshift(delc,1);
    est_dTdkc(l)=(TcP-TcM)/del;
  endfor
  max_abs_diff_dTdkc = max(abs(est_dTdkc-gradT(ntpl,:)));
  if verbose
    printf("max_abs_diff_dTdkc = del/%g\n", del/max_abs_diff_dTdkc);
  endif
  if max_abs_diff_dTdkc> del/50
    error("max_abs_diff_dTdkc > del/50");
  endif

  %
  % Check the diagonal of the Hessian of the group-delay
  %
  del=1e-6;
  wtpl=wplot(ntpl);
  est_diagd2Tdkc2=zeros(1,Nkc);
  % Check the diagonal of the Hessian of the group-delay wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    [TkP,gradTkP]=schurOneMlatticeT(wtpl,k+delk,epsilon,p,c);
    [TkM,gradTkM]=schurOneMlatticeT(wtpl,k-delk,epsilon,p,c);
    delk=circshift(delk,1);
    est_diagd2Tdkc2(l)=(gradTkP(l)-gradTkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the group-delay wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    [TkP,gradTkP]=schurOneMlatticeT(wtpl,k,epsilon,p,c+delc);
    [TkM,gradTkM]=schurOneMlatticeT(wtpl,k,epsilon,p,c-delc);
    delc=circshift(delc,1);
    est_diagd2Tdkc2(l)=(gradTkP(l)-gradTkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the group-delay
  max_abs_diff_diagd2Tdkc2 = ...
    max(abs(est_diagd2Tdkc2-diagHessT(ntpl,:)));
  if verbose
    printf("max_abs_diff_diagd2Tdkc2 = del/%g\n",
           del/max_abs_diff_diagd2Tdkc2);
  endif
  if max_abs_diff_diagd2Tdkc2 > del/10
    error("max_abs_diff_diagd2Tdkc2 > del/10");
  endif

  %
  % Check the Hessian of the group-delay
  %
  del=1e-6;
  wtpl=wplot(ntpl);
  est_d2Tdydx=zeros(Nkc,Nkc);
  % Check the Hessian of the group-delay wrt k
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=1:Nk
    for m=1:Nk
      [TkP,gradTkP]=schurOneMlatticeT(wtpl,k+delk,epsilon,p,c);
      [TkM,gradTkM]=schurOneMlatticeT(wtpl,k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      est_d2Tdydx(l,m)=(gradTkP(l)-gradTkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the group-delay wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    for m=(Nk+1):Nkc
      [TkP,gradTkP]=schurOneMlatticeT(wtpl,k,epsilon,p,c+delc);
      [TkM,gradTkM]=schurOneMlatticeT(wtpl,k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      est_d2Tdydx(l,m)=(gradTkP(l)-gradTkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the group-delay wrt k and c
  delc=zeros(size(c));
  delc(1)=del/2;
  for l=1:Nk
    for m=(Nk+1):Nkc
      [TkP,gradTkP]=schurOneMlatticeT(wtpl,k,epsilon,p,c+delc);
      [TkM,gradTkM]=schurOneMlatticeT(wtpl,k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      est_d2Tdydx(l,m)=(gradTkP(l)-gradTkM(l))/del;
    endfor
  endfor
  delk=zeros(size(k));
  delk(1)=del/2;
  for l=(Nk+1):Nkc
    for m=1:Nk
      [TkP,gradTkP]=schurOneMlatticeT(wtpl,k+delk,epsilon,p,c);
      [TkM,gradTkM]=schurOneMlatticeT(wtpl,k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      est_d2Tdydx(l,m)=(gradTkP(l)-gradTkM(l))/del;
    endfor
  endfor
  % Check the Hessian
  max_abs_diff_d2Tdydx = ...
    max(max(abs(est_d2Tdydx-squeeze(hessT(ntpl,:,:)))));
  if verbose
    printf("max_abs_diff_d2Tdydx = del/%g\n",del/max_abs_diff_d2Tdydx);
  endif
  if max_abs_diff_d2Tdydx > del/5
    error("max_abs_diff_d2Tdydx > del/5");
  endif
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
