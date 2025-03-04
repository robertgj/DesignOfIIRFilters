% schurOneMAPlatticePipelinedT_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMAPlatticePipelinedT_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2

  schur_lattice_test_common;
  
  % Convert filter transfer function to Schur 1-multiplier lattice form
  k=schurdecomp(d);
  epsilon=schurOneMscale(k);
  Nk=length(k);
  kk=k(1:(Nk-1)).*k(2:Nk);
  Nkk=length(kk);
  
  % Approximate kk
  kkr=round(kk*1024)/1024;

  Ax=[k(:);kkr(:)];
  Nx=Nk+Nkk;
  Rk=1:Nk;
  Rkk=(Nk+1):(Nk+Nkk);
  
  %
  % Check the group-delay response
  %
  t = delayz(flipud(d(:)),d(:),wt);
  T = schurOneMAPlatticePipelinedT(wt,k,epsilon,kk);
  max_abs_diff_T=max(abs(T-t));
  if verbose
    printf("max_abs_diff_T = %g\n",max_abs_diff_T);
  endif
  if max_abs_diff_T > 2e-6
    error("max_abs_diff_T > 2e-6");
  endif

  %
  % Check the gradients of the group-delay
  %
  [~,gradT] = schurOneMAPlatticePipelinedT(wt,k,epsilon,kkr);
  est_dTdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    TAxP=schurOneMAPlatticePipelinedT(wtc,AxP(Rk),epsilon,AxP(Rkk));
    AxM=Ax-delAx;
    TAxM=schurOneMAPlatticePipelinedT(wtc,AxM(Rk),epsilon,AxM(Rkk));
    delAx=circshift(delAx,1);
    est_dTdx(l)=(TAxP-TAxM)/del;
  endfor
  max_abs_diff_dTdx = max(abs(est_dTdx-gradT(ntc,:)));
  if verbose
    printf("max_abs_diff_dTdx = del/%g\n", del/max_abs_diff_dTdx);
  endif
  if max_abs_diff_dTdx> del/20
    error("max_abs_diff_dTdx > del/20");
  endif

  %
  % Check the diagonal of the Hessian of the group-delay
  %
  [~,~,diagHessT] = schurOneMAPlatticePipelinedT(wt,k,epsilon,kkr);
  est_diagd2Tdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,gradTAxP]=schurOneMAPlatticePipelinedT(wtc,AxP(Rk),epsilon,AxP(Rkk));
    AxM=Ax-delAx;
    [~,gradTAxM]=schurOneMAPlatticePipelinedT(wtc,AxM(Rk),epsilon,AxM(Rkk));
    delAx=circshift(delAx,1);
    est_diagd2Tdx2(l)=(gradTAxP(l)-gradTAxM(l))/del;
  endfor
  max_abs_diff_diagd2Tdx2 = max(abs(est_diagd2Tdx2-diagHessT(ntc,:)));
  if verbose
    printf("max_abs_diff_diagd2Tdx2 = del/%g\n",del/max_abs_diff_diagd2Tdx2);
  endif
  if max_abs_diff_diagd2Tdx2 > del/2
    error("max_abs_diff_diagd2Tdx2 > del/2");
  endif

  %
  % Check the Hessian of the group-delay
  %
  [~,~,~,hessT]=schurOneMAPlatticePipelinedT(wt,k,epsilon,kkr);
  est_d2Tdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,gradTAxP] = ...
        schurOneMAPlatticePipelinedT(wtc,AxP(Rk),epsilon,AxP(Rkk));
      AxM=Ax-delAx;
      [~,gradTAxM] = ...
        schurOneMAPlatticePipelinedT(wtc,AxM(Rk),epsilon,AxM(Rkk));
      delAx=circshift(delAx,1);
      est_d2Tdydx(l,m)=(gradTAxP(l)-gradTAxM(l))/del;
    endfor
  endfor
  max_abs_diff_d2Tdydx = ...
    max(max(abs(est_d2Tdydx-squeeze(hessT(ntc,:,:)))));
  if verbose
    printf("max_abs_diff_d2Tdydx = del/%g\n",del/max_abs_diff_d2Tdydx);
  endif
  if max_abs_diff_d2Tdydx > del
    error("max_abs_diff_d2Tdydx > del");
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
