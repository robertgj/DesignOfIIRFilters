% bitflip_bandpass_test_common.m
% Copyright (C) 2017,2018 Robert G. Jenssen

format long e

% PCLS IIR band pass filter from iir_sqp_slb_bandpass_test.m
n0 = [   0.0119656597,   0.0054227177,   0.0227005335,   0.0226922170, ... 
         0.0478437399,   0.0344596061,   0.0300157817,   0.0005327649, ... 
        -0.0020161873,  -0.0307157202,  -0.0676394572,  -0.1024149854, ... 
        -0.0701854751,   0.0360117096,   0.1357490011,   0.1563338602, ... 
         0.0634407938,  -0.0393847506,  -0.0985413186,  -0.0711217507, ... 
        -0.0333908343 ]';
d0 = [   1.0000000000,   0.0000000000,   1.7101927107,   0.0000000000, ... 
         1.9390379556,   0.0000000000,   1.9462051796,   0.0000000000, ... 
         1.7230562169,   0.0000000000,   1.2665042758,   0.0000000000, ... 
         0.8113877164,   0.0000000000,   0.4380806647,   0.0000000000, ... 
         0.1988495226,   0.0000000000,   0.0656499208,   0.0000000000, ... 
         0.0148050095 ]';

% Specify desired response
npoints=250;
fapl=0.1;fapu=0.2;fasl=0.05;fasu=0.25;
Wasl=30;Watl=0;Wap=1;Watu=0;Wasu=30;
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
ntl=floor(ftl*npoints/0.5)-1;
ntu=ceil(fth*npoints/0.5)+1;
Td=td*ones(npoints,1);
Wtp=1;
Wt=[zeros(ntl,1);Wtp*ones(ntu-ntl,1);zeros(npoints-ntu,1)];

% Specify quantisation
nbits=8
nscale=2^(nbits-1)
bitstart=6
msize=3
ndigits=2
