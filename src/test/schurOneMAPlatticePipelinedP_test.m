% schurOneMAPlatticePipelinedP_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMAPlatticePipelinedP_test";

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
  % Check the phase response
  %
  h=freqz(flipud(d(:)),d(:),wp);
  P = schurOneMAPlatticePipelinedP(wp,k,epsilon,kk);
  max_abs_diff_P=max(abs(P(2:npc)-unwrap(arg(h(2:npc)))));
  if verbose
    printf("max_abs_diff_P = %g*eps\n",max_abs_diff_P/eps);
  endif
  if max_abs_diff_P > 2000*eps
    error("max_abs_diff_P > 2000*eps");
  endif

  %
  % Check the gradients of the phase
  %
  [~,gradP] = schurOneMAPlatticePipelinedP(wp,k,epsilon,kkr);
  est_dPdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    PAxP=schurOneMAPlatticePipelinedP(wpc,AxP(Rk),epsilon,AxP(Rkk));
    AxM=Ax-delAx;
    PAxM=schurOneMAPlatticePipelinedP(wpc,AxM(Rk),epsilon,AxM(Rkk));
    delAx=circshift(delAx,1);
    est_dPdx(l)=(PAxP-PAxM)/del;
  endfor
  max_abs_diff_dPdx = max(abs(est_dPdx-gradP(npc,:)));
  if verbose
    printf("max_abs_diff_dPdx = del/%g\n", del/max_abs_diff_dPdx);
  endif
  if max_abs_diff_dPdx> del/600
    error("max_abs_diff_dPdx > del/600");
  endif

  %
  % Check the diagonal of the Hessian of the phase
  %
  [~,~,diagHessP] = schurOneMAPlatticePipelinedP(wp,k,epsilon,kkr);
  est_diagd2Pdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,gradPAxP]=schurOneMAPlatticePipelinedP(wpc,AxP(Rk),epsilon,AxP(Rkk));
    AxM=Ax-delAx;
    [~,gradPAxM]=schurOneMAPlatticePipelinedP(wpc,AxM(Rk),epsilon,AxM(Rkk));
    delAx=circshift(delAx,1);
    est_diagd2Pdx2(l)=(gradPAxP(l)-gradPAxM(l))/del;
  endfor
  max_abs_diff_diagd2Pdx2 = max(abs(est_diagd2Pdx2-diagHessP(npc,:)));
  if verbose
    printf("max_abs_diff_diagd2Pdx2 = del/%g\n",del/max_abs_diff_diagd2Pdx2);
  endif
  if max_abs_diff_diagd2Pdx2 > del/80
    error("max_abs_diff_diagd2Pdx2 > del/80");
  endif

  %
  % Check the Hessian of the phase
  %
  [~,~,~,hessP]=schurOneMAPlatticePipelinedP(wp,k,epsilon,kkr);
  est_d2Pdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,gradPAxP] = ...
        schurOneMAPlatticePipelinedP(wpc,AxP(Rk),epsilon,AxP(Rkk));
      AxM=Ax-delAx;
      [~,gradPAxM] = ...
        schurOneMAPlatticePipelinedP(wpc,AxM(Rk),epsilon,AxM(Rkk));
      delAx=circshift(delAx,1);
      est_d2Pdydx(l,m)=(gradPAxP(l)-gradPAxM(l))/del;
    endfor
  endfor
  max_abs_diff_d2Pdydx = ...
    max(max(abs(est_d2Pdydx-squeeze(hessP(npc,:,:)))));
  if verbose
    printf("max_abs_diff_d2Pdydx = del/%g\n",del/max_abs_diff_d2Pdydx);
  endif
  if max_abs_diff_d2Pdydx > del/50
    error("max_abs_diff_d2Pdydx > del/50");
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
