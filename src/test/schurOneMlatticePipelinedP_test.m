% schurOneMlatticePipelinedP_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

verbose=false;

strf="schurOneMlatticePipelinedP_test";

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
  % Check the phase response
  %
  h=freqz(n,d,wp);
  P=schurOneMlatticePipelinedP(wp,k,epsilon,c,kk,ck);
  max_abs_diff_P=max(abs(unwrap(arg(h(2:npc)))-P(2:npc)));
  if verbose
    printf("max_abs_diff_P = %g*eps\n",max_abs_diff_P/eps);
  endif
  if max_abs_diff_P > 1e4*eps
    error("max_abs_diff_P > 1e4*eps");
  endif

  %
  % Check the gradients of the phase
  %
  [~,gradP] = schurOneMlatticePipelinedP(wp,k,epsilon,c,kkr,ckr);
  est_dPdx=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    PAxP=schurOneMlatticePipelinedP ...
             (wpc,AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
    AxM=Ax-delAx;
    PAxM=schurOneMlatticePipelinedP ...
             (wpc,AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));
    delAx=circshift(delAx,1);
    est_dPdx(l)=(PAxP-PAxM)/del;
  endfor
  max_abs_diff_dPdx = max(abs(est_dPdx-gradP(npc,:)));
  if verbose
    printf("max_abs_diff_dPdx = del/%g\n", del/max_abs_diff_dPdx);
  endif
  if max_abs_diff_dPdx> del/800
    error("max_abs_diff_dPdx > del/800");
  endif

  %
  % Check the diagonal of the Hessian of the phase
  %
  [~,~,diagHessP] = schurOneMlatticePipelinedP(wp,k,epsilon,c,kkr,ckr);
  est_diagd2Pdx2=zeros(1,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [~,gradPAxP]=schurOneMlatticePipelinedP ...
                    (wpc,AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
    AxM=Ax-delAx;
    [~,gradPAxM]=schurOneMlatticePipelinedP ...
                     (wpc,AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));
    delAx=circshift(delAx,1);
    est_diagd2Pdx2(l)=(gradPAxP(l)-gradPAxM(l))/del;
  endfor
  max_abs_diff_diagd2Pdx2 = ...
    max(abs(est_diagd2Pdx2-diagHessP(npc,:)));
  if verbose
    printf("max_abs_diff_diagd2Pdx2 = del/%g\n",
           del/max_abs_diff_diagd2Pdx2);
  endif
  if max_abs_diff_diagd2Pdx2 > del/50
    error("max_abs_diff_diagd2Pdx2 > del/50");
  endif

  %
  % Check the Hessian of the phase
  %
  [~,~,~,hessP] = schurOneMlatticePipelinedP(wp,k,epsilon,c,kkr,ckr);
  est_d2Pdydx=zeros(Nx,Nx);
  delAx=zeros(size(Ax));
  del=1e-6;
  delAx(1)=del/2;
  for l=1:Nx
    for m=1:Nx
      AxP=Ax+delAx;
      [~,gradPAxP]=schurOneMlatticePipelinedP ...
                       (wpc,AxP(Rk),epsilon,AxP(Rc),AxP(Rkk),AxP(Rck));
      AxM=Ax-delAx;
      [~,gradPAxM]=schurOneMlatticePipelinedP ...
                       (wpc,AxM(Rk),epsilon,AxM(Rc),AxM(Rkk),AxM(Rck));
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
