% schurOneMPAlatticeT_test.m
% Copyright (C) 2017-2023 Robert G. Jenssen

test_common;

delete("schurOneMPAlatticeT_test.diary");
delete("schurOneMPAlatticeT_test.diary.tmp");
diary schurOneMPAlatticeT_test.diary.tmp

tol=1e-8;

for m=1:2
  
  schur_parallel_allpass_lattice_test_common;
  
  % Lattice decomposition
  [A1k,A1epsilon,A1p,~] = tf2schurOneMlattice(flipud(Da1),Da1);
  [A2k,A2epsilon,A2p,~] = tf2schurOneMlattice(flipud(Db1),Db1);

  A1rng=1:length(A1k);
  A2rng=(length(A1k)+1):(length(A1k)+length(A2k));

  % Find the group delay
  T=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

  % Check the group delay response
  Tab1=delayz(Nab1,Dab1,wa);
  Tab1=Tab1(Trng);
  if max(abs(Tab1-T)) > 16*tol
    error("max(abs(Tab1-T)) > 16*tol");
  endif

  % Find the gradients of T
  [T,gradT]=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                difference);
  
  % Check the gradients of the group delay response wrt A1k
  del=100*tol;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_Tk=zeros(length(Trng),length(A1k));
  for l=1:length(A1k)
    TkPdel2=schurOneMPAlatticeT(wt,A1k+delk,A1epsilon,A1p,A2k,A2epsilon,A2p,...
                                difference);
    TkMdel2=schurOneMPAlatticeT(wt,A1k-delk,A1epsilon,A1p,A2k,A2epsilon,A2p,...
                                difference);
    delk=circshift(delk,1);
    diff_Tk(:,l)=(TkPdel2-TkMdel2)/del;
  endfor
  if max(max(abs(diff_Tk-gradT(:,A1rng)))) > 3*tol
    error("max(max(abs(diff_Tk-gradT(,A1rng)))) > 3*tol");
  endif

  % Check the gradients of the group delay response wrt A2k
  del=100*tol;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_Tk=zeros(length(Trng),length(A2k));
  for l=1:length(A2k)
    TkPdel2=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k+delk,A2epsilon,A2p,...
                                difference);
    TkMdel2=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k-delk,A2epsilon,A2p,...
                                difference);
    delk=circshift(delk,1);
    diff_Tk(:,l)=(TkPdel2-TkMdel2)/del;
  endfor
  if max(max(abs(diff_Tk-gradT(:,A2rng)))) > 4*tol
    error("max(max(abs(diff_Tk-gradT(,A2rng)))) > 4*tol");
  endif

  % Find diagHessT
  [T,gradT,diagHessT]=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p, ...
                                          A2k,A2epsilon,A2p,difference);

  % Check the Hessian of the group delay response wrt A1k
  del=100*tol;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradTk=zeros(length(Trng),length(A1k));
  for l=1:length(A1k)
    [TkPdel2,gradTkPdel2]=schurOneMPAlatticeT(wt,A1k+delk,A1epsilon,A1p, ...
                                              A2k,A2epsilon,A2p,difference);
    [TkMdel2,gradTkMdel2]=schurOneMPAlatticeT(wt,A1k-delk,A1epsilon,A1p, ...
                                              A2k,A2epsilon,A2p,difference);
    delk=circshift(delk,1);
    diff_gradTk(:,l)=(gradTkPdel2(:,l)-gradTkMdel2(:,l))/del;
  endfor
  if max(max(abs(diff_gradTk-diagHessT(:,A1rng)))) > 50*tol
    error("max(max(abs(diff_gradTk-diagHessT(,A1rng)))) > 50*tol");
  endif

  % Check the Hessian of the group delay response wrt A2k
  del=100*tol;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradTk=zeros(length(Trng),length(A2k));
  for l=1:length(A2k)
    [TkPdel2,gradTkPdel2]=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p, ...
                                              A2k+delk,A2epsilon,A2p,difference);
    [TkMdel2,gradTkMdel2]=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p, ...
                                              A2k-delk,A2epsilon,A2p,difference);
    delk=circshift(delk,1);
    diff_gradTk(:,l)=(gradTkPdel2(:,length(A1k)+l)-...
                      gradTkMdel2(:,length(A1k)+l))/del;
  endfor
  if max(max(abs(diff_gradTk-diagHessT(:,A2rng)))) > 50*tol
    error("max(max(abs(diff_gradTk-diagHessT(,A2rng)))) > 50*tol");
  endif
  
endfor

% Done
diary off
movefile schurOneMPAlatticeT_test.diary.tmp schurOneMPAlatticeT_test.diary;
