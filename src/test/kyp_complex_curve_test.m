% kyp_complex_curve_test.m
% Copyright (C) 2021 Robert G. Jenssen
% See: T. Iwasaki and S. Hara, "Generalised KYP Lemma: Unified Frequency
% Domain Inequalities With Design Applications", IEEE Transactions on
% Automatic Control, Vol. 50, No. 1, pp. 41–59, January 2005

test_common;

delete("kyp_complex_curve_test.diary");
delete("kyp_complex_curve_test.diary.tmp");
diary kyp_complex_curve_test.diary.tmp

strf="kyp_complex_curve_test";

fl=0.1;
fh=0.2;
wl=2*pi*fl;
wh=2*pi*fh;

% LF
z=e.^(j*2*pi*(-fl:0.01:fl));
Phi=[-1,0;0,1];
Psi=[0,1;1,-2*cos(2*pi*fl)];
sigma_z_Phi=zeros(size(z));
sigma_z_Psi=zeros(size(z));
for k=1:length(z)
  sigma_z_Phi(k)=[conj(z(k)),1]*Phi*[z(k);1];
  sigma_z_Psi(k)=[conj(z(k)),1]*Psi*[z(k);1];
endfor
if max(abs(sigma_z_Phi))>eps
  error("max(abs(sigma_z_Phi))(%g)>eps",max(abs(sigma_z_Phi)));
endif
if min(sigma_z_Psi)<-eps
  error("min(sigma_z_Psi)(%g)<-eps",-min(sigma_z_Psi));
endif

% MF
z=e.^(j*2*pi*(fl:0.01:fh));
Phi=[-1,0;0,1];
wc=pi*(fh+fl);
ww=pi*(fl-fh);
Psi=[0,e^(j*wc);e^(-j*wc),-2*cos(ww)];
sigma_z_Phi=zeros(size(z));
sigma_z_Psi=zeros(size(z));
for k=1:length(z)
  sigma_z_Phi(k)=[conj(z(k)),1]*Phi*[z(k);1];
  sigma_z_Psi(k)=[conj(z(k)),1]*Psi*[z(k);1];
endfor
if max(abs(sigma_z_Phi))>eps
  error("max(abs(sigma_z_Phi))(%g)>eps",max(abs(sigma_z_Phi)));
endif
if min(sigma_z_Psi)<-eps
  error("min(sigma_z_Psi)(%g)<-eps",-min(sigma_z_Psi));
endif

% HF
z=e.^(j*2*pi*(fh:0.01:0.5));
Phi=[-1,0;0,1];
Psi=[0,-1;-1,2*cos(2*pi*fh)];
sigma_z_Phi=zeros(size(z));
sigma_z_Psi=zeros(size(z));
for k=1:length(z)
  sigma_z_Phi(k)=[conj(z(k)),1]*Phi*[z(k);1];
  sigma_z_Psi(k)=[conj(z(k)),1]*Psi*[z(k);1];
endfor
if max(abs(sigma_z_Phi))>eps
  error("max(abs(sigma_z_Phi))(%g)>eps",max(abs(sigma_z_Phi)));
endif
if min(sigma_z_Psi)<-eps
  error("min(sigma_z_Psi)(%g)<-eps",-min(sigma_z_Psi));
endif

% Done
diary off
movefile kyp_complex_curve_test.diary.tmp kyp_complex_curve_test.diary;
