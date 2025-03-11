% schurOneMlatticePipelineddAsqdw_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMlatticePipelineddAsqdw_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2

  schur_lattice_test_common;
  
  % Convert filter transfer function to Schur 1-multiplier lattice form
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  Nk=length(k);
  Nc=length(c);
  kk=k(1:(Nk-1)).*k(2:Nk);
  Nkk=length(kk);
  ck=c(2:Nk).*k(2:Nk);
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
  % Check the gradient of the squared-magnitude response
  %
  wmany=(0:((nplot*1000)-1))'*pi/(nplot*1000);
  dAsqdw=schurOneMlatticePipelineddAsqdw(wmany,k,epsilon,c,kk,ck);
  [h,wmany]=freqz(n,d,wmany);
  est_dAsqdw=diff(abs(h).^2)./diff(wmany);
  max_abs_diff_dAsqdw=max(abs(est_dAsqdw - ...
                              ((dAsqdw(1:(end-1))+dAsqdw(2:end))/2)));
  if verbose
    printf("max_abs_diff_dAsqdw = %g\n",max_abs_diff_dAsqdw);
  endif
  if max_abs_diff_dAsqdw > 1e-7
    error("max_abs_diff_dAsqdw > 1e-7");
  endif

  %
  % Check the gradients of the gradient of the squared-magnitude
  %
  [~,graddAsqdw] = schurOneMlatticePipelineddAsqdw(wd,k,epsilon,c,kkr,ckr);
  est_ddAsqdwdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    dAsqdwAxP=schurOneMlatticePipelineddAsqdw ...
             (wdc,AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
    AxM=Ax-delAx;
    dAsqdwAxM=schurOneMlatticePipelineddAsqdw ...
             (wdc,AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));
    delAx=circshift(delAx,1);
    est_ddAsqdwdx(l)=(dAsqdwAxP-dAsqdwAxM)/del;
  endfor
  max_abs_diff_ddAsqdwdx = max(abs(est_ddAsqdwdx-graddAsqdw(ndc,:)));
  if verbose
    printf("max_abs_diff_ddAsqdwdx = del/%g\n", del/max_abs_diff_ddAsqdwdx);
  endif
  if max_abs_diff_ddAsqdwdx> del/50
    error("max_abs_diff_ddAsqdwdx > del/50");
  endif

  %
  % Check the diagonal of the Hessian of the gradient of the squared-magnitude
  %
  [~,~,diagHessdAsqdw] = schurOneMlatticePipelineddAsqdw(wd,k,epsilon,c,kkr,ckr);
  est_diagd2dAsqdwdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,graddAsqdwAxP]=schurOneMlatticePipelineddAsqdw ...
                    (wdc,AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
    AxM=Ax-delAx;
    [~,graddAsqdwAxM]=schurOneMlatticePipelineddAsqdw ...
                     (wdc,AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));
    delAx=circshift(delAx,1);
    est_diagd2dAsqdwdx2(l)=(graddAsqdwAxP(l)-graddAsqdwAxM(l))/del;
  endfor
  max_abs_diff_diagd2dAsqdwdx2 = ...
    max(abs(est_diagd2dAsqdwdx2-diagHessdAsqdw(ndc,:)));
  if verbose
    printf("max_abs_diff_diagd2dAsqdwdx2 = del/%g\n", ...
           del/max_abs_diff_diagd2dAsqdwdx2);
  endif
  if max_abs_diff_diagd2dAsqdwdx2 > del/5
    error("max_abs_diff_diagd2dAsqdwdx2 > del/5");
  endif

  %
  % Check the Hessian of the gradient of the squared-magnitude
  %
  [~,~,~,hessdAsqdw] = schurOneMlatticePipelineddAsqdw(wd,k,epsilon,c,kkr,ckr);
  est_d2dAsqdwdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,graddAsqdwAxP]=schurOneMlatticePipelineddAsqdw ...
                       (wdc,AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
      AxM=Ax-delAx;
      [~,graddAsqdwAxM]=schurOneMlatticePipelineddAsqdw ...
                       (wdc,AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));
      delAx=circshift(delAx,1);
      est_d2dAsqdwdydx(l,m)=(graddAsqdwAxP(l)-graddAsqdwAxM(l))/del;
    endfor
  endfor
  max_abs_diff_d2dAsqdwdydx = ...
    max(max(abs(est_d2dAsqdwdydx-squeeze(hessdAsqdw(ndc,:,:)))));
  if verbose
    printf("max_abs_diff_d2dAsqdwdydx = del/%g\n",del/max_abs_diff_d2dAsqdwdydx);
  endif
  if max_abs_diff_d2dAsqdwdydx > del/2
    error("max_abs_diff_d2dAsqdwdydx > del/2");
  endif
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
