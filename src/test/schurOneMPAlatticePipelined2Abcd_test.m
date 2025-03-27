% schurOneMPAlatticePipelined2Abcd_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticePipelined2Abcd_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

del=1/(2^22);
tol=3e-9;

for x=1:2,
 
  % Filter transfer function
  if x==1
    % From schurOneMPAlattice_socp_slb_lowpass_test.m
    DA1 = [   1.0000000000,   0.6627628587,  -0.3238953478,  -0.2858809104, ... 
             -0.1062724820,   0.1270555182,   0.1027876361,  -0.1475216004, ... 
              0.1441517265,   0.0357716970,  -0.1234690101,   0.0537213303 ]';
    DA2 = [   1.0000000000,   0.1719703893,  -0.2854675865,   0.2873464580, ... 
              0.0731533343,   0.0455771610,  -0.0620228628,  -0.1822775736, ... 
              0.2597845724,  -0.0905454979,  -0.1312517901,   0.1406241154, ... 
             -0.0547333984 ]';
    difference=false;
    mm=1;
  elseif x==2
    % From schurOneMPAlattice_socp_slb_bandpass_hilbert_test.m
    DA1 = [   1.0000000000,  -1.5103925028,   1.4580310207,   0.4406270490, ... 
             -1.8596136480,   2.2339944607,  -0.6763833611,  -0.6552202400, ... 
              1.2379879399,  -0.7272788683,   0.2606467418 ]';
    DA2 = [   1.0000000000,  -2.2569218547,   2.0696253577,   0.4184700880, ... 
             -2.8305352152,   3.0247858682,  -0.8766906371,  -1.1114198358, ... 
              1.6289290528,  -0.9155619257,   0.2641334239 ]';
    difference=true;
    mm=-1;
  endif

  % Convert filter transfer function to lattice form
  [A1k,A1epsilon,~,A1kk,~]=tf2schurOneMlatticePipelined(flipud(DA1),DA1);
  [A2k,A2epsilon,~,A2kk,~]=tf2schurOneMlatticePipelined(flipud(DA2),DA2);

  % Check [A,B,C,D]
  [A,B,C,D]=schurOneMPAlatticePipelined2Abcd(A1k,A1epsilon,A1kk, ...
                                             A2k,A2epsilon,A2kk,difference);
  [check_n,check_d]=Abcd2tf(A,B,C,D);
  check_n=mm*check_n(:);
  check_d=check_d(:);
  N12=(conv(flipud(DA2),DA1)+(mm*conv(flipud(DA1),DA2)))/2;
  D12=conv(DA1,DA2);
  if max(abs(check_n-N12)) > 100*eps
    error("max(abs(check_n-N12))(%g*eps) > 100*eps", max(abs(check_n-N12))/eps);
  endif
  if max(abs(check_d-D12)) > 100*eps
    error("max(abs(check_d-D12))(%g*eps) > 100*eps", max(abs(check_d-D12))/eps);
  endif

  % Check the differentials of A,B,C,D with respect to k and kk
  A1kkr=round(A1kk*1024)/1024;
  A2kkr=round(A2kk*1024)/1024;
  [~,~,~,~,dAdx,dBdx,dCdx,dDdx] = ...
    schurOneMPAlatticePipelined2Abcd(A1k,A1epsilon,A1kkr, ...
                                     A2k,A2epsilon,A2kkr,difference);

  Ax=[A1k(:);A1kkr(:);A2k(:);A2kkr(:)];

  A1Nk=length(A1k);
  A1Nkk=length(A1kk);
  A2Nk=length(A2k);
  A2Nkk=length(A2kk);
  Nx=A1Nk+A1Nkk+A2Nk+A2Nkk;
  RA1k=1:A1Nk;
  RA1kk=(A1Nk+1):(A1Nk+A1Nkk);
  RA2k=(A1Nk+A1Nkk+1):(A1Nk+A1Nkk+A2Nk);
  RA2kk=(A1Nk+A1Nkk+A2Nk+1):(A1Nk+A1Nkk+A2Nk+A2Nkk);

  dAdx_max_err=zeros(1,Nx);
  dBdx_max_err=zeros(1,Nx);
  dCdx_max_err=zeros(1,Nx);
  dDdx_max_err=zeros(1,Nx);

  delAx=zeros(size(Ax));
  delAx(1)=del/2;
  for l=1:Nx
    AxP=Ax+delAx;
    [AP,BP,CP,DP] = ...
        schurOneMPAlatticePipelined2Abcd(AxP(RA1k),A1epsilon,AxP(RA1kk), ...
                                         AxP(RA2k),A2epsilon,AxP(RA2kk), ...
                                         difference);
    
    AxM=Ax-delAx;
    [AM,BM,CM,DM] = ...
        schurOneMPAlatticePipelined2Abcd(AxM(RA1k),A1epsilon,AxM(RA1kk), ...
                                         AxM(RA2k),A2epsilon,AxM(RA2kk), ...
                                         difference);
    
    delAx=circshift(delAx,1);
    
    dAdx_max_err(l)=max(max(abs(((AP-AM)/del)-dAdx{l})));
    dBdx_max_err(l)=max(abs(((BP-BM)/del)-dBdx{l}));
    dCdx_max_err(l)=max(abs(((CP-CM)/del)-dCdx{l}));
    dDdx_max_err(l)=max(abs(((DP-DM)/del)-dDdx{l}));
  endfor

  if max(dAdx_max_err) > eps
    error("max(dAdx_max_err) > eps");
  endif
  if max(dBdx_max_err) > eps
    error("max(dBdx_max_err) > eps");
  endif
  if max(dCdx_max_err) > eps
    error("max(dCdx_max_err) > eps");
  endif
  if max(dDdx_max_err) > eps
    error("max(dDdx_max_err) > eps");
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
