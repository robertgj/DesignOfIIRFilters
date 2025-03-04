% schurOneMAPlatticePipelinedEsq_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMAPlatticePipelinedEsq_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;

for x=1:1,

  schur_lattice_test_common;

  % Modify to suit an all-pass filter
  wa=wa(1:nac);
  Asqd=Asqd(1:nac);
  Wa=ones(size(wa));
  Wp=ones(size(wp));
  
  % Convert filter transfer function to Schur 1-multiplier lattice form
  [k,epsilon,~,~]=tf2schurOneMlattice(n,d);
  Nk=length(k);
  kk=k(1:(Nk-1)).*k(2:Nk);
  Nkk=length(kk);

  % Approximate kk and ck
  kkr=round(kk*1024)/1024;
  
  Ax=[k(:);kkr(:)];
  Nx=Nk+Nkk;
  Rk=1:Nk;
  Rkk=(Nk+1):(Nk+Nkk);
  
  %
  % Check the squared-error response
  %
  Asq=schurOneMAPlatticePipelinedAsq(wa,k,epsilon,kkr);
  AsqErr=Wa.*((Asq-Asqd).^2);
  AsqErrSum=sum(diff(wa).*(AsqErr(1:(length(wa)-1))+AsqErr(2:end)))/2;
  
  T=schurOneMAPlatticePipelinedT(wt,k,epsilon,kkr);
  TErr=Wt.*((T-Td).^2);  
  TErrSum=sum(diff(wt).*(TErr(1:(length(wt)-1))+TErr(2:end)))/2;
  
  P=schurOneMAPlatticePipelinedP(wp,k,epsilon,kkr);
  PErr=Wp.*((P-Pd).^2);  
  PErrSum=sum(diff(wp).*(PErr(1:(length(wp)-1))+PErr(2:end)))/2;
  
  D=schurOneMAPlatticePipelineddAsqdw(wd,k,epsilon,kkr);
  DErr=Wd.*((D-Dd).^2);
  DErrSum=sum(diff(wd).*(DErr(1:(length(wd)-1))+DErr(2:end)))/2;
  
  % Find the squared-error
  Esq=schurOneMAPlatticePipelinedEsq ...
        (k,epsilon,kkr,wa,Asqd,Wa);
  EsqErrSum=AsqErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > eps
    error("abs(EsqErrSum-Esq) > eps");
  endif

  Esq=schurOneMAPlatticePipelinedEsq ...
        (k,epsilon,kkr,wa,Asqd,Wa,wt,Td,Wt);
  EsqErrSum=AsqErrSum+TErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(AsqErrSum+TErrSum-Esq) > eps
    error("abs(EsqErrSum-Esq) > eps");
  endif

  Esq=schurOneMAPlatticePipelinedEsq ...
        (k,epsilon,kkr,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqErrSum=AsqErrSum+TErrSum+PErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > eps
    error("abs(EsqErrSum-Esq) > eps");
  endif

  Esq=schurOneMAPlatticePipelinedEsq ...
        (k,epsilon,kkr,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
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
    schurOneMAPlatticePipelinedEsq ...
      (k,epsilon,kkr,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  est_dEsqdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    EsqAxP=schurOneMAPlatticePipelinedEsq ...
             (AxP(Rk),epsilon,AxP(Rkk), ...
              wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    AxM=Ax-delAx;
    EsqAxM=schurOneMAPlatticePipelinedEsq ...
             (AxM(Rk),epsilon,AxM(Rkk), ...
              wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);    
    delAx=circshift(delAx,1);
    est_dEsqdx(l)=(EsqAxP-EsqAxM)/del;
  endfor
  max_abs_diff_dEsqdx = max(abs(est_dEsqdx-gradEsq));
  if verbose
    printf("max_abs_diff_dEsqdx = %g*del\n", max_abs_diff_dEsqdx/del);
  endif
  if max_abs_diff_dEsqdx> 5*del
    error("max_abs_diff_dEsqdx > 5*del");
  endif
  
  %
  % Check the diagonal of the Hessian of the squared-error
  %
  [~,~,diagHessEsq] = schurOneMAPlatticePipelinedEsq ...
                        (k,epsilon,kkr, ...
                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  est_diagd2Esqdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,gradEsqAxP] = ...
      schurOneMAPlatticePipelinedEsq(AxP(Rk),epsilon,AxP(Rkk), ...
                                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    AxM=Ax-delAx;
    [~,gradEsqAxM] = ...
      schurOneMAPlatticePipelinedEsq(AxM(Rk),epsilon,AxM(Rkk), ...
                                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    delAx=circshift(delAx,1);
    est_diagd2Esqdx2(l)=(gradEsqAxP(l)-gradEsqAxM(l))/del;
  endfor
  % Check the diagonal of the Hessian of the squared-error wrt k
  max_abs_diff_diagd2Esqdx2 = max(max(abs(est_diagd2Esqdx2-diagHessEsq)));
  if verbose
    printf("max_abs_diff_diagd2Esqdx2 = %g*del\n", ...
           max_abs_diff_diagd2Esqdx2/del);
  endif
  if max_abs_diff_diagd2Esqdx2 > 50*del
    error("max_abs_diff_diagd2Esqdx2 > 50*del");
  endif

  %
  % Check the Hessian of the squared-error
  %
  [Esq,gradEsq,diagHessEsq,hessEsq] = schurOneMAPlatticePipelinedEsq ...
                                        (k,epsilon,kkr, ...
                                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  est_d2Esqdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx,
    for m=1:Nx,
      AxP=Ax+delAx;
      [~,gradEsqAxP] = ...
        schurOneMAPlatticePipelinedEsq ...
          (AxP(Rk),epsilon,AxP(Rkk), ...
           wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      AxM=Ax-delAx;
      [~,gradEsqAxM] = ...
        schurOneMAPlatticePipelinedEsq ...
          (AxM(Rk),epsilon,AxM(Rkk), ...
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
