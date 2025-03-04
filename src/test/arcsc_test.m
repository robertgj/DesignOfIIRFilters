% arcsc_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("arcsc_test.diary");
delete("arcsc_test.diary.tmp");
diary arcsc_test.diary.tmp

k=0.05:0.05:0.95;
ur=(-0.85:0.05:0.85);
ui=(-0.85:0.05:0.85)';
u=[ur+(j*ui),ur-(j*ui)];
tol=5*eps;
for n=1:length(k),
  [snu,cnu]=ellipj(u,k(n)^2);
  scu=snu./cnu;
  uasc=zeros(size(u));
  errasc=zeros(size(u));
  for m=1:columns(u),
    for l=1:rows(u),
      [uasc(l,m),errasc(l,m)]=arcsc(scu(l,m),k(n));
    endfor
  endfor
  if max(max(abs(uasc-u)))>tol
    error("max(max(abs(uasc-u)))>tol");
  endif
endfor

% Half-argument identity: DLMF Equations 22.6.19 and 22.6.20
k=0.05:0.05:0.95;
K=ellipke(k.^2);
Kp=ellipke(1-(k.^2));
tol=200*ones(size(k))*eps;
tol_scuasc=4e4*ones(size(k))*eps;
for n=1:length(k),
  u=(0.9:0.1:1.5)'*exp(j*(-0.5:0.1:0.5)*pi);
  [snu,cnu]=ellipj(u,k(n)^2);
  scu=snu./cnu;
  uasc=zeros(size(u));
  errasc=zeros(size(u));
  % Calculate sc(u/2) from sc(u)
  sc2u=scu.^2;
  sn2u=sc2u./(1+sc2u);
  dnu=sqrt(1-((k(n)^2)*sn2u));
  cnu=sqrt(1-sn2u);
  sc_uon2=sqrt((1-dnu)./(((k(n)^2)*(1+cnu))-(1-dnu)));
  for m=1:columns(u),
    for l=1:rows(u),
      [uasc(l,m),errasc(l,m)]=arcsc(sc_uon2(l,m),k(n));
    endfor
  endfor
  uasc=uasc*2;
  
  % Check inverse against u
  if max(max(abs(uasc-u)))>tol(n)
    error("max(max(abs(uasc-u)))>tol(n)");
  endif

  % Check inverse against scu
  [snuasc,cnuasc]=ellipj(uasc,k(n)^2);
  scuasc=snuasc./cnuasc;
  if max(max(abs(scuasc-scu)))>tol_scuasc(n)
    error("max(max(abs(scuasc-scu)))>tol_scuasc(n)");
  endif
endfor

% Done
diary off
movefile arcsc_test.diary.tmp arcsc_test.diary;
