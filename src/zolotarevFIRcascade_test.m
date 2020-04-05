% zolotarevFIRcascade_test.m
%
% Test Zahradnik et al.s cascade FIR narrow-band Zolotarev filter.
% [1] "Cascade Structure of Narrow Equiripple Bandpass FIR Filters",
% P.Zahradnik, M.Susta, B.Simak and M.Vlcek, IEEE Transactions on Circuits
% and Systems-II:Express Briefs, Vol. 64, No. 4, April 2017, pp. 407-411
% 
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("zolotarevFIRcascade_test.diary");
delete("zolotarevFIRcascade_test.diary.tmp");
diary zolotarevFIRcascade_test.diary.tmp

strf="zolotarevFIRcascade_test";

% Test conjugate Jacobi Eta functions
fp=0.1;fs=0.15;asdB=-10;
phip=(0.5-fp)*pi;
phis=fs*pi;
wp=cos(fp*2*pi);
ws=cos(fs*2*pi);
k=sqrt(1-(cot(phip)*cot(phis))^2);
K=ellipke(k^2);
Kp=ellipke(1-(k^2));
u0=elliptic_F(phis,k);
[snu0,cnu0,dnu0]=ellipj(u0,k^2);
Zu0=jacobi_Zeta(u0,k);
sm=elliptic_F(asin(sqrt(Zu0/(((k^2)*snu0)*((cnu0*dnu0)+(snu0*Zu0))))),k);
est_n= ...
  acosh(2*(10^(-asdB/20))-1)/log((jacobi_Theta(sm+u0,k)/jacobi_Theta(sm-u0,k)));
n=ceil(est_n);
p=round(u0*n/K);
q=n-p;
u0=p*K/n;

nf=400;
u1=j*Kp*(0:nf)/nf;
u2=(K*(1:nf)/nf)+(j*Kp);
u3=K+(j*Kp*((nf-1):-1:0)/nf);
Tu1pu0=jacobi_Theta(u1+u0,k);
Tu1mu0=jacobi_Theta(u1-u0,k);
Hu1pu0=jacobi_Eta(u1+u0,k);
Hu1mu0=jacobi_Eta(u1-u0,k);
Hu2pu0=jacobi_Eta(u2+u0,k);
Hu2mu0=jacobi_Eta(u2-u0,k);
Hu3pu0=jacobi_Eta(u3+u0,k);
Hu3mu0=jacobi_Eta(u3-u0,k);

if max(abs(Hu1pu0+conj(Hu1mu0)))>eps
  error("max(abs(Hu1pu0+conj(Hu1mu0)))>eps");
endif
if max(imag((Hu2pu0./Hu2mu0)+(Hu2mu0./Hu2pu0)))>2*eps
  error("max(imag((Hu2pu0./Hu2mu0)+(Hu2mu0./Hu2pu0)))>2*eps");
endif
if max(abs(Hu3pu0-conj(Hu3mu0)))>20*eps
  error("max(abs(Hu3pu0-conj(Hu3mu0)))>20*eps");
endif

% Calculate Zpq
Zpq1=((-1)^p)*cosh(n*log((Hu1pu0./Hu1mu0)));
Zpq2=((-1)^p)*cosh(n*log((Hu2pu0./Hu2mu0)));
Zpq3=((-1)^p)*cosh(n*log((Hu3pu0./Hu3mu0)));
Zpq=[Zpq1,Zpq2,Zpq3];
if max(abs(imag(Zpq)))>2e5*eps
%  error("max(abs(imag(Zpq)))>2e5*eps");
endif
Zpq1=real(Zpq1);
Zpq2=real(Zpq2);
Zpq3=real(Zpq3);
Zpq=real(Zpq);

% Transform u to w
[snu1,cnu1]=ellipj(u1,k^2);
w1=(((snu1*cnu0).^2)+((cnu1*snu0).^2))./((snu1.^2)-(snu0^2));
[snu2,cnu2]=ellipj(u2,k^2);
w2=(((snu2*cnu0).^2)+((cnu2*snu0).^2))./((snu2.^2)-(snu0^2));
[snu3,cnu3]=ellipj(u3,k^2);
w3=(((snu3*cnu0).^2)+((cnu3*snu0).^2))./((snu3.^2)-(snu0^2));
u=[u1,u2,u3];
w=[w1,w2,w3];
if max(abs(imag(w)))>eps
  error("max(abs(imag(w)))>eps");
endif
w=real(w);

% Find Zpq with Eta function phase
Zpq1arg=((-1)^p)*cos(pi-(n*2*arg(Hu1pu0)));
if max(abs(Zpq1-Zpq1arg))>200*eps
  error("max(abs(Zpq1-Zpq1arg))>200*eps");
endif
Zpq3arg=((-1)^p)*cos(n*2*arg(Hu3pu0));
if max(abs(Zpq3-Zpq3arg))>200*eps
  error("max(abs(Zpq3-Zpq3arg))>200*eps");
endif

%
% Example of Chebyshev expansion
%
clear -x strf

k=0.75;p=7;q=5;
n=p+q;nf=200;nplot=2^10;

[wr,w,Q,twoargHp,wdr,Qdr,twoargHpdr,Zpqmax,wmax,wp,ws]= ...
  zolotarevFIRcascade_Q(nf,p,q,k);
[azs,hazs,Qazs,wQazs]=zolotarevFIRcascade_wr2T(wr,p,wmax,nplot);
Hazs_zero=freqz(hazs,1,acos(wr));
if max(abs(Hazs_zero))>1e4*eps
  error("max(abs(Hazs_zero))>1e4*eps");
endif

% Compare with multiplying out the roots of Q
bwr=1;
for l=1:length(wr)
  bwr=conv(bwr,[1 -wr(l)]);
endfor
bwr=fliplr(bwr)*((-1)^p);
c=p+q+1;
hbwr=zeros(1,(2*(p+q))+1);
for m=0:(p+q)
  hbwr(c-m:2:c+m)=hbwr(c-m:2:c+m)+(bwr(1+m)*bincoeff(m,0:m)/(2^m));
endfor
Hbwrmax=freqz(hbwr,1,[acos(wmax),0])(1);
hbwr=hbwr/abs(Hbwrmax);
Hbwr=freqz(hbwr,1,wQazs);
Qbwr=real(Hbwr.*(e.^(j*wQazs*(c-1))));
plot(wQazs*0.5/pi,Qbwr);
axis([0 0.5 0 1]);
Hbwr_zero=freqz(hbwr,1,acos(wr));
if max(abs(Hbwr_zero)) > 1e5*eps
  error("max(abs(Hbwr_zero)) > 1e5*eps");
endif
if max(abs(Qbwr-Qazs)) > 1e5*eps
  error("max(abs(Qbwr-Qazs)) > 1e5*eps");
endif

% Compare with Zpq 
[avu,bvu]=zolotarev_vlcek_unbehauen(p,q,k);
% Convert avu to Qavu
c=p+q+1;
havu=zeros(1,(2*(p+q))+1);
havu(c)=avu(1)+1;
havu(1:(c-1))=fliplr(avu(2:end))/2;
havu((c+1):end)=avu(2:end)/2;
havu=havu/(1+Zpqmax);
Havu=freqz(havu,1,wQazs);
Qavu=real(Havu.*(e.^(j*wQazs*(c-1))));
plot(wQazs*0.5/pi,Qavu);
axis([0 0.5 0 1]);
Havu_zero=freqz(havu,1,acos(wr));
if max(abs(Havu_zero)) > 100*eps
  error("max(abs(Havu_zero)) > 100*eps");
endif
if max(abs(Qazs-Qavu)) > 1e7*eps
  error("max(abs(Qazs-Qavu)) > 1e7*eps");
endif

% Convert bvu to Qbvu
c=p+q+1;
hbvu=zeros(1,(2*(p+q))+1);
for m=0:(p+q)
  hbvu(c-m:2:c+m)=hbvu(c-m:2:c+m)+(bvu(1+m)*bincoeff(m,0:m)/(2^m));
endfor
hbvu(c)=hbvu(c)+1;
hbvu=hbvu/(1+Zpqmax);
Hbvu=freqz(hbvu,1,wQazs);
Qbvu=real(Hbvu.*(e.^(j*wQazs*(c-1))));
plot(wQazs*0.5/pi,Qbvu);
axis([0 0.5 0 1]);
Hbvu_zero=freqz(hbvu,1,acos(wr));
if max(abs(Hbvu_zero)) > 2000*eps
  error("max(abs(Hbvu_zero)) > 1000*eps");
endif
if max(abs(Qbvu-Qazs)) > 1e7*eps
  error("max(abs(Qbvu-Qazs)) > 1e7*eps");
endif
if max(abs(Qbvu-Qavu)) > 1e4*eps
  error("max(abs(Qbvu-Qavu)) > 1e4*eps");
endif

%
% Reproduce Figure 2
%
clear -x strf
clf

nf=100;
k=0.75;
p=[7 7 8 8];
q=[5 4 5 4];
for l=1:4,
  n=p(l)+q(l);
  [wr,w,Q,twoargHp,wdr,Qdr,twoargHpdr]=zolotarevFIRcascade_Q(nf,p(l),q(l),k);

  [azs,hazs]=zolotarevFIRcascade_wr2T(wr,p(l));
  Hazs_zero=freqz(hazs,1,acos(wr));
  if max(abs(Hazs_zero))>1e6*eps
    error("max(abs(Hazs_zero))>1e6*eps");
  endif

  figure(1,"visible","off");
  subplot(2,2,l)
  plot(w,Q,wdr,Qdr,"or");
  axis([-1.05 1.05 -0.05 1.05]);
  xlabel("$w$");
  ylabel(sprintf("$Q_{%d,%d}(w,%4.2f)$",p(l),q(l),k));
  strt=sprintf("q=%d and p=%d",q(l),p(l));
  title(strt);
  grid("on");

  figure(2,"visible","off");
  subplot(2,2,l)
  h=plot(w,twoargHp*n/pi,wdr,twoargHpdr*n/pi,"or");
  axis([-1.05 1.05 -9 5]);
  xlabel("$w$");
  ylabel(sprintf("$2\\arg H(u+u_{0},%4.2f)(%d/\\pi)$",k,n));
  title(strt);
  grid("on");
endfor

figure(1,"visible","off");
print(sprintf("%s_Q_p_q",strf),"-dpdflatex");
close

figure(2,"visible","off");
print(sprintf("%s_argHupu0_p_q",strf),"-dpdflatex");
close

%
% Example 1
%
clear -x strf
fm=0.1505;Deltafs=0.01625;asdB=-20;
n=71;p=22;q=49;k=0.46850107;
nf=2000;
[wr,w,Q,twoargHp,wdr,Qdr,twoargHpdr,Zpqmax,wmax,wp,ws]= ...
  zolotarevFIRcascade_Q(nf,p,q,k);

% Plot Q
plot(w,Q)
axis([-1.05 1.05 -0.05 1.05]);
title(sprintf("$Q_{%d,%d}(w,%10.8f)$",p,q,k));
xlabel("$w$");
ylabel("Amplitude (dB)");
grid("on");
print(sprintf("%s_Q_%d_%d",strf,p,q),"-dpdflatex");
close

% Show detailed response at either end
subplot(311)
plot(w,Q,wdr,Qdr,"or")
axis([-1 -0.95 -0.01 0.11]);
title(sprintf("$Q_{%d,%d}(w,%10.8f)$",p,q,k));
grid("on");
subplot(312)
plot(w,Q,wdr,Qdr,"or"); 
axis([ws-0.05 wp+0.05 -0.05 1.05]);
grid("on");
subplot(313)
plot(w,Q,wdr,Qdr,"or");
axis([0.95 1 -0.01 0.11]);
xlabel("$w$");
grid("on");
print(sprintf("%s_Q_%d_%d_detail",strf,p,q),"-dpdflatex");
close

% Select zeros in subfilters and calculate subfilter impulse responses
m=4;
rho=zeros(1,m);
for l=1:m
  if mod(m,2)==mod(l,2)
    rho(l)=(m+l)/2;
  else
    rho(l)=(m-l+1)/2;
  endif
endfor
azs=cell(m,1);
hazs=cell(m,1);
hazsc=cell(m+1,1);
hazsc{1}=1;
Hazs=cell(m,1);
Hazsc=cell(m,1);
nplot=2^10;
for l=1:m,
  wrs=wr(rho(l):m:end);
  [azs{l},hazs{l},Hazs{l},wHazs]=zolotarevFIRcascade_wr2T(wrs,p,wmax,nplot);
  Hazs_zero=freqz(hazs{l},1,acos(wrs));
  if max(abs(Hazs_zero))>2e-8
    error("l=%d:max(abs(Hazs_zero))(%g)>2e-8",l,max(abs(Hazs_zero)));
  endif
  hazsc{l+1}=conv(hazsc{l},hazs{l});
  Hazsc{l}=freqz(hazsc{l+1},1,wHazs);
  print_polynomial ...
    (hazs{l},sprintf("h_%d",rho(l)), ...
     sprintf("%s_h_%d_%d_subfilter_%d_coef.m",strf,p,q,rho(l)),"%13.10f");
endfor

% Compare the final impulse response with Zpq
avu=zolotarev_vlcek_unbehauen(p,q,k);
c=p+q+1;
havu=zeros(1,(2*(p+q))+1);
havu(c)=avu(1)+1;
havu(1:(c-1))=fliplr(avu(2:end))/2;
havu((c+1):end)=avu(2:end)/2;
havu=havu/(1+Zpqmax);
if max(abs(havu-hazsc{m+1}))>1e-9
  error("max(abs(havu-hazsc{m+1}))>1e-9");
endif
print_polynomial(havu,"h",sprintf("%s_h_%d_%d_coef.m",strf,p,q),"%13.10f");

% Reproduce Figure 4
for l=1:m,
  subplot(m,2,(2*l)-1);
  plot(wHazs*0.5/pi,abs(Hazs{l}));
  title(sprintf("Subfilter m=%d",rho(l)));
  if l==m
    xlabel("Frequency");
  endif
  ylabel("Amplitude");
  grid("on");

  if l==1
    strt_start=sprintf("%%s cascade m=%d",rho(l));
    continue;
  else
    subplot(m,2,(2*l));
    plot(wHazs*0.5/pi,abs(Hazsc{l}));
    strt_start=strcat(strt_start,sprintf(",%d",rho(l)));
    if l==m
      xlabel("Frequency");
      strt=sprintf(strt_start,"Full");
    else
      strt=sprintf(strt_start,"Partial");
    endif
  endif 
  grid("on");
  title(strt);
  ylabel("Amplitude");
endfor
print(sprintf("%s_Q_%d_%d_subfilters",strf,p,q),"-dpdflatex");
close

%
% Example 2
%
clear -x strf
fm=0.4;Deltafs=0.00125;asdB=-80;
k=0.16238959;p=2159;q=540;

% Construct u
nf=1000;
y1=unique([(0:nf)/nf,logspace(-5,-2,nf)]);
nf=1000;
x2=(1:(nf-1))/nf;
nf=10000;
y3=fliplr(unique([(0:nf)/nf,logspace(-5,-log10(4),nf)]));
u.y1=y1;
u.x2=x2;
u.y3=y3;

[wr,w,Q,twoargHp,wdr,Qdr,twoargHpdr,Zpqmax,wmax,wp,ws]= ...
  zolotarevFIRcascade_Q(u,p,q,k);

% Compare with Zpq
avu=zolotarev_vlcek_unbehauen(p,q,k);
c=p+q+1;
havu=zeros(1,(2*(p+q))+1);
havu(c)=avu(1)+1;
havu(1:(c-1))=fliplr(avu(2:end))/2;
havu((c+1):end)=avu(2:end)/2;
havu=havu/(1+Zpqmax);
Havu=freqz(havu,1,acos(w));
Qavu=real(Havu.*(e.^(j*acos(w)*(p+q))));
if max(abs(Qavu-Q))>2e-7
  error("max(abs(Qavu-Q))>2e-7");
endif
print_polynomial(havu,sprintf("havu"), ...
                 sprintf("%s_h_%d_%d_coef.m",strf,p,q),"%13.10f");

% Plot Q
plot(w,20*log10(Q))
axis([-1.05 1.05 -100 5]);
title(sprintf("$Q_{%d,%d}(w,%10.8f)$",p,q,k));
xlabel("$w$");
ylabel("Amplitude (dB)");
grid("on");
print(sprintf("%s_Q_%d_%d",strf,p,q),"-dpdflatex");
close

% Show detailed response at either end
del=1e-4;
dr=[-0.05 1.05];
clf
subplot(311)
plot(w,Q,wdr,Qdr,"or")
axis([-1 -1+del del*dr]);
title(sprintf("$Q_{%d,%d}(w,%10.8f)$",p,q,k));
grid("on");
subplot(312)
plot(w,Q,wdr,Qdr,"or");
axis([ws-5*del wp+5*del dr]);
subplot(313)
plot(w,Q,wdr,Qdr,"or");
axis([1-del 1 del*dr]);
xlabel("$w$");
grid("on");
print(sprintf("%s_Q_%d_%d_detail",strf,p,q),"-dpdflatex");
close

subplot(111)
plot(wr);
axis([1 length(wr) -1.05 1.05]);
ylabel("Double zero location");
title(sprintf("Double zero locations of $Q_{%d,%d}(w,%10.8f)$ \
(%d on right, %d on left)", p,q,k,length(y1),length(y3)));
grid("on");
print(sprintf("%s_Q_%d_%d_zeros",strf,p,q),"-dpdflatex");
close

% Select zeros in subfilters and calculate subfilter impulse responses
m=3;
azs=cell(m,1);
hazs=cell(m,1);
hazsc=cell(m+1,1);
hazsc{1}=1;
Hazs=cell(m,1);
Hazsc=cell(m,1);
nplot=2^14;
for l=1:m,
  wrs=wr(l:m:end);
  [azs{l},hazs{l},Hazs{l},wHazs]=zolotarevFIRcascade_wr2T(wrs,p,wmax,nplot);
  Hazs_zero=freqz(hazs{l},1,acos(wrs));
  if max(abs(Hazs_zero))>2e-13
    error("l=%d:max(abs(Hazs_zero))(%g)>2e-13",l,max(abs(Hazs_zero)));
  endif
  hazsc{l+1}=conv(hazsc{l},hazs{l});
  Hazsc{l}=freqz(hazsc{l+1},1,wHazs);
  print_polynomial ...
    (hazs{l},sprintf("h_%d",l), ...
     sprintf("%s_h_%d_%d_subfilter_%d_coef.m",strf,p,q,l),"%13.10f");
endfor

% Compare havu with hazsc{4}
if max(abs(havu-hazsc{4}))>2e-10
  error("max(abs(havu-hazsc{4}))(%g)>2e-10",max(abs(havu-hazsc{4})));
endif

% Reproduce Figure 5
subplot(2,2,1);
plot(wHazs*0.5/pi,20*log10(abs(Hazs{1})));
axis([0 0.5 -100 20])
title("Subfilter m=1");
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
subplot(2,2,2);
plot(wHazs*0.5/pi,20*log10(abs(Hazs{2})));
axis([0 0.5 -100 20])
title("Subfilter m=2");
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
subplot(2,2,3);
plot(wHazs*0.5/pi,20*log10(abs(Hazs{3})));
axis([0 0.5 -100 20])
title("Subfilter m=3");
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
subplot(2,2,4);
plot(wHazs*0.5/pi,20*log10(abs(Hazsc{3})));
axis([0 0.5 -100 20])
title("Cascade of subfilters 1, 2 and 3");
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
print(sprintf("%s_Q_%d_%d_subfilters",strf,p,q),"-dpdflatex");
close

% Done
diary off
movefile zolotarevFIRcascade_test.diary.tmp zolotarevFIRcascade_test.diary;
