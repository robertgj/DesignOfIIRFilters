% goldfarb_idnani_fir_minimum_phase_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="goldfarb_idnani_fir_minimum_phase_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

% Define objective function
function [E,gradE,hessE]=iir_gi_fx(x,U,V,M,Q,R,wa,Ad,Wa)
  [E,gradE,hessE]=iirE(x,U,V,M,Q,R,wa,Ad,Wa,[],[],[],[],[],[],[],[],[]);
endfunction

% Define constraint gradient function
function [G,gradG]=iir_gi_gx(x,xl,xu,U,V,M,Q,R,wa,Adu,Adl)
  N=1+U+V+M+Q;
  [A,gradA]=iirA(wa,x,U,V,M,Q,R);
  G=[ A-Adl; Adu-A; x-xl; xu-x; ];
  gradG=[ gradA; -gradA; eye(N,N); -eye(N,N) ]';
endfunction

% Bandpass filter specification (frequencies are normalised to sample rate)
fapl=0.1,fapu=0.2,dBap=3,Wap=1
fasl=0.05,fasu=0.25,dBas=30,Wasl=0.2,Wasu=5
N=41

% Frequency points
n=50;
% Desired amplitude 
wa=(0:(n-1))'*pi/n;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Ad=[zeros(napl-1,1);
    ones(napu-napl+1,1);
    zeros(n-napu,1)];
Adu=[(10^(-dBas/20))*ones(nasl,1);
     ones(nasu-nasl-1,1);
     (10^(-dBas/20))*ones(n-nasu+1,1)];
Adl=[zeros(napl-1,1);
     (10^(-dBap/20))*ones(napu-napl+1,1);
     zeros(n-napu,1)];

Wa=[Wasl*ones(nasl,1);
    zeros(napl-nasl-1,1);
    Wap*ones(napu-napl+1,1);
    zeros(nasu-napu-1,1);
    Wasu*ones(n-nasu+1,1)];

% Initial filter
brz=remez(N-1,2*[0 fasl fapl fapu fasu 0.5],[0 0 1 1 0 0],[1 1 1],"bandpass");

% Plot initial filter
zplane(qroots(brz));
title("Goldfarb-Idnani initial FIR filter")
print(strcat(strf,"_initial_zeros"),"-dpdflatex");
close
[Hbrz,w]=freqz(brz,1,1024);
plot(w*0.5/pi,20*log10(abs(Hbrz)))
axis([0 0.5 -60 5])
grid("on");
xlabel("Frequency"); 
ylabel("Amplitude(dB)");
title("Goldfarb-Idnani initial FIR filter");
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

% Convert to gain-zero-pole form
[x0,U,V,M,Q]=tf2x(brz,1);
R=1;
if N ~= 1+U+V+M+Q
  error("N ~= 1+U+V+M+Q");
endif

% Use minimum phase coefficient constraints
tol=1e-3;
[xl,xu]=xConstraints(U,V,M,Q,inf,1-tol);
dmax=0.05;

try
  nc=1:5:n; % Constraint frequencies
  maxiter=50;
  verbose=true;
  feasible=false;
  [x,W,invW,iter,feasible] = ...
    goldfarb_idnani(x0, ...
                    @(x) iir_gi_fx(x,U,V,M,Q,R,wa,Ad,Wa), ...
                    @(x) iir_gi_gx(x,xl,xu,U,V,M,Q,R,wa(nc),Adu(nc),Adl(nc)), ...
                    tol,maxiter,verbose);
catch
end_try_catch

if ~feasible
  error("Filter not feasible!");
endif

% Plot minimum phase filter
[z,p,K]=x2zp(x,U,V,M,Q,R);
if max(abs(z))>1
  error("max(abs(z))>1");
endif
zplane(z);
title("Goldfarb-Idnani minimum phase FIR filter");
print(strcat(strf,"_zeros"),"-dpdflatex");
close
[b,a]=x2tf(x,U,V,M,Q,R);
[H,w]=freqz(b,a,1024);
Ha=freqz(b,a,wa);
plot(w*0.5/pi,20*log10(abs(H)), ...
     wa(nc)*0.5/pi,20*log10(abs(Ha(nc))),"+");
axis([0 0.5 -60 5]);
grid("on");
xlabel("Frequency"); 
ylabel("Amplitude(dB)");
title("Goldfarb-Idnani minimum phase FIR filter");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Save results
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on update\n",tol);
fprintf(fid,"fasl=%g %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"dBap=%d %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"dBas=%d %% Stop band minimum attenuation\n",dBas);
fprintf(fid,"Wasl=%d %% Lower stop band amplitude weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Upper stop band amplitude weight\n",Wasu);
fclose(fid);

print_pole_zero(x,U,V,M,Q,R,"x");
print_pole_zero(x,U,V,M,Q,R,"x",strcat(strf,"_x_coef.m"));
print_polynomial(b,"b");
print_polynomial(b,"b",strcat(strf,"_b_coef.m"));

eval(sprintf("save %s.mat tol maxiter N U V M Q R \
fasl fapl fapu fasu dBap Wap dBas Wasl Wasu x b ",strf));

% Done 
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
