% allpass_phase_socp_mmse_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

delete("allpass_phase_socp_mmse_test.diary");
delete("allpass_phase_socp_mmse_test.diary.tmp");
diary allpass_phase_socp_mmse_test.diary.tmp


verbose=false
tol=1e-6
maxiter=2000
strf="allpass_phase_socp_mmse_test";

% Low-pass elliptic filter specification
nh=4
fap=0.1
dBap=0.1
dBas=60
[N0,D0]=ellip(nh,dBap,dBas,2*fap);
[x0,Ux,Vx,Mx,Qx]=tf2x(N0,D0);
Rx=1;
n=1000;
w=(0:(n-1))'*pi/n;
Ax=iirA(w,x0,Ux,Vx,Mx,Qx,Rx);
Tx=iirT(w,x0,Ux,Vx,Mx,Qx,Rx);
Px=iirP(w,x0,Ux,Vx,Mx,Qx,Rx);

% All-pass phase equaliser specification and initial filter
na=3
fpp=0.08
tp=5
[~,A0]=butter(na,2*fpp);
[a0,Va,Qa]=tf2a(A0);
Ra=1;
printf("Initial a0=[");printf("%g ",a0');printf("]'\n");

% Desired pass-band phase response
npp=ceil(n*fpp/0.5)+1;
wp=w(1:npp);
Pd=-(Px(1:npp)+(tp*wp));
Pdu=[];
Pdl=[];
Wp=ones(npp,1);

% Linear constraints
rho=31/32;
[al,au]=aConstraints(Va,Qa,rho);

% SOCP MMSE
[a1,socp_iter,func_iter,feasible]= ...
  allpass_phase_socp_mmse([],a0,au,al,Va,Qa,Ra, ...
                          wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose);
if !feasible
  error("a1 infeasible");
endif

% Find response
Pa0=allpassP(w,a0,Va,Qa,Ra);
Pa1=allpassP(w,a1,Va,Qa,Ra);
Ta1=allpassT(w,a1,Va,Qa,Ra);

% Plot response
subplot(211);
plot(w*0.5/pi,20*log10(Ax));
ylabel("Amplitude(dB)");
axis([0 0.1 -0.1 0]);
grid("on");
s=sprintf("Elliptic filter with delay equaliser (pass-band) : \
nh=%d,fap=%g,dBap=%g,dBas=%g,na=%d,fpp=%g,tp=%g",nh,fap,dBap,dBas,na,fpp,tp);
title(s);
subplot(212);
f=w*0.5/pi;
plot(f,(Px+(tp*w))/pi,"linestyle","-.",f,(Px+Pa1+(tp*w))/pi);
axis([0 0.1 -0.1 0.2]);
ylabel("Phase error(rad/$\\pi$)");
xlabel("Frequency");
legend("Elliptic","Equalised","location","northwest");
legend("boxoff");
grid("on");
print(strcat(strf,"_a1"),"-dpdflatex");
close

if verbose
  EP=((Px(1:npp)+Pa1(1:npp)+(tp*w(1:npp)))/pi).^2;
  intEP=sum(diff(w(1:npp)).*(EP(1:(end-1))+EP(2:end)))/2;
  printf("tp=%f,intEP=%g\n",tp,intEP);
endif

% Plot poles and zeros
[~,Da1]=a2tf(a1,Va,Qa,Ra);
N1=conv(N0(:),flipud(Da1(:)));
D1=conv(D0(:),Da1(:));
subplot(111);
zplane(qroots(N1),qroots(D1));
title(s);
print(strcat(strf,"_a1pz"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"nh=%d %% Elliptic low-pass filter order\n",nh);
fprintf(fid,"dBap=%g %% Elliptic filter pass-band amplitude ripple\n",dBap);
fprintf(fid,"dBas=%g %% Elliptic filter stop-band amplitude ripple\n",dBas);
fprintf(fid,"fap=%g %% Elliptic filter pass-band amplitude response edge\n",fap);
fprintf(fid,"na=%d %% Allpass filter order\n",na);
fprintf(fid,"Va=%d %% Allpass filter no. of real poles\n",Va);
fprintf(fid,"Qa=%d %% Allpass filter no. of complex poles\n",Qa);
fprintf(fid,"Ra=%d %% Allpass filter decimation\n",Ra);
fprintf(fid,"tp=%g %% Combined filter pass-band nominal group delay\n",tp);
fprintf(fid,"fpp=%g %% Combined filter pass-band phase response edge\n",fpp);
fclose(fid);

% Save results
print_allpass_pole(a1,Va,Qa,Ra,"a1");
print_allpass_pole(a1,Va,Qa,Ra,"a1",strcat(strf,"_a1_coef.m"));

% Done 
diary off
movefile allpass_phase_socp_mmse_test.diary.tmp ...
         allpass_phase_socp_mmse_test.diary;
