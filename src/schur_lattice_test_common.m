% schur_lattice_test_common.m
% Copyright (C) 2017-2025 Robert G. Jenssen

if x==1
  N=7;fc=0.15;
  [n,d]=butter(N,2*fc);
  [Da1,Db1]=tf2pa(n,d);
  Da1=Da1(:);
  Db1=Db1(:);
  difference=false;
  
  % Filter specification
  fap=0.15; % Pass band amplitude response edge
  Wap=1; % Pass band amplitude response weight
  
  fas=0.2; % Stop band amplitude response edge
  Was=100; % Stop band amplitude response weight
  
  ftp=0.175; % Pass band group delay response edge
  Wtp=100; % Pass band group delay response weight
  td=N-1; % Pass band nominal group delay
  
  Wpp=10000; % Pass band phase response weight
  
  fdp=0.1; % Pass band dAsqdw response edge
  Wdp=0.1; % Pass band dAsqdw response weight
  
  % Desired squared magnitude response
  nplot=100;
  nc=ceil(nplot*fc/0.5)+1;
  nap=ceil(nplot*fap/0.5)+1;
  nas=floor(nplot*fas/0.5)+1;
  wa=(0:(nplot-1))'*pi/nplot;
  Asqd=[ones(nap,1);zeros(nplot-nap,1)];
  Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(nplot-nas+1,1)];
  nac=nap;
  wac=wa(nac);
  % Desired pass-band group delay response
  ntp=ceil(nplot*ftp/0.5)+1;
  wt=wa(1:ntp);
  Td=td*ones(ntp,1);
  Wt=Wtp*ones(ntp,1);
  ntc=floor(length(wt)/2);
  wtc=wt(ntc);
  % Desired pass-band phase response
  npp=ntp;
  wp=wt;
  Pd=-td*wp;
  Wp=Wpp*ones(size(wp));
  npc=floor(length(wp)/2);
  wpc=wp(npc);
  % Desired pass-band dAsqdw response
  ndp=ntp;
  wd=wt;
  Dd=zeros(size(wd));
  Wd=Wdp*ones(size(wd));
  ndc=floor(length(wd)/2);
  wdc=wp(ndc);
else
  % Band pass filter from parallel_allpass_socp_slb_bandpass_test.m
  difference=true;
  Da1 = [    1.0000000000,  -2.7748751774,   3.8948184294,  -3.0472366268, ... 
             1.0098151580,   0.8213133847,  -1.4061768147,   1.0010377066, ... 
            -0.3569551472,   0.0424285887,   0.0143840492 ]';
  Db1 = [    1.0000000000,  -2.1560163920,   3.0450213935,  -2.3939485824, ... 
             0.8700418441,   0.5846030963,  -1.0784663405,   0.8191749090, ... 
            -0.3219188977,   0.0644815445,   0.0174883384 ]';
  d    = [   1.0000000000,  -4.9308915694,  12.9225161911, -22.2880318663, ... 
            26.9524630583, -21.7884148463,   7.8808826750,   7.5537331566, ... 
           -16.4615294706,  15.9660900106,  -9.3042788622,   2.1266407631, ... 
             1.9527301826,  -2.6902603110,   1.7656021275,  -0.7283195469, ... 
             0.1741110914,  -0.0073860454,  -0.0081371887,   0.0016695112, ... 
             0.0002515531 ]';
  n    = [  -0.0015521446,  -0.0022686229,   0.0140505451,  -0.0224561646, ... 
             0.0218984692,  -0.0135501274,   0.0025119382,   0.0131990462, ... 
            -0.0197924849,   0.0059611144,   0.0000000000,  -0.0059611144, ... 
             0.0197924849,  -0.0131990462,  -0.0025119382,   0.0135501274, ... 
            -0.0218984692,   0.0224561646,  -0.0140505451,   0.0022686229, ... 
             0.0015521446 ]';
  
  ma=length(Da1)-1;
  mb=length(Db1)-1;
  % Filter specification
  % Amplitude
  fasl=0.05;
  fapl=0.1;
  fapu=0.2;
  fasu=0.25;
  dBap=2;dBas=53;
  Wap=1;Watl=0.1;Watu=0.1;
  Wasl=100;
  Wasu=100;
  % Delay
  ftpl=0.09;
  ftpu=0.21;
  td=16;
  tdr=td/200;
  Wtp=100;
  % Phase
  fppl=0.09;
  fppu=0.21;
  Wpp=0.01;
  % dAsqdw
  fdpl=0.1;
  fdpu=0.2;
  Wdp=0.1;
  % Desired squared magnitude response
  nplot=100;
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
  nac=floor((napl+napu)/2);
  wac=wa(nac);
  % Desired pass-band group delay response
  ntpl=floor(nplot*ftpl/0.5)+1;
  ntpu=ceil(nplot*ftpu/0.5)+1;
  wt=wa(ntpl:ntpu);
  Td=td*ones(ntpu-ntpl+1,1);
  Wt=Wtp*ones(ntpu-ntpl+1,1);
  ntc=floor(length(wt)/2);
  wtc=wt(ntc);
  % Desired pass-band phase response
  nppl=floor(nplot*fppl/0.5)+1;
  nppu=ceil(nplot*fppu/0.5)+1;
  wp=wa(nppl:nppu);
  npc=floor(length(wp)/2);
  wpc=wp(npc);
  % pd was found with:
  %   pd=schurOneMPAlatticeP(wp(1),A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,true);
  pd=1.7226;
  Pd=(pd*ones(nppu-nppl+1,1))-((wp-wp(1))*td);
  Wp=Wpp*ones(nppu-nppl+1,1);
  % Desired pass-band dAsqdw response
  ndpl=floor(nplot*fdpl/0.5)+1;
  ndpu=ceil(nplot*fdpu/0.5)+1;
  wd=wa(ndpl:ndpu);
  Dd=zeros(ndpu-ndpl+1,1);
  Wd=Wdp*ones(ndpu-ndpl+1,1);
  ndc=floor(length(wd)/2);
  wdc=wd(ndc);
endif

