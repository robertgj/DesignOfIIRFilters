% schurOneMPAlatticeDoublyPipelinedT_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeDoublyPipelinedT_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;

% Low pass filter
norder=9;
fpass=0.125;
[n,d]=butter(norder,2*fpass);
nplot=1000;
wplot=(0:(nplot-1))'*pi/nplot;
npass=floor(nplot*fpass/0.5)+1;

% Lattice decomposition
[Aap1,Aap2]=tf2pa(n,d);
Aap1=transpose(Aap1(:));
Aap2=transpose(Aap2(:));
[A1k,~,~,~] = tf2schurOneMlattice(fliplr(Aap1),Aap1);
[A2k,~,~,~] = tf2schurOneMlattice(fliplr(Aap2),Aap2);
A1rng=1:length(A1k);
A2rng=length(A1k)+(1:length(A2k));

for difference=[false,true]
  if difference
    wcheck=wplot(npass+1:end);
  else
    wcheck=wplot(1:npass);
  endif
  ncheck=length(wcheck);
  
  % Doubly pipelined state variable form where the Schur one-multiplier
  % lattice has z^-1 replaced by z^-2 with an extra z^-2 delay. In other
  % words, the response of the doubly pipelined filter is scaled by two
  % in frequency.
  T=schurOneMPAlatticeDoublyPipelinedT(wcheck/2,A1k,A2k,difference);

  % Check the response
  Tap1=delayz(fliplr(Aap1),Aap1,wcheck);
  Tap2=delayz(fliplr(Aap2),Aap2,wcheck);
  Tcheck=(2*(Tap1+Tap2)/2)+2;
  if verbose
    printf("max(abs(T-Tcheck))=%g\n",max(abs(T-Tcheck)));
  endif
  if max(abs(T-Tcheck)) > 1e-10
    error("max(abs(T-Tcheck)) > 1e-10");
  endif

  % Find the gradients of T
  [~,gradTcheck]= ...
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
  if verbose
    printf("max(max(abs(diff_Tk-gradTcheck(:,A1rng))))=%g\n", ...
           max(max(abs(diff_Tk-gradTcheck(:,A1rng)))));
  endif
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
  if verbose
    printf("max(max(abs(diff_Tk-gradTcheck(:,A2rng))))=%g\n", ...
           max(max(abs(diff_Tk-gradTcheck(:,A2rng)))));
  endif
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
  if verbose
    printf("max(max(abs(diff_gradTk-diagHessTcheck(,A1rng))))=%g\n", ...
           max(max(abs(diff_gradTk-diagHessTcheck(:,A1rng)))));
  endif
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
  if verbose
    printf("max(max(abs(diff_gradTk-diagHessTcheck(,A2rng))))=%g\n", ...
           max(max(abs(diff_gradTk-diagHessTcheck(:,A2rng)))));
  endif
  if max(max(abs(diff_gradTk-diagHessTcheck(:,A2rng)))) > 5*del
    error("max(max(abs(diff_gradTk-diagHessTcheck(,A2rng)))) > 5*del");
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
  if verbose
    printf("max(max(max(abs(squeeze(hessTcheck(l,A1rng,A1rng)) - ...\n\
squeeze(diff_gradTk(l,,))))))=%g\n",
           max(max(max(abs(squeeze(hessTcheck(l,A1rng,A1rng)) - ...
                           squeeze(diff_gradTk(l,:,:)))))));
  endif
  if max(max(max(abs(squeeze(hessTcheck(l,A1rng,A1rng)) - ...
                     squeeze(diff_gradTk(l,:,:)))))) > del
    error("if max(max(max(abs((squeeze(hessTcheck(l,A1rng,A1rng)) - ... \n\
                  squeeze(diff_gradTk(l,,))))))) > del");
  endif

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
  if verbose
    printf("max(max(max(abs(squeeze(hessTcheck(l,A2rng,A2rng)) - ...\n\
squeeze(diff_gradTk(l,,))))))=%g\n",
           max(max(max(abs(squeeze(hessTcheck(l,A2rng,A2rng)) - ...
                           squeeze(diff_gradTk(l,:,:)))))));
  endif
  if max(max(max(abs(squeeze(hessTcheck(l,A2rng,A2rng)) - ...
                     squeeze(diff_gradTk(l,:,:)))))) > 5*del
    error("if max(max(max(abs((squeeze(hessTcheck(l,A2rng,A2rng)) - ... \n\
                  squeeze(diff_gradTk(l,,))))))) > 5*del");
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
