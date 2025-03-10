% elliptic_Pi_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("elliptic_Pi_test.diary");
delete("elliptic_Pi_test.diary.tmp");
diary elliptic_Pi_test.diary.tmp

% Compare with the value given in Section 3 of  "Computing
% elliptic integrals by duplication", B.C.Carlson, Numerische
% Mathematik, 33:1-16, 1979
if abs(elliptic_Pi(pi/4,-0.5,1/sqrt(2))-0.7586184393)>4e-11
  error("abs(elliptic_Pi(pi/4,-0.5,1/sqrt(2))-0.7586184393)>4e-11");
endif

% Check special vales from Section 19.6(iv) of "Digital Library of
% Mathematical Functions", https://dlmf.nist.gov/19.6
tol=3*eps;
if abs(elliptic_Pi(0,0.5,1/sqrt(2)))>tol
  error("abs(elliptic_Pi(0,0.5,1/sqrt(2)))>tol");
endif
if abs(elliptic_Pi(pi/4,0,0)-(pi/4))>tol
  error("abs(elliptic_Pi(pi/4,0,0)-(pi/4))>tol");
endif
if abs(elliptic_Pi(pi/4,0,1)-elliptic_F(pi/4,1))>tol
  error("abs(elliptic_Pi(pi/4,0,1)-elliptic_F(pi/4,1))>tol");
endif
if abs(elliptic_Pi(pi/4,1,0)-tan(pi/4))>tol
  error("abs(elliptic_Pi(pi/4,1,0)-tan(pi/4))>tol");
endif
if abs(elliptic_Pi(pi/4,1,1)- ...
       ((carlson_RC(2,1)+sqrt(2))/2))>tol
  error(["abs(elliptic_Pi(pi/4,0.4,1)- ...\n", ...
 "       ((carlson_RC(2,1)-(0.4*carlson_RC(2,1.6)))/(0.6))))>tol"]);
endif
if abs(elliptic_Pi(pi/4,0.5,0)-carlson_RC(1,1.5))>tol
  error("abs(elliptic_Pi(pi/4,1,0)-carlson_RC(1,1.5))>tol");
endif
if abs(elliptic_Pi(pi/4,0.4,1)- ...
       ((carlson_RC(2,1)-(0.4*carlson_RC(2,1.6)))/(0.6)))>tol
  error(["abs(elliptic_Pi(elliptic_Pi(pi/4,0.4,1)- ...\n", ...
 "       ((carlson_RC(2,1)-(0.4*carlson_RC(2,1.6)))/(0.6))))>tol"]);
endif

% Check with integration
function y=elliptic_Pi_integrand(t,_n,_k)
  persistent n k
  persistent init_done=false
  if nargin==3
    n=_n;k=_k;
    init_done=true;
  endif
  if ~init_done
    error("Not initialised");
  endif
  y=1/(sqrt(1-((k*sin(t))^2))*(1-(n*(sin(t)^2))));
endfunction

tol=50*eps;

for p=0:0.1:0.5,
  for n=0:0.1:0.9,
    for k=0:0.1:0.9,
      phi=p*pi;
      if (n*sin(phi)*sin(phi)) >= 1.0
        continue;
      endif      
      x=elliptic_Pi(phi,n,k);
      elliptic_Pi_integrand(0,n,k);
      [q,ier,nfun,err]=quad(@elliptic_Pi_integrand, 0, phi);
      if abs(elliptic_Pi(phi,n,k)-q)>tol
        error("abs(elliptic_Pi(phi,n,k)-q)>tol,(p=%10.8f,n=%3.1f,k=%3.1f)",...
              p,n,k);
      endif
    endfor
  endfor
endfor

%{ 
  % elliptic_Pi_boost.txt was created by the boost::math::ellint_3 function:
  #include <cstdio>
  #include <boost/math/special_functions/ellint_3.hpp>
  int main(void)
  {
    double pi=4.0*atan(1.0);
    int s=0;
    for (int k=0;k<=9;k++)
      {
        for (int n=0;n<=9;n++)
          {
          for (int x=0;x<=5;x++)
            {
               double ph=x*pi/10;
               double nn=n/10.0;
               double kk=k/10.0;
               if ((nn*sin(ph)*sin(ph)) < 1.0)
                 {
                  double tmp=boost::math::ellint_3(kk,nn,ph);
                  printf("%23.16e\n",tmp);
               }
             }
          }
        }
   }
%}

load elliptic_Pi_boost.txt

k=0:0.1:0.9;
n=0:0.1:0.9;
t=(0:0.1:0.5);
s=0;
for p=1:length(k),
  for q=1:length(n),
    for r=1:length(t),
      phi=t(r)*pi;
      if (n(q)*sin(phi)*sin(phi)) < 1.0
        s=s+1;
        z=elliptic_Pi(phi,n(q),k(p));
        if abs(z-elliptic_Pi_boost(s))>tol
          error("p=%d,q=%d,r=%d,k=%g,n=%g,phi=%g,z=%g,boost(%d)=%g\n", ...
                p,q,r,k(p),n(q),phi,z,s,elliptic_Pi_boost(s));
        endif
      endif
    endfor
  endfor
endfor

% Done
diary off
movefile elliptic_Pi_test.diary.tmp elliptic_Pi_test.diary;
