% schurOneMAPlatticePipelinedAsq_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMAPlatticePipelinedAsq_test";

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
  % Check the squared-magnitude response
  %
  Asq = schurOneMAPlatticePipelinedAsq(wa,k,epsilon,kk);
  max_abs_diff_Asq=max(abs(Asq-1));
  if verbose
    printf("max_abs_diff_Asq = %g*eps\n",max_abs_diff_Asq/eps);
  endif
  if max_abs_diff_Asq > 40*eps
    error("max_abs_diff_Asq > 40*eps");
  endif

  %
  % Check the gradients of the squared-magnitude
  %
  [~,gradAsq] = schurOneMAPlatticePipelinedAsq(wa,k,epsilon,kkr);
  est_dAsqdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    AsqAxP=schurOneMAPlatticePipelinedAsq(wac,AxP(Rk),epsilon,AxP(Rkk));
    AxM=Ax-delAx;
    AsqAxM=schurOneMAPlatticePipelinedAsq(wac,AxM(Rk),epsilon,AxM(Rkk));
    delAx=circshift(delAx,1);
    est_dAsqdx(l)=(AsqAxP-AsqAxM)/del;
  endfor
  max_abs_diff_dAsqdx = max(abs(est_dAsqdx-gradAsq(nac,:)));
  if verbose
    printf("max_abs_diff_dAsqdx = del/%g\n", del/max_abs_diff_dAsqdx);
  endif
  if max_abs_diff_dAsqdx> del/200
    error("max_abs_diff_dAsqdx > del/200");
  endif

  %
  % Check the diagonal of the Hessian of the squared-magnitude
  %
  [~,~,diagHessAsq] = schurOneMAPlatticePipelinedAsq(wa,k,epsilon,kkr);
  est_diagd2Asqdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,gradAsqAxP]=schurOneMAPlatticePipelinedAsq(wac,AxP(Rk),epsilon,AxP(Rkk));
    AxM=Ax-delAx;
    [~,gradAsqAxM]=schurOneMAPlatticePipelinedAsq(wac,AxM(Rk),epsilon,AxM(Rkk));
    delAx=circshift(delAx,1);
    est_diagd2Asqdx2(l)=(gradAsqAxP(l)-gradAsqAxM(l))/del;
  endfor
  max_abs_diff_diagd2Asqdx2 = max(abs(est_diagd2Asqdx2-diagHessAsq(nac,:)));
  if verbose
    printf("max_abs_diff_diagd2Asqdx2 = del/%g\n",del/max_abs_diff_diagd2Asqdx2);
  endif
  if max_abs_diff_diagd2Asqdx2 > del/10
    error("max_abs_diff_diagd2Asqdx2 > del/10");
  endif

  %
  % Check the Hessian of the squared-magnitude
  %
  [~,~,~,hessAsq]=schurOneMAPlatticePipelinedAsq(wa,k,epsilon,kkr);
  est_d2Asqdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,gradAsqAxP] = ...
        schurOneMAPlatticePipelinedAsq(wac,AxP(Rk),epsilon,AxP(Rkk));
      AxM=Ax-delAx;
      [~,gradAsqAxM] = ...
        schurOneMAPlatticePipelinedAsq(wac,AxM(Rk),epsilon,AxM(Rkk));
      delAx=circshift(delAx,1);
      est_d2Asqdydx(l,m)=(gradAsqAxP(l)-gradAsqAxM(l))/del;
    endfor
  endfor
  max_abs_diff_d2Asqdydx = ...
    max(max(abs(est_d2Asqdydx-squeeze(hessAsq(nac,:,:)))));
  if verbose
    printf("max_abs_diff_d2Asqdydx = del/%g\n",del/max_abs_diff_d2Asqdydx);
  endif
  if max_abs_diff_d2Asqdydx > del/10
    error("max_abs_diff_d2Asqdydx > del/10");
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
