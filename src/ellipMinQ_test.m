% ellipMinQ_test.m
% Copyright (C) 2018 Robert G. Jenssen
%
% An example of the design of a minimal-Q elliptic IIR filter.
%
% References:
%  [1] H. J. Orchard and A. N. Willson, Jr., "Elliptic Functions
%      for Filter Design." IEEE Transactions on Circuits and
%      Systems-I; Fundamental Theory and Applications, April 1997.
%  [2] M. D. Lutovac and L. D. Milic, "Design of Computationally Efficient
%      Elliptic IIR Filters with a Reduced Number of Shift-and-Add Operations
%      in Multipliers", IEEE Transactions on Signal Processing, October 1997

test_common;

unlink("ellipMinQ_test.diary");
unlink("ellipMinQ_test.diary.tmp");
diary ellipMinQ_test.diary.tmp


% IIR filter specification
Fp=0.1,ApdB=0.1,Fa=0.125,AadB=40,n=9,nbits=8,ndigits=3
% Sanity check
if (n<3) || (mod(n,2)~=1)
  error("Expect n odd and n>=3");
endif

% Find a
a_min=-(1-(tan(pi*Fp)^2))/(1+(tan(pi*Fp)^2));
a_max=-(1-(tan(pi*Fa)^2))/(1+(tan(pi*Fa)^2));
for m=1:ndigits
  a=flt2SD((a_min+a_max)/2,nbits,m);
  if (a_min<a) && (a<a_max)
    printf("%f < a < %f. Choose a=%f\n",a_min,a_max,a);
    break;
  endif
endfor
% Sanity check
if a_min>a
  error("Found a_min(%f)>a(%f)!",a_min,a);
endif
if a>a_max
  error("Found a(%f)>a_max(%f)!",a,a_max);
endif

% Centre of z-plane pole circle
x0=-1/a
f3dB=acos(1/x0)/(2*pi)
a1=-x0*(1-sqrt(1-(x0^(-2))))

% Choose fa=Fa
fa=Fa
fp=atan(tan(pi*f3dB)^2/tan(pi*fa))/pi

% Find s-plane prototype normalised stop-band edge frequency
wa=tan(pi*fa)/tan(pi*fp)

% Follow [1,Fig.6] to find the s-plane filter

% Compute the Landen transform forwards on k
k=1/wa
v=k;
m1=1;
do
  v=(v/(1+sqrt(1-(v^2))))^2; % [1,Eqn.10]
  k=[k;v];
  m1=m1+1;
until v<1e-15;

% Compute the Landen transform backwards on g
g=zeros(size(k));  
for m=0:10,
  m2=m1-m;
  g(m2)=4*((k(m1)/4)^(n/(2^m))); % [1,Eqn.31]
  if g(m2)>1e-305,
    break;
  endif
endfor
for m=m2:-1:2
  g(m-1)=2*sqrt(g(m))/(1+g(m)); % [1,Eqn.32]
endfor

% Calculate u-to-Omega mapping and cd function value
k2=k(1)^2;
K=ellipke(k2);
Kp=ellipke(1-k2);
g2=g(1)^2;
G=ellipke(g2);
nf=8000;
Wend=8;
u=[(nf:-1:1)/nf, (j*Kp/K)*(0:(nf-1))/nf, ((0:(nf-1))/nf)+(j*Kp/K)];
[~,Kcn,Kdn]=ellipj(u*K,k2);
Omega=real(Kcn./Kdn);
Oend=min(find(Omega>Wend));
[~,Gcn,Gdn]=ellipj(n*u*G,g2);
cdnuGg=real(Gcn./Gdn).^2;

% Plot Omega and cdnuGg
[ax,h1,h2]=plotyy(Omega(1:nf),cdnuGg(1:nf), ...
                  Omega((nf+1):Oend),cdnuGg((nf+1):Oend));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 Wend 0 1]);
axis(ax(2),[0 Wend 0 2.5e9]);
strt="Minimal-Q elliptic filter $cd^2(nuG,\\gamma)$";
title(strt);
ylabel("$cd^2(nuG,\\gamma)$");
xlabel("$\\Omega$(u)");
grid("on");
strf="ellipMinQ_test";
print(strcat(strf,"_cd"),"-dpdflatex");
close

% Response ripple
printf("g=%g\n",g(1));
L=1/g(1)
apdB=10*log10(1+(1/L)) % [2, Eqn.11]
aadB=10*log10(1+L)

% Find s-plane poles/zeros by Landen transform of the Cheb. Type1 poles/zeros
epsilon=1/sqrt(L); % Minimal-Q relation
% From ellipap1.m
u2 = log((1 + sqrt(1 + epsilon^2))/epsilon)/n; % [1,Eqn.22]
zs = [];
ps = [];
for index=1:floor(n/2)
  u1 = (2*index -1)*pi/(2*n); % [1,Eqn.23]
  c = -i/cos((-u1+u2*i));
  d = 1/cos(u1); % [1,Eqn.23]
  for m = m1:-1:2
    c = (c - k(m)/c)/(1 + k(m)); % [1,Eqn.38]
    d = (d + k(m)/d)/(1 + k(m));
  endfor
  af(index) =  1/c;
  df(index) =  d/k(1);
  ps = [conj(af(index));af(index);ps];
  zs = [-df(index)*i;df(index)*i;zs];
endfor
% Odd order real pole (zero at inf)
if mod(n,2)
  tmp = 1/sinh(u2);
  for m=m1:-1:2
    tmp=(tmp - k(m)/tmp)/(1 + k(m));
  endfor
  ps = [ps;-1/tmp];
endif

% Check radius of s-plane pole circle
printf("abs(ps)=[ ");printf("%f ",abs(ps'));printf("], expected %f\n",sqrt(wa));

% Gain
Gs = real(prod(-ps)/prod(-zs));

% Plot s-plane response
[ns,ds]=zp2tf(zs,ps,Gs);
nWp=ceil(nf/Wend)+1;
nWa=floor(wa*nf/Wend)+1;
Ws=linspace(0,Wend,nf);
Hs=freqs(ns,ds,Ws);
ax=plotyy(Ws(1:nWp),20*log10(abs(Hs(1:nWp))), ...
          Ws((nWp+1):end),20*log10(abs(Hs((nWp+1):end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 Wend -0.0002 0]);
axis(ax(2),[0 Wend -80 0]);
strt="Minimal-Q elliptic filter s-plane response";
title(strt);
ylabel("Amplitude(dB)");
xlabel("$\\Omega$");
grid("on");
strf="ellipMinQ_test";
print(strcat(strf,"_s_resp"),"-dpdflatex");
close

% Convert s-plane poles/zeros to z-plane
% (w=1 in the s-plane is warped to fp in the z-plane)
[zz,pz,Gz]=bilinear(zs,ps,Gs,2*tan(pi*fp));
[nz,dz]=zp2tf(zz,pz,Gz);

% Check radius of z-plane pole circle
printf("abs(pz-x0)=[ ");printf("%f ",abs(pz'-x0));printf("]\n");

% Convert z-plane poles to lattice coefficients
spz=pz(imag(pz)>=0);
[~,m]=sort(abs(spz));
spz=spz(m);
ri=abs(spz);
b=ri(2:end).^2;
printf("b=[");printf(" %f",b');printf(" ]\n");
% Sanity check on alpha
costi=cos(arg(spz));
alpha=-2*ri.*costi./(1+(ri.^2)); % [2, Eqn.6]
printf("alpha=[");printf(" %f",alpha');printf(" ], expected %f\n",a);

% Convert lattice coefficients to all-pass filter polynomials
Az=[1,a1];
for m=2:2:length(b)
  Az=conv(Az,[1,a*(1+b(m)),b(m)]);
endfor
Bz=[1];
for m=1:2:length(b),
  Bz=conv(Bz,[1,a*(1+b(m)),b(m)]);
endfor

% Plot z-plane response
[hAz,Wz]=freqz(fliplr(Az),Az,nf);
hBz=freqz(fliplr(Bz),Bz,Wz);
hz=(hAz+hBz)/2;
nf3dB=floor(f3dB*nf/0.5)+1;
printf("Response at f3dB=%f is %f dB\n",f3dB,20*log10(abs(hz(nf3dB))))
nfp=ceil(fp*nf/0.5)+1;
printf("Response at fp=%f is %f dB\n",fp,20*log10(abs(hz(nfp))))
nfa=floor(fa*nf/0.5)+1;
printf("Response at fa=%f is %f dB\n",fa,20*log10(abs(hz(nfa))))
ax=plotyy(Wz(1:nfp)*0.5/pi,20*log10(abs(hz(1:nfp))), ...
          Wz(nfa:end)*0.5/pi,20*log10(abs(hz(nfa:end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
% Plotting axis limits
axis(ax(1),[0 0.5 -0.0008 0]);
axis(ax(2),[0 0.5 -46 -38]);
strt="Minimal-Q elliptic filter z-plane response";
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
strf="ellipMinQ_test";
print(strcat(strf,"_z_resp"),"-dpdflatex");
close

% Plot poles and zeros
zplane(zz,pz);
strt="Minimal-Q elliptic filter poles and zeros";
title(strt);
grid("on");
print(strcat(strf,"_z_pz"),"-dpdflatex");
close

% Convert signed-digit lattice coefficients to all-pass filter polynomials
[~,a1_sdu,a1_sdl]=flt2SD(a1,nbits,ndigits);
[~,b_sdu,b_sdl]=flt2SD(b,nbits,ndigits);
a1_sd=a1_sdl; % !!!WARNING!!! : change this manually to a1_sdu !?!
% Brute force search of b lattice coefficients for mini-max stop-band response
b_sd=cell(1,2^(length(b)));
Az_sd=cell(size(b_sd));
Bz_sd=cell(size(b_sd));
Aminimax=inf;
pminimax=inf;
for p=1:length(b_sd)
  b_sd{p}=zeros(size(b));
  mbin=dec2bin(p-1,length(b));
  for m=1:length(mbin),
    if mbin(m)=='0'
      b_sd{p}(m)=b_sdl(m);
    else
      b_sd{p}(m)=b_sdu(m);
    endif
  endfor
  Az_sd{p}=[1,a1_sd];
  for m=2:2:length(mbin)
    Az_sd{p}=conv(Az_sd{p},[1,a*(1+b_sd{p}(m)),b_sd{p}(m)]);
  endfor
  Bz_sd{p}=[1];
  for m=1:2:length(mbin),
    Bz_sd{p}=conv(Bz_sd{p},[1,a*(1+b_sd{p}(m)),b_sd{p}(m)]);
  endfor

  % Check z-plane stop-band response
  [hAz_sd,Wz]=freqz(fliplr(Az_sd{p}),Az_sd{p},nf);
  hBz_sd=freqz(fliplr(Bz_sd{p}),Bz_sd{p},Wz);
  hz_sd=(hAz_sd+hBz_sd)/2;
  [Amax,iAmax]=max(20*log10(abs(hz_sd(nfa:end))));
  printf("p=%d,mbin=%s, max. stop band response=%f dB at %f\n",
         p,mbin,Amax,Wz(iAmax+nfa-1)*0.5/pi);
  if Amax<Aminimax
    Aminimax=Amax;
    pminimax=p;
  endif
endfor

% Best response found (also nbits=10,ndigits=4,p=7,-38.4dB)
[hAz_sd,Wz]=freqz(fliplr(Az_sd{pminimax}),Az_sd{pminimax},nf);
hBz_sd=freqz(fliplr(Bz_sd{pminimax}),Bz_sd{pminimax},Wz);
hz_sd=(hAz_sd+hBz_sd)/2;
printf("SD response at f3dB=%f is %f dB\n",f3dB,20*log10(abs(hz_sd(nf3dB))))
printf("SD response at fp=%f is %f dB\n",fp,20*log10(abs(hz_sd(nfp))))
printf("SD response at fa=%f is %f dB\n",fa,20*log10(abs(hz_sd(nfa))))
ax=plotyy(Wz(1:nfp)*0.5/pi,20*log10(abs(hz_sd(1:nfp))), ...
          Wz(nfa:end)*0.5/pi,20*log10(abs(hz_sd(nfa:end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -0.0008 0]);
axis(ax(2),[0 0.5 -46 -38]);
strt=sprintf("Minimal-Q elliptic filter z-plane response (%d-bit, \
%d-signed-digit lattice coefficients)",nbits,ndigits);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
strf=sprintf("%s_z_resp_sd",strf);
print(strf,"-dpdflatex");
close

% Signed-digit coefficients
nscale=2^(nbits-1);
printf("%d bit, %d signed-digit, p=%d, a1=%d, a=%d, b=[", ...
       nbits,ndigits,pminimax,a1_sd*nscale,a*nscale);
printf(" %d",b_sd{pminimax}'*nscale);
printf(" ]\n");

% Done
diary off
movefile ellipMinQ_test.diary.tmp ellipMinQ_test.diary;
