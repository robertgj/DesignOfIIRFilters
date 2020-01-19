% selesnickFIRsymmetric_bandpass_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

unlink("selesnickFIRsymmetric_bandpass_test.diary");
unlink("selesnickFIRsymmetric_bandpass_test.diary.tmp");
diary selesnickFIRsymmetric_bandpass_test.diary.tmp

strf="selesnickFIRsymmetric_bandpass_test";

%  
% Initialise
%
nplot=4000;
max_iter=100;
tol=1e-5;

% Specification
%M=164;deltasl=1e-4;deltap=1e-3;deltasu=1e-4;ftl=0.2;ftu=0.35;at=0.5;
M=50;deltasl=2e-3;deltap=2e-3;deltasu=1e-3;ftl=0.1;ftu=0.2;at=0.5;
strt=sprintf("Selesnick-Burrus Hofstetter bandpass FIR: \
M=%d,deltasl=%g,deltap=%g,deltasu=%g,ftl=%g,ftu=%g,at=%g", ...
             M,deltasl,deltap,deltasu,ftl,ftu,at);

% Filter design
[hM,fext,fiter,feasible]= ...
  selesnickFIRsymmetric_bandpass(M,deltasl,deltap,deltasu,ftl,ftu,at, ...
                                 nplot,max_iter,tol);
if feasible==false
  error("hM not feasible");
endif

% Check transition frequency amplitudes
wt=[ftl,ftu]*2*pi;
At=directFIRsymmetricA(wt,hM);
if any(abs(At-at)>tol)
  error("any(abs(At-at)>tol)");
endif

% Check transition frequency amplitude slope
del=tol;
AtPdel=directFIRsymmetricA(wt+del,hM);
AtMdel=directFIRsymmetricA(wt-del,hM);
diffAt=(AtPdel-AtMdel)/(2*del);
MM=(M:-1:1)';
dAdwt=-sum(2*((MM.*hM(1:M)).*ones(size(wt))).*sin(MM.*wt));
printf("dAdwt=[%g,%g]\n",dAdwt(1),dAdwt(2));

%
% Plot solution
%
wa=(0:(nplot-1))'*pi/nplot;
A=directFIRsymmetricA(wa,hM);
plot(wa*0.5/pi,20*log10(abs(A)))
axis([0 0.5 (20*log10(deltasl)-10) 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
ax=plotyy(wa*0.5/pi,A,wa*0.5/pi,A);
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 1-(2*deltap) 1+(2*deltap)]);
axis(ax(2),[0 0.5 -2*deltasu 2*deltasu]);
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex");
close

% Plot zeros
zplane(roots([hM;flipud(hM(1:(end-1)))]));
title(strt);
grid("on");
print(strcat(strf,"_zeros"),"-dpdflatex");
close

%
% Compare with remez
%
b=remez(2*M,[0 0.08 0.11 0.19 0.22 0.5]*2,[0 0 1 1 0 0],[2 1 4],"bandpass");
A=directFIRsymmetricA(wa,b(1:(M+1)));
ax=plotyy(wa*0.5/pi,A,wa*0.5/pi,A);
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 1-(2*deltap) 1+(2*deltap)]);
axis(ax(2),[0 0.5 -2*deltasu 2*deltasu]);
strt=sprintf("Bandpass FIR: \
b=remez(2*M,[0 0.08 0.11 0.19 0.22 0.5]*2,[0 0 1 1 0 0],[2 1 4],\"bandpass\");");
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dual_remez"),"-dpdflatex");
close
zplane(roots(b));
title(strt);
grid("on");
print(strcat(strf,"_zeros_remez"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"deltasl=%g %% Amplitude lower stop-band peak ripple\n",deltasl);
fprintf(fid,"deltap=%g %% Amplitude pass-band peak ripple\n",deltap);
fprintf(fid,"deltasu=%g %% Amplitude upper stop-band peak ripple\n",deltasu);
fprintf(fid,"ftl=%g %% Amplitude lower transition band frequency\n",ftl);
fprintf(fid,"ftu=%g %% Amplitude upper transition band frequency\n",ftu);
fprintf(fid,"at=%g %% Amplitude at transition band frequencies\n",at);
fprintf(fid,"nplot=%d %% Number of frequencies\n",nplot);
fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
fclose(fid);

print_polynomial(hM,"hM","%15.12f");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"),"%15.12f");

save selesnickFIRsymmetric_bandpass_test.mat  ...
     M deltasl deltap deltasu ftl ftu at nplot max_iter tol hM fext

%
% Done
%
diary off
movefile selesnickFIRsymmetric_bandpass_test.diary.tmp ...
         selesnickFIRsymmetric_bandpass_test.diary;

