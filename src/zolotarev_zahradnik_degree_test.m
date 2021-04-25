% zolotarev_zahradnik_degree_test.m
%
% Test the degree equation for the Zolotarev functions of Zahradnik et al.:
%  [1] "Cascade Structure of Narrow Equiripple Bandpass FIR Filters",
%      P.Zahradnik, M.Susta, B.Simak and M.Vlcek, IEEE Transactions on Circuits
%      and Systems-II:Express Briefs, Vol. 64, No. 4, April 2017, pp 407-411
%
% Copyright (C) 2019-2021 Robert G. Jenssen

test_common;

pkg load optim;

delete("zolotarev_zahradnik_degree_test.diary");
delete("zolotarev_zahradnik_degree_test.diary.tmp");
diary zolotarev_zahradnik_degree_test.diary.tmp

strf="zolotarev_zahradnik_degree_test";

function err=zolotarev_zahradnik_degree_test_ksearch ...
               (arg,_fm,_apdB,_asdB,_Deltafp,_Deltafs,_scale)
  persistent k0 fm apdB asdB Deltafp Deltafs wm wp1 wp2 ws1 ws2 phis phip scale
  persistent init_done=false
  if nargin==7
    k0=arg;
    fm=_fm;
    apdB=_apdB;
    asdB=_asdB;
    Deltafp=_Deltafp;
    Deltafs=_Deltafs;
    scale=_scale;
    wp1=cos((fm-(Deltafp/2))*2*pi);
    wp2=cos((fm+(Deltafp/2))*2*pi);
    phis=(fm+(Deltafs/2))*pi;
    init_done=true;
  elseif nargin~=1
    init_done=false;
    print_usage("err=zolotarev_zahradnik_degree_test_ksearch ...\n\
      (arg[k0 or del],fm,apdB,asdB,Deltafp,Deltafs,scale)");
  elseif init_done==false
    error("init_done==false");
  endif
  del=arg;
  k=k0+(del/scale);
  if k<=0 || k>=1
    err=inf;
    return;
  endif 
  % Calculate n for this k 
  u0=elliptic_F(phis,k);
  [snu0,cnu0]=ellipj(u0,k^2);
  scu0wp1=(snu0/cnu0)*sqrt((1+wp1)/(1-wp1));
  uasnwp1=j*arcsn(scu0wp1,sqrt(1-(k^2)));
  Tpwp1=jacobi_Theta(real(uasnwp1)+u0,k);
  Tmwp1=jacobi_Theta(real(uasnwp1)-u0,k);
  est_n=acosh((2*(10^((apdB-asdB)/20)))-1)/log(Tpwp1/Tmwp1);
  % Compare the responses at wp1 and wp2 with this n
  n=ceil(est_n);
  K=ellipke(k^2);
  p=round(u0*n/K);
  q=n-p;
  u0=p*K/n;
  [snu0,cnu0,dnu0]=ellipj(u0,k^2);
  Zu0=jacobi_Zeta(u0,k);
  scu0wp1=(snu0/cnu0)*sqrt((1+wp1)/(1-wp1));
  uasnwp1=j*arcsn(scu0wp1,sqrt(1-(k^2)));
  Tpwp1=jacobi_Theta(real(uasnwp1)+u0,k);
  Tmwp1=jacobi_Theta(real(uasnwp1)-u0,k); 
  scu0wp2=(snu0/cnu0)*sqrt((1+wp2)/(1-wp2));
  uasnwp2=j*arcsn(scu0wp2,sqrt(1-(k^2)));
  Tpwp2=jacobi_Theta(real(uasnwp2)+u0,k);
  Tmwp2=jacobi_Theta(real(uasnwp2)-u0,k);
  err=abs((Tpwp1/Tmwp1)-(Tpwp2/Tmwp2));
  printf("search: k0=%f,del=%f,k=%f,n=%d,p=%d,q=%d,T1=%f,T2=%f,err=%f\n",
         k0,del,k,n,p,q,(Tpwp1/Tmwp1),(Tpwp2/Tmwp2),err);
endfunction

%
% Equation 7
%
p=100;
,q=37;
k=0.4;
n=p+q;
% Calculate Zpq with Chen-Parks
[u,x,f,um,xm,fmax]=zolotarev_chen_parks(k,n,p);
K=ellipke(k^2);
qKn=q*K/n;
snqKn=ellipj(qKn,k^2);
wp=(2*(snqKn^2))-1;
fp=acos(wp)*0.5/pi;
u0=p*K/n;
[snu0,cnu0,dnu0]=ellipj(u0,k^2);
ws=1-(2*(snu0^2));
fs=acos(ws)*0.5/pi;
Zu0=jacobi_Zeta(u0,k);
wm=ws+(2*snu0*cnu0*Zu0/dnu0);
[snu,cnu]=ellipj(u,k^2);
w=(((snu*cnu0).^2)+((cnu*snu0).^2))./((snu.^2)-(snu0^2));
if max(abs(imag(w)))>eps
  error("max(abs(imag(w)))>eps");
endif
% Calculate Zpq with Zahradnik et al. Equation 7
Hp=jacobi_Eta(u+u0,k);
Hm=jacobi_Eta(u-u0,k);
Hpm=Hp./Hm;
Zpq=((-1)^p)*cosh(n*log(Hpm));
if max(abs(real(f)-real(Zpq)))>1e4*eps
  error("max(abs(real(f)-real(Zpq)))>1e4*eps");
endif
if max(abs(imag(Zpq)))>2e400*eps
  error("max(abs(imag(Zpq)))>2e4*eps");
endif
plot(real(w),(1+real(Zpq))/(1+fmax));
axis([-1.05 1.05 -0.05 1.05]);
strt=sprintf("Normalised Zolotarev polynomial $Z_{%d,%d}(w,%3.1f)$ : \
$ws_{1}$=%7.4f, $wm$=%7.4f, $ws_{2}$=%7.4f, fmax=%7.4f",p,q,k,wp,wm,ws,fmax);
title(strt);
ylabel("Amplitude");
xlabel("$w$");
grid("on");
strfn=sprintf("%s_p_100_q_37",strf);
print(strfn,"-dpdflatex");
close

% Calculate Zpq as zero-phase FIR filter response with backwards recurrence
a=zolotarev_vlcek_unbehauen(p,q,k);
Za=chebyshevT_backward_recurrence(a);
Qzptf=polyval(Za,w);
if max(abs(Qzptf-Zpq))>1e36
  warning("max(abs(Qzptf-Zpq))>1e36");
endif
% Calculate Zpq as zero-phase FIR filter response with freqz
a=zolotarev_vlcek_unbehauen(p,q,k);
ha=zeros(1,(2*(p+q))+1);
c=p+q+1;
ha(c)=a(1);
ha(1:(c-1))=fliplr(a(2:end))/2;
ha((c+1):end)=a(2:end)/2;
[Ha,wa]=freqz(ha,1,acos(w));
Qfreqz=Ha.*exp(j*wa*(c-1));
if max(abs(Qfreqz-Zpq))>1e6*eps
  error("max(abs(Qfreqz-Zpq))>1e6*eps");
endif
% Calculate sigma_m with Zahradnik et al. Equation 10
smax=elliptic_F(asin(sqrt(Zu0/(((k^2)*snu0)*((cnu0*dnu0)+(snu0*Zu0))))),k);
% Chen and Parks Equation A6:
ymax=cosh(n*log(jacobi_Theta(smax+u0,k)/jacobi_Theta(smax-u0,k)));
if abs(ymax-fmax)>2e-12
  error("abs(ymax-fmax)>2e-12");
endif
  
%
% Check arcsc and arcsn using values of n and k from Example 1
%
% From Example 1:
fm=0.135;apdB=-3;asdB=-80;Deltafp=0.015;Deltafs=0.05;
% n and k are given in the text
n=57;k=0.80203834;
%
k2=k^2;
kp2=1-k2;
kp=sqrt(kp2);
K=ellipke(k2);
Kp=ellipke(kp2);
phis=(fm+(Deltafs/2))*pi;
phip=(0.5-(fm-(Deltafs/2)))*pi;
p=round(elliptic_F(phis,k)*n/K);
q=n-p;
[u,x,f,um,xm,fmax]=zolotarev_chen_parks(k,n,p);
u0=p*K/n;
[snu0,cnu0,dnu0]=ellipj(u0,k2);
[snu,cnu]=ellipj(u,k2);
w=(((snu*cnu0).^2)+((cnu*snu0).^2))./((snu.^2)-(snu0^2));
wp1=cos((fm-(Deltafp/2))*2*pi);
wp2=cos((fm+(Deltafp/2))*2*pi);
wmax=min(find(real(w)>wp1));
wmin=max(find(real(w)<wp2));
umm=u(wmin:wmax);
wmm=w(wmin:wmax);
scu0w=(snu0/cnu0)*sqrt((1+wmm)./(1-wmm));
uasc=zeros(size(umm));
uasn=zeros(size(umm));
for l=1:length(umm)
  uasc(l)=arcsc(j*scu0w(l),k);
  uasn(l)=j*arcsn(scu0w(l),kp);
endfor
% Compare arcsc to u
if max(abs(uasc-umm))>10*eps
  error("max(abs(uasc-umm))>10*eps");
endif
% Compare arcsn to u
if max(abs(uasn-umm))>10*eps
  error("max(abs(uasn-umm))>10*eps");
endif
% Compare a 3rd order polynomial fit of real(umm) (imag(umm) is jK')
pwu=polyfit(wmm,real(umm),3);
upwu=polyval(pwu,wmm);
if max(abs(upwu-real(umm)))>1e-4
  error("max(abs(upwu-real(umm)))>1e-4");
endif
% Compare Eta and Theta function in the main lobe
Hp=jacobi_Eta(umm+u0,k);
Hm=jacobi_Eta(umm-u0,k);
HHn=(Hp./Hm).^n;
Tp=jacobi_Theta(real(umm)+u0,k);
Tm=jacobi_Theta(real(umm)-u0,k);
TTn=((-1)^p)*((Tp./Tm).^n);
if ~all(isreal(TTn))
  error("~all(isreal(TTn))");
endif
if max(abs(imag(HHn)))>1e-9
  error("max(abs(imag(HHn)))>1e-9");
endif
if max(abs(real(TTn-HHn)))>2e-9
  error("max(abs(real(TTn-HHn)))>2e-9");
endif

%
% Example 1 : pass band constraints
%
clear -x strf
% Initial specification
fm=0.135;apdB=-3;asdB=-80;Deltafp=0.015;Deltafs=0.05;
fp1=fm-(Deltafp/2);
fp2=fm+(Deltafp/2);
fs1=fm-(Deltafs/2);
fs2=fm+(Deltafs/2);
phis=(fm+(Deltafs/2))*pi;
phip=(0.5-(fm-(Deltafs/2)))*pi;
k0=sqrt(1-(cot(phip)*cot(phis))^2);
wm=cos(fm*2*pi);
wp1=cos(fp1*2*pi);
wp2=cos(fp2*2*pi);
ws1=cos(fs1*2*pi);
ws2=cos(fs2*2*pi);

% Solve Equation 13 for k
tol=1e-8;maxiter=1e2;scale=100;
% Initial estimate of k
k0=sqrt(1-(cot(phip)*cot(phis))^2);
err=zolotarev_zahradnik_degree_test_ksearch ...
      (k0,fm,apdB,asdB,Deltafp,Deltafs,scale);
tolx=1e-6;tolf=1e-12;maxiter=1e3;
opt=optimset("MaxFunEvals",maxiter,"MaxIter",maxiter,"TolFun",tolf,"TolX",tolx);
[del,Fval,ExitFlag,Output]= ...
  fminsearch(@zolotarev_zahradnik_degree_test_ksearch,1,opt)
if ExitFlag==0
  error("Too many iterations or function evaluations");
elseif ExitFlag==-1
  error("Iteration stopped");
endif
k=k0+(del/scale);

% Estimate n with (corrected) Equation 14
K=ellipke(k^2);
Kp=ellipke(1-(k^2));
u0=elliptic_F(phis,k);
[snu0,cnu0,dnu0]=ellipj(u0,k^2);
Zu0=jacobi_Zeta(u0,k);
scu0wp1=(snu0/cnu0)*sqrt((1+wp1)/(1-wp1));
uasnwp1=j*arcsn(scu0wp1,sqrt(1-(k^2)));
Tpwp1=jacobi_Theta(real(uasnwp1)+u0,k);
Tmwp1=jacobi_Theta(real(uasnwp1)-u0,k);
est_n=acosh((2*(10^((apdB-asdB)/20)))-1)/log(Tpwp1/Tmwp1);

% Plot the response. u0 is adjusted for integral values of p and q
n=ceil(est_n);
p=round(u0*n/K);
q=n-p;
printf("Example 1 pass band constraints : k=%12.10f,n=%d,p=%d,q=%d\n",k,n,p,q);
u0=p*K/n;
[snu0,cnu0,dnu0]=ellipj(u0,k^2);
Zu0=jacobi_Zeta(u0,k);
% Chen and Parks Equation A6:
smax=elliptic_F(asin(sqrt(Zu0/(((k^2)*snu0)*((cnu0*dnu0)+(snu0*Zu0))))),k);
ymax=cosh(n*log(jacobi_Theta(smax+u0,k)/jacobi_Theta(smax-u0,k)));
umax=smax+(j*Kp);
[snumax,cnumax]=ellipj(umax,k^2);
wmax=real((((snumax*cnu0).^2)+((cnumax*snu0).^2))./((snumax.^2)-(snu0^2)));
fmax=acos(wmax)*0.5/pi;
printf("fm=%5.3f,Deltafp=%5.3f,k0=%10.8f,k=%10.8f,fmax=%10.8f,ymax=%10.4f\n",
       fm,Deltafp,k0,k,fmax,ymax);
% Find normalised impulse response
a=zolotarev_vlcek_unbehauen(p,q,k);
ha=zeros(1,(2*(p+q))+1);
c=p+q+1;
ha(c)=a(1)+1;
ha(1:(c-1))=fliplr(a(2:end))/2;
ha((c+1):end)=a(2:end)/2;
ha=ha/(1+ymax);
% Plot transfer function
[Ha,wa]=freqz(ha,1,2^14);
plot(wa*0.5/pi,20*log10(abs(Ha)));
axis([0 0.5 -120 5]);
grid("on");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strt=sprintf("$Z_{%d,%d}(w,%10.8f)$ : $f_{p1}=%6.4f,$f_{m}$=%5.3f,\
$f_{p2}$=%6.4f,$a_{pdB}$=%d,$a_{sdB}$=%d,$f_{max}$=%6.4f", ...
             p,q,k,fp1,fm,fp2,apdB,asdB,fmax);
title(strt);
strfn=sprintf("%s_fmax_135_Deltafp_015",strf);
print(strfn,"-dpdflatex");
close
plot(wa*0.5/pi,20*log10(abs(Ha)));
axis([floor(fp1*100)/100 ceil(fp2*100)/100 -4 1]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
title(strt);
print(sprintf("%s_pass",strfn),"-dpdflatex");
close
print_polynomial(ha,"ha",sprintf("%s_coef.m",strfn),"%17.10e");

%
% Example 1 : stop band constraints
%
k=k0;
K=ellipke(k^2);
Kp=ellipke(1-(k^2));
u0=elliptic_F(phis,k);
[snu0,cnu0,dnu0]=ellipj(u0,k^2);
Zu0=jacobi_Zeta(u0,k);
smax=elliptic_F(asin(sqrt(Zu0/(((k^2)*snu0)*((cnu0*dnu0)+(snu0*Zu0))))),k);
est_n=log((2*(10^(-asdB/20)))-1+sqrt((((2*(10^(-asdB/20)))-1)^2)-1)) ...
      /log((jacobi_Theta(smax+u0,k)/jacobi_Theta(smax-u0,k)));
% Compare with acosh:
est_np=acosh(2*(10^(-asdB/20))-1)...
       /log((jacobi_Theta(smax+u0,k)/jacobi_Theta(smax-u0,k)));
if abs(est_n-est_np)>eps
  error("abs(est_n-est_np)>eps")
endif
% Plot the response. u0 is adjusted for integral values of p and q
n=ceil(est_n);
p=round(u0*n/K);
q=n-p;
printf("Example 1 stop band constraints : k=%12.10f,n=%d,p=%d,q=%d\n",k,n,p,q);
u0=p*K/n;
[snu0,cnu0,dnu0]=ellipj(u0,k^2);
Zu0=jacobi_Zeta(u0,k);
% Chen and Parks Equation A6:
smax=elliptic_F(asin(sqrt(Zu0/(((k^2)*snu0)*((cnu0*dnu0)+(snu0*Zu0))))),k);
ymax=cosh(n*log(jacobi_Theta(smax+u0,k)/jacobi_Theta(smax-u0,k)));
umax=smax+(j*Kp);
[snumax,cnumax]=ellipj(umax,k^2);
wmax=real((((snumax*cnu0).^2)+((cnumax*snu0).^2))./((snumax.^2)-(snu0^2)));
fmax=acos(wmax)*0.5/pi;
% Find normalised impulse response
a=zolotarev_vlcek_unbehauen(p,q,k);
ha=zeros(1,(2*(p+q))+1);
c=p+q+1;
ha(c)=a(1)+1;
ha(1:(c-1))=fliplr(a(2:end))/2;
ha((c+1):end)=a(2:end)/2;
ha=ha/(1+ymax);
% Plot transfer function
[Ha,wa]=freqz(ha,1,2^14);
plot(wa*0.5/pi,20*log10(abs(Ha)));
axis([0 0.5 -120 5]);
grid("on");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strt=sprintf("$Z_{%d,%d}(w,%10.8f)$ : \
$f_{p1}=%6.4f,$f_{m}$=%5.3f,$f_{p2}$=%6.4f,$a_{sdB}$=%d,$f_{max}$=%6.4f", ...
             p,q,k,fp1,fm,fp2,asdB,fmax);
title(strt);
strfn=sprintf("%s_fmax_135_Deltafs_050",strf);
print(strfn,"-dpdflatex");
close
print_polynomial(ha,"ha",sprintf("%s_coef.m",strfn),"%17.10e");

%
% Example 2
%
clear -x strf 
% Initial specification
fm=0.275;apdB=-6;asdB=-140;Deltafp=0.00035;Deltafs=0.0015;
fp1=fm-(Deltafp/2);
fp2=fm+(Deltafp/2);
fs1=fm-(Deltafs/2);
fs2=fm+(Deltafs/2);
wm=cos(fm*2*pi);
wp1=cos(fp1*2*pi);
wp2=cos(fp2*2*pi);
ws1=cos(fs1*2*pi);
ws2=cos(fs2*2*pi);
phis=fs2*pi;
phip=(0.5-fs1)*pi;
k0=sqrt(1-(cot(phip)*cot(phis))^2);

% Stop band constraint
k=k0;
K=ellipke(k^2);
Kp=ellipke(1-(k^2));
u0=elliptic_F(phis,k);
[snu0,cnu0,dnu0]=ellipj(u0,k^2);
Zu0=jacobi_Zeta(u0,k);
smax=elliptic_F(asin(sqrt(Zu0/(((k^2)*snu0)*((cnu0*dnu0)+(snu0*Zu0))))),k);
est_n=log((2*(10^(-asdB/20)))-1+sqrt((((2*(10^(-asdB/20)))-1)^2)-1)) ...
      /log((jacobi_Theta(smax+u0,k)/jacobi_Theta(smax-u0,k)));

% Plot the response. u0 is adjusted for integral values of p and q
n=ceil(est_n);
p=round(u0*n/K);
q=n-p;
printf("Example 2 : k=%12.10f,n=%d,p=%4d,q=%4d\n",k,n,p,q);
u0=p*K/n;
[snu0,cnu0,dnu0]=ellipj(u0,k^2);
Zu0=jacobi_Zeta(u0,k);
% Chen and Parks Equation A6:
smax=elliptic_F(asin(sqrt(Zu0/(((k^2)*snu0)*((cnu0*dnu0)+(snu0*Zu0))))),k);
ymax=cosh(n*log(jacobi_Theta(smax+u0,k)/jacobi_Theta(smax-u0,k)));
umax=smax+(j*Kp);
[snumax,cnumax]=ellipj(umax,k^2);
wmax=real((((snumax*cnu0).^2)+((cnumax*snu0).^2))./((snumax.^2)-(snu0^2)));
fmax=acos(wmax)*0.5/pi;
% Find normalised impulse response
a=zolotarev_vlcek_unbehauen(p,q,k);
ha=zeros(1,(2*(p+q))+1);
c=p+q+1;
ha(c)=a(1)+1;
ha(1:(c-1))=fliplr(a(2:end))/2;
ha((c+1):end)=a(2:end)/2;
ha=ha/(1+ymax);
% Plot transfer function
[Ha,wa]=freqz(ha,1,2^12);
plot(wa*0.5/pi,20*log10(abs(Ha)));
axis([0 0.5 -160 5]);
grid("on");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strt=sprintf("$Z_{%d,%d}(w,%10.8f)$ : \
$f_{p1}$=%8.6f,$f_{m}$=%5.3f,$f_{p2}$=%8.6f,$a_{sdB}$=%d,$f_{max}$=%8.6f", ...
             p,q,k,fp1,fm,fp2,asdB,fmax);
title(strt);
strfn=sprintf("%s_fmax_275_asdB_140",strf);
print(strfn,"-dpdflatex");
close
% Detailed plot
del=(fs2-fs1+(2*Deltafs))/(2^12);
wa=((fs1-Deltafs):del:(fs2+Deltafs))*2*pi;
[Ha,wa]=freqz(ha,1,wa);
subplot(211)
plot(wa*0.5/pi,20*log10(abs(Ha)));
axis([0.2748 0.2752 -5 1]);
grid("on");
ylabel("Amplitude(dB)");
xlabel("Frequency");
title(strt);
subplot(212)
plot(wa*0.5/pi,20*log10(abs(Ha)));
axis([0.273 0.277 -140.1 -139.9]);
grid("on");
ylabel("Amplitude(dB)");
xlabel("Frequency");
print(sprintf("%s_detail",strfn),"-dpdflatex");
close
% Save
print_polynomial(ha,"ha",sprintf("%s_coef.m",strfn),"%17.10e");

% Done
diary off
movefile zolotarev_zahradnik_degree_test.diary.tmp ...
         zolotarev_zahradnik_degree_test.diary;
