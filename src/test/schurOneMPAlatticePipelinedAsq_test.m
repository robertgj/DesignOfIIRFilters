% schurOneMPAlatticePipelinedAsq_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMPAlatticePipelinedAsq_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2

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
  % Check the squared-magnitude response
  %
  Asq=schurOneMPAlatticePipelinedAsq ...
        (wa,A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk,difference);
  h=freqz(n,d,wa);
  max_abs_diff_Asq=max(abs(Asq-(abs(h).^2)));
  if verbose
    printf("max_abs_diff_Asq = %g\n",max_abs_diff_Asq);
  endif
  if max_abs_diff_Asq > 5e-8
    error("max_abs_diff_Asq > 5e-8");
  endif

  %
  % Check the gradients of the squared-magnitude
  %
  [~,gradAsq]=schurOneMPAlatticePipelinedAsq ...
    (wa,A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference);
  est_dAsqdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    AsqAxP=schurOneMPAlatticePipelinedAsq ...
             (wac,AxP(RA1k),A1epsilon,AxP(RA1kk), ...
              AxP(RA2k),A2epsilon,AxP(RA2kk),difference);
    AxM=Ax-delAx;
    AsqAxM=schurOneMPAlatticePipelinedAsq ...
             (wac,AxM(RA1k),A1epsilon,AxM(RA1kk), ...
              AxM(RA2k),A2epsilon,AxM(RA2kk),difference);
    delAx=circshift(delAx,1);
    est_dAsqdx(l)=(AsqAxP-AsqAxM)/del;
  endfor
  max_abs_diff_dAsqdx = max(abs(est_dAsqdx-gradAsq(nac,:)));
  if verbose
    printf("max_abs_diff_dAsqdx = del/%g\n", del/max_abs_diff_dAsqdx);
  endif
  if max_abs_diff_dAsqdx> del/800
    error("max_abs_diff_dAsqdx > del/800");
  endif

  %
  % Check the diagonal of the Hessian of the squared-magnitude
  %
  [~,~,diagHessAsq]=schurOneMPAlatticePipelinedAsq ... 
    (wa,A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference);
  est_diagd2Asqdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,gradAsqAxP]=schurOneMPAlatticePipelinedAsq ...
                      (wac,AxP(RA1k),A1epsilon,AxP(RA1kk), ...
                       AxP(RA2k),A2epsilon,AxP(RA2kk),difference);
    AxM=Ax-delAx;
    [~,gradAsqAxM]=schurOneMPAlatticePipelinedAsq ...
                      (wac,AxM(RA1k),A1epsilon,AxM(RA1kk), ...
                       AxM(RA2k),A2epsilon,AxM(RA2kk),difference);
    delAx=circshift(delAx,1);
    est_diagd2Asqdx2(l)=(gradAsqAxP(l)-gradAsqAxM(l))/del;
  endfor
  max_abs_diff_diagd2Asqdx2 = max(abs(est_diagd2Asqdx2-diagHessAsq(nac,:)));
  if verbose
    printf("max_abs_diff_diagd2Asqdx2 = del/%g\n",del/max_abs_diff_diagd2Asqdx2);
  endif
  if max_abs_diff_diagd2Asqdx2 > del/50
    error("max_abs_diff_diagd2Asqdx2 > del/50");
  endif

  %
  % Check the Hessian of the squared-magnitude
  %
  [~,~,~,hessAsq]=schurOneMPAlatticePipelinedAsq ... 
    (wa,A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference);
  est_d2Asqdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,gradAsqAxP]=schurOneMPAlatticePipelinedAsq ...
                       (wac,AxP(RA1k),A1epsilon,AxP(RA1kk), ...
                        AxP(RA2k),A2epsilon,AxP(RA2kk),difference);
      AxM=Ax-delAx;
      [~,gradAsqAxM]=schurOneMPAlatticePipelinedAsq ...
                       (wac,AxM(RA1k),A1epsilon,AxM(RA1kk), ...
                        AxM(RA2k),A2epsilon,AxM(RA2kk),difference);
      delAx=circshift(delAx,1);
      est_d2Asqdydx(l,m)=(gradAsqAxP(l)-gradAsqAxM(l))/del;
    endfor
  endfor
  max_abs_diff_d2Asqdydx = ...
    max(max(abs(est_d2Asqdydx-squeeze(hessAsq(nac,:,:)))));
  if verbose
    printf("max_abs_diff_d2Asqdydx = del/%g\n",del/max_abs_diff_d2Asqdydx);
  endif
  if max_abs_diff_d2Asqdydx > del/40
    error("max_abs_diff_d2Asqdydx > del/40");
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
