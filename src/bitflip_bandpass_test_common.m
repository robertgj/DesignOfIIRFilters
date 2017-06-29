% bitflip_bandpass_test_common.m
% Copyright (C) 2017 Robert G. Jenssen

format long e

% PCLS IIR band pass filter from iir_sqp_slb_bandpass_test.m
n0 = [   0.0121797025,   0.0037181466,   0.0271208444,   0.0229180899, ... 
         0.0527427390,   0.0310257396,   0.0310148929,  -0.0050816528, ... 
        -0.0052190028,  -0.0414041061,  -0.0726994834,  -0.0996450244, ... 
        -0.0564833866,   0.0506036935,   0.1386006506,   0.1492761564, ... 
         0.0507378434,  -0.0443572576,  -0.1001730674,  -0.0681538294, ... 
        -0.0335038915 ]';
d0 = [   1.0000000000,   0.0000000000,   1.8567605231,   0.0000000000, ... 
         2.1933886439,   0.0000000000,   2.2557980857,   0.0000000000, ... 
         2.0335494061,   0.0000000000,   1.5306996820,   0.0000000000, ... 
         0.9936532921,   0.0000000000,   0.5470027574,   0.0000000000, ... 
         0.2511015052,   0.0000000000,   0.0839735161,   0.0000000000, ... 
         0.0183734564 ]';

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

