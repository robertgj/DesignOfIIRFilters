% schurOneMlatticePipelinedAsq_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMlatticePipelinedAsq_test";

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
  % Check the squared-magnitude response
  %
  h=freqz(n,d,wa);
  Asq = schurOneMlatticePipelinedAsq(wa,k,epsilon,c,kk,ck);
  max_abs_diff_Asq=max(abs((abs(h).^2)-Asq));
  if verbose
    printf("max_abs_diff_Asq = %g\n",max_abs_diff_Asq);
  endif
  if max_abs_diff_Asq > 1e-12
    error("max_abs_diff_Asq > 1e-12");
  endif

  %
  % Check the gradients of the squared-magnitude
  %
  [~,gradAsq] = schurOneMlatticePipelinedAsq(wa,k,epsilon,c,kkr,ckr);
  est_dAsqdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    AsqAxP=schurOneMlatticePipelinedAsq ...
             (wac,AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
    AxM=Ax-delAx;
    AsqAxM=schurOneMlatticePipelinedAsq ...
             (wac,AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));
    delAx=circshift(delAx,1);
    est_dAsqdx(l)=(AsqAxP-AsqAxM)/del;
  endfor
  max_abs_diff_dAsqdx = max(abs(est_dAsqdx-gradAsq(nac,:)));
  if verbose
    printf("max_abs_diff_dAsqdx = del/%g\n", del/max_abs_diff_dAsqdx);
  endif
  if max_abs_diff_dAsqdx> del/600
    error("max_abs_diff_dAsqdx > del/600");
  endif

  %
  % Check the diagonal of the Hessian of the squared-magnitude
  %
  [~,~,diagHessAsq] = schurOneMlatticePipelinedAsq(wa,k,epsilon,c,kkr,ckr);
  est_diagd2Asqdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,gradAsqAxP]=schurOneMlatticePipelinedAsq ...
                    (wac,AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
    AxM=Ax-delAx;
    [~,gradAsqAxM]=schurOneMlatticePipelinedAsq ...
                     (wac,AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));
    delAx=circshift(delAx,1);
    est_diagd2Asqdx2(l)=(gradAsqAxP(l)-gradAsqAxM(l))/del;
  endfor
  max_abs_diff_diagd2Asqdx2 = ...
    max(abs(est_diagd2Asqdx2-diagHessAsq(nac,:)));
  if verbose
    printf("max_abs_diff_diagd2Asqdx2 = del/%g\n", ...
           del/max_abs_diff_diagd2Asqdx2);
  endif
  if max_abs_diff_diagd2Asqdx2 > del/20
    error("max_abs_diff_diagd2Asqdx2 > del/20");
  endif

  %
  % Check the Hessian of the squared-magnitude
  %
  [~,~,~,hessAsq] = schurOneMlatticePipelinedAsq(wa,k,epsilon,c,kkr,ckr);
  est_d2Asqdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,gradAsqAxP]=schurOneMlatticePipelinedAsq ...
                       (wac,AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
      AxM=Ax-delAx;
      [~,gradAsqAxM]=schurOneMlatticePipelinedAsq ...
                       (wac,AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));
      delAx=circshift(delAx,1);
      est_d2Asqdydx(l,m)=(gradAsqAxP(l)-gradAsqAxM(l))/del;
    endfor
  endfor
  max_abs_diff_d2Asqdydx = ...
    max(max(abs(est_d2Asqdydx-squeeze(hessAsq(nac,:,:)))));
  if verbose
    printf("max_abs_diff_d2Asqdydx = del/%g\n",del/max_abs_diff_d2Asqdydx);
  endif
  if max_abs_diff_d2Asqdydx > del/20
    error("max_abs_diff_d2Asqdydx > del/20");
  endif
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
