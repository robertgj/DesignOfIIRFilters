% kyp_complex_curve_union_test.m
% Copyright (C) 2021-2025 Robert G. Jenssen
%
% See: Section 3 of "Generalizing the KYP Lemma to multiple frequency
% intervals", G. Pipeleers, T. Iwasaki, S. Hara, SIAM J. Control. Optim.,
% Vol. 52, No. 6, pp. 3618-3638

test_common;

strf="kyp_complex_curve_union_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

pkg load symbolic

tol=20*eps;

PhiR=[0,i;-i,0];
PsiR=[0,1;1,0];
Phi0=[0,1;1,0];
Psi0=[-1,0;0,1];
Tr=[1,-1;i,i]/sqrt(2);
Phir=Tr'*Phi0*Tr;
if max(max(abs(Phir-PhiR)))>tol
  error("max(max(abs(Phir-PhiR)))>tol");
endif
Psir=Tr'*Psi0*Tr;
if max(max(abs(Psir-PsiR)))>tol
  error("max(max(abs(Psir-PsiR)))>tol");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Section 3.1 : Example of mapping from the imaginary to the real axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
l=4;
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)];

for m=1:2,
  if m==1
    alpha=[-0.75:0.5:0.75];
    beta=[-0.6:0.5:0.9];
  elseif m==2 
    alpha=[-inf,-0.6:0.5:0.4];
    beta=[-0.75:0.5:0.25,inf];
  endif
  if any(alpha>=beta)
    error("any(alpha>=beta)");
  endif
  print_polynomial(alpha,sprintf("alpha_m%d",m), ...
                   sprintf("%s_1_alpha_m%d_coef.m",strf,m),"%5.2f");
  print_polynomial(beta,sprintf("beta_m%d",m), ...
                   sprintf("%s_1_beta_m%d_coef.m",strf,m),"%5.2f");
  a=1;b=1;
  for k=1:l,
    if isinf(alpha(k))
      a=conv(a,[0;1]);
    else
      a=conv(a,[1;-alpha(k)]);
    endif
    if isinf(beta(k))
      b=conv(b,[0;-1]);
    else
      b=conv(b,[1;-beta(k)]);
    endif
  endfor

  % T~
  Tt=[-a,b]';

  Psi=Tt'*PsiR*Tt;
  if ~issymmetric(Psi)
    error("~issymmetric(Psi)");
  endif

  Phi=Tt'*PhiR*Tt;
  if ~issymmetric(Phi,"skew")
    error("~issymmetric(Phi,\"skew\")");
  endif

  syms r11 r12 r13 r14 r22 r23 r24 r33 r34 r44
  R=[r11,r12,r13,r14; ...
     r12,r22,r23,r24; ...
     r13,r23,r33,r34; ...
     r14,r24,r34,r44]; 
  PhialtR=(Jl'*kron(PhiR,R)*Jl);
  
  rr11=imag(Phi(1,2));
  rr12=imag(Phi(1,3));
  rr13=imag(Phi(1,4));
  rr14=imag(Phi(1,5));
  rr22=imag(Phi(2,3))+rr13;
  rr23=imag(Phi(2,4))+rr14;
  rr24=imag(Phi(2,5));
  rr33=imag(Phi(3,4))+rr24;
  rr34=imag(Phi(3,5));
  rr44=imag(Phi(4,5));

  RR=[rr11,rr12,rr13,rr14; ...
      rr12,rr22,rr23,rr24; ...
      rr13,rr23,rr33,rr34; ...
      rr14,rr24,rr34,rr44];
  
  if max(max(abs((Jl'*kron(PhiR,RR)*Jl)-Phi)))>tol
    error("max(max(abs((Jl'*kron(PhiR,RR)*Jl)-Phi)))>tol")
  endif

  % Sanity check
  % Test assumption 1
  w=(-1:0.02:1);
  T=Tr*Tt;
  rl=zeros(l,length(w));
  for k=1:length(w),
    rlk=roots(([1,0]*T)-w(k)*i*([0 1]*T));
    rl(:,k)=[zeros(l-length(rlk),1);rlk];
  endfor
  if max(max(abs(imag(rl))))>tol
    error("max(max(abs(imag(rl))))>tol")
  endif
  plot(w,real(rl(1,:)),"+k",w,real(rl(2,:)),"+k",
       w,real(rl(3,:)),"+k",w,real(rl(4,:)),"+k");
  axis([-1 1 -2 2])
  ylabel("Real part of roots")
  xlabel("Imaginary part of s")
  grid("on");
  print(sprintf("%s_1_root_locus_m%d",strf,m),"-dpdflatex");
  close
endfor

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Section 3.1 : Example 1, mapping from the imaginary to the real axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear alpha1 alpha2 beta1 beta2 w
syms alpha1 alpha2 beta1 beta2 real

l=2;
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)];
% Moebius transform of the imaginary to the real axis [mu(lambda)=-i*lambda]
M=[-i,0;0,1];
% Mapping from a union of two segments of the imaginary axis to the real axis
a=[1;-i*alpha1-i*alpha2;-alpha1*alpha2];
b=[1;-i*beta1-i*beta2;  -beta1*beta2];
Tt=[-a,b].';
Phi=expand(Tt'*PhiR*Tt);
Psi=expand(Tt'*PsiR*Tt);
RR=[beta1+beta2-alpha1-alpha2, alpha1*alpha2-beta1*beta2; ...
    alpha1*alpha2-beta1*beta2, beta1*beta2*(alpha1+alpha2)-...
                               alpha1*alpha2*(beta1+beta2)];
R=M'*RR*M;
syms rr11 rr12 rr21 rr22 real
Phialt=Jl'*kron(M'*PhiR*M,[rr11,rr12;rr21,rr22])*Jl;
PhialtR=expand(Jl'*kron(M'*PhiR*M,R)*Jl);
if max(max(abs(Phi-PhialtR))) > 0
  error("max(max(abs(Phi-PhialtR))) > 0");
endif

% Alternative mapping with the result of Lemma 3.1 applied to the
% image of the Moebius transform.

% First calculate (PhiH,PsiH), where H implies "\hat", a mapping from the
% segment of the imaginary axis, i*[-1,1], to two segments of the real axis.
TtH=[-[1;-alpha1-alpha2;alpha1*alpha2], ...
      [1;-beta1-beta2  ;beta1*beta2]].';
PhiH=TtH'*PhiR*TtH;
PsiH=TtH'*PsiR*TtH;
PhialtH=Jl'*kron(PhiR,[rr11,rr12;rr21,rr22])*Jl;
RH=expand([-i*PhiH(1,2), -i*PhiH(1,3); i*PhiH(3,1), i*PhiH(3,2)]);
if max(max(abs(RH-RR))) > 0
  error("max(max(abs(RH-RR))) > 0");
endif

% Now apply the Moebius transform to (PhiH,PsiH)
M1=M(1,:);
M2=M(2,:);
Ml=[conv(M1,M1);conv(M1,M2);conv(M2,M2)];
PhialtM=expand(Ml'*PhiH*Ml);
if max(max(abs(expand(PhialtM-Phi)))) > 0
  error("max(max(abs(expand(PhialtM-Phi)))) > 0");
endif
PsialtM=expand(Ml'*PsiH*Ml);
if max(max(abs(expand(PsialtM-Psi)))) > 0
  error("max(max(abs(expand(PsialtM-Psi)))) > 0");
endif
RaltM=expand(M'*RH*M);
if max(max(abs(expand(RaltM-R)))) > 0
  error("max(max(abs(expand(RaltM-R)))) > 0");
endif

% Sanity check
syms w real
% This should be zero
Ll=[w^2;-i*w;1];
if abs(Ll'*Phi*Ll)>0
  error("abs(Ll'*Phi*Ll)>0");
endif
%{
if eval(Ll'*Psi*Ll)<0
  error("eval(Ll'*Psi*Ll)<0");
endif
%}

% This should be positive when alpha1<w<beta1<alpha2<beta2 or
% alpha1<beta1<alpha2<w<beta2
factor([-w^2,-i*w,1]*Psi*[-w^2; i*w;1])

% Test assumption 1
alpha1=-0.75;alpha2=-0.25;beta1=-0.5;beta2=0.25;
print_polynomial([alpha1,alpha2],"alpha",strcat(strf,"_2_alpha_coef.m"),"%5.2f");
print_polynomial([beta1, beta2], "beta", strcat(strf,"_2_beta_coef.m"), "%5.2f");
T=Tr*([-[1;-alpha1-alpha2;alpha1*alpha2], ...
        [1;-beta1-beta2;beta1*beta2]].');

w=(-1:0.02:1);
rl=zeros(l,length(w));
for k=1:length(w),
  rlk=roots(([1,0]*T)-w(k)*i*([0, 1]*T));
  rl(:,k)=[zeros(l-length(rlk),1);rlk];
endfor
if max(max(abs(imag(rl))))>eps
  error("max(max(abs(imag(rl))))>eps")
endif
plot(w,real(rl(1,:)),"+k",w,real(rl(2,:)),"+k");
axis([-1 1 -2 2]);
ylabel("Real part of roots");
xlabel("Imaginary part of s");
grid("on");
print(sprintf("%s_2_root_locus_real",strf),"-dpdflatex");
close

T=Tr*([-[1;-i*alpha1-i*alpha2;-alpha1*alpha2], ...
        [1;-i*beta1-i*beta2;-beta1*beta2]].');
w=(-1:0.02:1);
rl=zeros(l,length(w));
for k=1:length(w),
  rlk=roots(([1,0]*T)-w(k)*i*([0, 1]*T));
  rl(:,k)=[zeros(l-length(rlk),1);rlk];
endfor
if max(max(abs(real(rl))))>eps
  error("max(max(abs(real(rl))))>eps")
endif
plot(w,imag(rl(1,:)),"+k",w,imag(rl(2,:)),"+k");
axis([-1 1 -2 2]);
ylabel("Imaginary part of roots");
xlabel("Imaginary part of s");
grid("on");
print(sprintf("%s_2_root_locus_imag",strf),"-dpdflatex");
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Section 3.1 : Example 2, mapping from a circle to the real axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear eta1 eta2 zeta1 zeta2 w
syms eta1 eta2 zeta1 zeta2 real
syms alpha1 alpha2 beta1 beta2 real

l=2;
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)];

% Moebius transform of the unit circle to the real axis
z1=1;z2=i;z3=-1;
% After simplifying
M=[-i,i;1,1];

% Mapping from a union of two segments of the unit circle to the real axis
a=[ 1;-e^(i*eta1)-e^(i*eta2);   e^(i*eta1)*e^(i*eta2)];
b=[ 1;-e^(i*zeta1)-e^(i*zeta2); e^(i*zeta1)*e^(i*zeta2)];
Tt=[-a,b].';
% Apply Mobius transform to eta1,...
% M is equivalent to mu(lambda)=tan(theta/2)
alpha1=tan(eta1/2);
alpha2=tan(eta2/2);
beta1=tan(zeta1/2);
beta2=tan(zeta2/2);
c=(1+i*alpha1)*(1+i*alpha2)*(1-i*beta1)*(1-i*beta2);
Phic=[0,i*c;-i*c',0];
Psic=[0,c;c',0];
Phi=expand(Tt'*Phic*Tt);
Psi=expand(Tt'*Psic*Tt);

RR=[beta1+beta2-alpha1-alpha2, alpha1*alpha2-beta1*beta2; ...
    alpha1*alpha2-beta1*beta2, beta1*beta2*(alpha1+alpha2)-...
                               alpha1*alpha2*(beta1+beta2)];
R=M'*RR*M;
PhialtR=expand(Jl'*kron(M'*PhiR*M,R)*Jl);

% Alternative mapping with the result of Lemma 3.1 applied to the
% image of the Moebius transform.

% First calculate (PhiH,PsiH), where H implies "\hat", a mapping from the
% segment of the imaginary axis, i*[-1,1], to two segments of the real axis.
a=[1;-alpha1-alpha2;alpha1*alpha2];
b=[1;-beta1-beta2  ;beta1*beta2];
TtH=[-a,b].';
PhiH=TtH'*PhiR*TtH;
PsiH=TtH'*PsiR*TtH;

% Now apply the Moebius transform to (PhiH,PsiH)
M1=M(1,:);
M2=M(2,:);
Ml=[conv(M1,M1);conv(M1,M2);conv(M2,M2)];
PhialtM=expand(Ml'*PhiH*Ml);
PsialtM=expand(Ml'*PsiH*Ml);

% Sanity check
syms w real
% This should be zero
Ll=[e^(i*2*w);e^(i*w);1];
if abs(Ll'*Phi*Ll)>0
  error("abs(Ll'*Phi*Ll)>0");
endif
%{
if eval(Ll'*Psi*Ll)<0
  error("eval(Ll'*Psi*Ll)<0");
endif
%}

% Sanity checks
eta1=0.1;
eta2=0.35;
zeta1=0.15;
zeta2=0.45;
print_polynomial([eta1,  eta2],  "eta",  strcat(strf,"_3_eta_coef.m"),  "%5.2f");
print_polynomial([zeta1, zeta2], "zeta", strcat(strf,"_3_zeta_coef.m"), "%5.2f");

if max(max(abs(eval(Phi)-eval(PhialtM)))) > tol
  error("max(max(abs(eval(Phi)-eval(PhialtM)))) > tol");
endif
if max(max(abs(eval(Phi)-eval(PhialtR)))) > tol
  error("max(max(abs(eval(Phi)-eval(PhialtR)))) > tol");
endif
if max(max(abs(eval(Psi)-eval(PsialtM)))) > tol
  error("max(max(abs(eval(Psi)-eval(PsialtM)))) > tol");
endif

% Test assumption 1
T=Tr*eval(Tt);
w=(-1:0.02:1);
rl=zeros(l,length(w));
for k=1:length(w),
  rlk=roots(([1,0]*T)-w(k)*i*([0 1]*T));
  if max(abs(rlk)-1)>tol
    error("max(abs(rlk)-1)>tol");
  endif
  rl(:,k)=[zeros(l-length(rlk),1);arg(rlk)];
endfor
plot(w,rl(1,:),"+k",w,rl(2,:),"+k");
axis([-1 1 0 0.5]);
ylabel("Angle of roots (rad.)");
xlabel("Imaginary part of s");
grid("on");
print(sprintf("%s_3_root_locus",strf),"-dpdflatex");
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Section 3.1 : Another example of mapping from a circle to the real axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eta1=0.1;
eta2=1;
zeta1=0.15;
zeta2=pi;
print_polynomial([eta1,  eta2],  "eta",  strcat(strf,"_4_eta_coef.m"),  "%5.2f");
print_polynomial([zeta1, zeta2], "zeta", strcat(strf,"_4_zeta_coef.m"), "%5.2f");

clear alpha1 alpha2 beta1 beta2 w
syms alpha1 alpha2 beta1 real

l=2;
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)];

% Moebius transform of the unit circle to the real axis
z1=1;z2=i;z3=-i;
M=[z2-z3,z2-z1;-z1*(z2-z3),-z3*(z2-z1)];

% Alternative mapping with the result of Lemma 3.1 applied to the
% image of the Moebius transform.
syms a b Tth
a=[1;-alpha1-alpha2;alpha1*alpha2];
b=[0; -1;  beta1];
TtH=[-a,b].';

% Calculate (PhiH,PsiH), where H implies "\hat", a mapping from the
% segment of the imaginary axis, i*[-1,1], to two segments of the real axis.
PhiH=TtH'*PhiR*TtH;
PsiH=TtH'*PsiR*TtH;

syms rr11 rr12 rr21 rr22
PhiHaltR=Jl'*kron(PhiR,[rr11,rr12;rr21,rr22])*Jl;
RH=[-i*PhiH(1,2), -i*PhiH(1,3); i*PhiH(3,1), i*PhiH(3,2)];

% Now apply the Moebius transform to (PhiH,PsiH)
M1=M(1,:);
M2=M(2,:);
Ml=[conv(M1,M1);conv(M1,M2);conv(M2,M2)];
Phi=expand(Ml'*PhiH*Ml);
Psi=expand(Ml'*PsiH*Ml);
R=expand(M'*RH*M);
PhialtR=expand(Jl'*kron(M'*PhiR*M,R)*Jl);
if max(max(abs(Phi-PhialtR))) > 0
  error("max(max(abs(Phi-PhialtR))) > 0");
endif

% Sanity check
syms w real
% This should be zero
Ll=[e^(i*2*w);e^(i*w);1];
if abs(Ll'*Phi*Ll)>0
  error("abs(Ll'*Phi*Ll)>0");
endif
%{
if eval(Ll'*Psi*Ll)<0
  error("eval(Ll'*Psi*Ll)<0");
endif
%}

% Sanity checks
% Test assumption 1
a=[ 1;-e^(i*eta1)-e^(i*eta2);   e^(i*eta1)*e^(i*eta2)];
b=[ 1;-e^(i*zeta1)-e^(i*zeta2); e^(i*zeta1)*e^(i*zeta2)];
Tt=[-a,b].';
T=Tr*Tt;
w=(-1:0.02:1);
rl=zeros(l,length(w));
for k=1:length(w),
  rlk=roots(([1,0]*T)-w(k)*i*([0 1]*T));
  if max(abs(rlk)-1)>tol
    error("max(abs(rlk)-1)>tol");
  endif
  rl(:,k)=[zeros(l-length(rlk),1);arg(rlk)];
endfor
plot(w,rl(1,:),"+k",w,rl(2,:),"+k");
axis([-1 1 0 pi]);
ylabel("Angle of roots (rad.)");
xlabel("Imaginary part of s");
grid("on");
print(sprintf("%s_4_root_locus",strf),"-dpdflatex");
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Section 3.1 : Yet another example of mapping from a circle to the real axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eta1=-pi;
eta2=-0.5;
eta3=pi-1;
zeta1=-eta3;
zeta2=-eta2;
zeta3=-eta1;
print_polynomial([eta1,eta2,eta2],"eta",strcat(strf,"_5_eta_coef.m"),"%5.2f");
print_polynomial([zeta1,zeta2, zeta3],"zeta", ...
                 strcat(strf,"_5_zeta_coef.m"),"%5.2f");

clear alpha1 alpha2 beta1 beta2 w
syms alpha2 alpha3 beta1 beta2 real

l=3;
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)];

% Moebius transform of the unit circle to the real axis
z1=1;z2=i;z3=-i;
M=[z2-z3,z2-z1;-z1*(z2-z3),-z3*(z2-z1)];

% Alternative mapping with the result of Lemma 3.1 applied to the
% image of the Moebius transform.

% Mapping from a union of two segments of the unit circle to the real axis
alpha1=-inf;
beta3=inf;
a= [1;-alpha2-alpha3;alpha2*alpha3];
b=-[1;-beta1-beta2;beta1*beta2];
TtH=[-a,b].';

% Calculate (PhiH,PsiH), where H implies "\hat", a mapping from the
% segment of the imaginary axis, i*[-1,1], to two segments of the real axis.
PhiH=TtH'*PhiR*TtH;
PsiH=TtH'*PsiR*TtH;
syms rr11 rr12 rr21 rr22 real
Jlm1=[eye(l-1),zeros(l-1,1);zeros(l-1,1),eye(l-1)];
PhialtH=Jlm1'*kron(PhiR,[rr11,rr12;rr21,rr22])*Jlm1;
RH=[-i*PhiH(1,2), -i*PhiH(1,3); ...
     i*PhiH(3,1),  i*PhiH(3,2)];
R=expand(M'*RH*M);
PhialtR=expand(Jlm1'*kron(M'*PhiR*M,R)*Jlm1);

% Now apply the Moebius transform to (PhiH,PsiH)
M1=M(1,:);
M2=M(2,:);
Ml=[conv(M1,M1);conv(M1,M2);conv(M2,M2)];
Phi=expand(Ml'*PhiH*Ml);
Psi=expand(Ml'*PsiH*Ml);

% Sanity check
if max(max(abs(Phi-PhialtR))) > 0
  error("max(max(abs(Phi-PhialtR))) > 0");
endif
syms w real
% This should be zero
Ll=[e^(i*2*w);e^(i*w);1];
if abs(Ll'*Phi*Ll)>0
  error("abs(Ll'*Phi*Ll)>0");
endif
% This should not be less than zero
%{
if eval(Ll'*Psi*Ll)<0
  error("eval(Ll'*Psi*Ll)<0");
endif
%}

% Sanity checks
% Test assumption 1
a=conv(conv([1;-e^(i*eta1)], [1;-e^(i*eta2)]), [1;-e^(i*eta3)]);
b=conv(conv([1;-e^(i*zeta1)],[1;-e^(i*zeta2)]),[1;-e^(i*zeta3)]);
Tt=[-a,b].';
T=Tr*Tt;
w=(-1:0.02:1);
rl=zeros(l,length(w));
for k=1:length(w),
  rlk=roots(([1,0]*T)-w(k)*i*([0 1]*T));
  if max(abs(rlk)-1)>tol
    error("max(abs(rlk)-1)>tol");
  endif
  rl(:,k)=[zeros(l-length(rlk),1);arg(rlk)];
endfor
for k=1:length(w),
  for q=1:l,
    if rl(q,k)<(-pi+tol)
      rl(q,k)=-rl(q,k);
    endif
  endfor
endfor
plot(w,rl(1,:),"+k",w,rl(2,:),"+k",w,rl(3,:),"+k");
axis([-1 1 -pi pi]);
ylabel("Angle of roots (rad.)");
xlabel("Imaginary part of s");
grid("on");
print(sprintf("%s_5_root_locus",strf),"-dpdflatex");
close

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Done
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
