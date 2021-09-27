% schurOneMPAlattice_test_common.m
% Copyright (C) 2017-2021 Robert G. Jenssen

if m==1
  % Low pass filter from parallel_allpass_socp_slb_flat_delay_test.m
  difference=false;
  Da1 = [    1.0000000000,  -0.0298444346,  -0.1187350349,   0.2309546357, ... 
            -0.4791616501,  -0.0572208481,   0.2510695333,  -0.1036879906, ... 
             0.0969679979,   0.0550589813,  -0.0821832560,   0.0197102066 ]';
  Db1 = [    1.0000000000,  -0.5570802972,   0.2780775229,   0.5236701564, ... 
            -0.5316868255,   0.3057680376,   0.1643070958,  -0.3314854023, ... 
             0.1942299376,  -0.0191318904,  -0.1010554662,   0.0795055088, ... 
            -0.0429839250 ]';
  Nab1 = [  -0.0116368592,  -0.0061875420,   0.0039990270,   0.0091403409, ... 
             0.0249226472,   0.0101829199,  -0.0232526210,  -0.0310375638, ... 
            -0.0141436686,   0.0527307723,   0.1515917913,   0.2103318249, ... 
             0.2103318249,   0.1515917913,   0.0527307723,  -0.0141436686, ... 
            -0.0310375638,  -0.0232526210,   0.0101829199,   0.0249226472, ... 
             0.0091403409,   0.0039990270,  -0.0061875420,  -0.0116368592 ]';
  Dab1 = [   1.0000000000,  -0.5869247318,   0.1759682345,   0.8124706742, ... 
            -1.1881549368,   0.5333918954,   0.4889575812,  -1.0058783392, ... 
             0.7045788836,   0.0399734392,  -0.5700100184,   0.5425660513, ... 
            -0.1588854712,  -0.1708861519,   0.2429039939,  -0.1258891594, ... 
            -0.0142350270,   0.0722192237,  -0.0523843435,   0.0120030290, ... 
             0.0081374009,  -0.0108924968,   0.0050996289,  -0.0008472220 ]';
  ma=11; % Allpass model filter A denominator order
  mb=12; % Allpass model filter B denominator order
  fap=0.15; % Pass band amplitude response edge
  Wap=0.1; % Pass band amplitude response weight
  fas=0.2; % Stop band amplitude response edge
  Was=750; % Stop band amplitude response weight
  ftp=0.175; % Pass band group delay response edge
  td=(ma+mb)/2; % Pass band nominal group delay
  Wtp=1000; % Pass band group delay response weight
  Wpp=10000; % Pass band phase response weight
  % Desired squared magnitude response
  nplot=1000;
  nap=ceil(nplot*fap/0.5)+1;
  nas=floor(nplot*fas/0.5)+1;
  wa=(0:(nplot-1))'*pi/nplot;
  Asqd=[ones(nap,1);zeros(nplot-nap,1)];
  Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(nplot-nas+1,1)];
  % Desired pass-band group delay response
  ntp=ceil(nplot*ftp/0.5)+1;
  wt=wa(1:ntp);
  Td=td*ones(ntp,1);
  Wt=Wtp*ones(ntp,1);
  % Desired pass-band phase response
  npp=ntp;
  wp=wt;
  Pd=-td*wp;
  Wp=Wpp*ones(npp,1);
  % For error calculation
  Asqrng=1:floor((nap+nas)/2);
  Trng=1:ntp;
  Prng=1:npp;
else
  % Band pass filter from parallel_allpass_socp_slb_bandpass_test.m
  difference=true;
  Da1 = [    1.0000000000,  -2.7748751774,   3.8948184294,  -3.0472366268, ... 
             1.0098151580,   0.8213133847,  -1.4061768147,   1.0010377066, ... 
            -0.3569551472,   0.0424285887,   0.0143840492 ]';
  Db1 = [    1.0000000000,  -2.1560163920,   3.0450213935,  -2.3939485824, ... 
             0.8700418441,   0.5846030963,  -1.0784663405,   0.8191749090, ... 
            -0.3219188977,   0.0644815445,   0.0174883384 ]';
  Dab1 = [   1.0000000000,  -4.9308915694,  12.9225161911, -22.2880318663, ... 
            26.9524630583, -21.7884148463,   7.8808826750,   7.5537331566, ... 
           -16.4615294706,  15.9660900106,  -9.3042788622,   2.1266407631, ... 
             1.9527301826,  -2.6902603110,   1.7656021275,  -0.7283195469, ... 
             0.1741110914,  -0.0073860454,  -0.0081371887,   0.0016695112, ... 
             0.0002515531 ]';
  Nab1 = [  -0.0015521446,  -0.0022686229,   0.0140505451,  -0.0224561646, ... 
             0.0218984692,  -0.0135501274,   0.0025119382,   0.0131990462, ... 
            -0.0197924849,   0.0059611144,   0.0000000000,  -0.0059611144, ... 
             0.0197924849,  -0.0131990462,  -0.0025119382,   0.0135501274, ... 
            -0.0218984692,   0.0224561646,  -0.0140505451,   0.0022686229, ... 
             0.0015521446 ]';
  
  ma=length(Da1)-1;
  mb=length(Db1)-1;
  fasl=0.05;
  fapl=0.1;
  fapu=0.2;
  fasu=0.25;
  dBap=2;dBas=53;
  Wap=0.1;Watl=0.1;Watu=0.1;
  Wasl=1e4;
  Wasu=1e4;
  ftpl=0.09;
  ftpu=0.21;
  td=16;
  tdr=td/200;
  Wtp=10;
  fppl=0.09;
  fppu=0.21;
  Wpp=100;
  % Desired squared magnitude response
  nplot=1000;
  wa=(0:(nplot-1))'*pi/nplot;
  nasl=ceil(nplot*fasl/0.5)+1;
  napl=floor(nplot*fapl/0.5)+1;
  napu=ceil(nplot*fapu/0.5)+1;
  nasu=floor(nplot*fasu/0.5)+1;
  Asqd=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(nplot-napu,1)];
  Wa=[Wasl*ones(nasl,1); ...
      Watl*ones(napl-nasl-1,1); ...
      Wap*ones(napu-napl+1,1); ...
      Watu*ones(nasu-napu-1,1); ...
      Wasu*ones(nplot-nasu+1,1)];
  % Desired pass-band group delay response
  ntpl=floor(nplot*ftpl/0.5)+1;
  ntpu=ceil(nplot*ftpu/0.5)+1;
  wt=wa(ntpl:ntpu);
  Td=td*ones(ntpu-ntpl+1,1);
  Wt=Wtp*ones(ntpu-ntpl+1,1);
  % Desired pass-band phase response
  nppl=floor(nplot*fppl/0.5)+1;
  nppu=ceil(nplot*fppu/0.5)+1;
  wp=wa(nppl:nppu);
  % pd was found with:
  %   pd=schurOneMPAlatticeP(wp(1),A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,true);
  pd=1.7226;
  Pd=(pd*ones(nppu-nppl+1,1))-((wp-wp(1))*td);
  Wp=Wpp*ones(nppu-nppl+1,1);
  % For error calculation
  Asqrng=napl:floor((napu+nasu)/2);
  Trng=ntpl:ntpu;
  Prng=nppl:nppu;
endif

% Lattice decomposition
[A1k,A1epsilon,A1p,~] = tf2schurOneMlattice(flipud(Da1),Da1);
[A2k,A2epsilon,A2p,~] = tf2schurOneMlattice(flipud(Db1),Db1);

A1rng=1:length(A1k);
A2rng=(length(A1k)+1):(length(A1k)+length(A2k));

