% schurOneMlatticePipelinedT_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMlatticePipelinedT_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

for x=1:2

  schur_lattice_test_common;
  
  % Convert filter transfer function to Schur 1-multiplier lattice form
  [k,epsilon,c,kk,ck]=tf2schurOneMlatticePipelined(n,d);
  Nk=length(k);
  Nc=length(c);
  Nkk=length(kk);
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
  % Check the group-delay response
  %
  t = delayz(n,d,wt);
  T = schurOneMlatticePipelinedT(wt,k,epsilon,c,kk,ck);
  max_abs_diff_T=max(abs(t-T));
  if verbose
    printf("max_abs_diff_T = %g\n",max_abs_diff_T);
  endif
  if max_abs_diff_T > 1e-9
    error("max_abs_diff_T > 1e-9");
  endif

  %
  % Check the gradients of the group-delay
  %
  [~,gradT] = schurOneMlatticePipelinedT(wt,k,epsilon,c,kkr,ckr);
  est_dTdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    TAxP=schurOneMlatticePipelinedT ...
             (wtc,AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
    AxM=Ax-delAx;
    TAxM=schurOneMlatticePipelinedT ...
             (wtc,AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));
    delAx=circshift(delAx,1);
    est_dTdx(l)=(TAxP-TAxM)/del;
  endfor
  max_abs_diff_dTdx = max(abs(est_dTdx-gradT(ntc,:)));
  if verbose
    printf("max_abs_diff_dTdx = del/%g\n", del/max_abs_diff_dTdx);
  endif
  if max_abs_diff_dTdx> del/60
    error("max_abs_diff_dTdx > del/60");
  endif

  %
  % Check the diagonal of the Hessian of the group-delay
  %
  [~,~,diagHessT] = schurOneMlatticePipelinedT(wt,k,epsilon,c,kkr,ckr);
  est_diagd2Tdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,gradTAxP]=schurOneMlatticePipelinedT ...
                    (wtc,AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
    AxM=Ax-delAx;
    [~,gradTAxM]=schurOneMlatticePipelinedT ...
                     (wtc,AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));
    delAx=circshift(delAx,1);
    est_diagd2Tdx2(l)=(gradTAxP(l)-gradTAxM(l))/del;
  endfor
  max_abs_diff_diagd2Tdx2 = ...
    max(abs(est_diagd2Tdx2-diagHessT(ntc,:)));
  if verbose
    printf("max_abs_diff_diagd2Tdx2 = del/%g\n", ...
           del/max_abs_diff_diagd2Tdx2);
  endif
  if max_abs_diff_diagd2Tdx2 > del/5
    error("max_abs_diff_diagd2Tdx2 > del/5");
  endif

  %
  % Check the Hessian of the group-delay
  %
  [~,~,~,hessT] = schurOneMlatticePipelinedT(wt,k,epsilon,c,kkr,ckr);
  est_d2Tdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,gradTAxP]=schurOneMlatticePipelinedT ...
                       (wtc,AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
      AxM=Ax-delAx;
      [~,gradTAxM]=schurOneMlatticePipelinedT ...
                       (wtc,AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));
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
