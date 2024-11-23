% schurOneMPAlatticeDoublyPipelineddAsqdw_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMPAlatticeDoublyPipelineddAsqdw_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2

  schur_lattice_test_common;
  
  % Convert filter transfer function to Schur 1-multiplier lattice form
  A1k=schurdecomp(Da1);
  A1Nk=length(A1k);
  A2k=schurdecomp(Db1);
  A2Nk=length(A2k);
  
  Ax=[A1k(:);A2k(:)];
  RA1k=1:A1Nk;
  RA2k=(A1Nk+1):(A1Nk+A2Nk);
  Nx=A1Nk+A2Nk;

  %
  % Check the gradient of the squared-magnitude response
  %
  wmany=(0:((nplot*1000)-1))'*pi/(nplot*1000);
  dAsqdw=schurOneMPAlatticeDoublyPipelineddAsqdw(wmany/2,A1k,A2k,difference);
  [h,wmany]=freqz(n,d,wmany);
  est_dAsqdw=diff(abs(h).^2)./diff(wmany);
  max_abs_diff_dAsqdw=max(abs(est_dAsqdw - ...
                              ((dAsqdw(1:(end-1))+dAsqdw(2:end))/4)));
  if verbose
    printf("max_abs_diff_dAsqdw = %g\n",max_abs_diff_dAsqdw);
  endif
  if max_abs_diff_dAsqdw > 1e-6
    error("max_abs_diff_dAsqdw > 1e-6");
  endif
  
  %
  % Check the gradients of the gradient of the squared-magnitude
  %
  try
    [dAsqdw,graddAsqdw]=schurOneMPAlatticeDoublyPipelineddAsqdw ...
                          (wd/2,A1k,A2k,difference);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      fprintf(stderr,"Called %s at line %d\n", ...
              err.stack(e).name,err.stack(e).line);
    endfor
    error("%s : %s\n", err.stack(1).name,err.message);
  end_try_catch
  
  est_ddAsqdwdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    dAsqdwAxP=schurOneMPAlatticeDoublyPipelineddAsqdw ...
                (wdc/2,AxP(RA1k),AxP(RA2k),difference);
    AxM=Ax-delAx;
    dAsqdwAxM=schurOneMPAlatticeDoublyPipelineddAsqdw ...
                (wdc/2,AxM(RA1k),AxM(RA2k),difference);
    delAx=circshift(delAx,1);
    est_ddAsqdwdx(l)=(dAsqdwAxP-dAsqdwAxM)/del;
  endfor
  max_abs_diff_ddAsqdwdx = max(abs(est_ddAsqdwdx-graddAsqdw(ndc,:)));
  if verbose
    printf("max_abs_diff_ddAsqdwdx = del/%g\n", del/max_abs_diff_ddAsqdwdx);
  endif
  if max_abs_diff_ddAsqdwdx> del/60
    error("max_abs_diff_ddAsqdwdx > del/60");
  endif

  %
  % Check the diagonal of the Hessian of the gradient of the squared-magnitude
  %
  try
    [~,~,diagHessdAsqdw]=schurOneMPAlatticeDoublyPipelineddAsqdw ...
                           (wd/2,A1k,A2k,difference);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      fprintf(stderr,"Called %s at line %d\n", ...
              err.stack(e).name,err.stack(e).line);
    endfor
    error("%s : %s\n", err.stack(1).name,err.message);
  end_try_catch
  est_diagd2dAsqdwdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,graddAsqdwAxP]=schurOneMPAlatticeDoublyPipelineddAsqdw ...
                      (wdc/2,AxP(RA1k),AxP(RA2k),difference);
    AxM=Ax-delAx;
    [~,graddAsqdwAxM]=schurOneMPAlatticeDoublyPipelineddAsqdw ...
                      (wdc/2,AxM(RA1k),AxM(RA2k),difference);
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
  % Check the Hessian of the gradient of the squared-magnitude
  %
  [~,~,~,hessdAsqdw]=schurOneMPAlatticeDoublyPipelineddAsqdw ...
                       (wd/2,A1k,A2k,difference);
  est_d2dAsqdwdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,graddAsqdwAxP]=schurOneMPAlatticeDoublyPipelineddAsqdw ...
                       (wdc/2,AxP(RA1k),AxP(RA2k),difference);
      AxM=Ax-delAx;
      [~,graddAsqdwAxM]=schurOneMPAlatticeDoublyPipelineddAsqdw ...
                       (wdc/2,AxM(RA1k),AxM(RA2k),difference);
      delAx=circshift(delAx,1);
      est_d2dAsqdwdydx(l,m)=(graddAsqdwAxP(l)-graddAsqdwAxM(l))/del;
    endfor
  endfor
  max_abs_diff_d2dAsqdwdydx = ...
    max(max(abs(est_d2dAsqdwdydx-squeeze(hessdAsqdw(ndc,:,:)))));
  if verbose
    printf("max_abs_diff_d2dAsqdwdydx = del/%g\n",del/max_abs_diff_d2dAsqdwdydx);
  endif
  if max_abs_diff_d2dAsqdwdydx > del
    error("max_abs_diff_d2dAsqdwdydx > del");
  endif
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
