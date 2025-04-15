% bitflip_bandpass_test_common.m
% Copyright (C) 2017-2025 Robert G. Jenssen

% Specify desired response
npoints=250;
fapl=0.1;fapu=0.2;fasl=0.05;fasu=0.25;
if exist("Wasl","var")~=1
  Wasl=30
endif
if exist("Watl","var")~=1
  Watl=0
endif
if exist("Wap","var")~=1
  Wap=1
endif
if exist("Watu","var")~=1
  Watl=0
endif
if exist("Wasu","var")~=1
  Wasu=30
endif
Watl=0;Wap=1;Watu=0;
nasl=ceil(npoints*fasl/0.5)+1;
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
nasu=floor(npoints*fasu/0.5)+1;
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(npoints-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(npoints-nasu+1,1)];
% Sanity check
nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];
w=(0:(npoints-1))'*pi/npoints;
printf("nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];\n");
printf("nchk=[ ");printf("%d ",nchk);printf("];\n");
printf("f(nchk)*0.5/pi=[");printf("%6.4g ",w(nchk)'/(2*pi));printf("];\n");
printf("Ad(nchk)=[ ");printf("%6.4g ",Ad(nchk)');printf("];\n");
printf("Wa(nchk)=[ ");printf("%6.4g ",Wa(nchk)');printf("];\n");
% Desired delay 
td=16;
ftl=0.09;
fth=0.21;
ntl=floor(ftl*npoints/0.5)+1;
ntu=ceil(fth*npoints/0.5)+1;
Td=td*ones(npoints,1);
if exist("Wtp","var")~=1
  Wtp=1
endif
Wt=[zeros(ntl-1,1);Wtp*ones(ntu-ntl+1,1);zeros(npoints-ntu,1)];
% Sanity check
nchk=[ntl-1,ntl,ntl+1,ntu-1,ntu,ntu+1];
w=(0:(npoints-1))'*pi/npoints;
printf("nchk=[ntl,ntl+1,ntu-1,ntu];\n");
printf("nchk=[ ");printf("%d ",nchk);printf("];\n");
printf("f(nchk)*0.5/pi=[");printf("%6.4g ",w(nchk)'/(2*pi));printf("];\n");
printf("Td(nchk)=[ ");printf("%6.4g ",Td(nchk)');printf("];\n");
printf("Wt(nchk)=[ ");printf("%6.4g ",Wt(nchk)');printf("];\n");

% Specify quantisation
if exist("nbits","var")~=1
  nbits=8
endif
nscale=2^(nbits-1)
if exist("bitstart","var")~=1
  bitstart=6
endif
if exist("msize","var")~=1
  msize=3
endif
if exist("ndigits","var")~=1
  ndigits=2
endif
