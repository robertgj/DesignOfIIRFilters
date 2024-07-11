% schurOneMlatticeEsq_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="schurOneMlatticeEsq_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;

for x=1:2,
  
  if x==1
    N=3;fap=0.15;fas=0.25;dBas=30;
    [n,d]=cheby2(N,dBas,fas*2);
    tp=2.5;
    Wap=1;Was=20;Wtp=0.1;Wpp=10;
    % Desired magnitude-squared response
    nplot=500;
    wa=(0:(nplot-1))'*pi/nplot;
    nap=floor(nplot*fap/0.5)+1;
    nas=ceil(nplot*fas/0.5)+1;
    Asqd=[ones(nap+1,1); ...
          zeros(nplot-nap-1,1)];
    Wa=[Wap*ones(nap,1); ...
        zeros(nas-nap-1,1); ...
        Was*ones(nplot-nas+1,1)];
    % Desired group delay response
    ntp=floor(nplot*fap/0.5)+1;
    wt=(1:ntp)'*pi/nplot;
    ntp=length(wt);
    Td=tp*ones(ntp,1);
    Wt=Wtp*ones(ntp,1);
    % Desired phase response
    wp=wt;
    h=freqz(n,d,wp);
    P=unwrap(arg(h));
    Pd=((wp-wp(1))*((P(end)-P(1))/(wp(end)-wp(1))))+P(1);
    Wp=Wpp*ones(length(wp),1);
  else
    % R=2 bandpass filter
    fapl=0.1;fapu=0.2;Wap=10;
    fasl=0.05;fasu=0.25;Wasl=20;Wasu=20;
    ftpl=0.09;ftpu=0.21;tp=16;Wtp=100;
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
    % Desired magnitude-squared response
    nplot=500;
    wa=(0:(nplot-1))'*pi/nplot;
    nasl=ceil(nplot*fasl/0.5)+1;
    napl=floor(nplot*fapl/0.5)+1;
    napu=ceil(nplot*fapu/0.5)+1;
    nasu=floor(nplot*fasu/0.5)+1;
    Asqd=[zeros(napl-1,1); ...
          ones(napu-napl+1,1); ...
          zeros(nplot-napu,1)];
    Wa=[Wasl*ones(nasl,1); ...
        zeros(napl-nasl-1,1); ...
        Wap*ones(napu-napl+1,1); ...
        zeros(nasu-napu-1,1); ...
        Wasu*ones(nplot-nasu+1,1)];
    % Desired group delay response
    ntpl=floor(nplot*ftpl/0.5);
    ntpu=ceil(nplot*ftpu/0.5);
    wt=(ntpl:ntpu)'*pi/nplot;
    ntp=length(wt);
    Td=tp*ones(ntp,1);
    Wt=Wtp*ones(ntp,1);
    % Desired phase response
    wp=wt;
    h=freqz(n,d,wp);
    P=unwrap(atan2(imag(h),real(h)));
    Pd=((wp-wp(1))*((P(end)-P(1))/(wp(end)-wp(1))))+P(1);
    Wpp=1e4;
    Wp=Wpp*ones(length(wp),1);
  endif

  % Convert filter transfer function to Schur 1-multiplier lattice form
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  Nk=length(k);
  Nc=length(c);
  Nkc=Nk+Nc;
  [Esq,gradEsq,diagHessEsq,hessEsq]=...
    schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

  %
  % Check the squared-error response
  %
  Asq=schurOneMlatticeAsq(wa,k,epsilon,p,c);
  AsqErr=Wa.*((Asq-Asqd).^2);
  AsqErrSum=sum(diff(wa).*(AsqErr(1:(length(wa)-1))+AsqErr(2:end)))/2;
  T=schurOneMlatticeT(wt,k,epsilon,p,c);
  TErr=Wt.*((T-Td).^2);  
  TErrSum=sum(diff(wt).*(TErr(1:(length(wt)-1))+TErr(2:end)))/2;
  P=schurOneMlatticeP(wp,k,epsilon,p,c);
  PErr=Wp.*((P-Pd).^2);  
  PErrSum=sum(diff(wp).*(PErr(1:(length(wp)-1))+PErr(2:end)))/2;
  if verbose
    printf("abs(AsqErrSum+TErrSum+PErrSum-Esq) = %g*eps\n",
           abs(AsqErrSum+TErrSum+PErrSum-Esq)/eps);
  endif
  if abs(AsqErrSum+TErrSum+PErrSum-Esq) > eps
    error("abs(AsqErrSum+TErrSum+PErrSum-Esq) > eps");
  endif

  %
  % Check the gradients of the squared-error
  %
  del=1e-6;
  est_dEsqdkc=zeros(1,Nkc);
  % Check the gradients of the squared-error wrt k
  delk=zeros(1,Nk);
  delk(1)=del/2;
  for l=1:Nk
    EsqkP=schurOneMlatticeEsq(k+delk,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqkM=schurOneMlatticeEsq(k-delk,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delk=circshift(delk,1);
    est_dEsqdkc(l)=(EsqkP-EsqkM)/del;
  endfor
  % Check the gradient of the squared-error response wrt c
  delc=zeros(1,length(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    EsqcP=schurOneMlatticeEsq(k,epsilon,p,c+delc,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    EsqcM=schurOneMlatticeEsq(k,epsilon,p,c-delc,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delc=circshift(delc,1);
    est_dEsqdkc(l)=(EsqcP-EsqcM)/del;
  endfor
  % Check the gradient of the squared-error response
  if verbose
    printf("max(abs(est_dEsqdkc-gradEsq)) = del/%g\n",
           del/max(abs(est_dEsqdkc-gradEsq)));
  endif
  if max(abs(est_dEsqdkc-gradEsq)) > del/100
    error("max(abs(est_dEsqdkc-gradEsq)) > del/100");
  endif

  %
  % Check the diagonal of the Hessian of the squared-error
  %
  del=1e-6;
  est_diagd2Esqdkc2=zeros(1,Nkc);
  % Check the diagonal of the Hessian of the squared-error wrt k
  delk=zeros(1,length(k));
  delk(1)=del/2;
  for l=1:Nk
    [EsqkP,gradEsqkP] = ...
        schurOneMlatticeEsq(k+delk,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqkM,gradEsqkM] = ...
      schurOneMlatticeEsq(k-delk,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delk=circshift(delk,1);
    est_diagd2Esqdkc2(l)=(gradEsqkP(l)-gradEsqkM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the squared-error wrt c
  delc=zeros(1,length(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc
    [EsqcP,gradEsqcP] = ...
        schurOneMlatticeEsq(k,epsilon,p,c+delc,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [EsqcM,gradEsqcM] = ...
      schurOneMlatticeEsq(k,epsilon,p,c-delc,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delc=circshift(delc,1);
    est_diagd2Esqdkc2(l)=(gradEsqcP(l)-gradEsqcM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the squared-error wrt k
  if verbose
    printf("max(abs(est_diagd2Esqdkc2-diagHessEsq)) = %g*del\n",
           max(abs(est_diagd2Esqdkc2-diagHessEsq))/del);
  endif
  if max(abs(est_diagd2Esqdkc2-diagHessEsq)) > 4*del
    error("max(abs(est_diagd2Esqdkc2-diagHessEsq)) > 4*del");
  endif

  %
  % Check the Hessian of the squared-error
  %
  del=1e-6;
  est_d2Esqdydx=zeros(Nkc,Nkc);
  % Check the Hessian of the squared-error wrt k
  delk=zeros(1,length(k));
  delk(1)=del/2;
  for l=1:Nk,
    for m=1:Nk,
      [EsqkP,gradEsqkP] = ...
          schurOneMlatticeEsq(k+delk,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      [EsqkM,gradEsqkM] = ...
        schurOneMlatticeEsq(k-delk,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      delk=circshift(delk,1);
      est_d2Esqdydx(l,m)=(gradEsqkP(l)-gradEsqkM(l))/del;
    endfor
  endfor
  % Check the Hessian of the squared-error wrt c
  delc=zeros(1,length(c));
  delc(1)=del/2;
  for l=(Nk+1):Nkc,
    for m=(Nk+1):Nkc,
      [EsqcP,gradEsqcP] = ...
          schurOneMlatticeEsq(k,epsilon,p,c+delc,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      [EsqcM,gradEsqcM] = ...
        schurOneMlatticeEsq(k,epsilon,p,c-delc,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      delc=circshift(delc,1);
      est_d2Esqdydx(l,m)=(gradEsqcP(l)-gradEsqcM(l))/del;
    endfor
  endfor
  % Check the Hessian of the squared-error wrt k and c
  delk=zeros(1,length(k));
  delk(1)=del/2;
  for l=(Nk+1):Nkc,
    for m=1:Nk,
      [EsqckP,gradEsqckP] = ...
          schurOneMlatticeEsq(k+delk,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      [EsqckM,gradEsqckM] = ...
        schurOneMlatticeEsq(k-delk,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      delk=circshift(delk,1);
      est_d2Esqdydx(l,m)=(gradEsqckP(l)-gradEsqckM(l))/del;
    endfor
  endfor
  delc=zeros(1,length(c));
  delc(1)=del/2;
  for l=1:Nk,
    for m=(Nk+1):Nkc,
      [EsqkcP,gradEsqkcP] = ...
          schurOneMlatticeEsq(k,epsilon,p,c+delc,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      [EsqkcM,gradEsqkcM] = ...
        schurOneMlatticeEsq(k,epsilon,p,c-delc,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      delc=circshift(delc,1);
      est_d2Esqdydx(l,m)=(gradEsqkcP(l)-gradEsqkcM(l))/del;
    endfor
  endfor
  % Check the Hessian of the squared-error
  if verbose
    printf("max(max(abs(est_d2Esqdydx-hessEsq))) = %g*del\n",
           max(max(abs(est_d2Esqdydx-hessEsq)))/del);
  endif
  if max(max(abs(est_d2Esqdydx-hessEsq))) > 10*del
    error("max(max(abs(est_d2Esqdydx-hessEsq))) > 10*del");
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
