% schurOneMPAlatticePipelinedT_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMPAlatticePipelinedT_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2

  schur_lattice_test_common;
  
  % Convert filter transfer function to Schur 1-multiplier lattice form
  A1k=schurdecomp(Da1);
  A1epsilon=schurOneMscale(A1k);
  A2k=schurdecomp(Db1);
  A2epsilon=schurOneMscale(A2k);

  A1Nk=length(A1k);
  A1kk=A1k(1:(A1Nk-1)).*A1k(2:A1Nk);
  A1Nkk=length(A1kk);
  A2Nk=length(A2k);
  A2kk=A2k(1:(A2Nk-1)).*A2k(2:A2Nk);
  A2Nkk=length(A2kk);
  
  % Approximate A1kk and A2kk
  A1kkr=round(A1kk*1024)/1024;
  A2kkr=round(A2kk*1024)/1024;
  
  Ax=[A1k(:);A1kkr(:);A2k(:);A2kkr(:)];
  Nx=A1Nk+A1Nkk+A2Nk+A2Nkk;
  RA1k=1:A1Nk;
  RA1kk=(A1Nk+1):(A1Nk+A1Nkk);
  RA2k=(A1Nk+A1Nkk+1):(A1Nk+A1Nkk+A2Nk);
  RA2kk=(A1Nk+A1Nkk+A2Nk+1):(A1Nk+A1Nkk+A2Nk+A2Nkk);

  %
  % Check the group-delay response
  %
  t=delayz(n,d,wt);
  T=schurOneMPAlatticePipelinedT ...
        (wt,A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk,difference);
  max_abs_diff_T=max(abs(T-t));
  if verbose
    printf("max_abs_diff_T = %g\n",max_abs_diff_T);
  endif
  if max_abs_diff_T > 2e-7
    error("max_abs_diff_T > 2e-7");
  endif

  %
  % Check the gradients of the group-delay
  %
  [~,gradT]=schurOneMPAlatticePipelinedT ...
    (wt,A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference);
  est_dTdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    TAxP=schurOneMPAlatticePipelinedT ...
             (wtc,AxP(RA1k),A1epsilon,AxP(RA1kk), ...
              AxP(RA2k),A2epsilon,AxP(RA2kk),difference);
    AxM=Ax-delAx;
    TAxM=schurOneMPAlatticePipelinedT ...
             (wtc,AxM(RA1k),A1epsilon,AxM(RA1kk), ...
              AxM(RA2k),A2epsilon,AxM(RA2kk),difference);
    delAx=circshift(delAx,1);
    est_dTdx(l)=(TAxP-TAxM)/del;
  endfor
  max_abs_diff_dTdx = max(abs(est_dTdx-gradT(ntc,:)));
  if verbose
    printf("max_abs_diff_dTdx = del/%g\n", del/max_abs_diff_dTdx);
  endif
  if max_abs_diff_dTdx> del/100
    error("max_abs_diff_dTdx > del/100");
  endif

  %
  % Check the diagonal of the Hessian of the group-delay
  %
  [~,~,diagHessT]=schurOneMPAlatticePipelinedT ... 
    (wt,A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference);
  est_diagd2Tdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,gradTAxP]=schurOneMPAlatticePipelinedT ...
                      (wtc,AxP(RA1k),A1epsilon,AxP(RA1kk), ...
                       AxP(RA2k),A2epsilon,AxP(RA2kk),difference);
    AxM=Ax-delAx;
    [~,gradTAxM]=schurOneMPAlatticePipelinedT ...
                      (wtc,AxM(RA1k),A1epsilon,AxM(RA1kk), ...
                       AxM(RA2k),A2epsilon,AxM(RA2kk),difference);
    delAx=circshift(delAx,1);
    est_diagd2Tdx2(l)=(gradTAxP(l)-gradTAxM(l))/del;
  endfor
  max_abs_diff_diagd2Tdx2 = max(abs(est_diagd2Tdx2-diagHessT(ntc,:)));
  if verbose
    printf("max_abs_diff_diagd2Tdx2 = del/%g\n",del/max_abs_diff_diagd2Tdx2);
  endif
  if max_abs_diff_diagd2Tdx2 > del/5
    error("max_abs_diff_diagd2Tdx2 > del/5");
  endif

  %
  % Check the Hessian of the group-delay
  %
  [~,~,~,hessT]=schurOneMPAlatticePipelinedT ... 
    (wt,A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference);
  est_d2Tdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,gradTAxP]=schurOneMPAlatticePipelinedT ...
                       (wtc,AxP(RA1k),A1epsilon,AxP(RA1kk), ...
                        AxP(RA2k),A2epsilon,AxP(RA2kk),difference);
      AxM=Ax-delAx;
      [~,gradTAxM]=schurOneMPAlatticePipelinedT ...
                       (wtc,AxM(RA1k),A1epsilon,AxM(RA1kk), ...
                        AxM(RA2k),A2epsilon,AxM(RA2kk),difference);
      delAx=circshift(delAx,1);
      est_d2Tdydx(l,m)=(gradTAxP(l)-gradTAxM(l))/del;
    endfor
  endfor
  max_abs_diff_d2Tdydx = ...
    max(max(abs(est_d2Tdydx-squeeze(hessT(ntc,:,:)))));
  if verbose
    printf("max_abs_diff_d2Tdydx = del/%g\n",del/max_abs_diff_d2Tdydx);
  endif
  if max_abs_diff_d2Tdydx > del/5
    error("max_abs_diff_d2Tdydx > del/5");
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
