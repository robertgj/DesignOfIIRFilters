% schurOneMPAlatticePipelineddAsqdw_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMPAlatticePipelineddAsqdw_test";

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
  % Check the gradient of the squared-magnitude response
  %
  wmany=(0:((nplot*1000)-1))'*pi/(nplot*1000);
  dAsqdw=schurOneMPAlatticePipelineddAsqdw ...
           (wmany,A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk,difference);
  [h,wmany]=freqz(n,d,wmany);
  est_dAsqdw=diff(abs(h).^2)./diff(wmany);
  max_abs_diff_dAsqdw=max(abs(est_dAsqdw - ...
                              ((dAsqdw(1:(end-1))+dAsqdw(2:end))/2)));
  if verbose
    printf("max_abs_diff_dAsqdw = %g\n",max_abs_diff_dAsqdw);
  endif
  if max_abs_diff_dAsqdw > 5e-7
    error("max_abs_diff_dAsqdw > 5e-7");
  endif

  %
  % Check the gradients of the gradient of the squared-magnitude
  %
  [~,graddAsqdw]=schurOneMPAlatticePipelineddAsqdw ...
    (wd,A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference);
  est_ddAsqdwdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    dAsqdwAxP=schurOneMPAlatticePipelineddAsqdw ...
             (wdc,AxP(RA1k),A1epsilon,AxP(RA1kk), ...
              AxP(RA2k),A2epsilon,AxP(RA2kk),difference);
    AxM=Ax-delAx;
    dAsqdwAxM=schurOneMPAlatticePipelineddAsqdw ...
             (wdc,AxM(RA1k),A1epsilon,AxM(RA1kk), ...
              AxM(RA2k),A2epsilon,AxM(RA2kk),difference);
    delAx=circshift(delAx,1);
    est_ddAsqdwdx(l)=(dAsqdwAxP-dAsqdwAxM)/del;
  endfor
  max_abs_diff_ddAsqdwdx = max(abs(est_ddAsqdwdx-graddAsqdw(ndc,:)));
  if verbose
    printf("max_abs_diff_ddAsqdwdx = del/%g\n", del/max_abs_diff_ddAsqdwdx);
  endif
  if max_abs_diff_ddAsqdwdx> del/80
    error("max_abs_diff_ddAsqdwdx > del/80");
  endif

  %
  % Check the diagonal of the Hessian of the gradient of the squared-magnitude
  %
  [~,~,diagHessdAsqdw]=schurOneMPAlatticePipelineddAsqdw ... 
    (wd,A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference);
  est_diagd2dAsqdwdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,graddAsqdwAxP]=schurOneMPAlatticePipelineddAsqdw ...
                      (wdc,AxP(RA1k),A1epsilon,AxP(RA1kk), ...
                       AxP(RA2k),A2epsilon,AxP(RA2kk),difference);
    AxM=Ax-delAx;
    [~,graddAsqdwAxM]=schurOneMPAlatticePipelineddAsqdw ...
                      (wdc,AxM(RA1k),A1epsilon,AxM(RA1kk), ...
                       AxM(RA2k),A2epsilon,AxM(RA2kk),difference);
    delAx=circshift(delAx,1);
    est_diagd2dAsqdwdx2(l)=(graddAsqdwAxP(l)-graddAsqdwAxM(l))/del;
  endfor
  max_abs_diff_diagd2dAsqdwdx2 = ...
    max(abs(est_diagd2dAsqdwdx2-diagHessdAsqdw(ndc,:)));
  if verbose
    printf("max_abs_diff_diagd2dAsqdwdx2 = del/%g\n", ...
           del/max_abs_diff_diagd2dAsqdwdx2);
  endif
  if max_abs_diff_diagd2dAsqdwdx2 > del/4
    error("max_abs_diff_diagd2dAsqdwdx2 > del/4");
  endif

  %
  % Check the Hessian of the gradient of the squared-magnitude
  %
  [~,~,~,hessdAsqdw]=schurOneMPAlatticePipelineddAsqdw ... 
    (wd,A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference);
  est_d2dAsqdwdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,graddAsqdwAxP]=schurOneMPAlatticePipelineddAsqdw ...
                       (wdc,AxP(RA1k),A1epsilon,AxP(RA1kk), ...
                        AxP(RA2k),A2epsilon,AxP(RA2kk),difference);
      AxM=Ax-delAx;
      [~,graddAsqdwAxM]=schurOneMPAlatticePipelineddAsqdw ...
                       (wdc,AxM(RA1k),A1epsilon,AxM(RA1kk), ...
                        AxM(RA2k),A2epsilon,AxM(RA2kk),difference);
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
