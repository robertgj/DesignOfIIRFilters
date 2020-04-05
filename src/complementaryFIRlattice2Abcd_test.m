% complementaryFIRlattice2Abcd_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("complementaryFIRlattice2Abcd_test.diary");
delete("complementaryFIRlattice2Abcd_test.diary.tmp");
diary complementaryFIRlattice2Abcd_test.diary.tmp

verbose=false;

for x=1:2
  
  if x==1
    % Lowpass linear-phase filter specification
    fap=0.1;fas=0.25;
    M=15;N=(2*M)+1;
    b1=remez(2*M,2*[0 fap fas 0.5],[1 1 0 0]);
  else
    % Bandpass minimum-phase filter specification
    Ud1=2;Vd1=0;Md1=14;Qd1=0;Rd1=1;
    d1 = [   0.0920209477, ...
             0.9990000000,   0.5128855702, ...
             0.7102414018,   0.9990000000,   0.9990000000,   0.9990000000, ... 
             0.9990000000,   0.9990000000,   0.9990000000, ...
            -0.9667931503,   0.2680255295,   2.2176753593,   3.3280228348, ... 
             3.7000375301,   4.4072989555,   4.6685041037 ]';
    [b1,~]=x2tf(d1,Ud1,Vd1,Md1,Qd1,Rd1);
  endif

  % Find lattice coefficients (b1 is scaled to |H|<=1 and returned as b)
  [b,bc,k,khat]=complementaryFIRlattice(b1(:));

  %
  % Check state variable description
  %
  
  % Find state variable description
  [A,B,Ch,Dh,Cg,Dg]=complementaryFIRlattice2Abcd(k,khat);
  Nk=length(k);
  
  % Convert back to polynomial
  [bh,~]=Abcd2tf(A,B,Ch,Dh);
  bh=bh(:);
  [bg,~]=Abcd2tf(A,B,Cg,Dg);
  bg=bg(:);
  
  % Sanity check (should be 0)
  tol=10*eps;
  if max(abs(b-bh)) > tol
    error("max(abs(b-bh)) > (%f*eps)",tol/eps);
  endif
  if max(abs(bc-bg)) > tol
    error("max(abs(bc-bg)) > (%f*eps)",tol/eps);
  endif
  if abs(1 - (bh(:)'*bh(:) + bg(:)'*bg(:))) > tol
    error("Expected abs(1 - (bh(:)'*bh(:) + bg(:)'*bg(:))) <= tol !");
  endif

  %
  % Check state variable diffentials
  %
  del=1e-7;
  if verbose
    printf("1-max(abs([k(:);khat(:)])+del)=%g\n",1-max(abs([k(:);khat(:)])+del));
  endif
  if max(abs([k(:);khat(:)])+del)>1
    error("1-max(abs([k(:);khat(:)])+del)=%g\n",1-max(abs([k(:);khat(:)])+del));
  endif
  del_tol=del/25;
  [A,B,Ch,Dh,Cg,Dg,dAdkkhat,dBdkkhat,dChdkkhat,dDhdkkhat, ...
   dCgdkkhat,dDgdkkhat]=complementaryFIRlattice2Abcd(k,khat);

  % Differentials with respect to k coefficients
  delk=zeros(size(k));
  delk(1)=del;
  dAdk_max_err=zeros(1,Nk);
  dBdk_max_err=zeros(1,Nk);
  dChdk_max_err=zeros(1,Nk);
  dDhdk_max_err=zeros(1,Nk);
  dCgdk_max_err=zeros(1,Nk);
  dDgdk_max_err=zeros(1,Nk);
  for l=1:Nk
    [APk,BPk,ChPk,DhPk,CgPk,DgPk] = ...
      complementaryFIRlattice2Abcd(k+(delk/2),khat);
    [AMk,BMk,ChMk,DhMk,CgMk,DgMk] = ...
      complementaryFIRlattice2Abcd(k-(delk/2),khat);
    dAdk_max_err(l)=max(max(abs(((APk-AMk)/del)-dAdkkhat{l})));
    dBdk_max_err(l)=max(abs(((BPk-BMk)/del)-dBdkkhat{l}));
    dChdk_max_err(l)=max(abs(((ChPk-ChMk)/del)-dChdkkhat{l})); 
    dDhdk_max_err(l)=max(abs(((DhPk-DhMk)/del)-dDhdkkhat{l}));
    dCgdk_max_err(l)=max(abs(((CgPk-CgMk)/del)-dCgdkkhat{l}));
    dDgdk_max_err(l)=max(abs(((DgPk-DgMk)/del)-dDgdkkhat{l}));
    delk=shift(delk,1);
  endfor
  if verbose
    printf("max(dAdk_max_err)=%f*del_tol\n",max(dAdk_max_err)/del_tol);
  endif
  if max(dAdk_max_err) > del_tol
    error("max(dAdk_max_err) > %f",del_tol);
  endif
  if verbose
    printf("max(dBdk_max_err)=%f*del_tol\n",max(dBdk_max_err)/del_tol);
  endif
  if max(dBdk_max_err) > del_tol
    error("max(dBdk_max_err) > %f",del_tol);
  endif
  if verbose
    printf("max(dChdk_max_err)=%f*del_tol\n",max(dChdk_max_err)/del_tol);
  endif
  if max(dChdk_max_err) > del_tol
    error("max(dChdk_max_err) > %f",del_tol);
  endif
  if verbose
    printf("max(dDhdk_max_err)=%f*del_tol\n",max(dDhdk_max_err)/del_tol);
  endif
  if max(dDhdk_max_err) > del_tol
    error("max(dDhdk_max_err) > %f",del_tol);
  endif
  if verbose
    printf("max(dCgdk_max_err)=%f*del_tol\n",max(dCgdk_max_err)/del_tol);
  endif
  if max(dCgdk_max_err) > del_tol
    error("max(dCgdk_max_err) > %f",del_tol);
  endif
  if verbose
    printf("max(dDgdk_max_err)=%f*del_tol\n",max(dDgdk_max_err)/del_tol);
  endif
  if max(dDgdk_max_err) > del_tol
    error("max(dDgdk_max_err) > %f",del_tol);
  endif

  % Differentials with respect to khat coefficients
  delkhat=zeros(size(khat));
  delkhat(1)=del;
  dAdkhat_max_err=zeros(1,Nk);
  dBdkhat_max_err=zeros(1,Nk);
  dChdkhat_max_err=zeros(1,Nk);
  dDhdkhat_max_err=zeros(1,Nk);
  dCgdkhat_max_err=zeros(1,Nk);
  dDgdkhat_max_err=zeros(1,Nk);
  for l=1:Nk
    [APkhat,BPkhat,ChPkhat,DhPkhat,CgPkhat,DgPkhat] = ...
      complementaryFIRlattice2Abcd(k,khat+(delkhat/2)); 
    [AMkhat,BMkhat,ChMkhat,DhMkhat,CgMkhat,DgMkhat] = ...
      complementaryFIRlattice2Abcd(k,khat-(delkhat/2));
    dAdkhat_max_err(l)=max(max(abs(((APkhat-AMkhat)/del)-dAdkkhat{Nk+l})));
    dBdkhat_max_err(l)=max(abs(((BPkhat-BMkhat)/del)-dBdkkhat{Nk+l}));
    dChdkhat_max_err(l)=max(abs(((ChPkhat-ChMkhat)/del)-dChdkkhat{Nk+l})); 
    dDhdkhat_max_err(l)=max(abs(((DhPkhat-DhMkhat)/del)-dDhdkkhat{Nk+l}));
    dCgdkhat_max_err(l)=max(abs(((CgPkhat-CgMkhat)/del)-dCgdkkhat{Nk+l}));
    dDgdkhat_max_err(l)=max(abs(((DgPkhat-DgMkhat)/del)-dDgdkkhat{Nk+l}));
    delkhat=shift(delkhat,1);
  endfor
  if verbose
    printf("max(dAdkhat_max_err)=%f*del_tol\n",max(dAdkhat_max_err)/del_tol);
  endif
  if max(dAdkhat_max_err) > del_tol
    error("max(dAdkhat_max_err) > %f",del_tol);
  endif
  if verbose
    printf("max(dBdkhat_max_err)=%f*del_tol\n",max(dBdkhat_max_err)/del_tol);
  endif
  if max(dBdkhat_max_err) > del_tol
    error("max(dBdkhat_max_err) > %f",del_tol);
  endif
  if verbose
    printf("max(dChdkhat_max_err)=%f*del_tol\n",max(dChdkhat_max_err)/del_tol);
  endif
  if max(dChdkhat_max_err) > del_tol
    error("max(dChdkhat_max_err) > %f",del_tol);
  endif
  if verbose
    printf("max(dDhdkhat_max_err)=%g*del_tol\n",max(dDhdkhat_max_err)/del_tol);
  endif
  if max(dDhdkhat_max_err) > del_tol/1000000
    error("max(dDhdkhat_max_err) > %g",del_tol/1000000);
  endif
  if verbose
    printf("max(dCgdkhat_max_err)=%f*del_tol\n",max(dCgdkhat_max_err)/del_tol);
  endif
  if max(dCgdkhat_max_err) > del_tol
    error("max(dCgdkhat_max_err) > %f",del_tol);
  endif
  if verbose
    printf("max(dDgdkhat_max_err)=%f*del_tol\n",max(dDgdkhat_max_err)/del_tol);
  endif
  if max(dDgdkhat_max_err) > del_tol
    error("max(dDgdkhat_max_err) > %f",del_tol);
  endif

endfor

% Done
diary off
movefile complementaryFIRlattice2Abcd_test.diary.tmp ...
         complementaryFIRlattice2Abcd_test.diary;

