% schurOneMPAlatticePipelined2Abcd_test.m
% Copyright (C) 2024 Robert G. Jenssen

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
    n = [   -0.0005060340,  -0.0049408401,  -0.0105602357,  -0.0032240696, ... 
             0.0217046037,   0.0374058975,   0.0035128628,  -0.0706983273, ... 
            -0.0932747378,   0.0308642808,   0.2765107083,   0.4808733923, ... 
             0.4808733923,   0.2765107083,   0.0308642808,  -0.0932747378, ... 
            -0.0706983273,   0.0035128628,   0.0374058975,   0.0217046037, ... 
            -0.0032240696,  -0.0105602357,  -0.0049408401,  -0.0005060340 ]';
    d = [    1.0000000000,   0.8347332480,  -0.4953873475,  -0.2434321751, ... 
             0.2006219840,   0.1913798246,   0.0173178669,  -0.4557118197, ... 
             0.2642116508,   0.2950608392,  -0.4042516994,   0.0777770787, ... 
             0.1083069222,  -0.0528842257,   0.0326569466,  -0.0937960603, ... 
             0.0645844631,   0.0422770403,  -0.0903976872,   0.0487860041, ... 
             0.0084817534,  -0.0263716476,   0.0143123931,  -0.0029403510 ]';
    A1k = [  0.7708884723,  -0.0881113352,  -0.2676988107,  -0.0638149974, ... 
            -0.0591391496,   0.2444844859,  -0.1442540300,  -0.0042931090, ... 
             0.1646157559,  -0.1595339245,   0.0537213303 ];
    A1epsilon = [  1,  1,  1,  1,  1, -1,  1,  1,  1,  1, -1 ];
    A2k = [  0.3876343601,  -0.2734688172,   0.1867648662,   0.1638998031, ... 
            -0.0461823074,   0.0417459541,  -0.2010119927,   0.1801872215, ... 
             0.0055480902,  -0.1784785436,   0.1504874613,  -0.0547333984 ];
    A2epsilon = [  1,  1,  1, -1,  1, -1, -1, -1, -1, -1, -1,  1 ];
    difference=false;
    mm=1;
  elseif x==2
    % From schurOneMPAlattice_socp_slb_bandpass_hilbert_test.m
    n = [    0.0018353612,   0.0001364758,  -0.0103072346,   0.0273401922, ... 
            -0.0210162524,  -0.0134279626,   0.0426466978,  -0.0286391021, ... 
            -0.0042626036,   0.0058324432,   0.0000000000,  -0.0058324432, ... 
             0.0042626036,   0.0286391021,  -0.0426466978,   0.0134279626, ... 
             0.0210162524,  -0.0273401922,   0.0103072346,  -0.0001364758, ... 
            -0.0018353612 ]';
    d = [    1.0000000000,  -3.7535560438,   6.8808271815,  -5.4624931675, ... 
            -3.3392851827,  15.1062432494, -18.6267644328,   7.8282891854, ... 
            10.7834342861, -22.0184887957,  17.5100642579,  -2.5018628210, ... 
            -9.9433859064,  12.2928518151,  -6.6714826979,   0.1684776915, ... 
             2.9048322774,  -2.6648523879,   1.3550419515,  -0.4109914473, ... 
             0.0657619057 ]';
    A1k = [ -0.4593688607,   0.8388619392,  -0.2696667474,   0.1101905355, ... 
             0.6684276622,  -0.3628031412,   0.1872036968,   0.4684976847, ... 
            -0.3496919062,   0.2546120491 ];
    A1epsilon = [  1,  1,  1, -1, -1, -1, -1,  1,  1, -1 ];
    A2k = [ -0.8147753076,   0.8838439780,  -0.3376370032,   0.0806482436, ... 
             0.6846577803,  -0.3332188908,   0.1955071392,   0.4701112123, ... 
            -0.3353417567,   0.2582827716 ];
    A2epsilon = [  1,  1,  1, -1, -1, -1, -1,  1,  1, -1 ];
    difference=true;
    mm=-1;
  endif

  % Convert filter transfer function to lattice form
  A1Nk=length(A1k);
  A1kk=A1k(1:(A1Nk-1)).*A1k(2:A1Nk);
  A1Nkk=length(A1kk);
  A2Nk=length(A2k);
  A2kk=A2k(1:(A2Nk-1)).*A2k(2:A2Nk);
  A2Nkk=length(A2kk);

  % Check [A,B,C,D]
  [A,B,C,D]=schurOneMPAlatticePipelined2Abcd(A1k,A1epsilon,A1kk, ...
                                             A2k,A2epsilon,A2kk,difference);
  [check_n,check_d]=Abcd2tf(A,B,C,D);
  if max(abs((mm*check_n(:))-n)) > tol
    error("max(abs((mm*check_n)-n)) > tol");
  endif
  if max(abs(check_d(:)-d)) > tol
    error("max(abs(check_d-d)) > tol");
  endif

  % Check the differentials of A,B,C,D with respect to k and kk
  A1kkr=round(A1kk*1024)/1024;
  A2kkr=round(A2kk*1024)/1024;
  [~,~,~,~,dAdx,dBdx,dCdx,dDdx] = ...
    schurOneMPAlatticePipelined2Abcd(A1k,A1epsilon,A1kkr, ...
                                     A2k,A2epsilon,A2kkr,difference);

  Ax=[A1k(:);A1kkr(:);A2k(:);A2kkr(:)];
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
