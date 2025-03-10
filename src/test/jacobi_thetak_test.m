% jacobi_thetak_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("jacobi_thetak_test.diary");
delete("jacobi_thetak_test.diary.tmp");
diary jacobi_thetak_test.diary.tmp

% Check identities from NIST Digital Library of Mathematical
% Formulas, Section 20.9(i)
tol=2*eps;
k=0.9;
z=0.2;
K=ellipke(k^2);
if abs(K-((pi/2)*(jacobi_theta3k(0,k)^2)))>tol
  error("abs(K-((pi/2)*(jacobi_theta3k(0,k)^2)))>tol");
endif
if abs(carlson_RF(0,jacobi_theta3k(0,k)^4,jacobi_theta4k(0,k)^4)-(pi/2))>tol
  error(["abs(carlson_RF(0,jacobi_theta3k(0,k)^4,", ...
 "jacobi_theta4k(0,k)^4)-(pi/2))>tol"]);
endif

tol=2*eps;
k=0.1;
z=0.2;
K=ellipke(k^2);
if abs(K-((pi/2)*(jacobi_theta3k(0,k)^2)))>tol
  error("abs(K-((pi/2)*(jacobi_theta3k(0,k)^2)))>tol");
endif
if abs(carlson_RF(0,jacobi_theta3k(0,k)^4,jacobi_theta4k(0,k)^4)-(pi/2))>tol
  error(["abs(carlson_RF(0,jacobi_theta3k(0,k)^4,", ...
 "jacobi_theta4k(0,k)^4)-(pi/2))>tol"]);
endif

% Check values of sn, cn and dn from NIST Digital Library of Mathematical
% Formulas, Section 22.2
tol=400*eps;
for k=0.1:0.1:0.9,
  zr=(-1.6:0.4:1.6);
  zi=(-1.6:0.4:1.6)';
  z=zr+(j*zi);
  [sn,cn,dn]=ellipj(z,k^2);
  K=ellipke(k^2);
  Kp=ellipke(1-(k^2));
  q=exp(-pi*Kp/K);
  zeta=pi*z/(2*K);
  snz=jacobi_theta3k(0,k)*jacobi_theta1k(zeta,k)./ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  if max(max(abs(sn-snz)))>tol
    error("max(max(abs(sn-snz)))(k=%f,%g*eps)>tol",k,max(max(abs(sn-snz)))/eps);
  endif
  cnz=jacobi_theta4k(0,k)*jacobi_theta2k(zeta,k)./ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  if max(max(abs(cn-cnz)))>tol
    error("max(max(abs(cn-cnz))))(k=%f,%g*eps)>tol",k,max(max(abs(cn-cnz)))/eps);
  endif
  dnz=jacobi_theta4k(0,k)*jacobi_theta3k(zeta,k)./ ...
      (jacobi_theta3k(0,k)*jacobi_theta4k(zeta,k));
  if max(max(abs(dn-dnz)))>tol
    error("max(max(abs(dn-dnz)))(k=%f,%g*eps)>tol",k,max(max(abs(dn-dnz)))/eps);
  endif
endfor

% Check sn,cn,dn identities
tol=20*eps;
for k=0.1:0.1:0.9,
  zr=(-1:0.1:1);
  zi=(-1:0.1:1)';
  z=zr+(j*zi);
  k2=k^2;
  K=ellipke(k2);
  kp2=1-k2;
  Kp=ellipke(kp2);
  zeta=pi*z/(2*K);
  snz=jacobi_theta3k(0,k)*jacobi_theta1k(zeta,k)./ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  cnz=jacobi_theta4k(0,k)*jacobi_theta2k(zeta,k)./ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  dnz=jacobi_theta4k(0,k)*jacobi_theta3k(zeta,k)./ ...
      (jacobi_theta3k(0,k)*jacobi_theta4k(zeta,k));
  snz2=snz.^2;
  cnz2=cnz.^2;
  dnz2=dnz.^2;

  % Check sn^2+cn^2=1
  if max(max(abs(snz2+(cnz2)-1)))>tol
    error("max(max(abs((snz^2)+(cnz^2)-1)))(k=%f,%g*eps)>tol", ...
          k,max(max(abs(snz2+(cnz2)-1)))/eps);
  endif
  % Check dn^2+k^2*sn^2=1
  if max(max(abs(dnz2+(k2*snz2)-1)))>tol
    error("max(max(abs((dnz^2)+(k2*(snz^2))-1)))(k=%f,%g*eps)>tol", ...
          k,max(max(abs(dnz2+(k2*snz2)-1)))/eps);
  endif
  % Check k'^2+k^2*cn^2=dn^2
  if max(max(abs(dnz2-(k2*cnz2)-kp2)))>tol
    error("max(max(abs((dnz^2)-(k2*(cnz^2))-kp2)))(k=%f,%g*eps)>tol", ...
          k,max(max(abs(dnz2-(k2*cnz2)-kp2)))/eps);
  endif
  % Check k'^2+k^2*cn^2=dn^2
  if max(max(abs(dnz2-cnz2-(kp2*snz2))))>tol
    error("max(max(abs((dnz^2)-(cnz^2)-((kp*snz)^2))))(k=%f,%g*eps)>tol", ...
          k,max(max(abs(dnz2-cnz2-(kp2*snz2))))/eps);
  endif
endfor

% Check special arguments with jacobi_theta[1,2,3,4]k functions
for k=0.02:0.02:0.98,
  k2=k^2;
  K=ellipke(k2);
  kp2=1-k2;
  kp=sqrt(kp2);
  Kp=ellipke(kp2);

  % Check K
  tol=10*eps;
  zr=K;
  zi=0;
  z=zr+(j*zi);
  zeta=pi*z/(2*K);
  % Check sn(K)=1
  snz=jacobi_theta3k(0,k)*jacobi_theta1k(zeta,k)/ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  if abs(snz-1)>tol
    error("abs(sn(K)-1)>tol(zr=%g,zi=%g,k=%g,%g eps)", ...
          zr,zi,k,abs(snz-1)/eps);
  endif
  % Check cn(K)=0
  cnz=jacobi_theta4k(0,k)*jacobi_theta2k(zeta,k)/ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  if abs(cnz)>tol
    error("abs(cn(K))>tol(zr=%g,zi=%g,k=%g,%g eps)", ...
          zr,zi,k,abs(cnz)/eps);
  endif
  % Check dn(K)=kp
  dnz=jacobi_theta4k(0,k)*jacobi_theta3k(zeta,k)/ ...
      (jacobi_theta3k(0,k)*jacobi_theta4k(zeta,k));
  if abs(dnz-kp)>tol
    error("abs(dn(K)-kp)>tol(zr=%g,zi=%g,k=%g,%g eps)", ...
          zr,zi,k,abs(dnz-kp)/eps);
  endif

  % Check jKp/2
  tol=1000*eps;
  zr=0;
  zi=Kp/2;
  z=zr+(j*zi);
  zeta=pi*z/(2*K);
  % Check sn(jKp/2)=j/sqrt(k)
  snz=jacobi_theta3k(0,k)*jacobi_theta1k(zeta,k)/ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  if abs(snz-(j/sqrt(k)))>tol
    error("abs(sn(jKp/2)-j/sqrt(k))>tol(zr=%g,zi=%g,k=%g,%g eps)", ...
          zr,zi,k,abs(snz-(j/sqrt(k)))/eps);
  endif
  % Check cn(jKp/2)=sqrt((1+k)/k)
  cnz=jacobi_theta4k(0,k)*jacobi_theta2k(zeta,k)/ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  if abs(cnz-sqrt((1+k)/k))>tol
    error("abs(cn(jKp/2)-sqrt((1+k)/k))>tol(zr=%g,zi=%g,k=%g,%g eps)", ...
          zr,zi,k,abs(cnz-sqrt((1+k)/k))/eps);
  endif
  % Check dn(jKp/2)=sqrt(1+k)
  dnz=jacobi_theta4k(0,k)*jacobi_theta3k(zeta,k)/ ...
      (jacobi_theta3k(0,k)*jacobi_theta4k(zeta,k));
  if abs(dnz-sqrt(1+k))>tol
    error("abs(dn(jKp/2)-sqrt(1+k))>tol(zr=%g,zi=%g,k=%g,%g eps)", ...
          zr,zi,k,abs(dnz-sqrt(1+k))/eps);
  endif

  % Check K+jKp/2
  tol=1000*eps;
  zr=K;
  zi=Kp/2;
  z=zr+(j*zi);
  zeta=pi*z/(2*K);
  % Check sn(K+jKp/2)=1/sqrt(k)
  snz=jacobi_theta3k(0,k)*jacobi_theta1k(zeta,k)/ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  if abs(snz-(1/sqrt(k)))>tol
    error("abs(sn(K+jKp/2)-1/sqrt(k))>tol(zr=%g,zi=%g,k=%g, %g eps)",...
          zr,zi,k,abs(snz-(1/sqrt(k)))/eps);
  endif
  % Check cn(K+jKp/2)=j*sqrt((1-k)/k)
  cnz=jacobi_theta4k(0,k)*jacobi_theta2k(zeta,k)/ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  if abs(cnz+(j*sqrt((1-k)/k)))>tol
    error("abs(cn(K+jKp/2)+j*sqrt((1-k)/k))>tol(zr=%g,zi=%g,k=%g, %g eps)",...
          zr,zi,k,abs(cnz+(j*sqrt((1-k)/k)))/eps);
  endif
  % Check dn(K+jKp/2)=sqrt(1-k)
  dnz=jacobi_theta4k(0,k)*jacobi_theta3k(zeta,k)/ ...
      (jacobi_theta3k(0,k)*jacobi_theta4k(zeta,k));
  if abs(dnz-sqrt(1-k))>tol
    error("abs(dn(K+jKp/2)-sqrt(1-k))>tol(zr=%g,zi=%g,k=%g, %g eps)",...
          zr,zi,k,abs(dnz-sqrt(1-k))/eps);
  endif
  
  % Check K+jKp
  tol=1000*eps;
  zr=K;
  zi=Kp;
  z=zr+(j*zi);
  zeta=pi*z/(2*K);
  % Check sn(K+jKp)=1/k
  snz=jacobi_theta3k(0,k)*jacobi_theta1k(zeta,k)/ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  if abs(snz-(1/k))>tol
    error("abs(sn(K+jKp)-(1/k))>tol(zr=%g,zi=%g,k=%g,%g eps)",...
          zr,zi,k,abs(snz-(1/k))/eps);
  endif
  % Check cn(K+jKp)=-jkp/k
  cnz=jacobi_theta4k(0,k)*jacobi_theta2k(zeta,k)/ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  if abs(cnz+(j*kp/k))>tol
    error("abs(cn(K+jKp)+(j*kp/k))>tol(zr=%g,zi=%g,k=%g,%g eps)",...
          zr,zi,k,abs(cnz+(j*kp/k))/eps);
  endif
  % Check dn(K+jKp)=0
  dnz=jacobi_theta4k(0,k)*jacobi_theta3k(zeta,k)/ ...
      (jacobi_theta3k(0,k)*jacobi_theta4k(zeta,k));
  if abs(dnz)>tol
    error("abs(dn(K+jKp))>tol(zr=%g,zi=%g,k=%g,%g eps)",...
          zr,zi,k,abs(dnz)/eps);
  endif
  
  % Check K+j2Kp
  tol=10*eps;
  zr=K;
  zi=2*Kp;
  z=zr+(j*zi);
  zeta=pi*z/(2*K);
  % Check sn(K+j2Kp)=1
  snz=jacobi_theta3k(0,k)*jacobi_theta1k(zeta,k)/ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  if abs(snz-1)>tol
    error("abs(sn(K+j2Kp)-1)>tol(zr=%g,zi=%g,k=%g, %g eps)", ...
          zr,zi,k,abs(snz-1)/eps);
  endif
  % Check cn(K+j2Kp)=0
  tol=500*eps;
  cnz=jacobi_theta4k(0,k)*jacobi_theta2k(zeta,k)/ ...
      (jacobi_theta2k(0,k)*jacobi_theta4k(zeta,k));
  if abs(cnz)>tol
    error("abs(cn(K+j2Kp))>tol(zr=%g,zi=%g,k=%g, %g eps)", ...
          zr,zi,k,abs(cnz)/eps);
  endif
  % Check dn(K+j2Kp)=-kp
  tol=10*eps;
  dnz=jacobi_theta4k(0,k)*jacobi_theta3k(zeta,k)/ ...
      (jacobi_theta3k(0,k)*jacobi_theta4k(zeta,k));
  if abs(dnz+kp)>tol
    error("abs(dn(K+j2Kp)+kp)>tol(zr=%g,zi=%g,k=%g, %g eps)", ...
          zr,zi,k,abs(dnz+kp)/eps);
  endif
endfor

% Check special arguments with Octave builtin functions
for k=0.02:0.02:0.98,
  k2=k^2;
  K=ellipke(k2);
  kp2=1-k2;
  kp=sqrt(kp2);
  Kp=ellipke(kp2);

  % Check K
  zr=K;
  zi=0;
  z=zr+(j*zi);
  [snz,cnz,dnz]=ellipj(z,k2);
  tol=10*eps;
  % Check sn(K)=1
  if abs(snz-1)>tol
    error("abs(sn(K)-1)>tol(zr=%g,zi=%g,k=%g,%g eps)", ...
          zr,zi,k,abs(snz-1)/eps);
  endif
  % Check cn(K)=0
  if abs(cnz)>tol
    error("abs(cn(K))>tol(zr=%g,zi=%g,k=%g,%g eps)", ...
          zr,zi,k,abs(cnz)/eps);
  endif
  % Check dn(K)=kp
  if abs(dnz-kp)>tol
    error("abs(dn(K)-kp)>tol(zr=%g,zi=%g,k=%g,%g eps)", ...
          zr,zi,k,abs(dnz-kp)/eps);
  endif

  % Check jKp/2
  zr=0;
  zi=Kp/2;
  z=zr+(j*zi);
  [snz,cnz,dnz]=ellipj(z,k2);
  tol=1000*eps;
  % Check sn(jKp/2)=j/sqrt(k)
  if abs(snz-(j/sqrt(k)))>tol
    error("abs(sn(jKp/2)-j/sqrt(k))>tol(zr=%g,zi=%g,k=%g,%g eps)", ...
          zr,zi,k,abs(snz-(j/sqrt(k)))/eps);
  endif
  % Check cn(jKp/2)=sqrt((1+k)/k)
  if abs(cnz-sqrt((1+k)/k))>tol
    error("abs(cn(jKp/2)-sqrt((1+k)/k))>tol(zr=%g,zi=%g,k=%g,%g eps)", ...
          zr,zi,k,abs(cnz-sqrt((1+k)/k))/eps);
  endif
  % Check dn(jKp/2)=sqrt(1+k)
  if abs(dnz-sqrt(1+k))>tol
    error("abs(dn(jKp/2)-sqrt(1+k))>tol(zr=%g,zi=%g,k=%g,%g eps)", ...
          zr,zi,k,abs(dnz-sqrt(1+k))/eps);
  endif
  
  % Check K+jKp/2
  zr=K;
  zi=Kp/2;
  z=zr+(j*zi);
  [snz,cnz,dnz]=ellipj(z,k2);
  tol=1000*eps;
  % Check sn(K+jKp/2)=1/sqrt(k)
  if abs(snz-(1/sqrt(k)))>tol
    error("abs(sn(K+jKp/2)-1/sqrt(k))>tol(zr=%g,zi=%g,k=%g, %g eps)",...
          zr,zi,k,abs(snz-(1/sqrt(k)))/eps);
  endif
  % Check cn(K+jKp/2)=j*sqrt((1-k)/k)
  if abs(cnz+(j*sqrt((1-k)/k)))>tol
    error("abs(cn(K+jKp/2)+j*sqrt((1-k)/k))>tol(zr=%g,zi=%g,k=%g, %g eps)",...
          zr,zi,k,abs(cnz+(j*sqrt((1-k)/k)))/eps);
  endif
  % Check dn(K+jKp/2)=sqrt(1-k)
  if abs(dnz-sqrt(1-k))>tol
    error("abs(dn(K+jKp/2)-sqrt(1-k))>tol(zr=%g,zi=%g,k=%g, %g eps)",...
          zr,zi,k,abs(dnz-sqrt(1-k))/eps);
  endif
  
  % Check K+jKp
  zr=K;
  zi=Kp;
  z=zr+(j*zi);
  [snz,cnz,dnz]=ellipj(z,k2);
  tol=20000*eps;
  % Check sn(K+jKp)=1/k
  if abs(snz-(1/k))>tol
    error("abs(sn(K+jKp)-(1/k))>tol(zr=%g,zi=%g,k=%g,%g eps)",...
          zr,zi,k,abs(snz-(1/k))/eps);
  endif
  % Check cn(K+jKp)=-jkp/k
  if abs(cnz+(j*kp/k))>tol
    error("abs(cn(K+jKp)+(j*kp/k))>tol(zr=%g,zi=%g,k=%g,%g eps)",...
          zr,zi,k,abs(cnz+(j*kp/k))/eps);
  endif
  % Check dn(K+jKp)=0
  if abs(dnz)>tol
    error("abs(dn(K+jKp))>tol(zr=%g,zi=%g,k=%g,%g eps)",...
          zr,zi,k,abs(dnz)/eps);
  endif
  
  % Check K+j2Kp
  zr=K;
  zi=2*Kp;
  z=zr+(j*zi);
  [snz,cnz,dnz]=ellipj(z,k2);
  tol=10*eps;
  % Check sn(K+j2Kp)=1
  if abs(snz-1)>tol
    error("abs(sn(K+j2Kp)-1)>tol(zr=%g,zi=%g,k=%g, %g eps)", ...
          zr,zi,k,abs(snz-1)/eps);
  endif
  % Check cn(K+j2Kp)=0
  if abs(cnz)>tol
    error("abs(cn(K+j2Kp))>tol(zr=%g,zi=%g,k=%g, %g eps)", ...
          zr,zi,k,abs(cnz)/eps);
  endif
  % Check dn(K+j2Kp)=-kp
  if abs(dnz+kp)>tol
    error("abs(dn(K+j2Kp)+kp)>tol(zr=%g,zi=%g,k=%g, %g eps)", ...
          zr,zi,k,abs(dnz+kp)/eps);
  endif
endfor

% Done
diary off
movefile jacobi_thetak_test.diary.tmp jacobi_thetak_test.diary;
