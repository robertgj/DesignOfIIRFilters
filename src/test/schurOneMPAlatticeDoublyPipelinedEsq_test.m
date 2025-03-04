% schurOneMPAlatticeDoublyPipelinedEsq_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeDoublyPipelinedEsq_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;

% Low pass filter
norder=9;
fpass=0.125;
[n,d]=butter(norder,2*fpass);
nplot=1000;
npass=ceil(nplot*fpass/0.5)+1;
Wap=1;
Was=10;
td=4;
Wtp=10;
Wpp=10;
Wdp=10;

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
  if difference
    H=(Hap1-Hap2)/2;
    wa=wplot;
    Asqd=[zeros(npass,1);ones(nplot-npass,1)];
    Wa=[Was*ones(npass,1);Wap*ones(nplot-npass,1)];
    wt=wplot((npass+1):end);
    Td=td*ones(size(wt));
    Wt=Wtp*ones(size(wt));
    wp=wplot((npass+1):end);
    Pd=-(2*wplot((npass+1):end))-pi;
    Wp=Wpp*ones(size(wp));
    wd=wplot((npass+1):end);
    Dd=zeros(size(wd));
    Wd=Wdp*ones(size(wd));
  else
    H=(Hap1+Hap2)/2;
    wa=wplot;
    Asqd=[ones(npass,1);zeros(nplot-npass,1)];
    Wa=[Wap*ones(npass,1);Was*ones(nplot-npass,1)];
    wt=wplot(1:npass);
    Td=td*ones(size(wt));
    Wt=Wtp*ones(size(wt));
    wp=wplot(1:npass);
    Pd=-8*wp;
    Wp=Wpp*ones(size(wp));
    wd=wplot(1:npass);
    Dd=zeros(size(wd));
    Wd=Wdp*ones(size(wd));
  endif
  
  % Doubly pipelined state variable form where the Schur one-multiplier
  % lattice has z^-1 replaced by z^-2 with an extra z^-2 delay. In other
  % words, the response of the doubly pipelined filter is scaled by two
  % in frequency.
  Asq=schurOneMPAlatticeDoublyPipelinedAsq(wa/2,A1k,A2k,difference);
  T=schurOneMPAlatticeDoublyPipelinedT(wt/2,A1k,A2k,difference);
  P=schurOneMPAlatticeDoublyPipelinedP(wp/2,A1k,A2k,difference);
  D=schurOneMPAlatticeDoublyPipelineddAsqdw(wd/2,A1k,A2k,difference);

  % Find the squared-error
  Esq=schurOneMPAlatticeDoublyPipelinedEsq ...
        (A1k,A2k,difference,wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);

  % Check squared error
  AsqErr=Wa.*((Asq-Asqd).^2);
  AsqErrSum=sum(diff(wa/2).*(AsqErr(1:(end-1))+AsqErr(2:end)))/2;
  TErr=Wt.*((T-Td).^2);
  TErrSum=sum(diff(wt/2).*(TErr(1:(end-1))+TErr(2:end)))/2; 
  PErr=Wp.*((P-Pd).^2);
  PErrSum=sum(diff(wp/2).*(PErr(1:(end-1))+PErr(2:end)))/2;
  DErr=Wd.*((D-Dd).^2);
  DErrSum=sum(diff(wd/2).*(DErr(1:(end-1))+DErr(2:end)))/2;
  EsqErrSum=AsqErrSum+TErrSum+PErrSum+DErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq)=%g*eps\n",abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > 2000*eps
    error("abs(EsqErrSum-Esq) > 2000*eps");
  endif

  % Find the gradients of Esq
  [~,gradEsq]=schurOneMPAlatticeDoublyPipelinedEsq ...
                (A1k,A2k,difference, ...
                 wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);

  % Check the gradients of the squared-error response wrt A1k
  del=1e-6;
  NA1k=length(A1k);
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_Esqk=zeros(size(A1k));
  for l=1:NA1k
    EsqkPdel2=schurOneMPAlatticeDoublyPipelinedEsq ...
                (A1k+delk,A2k,difference, ...
                 wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);
    EsqkMdel2=schurOneMPAlatticeDoublyPipelinedEsq ...
                (A1k-delk,A2k,difference, ...
                 wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);
    delk=circshift(delk,1);
    diff_Esqk(l)=(EsqkPdel2-EsqkMdel2)/del;
  endfor
  if verbose
    printf("max(max(abs(diff_Esqk-gradEsq(A1rng))))=%g*del\n",
           max(max(abs(diff_Esqk-gradEsq(A1rng))))/del);
  endif
  if max(max(abs(diff_Esqk-gradEsq(A1rng)))) > 10*del
    error("max(max(abs(diff_Esqk-gradEsq(A1rng)))) > 10*del");
  endif

  % Check the gradients of the squared-error response wrt A2k
  del=1e-6;
  NA2k=length(A2k);
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_Esqk=zeros(size(A2k));
  for l=1:NA2k
    EsqkPdel2=schurOneMPAlatticeDoublyPipelinedEsq ...
                (A1k,A2k+delk,difference, ...
                 wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);
    EsqkMdel2=schurOneMPAlatticeDoublyPipelinedEsq ...
                (A1k,A2k-delk,difference, ...
                 wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);
    delk=circshift(delk,1);
    diff_Esqk(l)=(EsqkPdel2-EsqkMdel2)/del;
  endfor
  if verbose
    printf("max(max(abs(diff_Esqk-gradEsq(A2rng))))=%g*del\n",
           max(max(abs(diff_Esqk-gradEsq(A2rng))))/del);
  endif
  if max(max(abs(diff_Esqk-gradEsq(A2rng)))) > 10*del
    error("max(max(abs(diff_Esqk-gradEsq(A2rng)))) > 10*del");
  endif

  % Find diagHessEsq
  [~,~,diagHessEsq]=schurOneMPAlatticeDoublyPipelinedEsq ...
                      (A1k,A2k,difference, ...
                       wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);

  % Check the diagonal of the Hessian of the squared-error response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(size(A1k));
  for l=1:NA1k
    [~,gradEsqkPdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k+delk,A2k,difference, ...
                         wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);
    [~,gradEsqkMdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k-delk,A2k,difference, ...
                         wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);
    delk=circshift(delk,1);
    diff_gradEsqk(l)=(gradEsqkPdel2(l)-gradEsqkMdel2(l))/del;
  endfor
  if verbose
    printf("max(max(abs(diff_gradEsqk-diagHessEsq(A1rng))))=%g*del\n",
           max(max(abs(diff_gradEsqk-diagHessEsq(A1rng))))/del);
  endif
  if max(max(abs(diff_gradEsqk-diagHessEsq(A1rng)))) > 10*del
    error("max(max(abs(diff_gradEsqk-diagHessEsq(A1rng)))) > 10*del");
  endif

  % Check the diagonal of the Hessian of the squared-error response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(size(A2k));
  for l=1:NA2k
    [~,gradEsqkPdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k,A2k+delk,difference, ...
                         wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);
    [~,gradEsqkMdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k,A2k-delk,difference, ...
                         wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);    
    delk=circshift(delk,1);
    diff_gradEsqk(l)=(gradEsqkPdel2(NA1k+l)-gradEsqkMdel2(NA1k+l))/del;
  endfor
  if verbose
    printf("max(max(abs(diff_gradEsqk-diagHessEsq(A2rng))))=%g*del\n",
           max(max(abs(diff_gradEsqk-diagHessEsq(A2rng))))/del);
  endif
  if max(max(abs(diff_gradEsqk-diagHessEsq(A2rng)))) > 100*del
    error("max(max(abs(diff_gradEsqk-diagHessEsq(A2rng)))) > 100*del");
  endif

  % Find hessEsq
  [~,~,~,hessEsq]=schurOneMPAlatticeDoublyPipelinedEsq ...
                    (A1k,A2k,difference, ...
                     wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);

  if max(abs(diagHessEsq-transpose(diag(hessEsq)))) > 1000000*eps
    error("max(abs(diagHessEsq-transpose(diag(hessEsq)))) > 1000000*eps");
  endif
  
  % Check the Hessian of the squared-error response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(length(A1k),length(A1k));
  for l=1:NA1k
    [~,gradEsqkPdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k+delk,A2k,difference, ...
                         wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);
    [~,gradEsqkMdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k-delk,A2k,difference, ...
                         wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);
    diff_gradEsqk(l,:)=(gradEsqkPdel2(A1rng)-gradEsqkMdel2(A1rng))/del;
    delk=circshift(delk,1);
  endfor
  if verbose
       printf("max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng))))=%g*del\n",
              max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng))))/del);
  endif
  if max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng)))) > 10*del
    error("max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng)))) > 10*del");
  endif
  
  % Check the Hessian of the squared-error response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(length(A2k),length(A2k));
  for l=1:NA2k
    [~,gradEsqkPdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k,A2k+delk,difference, ...
                         wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);
    [~,gradEsqkMdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k,A2k-delk,difference, ...
                         wa/2,Asqd,Wa,wt/2,Td,Wt,wp/2,Pd,Wp,wd/2,Dd,Wd);
    diff_gradEsqk(l,:)=(gradEsqkPdel2(A2rng)-gradEsqkMdel2(A2rng))/del;
    delk=circshift(delk,1);
  endfor
  if verbose
       printf("max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng))))=%g*del\n",
              max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng))))/del);
  endif
  if max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng)))) > 100*del
    error("max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng)))) > 100*del");
  endif
  
  % Find hessEsq for Asq only
  [~,~,diagHessEsq,hessEsq]=schurOneMPAlatticeDoublyPipelinedEsq ...
                              (A1k,A2k,difference,wa/2,Asqd,Wa);

  if max(abs(diagHessEsq-transpose(diag(hessEsq)))) > 1000000*eps
    error("max(abs(diagHessEsq-transpose(diag(hessEsq)))) > 1000000*eps");
  endif
  
  % Check the Hessian of the squared-error response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(length(A1k),length(A1k));
  for l=1:NA1k
    [~,gradEsqkPdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k+delk,A2k,difference,wa/2,Asqd,Wa);
    [~,gradEsqkMdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k-delk,A2k,difference,wa/2,Asqd,Wa);
    diff_gradEsqk(l,:)=(gradEsqkPdel2(A1rng)-gradEsqkMdel2(A1rng))/del;
    delk=circshift(delk,1);
  endfor
  if verbose
       printf("max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng))))=%g*del\n",
              max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng))))/del);
  endif
  if max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng)))) > 10*del
    error("max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng)))) > 10*del");
  endif
  
  % Check the Hessian of the squared-error response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(length(A2k),length(A2k));
  for l=1:NA2k
    [~,gradEsqkPdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k,A2k+delk,difference,wa/2,Asqd,Wa);
    [~,gradEsqkMdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k,A2k-delk,difference,wa/2,Asqd,Wa);
    diff_gradEsqk(l,:)=(gradEsqkPdel2(A2rng)-gradEsqkMdel2(A2rng))/del;
    delk=circshift(delk,1);
  endfor
  if verbose
       printf("max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng))))=%g*del\n",
              max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng))))/del);
  endif
  if max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng)))) > 100*del
    error("max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng)))) > 100*del");
  endif
  
  % Find hessEsq for T only
  [~,~,diagHessEsq,hessEsq]=schurOneMPAlatticeDoublyPipelinedEsq ...
                              (A1k,A2k,difference,[],[],[],wt/2,Td,Wt);

  if max(abs(diagHessEsq-transpose(diag(hessEsq)))) > 1000000*eps
    error("max(abs(diagHessEsq-transpose(diag(hessEsq)))) > 1000000*eps");
  endif
  
  % Check the Hessian of the squared-error response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(length(A1k),length(A1k));
  for l=1:NA1k
    [~,gradEsqkPdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k+delk,A2k,difference,[],[],[],wt/2,Td,Wt);
    [~,gradEsqkMdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k-delk,A2k,difference,[],[],[],wt/2,Td,Wt);
    diff_gradEsqk(l,:)=(gradEsqkPdel2(A1rng)-gradEsqkMdel2(A1rng))/del;
    delk=circshift(delk,1);
  endfor
  if verbose
       printf("max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng))))=%g*del\n",
              max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng))))/del);
  endif
  if max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng)))) > 10*del
    error("max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng)))) > 10*del");
  endif
  
  % Check the Hessian of the squared-error response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(length(A2k),length(A2k));
  for l=1:NA2k
    [~,gradEsqkPdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k,A2k+delk,difference,[],[],[],wt/2,Td,Wt);
    [~,gradEsqkMdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k,A2k-delk,difference,[],[],[],wt/2,Td,Wt);
    diff_gradEsqk(l,:)=(gradEsqkPdel2(A2rng)-gradEsqkMdel2(A2rng))/del;
    delk=circshift(delk,1);
  endfor
  if verbose
       printf("max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng))))=%g*del\n",
              max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng))))/del);
  endif
  if max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng)))) > 100*del
    error("max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng)))) > 100*del");
  endif
  
  % Find hessEsq for P only
  [~,~,diagHessEsq,hessEsq]=schurOneMPAlatticeDoublyPipelinedEsq ...
                              (A1k,A2k,difference,[],[],[],[],[],[],wp/2,Pd,Wp);

  if max(abs(diagHessEsq-transpose(diag(hessEsq)))) > 1000000*eps
    error("max(abs(diagHessEsq-transpose(diag(hessEsq)))) > 1000000*eps");
  endif
  
  % Check the Hessian of the squared-error response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(length(A1k),length(A1k));
  for l=1:NA1k
    [~,gradEsqkPdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k+delk,A2k,difference,[],[],[],[],[],[],wp/2,Pd,Wp);
    [~,gradEsqkMdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k-delk,A2k,difference,[],[],[],[],[],[],wp/2,Pd,Wp);
    diff_gradEsqk(l,:)=(gradEsqkPdel2(A1rng)-gradEsqkMdel2(A1rng))/del;
    delk=circshift(delk,1);
  endfor
  if verbose
       printf("max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng))))=%g*del\n",
              max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng))))/del);
  endif
  if max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng)))) > 10*del
    error("max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng)))) > 10*del");
  endif
  
  % Check the Hessian of the squared-error response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(length(A2k),length(A2k));
  for l=1:NA2k
    [~,gradEsqkPdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k,A2k+delk,difference,[],[],[],[],[],[],wp/2,Pd,Wp);
    [~,gradEsqkMdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k,A2k-delk,difference,[],[],[],[],[],[],wp/2,Pd,Wp);
    diff_gradEsqk(l,:)=(gradEsqkPdel2(A2rng)-gradEsqkMdel2(A2rng))/del;
    delk=circshift(delk,1);
  endfor
  if verbose
       printf("max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng))))=%g*del\n",
              max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng))))/del);
  endif
  if max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng)))) > 100*del
    error("max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng)))) > 100*del");
  endif
  
  % Find hessEsq for D only
  [~,~,diagHessEsq,hessEsq]=schurOneMPAlatticeDoublyPipelinedEsq ...
                              (A1k,A2k,difference, ...
                               [],[],[],[],[],[],[],[],[],wd/2,Dd,Wd);

  if max(abs(diagHessEsq-transpose(diag(hessEsq)))) > 1000000*eps
    error("max(abs(diagHessEsq-transpose(diag(hessEsq)))) > 1000000*eps");
  endif
  
  % Check the Hessian of the squared-error response wrt A1k
  del=1e-6;
  delk=zeros(size(A1k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(length(A1k),length(A1k));
  for l=1:NA1k
    [~,gradEsqkPdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k+delk,A2k,difference, ...
                         [],[],[],[],[],[],[],[],[],wd/2,Dd,Wd);
    [~,gradEsqkMdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k-delk,A2k,difference, ...
                         [],[],[],[],[],[],[],[],[],wd/2,Dd,Wd);
    diff_gradEsqk(l,:)=(gradEsqkPdel2(A1rng)-gradEsqkMdel2(A1rng))/del;
    delk=circshift(delk,1);
  endfor
  if verbose
       printf("max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng))))=%g*del\n",
              max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng))))/del);
  endif
  if max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng)))) > 10*del
    error("max(max(abs(diff_gradEsqk-hessEsq(A1rng,A1rng)))) > 10*del");
  endif
  
  % Check the Hessian of the squared-error response wrt A2k
  del=1e-6;
  delk=zeros(size(A2k));
  delk(1)=del/2;
  diff_gradEsqk=zeros(length(A2k),length(A2k));
  for l=1:NA2k
    [~,gradEsqkPdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k,A2k+delk,difference, ...
                         [],[],[],[],[],[],[],[],[],wd/2,Dd,Wd);
    [~,gradEsqkMdel2]=schurOneMPAlatticeDoublyPipelinedEsq ...
                        (A1k,A2k-delk,difference, ...
                         [],[],[],[],[],[],[],[],[],wd/2,Dd,Wd);
    diff_gradEsqk(l,:)=(gradEsqkPdel2(A2rng)-gradEsqkMdel2(A2rng))/del;
    delk=circshift(delk,1);
  endfor
  if verbose
       printf("max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng))))=%g*del\n",
              max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng))))/del);
  endif
  if max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng)))) > 100*del
    error("max(max(abs(diff_gradEsqk-hessEsq(A2rng,A2rng)))) > 100*del");
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
