% jacobi_thetaj_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("jacobi_thetaj_test.diary");
delete("jacobi_thetaj_test.diary.tmp");
diary jacobi_thetaj_test.diary.tmp

% Check identities from NIST Digital Library of Mathematical
% Formulas, Section 20.9(i)
tol=2*eps;
k=0.1;
z=0.2;
K=ellipke(k^2);
Kp=ellipke(1-(k^2));
tau=j*Kp/K;
q=exp(j*pi*tau);
if abs(K-((pi/2)*(jacobi_theta3(0,q)^2)))>tol
  error("abs(K-((pi/2)*(jacobi_theta3(0,q)^2)))>tol");
endif

if abs(carlson_RF(0,jacobi_theta3(0,q)^4,jacobi_theta4(0,q)^4)-(pi/2))>tol
  error("abs(carlson_RF(0,jacobi_theta3(0,q)^4,\
jacobi_theta4(0,q)^4)-(pi/2))>tol");
endif

if abs(exp(-pi*carlson_RF(0,k^2,1)/carlson_RF(0,1-(k^2),1))-q)>tol
  error("abs(exp(-pi*carlson_RF(0,k^2,1)/carlson_RF(0,1-(k^2),1))-q)>tol");
endif

% Check duplication formula from NIST Digital Library of Mathematical
% Formulas, Section 20.7(iii)
tol=2*eps;
z=0.2;q=0.2;
if abs((2*jacobi_theta1(z,q)*jacobi_theta2(z,q)* ...
        jacobi_theta3(z,q)*jacobi_theta4(z,q)/ ...
        (jacobi_theta2(0,q)*jacobi_theta3(0,q)*jacobi_theta4(0,q))) - ...
       jacobi_theta1(2*z,q))>tol
  error("Duplication formula 20.7.10 failed")
endif

% Check reduction formulas from NIST Digital Library of Mathematical
% Formulas, Section 20.7(iv)
tol=5*eps;
z=0.5;q=0.5;
if abs((jacobi_theta1(z,q)*jacobi_theta2(z,q)/jacobi_theta1(2*z,q^2))-...
       jacobi_theta4(0,q^2))>tol
  error("Reduction formula 20.7.11 first part failed!");
endif
if abs((jacobi_theta3(z,q)*jacobi_theta4(z,q)/jacobi_theta4(2*z,q^2))-...
       jacobi_theta4(0,q^2))>tol
  error("Reduction formula 20.7.11 second part failed!");
endif
if abs((2*jacobi_theta1(z,q^2)*jacobi_theta4(z,q^2)/jacobi_theta1(z,q))-...
       jacobi_theta2(0,q))>tol
  error("Reduction formula 20.7.12 first part failed!");
endif
if abs((2*jacobi_theta2(z,q^2)*jacobi_theta3(z,q^2)/jacobi_theta2(z,q))-...
       jacobi_theta2(0,q))>tol
  error("Reduction formula 20.7.12 second part failed!");
endif

% Check sn,cn,dn

% Check z=0
tol=eps;
zeta=0;
snz=jacobi_theta3(0,q)*jacobi_theta1(zeta,q)/ ...
       (jacobi_theta2(0,q)*jacobi_theta4(zeta,q));
if abs(snz)>tol
  error("abs(sn(0))>tol");
endif
cnz=jacobi_theta4(0,q)*jacobi_theta2(zeta,q)/ ...
       (jacobi_theta2(0,q)*jacobi_theta4(zeta,q));
if abs(cnz-1)>tol
  error("abs(cn(0)-1)>tol");
endif
dnzeta=jacobi_theta4(0,q)*jacobi_theta3(zeta,q)/ ...
       (jacobi_theta3(0,q)*jacobi_theta4(zeta,q));
if abs(dnzeta-1)>tol
  error("abs(dn(0)-1)>tol");
endif

% Check values of sn, cn and dn from NIST Digital Library of Mathematical
% Formulas, Section 22.2
tol=10*eps;
for k=0.02:0.02:0.98,
  zr=(-1:0.1:1);
  zi=(-1:0.1:1)';
  z=zr+(j*zi);
  [sn,cn,dn]=ellipj(z,k^2);
  K=ellipke(k^2);
  Kp=ellipke(1-(k^2));
  q=exp(-pi*Kp/K);
  zeta=pi*z/(2*K);
  snz=jacobi_theta3(0,q)*jacobi_theta1(zeta,q)./ ...
      (jacobi_theta2(0,q)*jacobi_theta4(zeta,q));
  if max(max(abs(sn-snz)))>tol
    error("max(max(abs(sn-snz)))(k=%f,%g)>tol",k,max(max(abs(sn-snz))));
  endif
  cnz=jacobi_theta4(0,q)*jacobi_theta2(zeta,q)./ ...
      (jacobi_theta2(0,q)*jacobi_theta4(zeta,q));
  if max(max(abs(cn-cnz)))>tol
    error("max(max(abs(cn-cnz)))(k=%f,%g)>tol",k,max(max(abs(cn-cnz))));
  endif
  dnz=jacobi_theta4(0,q)*jacobi_theta3(zeta,q)./ ...
      (jacobi_theta3(0,q)*jacobi_theta4(zeta,q));
  if max(max(abs(dn-dnz)))>tol
    error("max(max(abs(dn-dnz)))(k=%f,%g)>tol",k,max(max(abs(dn-dnz))));
  endif
endfor

% Check sn,cn,dn identities
tol=20*eps;
for k=0.05:0.05:0.3,
  zr=(-1:0.1:1);
  zi=(-1:0.1:1)';
  z=zr+(j*zi);
  k2=k^2;
  kp2=1-k2;
  K=ellipke(k2);
  Kp=ellipke(kp2);
  q=exp(-pi*Kp/K);
  zeta=pi*z/(2*K);
  snz=jacobi_theta3(0,q)*jacobi_theta1(zeta,q)./ ...
      (jacobi_theta2(0,q)*jacobi_theta4(zeta,q));
  cnz=jacobi_theta4(0,q)*jacobi_theta2(zeta,q)./ ...
      (jacobi_theta2(0,q)*jacobi_theta4(zeta,q));
  dnz=jacobi_theta4(0,q)*jacobi_theta3(zeta,q)./ ...
      (jacobi_theta3(0,q)*jacobi_theta4(zeta,q));
  
  snz2=snz.^2;
  cnz2=cnz.^2;
  dnz2=dnz.^2;

  % Check sn^2+cn^2=1
  if max(max(abs(snz2+cnz2-1)))>tol
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

% Done
diary off
movefile jacobi_thetaj_test.diary.tmp jacobi_thetaj_test.diary;
