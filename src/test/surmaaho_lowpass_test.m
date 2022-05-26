% surmaaho_lowpass_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

delete("surmaaho_lowpass_test.diary");
delete("surmaaho_lowpass_test.diary.tmp");
diary surmaaho_lowpass_test.diary.tmp

maxiter=5000
tol=1e-6
verbose=false
strf="surmaaho_lowpass_test";

% Minimum-phase filter specification
nmin=7,fap=0.1,fas=0.125,dBap=0.1,dBas=60
nf=1000;
nap=ceil(fap*nf/0.5)+1;
nas=floor(fas*nf/0.5)+1;
w=(0:(nf-1))'*pi/nf;
wa=w(1:nap);
ws=w(nas:end);

% All-pass equaliser specification
nall=4,fpp=0.08,tp=25
npp=ceil(nf*fpp/0.5)+1;
wp=w(1:npp);
% Wider than initial phase response
fpw=0.105
npw=ceil(nf*fpw/0.5)+1;
ww=w(1:npw);

%
% Step 1 : design an initial equiripple low-pass filter
%
    
% Design initial equi-ripple filter
[z0,p0,K0]=ellip(nmin,dBap,dBas,2*fap);

%
% Step 2 : design an initial phase equaliser
%
    
% Desired initial pass-band phase response
[x0,U0,V0,M0,Q0]=zp2x(z0,p0,K0);
R0=1;
P0=iirP(w,x0,U0,V0,M0,Q0,R0);
Pd=-(P0(1:npp)+(tp*wp));

% Design initial all-pass equaliser
[~,A0]=butter(nall,2*fpp);
[a0,Va,Qa]=tf2a(A0);
Ra=1;

% Linear constraints
rho=31/32;
[al,au]=aConstraints(Va,Qa,rho);

% SOCP MMSE
[a,socp_iter,func_iter,feasible]= ...
allpass_phase_socp_mmse([],a0,au,al,Va,Qa,Ra, ...
                        wp,Pd,[],[],ones(size(wp)),maxiter,tol,verbose);
if ~feasible
  error("Initial allpass_phase_socp_mmse not feasible");
endif
allpass_p=a2p(a,Va,Qa); % Fixed all-pass poles

%
% Iterate
%
for iter=0:maxiter
  if iter==maxiter
    error("iter==maxiter");
  endif

  %
  % Step 3 : Find a filter with single fixed zeros
  %
  [min_z,min_p,K,iter]=surmaahoFAvLogNewton(nmin,fap,fas,allpass_p,tp,dBap,dBas);

  %
  % Step 4 : Design a new phase equaliser.
  %          The previous allpass_p poles are now zeros.
  % 
  [x4,U4,V4,M4,Q4]=zp2x([min_z;allpass_p],min_p,K);
  R4=1;
  P=iirP(ww,x4,U4,V4,M4,Q4,R4);
  Pd=-(P+(tp*ww));
  [next_a,socp_iter,func_iter,feasible] = ...
    allpass_phase_socp_mmse([],a,au,al,Va,Qa,Ra,ww,Pd,[],[],ones(size(ww)), ...
                            maxiter,tol,verbose);
  if ~feasible
    error("allpass_phase_socp_mmse not feasible");
  endif
  next_allpass_p=a2p(next_a,Va,Qa);
  a=next_a;

  %
  % Step 5 : Check equaliser pole-zero convergence
  %
  diff_allpass_p=norm(allpass_p-next_allpass_p);
  if diff_allpass_p<tol
    break;
  else
    allpass_p=next_allpass_p;
  endif
  
endfor

%
% Calculate combined response
%
[x,U,V,M,Q]=zp2x([min_z;1./allpass_p],min_p,K);
R=1;
Ap=iirA(wa,x,U,V,M,Q,R);
Ap=20*log10(Ap);
As=iirA(ws,x,U,V,M,Q,R);
As=20*log10(As);
P=iirP(wa,x,U,V,M,Q,R);
Pp=(P+(tp*wa))/pi;
Fp=wa*0.5/pi;
Fs=ws*0.5/pi;

% Check dBap, dBas
max_dBap=max(Ap);
min_dBap=min(Ap);
max_dBas=0-max(As);
max_P=max(Pp);
min_P=min(Pp);
printf("nmin=%d,nall=%d,iter=%d,diff_allpass_p=%g\n", ...
       nmin,nall,iter,diff_allpass_p);
printf("max_dBap=%8.6f,min_dBap=%8.6f,max_dBas=%6.2f,min_P=%6.2f,max_P=%6.2f\n",
       max_dBap,min_dBap,max_dBas,min_P,max_P);

% Plot response
subplot(211);
ax=plotyy(Fp,Ap,Fs,As);
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -0.02 0]);
axis(ax(2),[0 0.5 -70 -50]);
strt="Surma-aho-and-Saram\\\"{a}ki combined filter response";
title(strt);
ylabel("Amplitude(dB)");
grid("on");
subplot(212); 
plot(Fp,Pp);
axis([0 0.5 -0.08 0.08]);
grid("on");
ylabel("Phase error(rad./$\\pi$)");
xlabel("Frequency");
print(strcat(strf,"_resp"),"-dpdflatex");
close

% Combined filter zplane plot
subplot(111);
zplane([min_z;1./allpass_p],min_p);
strt="Surma-aho-and-Saram\\\"{a}ki combined filter";
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Save the filter specification
fid=fopen("surmaaho_lowpass_test.spec","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"nf=%d %% Frequency points across the band\n",nf);
fprintf(fid,"nmin=%d %% Minimum-phase filter order\n",nmin);
fprintf(fid,"nall=%d %% All-pass phase equaliser filter order\n",nall);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple\n",dBap);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple\n",dBas);
fprintf(fid,"fpp=%g %% Initial pass band phase response edge\n",fpp);
fprintf(fid,"fpw=%g %% Wider pass band phase response edge\n",fpw);
fprintf(fid,"tp=%g %% Nominal pass band group delay\n",tp);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);

% Print filter
print_pole_zero(x,U,V,M,Q,R,"x",strcat(strf,"_x_coef.m"));
print_polynomial(abs(allpass_p),"abs_allpass_p");
print_polynomial(angle(allpass_p),"angle_allpass_p");
print_polynomial(abs(min_z),"abs_min_z");
print_polynomial(angle(min_z),"angle_min_z");
print_polynomial(abs(min_p),"abs_min_p");
print_polynomial(angle(min_p),"angle_min_p");
    
% Done
diary off
movefile surmaaho_lowpass_test.diary.tmp surmaaho_lowpass_test.diary;
