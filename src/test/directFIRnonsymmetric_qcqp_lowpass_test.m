% directFIRnonsymmetric_qcqp_lowpass_test.m
% SDP design of a direct-form non-symmetric FIR lowpass filter with QCQP.
% See Section 8.2 of "Introduction to Semidefinite Programming", R. M. Freund, 
% MIT6_251JF09_SDP.pdf
%
% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="directFIRnonsymmetric_qcqp_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false;
tol=1e-12;

% Low-pass filter specification
N=30;d=10;fap=0.175;Wap=1e-5;fas=0.25;Was=1;

% Set up the quadratic constraints on the amplitude response
[~,~,Q_p,q_p]=directFIRnonsymmetricEsqPW ...
                (zeros(N+1,1),[0,fap]*2*pi,[1],[d],[Wap]);
if min(eigs(Q_p,N+1)) < -tol
  error("min(eigs(Q_p,N+1))(%g*tol) < -tol",min(eigs(Q_p,N+1))/tol);
endif
c_p=fap*2*Wap;
 
[~,~,Q_s,q_s]=directFIRnonsymmetricEsqPW ...
                (zeros(N+1,1),[fas,0.5]*2*pi,[0],[d],[Was]);
if min(eigs(Q_s,N+1)) < -tol
  error("min(eigs(Q_s,N+1))(%g*tol) < -tol",min(eigs(Q_s,N+1))/tol);
endif
c_s=0;

theta_s=sdpvar(1,1,"full","real");
x=sdpvar(1,N+1,"full","real");
W=sdpvar(N+1,N+1,"symmetric","real");
xW=[[1,x];[x',W]];
F_p=trace([[c_p,q_p];[q_p',Q_p]]*xW);
F_s=trace([[c_s-theta_s,q_s];[q_s',Q_s]]*xW);

% Call YALMIP
Objective=[theta_s];
Constraints=[xW>=0,F_p<=0,F_s<=0];
Options=sdpsettings("solver","sedumi"); %,"sedumi.eps",1e-7);
sol=optimize(Constraints,Objective,Options);
if sol.problem
  warning("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)

% Extract filter impulse response
h=value(x);
print_polynomial(h,"h");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"));

% Calculate response
nplot=1000;
nap=floor(fap*nplot/0.5)+1;
nas=floor(fas*nplot/0.5)+1;
f=(0:(nplot-1))'*0.5/nplot;
w=2*pi*f;
H=freqz(h,1,w);
T=delayz(h,1,nplot);

% Find pass-band ripple
[maxPassRipple,imaxPassRipple]=max(abs(abs(H(1:nap))-1));
dBap=abs(20*log10(abs(H(imaxPassRipple))));
[maxStop,imaxStop]=max(abs(H(nas:end)));
imaxStop=imaxStop+nas;
dBas=abs(20*log10(maxStop));
tdr=max(abs(T(1:nap)-d));

% Plot response
subplot(211)
plot(f,20*log10(abs(H)), ...
     f([imaxPassRipple,imaxStop]), ...
     20*log10(abs(H([imaxPassRipple,imaxStop]))),"+");
ylabel("Amplitude(dB)");
axis([0 0.5 -80 10]);
grid("on");
strt=sprintf(["QCQP non-symmetric FIR filter : ", ...
              "N=%d,d=%d,dBap=%6.4f,dBas=%6.2f,theta\\_s=%10.4g"],
             N,d,dBap,dBas,value(theta_s));
title(strt);
zticks([]);
subplot(212)
plot(w*0.5/pi,T);
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0 0.5 0 20]);
grid("on");
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
subplot(211)
axis([0 fap 0.1*[-1,1]]);
grid("on");
zticks([]);
subplot(212)
axis([0 fap d+0.2*[-1,1]]);
grid("on");
zticks([]);
print(strcat(strf,"_passband_response"),"-dpdflatex");
close
% Dual plot response
subplot(211)
ax=plotyy(f(1:nap),20*log10(abs(H(1:nap))), ...
          f(nas:end),20*log10(abs(H(nas:end))));
axis(ax(1),[0 0.5 0.1*[-1,1]]);
axis(ax(2),[0 0.5 -70,-30]);
grid("on");
ylabel("Amplitude(dB)");
title(strt);
zticks([]);
subplot(212)
plot(f(1:nap),T(1:nap));
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0 0.5 d+0.2*[-1,1]]);
grid("on");
zticks([]);
print(strcat(strf,"_dual_response"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"d=%d %% Nominal FIR filter delay\n",d);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fclose(fid);

% Save results
eval(sprintf("save %s.mat N d fap dBap Wap fas dBas Was h",strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
