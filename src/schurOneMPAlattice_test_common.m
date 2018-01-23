% schurOneMPAlatticeEsq_test_common.m
% Copyright (C) 2017 Robert G. Jenssen

if m==1
  % Low pass filter from parallel_allpass_socp_slb_flat_delay_test.m
  difference=false;
  Da1=[   1.0000000000,  0.3931432341, -0.2660133321, -0.0850275861, ... 
         -0.2707651069, -0.0298153197,  0.1338823243, -0.0589362474, ... 
          0.1650490792,  0.0296371262, -0.1113859180,  0.0372881323 ]';
  Db1=[   1.0000000000, -0.1344939785, -0.0918734630,  0.4461033862, ... 
         -0.1115261080,  0.1180340147,  0.0396352218, -0.2006006436, ... 
          0.2105512466, -0.0838522576, -0.1001537312,  0.1080994566, ... 
         -0.0610732672 ]';
  Dab1=[  1.0000000000,  0.2586492556, -0.4107621927,  0.3607335610, ... 
         -0.1710334226, -0.0300684328,  0.2405442669, -0.4019267583, ... 
          0.2886788963,  0.0928616471, -0.3580821837,  0.2718123207, ... 
         -0.0374493775, -0.0939561603,  0.1157815704, -0.0939661732, ... 
          0.0336391381,  0.0384186168, -0.0644954956,  0.0356638996, ... 
          0.0011526919, -0.0175853389,  0.0108335288, -0.0022773081 ]';
  Nab1=[ -0.0118925675, -0.0161560163, -0.0001083932,  0.0205704164, ... 
          0.0369335724,  0.0211196767, -0.0280717678, -0.0596562038, ... 
         -0.0358505121,  0.0676811446,  0.2182340832,  0.3207798419, ... 
          0.3207798419,  0.2182340832,  0.0676811446, -0.0358505121, ... 
         -0.0596562038, -0.0280717678,  0.0211196767,  0.0369335724, ... 
          0.0205704164, -0.0001083932, -0.0161560163, -0.0118925675 ]';
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
  Da1=[   1.0000000000, -0.7184909638,  0.9046312454,  0.2169596468, ... 
         -0.2798425957,  0.3771956551,  0.0063820636, -0.0452498367, ... 
          0.0608299208,  0.0689948384,  0.0082607368,  0.0097260773, ... 
          0.0328541478 ]';
  Db1=[   1.0000000000, -1.3444712615,  0.8666938350,  0.1940433524, ... 
         -0.4496635068,  0.4324017246, -0.0071973685, -0.1042230681, ... 
          0.0588756264,  0.0868578706, -0.0155491317, -0.0251825310, ... 
          0.0258643337 ]';
  Nab1=[  0.0034949070,  0.0046602204, -0.0011415905, -0.0040836091, ... 
         -0.0036797116, -0.0006400210, -0.0006131756, -0.0071530574, ... 
         -0.0081577407,  0.0052305276,  0.0216792451,  0.0209639932, ... 
          0.0000000000, -0.0209639932, -0.0216792451, -0.0052305276, ... 
          0.0081577407,  0.0071530574,  0.0006131756,  0.0006400210, ... 
          0.0036797116,  0.0040836091,  0.0011415905, -0.0046602204, ... 
         -0.0034949070 ]';
  Dab1=[  1.0000000000, -2.0629622252,  2.7373155327, -1.4279594012, ... 
         -0.3765821845,  1.8724921416, -1.4258386885,  0.4133346669, ... 
          0.5472873534, -0.3926728588,  0.0743768520,  0.1971162087, ... 
         -0.0136920205, -0.0860365921,  0.1161825249,  0.0034209781, ... 
         -0.0350028719,  0.0329196939,  0.0055876766, -0.0059090393, ... 
          0.0024865083,  0.0042788885, -0.0005421223, -0.0005757921, ... 
          0.0008497506 ]';

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

