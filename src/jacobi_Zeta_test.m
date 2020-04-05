% jacobi_Zeta_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("jacobi_Zeta_test.diary");
delete("jacobi_Zeta_test.diary.tmp");
diary jacobi_Zeta_test.diary.tmp

% Compare jacobi_Zeta.m and jacobi_Zeta_alt.m 
tol=40*eps;
x=(-5:0.1:5)';
k=0.1:0.1:0.9;
Z=zeros(length(x),length(k));
Zalt=zeros(length(x),length(k));
for m=1:length(x),
  for n=1:length(k),
    Z(m,n)=jacobi_Zeta(x(m),k(n));
    Zalt(m,n)=jacobi_Zeta_alt(x(m),k(n));
    if abs(Z(m,n)-Zalt(m,n))>tol
      error("abs(Z(%d,%d)(%g)-Zalt(%d,%d))(%g)>tol", ...
            m,n,Z(m,n),m,n,abs(Z(m,n)-Zalt(m,n)));
    endif
  endfor
endfor

%{ 
  % JacobiZeta.txt was created by the JacobiZeta function in
  % elfun18v1_3 (https://github.com/ElsevierSoftwareX/SOFTX_2018_246)
  x=-1:0.1:1;
  k=0.1:0.1:0.9;
  zeta=zeros(length(x),length(k));
  for m=1:length(x),
    for n=1:length(k),
      zeta(m,n)=JacobiZeta(x(m),k(n));
    endfor
  endfor
  save -ascii -double JacobiZeta.txt zeta
%}

load JacobiZeta.txt

tol=100*eps;
x=(-5:0.1:5)';
k=0.1:0.1:0.9;
for n=1:length(k);
  Z=jacobi_Zeta(x,k(n));
  if max(abs(Z-JacobiZeta(:,n)))>tol
    error("max(abs(Z-JacobiZeta(_,%d)))(%g)>tol",n,max(abs(Z-JacobiZeta(:,n))));
  endif
endfor

%{ 
  % jacobi_zeta_boost.txt was created by the boost::math::jacobi_zeta function:
  #include <cstdio>
  #include <boost/math/special_functions/jacobi_zeta.hpp>
  #include <boost/math/special_functions/jacobi_elliptic.hpp>
  int main(void)
  {
    for (double x=-10;x<=10;x++)
      {
        for (double k=1;k<=9;k++)
          {
             double phi=asin(boost::math::jacobi_sn(k/10,x/10));
             double tmp=boost::math::jacobi_zeta(k/10,phi);
             printf(" %23.16e",tmp);
          }
        printf("\n");
      }
  }
%}

load jacobi_zeta_boost.txt
tol=10*eps;
x=(-1:0.1:1)';
k=0.1:0.1:0.9;
for n=1:length(k),
    Z=jacobi_Zeta(x,k(n));
  if max(abs(Z-jacobi_zeta_boost(:,n)))>tol
    error("max(abs(Z-jacobi_zeta_boost(_,%d))(%g)>tol", ...
          n,max(abs(Z-jacobi_zeta_boost(:,n))));
  endif
endfor

% Reproduce Figure 22.16.3 of https://dlmf.nist.gov/22.16
k=[0.4 0.7 0.99 0.999999];
nf=1000;
jz=zeros(nf,length(k));
x=10*pi*(1:nf)'/nf;
for n=1:length(k),
  jz(:,n)=jacobi_Zeta(x,k(n));
endfor
plot(x/pi,jz(:,1),":",x/pi,jz(:,2),"-.",x/pi,jz(:,3),"--",x/pi,jz(:,4),"-")
axis([0 10 -0.8 0.8])
grid("on");
title("Jacobi's Zeta function, Z(x,k) (DLMF Figure 22.16.3)");
xlabel("x/$\\pi$")
legend(sprintf("k=%3.1f",k(1)),sprintf("k=%3.1f",k(2)), ...
       sprintf("k=%4.2f",k(3)),sprintf("k=%8.6f",k(4)));
legend("boxoff")
legend("location","southwest")
print("jacobi_Zeta_test_DLMF_Figure_22_16_3","-dpdflatex");
close

% Done
diary off
movefile jacobi_Zeta_test.diary.tmp jacobi_Zeta_test.diary;
