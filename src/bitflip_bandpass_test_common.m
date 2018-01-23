% bitflip_bandpass_test_common.m
% Copyright (C) 2017,2018 Robert G. Jenssen

format long e

% PCLS IIR band pass filter from iir_sqp_slb_bandpass_test.m
n0 = [   0.0119791719,   0.0055196153,   0.0227331458,   0.0227914190, ... 
         0.0478041828,   0.0346917424,   0.0301303014,   0.0008781758, ... 
        -0.0019950672,  -0.0304170074,  -0.0676696158,  -0.1022691500, ... 
        -0.0706575011,   0.0358390487,   0.1355863349,   0.1570889466, ... 
         0.0640606014,  -0.0387898868,  -0.0987542367,  -0.0713801047, ... 
        -0.0337535000 ]';
d0 = [   1.0000000000,   0.0000000000,   1.7123000538,   0.0000000000, ... 
         1.9402922218,   0.0000000000,   1.9473017989,   0.0000000000, ... 
         1.7233349664,   0.0000000000,   1.2666849197,   0.0000000000, ... 
         0.8111419473,   0.0000000000,   0.4378142096,   0.0000000000, ... 
         0.1985844837,   0.0000000000,   0.0655700341,   0.0000000000, ... 
         0.0147544552 ]';

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
