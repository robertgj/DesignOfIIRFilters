% zahradnik_halfband_test.m
% See: "Equiripple Approximation of Half-Band FIR Filters",
% P. Zahradnik and M. Vlcek, IEEE Transactions on Circuits and Systems - II:
% Express Briefs, Vol. 56, No. 12, December 2009, pp. 941-945

% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("zahradnik_halfband_test.diary");
unlink("zahradnik_halfband_test.diary.tmp");
diary zahradnik_halfband_test.diary.tmp

strf="zahradnik_halfband_test";

function [Pn,Pnm1]=chebychevP(n,kind)
  if nargin~=2 || nargout>2
    print_usage("[P,Pnm1]=chebychevP(n,kind)");
  endif
  if kind~=1 && kind~=2
    error("kind~=1 && kind~=2");
  endif
  if n==0
    Pn=1;
    Pnm1=[];
  elseif n==1
    Pn=[kind 0];
    Pnm1=[1];
  else
    Pnm1=[zeros(1,n),1];
    Pn=[zeros(1,n-1),kind,0];
    Pnp1=zeros(1,n+1);
    for m=2:n,
      Pnp1=2*shift(Pn,-1)-Pnm1;
      Pnm1=Pn;
      Pn=Pnp1;
    endfor
    Pnm1=Pnm1(2:end);
  endif
endfunction

function [Tn,Tnm1]=chebychevT(n)
  if nargin~=1 || nargout>2
    print_usage("[T,Tnm1]=chebychevT(n)");
  endif
  [Tn,Tnm1]=chebychevP(n,1);
endfunction

function [Un,Unm1]=chebychevU(n)
  if nargin~=1 || nargout>2
    print_usage("[U,Unm1]=chebychevU(n)");
  endif
  [Un,Unm1]=chebychevP(n,2);
endfunction

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
  [Un,Unm1]=chebychevU(n);
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

  % Find Qn
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

function Qerr=zahradnik_halfband_QABsearch(X,_fp,_n,_kp)
  persistent fp n kp
  persistent init_done=false
  if nargin==4
    fp=_fp;n=_n;kp=_kp;
    init_done=true;
    return;
  elseif nargin~=1
    print_usage("Qerr=zahradnik_halfband_QABsearch(X,_fp,_n,_kp)");
  elseif init_done==false
    error("init_done==false");
  endif
  [~,Q,~]=zahradnik_halfband_G(n,kp,X(1),X(2));
  vp=cos(2*pi*fp);
  v01=sqrt((kp^2)+((1-(kp^2))*(cos(pi/((2*n)+1))^2)));
  Q=polyval(Q,[1,v01,vp]); 
  Q_1=Q(1);Q_v01=Q(2);Q_vp=Q(3);
  if mod(n,2)
    Qerr=abs(Q_vp-Q_1)+abs(Q_v01-1);
  else
    Qerr=abs(Q_vp-Q_v01)+abs(Q_1-1);
  endif
endfunction

function Herr=zahradnik_halfband_hABsearch(X,_fp,_n,_kp,_hn,_hnm1)
  % FIXME !?!?!?!
  persistent fp n kp hn hnm1
  persistent init_done=false
  if nargin==6
    fp=_fp;n=_n;kp=_kp;hn=_hn;hnm1=_hnm1;
    init_done=true;
    return;
  elseif nargin~=1
    print_usage("Herr=zahradnik_halfband_hABsearch(X,_fp,_n,_kp,_hn,_hnm1)");
  elseif init_done==false
    error("init_done==false");
  endif
  % Calculate non-normalised h
  h=(X(1)*hn)+(X(2)*[0,0,hnm1,0,0]);
  % Normalise h
  omegap=2*pi*fp;
  vp=cos(omegap);
  v01=sqrt((kp^2)+((1-(kp^2))*(cos(pi/((2*n)+1))^2)));
  omega01=acos(v01);
  H01=abs(freqz(h,1,[0,omega01]));
  if mod(n,2)
    Np=-2*H01(2);
  else
    Np=2*H01(1);
  endif
  h=h/Np;
  
  % Find error from equiripple
  H=abs(freqz(h,1,[0,omega01,omegap]));
  H_0=H(1);H_f01=H(2);H_fp=H(3);
  h((2*n)+2)=0.5;
  if mod(n,2)
    Herr=H_fp-H_0+H_f01-1;
  else
    Herr=H_fp-H_f01+H_0-1;
  endif
endfunction


%
% Check Chebychev Type 2 identities in the Appendix
%
n=40;
U=cell(1,n+1);
dU=cell(1,n+1);
d2U=cell(1,n+1);
for l=0:n,
  U{1+l}=chebychevU(l);
  dU{1+l}=polyder(chebychevU(l));
  d2U{1+l}=polyder(dU{1+l});
  U{1+l}=[zeros(1,n+1-length(U{1+l})),U{1+l}];
  dU{1+l}=[zeros(1,n+1-length(dU{1+l})),dU{1+l}];
  d2U{1+l}=[zeros(1,n+1-length(d2U{1+l})),d2U{1+l}];
endfor
% Equation 18
for l=2:n,
  if any((2*l*U{1+l-1})-dU{1+l}+dU{1+l-2})
    error("Equation 18 failed at l=%d",l);
  endif
endfor
% Equation 19
for l=1:floor(n/2),
  sU2m=zeros(1,n+1);
  for m=0:(l-1)
    sU2m=sU2m+((2*((2*m)+1))*U{1+(2*m)});
  endfor
  if any(dU{1+(2*l)-1}-sU2m)
    error("Equation 19 failed at l=%d",l);
  endif
endfor
% Equation 20
for l=1:floor(n/2),
  sU2m1=zeros(1,n+1);
  for m=1:l
    sU2m1=sU2m1+(4*m*U{1+(2*m)-1});
  endfor
  if any(dU{1+(2*l)}-sU2m1)
    error("Equation 20 failed at l=%d",l);
  endif
endfor
% Equation 21
for l=1:floor(n/2),
  sU2m1=U{1+1}; % U{1+(2*0)+1}, Ul=0 for l<=0
  for m=1:(l-1)
    sU2m1=sU2m1+(((2*m)+1)*(U{1+(2*m)+1}+U{1+(2*m)-1}));
  endfor
  if any(shift(dU{1+(2*l)-1},-1)-sU2m1)
    error("Equation 21 failed at l=%d",l);
  endif
endfor
% Equation 22
for l=1:floor(n/2),
  sU2m1=zeros(1,n+1);
  for m=1:l
    sU2m1=sU2m1+((2*m)*(U{1+(2*m)}+U{1+(2*m)-2}));
  endfor
  if any(shift(dU{1+(2*l)},-1)-sU2m1)
    error("Equation 22 failed at l=%d",l);
  endif
endfor
% Equation 23 (w^3 part)
for l=2:(floor(n/2)-2),
  if any((shift(d2U{1+(2*l)},-3)-shift(d2U{1+(2*l)},-5)- ...
          (3*shift(dU{1+(2*l)},-4)))+ ...
         (l*(l+1)*(U{1+(2*l)+3}+(3*U{1+(2*l)+1})+ ...
                   (3*U{1+(2*l)-1})+U{1+(2*l)-3})/2))
    error("Equation 23 (w^3 part) failed at l=%d",l);
  endif
endfor
% Equation 23 (-w*kp part)
for l=1:(floor(n/2)-1),
  if any((shift(d2U{1+(2*l)},-3)-shift(d2U{1+(2*l)},-1)+ ...
          (3*shift(dU{1+(2*l)},-2)))- ...
         (2*l*(l+1)*(U{1+(2*l)+1}+U{1+(2*l)-1})))
    error("Equation 23 (kp part) failed at l=%d",l);
  endif
endfor
% Equation 24 (kp part)
for l=1:(floor(n/2)-1),
  if any(dU{1+(2*l)}-shift(dU{1+(2*l)},-2)- ...
         (((l+1)*U{1+(2*l)-1})-(l*U{1+(2*l)+1})))
    error("Equation 24 (kp part) failed at l=%d",l);
  endif
endfor
% Equation 24 (v^2(1-v^2) part)
for l=2:(floor(n/2)-2),
  if any((4*shift(dU{1+(2*l)},-2))-(4*shift(dU{1+(2*l)},-4))- ...
         (((l+1)*(U{1+(2*l)+1}+(2*U{1+(2*l)-1})+U{1+(2*l)-3}))- ...
          (l*(U{1+(2*l)+3}+(2*U{1+(2*l)+1})+U{1+(2*l)-1}))))
    error("Equation 24 (v^2(1-v^2) part) failed at l=%d",l);
  endif
endfor
% Equation 25
for l=2:(floor(n/2)-2),
  if any((8*shift(U{1+(2*l)},-3))- ...
         (U{1+(2*l)+3}+(3*U{1+(2*l)+1})+(3*U{1+(2*l)-1})+U{1+(2*l)-3}))
    error("Equation 25 failed at l=%d",l);
  endif
endfor

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
[H,w]=freqz(h,1,2000);
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
% Specify fp and as and search for the normalising factors with Q
%
fp=0.225
as=-60;
[n,kp,Ap,Bp]=zahradnik_halfband_param(fp,as)
zahradnik_halfband_QABsearch([],fp,n,kp);
opt=optimset("MaxFunEvals",1e4,"MaxIter",1e3,"TolFun",1e-7,"TolX",1e-6);
[X,Fval,ExitFlag,Output]=fminsearch(@zahradnik_halfband_QABsearch,[Ap,Bp],opt);
if ExitFlag==0
  error("Too many iterations or function evaluations");
elseif ExitFlag==-1
  error("Iteration stopped");
endif
if 1
  A=X(1);B=X(2);
else
  A=Ap;B=Bp;
endif
[G,Q,h]=zahradnik_halfband_G(n,kp,A,B);
nplot=2000;
[H,w]=freqz(h,1,nplot);
np=ceil(nplot*fp/0.5)+1;
ns=ceil(nplot*(0.5-fp)/0.5)+1;
ax=plotyy(w(1:np)*0.5/pi,20*log10(abs(H(1:np))), ...
          w(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -0.02 0]);
axis(ax(2),[0 0.5 -70 -50]);
strt=sprintf("Zahradnik and Vlcek half-band filter: n=%d, fp=%5.3f, as=%ddB", ...
             n,fp,as);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_fp_0_225_as_60"),"-dpdflatex");
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
[H,w]=freqz(h,1,2000);
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
% Use zahradnik_halfband with search
%
fp=0.225
as=-60;
[n,kp,Ap,Bp]=zahradnik_halfband_param(fp,as);
hn=zahradnik_halfband(n,kp);
hnm1=zahradnik_halfband(n-1,kp);
if 0
  % FIXME !?!?!?!
  zahradnik_halfband_hABsearch([],fp,n,kp,hn,hnm1);
  opt=optimset("MaxFunEvals",1e4,"MaxIter",1e4,"TolFun",1e-7,"TolX",1e-6);
  [X,Fval,ExitFlag,Output]=...
  fminsearch(@zahradnik_halfband_hABsearch,[Ap,Bp],opt)
  if ExitFlag==0
    error("Too many iterations or function evaluations");
  elseif ExitFlag==-1
    error("Iteration stopped");
  endif
  Ap=X(1);
  Bp=X(2);
endif
h=((Ap*hn)+(Bp*[0,0,hnm1,0,0]));
v01=sqrt((kp^2)+((1-(kp^2))*(cos(pi/((2*n)+1))^2)));
omega01=acos(v01);
H01=freqz(h,1,[0,omega01]);
if mod(n,2)
  Np=-2*abs(H01(2));
else
  Np=2*abs(H01(1));
endif
h=h/Np;
h((2*n)+2)=0.5;
[H,w]=freqz(h,1,2000);
np=ceil(nplot*fp/0.5)+1;
ns=ceil(nplot*(0.5-fp)/0.5)+1;
ax=plotyy(w(1:np)*0.5/pi,20*log10(abs(H(1:np))), ...
          w(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
axis(ax(1),[0 0.5 -0.02 0]);
axis(ax(2),[0 0.5 -70 -50]);
strt=sprintf("Zahradnik and Vlcek half-band filter (hn and hnm1): \
fp=%5.3f, as=%ddB" ,fp,as);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_hn_fp_0_225_as_60"),"-dpdflatex");
close

%
% Reproduce Figures 6 and 7
%
fp=0.225;
as=-120;
[n120,kp,Ap,Bp]=zahradnik_halfband_param(fp,as)
hn=zahradnik_halfband(n120,kp);
hnm1=zahradnik_halfband(n120-1,kp);
h120=((Ap*hn)+(Bp*[0,0,hnm1,0,0]));
v01=sqrt((kp^2)+((1-(kp^2))*(cos(pi/((2*n120)+1))^2)));
omega01=acos(v01);
H01=freqz(h120,1,[0,omega01]);
if mod(n120,2)
  Np=-2*abs(H01(2));
else
  Np=2*abs(H01(1));
endif
h120=h120/Np;
h120((2*n120)+2)=0.5;

[H,w]=freqz(h120,1,2000);
np=ceil(nplot*fp/0.5)+1;
ns=ceil(nplot*(0.5-fp)/0.5)+1;
ax=plotyy(w(1:np)*0.5/pi,20*log10(abs(H(1:np))), ...
          w(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
axis(ax(1),[0 0.5 -1e-6 0]);
axis(ax(2),[0 0.5 -130 -110]);
strt=sprintf("Zahradnik and Vlcek half-band filter: fp=%5.3f, as=%ddB, n=%d",
             fp,as,n);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_fp_0_225_as_120"),"-dpdflatex");
close

%
% Try harder
%
fp=0.225;
as=-140;
[n140,kp,Ap,Bp]=zahradnik_halfband_param(fp,as)
hn=zahradnik_halfband(n140,kp);
hnm1=zahradnik_halfband(n140-1,kp);
h140=((Ap*hn)+(Bp*[0,0,hnm1,0,0]));
v01=sqrt((kp^2)+((1-(kp^2))*(cos(pi/((2*n140)+1))^2)));
omega01=acos(v01);
H01=freqz(h140,1,[0,omega01]);
if mod(n140,2)
  Np=-2*abs(H01(2));
else
  Np=2*abs(H01(1));
endif
h140=h140/Np;
h140((2*n140)+2)=0.5;

[H,w]=freqz(h140,1,2000);
np=ceil(nplot*fp/0.5)+1;
ns=ceil(nplot*(0.5-fp)/0.5)+1;
ax=plotyy(w(1:np)*0.5/pi,20*log10(abs(H(1:np))), ...
          w(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
axis(ax(1),[0 0.5 -1e-6 2e-7]);
axis(ax(2),[0 0.5 -150 -132]);
strt=sprintf("Zahradnik and Vlcek half-band filter: fp=%5.3f, as=%ddB, n=%d",
             fp,as,n140);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_fp_0_225_as_140"),"-dpdflatex");
close

% Save results
print_polynomial([h120(1:2:((2*n120)+1)),h140((2*n120)+2)], ...
                 "h_distinct",sprintf("%s_fp_0_225_as_120_coef.m",strf));
print_polynomial([h140(1:2:((2*n140)+1)),h140((2*n140)+2)], ...
                 "h_distinct",sprintf("%s_fp_0_225_as_140_coef.m",strf));

% Done
diary off
movefile zahradnik_halfband_test.diary.tmp zahradnik_halfband_test.diary;
