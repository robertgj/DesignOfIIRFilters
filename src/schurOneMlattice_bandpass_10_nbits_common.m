% schurOneMlattice_bandpass_10_nbits_common.m
% Copyright (C) 2017-2020 Robert G. Jenssen

% Coefficients found by schurOneMlattice_sqp_slb_bandpass_test.m
k0 = [   0.0000000000,   0.6672955640,   0.0000000000,   0.4964341949, ... 
         0.0000000000,   0.3462544804,   0.0000000000,   0.4174442880, ... 
         0.0000000000,   0.2972266682,   0.0000000000,   0.2512374722, ... 
         0.0000000000,   0.1512063085,   0.0000000000,   0.1021208736, ... 
         0.0000000000,   0.0362871687,   0.0000000000,   0.0150432836 ];
epsilon0 = [  0,  1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0, -1,  0,  1, ... 
              0, -1,  0, -1 ];
p0 = [   1.1347075754,   1.1347075754,   0.5068820974,   0.5068820974, ... 
         0.8737911640,   0.8737911640,   0.6089034442,   0.6089034442, ... 
         0.9498011634,   0.9498011634,   0.6990888887,   0.6990888887, ... 
         0.9037123550,   0.9037123550,   1.0524603142,   1.0524603142, ... 
         0.9499484805,   0.9499484805,   0.9850681834,   0.9850681834 ];
c0 = [   0.0704221417,  -0.0128119538,  -0.2992871552,  -0.4821902862, ... 
        -0.1624798794,   0.1224163794,   0.3957922392,   0.3003821423, ... 
         0.0171930791,  -0.0825256371,  -0.0795022560,  -0.0125415926, ... 
        -0.0099075145,  -0.0352745191,  -0.0255813129,   0.0048306421, ... 
         0.0246321541,   0.0165314320,   0.0027523861,   0.0012900332, ... 
         0.0058051915 ];

% Bandpass filter specification
if exist('tol','var')~=1
  tol=1e-4
endif
if exist('ctol','var')~=1
  ctol=tol/10
endif
fapl=0.1,fapu=0.2,Wap=1
if exist('dBap','var')~=1
  dBap=2
endif
fasll=0.04,fasl=0.05,fasu=0.25,fasuu=0.26
if exist('dBas','var')~=1
  dBas=33
endif
if exist('dBass','var')~=1
  dBass=40
endif
if exist('Wasl','var')~=1
  Wasl=5e5
endif
if exist('Wasu','var')~=1
  Wasu=1e6
endif
ftpl=0.09,ftpu=0.21,tp=16
if exist('tpr','var')~=1
  tpr=0.2
endif
if exist('Wtp','var')~=1
  Wtp=5
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

% Set coefficient size
if exist('nbits','var')~=1
  nbits=10;
endif
nscale=2^(nbits-1);
if exist('ndigits','var')~=1
  ndigits=3;
endif

% Constraints on the coefficients
dmax=0.25
rho=(nscale-1)/nscale
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc0=[k0;c0];
kc0_u=[rho*ones(size(k0));10*ones(size(c0))];
kc0_l=-kc0_u;

% Allocate digits
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

