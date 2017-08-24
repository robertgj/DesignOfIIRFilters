% bitflip_bandpass_test_common.m
% Copyright (C) 2017 Robert G. Jenssen

format long e

% PCLS IIR band pass filter from iir_sqp_slb_bandpass_test.m
n0 = [  0.0119898572,   0.0055005262,   0.0227465629,   0.0227676952, ... 
        0.0477699159,   0.0346032386,   0.0300158271,   0.0007692638, ... 
       -0.0021264872,  -0.0305118086,  -0.0677680871,  -0.1021835628, ... 
       -0.0704487200,   0.0361830861,   0.1357812748,   0.1570834904, ... 
        0.0638315615,  -0.0390403107,  -0.0989222753,  -0.0714382761, ... 
       -0.0337487587 ]';
d0 = [  1.0000000000,   0.0000000000,   1.7122688809,   0.0000000000, ... 
        1.9398016652,   0.0000000000,   1.9464309420,   0.0000000000, ... 
        1.7222723403,   0.0000000000,   1.2656797602,   0.0000000000, ... 
        0.8103366569,   0.0000000000,   0.4372977468,   0.0000000000, ... 
        0.1983164681,   0.0000000000,   0.0654678098,   0.0000000000, ... 
        0.0147305592 ]';

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
nbits=6
bitstart=4
msize=3
ndigits=3
fmt_str="%8.5f";

