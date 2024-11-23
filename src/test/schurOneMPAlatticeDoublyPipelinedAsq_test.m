% schurOneMPAlatticeDoublyPipelinedAsq_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeDoublyPipelinedAsq_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=true;

% Low pass filter
norder=9;
fpass=0.125;
[n,d]=butter(norder,2*fpass);
nplot=1000;
npass=floor(nplot*fpass/0.5)+1;

% Lattice decomposition
[Aap1,Aap2]=tf2pa(n,d);
Aap1=transpose(Aap1(:));
Aap2=transpose(Aap2(:));
[Hap1,wplot]=freqz(fliplr(Aap1),Aap1,nplot);
[Hap2,wplot]=freqz(fliplr(Aap2),Aap2,nplot);
[A1k,~,~,~] = tf2schurOneMlattice(fliplr(Aap1),Aap1);
[A2k,~,~,~] = tf2schurOneMlattice(fliplr(Aap2),Aap2);
A1rng=1:length(A1k);
A2rng=length(A1k)+(1:length(A2k));

for difference=[false,true]
  % Doubly pipelined state variable form where the Schur one-multiplier
  % lattice has z^-1 replaced by z^-2 with an extra z^-2 delay. In other
  % words, the response of the doubly pipelined filter is scaled by two
  % in frequency.
  Asq=schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k,A2k,difference);

  % Check the response
  if difference
    H=(Hap1-Hap2)/2;
  else
    H=(Hap1+Hap2)/2;
  endif
  if max(abs((abs(H).^2)-Asq)) > 10000*eps
    error("max(abs((abs(H).^2)-Asq)) > 10000*eps");
  endif

  % Find the gradients of Asq
  [Asq,gradAsq]=schurOneMPAlatticeDoublyPipelinedAsq...
                  (wplot/2,A1k,A2k,difference);

  % Check the gradients of the squared amplitude response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_Asqk=zeros(nplot,length(A1k));
  for l=1:length(A1k)
    AsqkP=schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k+delk,A2k,difference);
    AsqkM=schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k-delk,A2k,difference);
    delk=circshift(delk,1);
    diff_Asqk(:,l)=(AsqkP-AsqkM)/del;
  endfor
  if max(max(abs(diff_Asqk-gradAsq(:,A1rng)))) > del/100
    error("max(max(abs(diff_Asqk-gradAsq(,A1rng)))) > del/100");
  endif

  % Check the gradients of the squared amplitude response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_Asqk=zeros(nplot,length(A2k));
  for l=1:length(A2k)
    AsqkP=schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k,A2k+delk,difference);
    AsqkM=schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k,A2k-delk,difference);
    delk=circshift(delk,1);
    diff_Asqk(:,l)=(AsqkP-AsqkM)/del;
  endfor
  if max(max(abs(diff_Asqk-gradAsq(:,A2rng)))) > del/100
    error("max(max(abs(diff_Asqk-gradAsq(,A2rng)))) > del/100");
  endif

  % Find diagHessAsq
  [~,~,diagHessAsq]=schurOneMPAlatticeDoublyPipelinedAsq ...
                      (wplot/2,A1k,A2k,difference);

  % Check the diagonal of the Hessian of the squared amplitude response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradAsqk=zeros(nplot,length(A1k));
  for l=1:length(A1k)
    [~,gradAsqkP]= ...
        schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k+delk,A2k,difference);
    [~,gradAsqkM]= ...
      schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k-delk,A2k,difference);
    delk=circshift(delk,1);
    diff_gradAsqk(:,l)=(gradAsqkP(:,l)-gradAsqkM(:,l))/del;
  endfor
  if max(max(abs(diff_gradAsqk-diagHessAsq(:,A1rng)))) > del/10
    error("max(max(abs(diff_gradAsqk-diagHessAsq(,A1rng)))) > del/10");
  endif

  % Check the diagonal of the Hessian of the squared amplitude response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradAsqk=zeros(nplot,length(A2k));
  for l=1:length(A2k)
    [~,gradAsqkP]= ...
        schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k,A2k+delk,difference);
    [~,gradAsqkM]= ...                                         
      schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k,A2k-delk,difference);
    delk=circshift(delk,1);
    diff_gradAsqk(:,l)=(gradAsqkP(:,length(A1k)+l)- ...
                        gradAsqkM(:,length(A1k)+l))/del;
  endfor
  if max(max(abs(diff_gradAsqk-diagHessAsq(:,A2rng)))) > del
    error("max(max(abs(diff_gradAsqk-diagHessAsq(,A2rng)))) > del");
  endif

  % Find hessAsq
  [~,~,~,hessAsq]=schurOneMPAlatticeDoublyPipelinedAsq ...
                    (wplot/2,A1k,A2k,difference);

  % Check the diagonal of hessAsq
  if max(abs(diagHessAsq(npass,:) - ...
             transpose(diag(squeeze(hessAsq(npass,:,:))))))>1000*eps
    error("max(abs(diagHessAsq(npass,) - ... \n\
             transpose(diag(squeeze(hessAsq(npass,,))))))>1000*eps");
  endif

  % Check the Hessian of the squared amplitude response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradAsqk=zeros(nplot,length(A1k),length(A1k));
  for l=1:length(A1k)
    [~,gradAsqkP]= ...
      schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k+delk,A2k,difference);
    [~,gradAsqkM]= ...
      schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k-delk,A2k,difference);
    for m=1:length(wplot)
      diff_gradAsqk(m,l,:)=(gradAsqkP(m,A1rng)-gradAsqkM(m,A1rng))/del;
    endfor
    delk=circshift(delk,1);
  endfor
  for l=1:length(wplot)
    if max(max(abs(squeeze(hessAsq(l,A1rng,A1rng)) - ...
                   squeeze(diff_gradAsqk(l,:,:))))) > del/10
      error("max(max(abs(squeeze(hessAsq(l,A1rng,A1rng)) - ... \n\
            squeeze(diff_gradAsqk(l,,))))) > del/10");
    endif
  endfor

  % Check the Hessian of the squared amplitude response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradAsqk=zeros(nplot,length(A2k),length(A2k));
  for l=1:length(A2k)
    [~,gradAsqkP]= ...
        schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k,A2k+delk,difference);
    [~,gradAsqkM]= ...                                         
      schurOneMPAlatticeDoublyPipelinedAsq(wplot/2,A1k,A2k-delk,difference);
    for m=1:length(wplot)
      diff_gradAsqk(m,l,:)=(gradAsqkP(m,A2rng)-gradAsqkM(m,A2rng))/del;
    endfor
    delk=circshift(delk,1);
  endfor
  for l=1:length(wplot)
    if max(max(abs(squeeze(hessAsq(l,A2rng,A2rng)) - ...
                   squeeze(diff_gradAsqk(l,:,:))))) > del
      error("max(max(abs(squeeze(hessAsq(l,A2rng,A2rng)) - ... \n\
            squeeze(diff_gradAsqk(l,,))))) > del");
    endif
  endfor

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
