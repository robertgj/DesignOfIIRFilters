% schurOneMPAlatticeDoublyPipelinedAntiAliasedP_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

% Test the series combination of a doubly-pipelined parallel-allpass lattice
% filter and a low-pass anti-aliasing filter. The doubly-pipelined lattice has
% the usual z^-1 replaced by z^-2 with an extra z^-2 output delay. In other
% words, the response of the doubly pipelined filter is scaled by two in
% frequency.

test_common;

strf="schurOneMPAlatticeDoublyPipelinedAntiAliasedP_test";
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
% Check the expected phase response of the anti-aliasing filter
HB=freqz(Bn,Bd,wplot(1:nstop_AA));
PB=unwrap(arg(HB));
HBap1=freqz(fliplr(Bap1),Bap1,wplot(1:nstop_AA));
HBap2=freqz(fliplr(Bap2),Bap2,wplot(1:nstop_AA));
PBap=unwrap(arg((HBap1+HBap2)/2));
if verbose
  printf("max(abs(PB-PBap))=%g\n",max(abs(PB-PBap)));
endif
if max(abs(PB-PBap)) > 2e-14
  error("max(abs(PB-PBap)) > 2e-14");
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
  % Check the P response
  %
  P=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
        (wcheck,A1k,A2k,difference,B1k,B2k);
  HAap1=freqz(flipud(Aap1(:)),Aap1(:),wcheck*2);
  HAap2=freqz(flipud(Aap2(:)),Aap2(:),wcheck*2);
  PA=unwrap(arg((HAap1+(mm*HAap2))/2))-(2*wcheck);
  HB=freqz(Bn,Bd,wcheck);
  PB=unwrap(arg(HB));
  PP=PA+PB;
  if verbose
    printf("max(abs(PP-P))=%g*eps\n",max(abs(PP-P))/eps);
  endif
  if max(abs(PP-P)) > 100*eps
    error("max(abs(PP-P)) > 100*eps");
  endif

  %
  % Check the gradients of P wrt k
  %
  [~,gradP]=schurOneMPAlatticeDoublyPipelinedAntiAliasedP...
                (wcheck,A1k,A2k,difference,B1k,B2k);
  del=1e-6;
  k=[A1k,A2k,B1k,B2k];
  delk=zeros(size(k));
  delk(1)=del/2;
  diff_Pk=zeros(ncheck,Nk);
  for l=1:Nk
    PkP=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
            (wcheck,A1k+delk(RA1k),A2k+delk(RA2k),difference, ...
             B1k+delk(RB1k),B2k+delk(RB2k));
    PkM=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
            (wcheck,A1k-delk(RA1k),A2k-delk(RA2k),difference, ...
             B1k-delk(RB1k),B2k-delk(RB2k));
    delk=circshift(delk,1);
    diff_Pk(:,l)=(PkP-PkM)/del;
  endfor
  if verbose
    printf("max(max(abs(diff_Pk-gradP)))=%g*del\n", ...
           max(max(abs(diff_Pk-gradP)))/del);
  endif
  if max(max(abs(diff_Pk-gradP))) > del/200
    error("max(max(abs(diff_Pk-gradP))) > del/200");
  endif

  %
  % Check the diagonal of the Hessian, diagHessP, wrt k
  %
  [~,~,diagHessP]=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
                      (wcheck,A1k,A2k,difference,B1k,B2k);
  del=1e-6;
  k=[A1k,A2k,B1k,B2k];
  delk=zeros(size(k));
  delk(1)=del/2;
  diff_gradPk=zeros(ncheck,Nk);
  for l=1:Nk
    [~,gradPkP]=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
                    (wcheck,A1k+delk(RA1k),A2k+delk(RA2k),difference, ...
                     B1k+delk(RB1k),B2k+delk(RB2k));
    [~,gradPkM]=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
                    (wcheck,A1k-delk(RA1k),A2k-delk(RA2k),difference, ...
                     B1k-delk(RB1k),B2k-delk(RB2k));
    delk=circshift(delk,1);
    diff_gradPk(:,l)=(gradPkP(:,l)-gradPkM(:,l))/del;
  endfor
  if verbose
    printf("max(max(abs(diff_gradPk-diagHessP)))=%g*del\n", ...
           max(max(abs(diff_gradPk-diagHessP)))/del);
  endif
  if max(max(abs(diff_gradPk-diagHessP))) > del/5
    error("max(max(abs(diff_gradPk-diagHessP))) > del/5");
  endif

  %
  % Check the Hessian of P wrt k
  %
  [~,~,~,hessP]=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
                    (wcheck,A1k,A2k,difference,B1k,B2k);
  del=1e-6;
  k=[A1k,A2k,B1k,B2k];
  delk=zeros(size(k));
  delk(1)=del/2;
  diff_gradPk=zeros(ncheck,Nk,Nk);
  for l=1:Nk
    [~,gradPkP]=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
                    (wcheck,A1k+delk(RA1k),A2k+delk(RA2k),difference, ...
                     B1k+delk(RB1k),B2k+delk(RB2k));
    [~,gradPkM]=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
                    (wcheck,A1k-delk(RA1k),A2k-delk(RA2k),difference, ...
                     B1k-delk(RB1k),B2k-delk(RB2k));
    delk=circshift(delk,1);
    diff_gradPk(:,l,:)=(gradPkP-gradPkM)/del;
  endfor

  % Blocks on the diagonal
  max_diff_hessPk=max(max(max(abs(hessP-(diff_gradPk.*test_hess)))));
  if verbose
    printf("max_diff_hessPk=%g*del\n",max_diff_hessPk/del);
  endif
  if max_diff_hessPk > del/5
    error("max_diff_hessPk(%g*del) > del/5\n",max_diff_hessPk/del);
  endif

  % Blocks off the diagonal are expected to be zero
  max_diff_gradPk= ...
    max(max(max(abs((hessP-diff_gradPk).*(test_hess==0)))))*del;
  if verbose
    printf("max_diff_gradPk=%g\n",max_diff_gradPk);
  endif
  if max_diff_gradPk > 50*del
    error("max_diff_gradPk(%g) > 50*del\n",max_diff_gradPk);
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
