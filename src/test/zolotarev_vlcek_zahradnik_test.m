% zolotarev_vlcek_zahradnik_test.m
% Test Vlcek and Zahradnik's almost equi-ripple filter design. See:
% [1] "Almost Equiripple Low-Pass FIR Filters", M. Vlcek and
% P. Zahradnik, Circuits Syst Signal Process (2013) 32:743–757,
% DOI 10.1007/s00034-012-9484-0
% [2] "Approximation of Almost Equiripple Low-pass FIR Filters", M. Vlcek and
% P. Zahradnik, 2013 European Conference on Circuit Theory and Design,
% DOI: 10.1109/ECCTD.2013.6662301
% 
% Copyright (C) 2019-2021 Robert G. Jenssen

test_common;

pkg load optim;

delete("zolotarev_vlcek_zahradnik_test.diary");
delete("zolotarev_vlcek_zahradnik_test.diary.tmp");
diary zolotarev_vlcek_zahradnik_test.diary.tmp

strf="zolotarev_vlcek_zahradnik_test";

function eqn17_err=zolotarev_vlcek_zahradnik_equation_17alt(S,n,wp,wm,ws)
  % Equation 17 of [1]
  if nargin~=5 || nargout>1
    print_usage ...
      ("eqn17_err=zolotarev_vlcek_zahradnik_equation_17alt(S,n,wp,wm,ws)");
  endif
  Sp=polyder(S);
  Spp=polyder(Sp);
  wq=(ws+wp)/2;
  g0=conv([1,-wm],conv([1,-wm],[1,-wm]));
  g1=conv([1,-wp],[1, -ws])-conv([1,-wm],[1,-wq]);
  g2=conv([1,-wp],conv([1,-ws],[1,-wm]));
  term1=conv(g2,conv([-1,0,1],Spp)-[3*Sp,0]);
  term2=conv(-g1,conv([-1,0,1],Sp));
  term3=conv((((n+1)^2)*g0)+[g1,0]-g2,S);
  eqn17=[term1;term2;term3];
  eqn17_err=sum(abs(sum(eqn17,1)));
endfunction

%
% Does polynomial Spq satisfy the revised version of [1,Equation 17]?
%
for p=1:4,
  for q=1:11,
    k=0.75;
    n=p+q;
    % Calculate the generating function using Vlcek and Zahradnik Table 4
    [~,wp,wm,ws,a,aplus]=zolotarev_vlcek_zahradnik(p,q,k);
    % Brute force calculation of Spq for chebyshevU coefficients
    Spq=zeros(size(aplus));
    for m=0:n,
      aplusU=aplus(1+m)*chebyshevU(m);
      Spq=Spq+[zeros(1,columns(aplus)-columns(aplusU)),aplusU];
    endfor
    % Check Chebyshev recurrence calculation of Spq
    Spq_br=chebyshevU_backward_recurrence(aplus);
    tol=1e-10;
    if max(abs(Spq_br-Spq)) > tol
      error("p=%d,q=%d,max(abs(Spq_br-Spq))(%g)>%g", ...
            p,q,max(abs(Spq_br-Spq)),tol);
    endif
    % Check recurrence for chebyshevT coefficients
    intSpq=zeros(size(a));
    for m=1:(n+1),
      aT=a(1+m)*chebyshevT(m);
      intSpq=intSpq+[zeros(1,columns(a)-columns(aT)),aT];
    endfor
    intSpq_br=chebyshevT_backward_recurrence(a);
    tol=1e-10;
    if max(abs(intSpq_br-intSpq)) > tol
      error("p=%d,q=%d,max(abs(intSpq_br-intSpq))(%g)>%g",
            p,q,max(abs(intSpq_br-intSpq)),tol);
    endif
    % Calculate the wp, wm and ws frequencies in the w-plane
    printf("p=%2d,q=%1d,k=%4.2f,fp=%8f,fm=%d,fs=%8f\n",
           p,q,k,acos(wp)*0.5/pi,acos(wm)*0.5/pi,acos(ws)*0.5/pi);
    % Check Equation 5
    eqn17alt_err=zolotarev_vlcek_zahradnik_equation_17alt(Spq,n,wp,wm,ws);
    tol=1e-7;
    if eqn17alt_err > tol
      error("p=%d,q=%d,sum(abs(sum(eqn17alt_err,1)))(%g)>%g", ...
            p,q,eqn17alt_err,tol);
    endif
  endfor
endfor

%
% Compare zolotarev_chen_parks.m and zolotarev_vlcek_zahradnik.m
%
p=4,q=11,k=0.75
n=p+q;
% Calculate the Zolotarev function directly using Chen and Parks
[u,x,f,um,xm,fm,a,fa,b,fb]=zolotarev_chen_parks(k,p+q,p);
% Transform from x to w
K=ellipke(k^2);
uZ=p*K/n;
[snuZ,cnuZ]=ellipj(uZ,k^2);
wx=(x.*(cnuZ^2))-(snuZ.^2);
wx=real(wx);
Zwx=f;
% Calculate the generating function using Vlcek and Zahradnik Table 4
[~,~,~,~,~,aplus]=zolotarev_vlcek_zahradnik(p,q,k);
Spq=chebyshevU_backward_recurrence(aplus);
% Calculate the Zolotarev function using Vlcek and Unbehauen Chebyshev recurrence
aa=zolotarev_vlcek_unbehauen(p,q,k);
ZC_br=chebyshevT_backward_recurrence(aa);
ZCwx_br=polyval(ZC_br,wx);
if max(abs(ZCwx_br-Zwx))>1e-10
  error("max(abs(ZCwx_br-Zwx))(%g)>1e-10",max(abs(ZCwx_br-Zwx)));
endif
% Calculate the Zolotarev function using Vlcek and Unbehauen Chebyshev expansion
ZCwx=zeros(size(wx));
for m=0:n,
  ZCwx=ZCwx+polyval(aa(1+m)*chebyshevT(m),wx);
endfor
if max(abs(ZCwx-Zwx))>1e-10
  error("max(abs(ZCwx-Zwx))(%g)>1e-10",max(abs(ZCwx-Zwx)));
endif
% Compare plots of Zolotarev and modified Vlcek and Zahradnik Spq
SZwx=Zwx./sqrt(1-(wx.^2));
Swx=polyval(Spq,wx);
ZSwx=Swx.*sqrt(1-(wx.^2));
subplot(211);
plot(wx,ZSwx,'-',wx,Zwx,'--');
axis([-1.1 1.1 -2 8]);
ylabel("Amplitude");
grid("on");
legend_ZSwx=sprintf("$(1-w^{2})^{1/2}S_{%d,%d}(u,%4.2f)$",p,q,k);
legend_Zwx=sprintf("$Z_{%d,%d}(u,%4.2f)$",p,q,k);
legend(legend_ZSwx,legend_Zwx);
hlegend = findobj(gcf(),"type","axes","Tag","legend");
set(hlegend, "FontSize", 10);
legend("location","north");
legend("boxoff");
legend("left");
strt=sprintf("$(1-w^{2})^{1/2}S_{%d,%d}(u,%4.2f)$ and $Z_{%d,%d}(u,%4.2f)$",
             p,q,k,p,q,k);
title(strt);
subplot(212);
plot(wx,Swx,'-',wx,SZwx,'--');
axis([-1.1 1.1 -10 10]);
xlabel("$w$");
ylabel("Amplitude");
legend_Swx=sprintf("$S_{%d,%d}(u,%4.2f)$",p,q,k);
legend_SZwx=sprintf("$Z_{%d,%d}(u,%4.2f)/(1-w^{2})^{1/2}$",p,q,k);
legend(legend_Swx,legend_SZwx);
legend("location","north");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf("$S_{%d,%d}(u,%4.2f)$ and $Z_{%d,%d}(u,%4.2f)/(1-w^{2})^{1/2}$",
             p,q,k,p,q,k);
title(strt);
print(sprintf("%s_p_%d_q_%d_chen_parks",strf,p,q),"-dpdflatex");
close

%
% Reproduce Figures 1 to 4 with Table 4 from [1]
%
p=4;q=11;k=0.75;
n=p+q;
[h,wp,wm,ws,a,aplus]=zolotarev_vlcek_zahradnik(p,q,k);
if a(1)~=0
  error("a(1)~=0");
else
  nnp1=1:n+1;
  if max(abs(a-[0,(aplus./nnp1)]))>eps
    error("max(abs(a-[0,(aplus./nnp1)]))>eps");
  endif
endif

% Modified Zolotarev function
Spq=chebyshevU_backward_recurrence(aplus);
w=-1:0.001:1;
plot(w,polyval(Spq,w).*sqrt(1-(w.^2)));
axis([-1.1 1.1 -1 7])
xlabel("$w$");
ylabel("Amplitude");
strt=sprintf("Function $(1-w^2)^{1/2}S_{%d,%d}(u,%4.2f)$",p,q,k);
title(strt);
grid("on");
print(sprintf("%s_p_%d_q_%d_isoextremal",strf,p,q),"-dpdflatex");
close

% Generating function (Figure 2)
plot(w,polyval(Spq,w));
axis([-1.1 1.1 -10 10])
xlabel("$w$");
ylabel("Amplitude");
grid("on");
strt=sprintf("Generating function $S_{%d,%d}(u,%4.2f)$",p,q,k);
title(strt);
print(sprintf("%s_p_%d_q_%d_generator",strf,p,q),"-dpdflatex");
close
print_polynomial(Spq,sprintf("Spq_%d_%d",p,q),
                 sprintf("%s_p_%d_q_%d_generator_coef.m",strf,p,q),"%17.10f");

% Zero phase transfer function (Figure 3)
intSpq=chebyshevT_backward_recurrence(a);
N=polyval(intSpq,cos([0,(pi/(n+1)),(n*pi/(n+1)),pi]));
if mod(q,2)
  N1=N(3);
else
  N1=N(4);
endif
if mod(p,2)
  N2=N(2);
else
  N2=N(1);
endif
w=-1:0.001:1;
S=(-N1+polyval(intSpq,w))./(N2-N1);
plot(w,S);
axis([-1 1 0 1])
xlabel("$w$");
ylabel("Amplitude");
grid("on");
strt=sprintf("Un-normalised zero-phase transfer function S :\
p=%d, q=%d, k=%4.2f",p,q,k);
title(strt);
print(sprintf("%s_p_%d_q_%d_S",strf,p,q),"-dpdflatex");
close

% Try with modified coefficients
a=zeros(1,n+2);
a=[-N1,aplus./(1:n+1)]/(N2-N1);
intSpq=chebyshevT_backward_recurrence(a);
w=-1:0.001:1;
Q=polyval(intSpq,w);
tol=2e-6;
if max(abs(Q-S))>tol
  error("max(abs(Q-S))(%g)>%f",max(abs(Q-S)),tol);
endif
plot(w,Q);
axis([-1.1 1.1 0 1])
xlabel("$w$");
ylabel("Amplitude");
grid("on");
strt=sprintf("Zero-phase transfer function $Q_{%d,%d}(u,%4.2f)$",p,q,k);
title(strt);
print(sprintf("%s_p_%d_q_%d_zero_phase",strf,p,q),"-dpdflatex");
close
print_polynomial(a,sprintf("a_%d_%d",p,q),
                 sprintf("%s_p_%d_q_%d_a_coef.m",strf,p,q));

% Frequency response (Figure 4)
[H,w]=freqz(h,1,1024);
H=H.*(e.^(j*(n+1)*w));
plot(w*0.5/pi,real(H));
axis([0 0.5 0 1]);
grid("on");
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
strt=sprintf("Transfer function (Vlcek and Zahradnik) : p=%d,q=%d,k=%4.2f",
             p,q,k);
title(strt);
print(sprintf("%s_p_%d_q_%d_response",strf,p,q),"-dpdflatex");
close
print_polynomial(h,sprintf("h_%d_%d",p,q),
                 sprintf("%s_p_%d_q_%d_h_coef.m",strf,p,q));

% Frequency response (Figure 5)
p=100;q=300;k=0.25;
[h,wp,wm,ws]=zolotarev_vlcek_zahradnik(p,q,k);
nplot=10000;
[H,w]=freqz(h,1,nplot);
fp=acos(wp)*0.5/pi;
np=ceil(nplot*fp/0.5)+1;
fs=acos(ws)*0.5/pi;
ns=floor(nplot*(fs)/0.5)+1;
ax=plotyy(w(1:np)*0.5/pi,20*log10(abs(H(1:np))), ...
          w(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
axis(ax(1),[0 0.5 -0.08 0.02]);
axis(ax(2),[0 0.5 -46 -36]);
strt=sprintf("Transfer function (Vlcek and Zahradnik) : p=%3d, q=%3d, k=%4.2f",
             p,q,k);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(sprintf("%s_p_%d_q_%d_response",strf,p,q),"-dpdflatex");
close
print_polynomial(h,sprintf("h_%d_%d",p,q),
                 sprintf("%s_p_%d_q_%d_h_coef.m",strf,p,q));

%
% Exercise the design procedure with the example in [2,Section 8] 
%
asdB=-120,fp=0.15,fs=0.175
% Step 1
omegap=2*pi*fp;
omegas=2*pi*fs;
domega=omegas-omegap;
% Step 2
function err=zolotarev_vlcek_zahradnik_test_nsearch(n,_asdB,_domega,_xi)
  persistent asdB domega xi
  persistent init_done=false
  if nargin==4
    asdB=_asdB;domega=_domega;xi=_xi;
    init_done=true;
    return;
  elseif nargin~=1
    print_usage("err=zolotarev_vlcek_zahradnik_test_nsearch(n,asdB,domega,xi)");
  elseif init_done==false
    error("init_done==false");
  endif
  err=abs(asdB- ...
          (((((xi(1)*n)+xi(2))*domega)/pi)+xi(3)+(xi(4)/((n+xi(5))^xi(6)))));
endfunction
xi=[-14.02925485, -32.86119410,  -5.80117336, ...
      2.99564719, -21.24188066,   0.28632078];
zolotarev_vlcek_zahradnik_test_nsearch([],asdB,domega,xi);
tol=1e-6;maxiter=1e2;
opt=optimset("MaxFunEvals",maxiter,"MaxIter",maxiter,"TolFun",tol,"TolX",tol);
[X,Fval,ExitFlag,Output]= ...
  fminsearch(@zolotarev_vlcek_zahradnik_test_nsearch,30,opt);
if ExitFlag==0
  error("Too many iterations or function evaluations");
elseif ExitFlag==-1
  error("Iteration stopped");
endif
n=ceil(X);
% Step 3
p=round(n*(omegas+omegap)/(2*pi));
q=n-p;
% Step 4
wp=cos((pi-domega)/2);
chi=[ -0.00452871,  0.51350112,  2.56407699,  1.12297611,  0.01473844, ...
       0.14824220,  0.00245539,  0.52499043,  0.75104615,  1.29448910, ...
      -1.06038228,  0.64247743, -0.00932499,  1.88486768];
khat=((((chi(1)+(chi(2)/((p+chi(3))^chi(4))))*n)+(chi(5)*p)+chi(6))*wp) + ...
     chi(7) + (chi(8)/((p+chi(9))^chi(10))) + ...
     (1/(((n+(chi(11)*p)+chi(12)))^((chi(13)*p)+chi(14))));
k=sqrt(1-(((1-khat)/(1+khat))^2));
% Find actual response band edges
K=ellipke(k^2);
u0=((2*p)+1)*K/((2*n)+2);
[snu0,cnu0,dnu0]=ellipj(u0,k^2);
wp=(2*((cnu0/dnu0)^2))-1;
ws=(2*(cnu0^2))-1;
Zu0=jacobi_Zeta(u0,k);
wm=ws+(2*(snu0*cnu0)*Zu0/dnu0);
printf("p=%2d,q=%1d,k=%12.10f,actual_fp=%10.8f,actual_fs=%10.8f\n",
       p,q,k,acos(wp)*0.5/pi,acos(ws)*0.5/pi);
% Step 5
h=zolotarev_vlcek_zahradnik(p,q,k,2e-10);

% Show results
nplot=10000;
[H,w]=freqz(h,1,nplot);
np=ceil(nplot*fp/0.5)+1;
ns=floor(nplot*(fs)/0.5)+1;
ax=plotyy(w(1:np)*0.5/pi,20*log10(abs(H(1:np))), ...
          w(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
axis(ax(1),[0 0.5 -0.00001 0.000002]);
axis(ax(2),[0 0.5 -130 -118]);
strt=sprintf("Transfer function (Vlcek and Zahradnik) : \
asdB=%3d, fp=%5.3f, fs=%5.3f", asdB,fp,fs);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(sprintf("%s_as_120_fp_0_15_response",strf),"-dpdflatex");
close
print_polynomial(h,"h",sprintf("%s_as_120_fp_0_15_h_coef.m",strf));

% Done
diary off
movefile zolotarev_vlcek_zahradnik_test.diary.tmp ...
         zolotarev_vlcek_zahradnik_test.diary;
