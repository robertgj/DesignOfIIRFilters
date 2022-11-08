% kyp_complex_curve_union_test.m
% Copyright (C) 2021 Robert G. Jenssen
%
% See: Sections 2.1 and 3 of "Generalizing the KYP Lemma to multiple frequency
% intervals", G. Pipeleers, T. Iwasaki, S. Hara, SIAM J. Control. Optim.,
% Vol. 52, No. 6, pp. 3618-3638

test_common;
%set(0,'DefaultFigureVisible','on');

pkg load symbolic

delete("kyp_complex_curve_union_test.diary");
delete("kyp_complex_curve_union_test.diary.tmp");
diary kyp_complex_curve_union_test.diary.tmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Section 2.1 : Curves in the complex plane
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Section 3.1 : Example of mapping to the real axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
strf="kyp_complex_curve_union_test";
l=4
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)]
PhiR=[0,i;-i,0];
PsiR=[0,1;1,0];
Phi0=[0,1;1,0];
Psi0=[-1,0;0,1];
Tr=[1,-1;i,i]/sqrt(2);

for m=1:2,
  if m==1
    alpha=[-0.75:0.5:0.75]
    beta=[-0.6:0.5:0.9]
  elseif m==2 
    alpha=[-inf,-0.6:0.5:0.4]
    beta=[-0.75:0.5:0.25,inf]
  endif
  if any(alpha>=beta)
    error("any(alpha>=beta)");
  endif
  print_polynomial(alpha,sprintf("alpha_m%d",m), ...
                   sprintf("%s_alpha_m%d_coef.m",strf,m),"%5.2f");
  print_polynomial(beta,sprintf("beta_m%d",m), ...
                   sprintf("%s_beta_m%d_coef.m",strf,m),"%5.2f");
  a=1,b=1
  for k=1:l,
    if isinf(alpha(k))
      a=conv(a,[1;0]);
    else
      a=conv(a,[1;-alpha(k)])
    endif
    if isinf(beta(k))
      b=conv(b,[-1;0]);
    else
      b=conv(b,[1;-beta(k)])
    endif
  endfor

  Tt=[-a,b]';

  Psi=Tt'*PsiR*Tt
  if ~issymmetric(Psi)
    error("~issymmetric(Psi)");
  endif

  Phi=Tt'*PhiR*Tt
  if ~issymmetric(Phi,'skew')
    error("~issymmetric(Phi,'skew')");
  endif
  if ~ishermitian(Phi)
    error("~ishermitian(Phi)");
  endif

  syms r11 r12 r13 r14 r22 r23 r24 r33 r34 r44
  R=[r11,r12,r13,r14; ...
     r12,r22,r23,r24; ...
     r13,r23,r33,r34; ...
     r14,r24,r34,r44]
  (Jl'*kron(R,PhiR)*Jl)
  
  rr11=imag(Phi(1,2));
  rr12=imag(Phi(1,4));
  rr13=imag(Phi(1,3));
  rr14=imag(Phi(1,5));
  rr24=imag(Phi(3,5));
  rr34=imag(Phi(2,5));
  rr44=imag(Phi(4,5));
  rr22=imag(Phi(3,4))+rr34;
  rr23=imag(Phi(2,4))+rr14;
  rr33=imag(Phi(2,3))+rr12;

  RR=[rr11,rr12,rr13,rr14; ...
      rr12,rr22,rr23,rr24; ...
      rr13,rr23,rr33,rr34; ...
      rr14,rr24,rr34,rr44]
  
  if max(max(abs((Jl'*kron(RR,PhiR)*Jl)-Phi)))>eps
    error("max(max(abs((Jl'*kron(RR,PhiR)*Jl)-Phi)))>eps")
  endif

  % Test assumption 1
  Phir=Tr'*Phi0*Tr;
  Psir=Tr'*Psi0*Tr;
  T=Tr*Tt;
  s=(-1:0.02:1)*i;
  rl=zeros(l,length(s));
  for k=1:length(s),
    rlk=roots(([1,0]*T)-s(k)*([0 1]*T));
    rl(:,k)=[zeros(l-length(rlk),1);rlk];
  endfor
  if max(max(abs(imag(rl))))>eps
    error("max(max(abs(imag(rl))))>eps")
  endif
  mt=['+','o','x','s'];
  plot(imag(s),rl(1,:),mt(1),imag(s),rl(2,:),mt(2), ...
       imag(s),rl(3,:),mt(3),imag(s),rl(4,:),mt(4));
  axis([-1 1 -2 2])
  ylabel("Real part of roots")
  xlabel("Imaginary part of s")
  legend(sprintf("%g to %g",alpha(1),beta(1)), ...
         sprintf("%g to %g",alpha(2),beta(2)), ...
         sprintf("%g to %g",alpha(3),beta(3)), ...
         sprintf("%g to %g",alpha(4),beta(4)));
  legend("location","southeast");
  legend("boxoff");
  legend("left");
  print(sprintf("%s_Assumption1_m%d",strf,m),"-dpdflatex");
%  print(sprintf("%s_Assumption1_m%d",strf,m),"-dsvg");
endfor
l=4
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)]
PhiR=[0,i;-i,0];
PsiR=[0,1;1,0];
Phi0=[0,1;1,0];
Psi0=[-1,0;0,1];
Tr=[1,-1;i,i]/sqrt(2);

for m=1:2,
  if m==1
    alpha=[-0.75:0.5:0.75]
    beta=[-0.6:0.5:0.9]
  elseif m==2 
    alpha=[-inf,-0.6:0.5:0.4]
    beta=[-0.75:0.5:0.25,inf]
  endif
  if any(alpha>=beta)
    error("any(alpha>=beta)");
  endif
  print_polynomial(alpha,sprintf("alpha_m%d",m), ...
                   sprintf("%s_alpha_m%d_coef.m",strf,m),"%5.2f");
  print_polynomial(beta,sprintf("beta_m%d",m), ...
                   sprintf("%s_beta_m%d_coef.m",strf,m),"%5.2f");
  a=1,b=1
  for k=1:l,
    if isinf(alpha(k))
      a=conv(a,[1;0]);
    else
      a=conv(a,[1;-alpha(k)])
    endif
    if isinf(beta(k))
      b=conv(b,[-1;0]);
    else
      b=conv(b,[1;-beta(k)])
    endif
  endfor

  Tt=[-a,b]';

  Phi=Tt'*PhiR*Tt
  if ~issymmetric(Phi,'skew')
    error("~issymmetric(Phi,'skew')");
  endif
  if ~ishermitian(Phi)
    error("~ishermitian(Phi)");
  endif

  Psi=Tt'*PsiR*Tt
  if ~issymmetric(Psi)
    error("~issymmetric(Psi)");
  endif

  syms r11 r12 r13 r14 r22 r23 r24 r33 r34 r44
  R=[r11,r12,r13,r14; ...
     r12,r22,r23,r24; ...
     r13,r23,r33,r34; ...
     r14,r24,r34,r44]
  (Jl'*kron(R,PhiR)*Jl)
  
  rr11=imag(Phi(1,2));
  rr12=imag(Phi(1,4));
  rr13=imag(Phi(1,3));
  rr14=imag(Phi(1,5));
  rr24=imag(Phi(3,5));
  rr34=imag(Phi(2,5));
  rr44=imag(Phi(4,5));
  rr22=imag(Phi(3,4))+rr34;
  rr23=imag(Phi(2,4))+rr14;
  rr33=imag(Phi(2,3))+rr12;

  RR=[rr11,rr12,rr13,rr14; ...
      rr12,rr22,rr23,rr24; ...
      rr13,rr23,rr33,rr34; ...
      rr14,rr24,rr34,rr44]
  
  if max(max(abs((Jl'*kron(RR,PhiR)*Jl)-Phi)))>eps
    error("max(max(abs((Jl'*kron(RR,PhiR)*Jl)-Phi)))>eps")
  endif

  % Check Lambda
  s=(0:0.02:1);
  Phi_s=zeros(length(s),l);
  Psi_s=zeros(length(s),l);
  for k=1:length(s),
    lambda=alpha+((beta-alpha)*s(k));  
    for kk=1:l,
      L=(lambda(kk)).^((l:-1:0)');
      Phi_s(k,kk)=L'*Phi*L;
      Psi_s(k,kk)=L'*Psi*L;
    endfor
  endfor
  if any(any(abs(Phi_s)>eps))
    error("any(any(abs(Phi_s)>eps))");
  endif
  if any(any(Psi_s<-eps))
    error("any(any(Psi_s<-eps))");
  endif
  % Check region outside union
  Phi_sf=zeros(length(s),l-1);
  Psi_sf=zeros(length(s),l-1);
  for k=1:length(s),
    lambda=beta(1:(l-1))+((alpha(2:l)-beta(1:(l-1)))*s(k));
    for kk=1:l-1,
      L=(lambda(kk)*i).^((l:-1:0)');
      Phi_sf(k,kk)=L'*Phi*L;
      Psi_sf(k,kk)=L'*Psi*L;
    endfor
  endfor
  
  % Test assumption 1
  Phir=Tr'*Phi0*Tr;
  Psir=Tr'*Psi0*Tr;
  T=Tr*Tt;
  s=(-1:0.02:1)*i;
  rl=zeros(l,length(s));
  for k=1:length(s),
    rlk=roots(([1,0]*T)-s(k)*([0 1]*T));
    rl(:,k)=[zeros(l-length(rlk),1);rlk];
  endfor
  if max(max(abs(imag(rl))))>eps
    error("max(max(abs(imag(rl))))>eps")
  endif
  mt=['+','o','x','s'];
  plot(imag(s),rl(1,:),mt(1),imag(s),rl(2,:),mt(2), ...
       imag(s),rl(3,:),mt(3),imag(s),rl(4,:),mt(4));
  axis([-1 1 -2 2])
  ylabel("Real part of roots")
  xlabel("Imaginary part of s")
  legend(sprintf("%g to %g",alpha(1),beta(1)), ...
         sprintf("%g to %g",alpha(2),beta(2)), ...
         sprintf("%g to %g",alpha(3),beta(3)), ...
         sprintf("%g to %g",alpha(4),beta(4)));
  legend("location","southeast");
  legend("boxoff");
  legend("left");
  print(sprintf("%s_Assumption1_m%d",strf,m),"-dpdflatex");
%  print(sprintf("%s_Assumption1_m%d",strf,m),"-dsvg");
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Section 3.1 : Example 1 , mapping from the imaginary to real axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
strf="kyp_complex_curve_union_test";
m=3;
l=2
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)]
PhiR=[0,i;-i,0];
PsiR=[0,1;1,0];
Phi0=[0,1;1,0];
Psi0=[-1,0;0,1];
M=[-j,0; 0,1];
Tr=[1,-1;i,i]/sqrt(2);
% Intervals on the imaginary axis
alpha=[0.1, 0.3];
beta=[0.2, 0.5];
if any(alpha>=beta)
  error("any(alpha>=beta)");
endif
print_polynomial(alpha,sprintf("alpha_m%d",m), ...
                 sprintf("%s_alpha_m%d_coef.m",strf,m),"%5.2f");
print_polynomial(beta,sprintf("beta_m%d",m), ...
                 sprintf("%s_beta_m%d_coef.m",strf,m),"%5.2f");

syms alpha1 alpha2 beta1 beta2 real
Tt=[-1,  j*alpha1+j*alpha2,  alpha1*alpha2; ...
     1, -j*beta1-j*beta2,   -beta1*beta2];
expand(Tt'*PhiR*Tt)

syms r11 r12 r22 
R=[r11,r12; ...
   conj(r12),r22];
expand(Jl'*kron(M'*PhiR*M,R)*Jl)

Rr=[beta1+beta2-alpha1-alpha2, alpha1*alpha2-beta1*beta2; ...
    alpha1*alpha2-beta1*beta2, ...
    beta1*beta2*(alpha1+alpha2)-alpha1*alpha2*(beta1+beta2)];
expand(M'*Rr*M)

Tt=[-1,  j*sum(alpha),  prod(alpha); ...
     1, -j*sum(beta),  -prod(beta)];

Phi=Tt'*PhiR*Tt
if ~ishermitian(Phi)
  error("~ishermitian(Phi)");
endif

Psi=Tt'*PsiR*Tt
if ~ishermitian(Psi)
  error("~ishermitian(Psi)");
endif

R=M'*[sum(beta)-sum(alpha),   prod(alpha)-prod(beta); ...
      prod(alpha)-prod(beta), (prod(beta)*sum(alpha))-(prod(alpha)*sum(beta))]*M;
if ~ishermitian(R)
  error("~ishermitian(R)");
endif
if max(max(abs((Jl'*kron(M'*PhiR*M,R)*Jl)-Phi)))>eps
  error("max(max(abs((Jl'*kron(M'*PhiR*M,R)*Jl)-Phi)))>eps")
endif

RR=[-Phi(1,2),     -Phi(1,3); ...
   conj(-Phi(1,3)),-Phi(2,3)];
if max(max(abs((Jl'*kron(M'*PhiR*M,RR)*Jl)-Phi)))>eps
  error("max(max(abs((Jl'*kron(M'*PhiR*M,RR)*Jl)-Phi)))>eps")
endif

% Check Lambda
s=(0:0.02:1);
Phi_s=zeros(length(s),l);
Psi_s=zeros(length(s),l);
for k=1:length(s),
  lambda=alpha+((beta-alpha)*s(k));  
  for kk=1:l,
    L=(lambda(kk)*i).^((l:-1:0)');
    Phi_s(k,kk)=L'*Phi*L;
    Psi_s(k,kk)=L'*Psi*L;
  endfor
endfor
if any(any(abs(Phi_s)>eps))
  error("any(any(abs(Phi_s)>eps))");
endif
if any(any(Psi_s<-eps))
  error("any(any(Psi_s<-eps))");
endif
% Check region outside union
Phi_sf=zeros(length(s),1);
Psi_sf=zeros(length(s),1);
for k=1:length(s),
  lambda=beta(1)+((alpha(2)-beta(1))*s(k));  
  L=(lambda*i).^((l:-1:0)');
  Phi_sf(k)=L'*Phi*L;
  Psi_sf(k)=L'*Psi*L;
endfor
  
% Test assumption 1
T=Tr*Tt;
s=(-1:0.02:1)*i;
rl=zeros(l,length(s));
for k=1:length(s),
  rlk=roots(([1,0]*T)-s(k)*([0 1]*T));
  rl(:,k)=[zeros(l-length(rlk),1);rlk];
endfor
if max(max(abs(real(rl))))>eps
  error("max(max(abs(real(rl))))>eps")
endif
mt=['+','o'];
plot(imag(s),imag(rl(1,:)),mt(1),imag(s),imag(rl(2,:)),mt(2));
axis([-1 1 0 0.5])
ylabel("Imaginary part of roots")
xlabel("Imaginary part of s")
legend(sprintf("%g to %g",alpha(2),beta(2)), ...
       sprintf("%g to %g",alpha(1),beta(1)));
legend("location","southeast");
legend("boxoff");
legend("left");
print(sprintf("%s_Assumption1_m%d",strf,m),"-dpdflatex");
% print(sprintf("%s_Assumption1_m%d",strf,m),"-dsvg");
%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Section 3.1 : Example 2 , mapping from a circle to the real axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
strf="kyp_complex_curve_union_test";
m=4;
l=2
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)]
PhiR=[0,i;-i,0];
PsiR=[0,1;1,0];
Phi0=[0,1;1,0];
Psi0=[-1,0;0,1];
Tr=[1,-1;i,i]/sqrt(2);
% Intervals on the unit circle
eta=[0, 0.35];
zeta=[0.05, 0.5];
print_polynomial(eta,sprintf("eta_m%d",m), ...
                 sprintf("%s_eta_m%d_coef.m",strf,m),"%5.2f");
print_polynomial(zeta,sprintf("zeta_m%d",m), ...
                 sprintf("%s_zeta_m%d_coef.m",strf,m),"%5.2f");

% Ref 2, Equation 11
syms a2 a1 a0 b2 b1 b0
T=[-a2,-a1,-a0; ...
    b2, b1, b0];
Phi=T'*PhiR*T
Psi=T'*PsiR*T

% After Mobius transform from the circle to the real axis
z=e.^[0.15,0.2,0.25];
alpha=real(((e.^(j*zeta)-z(1))./(e.^(j*zeta)-z(3)))*(z(2)-z(3))/(z(2)-z(1)));
beta=real(((e.^(j*eta)-z(1))./(e.^(j*eta)-z(3)))*(z(2)-z(3))/(z(2)-z(1)));
if any(alpha>=beta)
  error("any(alpha>=beta)");
endif

Tt=[-conv([1,-alpha(1)],[1,-alpha(2)]);conv([1,-beta(1)],[1,-beta(2)])];
Phih=Tt'*PhiR*Tt;
Psih=Tt'*PsiR*Tt;
syms rr11 rr12 rr22 
RRh=[rr11,rr12; ...
   conj(rr12),rr22];
(Jl'*kron(PhiR,RRh)*Jl)
r11=Phih(1,2)/j;
r12=Phih(1,3)/j;
r22=Phih(2,3)/j;
Rh=[r11,r12; ...
    conj(r12),r22];
if max(max(abs((Jl'*kron(PhiR,Rh)*Jl)-Phih)))>eps
  error("max(max(abs((Jl'*kron(PhiR,Rh)*Jl)-Phih)))>eps");
endif


M=[z(2)-z(3), -z(1)*(z(2)-z(3)); ...
   z(2)-z(1), -z(3)*(z(2)-z(1))];
Ml=[conv(M(1,:),M(1,:)); ...
    conv(M(1,:),M(2,:)); ...
    conv(M(2,:),M(2,:))];

Phi=Ml'*Phih*Ml;
Psi=Ml'*Psih*Ml;
R=M'*Rh*M;
(Jl'*kron(PhiR,R)*Jl)

Tt=[-1,  e^(j*eta(1))+e^(j*eta(2)),   -e^(j*sum(eta)); ...
     1, -e^(j*zeta(1))+e^(j*zeta(2)),  e^(j*sum(zeta))];
c=(1+j*alpha(1))*(1+j*alpha(2))*(1-j*beta(1))*(1-j*beta(2));

Phi=Tt'*[0,j*c;-j*conj(c),0]*Tt
if ~ishermitian(Phi)
  error("~ishermitian(Phi)");
endif

Psi=Tt'*[0,c;conj(c),0]*Tt
if ~ishermitian(Psi)
  error("~ishermitian(Psi)");
endif

M=[-j,j; ...
    1,1];
R=M'*[sum(beta)-sum(alpha),   prod(alpha)-prod(beta); ...
      prod(alpha)-prod(beta), (prod(beta)*sum(alpha))-(prod(alpha)*sum(beta))]*M;
if ~ishermitian(R)
  error("~ishermitian(R)");
endif
if max(max(abs((Jl'*kron(M'*PhiR*M,R)*Jl)-Phi)))>eps
  error("max(max(abs((Jl'*kron(M'*PhiR*M,R)*Jl)-Phi)))>eps")
endif

syms r11 r12 r22 
R=[r11,r12; ...
   conj(r12),r22];
(Jl'*kron(M'*PhiR*M,R)*Jl)

rr11=-Phi(1,1)/2;
rr12=-Phi(1,2)/2;
rr22=Phi(3,3)/2;

RR=[rr11,rr12; ...
   conj(rr12),rr22];

if max(max(abs((Jl'*kron(M'*PhiR*M,RR)*Jl)-Phi)))>eps
  error("max(max(abs((Jl'*kron(RR,PhiR)*Jl)-Phi)))>eps")
endif

% Test assumption 1
Phir=Tr'*Phi0*Tr;
Psir=Tr'*Psi0*Tr;
T=Tr*Tt;
s=(-1:0.02:1)*i;
rl=zeros(l,length(s));
for k=1:length(s),
  rlk=roots(([1,0]*T)-s(k)*([0 1]*T));
  rl(:,k)=[zeros(l-length(rlk),1);rlk];
endfor
if max(max(abs(real(rl))))>eps
  error("max(max(abs(real(rl))))>eps")
endif
mt=['+','o'];
plot(imag(s),imag(rl(1,:)),mt(1),imag(s),imag(rl(2,:)),mt(2));
axis([-1 1 0 0.5])
ylabel("Imaginary part of roots")
xlabel("Imaginary part of s")
legend(sprintf("%g to %g",eta(2),zeta(2)), ...
       sprintf("%g to %g",eta(1),zeta(1)));
legend("location","southeast");
legend("boxoff");
legend("left");
print(sprintf("%s_Assumption1_m%d",strf,m),"-dsvg");
print(sprintf("%s_Assumption1_m%d",strf,m),"-dpdflatex");
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Done
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diary off
movefile kyp_complex_curve_union_test.diary.tmp ...
         kyp_complex_curve_union_test.diary;
