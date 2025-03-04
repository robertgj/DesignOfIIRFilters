% schurOneMPAlatticeDoublyPipelinedP_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeDoublyPipelinedP_test";
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
  P=schurOneMPAlatticeDoublyPipelinedP(wplot/2,A1k,A2k,difference);

  % Check the response
  if difference
    H=(Hap1-Hap2)/2;
    Hcheck=H((npass+1):end);
    Pcheck=P((npass+1):end);
    wcheck=wplot((npass+1):end)+(2*pi);
    ncheck=length(wcheck);
  else
    H=(Hap1+Hap2)/2;
    Hcheck=H(1:npass);
    Pcheck=P(1:npass);
    wcheck=wplot(1:npass);
    ncheck=length(wcheck);
  endif
  if max(abs(unwrap(arg(Hcheck))-Pcheck-wcheck)) > 100*eps
    error("max(abs(unwrap(arg(Hcheck))-Pcheck-wcheck)) > 100*eps");
  endif

  % Find the gradients of P
  [Pcheck,gradPcheck]= ...
    schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k,A2k,difference);

  % Check the gradients of the squared amplitude response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_Pk=zeros(ncheck,length(A1k));
  for l=1:length(A1k)
    PkP=schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k+delk,A2k,difference);
    PkM=schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k-delk,A2k,difference);
    delk=circshift(delk,1);
    diff_Pk(:,l)=(PkP-PkM)/del;
  endfor
  if max(max(abs(diff_Pk-gradPcheck(:,A1rng)))) > del/100
    error("max(max(abs(diff_Pk-gradPcheck(,A1rng)))) > del/100");
  endif

  % Check the gradients of the squared amplitude response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_Pk=zeros(ncheck,length(A2k));
  for l=1:length(A2k)
    PkP=schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k,A2k+delk,difference);
    PkM=schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k,A2k-delk,difference);
    delk=circshift(delk,1);
    diff_Pk(:,l)=(PkP-PkM)/del;
  endfor
  if max(max(abs(diff_Pk-gradPcheck(:,A2rng)))) > del/100
    error("max(max(abs(diff_Pk-gradPcheck(,A2rng)))) > del/100");
  endif

  % Find diagHessP
  [~,~,diagHessPcheck]= ...
    schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k,A2k,difference);

  % Check the diagonal of the Hessian of the squared amplitude response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradPk=zeros(ncheck,length(A1k));
  for l=1:length(A1k)
    [~,gradPkP]= ...
        schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k+delk,A2k,difference);
    [~,gradPkM]= ...
      schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k-delk,A2k,difference);
    delk=circshift(delk,1);
    diff_gradPk(:,l)=(gradPkP(:,l)-gradPkM(:,l))/del;
  endfor
  if max(max(abs(diff_gradPk-diagHessPcheck(:,A1rng)))) > del/10
    error("max(max(abs(diff_gradPk-diagHessPcheck(,A1rng)))) > del/10");
  endif

  % Check the diagonal of the Hessian of the squared amplitude response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradPk=zeros(ncheck,length(A2k));
  for l=1:length(A2k)
    [~,gradPkP]= ...
        schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k,A2k+delk,difference);
    [~,gradPkM]= ...                                         
      schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k,A2k-delk,difference);
    delk=circshift(delk,1);
    diff_gradPk(:,l)=(gradPkP(:,length(A1k)+l)- ...
                        gradPkM(:,length(A1k)+l))/del;
  endfor
  if max(max(abs(diff_gradPk-diagHessPcheck(:,A2rng)))) > del/10
    error("max(max(abs(diff_gradPk-diagHessPcheck(,A2rng)))) > del/10");
  endif

  % Find hessP
  [~,~,~,hessPcheck]= ...
    schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k,A2k,difference);

  % Check the diagonal of hessP
  for l=1:rows(diagHessPcheck)
    if max(abs(diagHessPcheck(l,:) - ...
               transpose(diag(squeeze(hessPcheck(l,:,:))))))>1000*eps
      error("max(abs(diagHessPcheck(l,) - ... \n\
             transpose(diag(squeeze(hessPcheck(l,,))))))>1000*eps");
    endif
  endfor

  % Check the Hessian of the squared amplitude response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradPk=zeros(ncheck,length(A1k),length(A1k));
  for l=1:length(A1k)
    [~,gradPkP]= ...
      schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k+delk,A2k,difference);
    [~,gradPkM]= ...
      schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k-delk,A2k,difference);
    for m=1:length(wcheck)
      diff_gradPk(m,l,:)=(gradPkP(m,A1rng)-gradPkM(m,A1rng))/del;
    endfor
    delk=circshift(delk,1);
  endfor
  for l=1:length(wcheck)
    if max(max(abs(squeeze(hessPcheck(l,A1rng,A1rng)) - ...
                    squeeze(diff_gradPk(l,:,:))))) > del/10
      error("if max(max(abs((squeeze(hessPcheck(l,A1rng,A1rng)) - ... \n\
                  squeeze(diff_gradPk(l,,)))))) > del/10");
    endif
  endfor

  % Check the Hessian of the squared amplitude response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradPk=zeros(ncheck,length(A2k),length(A2k));
  for l=1:length(A2k)
    [~,gradPkP]= ...
      schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k,A2k+delk,difference);
    [~,gradPkM]= ...                                         
      schurOneMPAlatticeDoublyPipelinedP(wcheck/2,A1k,A2k-delk,difference);
    for m=1:length(wcheck)
      diff_gradPk(m,l,:)=(gradPkP(m,A2rng)-gradPkM(m,A2rng))/del;
    endfor
    delk=circshift(delk,1);
  endfor
  for l=1:length(wcheck)
    if max(max(abs(squeeze(hessPcheck(l,A2rng,A2rng)) - ...
                   squeeze(diff_gradPk(l,:,:))))) > del/10
      error("if max(max(abs((squeeze(hessPcheck(l,A2rng,A2rng)) - ... \n\
                  squeeze(diff_gradPk(l,,)))))) > del/10");
    endif
  endfor

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
