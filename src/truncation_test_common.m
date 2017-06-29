% truncation_test_common.m
% Copyright (C) 2017 Robert G. Jenssen

format short e

% Specify elliptic low pass filter
norder=5
dBpass=1
dBstop=40
fpass=0.125
fstop=0.15
[n0,d0]=ellip(norder,dBpass,dBstop,2*fpass);

% Specify desired response
Wap=1;
Wat=0.1;
Was=10;
npoints=500;
npass=ceil(npoints*fpass/0.5)+1;
nstop=floor(npoints*fstop/0.5)+1;
Ad=[ones(npass,1);zeros(npoints-npass,1)];
Wa=[Wap*ones(npass,1);Wat*ones(nstop-npass-1,1);Was*ones(npoints-nstop+1,1)];
Td=[];
Wt=[];

% Specify truncation
nbits=6
nshift=2^(nbits-1);
% Specify number of signed digits
ndigits=2
% Specify bitflipping mask
bitstart=4
msize=3

