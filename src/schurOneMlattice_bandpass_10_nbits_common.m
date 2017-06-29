% schurOneMlattice_bandpass_10_nbits_common.m
% Copyright (C) 2017 Robert G. Jenssen

% Coefficients found by schurOneMlattice_sqp_slb_bandpass_test.m
n0 = [   0.0023859122,  -0.0015081026,   0.0061648873,   0.0144832636, ... 
         0.0316730381,   0.0279667393,   0.0204984234,   0.0077691540, ... 
         0.0059396642,  -0.0163870947,  -0.0619300123,  -0.0990072266, ... 
        -0.0731114507,   0.0258103302,   0.1174122287,   0.1339936130, ... 
         0.0537010475,  -0.0342726086,  -0.0790579382,  -0.0555016217, ... 
        -0.0236135458 ];
d0 = [   1.0000000000,  -0.0000000000,   1.5910285875,  -0.0000000000, ... 
         1.8662201415,  -0.0000000000,   1.8395381742,  -0.0000000000, ... 
         1.6256733015,  -0.0000000000,   1.1646841245,  -0.0000000000, ... 
         0.7469684663,  -0.0000000000,   0.3950965740,  -0.0000000000, ... 
         0.1788931112,  -0.0000000000,   0.0545947937,  -0.0000000000, ... 
         0.0134002323 ];
k0 = [   0.0000000000,   0.6578120679,   0.0000000000,   0.5164877092, ... 
         0.0000000000,   0.3527537927,   0.0000000000,   0.4280317934, ... 
         0.0000000000,   0.2989556994,   0.0000000000,   0.2525473176, ... 
         0.0000000000,   0.1498954992,   0.0000000000,   0.1010893608, ... 
         0.0000000000,   0.0332806170,   0.0000000000,   0.0134002323 ];
epsilon0 = [  0,  1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0, -1,  0,  1, ... 
              0, -1,  0, -1 ];
p0 = [   1.0859542638,   1.0859542638,   0.4933739682,   0.4933739682, ... 
         0.8737595176,   0.8737595176,   0.6043900367,   0.6043900367, ... 
         0.9549932244,   0.9549932244,   0.7015778220,   0.7015778220, ... 
         0.9081991060,   0.9081991060,   1.0562679428,   1.0562679428, ... 
         0.9543794437,   0.9543794437,   0.9866883596,   0.9866883596 ];
c0 = [   0.0751717907,  -0.0082427906,  -0.2880852630,  -0.4887366083, ... 
        -0.1709389778,   0.1065369928,   0.3845903475,   0.3074219368, ... 
         0.0242136637,  -0.0804302473,  -0.0844066957,  -0.0154037568, ... 
        -0.0063029471,  -0.0302681729,  -0.0243108556,   0.0037923197, ... 
         0.0245894675,   0.0177004014,   0.0024010069,  -0.0015285861, ... 
         0.0023859122 ];


% Bandpass filter specification
fapl=0.1,fapu=0.2,Wap=1
if exist('dBap','var')~=1
  dBap=2
endif
fasll=0.04,fasl=0.05,fasu=0.25,fasuu=0.26
if exist('dBas','var')~=1
  dBas=33
endif
if exist('dBass','var')~=1
  dBass=36
endif
if exist('Wasl','var')~=1
  Wasl=1e5
endif
if exist('Wasu','var')~=1
  Wasu=1e6
endif
ftpl=0.09,ftpu=0.21,tp=16
if exist('tpr','var')~=1
  tpr=0.16
endif
if exist('Wtp','var')~=1
  Wtp=6
endif

% Amplitude constraints
npoints=250;
wa=(0:(npoints-1))'*pi/npoints;
nasll=floor(npoints*fasll/0.5)+1;
nasl=ceil(npoints*fasl/0.5)+1;
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
nasu=floor(npoints*fasu/0.5)+1;
nasuu=ceil(npoints*fasuu/0.5)+1;

Asqd=[zeros(napl-1,1); ...
      ones(napu-napl+1,1); ...
      zeros(npoints-napu,1)];
Asqdu=[(10^(-dBass/10))*ones(nasll,1); ...
       (10^(-dBas/10))*ones(nasl-nasll,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBas/10))*ones(nasuu-nasu,1); ...
       (10^(-dBass/10))*ones(npoints-nasuu+1,1)];
Asqdl=[zeros(napl-1,1); ...
       (10^(-dBap/10))*ones(napu-napl+1,1); ...
       zeros(npoints-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(npoints-nasu+1,1)];
% Sanity checks
nchka=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];
printf("nchka=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];\n");
printf("nchka=[ ");printf("%d ",nchka);printf("];\n");
printf("f(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)'/(2*pi));printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Group delay constraints
ntpl=floor(npoints*ftpl/0.5);
ntpu=ceil(npoints*ftpu/0.5);
wt=(ntpl:ntpu)'*pi/npoints;
ntp=length(wt);
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Constraints on the coefficients
dmax=0.25
rho=127/128
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc0=[k0;c0];
kc0_u=[rho*ones(size(k0));10*ones(size(c0))];
kc0_l=-kc0_u;

% Set coefficient size
if exist('nbits','var')~=1
  nbits=10;
endif
nscale=2^(nbits-1);
if exist('ndigits','var')~=1
  ndigits=3;
endif
ndigits_alloc=schurOneMlattice_allocsd_Ito(nbits,ndigits,k0,epsilon0,p0,c0, ...
                                           wa,Asqd,Wa,wt,Td,Wt);
k_allocsd_digits=int16(ndigits_alloc(1:Nk));
c_allocsd_digits=int16(ndigits_alloc((Nk+1):end));
% Find the signed-digit approximations to k0 and c0
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits_alloc);
k0_sd=kc0_sd(1:Nk);
k0_sd=k0_sd(:);
c0_sd=kc0_sd((Nk+1):end);
c0_sd=c0_sd(:);
% Initialise kc_active
kc0_sdul=kc0_sdu-kc0_sdl;
kc0_active=find(kc0_sdul~=0);
n_active=length(kc0_active);
% Check for consistent upper and lower bounds
if any(kc0_sdl>kc0_sdu)
  error("found kc0_sdl>kc0_sdu");
endif
if any(kc0_sdl>kc0_sdu)
  error("found kc0_sdl>kc0_sdu");
endif
if any(kc0_sd(kc0_active)>kc0_sdu(kc0_active))
  error("found kc0_sd(kc0_active)>kc0_sdu(kc0_active)");
endif
if any(kc0_sdl(kc0_active)>kc0_sd(kc0_active))
  error("found kc0_sdl(kc0_active)>kc0_sd(kc0_active)");
endif
if any(kc0(kc0_active)>kc0_sdu(kc0_active))
  error("found kc0(kc0_active)>kc0_sdu(kc0_active)");
endif
if any(kc0_sdl(kc0_active)>kc0(kc0_active))
  error("found kc0_sdl>kc0");
endif

% Find kc0 error
Esq0=schurOneMlatticeEsq(k0,epsilon0,p0,c0,wa,Asqd,Wa,wt,Td,Wt);

% Find kc0_sd error
Esq0_sd=schurOneMlatticeEsq(k0_sd,epsilon0,p0,c0_sd,wa,Asqd,Wa,wt,Td,Wt);

% Find the number of signed-digits and adders used by kc0_sd
[kc0_digits,kc0_adders]=SDadders(kc0_sd(kc0_active),nbits);

