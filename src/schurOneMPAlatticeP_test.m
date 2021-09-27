% schurOneMPAlatticeP_test.m
% Copyright (C) 2017-2021 Robert G. Jenssen

test_common;

delete("schurOneMPAlatticeP_test.diary");
delete("schurOneMPAlatticeP_test.diary.tmp");
diary schurOneMPAlatticeP_test.diary.tmp

tol=1e-8;

for m=1:2
  
  schurOneMPAlattice_test_common;

  % Find the phase
  P=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

  % Check the phase response
  Hab1=freqz(Nab1,Dab1,wa);
  Pab1=unwrap(arg(Hab1(Prng)));
  if max(abs(Pab1-P)) > tol
    error("max(abs(Pab1-P)) > tol");
  endif

  % Find the gradients of P
  [P,gradP]=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                difference);
  
  % Check the gradients of the phase response wrt A1k
  del=tol*100;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_Pk=zeros(length(Prng),length(A1k));
  for l=1:length(A1k)
    PkPdel2=schurOneMPAlatticeP(wp,A1k+delk,A1epsilon,A1p,A2k,A2epsilon,A2p,...
                                difference);
    PkMdel2=schurOneMPAlatticeP(wp,A1k-delk,A1epsilon,A1p,A2k,A2epsilon,A2p,...
                                difference);
    delk=shift(delk,1);
    diff_Pk(:,l)=(PkPdel2-PkMdel2)/del;
  endfor
  if max(max(abs(diff_Pk-gradP(:,A1rng)))) > tol
    error("max(max(abs(diff_Pk-gradP(:,A1rng)))) > tol");
  endif

  % Check the gradients of the phase response wrt A2k
  del=tol*100;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_Pk=zeros(length(Prng),length(A2k));
  for l=1:length(A2k)
    PkPdel2=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,A2k+delk,A2epsilon,A2p,...
                                difference);
    PkMdel2=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,A2k-delk,A2epsilon,A2p,...
                                difference);
    delk=shift(delk,1);
    diff_Pk(:,l)=(PkPdel2-PkMdel2)/del;
  endfor
  if max(max(abs(diff_Pk-gradP(:,A2rng)))) > tol
    error("max(max(abs(diff_Pk-gradP(:,A2rng)))) > tol");
  endif

  % Find diagHessP
  [P,gradP,diagHessP]=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p, ...
                                          A2k,A2epsilon,A2p,difference);

  % Check the Hessian of the phase response wrt A1k
  del=tol*100;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradPk=zeros(length(Prng),length(A1k));
  for l=1:length(A1k)
    [PkPdel2,gradPkPdel2]=schurOneMPAlatticeP(wp,A1k+delk,A1epsilon,A1p, ...
                                              A2k,A2epsilon,A2p,difference);
    [PkMdel2,gradPkMdel2]=schurOneMPAlatticeP(wp,A1k-delk,A1epsilon,A1p, ...
                                              A2k,A2epsilon,A2p,difference);
    delk=shift(delk,1);
    diff_gradPk(:,l)=(gradPkPdel2(:,l)-gradPkMdel2(:,l))/del;
  endfor
  if max(max(abs(diff_gradPk-diagHessP(:,A1rng)))) > 3*tol
    error("max(max(abs(diff_gradPk-diagHessP(,A1rng)))) > 3*tol");
  endif

  % Check the Hessian of the phase response wrt A2k
  del=tol*100;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradPk=zeros(length(Prng),length(A2k));
  for l=1:length(A2k)
    [PkPdel2,gradPkPdel2]=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p, ...
                                              A2k+delk,A2epsilon,A2p,difference);
    [PkMdel2,gradPkMdel2]=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p, ...
                                              A2k-delk,A2epsilon,A2p,difference);
    delk=shift(delk,1);
    diff_gradPk(:,l)=(gradPkPdel2(:,length(A1k)+l)-...
                      gradPkMdel2(:,length(A1k)+l))/del;
  endfor
  if max(max(abs(diff_gradPk-diagHessP(:,A2rng)))) > 3*tol
    error("max(max(abs(diff_gradPk-diagHessP(,A2rng)))) > 3*tol");
  endif
  
endfor

% Done
diary off
movefile schurOneMPAlatticeP_test.diary.tmp schurOneMPAlatticeP_test.diary;
