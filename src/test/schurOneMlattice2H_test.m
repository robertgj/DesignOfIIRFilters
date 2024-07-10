% schurOneMlattice2H_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="schurOneMlattice2H_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

check_octave_file(strtok(strf,"_"));

verbose=false;

for N=1:7,
  % Design filter transfer function
  fc=0.1;
  dBap=1;
  [n,d]=cheby1(N,dBap,2*fc);
  nplot=1024;
  Nw=250;
  wplot=(0:(Nw-1))'*pi/nplot;
  nc=floor(nplot*fc/0.5)+1;
  wc=wplot(nc);
  h=freqz(n,d,wplot);
  hap=freqz(flipud(d(:)),d(:),wplot);

  % Convert filter transfer function to Schur 1-multiplier lattice form
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  Nk=length(k);
  Nc=length(c);
  Nkc=Nk+Nc;
  [A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c);

  %
  % Check the magnitude-squared response
  %
  H=schurOneMlattice2H(wplot,A,B,C,D);
  if verbose
    printf("max(abs(h-H))=%g*eps\n",max(abs(h-H))/eps)
  endif
  if max(abs(h-H)) > 2e4*eps
    error("max(abs(h-H)) > 2e4*eps");
  endif
  HAbcd=Abcd2H(wplot,A,B,C,D);
  if verbose
    printf("max(abs(h-HAbcd))=%g*eps\n",max(abs(h-HAbcd))/eps)
  endif
  if max(abs(h-HAbcd)) > 2e4*eps
    error("max(abs(h-HAbcd)) > 2e4*eps");
  endif
  % Check the magnitude-squared response of the allpass filter
  Hap=schurOneMlattice2H(wplot,A,B,Cap,Dap);
  if verbose
    printf("max(abs(hap-Hap))=%g*eps\n",max(abs(hap-Hap))/eps)
  endif
  if max(abs(hap-Hap)) > 1e5*eps
    error("max(abs(hap-Hap)) > 1e5*eps");
  endif
  HapAbcd=Abcd2H(wplot,A,B,Cap,Dap);
  if verbose
    printf("max(abs(hap-HapAbcd))=%g*eps\n",max(abs(hap-HapAbcd))/eps)
  endif
  if max(abs(hap-HapAbcd)) > 3e4*eps
    error("max(abs(hap-HapAbcd)) > 3e4*eps");
  endif

  %
  % Check the gradient of H wrt w
  %
  [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc]=schurOneMlattice2Abcd(k,epsilon,p,c);
  [H,dHdw]=schurOneMlattice2H(wplot,A,B,C,D);
  [HAbcd,dHdwAbcd]=Abcd2H(wplot,A,B,C,D);
  if verbose
    printf("max(abs(dHdwAbcd-dHdw))=%g*eps\n",max(abs(dHdwAbcd-dHdw))/eps)
  endif
  if max(abs(dHdwAbcd-dHdw)) > 1000*eps
    error("max(abs(dHdwAbcd-dHdw)) > 1000*eps");
  endif
  delw=1e-6;
  diff_Hw=0;
  HwPdelw2=schurOneMlattice2H(wc+delw/2,A,B,C,D);
  HwMdelw2=schurOneMlattice2H(wc-delw/2,A,B,C,D);
  est_dHdw=(HwPdelw2-HwMdelw2)/delw;
  max_abs_rel_diff_dHdw=max(abs((est_dHdw-dHdw(nc))./dHdw(nc)));
  if verbose
    printf("max_abs_rel_diff_dHdw=delw/%g\n",delw/max_abs_rel_diff_dHdw)
  endif
  if max_abs_rel_diff_dHdw > delw/2000
    error("max_abs_rel_diff_dHdw > delw/2000");
  endif

  %
  % Check the gradients of H wrt k and c
  %
  [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc]=schurOneMlattice2Abcd(k,epsilon,p,c);
  [H,dHdw,dHdkc]=schurOneMlattice2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  [HAbcd,dHdwAbcd,dHdkcAbcd]=Abcd2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  if verbose
    printf("max(max(abs(dHdkcAbcd-dHdkc))) = %g*eps\n",
           max(max(abs(dHdkcAbcd-dHdkc)))/eps)
  endif
  if max(max(abs(dHdkcAbcd-dHdkc))) > 10000*eps
    error("max(max(abs(dHdkcAbcd-dHdkc))) > 10000*eps");
  endif
  % Check the gradient of H wrt k
  del=1e-6;
  delk=zeros(size(k));
  delk(1)=del/2;
  wc=wplot(nc);
  est_dHdk=zeros(size(k));
  for l=1:Nk
    [AP,BP,CP,DP,~,~,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
        schurOneMlattice2Abcd(k+delk,epsilon,p,c);
    HkPdel2=schurOneMlattice2H(wc,AP,BP,CP,DP,dAdkcP,dBdkcP,dCdkcP,dDdkcP);
    [AM,BM,CM,DM,~,~,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
      schurOneMlattice2Abcd(k-delk,epsilon,p,c);
    HkMdel2=schurOneMlattice2H(wc,AM,BM,CM,DM,dAdkcM,dBdkcM,dCdkcM,dDdkcM);
    delk=circshift(delk,1);
    est_dHdk(l)=(HkPdel2-HkMdel2)/del;
  endfor
  max_abs_rel_diff_dHdk=max(abs((est_dHdk-dHdkc(nc,1:Nk))./dHdkc(nc,1:Nk)));
  if verbose
    printf("max_abs_rel_diff_dHdk=del/%g\n",del/max_abs_rel_diff_dHdk)
  endif
  if max_abs_rel_diff_dHdk > del/10
    error("max_abs_rel_diff_dHdk > del/10");
  endif
  % Check the gradient of H wrt c
  del=1e-6;
  delc=zeros(size(c));
  delc(1)=del/2;
  wc=wplot(nc);
  est_dHdc=zeros(size(c));
  for l=1:Nc
    [AP,BP,CP,DP,~,~,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
        schurOneMlattice2Abcd(k,epsilon,p,c+delc);
    HcPdel2=schurOneMlattice2H(wc,AP,BP,CP,DP,dAdkcP,dBdkcP,dCdkcP,dDdkcP);
    [AM,BM,CM,DM,~,~,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
      schurOneMlattice2Abcd(k,epsilon,p,c-delc);
    HcMdel2=schurOneMlattice2H(wc,AM,BM,CM,DM,dAdkcM,dBdkcM,dCdkcM,dDdkcM);
    delc=circshift(delc,1);
    est_dHdc(l)=(HcPdel2-HcMdel2)/del;
  endfor
  max_abs_rel_diff_dHdc= ...
    max(abs((est_dHdc-dHdkc(nc,(Nk+1):end))./dHdkc(nc,(Nk+1):end)));
  if verbose
    printf("max_abs_rel_diff_dHdc=del/%g\n",del/max_abs_rel_diff_dHdc);
  endif
  if max_abs_rel_diff_dHdc > del/2000
    error("max_abs_rel_diff_dHdc > del/2000");
  endif

  %
  % Check the gradient of H wrt w and k and c
  %
  [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc]=schurOneMlattice2Abcd(k,epsilon,p,c);
  [H,dHdw,dHdkc,d2Hdwdkc] = ...
    schurOneMlattice2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  [HAbcd,dHdwAbcd,dHdkcAbcd,d2HdwdkcAbcd]= ...
    Abcd2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  if verbose
    printf("max(max(abs(d2HdwdkcAbcd-d2Hdwdkc)))=%g*eps\n",
           max(max(abs(d2HdwdkcAbcd-d2Hdwdkc)))/eps);
  endif
  if max(max(abs(d2HdwdkcAbcd-d2Hdwdkc))) > 2e5*eps
    error("max(max(abs(d2HdwdkcAbcd-d2Hdwdkc))) > 2e5*eps");
  endif
  delw=1e-6;
  wc=wplot(nc);
  est_d2Hdwdkc=zeros(1,columns(dHdkc));
  [HwPdelw2,dHwPdw,dHwPdkc]=schurOneMlattice2H(wc+delw/2,A,B,C,D, ...
                                               dAdkc,dBdkc,dCdkc,dDdkc);
  [HwMdelw2,dHwMdw,dHwMdkc]=schurOneMlattice2H(wc-delw/2,A,B,C,D, ...
                                               dAdkc,dBdkc,dCdkc,dDdkc);
  est_d2Hdwdkc=(dHwPdkc-dHwMdkc)/delw;
  if verbose
    printf("est_d2Hdwdkc(end) = %g*eps\n",est_d2Hdwdkc(end)/eps);
  endif
  if est_d2Hdwdkc(end) > eps
    error("est_d2Hdwdkc(end) > eps");
  endif
  max_abs_rel_diff_d2Hdwdkc= ...
    max(abs((est_d2Hdwdkc(1:(Nkc-1))-d2Hdwdkc(nc,1:(Nkc-1))) ...
            ./d2Hdwdkc(nc,(1:Nkc-1))));
  if verbose
    printf("max_abs_rel_diff_d2Hdwdkc)) = delw/%g\n",
          del/max_abs_rel_diff_d2Hdwdkc);
  endif
  if max_abs_rel_diff_d2Hdwdkc > delw/500
    error("max_abs_rel_diff_d2Hdwdkc > delw/500");
  endif

  %
  % Check the diagonal of the Hessian of H wrt k and c
  %
  [A,B,C,D,~,~,dAdkc,dBdkc,dCdkc,dDdkc] = schurOneMlattice2Abcd(k,epsilon,p,c);
  [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2]= ...
    schurOneMlattice2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  [HAbcd,dHdwAbcd,dHdkcAbcd,d2HdwdkcAbcd,diagd2Hdkc2Abcd]= ...
    Abcd2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  if verbose
    printf("max(max(abs(diagd2Hdkc2Abcd-diagd2Hdkc2))) = %g*eps\n",
           max(max(abs(diagd2Hdkc2Abcd-diagd2Hdkc2)))/eps);
  endif
  if max(max(abs(diagd2Hdkc2Abcd-diagd2Hdkc2))) > 1e6*eps
    error("max(max(abs(diagd2Hdkc2Abcd-diagd2Hdkc2))) > 1e6*eps");
  endif
  % Check the diagonal of the Hessian of H wrt k
  del=1e-6;
  delk=zeros(size(k));
  delk(1)=del/2;
  wc=wplot(nc);
  est_d2Hdk2=zeros(1,Nk);
  for l=1:Nk
    [AkP,BkP,CkP,DkP,CapkP,DapkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
        schurOneMlattice2Abcd(k+delk,epsilon,p,c);
    [HkP,dHdwP,dHdkP]=schurOneMlattice2H(wc,AkP,BkP,CkP,DkP, ...
                                         dAdkcP,dBdkcP,dCdkcP,dDdkcP);
    [AkM,BkM,CkM,DkM,CapkM,DapkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
      schurOneMlattice2Abcd(k-delk,epsilon,p,c);
    [HkM,dHdwM,dHdkM]=schurOneMlattice2H(wc,AkM,BkM,CkM,DkM, ...
                                         dAdkcM,dBdkcM,dCdkcM,dDdkcM);
    est_d2Hdk2(l)=(dHdkP(l)-dHdkM(l))/del;
    delk=circshift(delk,1);
  endfor
  max_abs_rel_diff_d2Hdk2= ...
    max(abs((est_d2Hdk2-diagd2Hdkc2(nc,1:Nk))./diagd2Hdkc2(nc,1:Nk)));
  if verbose
    printf("max_abs_rel_diff_d2Hdk2 = del/%g\n",
           del/max_abs_rel_diff_d2Hdk2);
  endif
  if max_abs_rel_diff_d2Hdk2 > del/50
    error("max_abs_rel_diff_d2Hdk2)) > del/50");
  endif
  % Check the diagonal of the Hessian of H wrt c
  del=1e-6;
  delc=zeros(size(c));
  delc(1)=del/2;
  wc=wplot(nc);
  est_d2Hdc2=zeros(1,Nc);
  for l=1:Nc
    [AcP,BcP,CcP,DcP,CapcP,DapcP,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
        schurOneMlattice2Abcd(k,epsilon,p,c+delc);
    [HcP,dHdwP,dHdcP]=schurOneMlattice2H(wc,AcP,BcP,CcP,DcP, ...
                                         dAdkcP,dBdkcP,dCdkcP,dDdkcP);
    [AcM,BcM,CcM,DcM,CapcM,DapcM,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
      schurOneMlattice2Abcd(k,epsilon,p,c-delc);
    [HcM,dHdwM,dHdcM]=schurOneMlattice2H(wc,AcM,BcM,CcM,DcM, ...
                                         dAdkcM,dBdkcM,dCdkcM,dDdkcM);
    est_d2Hdc2(l)=(dHdcP(Nk+l)-dHdcM(Nk+l))/del;
    delc=circshift(delc,1);
  endfor
  if verbose
    printf("max(abs(est_d2Hdc2)) = %g*eps\n", max(abs(est_d2Hdc2))/eps);
  endif
  if max(abs(est_d2Hdc2)) > eps
    error("max(abs(est_d2Hdc2)) > eps");
  endif
  if verbose
    printf("max(abs(diagd2Hdkc2(nc,(Nk+1):end))) = %g*eps\n",
           max(abs(diagd2Hdkc2(nc,(Nk+1):end)))/eps);
  endif
  if max(abs(diagd2Hdkc2(nc,(Nk+1):end))) > eps
    error("max(abs(diagd2Hdkc2(nc,(Nk+1):end))) > eps");
  endif

  %
  % Check the diagonal of the second partial derivative of dHdw wrt k and c
  %
  [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2] = ...
    schurOneMlattice2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  [HAbcd,dHdwAbcd,dHdkcAbcd,d2HdwdkcAbcd,diagd2Hdkc2Abcd,diagd3Hdwdkc2Abcd]= ...
    Abcd2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  max_abs_rel_diff_diagd3Hdwdkc2Abcd = ...
    max(max(abs((diagd3Hdwdkc2Abcd-diagd3Hdwdkc2)./diagd3Hdwdkc2)));
  if verbose
    printf("max_abs_rel_diff_diagd3Hdwdkc2Abcd = %g*eps\n",
           max_abs_rel_diff_diagd3Hdwdkc2Abcd/eps);
  endif
  if max_abs_rel_diff_diagd3Hdwdkc2Abcd > 1000*eps
    error("max_abs_rel_diff_diagd3Hdwdkc2Abcd > 1000*eps");
  endif
  % Check the diagonal of the second partial derivative of dHdw wrt k
  del=1e-6;
  delk=zeros(size(k));
  delk(1)=del/2;
  wc=wplot(nc);
  est_diagd3Hdwdk2=zeros(1,Nk);
  for l=1:Nk
    [AkP,BkP,CkP,DkP,CapkP,DapkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
        schurOneMlattice2Abcd(k+delk,epsilon,p,c);
    [AkM,BkM,CkM,DkM,CapkM,DapkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
      schurOneMlattice2Abcd(k-delk,epsilon,p,c);
    delk=circshift(delk,1);

    [HkP,dHdwP,dHdkcP,d2HdwdkcP] = ...
      schurOneMlattice2H(wc,AkP,BkP,CkP,DkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP);
    [HkM,dHdwM,dHdkcM,d2HdwdkcM] = ...
      schurOneMlattice2H(wc,AkM,BkM,CkM,DkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM);
    est_diagd3Hdwdk2(l)=(d2HdwdkcP(l)-d2HdwdkcM(l))/del;
  endfor
  max_abs_rel_diff_diagd3Hdwdk2= ...
    max(max(abs((est_diagd3Hdwdk2-diagd3Hdwdkc2(nc,1:Nk)) ...
                ./diagd3Hdwdkc2(nc,1:Nk))));
  if verbose
    printf("max_abs_rel_diff_diagd3Hdwdk2 = del/%g\n",
           del/max_abs_rel_diff_diagd3Hdwdk2);
  endif
  if max_abs_rel_diff_diagd3Hdwdk2 > del/200
    error("max_abs_rel_diff_diagd3Hdwdk2 > del/200");
  endif
  % Check the diagonal of the second partial derivative of dHdw wrt c
  delc=zeros(size(c));
  delc(1)=del/2;
  est_diagd3Hdwdc2=zeros(1,Nc);
  for l=1:Nc
    [AkP,BkP,CkP,DkP,CapkP,DapkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
        schurOneMlattice2Abcd(k,epsilon,p,c+delc);
    [AkM,BkM,CkM,DkM,CapkM,DapkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
      schurOneMlattice2Abcd(k,epsilon,p,c-delc);
    delc=circshift(delc,1);

    [HkP,dHdwP,dHdkcP,d2HdwdkcP] = ...
      schurOneMlattice2H(wc,AkP,BkP,CkP,DkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP);
    [HkM,dHdwM,dHdkcM,d2HdwdkcM] = ...
      schurOneMlattice2H(wc,AkM,BkM,CkM,DkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM);
    est_diagd3Hdwdc2(l)=(d2HdwdkcP(Nk+l)-d2HdwdkcM(Nk+l))/del;
  endfor
  max_abs_diff_diagd3Hdwdc2= ...
    max(max(abs(est_diagd3Hdwdc2-diagd3Hdwdkc2(nc,(Nk+1):Nkc))));
  if verbose
    printf("max_abs_diff_diagd3Hdwdc2 = %g*eps\n",
           max_abs_diff_diagd3Hdwdc2/eps);
  endif
  if max_abs_diff_diagd3Hdwdc2 > eps
    error("max_abs_diff_diagd3Hdwdc2 > eps");
  endif

  %
  % Check the diagonal of the partial derivative of d2Hdkc2 wrt w
  %
  [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2] = ...
    schurOneMlattice2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  del=1e-6;
  delw=del/2;
  wc=wplot(nc);
  [HkP,dHdwP,dHdkcP,d2HdwdkcP,diagd2Hdkc2P] = ...
    schurOneMlattice2H(wc+delw,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  [HkM,dHdwM,dHdkcM,d2HdwdkcM,diagd2Hdkc2M] = ...
    schurOneMlattice2H(wc-delw,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  est_d3Hdwdkc2=(diagd2Hdkc2P-diagd2Hdkc2M)/del;
  max_abs_rel_diff_d3Hdwdkc2= ...
    max(abs((est_d3Hdwdkc2-diagd3Hdwdkc2(nc,:))./diagd3Hdwdkc2(nc,:)));
  if verbose
    printf("max_abs_rel_diff_d3Hdwdkc2 = del/%g\n",
           del/max_abs_rel_diff_d3Hdwdkc2);
  endif
  if max_abs_rel_diff_d3Hdwdkc2 > del/400
    error("max_abs_rel_diff_d3Hdwdkc2 > del/400");
  endif

  %
  % Check the second partial derivative of H wrt k and c
  %
  [A,B,C,D,~,~,dAdkc,dBdkc,dCdkc,dDdkc,~,~, ...
   d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx,~,~]=schurOneMlattice2Abcd(k,epsilon,p,c);
  [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2,d2Hdydx] = ...
    schurOneMlattice2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adydx);
  [HAbcd,dHdwAbcd,dHdkcAbcd,d2HdwdkcAbcd, ...
   diagd2Hdkc2Abcd,diagd3Hdwdkc2Abcd,d2HdydxAbcd]= ...
    Abcd2H(wplot,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc, ...
           d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx);
  max_abs_diff_d2HdydxAbcd = max(max(max(abs(d2HdydxAbcd-d2Hdydx))));
  if verbose
    printf("max_abs_diff_d2HdydxAbcd = %g*eps\n",
           max_abs_diff_d2HdydxAbcd/eps);
  endif
  if max_abs_diff_d2HdydxAbcd > 1e6*eps
    error("max_abs_diff_d2HdydxAbcd > 1e6*eps");
  endif
  % Check d2Hdydx is symmetric
  [l,m,n]=size(d2Hdydx);
  for v=1:l,
    if ~issymmetric(squeeze(d2Hdydx(v,:,:)),1e3*eps)
      error("d2Hdydx(v,:,:) is not symmetric");
    endif
  endfor
  % Check the second partial derivative of H wrt k
  del=1e-6;
  delk=zeros(1,Nk);
  delk(1)=del/2;
  wc=wplot(nc);
  est_d2Hdkdk=zeros(Nk,Nk);
  for l=1:Nk
    for m=1:Nk
      [AP,BP,CP,DP,~,~,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
          schurOneMlattice2Abcd(k+delk,epsilon,p,c);
      [AM,BM,CM,DM,~,~,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
        schurOneMlattice2Abcd(k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      
      [HP,dHdwP,dHdkcP] = ...
        schurOneMlattice2H(wc,AP,BP,CP,DP,dAdkcP,dBdkcP,dCdkcP,dDdkcP);
      [HM,dHdwM,dHdkcM] = ...
        schurOneMlattice2H(wc,AM,BM,CM,DM,dAdkcM,dBdkcM,dCdkcM,dDdkcM);
      
      est_d2Hdkdk(l,m)=(dHdkcP(l)-dHdkcM(l))/del;
    endfor
  endfor
  max_abs_rel_diff_d2Hdkdk= ...
    max(max(abs((est_d2Hdkdk-squeeze(d2Hdydx(nc,1:Nk,1:Nk))) ...
               ./squeeze(d2Hdydx(nc,1:Nk,1:Nk)))));
  if verbose
    printf("max_abs_rel_diff_d2Hdkdk = del/%g\n", del/max_abs_rel_diff_d2Hdkdk);
  endif
  if max_abs_rel_diff_d2Hdkdk > del/400
    error("max_abs_rel_diff_d2Hdkdk > del/400");
  endif
  % Check the second partial derivative of H wrt c
  del=1e-6;
  delc=zeros(1,Nk+1);
  delc(1)=del/2;
  wc=wplot(nc);
  est_d2Hdcdc=zeros(Nk+1,Nk+1);
  for l=1:(Nk+1)
    for m=1:(Nk+1)
      [AP,BP,CP,DP,~,~,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
          schurOneMlattice2Abcd(k,epsilon,p,c+delc);
      [AM,BM,CM,DM,~,~,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
        schurOneMlattice2Abcd(k,epsilon,p,c-delc);
      delc=circshift(delc,1);
      
      [HP,dHdwP,dHdkcP] = ...
        schurOneMlattice2H(wc,AP,BP,CP,DP,dAdkcP,dBdkcP,dCdkcP,dDdkcP);
      [HM,dHdwM,dHdkcM] = ...
        schurOneMlattice2H(wc,AM,BM,CM,DM,dAdkcM,dBdkcM,dCdkcM,dDdkcM);
      
      est_d2Hdcdc(l,m)=(dHdkcP(Nk+l)-dHdkcM(Nk+l))/del;
    endfor
  endfor
  max_abs_diff_d2Hdcdc= ...
    max(max(abs(est_d2Hdcdc-squeeze(d2Hdydx(nc,(Nk+1):Nkc,(Nk+1):Nkc)))));
  if verbose
    printf("max_abs_diff_d2Hdcdc = %g*eps\n", max_abs_diff_d2Hdcdc/eps);
  endif
  if max_abs_diff_d2Hdcdc > eps
    error("max_abs_diff_d2Hdcdc > eps");
  endif
  % Check the second partial derivative of H wrt k and c
  del=1e-6;
  delk=zeros(1,Nk);
  delk(1)=del/2;
  wc=wplot(nc);
  est_d2Hdkdc=zeros(Nk+1,Nk);
  for l=1:(Nk+1)
    for m=1:Nk
      [AP,BP,CP,DP,~,~,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
          schurOneMlattice2Abcd(k+delk,epsilon,p,c);
      [AM,BM,CM,DM,~,~,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
        schurOneMlattice2Abcd(k-delk,epsilon,p,c);
      delk=circshift(delk,1);
      
      [HP,dHdwP,dHdkcP] = ...
        schurOneMlattice2H(wc,AP,BP,CP,DP,dAdkcP,dBdkcP,dCdkcP,dDdkcP);
      [HM,dHdwM,dHdkcM] = ...
        schurOneMlattice2H(wc,AM,BM,CM,DM,dAdkcM,dBdkcM,dCdkcM,dDdkcM);
      
      est_d2Hdkdc(l,m)=(dHdkcP(Nk+l)-dHdkcM(Nk+l))/del;
    endfor
  endfor
  if any(abs(est_d2Hdkdc(end,:)))
    error("any(abs(est_d2Hdkdc(end,:)))");
  endif
  nc_d2Hdkdc=reshape(d2Hdydx(nc,(Nk+1):(Nkc-1),1:Nk),Nk,Nk);
  max_abs_rel_diff_d2Hdkdc= ...
    max(max(abs((est_d2Hdkdc(1:Nk,:)-nc_d2Hdkdc)./nc_d2Hdkdc)));
  if verbose
    printf("max_abs_rel_diff_d2Hdkdc = del/%g\n",del/max_abs_rel_diff_d2Hdkdc);
  endif
  if max_abs_rel_diff_d2Hdkdc > del/600
    error("max_abs_rel_diff_d2Hdkdc > del/600");
  endif

  %
  % Check the partial derivative of d2Hdydx wrt w
  %
  [A,B,C,D,~,~,dAdkc,dBdkc,dCdkc,dDdkc,~,~,d2Adydx]= ...
    schurOneMlattice2Abcd(k,epsilon,p,c);
  nt=[nc,1,50:50:Nw];
  [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2,d2Hdydx,d3Hdwdydx] = ...
    schurOneMlattice2H(wplot(nt),A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adydx);
  [HAbcd,dHdwAbcd,dHdkcAbcd,d2HdwdkcAbcd, ...
   diagd2Hdkc2Abcd,diagd3Hdwdkc2Abcd,d2HdydxAbcd,d3HdwdydxAbcd]= ...
    Abcd2H(wplot(nt),A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc, ...
           d2Adydx,d2Bdydx,d2Cdydx,d2Ddydx);
  v_threshold=0.1;
  v=find(abs(d3Hdwdydx)>v_threshold);
  max_abs_rel_diff_d3HdwdydxAbcd= ...
    max(abs((d3HdwdydxAbcd(v)-d3Hdwdydx(v))./d3Hdwdydx(v)));
  if verbose
    printf("max_abs_rel_diff_d3HdwdydxAbcd (>%f) = %g*eps\n",
           v_threshold,max_abs_rel_diff_d3HdwdydxAbcd/eps);
  endif
  if max_abs_rel_diff_d3HdwdydxAbcd > 3000*eps
    error("max_abs_rel_diff_d3HdwdydxAbcd (>%f) > 3000*eps", v_threshold);
  endif
  % Check d3Hdwdydx is symmetric
  [l,m,n]=size(d3Hdwdydx);
  for v=1:l,
    if ~issymmetric(squeeze(d3Hdwdydx(v,:,:)),1e3*eps)
      error("d3Hdwdydx(v,:,:) is not symmetric");
    endif
  endfor
  del=1e-6;
  for l=1:length(nt)
    wt=wplot(nt(l));
    [~,~,~,~,~,~,d2HdydxP] = ...
      schurOneMlattice2H(wt+(del/2),A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adydx);
    [~,~,~,~,~,~,d2HdydxM] = ...
      schurOneMlattice2H(wt-(del/2),A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adydx);
    
    est_d3Hdwdydx=squeeze(d2HdydxP(1,:,:)-d2HdydxM(1,:,:))/del;
    wt_d3Hdwdydx=abs(squeeze(d3Hdwdydx(l,1:Nkc,1:Nkc)));
    [u,v]=find(wt_d3Hdwdydx<del);
    nz_wt_d3Hdwdydx=wt_d3Hdwdydx;
    for w=1:length(u)
      nz_wt_d3Hdwdydx(u(w),v(w))=1;
    endfor
    max_abs_rel_diff_d3Hdwdydx = ...
      max(max(abs(abs(est_d3Hdwdydx)-wt_d3Hdwdydx)./nz_wt_d3Hdwdydx));
    if verbose
      printf("max_abs_rel_diff_d3Hdwdydx = del/%g\n",
             del/max_abs_rel_diff_d3Hdwdydx);
    endif
    if max_abs_rel_diff_d3Hdwdydx > 10*del
      error("max_abs_rel_diff_d3Hdwdydx > 10*del");
    endif
  endfor
  % Check the derivative of d2Hdwdkc wrt k
  [~,~,~,~,~,~,~,wc_d3Hdwdydx] = ...
    schurOneMlattice2H(wc,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adydx);
  wc_d3Hdwdydx=squeeze(wc_d3Hdwdydx);
  del=1e-6;
  delk=zeros(size(k));
  delk(1)=del/2;
  wc=wplot(nc);
  est_d3Hdwdkdk=zeros(Nk,Nk);
  for l=1:Nk
    for m=1:Nk
      [AkP,BkP,CkP,DkP,CapkP,DapkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
          schurOneMlattice2Abcd(k+delk,epsilon,p,c);
      [AkM,BkM,CkM,DkM,CapkM,DapkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
        schurOneMlattice2Abcd(k-delk,epsilon,p,c);
      delk=circshift(delk,1);

      [~,~,~,d2HdwdkcP]=schurOneMlattice2H(wc,AkP,BkP,CkP,DkP, ...
                                           dAdkcP,dBdkcP,dCdkcP,dDdkcP);
      [~,~,~,d2HdwdkcM]=schurOneMlattice2H(wc,AkM,BkM,CkM,DkM, ...
                                           dAdkcM,dBdkcM,dCdkcM,dDdkcM);
      est_d3Hdwdkdk(l,m)=(d2HdwdkcP(l)-d2HdwdkcM(l))/del;
    endfor
  endfor
  max_abs_rel_diff_d3Hdwdkdk= ...
    max(max(abs((est_d3Hdwdkdk-wc_d3Hdwdydx(1:Nk,1:Nk)) ...
                ./wc_d3Hdwdydx(1:Nk,1:Nk))));
  if verbose
    printf("max_abs_rel_diff_d3Hdwdkdk = del/%g\n",
           del/max_abs_rel_diff_d3Hdwdkdk);
  endif
  if max_abs_rel_diff_d3Hdwdkdk > del/200
    error("max_abs_rel_diff_d3Hdwdkdk > del/200");
  endif
  % Check the derivative of d2Hdwdkc wrt c
  del=1e-6;
  delc=zeros(size(c));
  delc(1)=del/2;
  wc=wplot(nc);
  est_d3Hdwdcdc=zeros(Nc,Nc);
  for l=1:Nc
    for m=1:Nc
      [AkP,BkP,CkP,DkP,CapkP,DapkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
          schurOneMlattice2Abcd(k,epsilon,p,c+delc);
      [~,~,~,d2HdwdkcP]=schurOneMlattice2H(wc,AkP,BkP,CkP,DkP, ...
                                           dAdkcP,dBdkcP,dCdkcP,dDdkcP);
      [AkM,BkM,CkM,DkM,CapkM,DapkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
        schurOneMlattice2Abcd(k,epsilon,p,c-delc);
      [~,~,~,d2HdwdkcM]=schurOneMlattice2H(wc,AkM,BkM,CkM,DkM, ...
                                           dAdkcM,dBdkcM,dCdkcM,dDdkcM);
      est_d3Hdwdcdc(l,m)=(d2HdwdkcP(Nk+l)-d2HdwdkcM(Nk+l))/del;
      delk=circshift(delc,1);
    endfor
  endfor
  max_abs_diff_d3Hdwdcdc= ...
    max(max(abs(est_d3Hdwdcdc - wc_d3Hdwdydx((Nk+1):Nkc,(Nk+1):Nkc))));
  if verbose
    printf("max_abs_diff_d3Hdwdcdc = %g*eps\n", max_abs_diff_d3Hdwdcdc/eps);
  endif
  if max_abs_diff_d3Hdwdcdc > eps
    error("max_abs_diff_d3Hdwdcdc > eps");
  endif
  % Check the derivative of d2Hdwdkc wrt k and c
  del=1e-6;
  delc=zeros(size(c));
  delc(1)=del/2;
  est_d3Hdwdkdc=zeros(Nk,Nc);
  for l=1:Nk
    for m=1:Nc
      [AkP,BkP,CkP,DkP,CapkP,DapkP,dAdkcP,dBdkcP,dCdkcP,dDdkcP] = ...
          schurOneMlattice2Abcd(k,epsilon,p,c+delc);
      [~,~,~,d2HdwdkcP]=schurOneMlattice2H(wc,AkP,BkP,CkP,DkP, ...
                                           dAdkcP,dBdkcP,dCdkcP,dDdkcP);
      [AkM,BkM,CkM,DkM,CapkM,DapkM,dAdkcM,dBdkcM,dCdkcM,dDdkcM] = ...
        schurOneMlattice2Abcd(k,epsilon,p,c-delc);
      [~,~,~,d2HdwdkcM]=schurOneMlattice2H(wc,AkM,BkM,CkM,DkM, ...
                                           dAdkcM,dBdkcM,dCdkcM,dDdkcM);
      est_d3Hdwdkdc(l,m)=(d2HdwdkcP(l)-d2HdwdkcM(l))/del;
      delc=circshift(delc,1);
    endfor
  endfor
  if any(abs(est_d3Hdwdkdc(:,Nc)))
    error("any(abs(est_d3Hdwdkdc(:,Nc)))");
  endif
  nz_wc_d3Hdwdkdc=wc_d3Hdwdydx(1:Nk,(Nk+1):(Nkc-1));
  max_abs_rel_diff_d3Hdwdkdc= ...
    max(max(abs((est_d3Hdwdkdc(:,1:(Nc-1))-nz_wc_d3Hdwdkdc)./nz_wc_d3Hdwdkdc)));
  if verbose
    printf("max_abs_rel_diff_d3Hdwdkdc = del/%g\n",
           del/max_abs_rel_diff_d3Hdwdkdc);
  endif
  if max_abs_rel_diff_d3Hdwdkdc > del/1000
    error("max_abs_rel_diff_d3Hdwdkdc > del/1000");
  endif
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
