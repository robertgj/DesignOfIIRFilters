% schurOneMlatticePipelinedEsq_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMlatticePipelinedEsq_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;

for x=1:1,

  schur_lattice_test_common;

  % Convert filter transfer function to Schur 1-multiplier lattice form
  [k,epsilon,c,kk,ck]=tf2schurOneMlatticePipelined(n,d);
  Nk=length(k);
  Nc=length(c);
  Nkk=length(kk);
  Nck=length(ck);

  % Approximate kk and ck
  kkr=round(kk*1024)/1024;
  ckr=round(ck*1024)/1024;
  
  Ax=[k(:);c(:);kkr(:);ckr(:)];
  Nx=Nk+Nc+Nkk+Nck;
  Rk=1:Nk;
  Rc=(Nk+1):(Nk+Nc);
  Rkk=(Nk+Nc+1):(Nk+Nc+Nkk);
  Rck=(Nk+Nc+Nkk+1):(Nk+Nc+Nkk+Nck);
  
  %
  % Check the squared-error response
  %
  Asq=schurOneMlatticePipelinedAsq(wa,k,epsilon,c,kkr,ckr);
  AsqErr=Wa.*((Asq-Asqd).^2);
  AsqErrSum=sum(diff(wa).*(AsqErr(1:(length(wa)-1))+AsqErr(2:end)))/2;
  
  T=schurOneMlatticePipelinedT(wt,k,epsilon,c,kkr,ckr);
  TErr=Wt.*((T-Td).^2);  
  TErrSum=sum(diff(wt).*(TErr(1:(length(wt)-1))+TErr(2:end)))/2;
  
  P=schurOneMlatticePipelinedP(wp,k,epsilon,c,kkr,ckr);
  PErr=Wp.*((P-Pd).^2);  
  PErrSum=sum(diff(wp).*(PErr(1:(length(wp)-1))+PErr(2:end)))/2;
  
  D=schurOneMlatticePipelineddAsqdw(wd,k,epsilon,c,kkr,ckr);
  DErr=Wd.*((D-Dd).^2);
  DErrSum=sum(diff(wd).*(DErr(1:(length(wd)-1))+DErr(2:end)))/2;
  
  % Find the squared-error
  Esq=schurOneMlatticePipelinedEsq ...
        (k,epsilon,c,kkr,ckr,wa,Asqd,Wa);
  EsqErrSum=AsqErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > eps
    error("abs(EsqErrSum-Esq) > eps");
  endif

  Esq=schurOneMlatticePipelinedEsq ...
        (k,epsilon,c,kkr,ckr,wa,Asqd,Wa,wt,Td,Wt);
  EsqErrSum=AsqErrSum+TErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(AsqErrSum+TErrSum-Esq) > eps
    error("abs(AsqErrSum-Esq) > eps");
  endif

  Esq=schurOneMlatticePipelinedEsq ...
        (k,epsilon,c,kkr,ckr,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqErrSum=AsqErrSum+TErrSum+PErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > eps
    error("abs(EsqErrSum-Esq) > eps");
  endif

  Esq=schurOneMlatticePipelinedEsq ...
        (k,epsilon,c,kkr,ckr,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  EsqErrSum=AsqErrSum+TErrSum+PErrSum+DErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > eps
    error("abs(EsqErrSum-Esq) > eps");
  endif

  %
  % Check the gradients of the squared-error
  %
  [~,gradEsq]=...
    schurOneMlatticePipelinedEsq ...
      (k,epsilon,c,kkr,ckr,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  est_dEsqdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    EsqAxP=schurOneMlatticePipelinedEsq ...
             (AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck), ...
              wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    AxM=Ax-delAx;
    EsqAxM=schurOneMlatticePipelinedEsq ...
             (AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck), ...
              wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);    
    delAx=circshift(delAx,1);
    est_dEsqdx(l)=(EsqAxP-EsqAxM)/del;
  endfor
  max_abs_diff_dEsqdx = max(abs(est_dEsqdx-gradEsq));
  if verbose
    printf("max_abs_diff_dEsqdx = %g*del\n", max_abs_diff_dEsqdx/del);
  endif
  if max_abs_diff_dEsqdx> 3*del
    error("max_abs_diff_dEsqdx > 3*del");
  endif
  
  %
  % Check the diagonal of the Hessian of the squared-error
  %
  [~,~,diagHessEsq] = schurOneMlatticePipelinedEsq ...
                        (k,epsilon,c,kkr,ckr, ...
                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  est_diagd2Esqdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,gradEsqAxP] = ...
      schurOneMlatticePipelinedEsq(AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck), ...
                                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    AxM=Ax-delAx;
    [~,gradEsqAxM] = ...
      schurOneMlatticePipelinedEsq(AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck), ...
                                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    delAx=circshift(delAx,1);
    est_diagd2Esqdx2(l)=(gradEsqAxP(l)-gradEsqAxM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the squared-error wrt k
  max_abs_diff_diagd2Esqdx2 = max(max(abs(est_diagd2Esqdx2-diagHessEsq)));
  if verbose
    printf("max_abs_diff_diagd2Esqdx2 = %g*del\n",max_abs_diff_diagd2Esqdx2/del);
  endif
  if max_abs_diff_diagd2Esqdx2 > 100*del
    error("max_abs_diff_diagd2Esqdx2 > 100*del");
  endif

  %
  % Check the Hessian of the squared-error
  %
  [Esq,gradEsq,diagHessEsq,hessEsq] = schurOneMlatticePipelinedEsq ...
                                        (k,epsilon,c,kkr,ckr, ...
                                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  est_d2Esqdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx,
    for m=1:Nx,
      AxP=Ax+delAx;
      [~,gradEsqAxP] = ...
        schurOneMlatticePipelinedEsq ...
          (AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck), ...
           wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      AxM=Ax-delAx;
      [~,gradEsqAxM] = ...
        schurOneMlatticePipelinedEsq ...
          (AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck), ...
           wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      delAx=circshift(delAx,1);
      est_d2Esqdydx(l,m)=(gradEsqAxP(l)-gradEsqAxM(l))/del;
    endfor
  endfor
  max_abs_diff_d2Esqdydx = max(max(abs(est_d2Esqdydx-hessEsq)));
  if verbose
    printf("max_abs_diff_d2Esqdydx = %g*del\n",max_abs_diff_d2Esqdydx/del);
  endif
  if max_abs_diff_d2Esqdydx > 100*del
    error("max_abs_diff_d2Esqdydx > 100*del");
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
