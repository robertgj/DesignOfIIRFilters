% schurOneMPAlatticePipelinedP_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMPAlatticePipelinedP_test";

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
  % Check the phase response
  %
  P=schurOneMPAlatticePipelinedP ...
        (wp,A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk,difference);
  h=freqz(n,d,wp);
  max_abs_diff_P=max(abs(unwrap(arg(h(2:npc)))-P(2:npc)));
  if verbose
    printf("max_abs_diff_P = %g*eps\n",max_abs_diff_P/eps);
  endif
  if x==1
    tol_eps=50;
  elseif x==2
    tol_eps=5e7;
  endif
  if max_abs_diff_P > tol_eps*eps
    error("max_abs_diff_P > %g*eps",tol_eps);
  endif

  %
  % Check the gradients of the phase
  %
  [~,gradP]=schurOneMPAlatticePipelinedP ...
    (wp,A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference);
  est_dPdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    PAxP=schurOneMPAlatticePipelinedP ...
             (wpc,AxP(RA1k),A1epsilon,AxP(RA1kk), ...
              AxP(RA2k),A2epsilon,AxP(RA2kk),difference);
    AxM=Ax-delAx;
    PAxM=schurOneMPAlatticePipelinedP ...
             (wpc,AxM(RA1k),A1epsilon,AxM(RA1kk), ...
              AxM(RA2k),A2epsilon,AxM(RA2kk),difference);
    delAx=circshift(delAx,1);
    est_dPdx(l)=(PAxP-PAxM)/del;
  endfor
  max_abs_diff_dPdx = max(abs(est_dPdx-gradP(npc,:)));
  if verbose
    printf("max_abs_diff_dPdx = del/%g\n", del/max_abs_diff_dPdx);
  endif
  if max_abs_diff_dPdx> del/1000
    error("max_abs_diff_dPdx > del/1000");
  endif

  %
  % Check the diagonal of the Hessian of the phase
  %
  [~,~,diagHessP]=schurOneMPAlatticePipelinedP ... 
    (wp,A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference);
  est_diagd2Pdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,gradPAxP]=schurOneMPAlatticePipelinedP ...
                      (wpc,AxP(RA1k),A1epsilon,AxP(RA1kk), ...
                       AxP(RA2k),A2epsilon,AxP(RA2kk),difference);
    AxM=Ax-delAx;
    [~,gradPAxM]=schurOneMPAlatticePipelinedP ...
                      (wpc,AxM(RA1k),A1epsilon,AxM(RA1kk), ...
                       AxM(RA2k),A2epsilon,AxM(RA2kk),difference);
    delAx=circshift(delAx,1);
    est_diagd2Pdx2(l)=(gradPAxP(l)-gradPAxM(l))/del;
  endfor
  max_abs_diff_diagd2Pdx2 = max(abs(est_diagd2Pdx2-diagHessP(npc,:)));
  if verbose
    printf("max_abs_diff_diagd2Pdx2 = del/%g\n",del/max_abs_diff_diagd2Pdx2);
  endif
  if max_abs_diff_diagd2Pdx2 > del/50
    error("max_abs_diff_diagd2Pdx2 > del/50");
  endif

  %
  % Check the Hessian of the phase
  %
  [~,~,~,hessP]=schurOneMPAlatticePipelinedP ... 
    (wp,A1k,A1epsilon,A1kkr,A2k,A2epsilon,A2kkr,difference);
  est_d2Pdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,gradPAxP]=schurOneMPAlatticePipelinedP ...
                       (wpc,AxP(RA1k),A1epsilon,AxP(RA1kk), ...
                        AxP(RA2k),A2epsilon,AxP(RA2kk),difference);
      AxM=Ax-delAx;
      [~,gradPAxM]=schurOneMPAlatticePipelinedP ...
                       (wpc,AxM(RA1k),A1epsilon,AxM(RA1kk), ...
                        AxM(RA2k),A2epsilon,AxM(RA2kk),difference);
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
