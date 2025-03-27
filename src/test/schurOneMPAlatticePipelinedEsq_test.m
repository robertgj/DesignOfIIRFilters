% schurOneMPAlatticePipelinedEsq_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticePipelinedEsq_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false;

for x=1:2,

  schur_lattice_test_common;

  % Convert filter transfer function to lattice form
  [A1k,A1epsilon,~,A1kk,~]=tf2schurOneMlatticePipelined(flipud(Da1),Da1);
  [A2k,A2epsilon,~,A2kk,~]=tf2schurOneMlatticePipelined(flipud(Db1),Db1);

  % Approximate A1kk and A2kk
  A1kkr=round(A1kk*1024)/1024;
  A2kkr=round(A2kk*1024)/1024;
  
  Ax=[A1k(:);A1kkr(:);A2k(:);A2kkr(:)];
  A1Nk=length(A1k);
  A1Nkk=length(A1kk);
  A2Nk=length(A2k);
  A2Nkk=length(A2kk);
  Nx=A1Nk+A1Nkk+A2Nk+A2Nkk;
  RA1k=1:A1Nk;
  RA1kk=(A1Nk+1):(A1Nk+A1Nkk);
  RA2k=(A1Nk+A1Nkk+1):(A1Nk+A1Nkk+A2Nk);
  RA2kk=(A1Nk+A1Nkk+A2Nk+1):(A1Nk+A1Nkk+A2Nk+A2Nkk);
  
  %
  % Check the squared-error response
  %
  Asq=schurOneMPAlatticePipelinedAsq(wa,A1k,A1epsilon,A1kk, ...
                                     A2k,A2epsilon,A2kk,difference);
  AsqErr=Wa.*((Asq-Asqd).^2);
  AsqErrSum=sum(diff(wa).*(AsqErr(1:(length(wa)-1))+AsqErr(2:end)))/2;
  
  T=schurOneMPAlatticePipelinedT(wt,A1k,A1epsilon,A1kk, ...
                                 A2k,A2epsilon,A2kk,difference);
  TErr=Wt.*((T-Td).^2);  
  TErrSum=sum(diff(wt).*(TErr(1:(length(wt)-1))+TErr(2:end)))/2;
  
  P=schurOneMPAlatticePipelinedP(wp,A1k,A1epsilon,A1kk, ...
                                 A2k,A2epsilon,A2kk,difference);
  PErr=Wp.*((P-Pd).^2);  
  PErrSum=sum(diff(wp).*(PErr(1:(length(wp)-1))+PErr(2:end)))/2;
  
  D=schurOneMPAlatticePipelineddAsqdw(wd,A1k,A1epsilon,A1kk, ...
                                      A2k,A2epsilon,A2kk,difference);
  DErr=Wd.*((D-Dd).^2);
  DErrSum=sum(diff(wd).*(DErr(1:(length(wd)-1))+DErr(2:end)))/2;
  
  % Find the squared-error
  Esq=schurOneMPAlatticePipelinedEsq ...
        (A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk,difference, ...
         wa,Asqd,Wa);
  EsqErrSum=AsqErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > eps
    error("abs(EsqErrSum-Esq) > eps");
  endif

  Esq=schurOneMPAlatticePipelinedEsq ...
        (A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk,difference, ...
         wa,Asqd,Wa,wt,Td,Wt);
  EsqErrSum=AsqErrSum+TErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(AsqErrSum+TErrSum-Esq) > eps
    error("abs(AsqErrSum-Esq) > eps");
  endif

  Esq=schurOneMPAlatticePipelinedEsq ...
        (A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk,difference, ...
         wa,Asqd, Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqErrSum=AsqErrSum+TErrSum+PErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > 5e3*eps
    error("abs(EsqErrSum-Esq) > 5e3*eps");
  endif

  Esq=schurOneMPAlatticePipelinedEsq ...
        (A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk,difference, ...
         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  EsqErrSum=AsqErrSum+TErrSum+PErrSum+DErrSum;
  if verbose
    printf("abs(EsqErrSum-Esq) = %g*eps\n", abs(EsqErrSum-Esq)/eps);
  endif
  if abs(EsqErrSum-Esq) > 5e3*eps
    error("abs(EsqErrSum-Esq) > 5e3*eps");
  endif

  %
  % Check the gradients of the squared-error
  %
  [~,gradEsq]=...
    schurOneMPAlatticePipelinedEsq ...
      (A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference, ...
       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  est_dEsqdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    EsqAxP=schurOneMPAlatticePipelinedEsq ...
             (AxP(RA1k),A1epsilon,AxP(RA1kk), ...
              AxP(RA2k),A2epsilon,AxP(RA2kk),difference, ...
              wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    AxM=Ax-delAx;
    EsqAxM=schurOneMPAlatticePipelinedEsq ...
             (AxM(RA1k),A1epsilon,AxM(RA1kk), ...
              AxM(RA2k),A2epsilon,AxM(RA2kk),difference, ...
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
  [~,~,diagHessEsq] = schurOneMPAlatticePipelinedEsq ...
                        (A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference, ...
                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  est_diagd2Esqdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,gradEsqAxP] = schurOneMPAlatticePipelinedEsq ...
                       (AxP(RA1k),A1epsilon,AxP(RA1kk), ...
                        AxP(RA2k),A2epsilon,AxP(RA2kk),difference, ...
                        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    AxM=Ax-delAx;
    [~,gradEsqAxM] = schurOneMPAlatticePipelinedEsq ...
                       (AxM(RA1k),A1epsilon,AxM(RA1kk), ...
                        AxM(RA2k),A2epsilon,AxM(RA2kk),difference, ...
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
  if max_abs_diff_diagd2Esqdx2 > 100*del
    error("max_abs_diff_diagd2Esqdx2 > 100*del");
  endif

  %
  % Check the Hessian of the squared-error
  %
  [Esq,gradEsq,diagHessEsq,hessEsq] = schurOneMPAlatticePipelinedEsq ...
                                        (A1k,A1epsilon,A1kkr, ...
                                         A2k,A2epsilon,A2kkr,difference, ...
                                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  est_d2Esqdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx,
    for m=1:Nx,
      AxP=Ax+delAx;
      [~,gradEsqAxP] = schurOneMPAlatticePipelinedEsq ...
                         (AxP(RA1k),A1epsilon,AxP(RA1kk), ...
                          AxP(RA2k),A2epsilon,AxP(RA2kk),difference, ...
                          wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      AxM=Ax-delAx;
      [~,gradEsqAxM] = schurOneMPAlatticePipelinedEsq ...
                         (AxM(RA1k),A1epsilon,AxM(RA1kk), ...
                          AxM(RA2k),A2epsilon,AxM(RA2kk),difference, ...
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
