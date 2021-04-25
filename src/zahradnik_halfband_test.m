% zahradnik_halfband_test.m
% See: "Equiripple Approximation of Half-Band FIR Filters",
% P. Zahradnik and M. Vlcek, IEEE Transactions on Circuits and Systems - II:
% Express Briefs, Vol. 56, No. 12, December 2009, pp. 941-945
%
% Copyright (C) 2019-2021 Robert G. Jenssen

test_common;

pkg load optim;

delete("zahradnik_halfband_test.diary");
delete("zahradnik_halfband_test.diary.tmp");
diary zahradnik_halfband_test.diary.tmp

strf="zahradnik_halfband_test";
nplot=10000;
tol=1e-10;
maxiter=1e4;

function [n,kp,A,B]=zahradnik_halfband_param(fp,as)
  wp=2*pi*fp;
  n=ceil((as-(18.18840664*wp)+33.64775300)/((18.54155181*wp)-29.13196871));
  kp=((n*wp)-(1.57111377*n)+0.00665857)/(-(1.01927560*n)+0.37221484);
  A=(((0.01525753*n)+0.03682344+(9.24760314/n))*kp)+1.01701407+(0.73512298/n);
  B=(((0.00233667*n)-1.35418408+(5.75145813/n))*kp)+1.02999650-(0.72759508/n);
endfunction

function [G,Q,h]=zahradnik_halfband_G(n,kp,A,B,N)
  if (nargin~=4 && nargin~=5) || nargout>3
    print_usage("[G,Q,h]=zahradnik_halfband_G(n,kp,A,B,N)");
  endif
  
  % Find G in x
  [Un,Unm1]=chebyshevU(n);
  G=(A*Un)+(B*[0,Unm1]);
  
  if nargout==1
    return;
  endif
  
  % Expand G in v to give G2
  kp2=kp^2;
  PV2=[2/(1-kp2),0,(-1-kp2)/(1-kp2)];
  PV2n=1;
  G2=zeros(1,(2*length(G))-1);
  G2(1)=G(end);
  for r=(length(G)-1):-1:1,
    PV2n=conv(PV2n,PV2);
    G2(1:length(PV2n))=G2(1:length(PV2n))+(G(r)*fliplr(PV2n));
  endfor
  G2=fliplr(G2);

  % Find Q
  if nargin==4
    Q=polyint(G2);
    if mod(n,2)
      v01=sqrt((kp^2)+((1-(kp^2))*(cos(pi/((2*n)+1))^2)));
      N=2*polyval(Q,v01);
    else
      N=2*polyval(Q,1);
    endif
    Q=Q/N;
    Q(end)=0.5;
  else
    Q=polyint(G2)/N;
    Q(end)=0.5;
  endif;
  
  if nargout==2
    return;
  endif
  
  % Expand Q(v) in v=(z+1/z)/2 to find h
  c=length(Q);
  h=zeros(1,(2*c)-1);
  h(c)=Q(end);
  for l=1:2:(c-1),
    h((c-l):2:(c+l))=h((c-l):2:(c+l))+(Q(c-l)*bincoeff(l,0:l)/(2^l));
  endfor
endfunction

function h=zahradnik_halfband_h(fp,n,kp,A,B)
  if nargin~=5
    print_usage("h=zahradnik_halfband_h(fp,n,kp,A,B)");
  endif
  hn=zahradnik_halfband(n,kp);
  hnm1=zahradnik_halfband(n-1,kp);
  h=((A*hn)+(B*[0,0,hnm1,0,0]));
  v01=sqrt((kp^2)+((1-(kp^2))*(cos(pi/((2*n)+1))^2)));
  omega_01=acos(v01);
  Hv_01=freqz(h,1,[0,omega_01]);
  if mod(n,2)
    Np=-2*abs(Hv_01(2));
  else
    Np=2*abs(Hv_01(1));
  endif
  h=h/Np;
  h((2*n)+2)=0.5;
endfunction

function Herr=zahradnik_halfband_hABsearch(X,_fp,_n,_kp)
  persistent fp n kp
  persistent init_done=false
  if nargin==4
    fp=_fp;n=_n;kp=_kp;
    init_done=true;
    return;
  elseif nargin~=1
    print_usage("Qerr=zahradnik_halfband_hABsearch(X,_fp,_n,_kp)");
  elseif init_done==false
    error("init_done==false");
  endif
  h=zahradnik_halfband_h(fp,n,kp,X(1),X(2));
  v01=sqrt((kp^2)+((1-(kp^2))*(cos(pi/((2*n)+1))^2)));
  omega_01=acos(v01);
  omega_p=2*pi*fp;
  Hv=freqz(h,1,[0,omega_01,omega_p]);
  Hv_0=abs(Hv(1));
  Hv_01=abs(Hv(2));
  Hv_p=abs(Hv(3));

  if 0
    % Equation 15 checks only the first extremum and pass-band edge 
    if mod(n,2)
      Herr=abs(Hv_p-Hv_0);
    else
      Herr=abs(Hv_p-Hv_01);
    endif
    Herr=Herr;
  else
    % Brute force comparison of all pass-band extrema
    npoints=n*1000;
    wpoints=2*pi*(0:npoints)*fp/npoints;
    H=freqz(h,1,wpoints);
    omega_max=local_max(abs(H));
    omega_min=local_max(-abs(H));
    if mod(n,2)
      Herr_max=sum(abs(abs(H(omega_max))-Hv_01));
      Herr_min=sum(abs(abs(H(omega_min))-Hv_0));
    else
      Herr_max=sum(abs(abs(H(omega_max))-Hv_0));
      Herr_min=sum(abs(abs(H(omega_min))-Hv_01));
    endif
    Herr=Herr_min+Herr_max;
  endif
endfunction

function eqn8_err=zahradnik_halfband_equation_8(U,n,kp)
  if nargin~=3 || nargout>1
    print_usage("eqn8_err=zahradnik_halfband_equation_8(U,n,kp)");
  endif
  kp2=kp^2;
  Up=polyder(U);
  Upp=polyder(Up);
  term1=conv(conv([1,0],[1,0,-kp2]),conv([-1,0,1],Upp)-conv([3,0],Up));
  term2=conv(conv([2,0,kp2],[-1,0,1]),Up);
  term3=4*n*(n+2)*conv([1,0,0,0],U);
  eqn8=[term1;term2;term3];
  eqn8_err=sum(abs(sum(eqn8,1)));
endfunction

%
% Check alpha and Equation 8 (Roundoff error limits as to >-50dB)
%
fp=0.225;
as=-20;
[n,kp]=zahradnik_halfband_param(fp,as)
[~,~,alpha]=zahradnik_halfband(n,kp);
if any(alpha(2:2:end))
  error("any(alpha(2:2:end))");
endif
U=zeros(1,((2*n)+1));
for m=0:2:(2*n),
  alphaUm=alpha(1+m)*chebyshevU(m);
  U=U+[zeros(1,length(U)-length(alphaUm)),alphaUm];
endfor
U_br=chebyshevU_backward_recurrence(alpha);
tol=1e-12;
if max(abs(U-U_br))>tol
  error("max(abs(U-U_br))(%g)>%g",max(abs(U-U_br)),tol);
endif
eqn8_err=zahradnik_halfband_equation_8(U,n,kp);
tol=1e-10;
if eqn8_err>tol
  error("eqn8_err(%g)>%g",eqn8_err,tol);
endif

%
% Reproduce Figures 1 and 2 using Q and the generating function, G
%
n=20
kp=0.03922835
if 1
  A=1.08532371
  B=0.95360863
else
  A=(((0.01525753*n)+0.03682344+(9.24760314/n))*kp)+1.01701407+(0.73512298/n)
  B=(((0.00233667*n)-1.35418408+(5.75145813/n))*kp)+1.02999650-(0.72759508/n)
endif
N=0.55091994
[G,Q,h]=zahradnik_halfband_G(n,kp,A,B);

% Scale Qn slightly
del=0.00001;
v=-1:del:1;
Q(end)=0;
Qv=polyval(Q,v);
Qscale=max([-Qv,Qv])/0.5;
Q=Q/Qscale;
Q(end)=0.5;
h(1:2:end)=h(1:2:end)/Qscale;

% Plot Gx
del=0.0001;
v=-1:del:1;
kp2=kp^2;
PV2=[2/(1-kp2),0,(-1-kp2)/(1-kp2)];
x=polyval(PV2,v);
Gx=polyval(G,x);
plot(v,Gx);
axis([-1.02 1.02 -10 50])
grid("on");
xlabel("v")
ylabel("G(v)")
strt=sprintf("Zahradnik and Vlcek half-band filter, G(v): \
n=%d, kp=%10.8f, A=%10.8f, B=%10.8f", n,kp,A,B);
title(strt);
print(strcat(strf,"_fig1"),"-dpdflatex");
close

% Plot Q
del=0.0001;
v=-1:del:1;
Qv=polyval(Q,v);
plot(v,Qv);
axis([-1.02 1.02 -0.02 1.02]);
grid("on");
xlabel("v")
ylabel("Q(v)")
strt=sprintf("Zahradnik and Vlcek half-band filter, Q(v) : \
n=%d, kp=%10.8f, A=%10.8f, B=%10.8f", n,kp,A,B);
title(strt);
print(strcat(strf,"_fig2"),"-dpdflatex");
close

% Plot response of h
[H,w]=freqz(h,1,nplot);
plot(w*0.5/pi,20*log10(abs(H)));
axis([0 0.5 -25 5]);
xlabel("Frequency")
ylabel("Amplitude(dB)")
grid("on");
strt=sprintf("Zahradnik and Vlcek half-band filter frequency response : \
n=%d, kp=%10.8f, A=%10.8f, B=%10.8f", n,kp,A,B);
title(strt);
print(strcat(strf,"_fig2_response"),"-dpdflatex");
close

%
% Specify fp and as 
%
fp=0.225;
as=-60;
[n,kp,A,B]=zahradnik_halfband_param(fp,as)
[G,Q,h]=zahradnik_halfband_G(n,kp,A,B);
% Compare h from zahradnik_halfband_G and h from zahradnik_halfband 
hnnm1=zahradnik_halfband_h(fp,n,kp,A,B);
Gtol=2.5e-6;
Gerr=max(abs(h-hnnm1));
if Gerr>Gtol
  error("max(abs(h-hnnm1))(%g)>%g",Gerr,Gtol);
endif
% Plot
[H,w]=freqz(h,1,nplot);
np=ceil(nplot*fp/0.5)+1;
ns=ceil(nplot*(0.5-fp)/0.5)+1;
ax=plotyy(w(1:np)*0.5/pi,20*log10(abs(H(1:np))), ...
          w(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -0.01 0.002]);
axis(ax(2),[0 0.5 -68 -56]);
strt=sprintf("Zahradnik and Vlcek half-band filter: fp=%5.3f, as=%ddB, n=%d", ...
             fp,as,n);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_G_fp_0_225_as_60"),"-dpdflatex");
close

%
% Use zahradnik_halfband with hABsearch
%
fp=0.225;
as=-60;
[n,kp,Ap,Bp]=zahradnik_halfband_param(fp,as);
if 1
  zahradnik_halfband_hABsearch([],fp,n,kp);
  opt=optimset("MaxFunEvals",maxiter,"MaxIter",maxiter,"TolFun",tol,"TolX",tol);
  [X,Fval,ExitFlag,Output]=fminsearch(@zahradnik_halfband_hABsearch,[Ap,Bp],opt)
  if ExitFlag==0
    error("Too many iterations or function evaluations");
  elseif ExitFlag==-1
    error("Iteration stopped");
  endif
  A=X(1);B=X(2);
else
  A=Ap;B=Bp;
endif
h=zahradnik_halfband_h(fp,n,kp,A,B);
print_polynomial([h(1:2:((2*n)+1)),h((2*n)+2)], ...
                 "h_distinct",sprintf("%s_fp_0_225_as_60_coef.m",strf));
% Plot
[H,w]=freqz(h,1,nplot);
np=ceil(nplot*fp/0.5)+1;
ns=ceil(nplot*(0.5-fp)/0.5)+1;
ax=plotyy(w(1:np)*0.5/pi,20*log10(abs(H(1:np))), ...
          w(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
axis(ax(1),[0 0.5 -0.01 0.002]);
axis(ax(2),[0 0.5 -68 -56]);
strt=sprintf("Zahradnik and Vlcek half-band filter (hn and hnm1): \
fp=%5.3f, as=%ddB, n=%d" ,fp,as,n);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_fp_0_225_as_60"),"-dpdflatex");
close

%
% Reproduce Figures 6 and 7 with hABsearch
%
fp=0.225;
as=-120;
[n,kp,Ap,Bp]=zahradnik_halfband_param(fp,as)
if 1
  zahradnik_halfband_hABsearch([],fp,n,kp);
  opt=optimset("MaxFunEvals",maxiter,"MaxIter",maxiter,"TolFun",tol,"TolX",tol);
  [X,Fval,ExitFlag,Output]=fminsearch(@zahradnik_halfband_hABsearch,[Ap,Bp],opt)
  if ExitFlag==0
    error("Too many iterations or function evaluations");
  elseif ExitFlag==-1
    error("Iteration stopped");
  endif
  A=X(1);B=X(2);
else
  A=Ap;B=Bp;
endif
h=zahradnik_halfband_h(fp,n,kp,A,B);
print_polynomial([h(1:2:((2*n)+1)),h((2*n)+2)], ...
                 "h_distinct",sprintf("%s_fp_0_225_as_120_coef.m",strf));
% Plot
[H,w]=freqz(h,1,nplot);
np=ceil(nplot*fp/0.5)+1;
ns=ceil(nplot*(0.5-fp)/0.5)+1;
ax=plotyy(w(1:np)*0.5/pi,20*log10(abs(H(1:np))), ...
          w(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
axis(ax(1),[0 0.5 -1e-5 2e-6]);
axis(ax(2),[0 0.5 -130 -118]);
strt=sprintf("Zahradnik and Vlcek half-band filter: fp=%5.3f, as=%ddB, n=%d",
             fp,as,n);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_fp_0_225_as_120"),"-dpdflatex");
close

%
% Show the response of the filter in Table II
%
n=39;
hii=[-0.00000070,  0.00000158, -0.00000331,  0.00000622, -0.00001087, ...
      0.00001799, -0.00002852,  0.00004363, -0.00006481,  0.00009384, ...
     -0.00013287,  0.00018446, -0.00025161,  0.00033779, -0.00044697, ...
      0.00058370, -0.00075311,  0.00096097, -0.00121375,  0.00151871, ...
     -0.00188398,  0.00231877, -0.00283354,  0.00344038, -0.00415347, ...
      0.00498985, -0.00597048,  0.00712193, -0.00847897,  0.01008867, ...
     -0.01201717,  0.01436125, -0.01726924,  0.02098117, -0.02591284, ...
      0.03285186, -0.04348979,  0.06223123, -0.10523903,  0.31802058, ...
      0.50000000];
h=zeros(1,1+(2*((2*n)+1)));
h(1:2:end)=[hii(1:(end-1)),hii((end-1):-1:1)];
h((2*n)+2)=hii(end);
[H,w]=freqz(h,1,nplot);
np=ceil(nplot*fp/0.5)+1;
ns=ceil(nplot*(0.5-fp)/0.5)+1;
ax=plotyy(w(1:np)*0.5/pi,20*log10(abs(H(1:np))), ...
          w(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
axis(ax(1),[0 0.5 -1e-5 2e-6]);
axis(ax(2),[0 0.5 -130 -118]);
strt=sprintf("Zahradnik and Vlcek half-band filter: Table II");
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_table_ii"),"-dpdflatex");
close

%
% Try harder
%
fp=0.24;
as=-140;
[n,kp,Ap,Bp]=zahradnik_halfband_param(fp,as)
n=n+3
if 1
  zahradnik_halfband_hABsearch([],fp,n,kp);
  opt=optimset("MaxFunEvals",maxiter,"MaxIter",maxiter,"TolFun",tol,"TolX",tol);
  [X,Fval,ExitFlag,Output]=fminsearch(@zahradnik_halfband_hABsearch,[Ap,Bp],opt)
  if ExitFlag==0
    error("Too many iterations or function evaluations");
  elseif ExitFlag==-1
    error("Iteration stopped");
  endif
  A=X(1);B=X(2);
else
  A=Ap;B=Bp;
endif
h=zahradnik_halfband_h(fp,n,kp,A,B);
print_polynomial([h(1:2:((2*n)+1)),h((2*n)+2)], ...
                 "h_distinct",sprintf("%s_fp_0_240_as_140_coef.m",strf));
% Plot
[H,w]=freqz(h,1,nplot);
np=ceil(nplot*fp/0.5)+1;
ns=ceil(nplot*(0.5-fp)/0.5)+1;
ax=plotyy(w(1:np)*0.5/pi,20*log10(abs(H(1:np))), ...
          w(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
axis(ax(1),[0 0.5 -8e-7 2e-7]);
axis(ax(2),[0 0.5 -145 -140]);
strt=sprintf("Zahradnik and Vlcek half-band filter: fp=%5.3f, as=%ddB, n=%d",
             fp,as,n);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_fp_0_240_as_140"),"-dpdflatex");
close

% Done
diary off
movefile zahradnik_halfband_test.diary.tmp zahradnik_halfband_test.diary;
