% schurOneMPAlatticeT_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("schurOneMPAlatticeT_test.diary");
unlink("schurOneMPAlatticeT_test.diary.tmp");
diary schurOneMPAlatticeT_test.diary.tmp

tic;
verbose=true;
tol=1e-8;

for m=1:2
  
  schurOneMPAlattice_test_common;

  % Find the group delay
  T=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

  % Check the group delay response
  Tab1=grpdelay(Nab1,Dab1,wa);
  Tab1=Tab1(Trng);
  if max(abs(Tab1-T)) > 4*tol
    error("max(abs(Tab1-T)) > 4*tol");
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
    delk=shift(delk,1);
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
    delk=shift(delk,1);
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
    delk=shift(delk,1);
    diff_gradTk(:,l)=(gradTkPdel2(:,l)-gradTkMdel2(:,l))/del;
  endfor
  if max(max(abs(diff_gradTk-diagHessT(:,A1rng)))) > 40*tol
    error("max(max(abs(diff_gradTk-diagHessT(,A1rng)))) > 40*tol");
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
    delk=shift(delk,1);
    diff_gradTk(:,l)=(gradTkPdel2(:,length(A1k)+l)-...
                      gradTkMdel2(:,length(A1k)+l))/del;
  endfor
  if max(max(abs(diff_gradTk-diagHessT(:,A2rng)))) > 50*tol
    error("max(max(abs(diff_gradTk-diagHessT(,A2rng)))) > 50*tol");
  endif
  
endfor

% Done
toc;
diary off
movefile schurOneMPAlatticeT_test.diary.tmp schurOneMPAlatticeT_test.diary;
