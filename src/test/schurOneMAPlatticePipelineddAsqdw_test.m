% schurOneMAPlatticePipelineddAsqdw_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMAPlatticePipelineddAsqdw_test";

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
  wmany=(0:((nplot*1000)-1))'*pi/(nplot*1000);
  dAsqdw=schurOneMAPlatticePipelineddAsqdw(wmany,k,epsilon,kkr);
  [Aap,Bap,Cap,Dap]=schurOneMAPlatticePipelined2Abcd(k,epsilon,kkr);
  h=Abcd2H(wmany,Aap,Bap,Cap,Dap);
  est_dAsqdw=diff(abs(h).^2)./diff(wmany);
  max_abs_diff_dAsqdw=max(abs(est_dAsqdw - ...
                              ((dAsqdw(1:(end-1))+dAsqdw(2:end))/2)));
  if verbose
    printf("max_abs_diff_dAsqdw = %g\n",max_abs_diff_dAsqdw);
  endif
  if max_abs_diff_dAsqdw > 1e-8
    error("max_abs_diff_dAsqdw > 1e-8");
  endif

  %
  % Check the gradients of the squared-magnitude
  %
  [~,graddAsqdw] = schurOneMAPlatticePipelineddAsqdw(wd,k,epsilon,kkr);
  est_ddAsqdwdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    dAsqdwAxP=schurOneMAPlatticePipelineddAsqdw(wdc,AxP(Rk),epsilon,AxP(Rkk));
    AxM=Ax-delAx;
    dAsqdwAxM=schurOneMAPlatticePipelineddAsqdw(wdc,AxM(Rk),epsilon,AxM(Rkk));
    delAx=circshift(delAx,1);
    est_ddAsqdwdx(l)=(dAsqdwAxP-dAsqdwAxM)/del;
  endfor
  max_abs_diff_ddAsqdwdx = max(abs(est_ddAsqdwdx-graddAsqdw(ndc,:)));
  if verbose
    printf("max_abs_diff_ddAsqdwdx = del/%g\n", del/max_abs_diff_ddAsqdwdx);
  endif
  if max_abs_diff_ddAsqdwdx> del/20
    error("max_abs_diff_ddAsqdwdx > del/20");
  endif

  %
  % Check the diagonal of the Hessian of the squared-magnitude
  %
  [~,~,diagHessdAsqdw] = schurOneMAPlatticePipelineddAsqdw(wd,k,epsilon,kkr);
  est_diagd2dAsqdwdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,graddAsqdwAxP] = ...
      schurOneMAPlatticePipelineddAsqdw(wdc,AxP(Rk),epsilon,AxP(Rkk));
    AxM=Ax-delAx;
    [~,graddAsqdwAxM] = ...
      schurOneMAPlatticePipelineddAsqdw(wdc,AxM(Rk),epsilon,AxM(Rkk));
    delAx=circshift(delAx,1);
    est_diagd2dAsqdwdx2(l)=(graddAsqdwAxP(l)-graddAsqdwAxM(l))/del;
  endfor
  max_abs_diff_diagd2dAsqdwdx2 = ...
    max(abs(est_diagd2dAsqdwdx2-diagHessdAsqdw(ndc,:)));
  if verbose
    printf("max_abs_diff_diagd2dAsqdwdx2 = del/%g\n", ...
           del/max_abs_diff_diagd2dAsqdwdx2);
  endif
  if max_abs_diff_diagd2dAsqdwdx2 > del
    error("max_abs_diff_diagd2dAsqdwdx2 > del");
  endif

  %
  % Check the Hessian of the squared-magnitude
  %
  [~,~,~,hessdAsqdw]=schurOneMAPlatticePipelineddAsqdw(wd,k,epsilon,kkr);
  est_d2dAsqdwdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,graddAsqdwAxP] = ...
        schurOneMAPlatticePipelineddAsqdw(wdc,AxP(Rk),epsilon,AxP(Rkk));
      AxM=Ax-delAx;
      [~,graddAsqdwAxM] = ...
        schurOneMAPlatticePipelineddAsqdw(wdc,AxM(Rk),epsilon,AxM(Rkk));
      delAx=circshift(delAx,1);
      est_d2dAsqdwdydx(l,m)=(graddAsqdwAxP(l)-graddAsqdwAxM(l))/del;
    endfor
  endfor
  max_abs_diff_d2dAsqdwdydx = ...
    max(max(abs(est_d2dAsqdwdydx-squeeze(hessdAsqdw(ndc,:,:)))));
  if verbose
    printf("max_abs_diff_d2dAsqdwdydx = del/%g\n", ...
           del/max_abs_diff_d2dAsqdwdydx);
  endif
  if max_abs_diff_d2dAsqdwdydx > 2*del
    error("max_abs_diff_d2dAsqdwdydx > 2*del");
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
