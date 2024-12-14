% schurOneMPAlatticeDoublyPipelinedAntiAliasedT_test.m
% Copyright (C) 2024 Robert G. Jenssen

% Test the series combination of a doubly-pipelined parallel-allpass lattice
% filter and a low-pass anti-aliasing filter. The doubly-pipelined lattice has
% the usual z^-1 replaced by z^-2 with an extra z^-2 output delay. In other
% words, the response of the doubly pipelined filter is scaled by two in
% frequency.

test_common;

strf="schurOneMPAlatticeDoublyPipelinedAntiAliasedT_test";
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
% Check the expected group-delay response of the anti-aliasing filter
TB=delayz(Bn,Bd,wplot(1:nstop_AA));
TBap1=delayz(flipud(Bap1(:)),Bap1(:),wplot(1:nstop_AA));
TBap2=delayz(flipud(Bap2(:)),Bap2(:),wplot(1:nstop_AA));
TBap=(TBap1+TBap2)/2;
if verbose
  printf("max(abs(TB-TBap))=%g\n",max(abs(TB-TBap)));
endif
if max(abs(TB-TBap)) > 2e-12
  error("max(abs(TB-TBap)) > 2e-12");
endif


for difference=[false,true]
  
  if difference
    mm=-1;
    % Chebyshev Type-2 band-pass filter stop-band edges
    fasl=0.1;fapl=0.125;fapu=0.185;fasu=0.2;dBas=40;
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
  else
    mm=1;
    % Butterworth low-pass filter specification
    norder_LP=9;
    fpass_LP=0.2;
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
  test_hess=permute(reshape(kron(ones(1,ncheck), ...
                                 [ones(NAk),zeros(NAk,NBk); ...
                                  zeros(NBk,NAk),ones(NBk)]), ...
                            Nk,Nk,ncheck), ...
                    [3,2,1]);


  %
  % Check the T response
  %
  T=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
        (wcheck,A1k,A2k,difference,B1k,B2k);
  TAap1=delayz(fliplr(Aap1),Aap1,wcheck*2);
  TAap2=delayz(fliplr(Aap2),Aap2,wcheck*2);
  TA=(TAap1+TAap2)/2;
  TB=delayz(Bn,Bd,wcheck);
  TT=((2*TA)+2)+TB;
  if verbose
    printf("max(abs(TT-T))=%g\n",max(abs(TT-T)));
  endif
  if max(abs(TT-T)) > 1e-8
    error("max(abs(TT-T)) > 1e-8");
  endif

  %
  % Check the gradients of T wrt k
  %
  [~,gradT]=schurOneMPAlatticeDoublyPipelinedAntiAliasedT...
                  (wcheck,A1k,A2k,difference,B1k,B2k);
  del=1e-6;
  k=[A1k,A2k,B1k,B2k];
  delk=zeros(size(k));
  delk(1)=del/2;
  diff_Tk=zeros(ncheck,Nk);
  for l=1:Nk
    TkP=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
            (wcheck,A1k+delk(RA1k),A2k+delk(RA2k),difference, ...
             B1k+delk(RB1k),B2k+delk(RB2k));
    TkM=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
            (wcheck,A1k-delk(RA1k),A2k-delk(RA2k),difference, ...
             B1k-delk(RB1k),B2k-delk(RB2k));
    delk=circshift(delk,1);
    diff_Tk(:,l)=(TkP-TkM)/del;
  endfor
  if verbose
    printf("max(max(abs(diff_Tk-gradT)))=%g*del\n", ...
           max(max(abs(diff_Tk-gradT)))/del);
  endif
  if max(max(abs(diff_Tk-gradT))) > del/10
    error("max(max(abs(diff_Tk-gradT))) > del/10");
  endif

  %
  % Check the diagonal of the Hessian, diagHessT, wrt k
  %
  [~,~,diagHessT]=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
                      (wcheck,A1k,A2k,difference,B1k,B2k);
  del=1e-6;
  k=[A1k,A2k,B1k,B2k];
  delk=zeros(size(k));
  delk(1)=del/2;
  diff_gradTk=zeros(ncheck,Nk);
  for l=1:Nk
    [~,gradTkP]=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
                    (wcheck,A1k+delk(RA1k),A2k+delk(RA2k),difference, ...
                     B1k+delk(RB1k),B2k+delk(RB2k));
    [~,gradTkM]=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
                    (wcheck,A1k-delk(RA1k),A2k-delk(RA2k),difference, ...
                     B1k-delk(RB1k),B2k-delk(RB2k));
    delk=circshift(delk,1);
    diff_gradTk(:,l)=(gradTkP(:,l)-gradTkM(:,l))/del;
  endfor
  if verbose
    printf("max(max(abs(diff_gradTk-diagHessT)))=%g*del\n", ...
           max(max(abs(diff_gradTk-diagHessT)))/del);
  endif
  if max(max(abs(diff_gradTk-diagHessT))) > 10*del
    error("max(max(abs(diff_gradTk-diagHessT))) > 10*del");
  endif

  %
  % Check the Hessian of T wrt k
  %
  [~,~,~,hessT]=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
                    (wcheck,A1k,A2k,difference,B1k,B2k);
  del=1e-6;
  k=[A1k,A2k,B1k,B2k];
  delk=zeros(size(k));
  delk(1)=del/2;
  diff_gradTk=zeros(ncheck,Nk,Nk);
  for l=1:Nk
    [~,gradTkP]=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
                    (wcheck,A1k+delk(RA1k),A2k+delk(RA2k),difference, ...
                     B1k+delk(RB1k),B2k+delk(RB2k));
    [~,gradTkM]=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
                    (wcheck,A1k-delk(RA1k),A2k-delk(RA2k),difference, ...
                     B1k-delk(RB1k),B2k-delk(RB2k));
    delk=circshift(delk,1);
    diff_gradTk(:,l,:)=(gradTkP-gradTkM)/del;
  endfor

  % Blocks on the diagonal
  max_diff_hessTk=max(max(max(abs(hessT-(diff_gradTk.*test_hess)))));
  if verbose
    printf("max_diff_hessTk=%g*del\n",max_diff_hessTk/del);
  endif
  if max_diff_hessTk > 10*del
    error("max_diff_hessTk(%g*del) > 10*del\n",max_diff_hessTk/del);
  endif

  % Blocks off the diagonal are expected to be zero
  max_diff_gradTk= ...
    max(max(max(abs((hessT-diff_gradTk).*(test_hess==0)))))*del;
  if max_diff_gradTk > del
    error("max_diff_gradTk(%g) > del\n",max_diff_gradTk);
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
