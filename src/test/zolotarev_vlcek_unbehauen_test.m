% zolotarev_vlcek_unbehauen_test.m
%
% Test the Vlcek and Unbehauen formula for the Zolotarev polynomials. See:
%  [1] "Zolotarev Polynomials and Optimal FIR Filters", M. Vlcek and
%       R. Unbehauen, IEEE Transactions on Signal Processing, Vol. 47,
%       No. 3, March, 1999, pp. 717-730
%  [2] Corrections to "Zolotarev Polynomials and Optimal FIR Filters",
%      M. Vlcek and R. Unbehauen, IEEE Transactions on Signal Processing,
%      Vol. 48, No.7, July, 2000 p. 2171
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("zolotarev_vlcek_unbehauen_test.diary");
delete("zolotarev_vlcek_unbehauen_test.diary.tmp");
diary zolotarev_vlcek_unbehauen_test.diary.tmp

strf="zolotarev_vlcek_unbehauen_test";

function err=zolotarev_vlcek_unbehauen_equation_7(f,n,wp,wm,ws)
  if nargin~=5 && nargout>1
    print_usage("err=zolotarev_vlcek_unbehauen_equation_7(f,n,wp,wm,ws)");
  endif
  f2=conv(f,f);
  fp=polyder(f);
  fp2=conv(fp,fp);
  lside=conv([-1,0,1],conv([1,-wp],conv([1,-ws],fp2)));
  rside1=(n^2)*conv([1,-wm],[1,-wm]);
  rside2=-(n^2)*conv(f2,conv([1,-wm],[1,-wm]));
  eqn7=[lside; ...
        [zeros(1,length(lside)-length(rside1)),-rside1]; ...
        [zeros(1,length(lside)-length(rside2)),-rside2]];
  err=sum(abs(sum(eqn7,1)));
endfunction

function err=zolotarev_vlcek_unbehauen_equation_63(f,n,wp,wm,ws)
  if nargin~=5 && nargout>1
    print_usage("err=zolotarev_vlcek_unbehauen_equation_63(f,n,wp,wm,ws)");
  endif
  fp=polyder(f);
  fpp=polyder(fp);
  g0=n*n*conv([1,-wm],conv([1,-wm],[1,-wm]));
  g1=conv([1,-wp],[1,-ws])-conv([1,-wm],[1,-(ws+wp)/2]);
  g2=conv([1,-wp],conv([1,-ws],[1,-wm]));
  term1=conv(g2,conv([-1,0,1],fpp));
  term2=conv(g2,conv([1,0],fp));
  term3=conv([-1,0,1],conv(g1,fp));
  term4=conv(g0,f);
  eqn63=[term1;-term2;-term3;term4];
  err=sum(abs(sum(eqn63,1)));
endfunction

%
% Reproduce Figure 1.
%
% Calculate u-to-x mapping and Zolotarev polynomial value
k=0.78;p=5;q=9;
[u,x,f,um,xm,fm,a,fa,b,fb]=zolotarev_chen_parks(k,p+q,p);
% Transform from x to w
K=ellipke(k^2);
u0=K*p/(p+q);
[snu0,cnu0]=ellipj(u0,k^2);
w=(x.*(cnu0^2))-(snu0.^2);
ws=(cnu0^2)-(snu0.^2);
wp=(a.*(cnu0^2))-(snu0.^2);
wm=(xm.*(cnu0^2))-(snu0.^2);
printf("p=%2d,q=%1d,k=%4.2f,wm=%13.10f,fm=%13.10f\nwp=%13.10f,ws=%13.10f\n",
       p,q,k,wm,fm,wp,ws);
% Plot w and f and maximum
plot(w,f,"-",[ws,ws],[-1,1],"-",[wm,wm],[-1,fm],"-",[wp,wp],[-1,1],"-");
axis([-1 1 -1 10]);
text(wp,-1.5,"$w_{p}$","horizontalalignment","center");
text(wm,-1.5,"$w_{m}$","horizontalalignment","center");
text(ws,-1.5,"$w_{s}$","horizontalalignment","center");
strt=sprintf(["Zolotarev polynomial $Z_{%d,%d}(w,%4.2f)$ (Vlcek and Unbehauen) : ", ...
 "$w_{p}=%6.4f$,$w_{m}=%6.4f$,$w_{s}=%6.4f$\n"],p,q,k,wp,wm,ws);
title(strt);
ylabel("Amplitude");
xlabel("$w$");
grid("on");
print(sprintf("%s_w_%d_%d",strf,p,q),"-dpdflatex");
close
% Find the coefficients in w^m
[~,b]=zolotarev_vlcek_unbehauen(p,q,k);
plot(b);
axis([1 (p+q+1)]);
strt=sprintf(["Zolotarev polynomial $Z_{%d,%d}(w,%4.2f)$ coefficients ", ...
 "(Vlcek and Unbehauen)"],p,q,k);
title(strt);
grid("on");
print(sprintf("%s_b_%d_%d",strf,p,q),"-dpdflatex");
close
% Find the z-domain impulse response
c=p+q+1;
h=zeros(1,(2*(p+q))+1);
for m=0:(p+q)
  h(c-m:2:c+m)=h(c-m:2:c+m)+(b(1+m)*bincoeff(m,0:m)/(2^m));
endfor
h=h/fm;
print_polynomial(h,sprintf("h_%d_%d",p,q),sprintf("%s_h_%d_%d_coef.m",strf,p,q));
plot(h);
axis([1 ((2*(p+q))+1)]);
strt=sprintf(["Zolotarev polynomial $Z_{%d,%d}(w,%4.2f)$ impulse response ", ...
 "(Vlcek and Unbehauen)"],p,q,k);
title(strt);
grid("on");
print(sprintf("%s_h_%d_%d",strf,p,q),"-dpdflatex");
close

%
% Confirm that the b power series in w satisfies Equation 7
%
% Set up an array of 2 rows, one for each side of equation 7. The
% columns correspond to powers of w and must sum to 0.
k=0.78;p=5;q=9;
n=p+q;
f=fliplr((b(:)'));
err=zolotarev_vlcek_unbehauen_equation_7(f,n,wp,wm,ws);
tol=6e-3;
if sum(abs(err)) > tol
  error("sum(abs(err)))(%g) > %g",sum(abs(err)),tol);
endif

%
% Confirm that the b power series in w satisfies Equation 63
%
n=p+q;
f=fliplr((b(:)'));
err=zolotarev_vlcek_unbehauen_equation_63(f,n,wp,wm,ws);
tol=5e-8;
if err > tol
  error("sum(abs(sum(eqn63,1)))(%g) > %g",err,tol);
endif

%
% Compare the Zolotarev polynomials calculated from the formula shown by
% Chen and Parks and the power series and Chebyshev expansions.
%
k=0.78;p=5;q=9;
%k=0.58;p=15;q=19;
n=p+q;
% Calculate the Zolotarev polynomial directly using Chen and Parks
[u,x,f,um,xm,fm,a,fa,b,fb]=zolotarev_chen_parks(k,p+q,p);
% Transform from x to w
K=ellipke(k^2);
u0=p*K/n;
[snu0,cnu0]=ellipj(u0,k^2);
wx=(x.*(cnu0^2))-(snu0.^2);
if max(imag(wx))>eps
  error("max(imag(wx))(%g)>eps",max(imag(wx)));
endif
wx=real(wx);
Zwx=f;
% Compare Zolotarev and Vlcek and Unbehauen Chebyshev expansion
[aa,Zb]=zolotarev_vlcek_unbehauen(p,q,k);
% Calculate the zero-phase response with Chebyshev backward recurrence.
% Numerical problems for long polynomials?
Zaa=chebyshevT_backward_recurrence(aa);
Zaawx=polyval(Zaa,wx);
% Compare Zolotarev and Vlcek and Unbehauen Chebyshev polynomial expansion
tol=1e-10;
if max(abs(Zaawx-Zwx))>tol
  error("max(abs(Zaawx-Zwx))(%g)>%g",max(abs(Zaawx-Zwx)),tol);
endif
% Calculate the zero-phase response with freqz
ha=zeros(1,(2*n)+1);
ha(n+1)=aa(1);
ha(1:n)=fliplr(aa(2:end)/2);
ha((n+2):end)=aa(2:end)/2;
Ha=freqz(ha,1,acos(wx));
Zawx=Ha.*e.^(j*n*acos(wx));
if max(abs(imag(Zawx)))>200*eps
  warning("max(abs(imag(Zawx)))(%g)>200*eps",max(abs(imag(Zawx))));
endif
Zawx=real(Zawx);
if max(abs(Zawx-Zwx))>2000*eps
  error("max(abs(Zawx-Zwx))(%g)>2000*eps",max(abs(Zawx-Zwx)));
endif
% Compare Zolotarev and Vlcek and Unbehauen power series expansion
% (This calculation has round-off and overflow problems for long filters!)
Zbwx=polyval(fliplr(Zb),wx);
if max(abs(Zbwx-Zwx))>5e-10
  error("max(abs(Zbwx-Zwx))(%g)>5e-10",max(abs(Zbwx-Zwx)));
endif

%
% b coefficients from Table VI
%
p=3;q=6;k=0.682;
[a,b]=zolotarev_vlcek_unbehauen(p,q,k);
print_polynomial(a,sprintf("a_%d_%d",p,q),sprintf("%s_a_%d_%d_coef.m",strf,p,q));
print_polynomial(a,sprintf("b_%d_%d",p,q),sprintf("%s_b_%d_%d_coef.m",strf,p,q));

%
% Expand the b power series in Chebyshev polynomials of the first kind
%
n=p+q;
alpha=chebyshevT_expand(fliplr(b));
tol=1e-12;
if max(abs(alpha-a))>tol
  error("max(abs(alpha-a))>%g",tol);
endif
alphaTvi=[ 0.098598, 0.097937,-0.098642,-0.193401,-0.093506, ...
           0.095518, 0.182318, 0.085744,-0.088768,-1.085798];
tol=1e-6;
if max(abs(alphaTvi-a))>tol
  error("max(abs(alphaTvi-a))>%g",tol);
endif
% Reverse
br=zeros(size(b));
for m=0:n,
  Tm=chebyshevT(m);
  Tm=fliplr(Tm);
  Tm=[Tm,zeros(1,columns(b)-columns(Tm))];
  br=br+(alpha(1+m)*Tm);
endfor
if max(abs(b-br))>eps
  error("max(abs(b-br))>eps");
endif

%
% a coefficients from Table VI
%
p=3;q=6;k=0.682;
[alpha,b]=zolotarev_vlcek_unbehauen(p,q,k);
M=length(alpha)-1;
ha=zeros(1,(2*M)+1);
ha(M+1)=alpha(1);
ha(1:M)=alpha(end:-1:2)/2;
ha((M+2):end)=alpha(2:end)/2;
[~,~,~,~,~,fm]=zolotarev_chen_parks(k,p+q,p);
ha=ha/fm;
% Compare with b coefficients
c=p+q+1;
hb=zeros(1,(2*(p+q))+1);
for m=0:(p+q)
  hb(c-m:2:c+m)=hb(c-m:2:c+m)+(b(1+m)*bincoeff(m,0:m)/(2^m));
endfor
hb=hb/fm;
tol=1e-12;
if max(abs(ha-hb))>tol
  error("max(abs(ha-hb))>%g",tol);
endif

%
% Confirm that the alpha coefficients from Table VI satisfy Equation 63
%
p=3;
q=6;
n=p+q;
k=0.682;
if 0
  wp=cos(0.2912*pi);
  ws=cos(0.3771*pi);
  wm=cos(0.3342*pi);
  wq=(wp+ws)/2;
else
  k2=k^2;
  K=ellipke(k2);
  n=p+q;
  u0=p*K/n;
  [snu0,cnu0,dnu0]=ellipj(u0,k2);
  Zu0=jacobi_Zeta(u0,k);
  wp=(2*((cnu0/dnu0)^2))-1;
  ws=(2*(cnu0^2))-1;
  wm=ws+(2*(snu0*cnu0)*Zu0/dnu0);
  wq=(wp+ws)/2;
endif
alphaTvi=zolotarev_vlcek_unbehauen(p,q,k);
f=zeros(size(alphaTvi));
for m=0:n,
  aT=alphaTvi(1+m)*chebyshevT(m);
  f=f+[zeros(1,columns(alphaTvi)-columns(aT)),aT];
endfor
err=zolotarev_vlcek_unbehauen_equation_7(f,n,wp,wm,ws);
tol=5e-8;
if err > tol
  error("sum(abs(sum(eqn7,1))) > %g",tol);
endif
err=zolotarev_vlcek_unbehauen_equation_63(f,n,wp,wm,ws);
tol=1e-10;
if err > tol
  error("sum(abs(sum(eqn63,1))) > %g",tol);
endif

%
% Reproduce Figure 4.
%
% Calculate the frequency response as a sum over w^m=(coswT)^m
p=5;q=15;k=0.77029;
[a,b]=zolotarev_vlcek_unbehauen(p,q,k);
print_polynomial(a,sprintf("a_%d_%d",p,q),...
                 sprintf("%s_a_%d_%d_coef.m",strf,p,q),"%15.6f");
print_polynomial(b,sprintf("b_%d_%d",p,q),...
                 sprintf("%s_b_%d_%d_coef.m",strf,p,q),"%15.6f");
nf=1000;
f=(0:(nf-1))'/(2*nf);
cosw_n=cos(2*pi*f).^(0:(p+q));
Hc=cosw_n*b(:);
Hc=Hc;
plot(f,Hc);
axis([0 0.5 -1 14]);
strt=sprintf("Zolotarev polynomial $Z_{%d,%d}(w,%7.5f)$ (Vlcek and Unbehauen)",
             p,q,k);
title(strt);
ylabel(sprintf("$Z_{%d,%d}(w,%7.5f)$",p,q,k));
xlabel("$w$");
grid("on");
print(sprintf("%s_f_%d_%d",strf,p,q),"-dpdflatex");
close
% Calculate z-domain impulse response as a sum over w^m=((z^(-1)+z)/2)^m
c=p+q+1;
[~,~,~,~,~,fm]=zolotarev_chen_parks(k,p+q,p);
% Using Chebyshev polynomial of the first kind expansion
ha=zeros(1,(2*(p+q))+1);
ha(c)=a(1);
ha(1:(c-1))=fliplr(a(2:end))/2;
ha((c+1):end)=a(2:end)/2;
ha=ha/fm;
% Using the power series in w
hb=zeros(1,(2*(p+q))+1);
for m=0:(p+q)
  hb(c-m:2:c+m)=hb(c-m:2:c+m)+(b(1+m)*bincoeff(m,0:m)/(2^m));
endfor
hb=hb/fm;
% Compare the two
tol=5e-9;
if max(abs(ha-hb))>tol
  error("max(abs(ha-hb))>%g",tol);
endif
% Choose the power series expansion
h=hb;
print_polynomial(h,sprintf("h_%d_%d",p,q),sprintf("%s_h_%d_%d_coef.m",strf,p,q));
plot(h);
axis([1 ((2*(p+q))+1)]);
strt=sprintf(["Zolotarev polynomial $Z_{%d,%d}(w,%7.5f)$ impulse response ", ...
 "(Vlcek and Unbehauen)"],p,q,k);
title(strt);
xlabel("$w$");
grid("on");
print(sprintf("%s_h_%d_%d",strf,p,q),"-dpdflatex");
close
% Calculate the frequency response corresponding to the impulse response
[H,w]=freqz(h,1,nf);
plot(w*0.5/pi,20*log10(abs(H)));
axis([0 0.5 -40 0]);
strt=sprintf(["Zolotarev polynomial $Z_{%d,%d}(w,%7.5f)$ frequency response ", ...
 "(Vlcek and Unbehauen)"],p,q,k);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(sprintf("%s_response_%d_%d",strf,p,q),"-dpdflatex");
close

%
% Design an FIR filter that approximates Figure 4
%
% Step 1: Initial specification
ifp=0.10;ifs=0.15;idelta=20;
% Step 2: Elliptic modulus (note correction for phip)
phip=(0.5-ifp)*pi;phis=ifs*pi;kp=cot(phip)*cot(phis);k=sqrt(1-(kp^2));
% Step 3: Search for n
qKn=elliptic_F(phip,k);
pKn=elliptic_F(phis,k);
ws=cos(2*pi*ifs);
u0=pKn;
[snu0,cnu0,dnu0]=ellipj(u0,k^2);
Zu0=jacobi_Zeta(u0,k);
wm=ws+(2*(snu0*cnu0)*Zu0/dnu0);
sm=elliptic_F(asin(sqrt((wm-ws)/(wm+1))/(k*snu0)),k);
% Estimate n
ym=(2*10^(idelta/20))-1;
est_n=log(ym+sqrt((ym^2)-1))/log(jacobi_Theta(sm+u0,k)/jacobi_Theta(sm-u0,k));
% Step 4: Find p and q
K=ellipke(k^2);
n=ceil(est_n);
p=round(n*u0/K);
q=n-p;
% Step 5: Calculate the actual values of wp,ws and wm
snqKn=ellipj(q*K/n,k^2);
wp=(2*(snqKn^2))-1;
fp=acos(wp)*0.5/pi;
[snpKn,cnpKn,dnpKn]=ellipj(p*K/n,k^2);
ws=1-(2*(snpKn^2));
fs=acos(ws)*0.5/pi;
ZpKn=jacobi_Zeta(p*K/n,k);
wm=ws+(2*snpKn*cnpKn*ZpKn/dnpKn);
[~,~,~,~,~,fm]=zolotarev_chen_parks(k,p+q,p);
fmax=acos(wm)*0.5/pi;
% Step 6: Calculate the scaled z-domain impulse response from 
[a,b]=zolotarev_vlcek_unbehauen(p,q,k);
c=p+q+1;
% Using Chebyshev polynomial of the first kind expansion
ha=zeros(1,(2*(p+q))+1);
ha(c)=a(1)+1;
ha(1:(c-1))=fliplr(a(2:end))/2;
ha((c+1):end)=a(2:end)/2;
ha=ha/(1+fm);
% Using the power series in w
hb=zeros(1,(2*(p+q))+1);
for m=0:(p+q)
  hb(c-m:2:c+m)=hb(c-m:2:c+m)+(b(1+m)*bincoeff(m,0:m)/(2^m));
endfor
hb(c)=hb(c)+1;
hb=hb/(1+fm);
% Compare the two
tol=6.5e-8;
if max(abs(ha-hb))>tol
  error("max(abs(ha-hb))>%g",tol);
endif
% Plot using the Chebyshev polynomial of the first kind expansion coefficients
h=ha;
print_polynomial(h,sprintf("h_%d_%d",p,q),sprintf("%s_fir_coef.m",strf));
printf("p=%d,q=%2d,k=%7.5f,fmax=%6.4f,fm=%6.4f(%6.4f dB),fp=%6.4f,fs=%6.4f\n",
       p,q,k,fmax,fm,20*log10(fm),fp,fs);
% Show response
[H,w]=freqz(h,1,nf);
plot(w*0.5/pi,20*log10(abs(H)));
axis([0 0.5 -40 0]);
strt=sprintf(["Normalised Zolotarev polynomial $Z_{%d,%d}(w,%7.5f)$ FIR filter ", ...
 "(Vlcek and Unbehauen) : fp=%6.4f,fmax=%6.4f,fs=%6.4f"], p,q,k,fp,fmax,fs);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(sprintf("%s_fir_response",strf),"-dpdflatex");
close
% ZPTF
Za=chebyshevT_backward_recurrence(a);
Wzptf=(-1:0.001:1);
Qzptf=polyval(Za,Wzptf);
plot(Wzptf,(1+Qzptf)/(1+fm));
axis([-1 1 -0.1 1]);
strt=sprintf(["Normalised Zolotarev polynomial $Z_{%d,%d}(w,%7.5f)$ ", ...
 "(Vlcek and Unbehauen)"],p,q,k);
title(strt);
ylabel("Amplitude");
xlabel("$w$");
grid("on");
print(sprintf("%s_fir_zptf",strf),"-dpdflatex");
close
% Show z-plane zeros
zplane(qroots(h),[]);
title(strt);
grid("on");
print(sprintf("%s_fir_pz",strf),"-dpdflatex");
close
% Save filter specification
fid=fopen(strcat(strf,"_fir_spec.m"),"wt");
fprintf(fid,"p=%d %% Zeros in lower stop-band\n",p);
fprintf(fid,"q=%d %% Zeros in upper stop-band\n",q);
fprintf(fid,"N=%d %% Degree of FIR polynomial\n",2*(p+q));
fprintf(fid,"k=%8.6f %% Elliptic modulus\n",k);
fprintf(fid,"fp=%8.6f %% Lower stop-band edge\n",fp);
fprintf(fid,"fmax=%8.6f %% Pass-band centre frequency\n",fmax);
fprintf(fid,"fs=%8.6f %% Upper stop-band edge\n",fs);
fprintf(fid,"delta=%8.6f %% Stop-band attenuation(dB)\n",20*log10(2/(1+fm)));
fclose(fid);

% Done
diary off
movefile zolotarev_vlcek_unbehauen_test.diary.tmp ...
         zolotarev_vlcek_unbehauen_test.diary;
