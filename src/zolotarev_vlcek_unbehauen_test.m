% zolotarev_vlcek_unbehauen_test.m
%
% Test the Vlcek and Unbehauen formula for the Zolotarev functions. See:
%  [1] "Zolotarev Polynomials and Optimal FIR Filters", M. Vlcek and
%       R. Unbehauen, IEEE Transactions on Signal Processing, Vol. 47,
%       No. 3, March, 1999, pp. 717-730
%  [2] Corrections to "Zolotarev Polynomials and Optimal FIR Filters",
%      M. Vlcek and R. Unbehauen, IEEE Transactions on Signal Processing,
%      Vol. 48, No.7, July, 2000 p. 2171
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("zolotarev_vlcek_unbehauen_test.diary");
unlink("zolotarev_vlcek_unbehauen_test.diary.tmp");
diary zolotarev_vlcek_unbehauen_test.diary.tmp

strf="zolotarev_vlcek_unbehauen_test";

%
% Reproduce Figure 1.
%
% Calculate u-to-x mapping and zolotarev function value
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
text(wp,-1.8,"$w_{p}$","horizontalalignment","center");
text(wm,-1.8,"$w_{m}$","horizontalalignment","center");
text(ws,-1.8,"$w_{s}$","horizontalalignment","center");
strt=sprintf("Zolotarev function (Vlcek and Unbehauen) : \
p=%2d,q=%1d,k=%4.2f,$w_{p}=%6.4f$,$w_{m}=%6.4f$,$w_{s}=%6.4f$\n",p,q,k,wp,wm,ws);
title(strt);
ylabel(sprintf("$Z_{%d,%d}(u,%7.5f)$",p,q,k));
xlabel("w");
grid("on");
print(sprintf("%s_w_%d_%d",strf,p,q),"-dpdflatex");
close
% Find the coefficients in w^m
b=zolotarev_vlcek_unbehauen(p,q,k);
plot(b);
axis([1 (p+q+1)]);
strt=sprintf("Zolotarev function (Vlcek and Unbehauen) coefficients :\
 p=%d, q=%d k=%4.2f",p,q,k);
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
strt=sprintf("Zolotarev function (Vlcek and Unbehauen) impulse response :\
 p=%d, q=%d k=%4.2f",p,q,k);
title(strt);
grid("on");
print(sprintf("%s_h_%d_%d",strf,p,q),"-dpdflatex");
close

%
% Reproduce Figure 4.
%
% Calculate the frequency response as a sum over w^m=(coswT)^m
p=5;q=15;k=0.77029;
b=zolotarev_vlcek_unbehauen(p,q,k);
nf=1000;
f=(0:(nf-1))'/(2*nf);
cosw_n=cos(2*pi*f).^(0:(p+q));
Hc=cosw_n*b(:);
Hc=Hc;
plot(f,Hc);
axis([0 0.5 -1 14]);
strt=sprintf("Zolotarev function (Vlcek and Unbehauen) : p=%d, q=%d k=%7.5f",
             p,q,k);
title(strt);
ylabel(sprintf("$Z_{%d,%d}(u,%7.5f)$",p,q,k));
xlabel("Frequency");
grid("on");
print(sprintf("%s_f_%d_%d",strf,p,q),"-dpdflatex");
close
% Calculate z-domain impulse response as a sum over w^m=((z^(-1)+z)/2)^m
c=p+q+1;
h=zeros(1,(2*(p+q))+1);
for m=0:(p+q)
  h(c-m:2:c+m)=h(c-m:2:c+m)+(b(1+m)*bincoeff(m,0:m)/(2^m));
endfor
[~,~,~,~,~,fm]=zolotarev_chen_parks(k,p+q,p);
h=h/fm;
print_polynomial(h,sprintf("h_%d_%d",p,q),sprintf("%s_h_%d_%d_coef.m",strf,p,q));
plot(h);
axis([1 ((2*(p+q))+1)]);
strt=sprintf("Zolotarev function (Vlcek and Unbehauen) impulse response :\
 p=%d, q=%d k=%7.2f",p,q,k);
title(strt);
grid("on");
print(sprintf("%s_h_%d_%d",strf,p,q),"-dpdflatex");
close
% Calculate the frequency response corresponding to the impulse response
[H,w]=freqz(h,1,nf);
plot(w*0.5/pi,20*log10(abs(H)));
axis([0 0.5 -40 0]);
strt=sprintf("Zolotarev function (Vlcek and Unbehauen) frequency response : \
p=%d, q=%d k=%7.5f",p,q,k);
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
ym=10^(idelta/20);
ws=cos(2*pi*ifs);
u0=pKn;
[snu0,cnu0,dnu0]=ellipj(u0,k^2);
Zu0=jacobi_Zeta(u0,k);
wm=ws+(2*(snu0*cnu0)*Zu0/dnu0);
sm=elliptic_F(asin(sqrt((wm-ws)/(wm+1))/(k*snu0)),k);
Kp=ellipke(kp^2);
um=sm+(j*Kp);
HummpKn=jacobi_Eta(um-pKn,k);
HumppKn=jacobi_Eta(um+pKn,k);
for n=1:100,
  if n==100
    error("Did not find suitable n for delta=%fdB",delta)
  endif
  fm=abs(real(0.5*(((HummpKn/HumppKn)^n)+((HumppKn/HummpKn)^n))));
  if fm>ym
    break;
  endif
endfor
% Compare with [1,Eqn. 85]
PIuak=(log(jacobi_Theta(sm-u0,k)/jacobi_Theta(sm+u0,k))/2)+(sm*Zu0);
np=log(ym+sqrt((ym^2)-1))/((2*sm*Zu0)-(2*PIuak));
printf("idelta=%d,n(brute force)=%d,n(with Pi function)=%f\n",idelta,n,np);

% Step 4: Find p and q
K=ellipke(k^2);
q=ceil(n*qKn/K);
p=ceil(n*pKn/K);
n=p+q;
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
% Step 6: Calculate the z-domain impulse response
b=zolotarev_vlcek_unbehauen(p,q,k);
c=p+q+1;
h=zeros(1,(2*(p+q))+1);
for m=0:(p+q)
  h(c-m:2:c+m)=h(c-m:2:c+m)+(b(1+m)*bincoeff(m,0:m)/(2^m));
endfor
h=h/fm;
print_polynomial(h,sprintf("h_%d_%d",p,q),sprintf("%s_fir_coef.m",strf));
printf("p=%d,q=%2d,k=%7.5f,fmax=%6.4f,fm=%6.4f(%6.4f dB),fp=%6.4f,fs=%6.4f\n",
       p,q,k,fmax,fm,20*log10(fm),fp,fs);
% Show response
[H,w]=freqz(h,1,nf);
plot(w*0.5/pi,20*log10(abs(H)));
axis([0 0.5 -40 0]);
strt=sprintf("Zolotarev function (Vlcek and Unbehauen) FIR filter : \
p=%d,q=%d,k=%6.4f,fp=%6.4f,fmax=%6.4f,fs=%6.4f",p,q,k,fp,fmax,fs);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(sprintf("%s_fir_response",strf),"-dpdflatex");
close
% Show z-plane zeros
zplane(roots(h),[]);
title(strt);
grid("on");
print(sprintf("%s_fir_pz",strf),"-dpdflatex");
close
% Save filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"p=%d %% Zeros in lower stop-band\n",p);
fprintf(fid,"q=%d %% Zeros in upper stop-band\n",q);
fprintf(fid,"N=%d %% Degree of FIR polynomial\n",2*(p+q));
fprintf(fid,"k=%8.6f %% Elliptic modulus\n",k);
fprintf(fid,"fp=%8.6f %% Lower stop-band edge\n",fp);
fprintf(fid,"fmax=%8.6f %% Pass-band centre frequency\n",fmax);
fprintf(fid,"fs=%8.6f %% Upper stop-band edge\n",fs);
fprintf(fid,"delta=%8.6f %% Stop-band attenuation(dB)\n",20*log10(fm));
fclose(fid);

% Done
diary off
movefile zolotarev_vlcek_unbehauen_test.diary.tmp ...
         zolotarev_vlcek_unbehauen_test.diary;
