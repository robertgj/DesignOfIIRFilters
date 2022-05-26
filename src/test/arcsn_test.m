% arcsn_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("arcsn_test.diary");
delete("arcsn_test.diary.tmp");
diary arcsn_test.diary.tmp

% DLMF Equation 19.25.33
k=0.05:0.05:0.95;
ur=(-0.85:0.05:0.85);
ui=(-0.85:0.05:0.85)';
u=[ur+(j*ui),ur-(j*ui)];
tol=4*eps;
for n=1:length(k),
  snu=ellipj(u,k(n)^2);
  uasn=zeros(size(u));
  errasn=zeros(size(u));
  uc=zeros(size(u));
  for m=1:columns(u),
    for l=1:rows(u),
      [uasn(l,m),errasn(l,m)]=arcsn(snu(l,m),k(n));
    endfor
  endfor
  if max(max(abs(uasn-u)))>tol
    error("max(max(abs(uasn-u)))>tol");
  endif
endfor

% Half-argument identity: DLMF Equation 22.6.19 (z/4 does not improve accuracy)
k=0.05:0.05:0.95;
K=ellipke(k.^2);
Kp=ellipke(1-(k.^2));
tol=[40*ones(1,14),100*ones(1,7)]*eps;
tol_snuasn=[100*ones(1,10),1000,1e5*ones(1,5),2e6*ones(1,5)]*eps;
for n=1:length(k),
  u=(0.9:0.1:2)'*exp(j*(-0.5:0.1:0.5)*pi);
  snu=ellipj(u,k(n)^2);
  uasn=zeros(size(u));
  errasn=zeros(size(u));
  % Calculate sn(u/2) from sn(u)
  sn_uon2=sqrt((1-(sqrt(1-(snu.^2))))./(1+sqrt(1-((k(n)*snu).^2))));
  for m=1:columns(u),
    for l=1:rows(u),
      [uasn(l,m),errasn(l,m)]=arcsn(sn_uon2(l,m),k(n));
    endfor
  endfor
  uasn=uasn*2;
  % Adjust uasc to be consistent with u
  adj_uasn=uasn;
  if any(any(abs(uasn-u)>tol(n)))
    % Adjust real part 
    if any(any(abs(real(uasn)-real(u))>tol(n)))
      [lr,mr]=find(abs(real(uasn)-real(u))>tol(n));
      for p=1:length(lr)
        warning("Adjusting real k=%4.2f,uasn(%d,%d)=%10.7f+%10.7fj\n",
                k(n),lr(p),mr(p), ...
                real(uasn(lr(p),mr(p))),imag(uasn(lr(p),mr(p))));
        adj_uasn(lr(p),mr(p))=((2*K(n))-real(uasn(lr(p),mr(p)))) ...
                              +(j*imag(uasn(lr(p),mr(p))));
      endfor
    endif
    if any(any(abs(imag(uasn)-imag(u))>tol(n)))
      [li,mi]=find(abs(imag(uasn)-imag(u))>tol(n));
      for p=1:length(li)
        if abs(abs(imag(adj_uasn(li(p),mi(p))))-abs(imag(u(li(p),mi(p)))))<tol(n)
          % Conjugate imaginary part 
          warning("Conjugating k=%4.2f,adj_uasn(%d,%d)=%10.7f+%10.7fj\n",
                  k(n),li(p),mi(p), ...
                  real(adj_uasn(li(p),mi(p))),imag(adj_uasn(li(p),mi(p))));
          adj_uasn(li(p),mi(p))=conj(adj_uasn(li(p),mi(p)));
        else
          % Adjust imaginary part 
          warning("Adjusting imag. k=%4.2f,adj_uasn(%d,%d)=%10.7f+%10.7fj\n",
                  k(n),li(p),mi(p), ...
                  real(adj_uasn(li(p),mi(p))),imag(adj_uasn(li(p),mi(p))));
          if imag(u(li(p),mi(p)))>=0
            adj_uasn(li(p),mi(p))=real(adj_uasn(li(p),mi(p))) ...
                                  +(j*(imag(adj_uasn(li(p),mi(p)))+(2*Kp(n))));
          else
            adj_uasn(li(p),mi(p))=real(adj_uasn(li(p),mi(p))) ...
                                  +(j*(imag(adj_uasn(li(p),mi(p)))-(2*Kp(n))));
          endif
        endif
      endfor
    endif
  endif

  % Check inverse against u
  if max(max(abs(adj_uasn-u)))>tol(n)
    error("max(max(abs(adj_uasn-u)))>tol(n)");
  endif
  
  % Check inverse without adjustment against snu
  snuasn=ellipj(uasn,k(n)^2);
  if max(max(abs(snuasn-snu)))>tol_snuasn(n)
    error("max(max(abs(snuasn-snu)))>tol_snuasn(n)");
  endif
endfor

% Done
diary off
movefile arcsn_test.diary.tmp arcsn_test.diary;
