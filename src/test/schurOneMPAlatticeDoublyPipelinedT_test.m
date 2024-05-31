% schurOneMPAlatticeDoublyPipelinedT_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeDoublyPipelinedT_test";
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
  T=schurOneMPAlatticeDoublyPipelinedT(wplot/2,A1k,A2k,difference);

  % Check the response
  if difference
    H=(Hap1-Hap2)/2;
    Hcheck=H((npass+1):end);
    Tcheck=T((npass+1):end);
    TT=T((npass+1):end);
    wcheck=wplot((npass+1):end)+(2*pi);
    ncheck=length(wcheck);
  else
    H=(Hap1+Hap2)/2;
    Hcheck=H(1:npass);
    Tcheck=T(1:npass);
    TT=T(1:npass);
    wcheck=wplot(1:npass);
    ncheck=length(wcheck);
  endif
  if max(abs(TT-Tcheck)) > 100*eps
    error("max(abs(TT-Tcheck)) > 100*eps");
  endif

  % Find the gradients of T
  [Tcheck,gradTcheck]= ...
    schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k,A2k,difference);

  % Check the gradients of the squared amplitude response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_Tk=zeros(ncheck,length(A1k));
  for l=1:length(A1k)
    TkP=schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k+delk,A2k,difference);
    TkM=schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k-delk,A2k,difference);
    delk=circshift(delk,1);
    diff_Tk(:,l)=(TkP-TkM)/del;
  endfor
  if max(max(abs(diff_Tk-gradTcheck(:,A1rng)))) > del/10
    error("max(max(abs(diff_Tk-gradTcheck(,A1rng)))) > del/10");
  endif

  % Check the gradients of the squared amplitude response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_Tk=zeros(ncheck,length(A2k));
  for l=1:length(A2k)
    TkP=schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k,A2k+delk,difference);
    TkM=schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k,A2k-delk,difference);
    delk=circshift(delk,1);
    diff_Tk(:,l)=(TkP-TkM)/del;
  endfor
  if max(max(abs(diff_Tk-gradTcheck(:,A2rng)))) > del/10
    error("max(max(abs(diff_Tk-gradTcheck(,A2rng)))) > del/10");
  endif

  % Find diagHessT
  [~,~,diagHessTcheck]= ...
    schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k,A2k,difference);

  % Check the diagonal of the Hessian of the squared amplitude response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradTk=zeros(ncheck,length(A1k));
  for l=1:length(A1k)
    [~,gradTkP]= ...
        schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k+delk,A2k,difference);
    [~,gradTkM]= ...
      schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k-delk,A2k,difference);
    delk=circshift(delk,1);
    diff_gradTk(:,l)=(gradTkP(:,l)-gradTkM(:,l))/del;
  endfor
  if max(max(abs(diff_gradTk-diagHessTcheck(:,A1rng)))) > del
    error("max(max(abs(diff_gradTk-diagHessTcheck(,A1rng)))) > del");
  endif

  % Check the diagonal of the Hessian of the squared amplitude response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradTk=zeros(ncheck,length(A2k));
  for l=1:length(A2k)
    [~,gradTkP]= ...
        schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k,A2k+delk,difference);
    [~,gradTkM]= ...                                         
      schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k,A2k-delk,difference);
    delk=circshift(delk,1);
    diff_gradTk(:,l)=(gradTkP(:,length(A1k)+l)- ...
                        gradTkM(:,length(A1k)+l))/del;
  endfor
  if max(max(abs(diff_gradTk-diagHessTcheck(:,A2rng)))) > 2*del
    error("max(max(abs(diff_gradTk-diagHessTcheck(,A2rng)))) > 2*del");
  endif

  % Find hessT
  [~,~,~,hessTcheck]= ...
    schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k,A2k,difference);

  % Check the diagonal of hessT
  for l=1:rows(diagHessTcheck)
    if max(abs(diagHessTcheck(l,:) - ...
               transpose(diag(squeeze(hessTcheck(l,:,:))))))>100000*eps
      error("max(abs(diagHessTcheck(l,) - ... \n\
             transpose(diag(squeeze(hessTcheck(l,,))))))>100000*eps");
    endif
  endfor

  % Check the Hessian of the squared amplitude response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradTk=zeros(ncheck,length(A1k),length(A1k));
  for l=1:length(A1k)
    [~,gradTkP]= ...
      schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k+delk,A2k,difference);
    [~,gradTkM]= ...
      schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k-delk,A2k,difference);
    for m=1:length(wcheck)
      diff_gradTk(m,l,:)=(gradTkP(m,A1rng)-gradTkM(m,A1rng))/del;
    endfor
    delk=circshift(delk,1);
  endfor
  for l=1:length(wcheck)
    if max(max(abs(squeeze(hessTcheck(l,A1rng,A1rng)) - ...
                    squeeze(diff_gradTk(l,:,:))))) > del
      error("if max(max(abs((squeeze(hessTcheck(l,A1rng,A1rng)) - ... \n\
                  squeeze(diff_gradTk(l,,)))))) > del");
    endif
  endfor

  % Check the Hessian of the squared amplitude response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradTk=zeros(ncheck,length(A2k),length(A2k));
  for l=1:length(A2k)
    [~,gradTkP]= ...
      schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k,A2k+delk,difference);
    [~,gradTkM]= ...                                         
      schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k,A2k-delk,difference);
    for m=1:length(wcheck)
      diff_gradTk(m,l,:)=(gradTkP(m,A2rng)-gradTkM(m,A2rng))/del;
    endfor
    delk=circshift(delk,1);
  endfor
  for l=1:length(wcheck)
    if max(max(abs(squeeze(hessTcheck(l,A2rng,A2rng)) - ...
                   squeeze(diff_gradTk(l,:,:))))) > 10*del
      error("if max(max(abs((squeeze(hessTcheck(l,A2rng,A2rng)) - ... \n\
                  squeeze(diff_gradTk(l,,)))))) > 10*del");
    endif
  endfor

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
