% schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq_test.m
% Copyright (C) 2024 Robert G. Jenssen

% Test the series combination of a doubly-pipelined parallel-allpass lattice
% filter and a low-pass anti-aliasing filter. The doubly-pipelined lattice has
% the usual z^-1 replaced by z^-2 with an extra z^-2 output delay. In other
% words, the response of the doubly pipelined filter is scaled by two in
% frequency.

test_common;

strf="schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;

% Angular frequencies
nplot=1000;
wplot=((0:(nplot-1))*pi/nplot)';

% Chebyshev Type-2 anti-aliasing filter
norder_AA=5;
fstop_AA=0.3;
nstop_AA=floor(nplot*fstop_AA/0.5)+1;
dBas_AA=40;
% Anti-aliasing low pass filter lattice decomposition
[Bn,Bd]=cheby2(norder_AA,dBas_AA,2*fstop_AA);
[Bap1,Bap2]=tf2pa(Bn,Bd);
[B1k,~,~,~] = tf2schurOneMlattice(flipud(Bap1(:)),Bap1(:));
[B2k,~,~,~] = tf2schurOneMlattice(flipud(Bap2(:)),Bap2(:));
% Check the expected response of the anti-aliasing filter
HB=freqz(Bn,Bd,wplot(1:nstop_AA));
HBap1=freqz(flipud(Bap1(:)),Bap1(:),wplot(1:nstop_AA));
HBap2=freqz(flipud(Bap2(:)),Bap2(:),wplot(1:nstop_AA));
HBap=(HBap1+HBap2)/2;
if verbose
  printf("max(abs(HB-HBap))=%g\n",max(abs(HB-HBap)));
endif
if max(abs(HB-HBap)) > 2e-14
  error("max(abs(HB-HBap)) > 2e-14");
endif


for difference=[false,true]

  if difference
    mm=-1;
    % Chebyshev Type-2 band-pass filter stop-band edges
    fasl=0.1;fapl=0.125;fapu=0.185;fasu=0.2;dBas=40;tp=16;
    Wap=1;Wtp=0.1;Wpp=0.2;Wdp=0.3;
    % Prototype low-pass filter 
    norder_LP=5;
    [Anp,Adp]=cheby2(norder_LP,dBas,0.5);
    % Prototype low-pass parallel all-pass decomposition
    [Aap1p,Aap2p]=tf2pa(Anp,Adp);
    % Transform to band-pass (before frequency scaling by 0.5)
    phi=2*[fasl,fasu];
    p=phi2p(phi);
    [~,Aap1]=tfp2g(flipud(Aap1p(:)),Aap1p(:),p,-1);
    [~,Aap2]=tfp2g(flipud(Aap2p(:)),Aap2p(:),p,-1);
    % Band-pass filter lattice decomposition
    [A1k,~,~,~] = tf2schurOneMlattice(flipud(Aap1(:)),Aap1(:));
    [A2k,~,~,~] = tf2schurOneMlattice(flipud(Aap2(:)),Aap2(:));
    % Check group delay in the pass-band
    nasl=floor(nplot*fasl/0.5)+1;
    napl=floor(nplot*fapl/0.5)+1;
    napu=floor(nplot*fapu/0.5)+1;
    nasu=floor(nplot*fasu/0.5)+1;
    wcheck=wplot(napl:napu);
    ncheck=length(wcheck);
    % Frequency vectors
    wa=wcheck;
    Asqd=ones(size(wa));
    Wa=Wap*ones(size(wa));
    wt=wcheck;
    Td=tp*ones(size(wt));
    Wt=Wtp*ones(size(wt));
    wp=wcheck;
    Pd=-(tp*wp);
    Wp=Wpp*ones(size(wp));
    wd=wcheck;
    Dd=zeros(size(wd));
    Wd=Wdp*ones(size(wd));
  else
    mm=1;
    % Butterworth low-pass filter specification
    norder_LP=9;
    fpass_LP=0.2;
    tp=16;
    Wap=1;Wtp=0.1;Wpp=0.2;Wdp=0.3;
    % Prototype low pass filter (before frequency scaling by 0.5)
    [An,Ad]=butter(norder_LP,2*(2*fpass_LP));
    % Prototype low pass filter lattice decomposition
    [Aap1,Aap2]=tf2pa(An,Ad);
    [A1k,~,~,~] = tf2schurOneMlattice(flipud(Aap1(:)),Aap1(:));
    [A2k,~,~,~] = tf2schurOneMlattice(flipud(Aap2(:)),Aap2(:));
    % Check group delay in the pass-band
    npass_LP=floor(nplot*fpass_LP/0.5)+1;
    wcheck=wplot(1:npass_LP);
    ncheck=length(wcheck);
    % Frequency vectors
    wa=wcheck;
    Asqd=ones(size(wa));
    Wa=Wap*ones(size(wa));
    wt=wcheck;
    Td=tp*ones(size(wt));
    Wt=Wtp*ones(size(wt));
    wp=wcheck;
    Pd=-(tp*wp);
    Wp=Wpp*ones(size(wp));
    wd=wcheck;
    Dd=zeros(size(wd));
    Wd=Wdp*ones(size(wd));
  endif

  % Initialise ranges
  NA1k=length(A1k);
  NA2k=length(A2k);
  NAk=NA1k+NA2k;
  RA1k=1:NA1k;
  RA2k=NA1k+(1:NA2k);
  NB1k=length(B1k);
  NB2k=length(B2k);
  NBk=NB1k+NB2k;
  RB1k=(NAk)+(1:NB1k);
  RB2k=(NAk+NB1k)+(1:NB2k);
  Nk=NAk+NBk;

  % Select Hessian block diagonal
  test_hess=[ones(NAk),zeros(NAk,NBk); ...
             zeros(NBk,NAk),ones(NBk)];

  %
  % Check the Esq response
  %
  Asq=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
        (wa,A1k,A2k,difference,B1k,B2k);
  AsqErr=Wa.*((Asq-Asqd).^2);
  AsqErrSum=sum(diff(wa).*(AsqErr(1:(end-1))+AsqErr(2:end)))/2;
  
  T=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
      (wt,A1k,A2k,difference,B1k,B2k);
  TErr=Wt.*((T-Td).^2);
  TErrSum=sum(diff(wt).*(TErr(1:(end-1))+TErr(2:end)))/2; 

  P=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
      (wp,A1k,A2k,difference,B1k,B2k);
  PErr=Wp.*((P-Pd).^2);
  PErrSum=sum(diff(wp).*(PErr(1:(end-1))+PErr(2:end)))/2;

  D=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
      (wd,A1k,A2k,difference,B1k,B2k);
  DErr=Wd.*((D-Dd).^2);
  DErrSum=sum(diff(wd).*(DErr(1:(end-1))+DErr(2:end)))/2;

  Esq=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
        (A1k,A2k,difference,B1k,B2k, ...
         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

  EsqErrSum=AsqErrSum+TErrSum+PErrSum+DErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq)=%g*eps\n",abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > 2000*eps
    error("abs(EsqErrSum-Esq) > 2000*eps");
  endif

  %
  % Check the gradients of Esq wrt k
  %
  [~,gradEsq]=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq...
                (A1k,A2k,difference,B1k,B2k, ...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  del=1e-6;
  k=[A1k,A2k,B1k,B2k];
  delk=zeros(size(k));
  delk(1)=del/2;
  diff_Esqk=zeros(1,Nk);
  for l=1:Nk
    EsqkP=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
            (A1k+delk(RA1k),A2k+delk(RA2k),difference, ...
             B1k+delk(RB1k),B2k+delk(RB2k), ...
             wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    EsqkM=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
            (A1k-delk(RA1k),A2k-delk(RA2k),difference, ...
             B1k-delk(RB1k),B2k-delk(RB2k), ...
             wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    delk=circshift(delk,1);
    diff_Esqk(l)=(EsqkP-EsqkM)/del;
  endfor
  if verbose
    printf("max(abs(diff_Esqk-gradEsq))=%g*del\n", ...
           max(abs(diff_Esqk-gradEsq))/del);
  endif
  if max(abs(diff_Esqk-gradEsq)) > del/20
    error("max(abs(diff_Esqk-gradEsq)) > del/20");
  endif

  %
  % Check the diagonal of the Hessian, diagHessEsq, wrt k
  %
  [~,~,diagHessEsq]=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
                      (A1k,A2k,difference,B1k,B2k, ...
                       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  del=1e-6;
  k=[A1k,A2k,B1k,B2k];
  delk=zeros(size(k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(1,Nk);
  for l=1:Nk
    [~,gradEsqkP]=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
                    (A1k+delk(RA1k),A2k+delk(RA2k),difference, ...
                     B1k+delk(RB1k),B2k+delk(RB2k), ...
                     wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    [~,gradEsqkM]=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
                    (A1k-delk(RA1k),A2k-delk(RA2k),difference, ...
                     B1k-delk(RB1k),B2k-delk(RB2k), ...
                     wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    delk=circshift(delk,1);
    diff_gradEsqk(l)=(gradEsqkP(l)-gradEsqkM(l))/del;
  endfor
  if verbose
    printf("max(abs(diff_gradEsqk-diagHessEsq))=%g*del\n", ...
           max(abs(diff_gradEsqk-diagHessEsq))/del);
  endif
  if max(abs(diff_gradEsqk-diagHessEsq)) > 10*del
    error("max(abs(diff_gradEsqk-diagHessEsq)) > 10*del");
  endif
  
  %
  % Check the Hessian of Esq wrt k
  %
  [~,~,~,hessEsq]=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
                    (A1k,A2k,difference,B1k,B2k, ...
                     wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  del=1e-6;
  k=[A1k,A2k,B1k,B2k];
  delk=zeros(size(k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(Nk);
  for l=1:Nk
    [~,gradEsqkP]=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
                    (A1k+delk(RA1k),A2k+delk(RA2k),difference, ...
                     B1k+delk(RB1k),B2k+delk(RB2k), ...
                     wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    [~,gradEsqkM]=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
                    (A1k-delk(RA1k),A2k-delk(RA2k),difference, ...
                     B1k-delk(RB1k),B2k-delk(RB2k), ...
                     wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    delk=circshift(delk,1);
    diff_gradEsqk(l,:)=(gradEsqkP-gradEsqkM)/del;
  endfor

  % Blocks on the diagonal
  max_diff_hessEsqk=max(max(abs(hessEsq-(diff_gradEsqk.*test_hess))));
  if verbose
    printf("max_diff_hessEsqk=%g*del\n",max_diff_hessEsqk/del);
  endif
  if max_diff_hessEsqk > 5*del
    error("max_diff_hessEsqk(%g*del) > 5*del\n",max_diff_hessEsqk/del);
  endif

  % Blocks off the diagonal are expected to be zero
  max_diff_gradEsqk= ...
    max(max(abs((hessEsq-diff_gradEsqk).*(test_hess==0))))*del;
  if verbose
    printf("max_diff_gradEsqk=%g\n",max_diff_gradEsqk);
  endif
  if max_diff_gradEsqk > 2e-4
    error("max_diff_gradEsqk(%g) > 2e-4\n",max_diff_gradEsqk);
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
