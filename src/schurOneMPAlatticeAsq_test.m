% schurOneMPAlatticeAsq_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("schurOneMPAlatticeAsq_test.diary");
unlink("schurOneMPAlatticeAsq_test.diary.tmp");
diary schurOneMPAlatticeAsq_test.diary.tmp

tol=1e-7;

for m=1:2
  
  schurOneMPAlattice_test_common;

  % Find the squared amplitude
  Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

  % Check the squared amplitude response
  Hab1=freqz(Nab1,Dab1,wa);
  Asqab1=abs(Hab1).^2;
  if max(abs(Asqab1-Asq))/min(Asq(Asqrng)) > tol
    error("max(abs(Asqab1-Asq))/min(Asq(Asqrng)) > tol");
  endif

  % Find the gradients of Asq
  [Asq,gradAsq]=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p, ...
                                      A2k,A2epsilon,A2p,difference);
  
  % Check the gradients of the squared amplitude response wrt A1k
  del=tol*10;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_Asqk=zeros(length(wa),length(A1k));
  for l=1:length(A1k)
    AsqkPdel2=schurOneMPAlatticeAsq(wa,A1k+delk,A1epsilon,A1p, ...
                                    A2k,A2epsilon,A2p,difference);
    AsqkMdel2=schurOneMPAlatticeAsq(wa,A1k-delk,A1epsilon,A1p, ...
                                    A2k,A2epsilon,A2p,difference);
    delk=shift(delk,1);
    diff_Asqk(:,l)=(AsqkPdel2-AsqkMdel2)/del;
  endfor
  if max(max(abs(diff_Asqk-gradAsq(:,A1rng)))) > tol
    error("max(max(abs(diff_Asqk-gradAsq(:,A1rng)))) > tol");
  endif

  % Check the gradients of the squared amplitude response wrt A2k
  del=tol*10;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_Asqk=zeros(length(wa),length(A2k));
  for l=1:length(A2k)
    AsqkPdel2=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p, ...
                                    A2k+delk,A2epsilon,A2p,difference);
    AsqkMdel2=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p, ...
                                    A2k-delk,A2epsilon,A2p,difference);
    delk=shift(delk,1);
    diff_Asqk(:,l)=(AsqkPdel2-AsqkMdel2)/del;
  endfor
  if max(max(abs(diff_Asqk-gradAsq(:,A2rng)))) > tol
    error("max(max(abs(diff_Asqk-gradAsq(:,A2rng)))) > tol");
  endif

  % Find diagHessAsq
  [Asq,gradAsq,diagHessAsq]=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p, ...
                                                  A2k,A2epsilon,A2p,difference);

  % Check the Hessian of the squared amplitude response wrt A1k
  del=tol*10;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradAsqk=zeros(length(wa),length(A1k));
  for l=1:length(A1k)
    [AsqkPdel2,gradAsqkPdel2]=schurOneMPAlatticeAsq(wa,A1k+delk,A1epsilon,A1p,...
                                                    A2k,A2epsilon,A2p, ...
                                                    difference);
    [AsqkMdel2,gradAsqkMdel2]=schurOneMPAlatticeAsq(wa,A1k-delk,A1epsilon,A1p,...
                                                    A2k,A2epsilon,A2p, ...
                                                    difference);
    delk=shift(delk,1);
    diff_gradAsqk(:,l)=(gradAsqkPdel2(:,l)-gradAsqkMdel2(:,l))/del;
  endfor
  if max(max(abs(diff_gradAsqk-diagHessAsq(:,A1rng)))) > tol
    error("max(max(abs(diff_gradAsqk-diagHessAsq(,A1rng)))) > tol");
  endif

  % Check the Hessian of the squared amplitude response wrt A2k
  del=tol*10;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradAsqk=zeros(length(wa),length(A2k));
  for l=1:length(A2k)
    [AsqkPdel2,gradAsqkPdel2]=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p, ...
                                                    A2k+delk,A2epsilon,A2p, ...
                                                    difference);
    [AsqkMdel2,gradAsqkMdel2]=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p, ...
                                                    A2k-delk,A2epsilon,A2p, ...
                                                    difference);
    delk=shift(delk,1);
    diff_gradAsqk(:,l)=(gradAsqkPdel2(:,length(A1k)+l)-...
                        gradAsqkMdel2(:,length(A1k)+l))/del;
  endfor
  if max(max(abs(diff_gradAsqk-diagHessAsq(:,A2rng)))) > tol
    error("max(max(abs(diff_gradAsqk-diagHessAsq(,A2rng)))) > tol");
  endif
  
endfor

% Done
diary off
movefile schurOneMPAlatticeAsq_test.diary.tmp schurOneMPAlatticeAsq_test.diary;
