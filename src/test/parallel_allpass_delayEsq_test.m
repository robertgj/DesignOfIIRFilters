% parallel_allpass_delayEsq_test.m
% Copyright (C) 2017-2023 Robert G. Jenssen
% Check the squared-error response and gradient for the parallel
% combination of an allpass filter and a pure delay

test_common;

delete("parallel_allpass_delayEsq_test.diary");
delete("parallel_allpass_delayEsq_test.diary.tmp");
diary parallel_allpass_delayEsq_test.diary.tmp

verbose=false;

% Use the filter calculated by tarczynski_parallel_allpass_delay_test.m
Da = [  1.0000000000,  -0.5293688892,   0.3581214325,   0.1868454349, ... 
        0.0310301162,  -0.0571095908,  -0.0703708412,  -0.0384386690, ... 
       -0.0003605791,   0.0199157500,   0.0202940594,   0.0113549166, ... 
        0.0034443539 ]';
[a,V,Q]=tf2a(Da);
R=1;
DD=11;
ftp=0.15;
Wtp=1;
fas=0.2;
Was=2;

% Frequency points
n=1000;
w=pi*(0:(n-1))'/n;
ntp=ceil(ftp*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Frequency vectors
wa=w;
Asqd=[ones(ntp,1);zeros(n-ntp,1)];
Wa=[zeros(nas-1,1);Was*ones(n-nas+1,1)];
wt=w(1:ntp);
Td=DD*R*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

%
% Check the squared-error response
%

% Use freqz and delayz to find the frequency response
[Ba,Aa]=a2tf(a,V,Q,R);
Ha_freqz=freqz(Ba,Aa,w);
Asq_freqz=abs(0.5*(Ha_freqz+exp(-j*w*DD*R))).^2;
Ta_delayz=delayz(Ba,Aa,w);
T_delayz=(Ta_delayz(1:ntp)+(DD*R))/2;

% Trapezoidal integration of weighted squared-error response  
EsqAsq=Wa.*((Asq_freqz-Asqd).^2);
EsqT=Wt.*((T_delayz-Td).^2);
EsqAsqT=(sum(diff(wa).*(EsqAsq(1:(n-1))+EsqAsq(2:end)))/2)+...
        (sum(diff(wt).*(EsqT(1:(ntp-1))+EsqT(2:end)))/2);

% Use parallel_allpass_delayEsq to find the squared-error response
Esq_allpass_delay=parallel_allpass_delayEsq(a,V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);

% Compare the squared-error responses
maxAbsDelEsqeps=max(abs(Esq_allpass_delay-EsqAsqT))/eps;
if maxAbsDelEsqeps > 800
  error("max(abs(Esq_allpass_delay-EsqAsqT))/eps(=%g) > 800",
        maxAbsDelEsqeps);
endif

%
% Check partial derivatives of the squared-error
%

[Esqac,gradEsqac,diagHessEsqac]=...
  parallel_allpass_delayEsq(a,V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);

delEsqdelRpa=gradEsqac(1:V);
Qon2=Q/2;
delEsqdelrpa=gradEsqac((V+1):(V+Qon2));
delEsqdelthetapa=gradEsqac((V+Qon2+1):end);
del2EsqdelRpa2=diagHessEsqac(1:V);
del2Esqdelrpa2=diagHessEsqac((V+1):(V+Qon2));
del2Esqdelthetapa2=diagHessEsqac((V+Qon2+1):end);

% Find approximate values
tol=2.5e-10;
del=1e-6;
delk=[del;zeros(V+Q-1,1)];

% Compare gradient with calculated values
for k=1:V
  % delEsqdelRpa
  EsqacPdelk2 = ...
    parallel_allpass_delayEsq(a+(delk/2),V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  EsqacMdelk2 = ...
    parallel_allpass_delayEsq(a-(delk/2),V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  approx_delEsqdelRpak=(EsqacPdelk2-EsqacMdelk2)/del;
  if verbose
    printf("Filter a: real pole/zero %d\n", k); 
    printf("abs(approx_delEsqdelRpak-delEsqdelRpa(%d)=%g\n",
           k,approx_delEsqdelRpak-delEsqdelRpa(k));
  endif
  if abs(approx_delEsqdelRpak-delEsqdelRpa(k)) > tol
    error("abs(approx_delEsqdelRpak(=%g)-delEsqdelRpa(%d)(=%g)) > %g",
          approx_delEsqdelRpak,k,delEsqdelRpa(k),tol);
  endif
  
  delk=circshift(delk,1);
endfor
tol=1e-7;
for k=1:Qon2
  % delEsqdelrpa
  EsqacPdelk2 = ...
    parallel_allpass_delayEsq(a+(delk/2),V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  EsqacMdelk2 = ...
    parallel_allpass_delayEsq(a-(delk/2),V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  approx_delEsqdelrpak=(EsqacPdelk2-EsqacMdelk2)/del;
  if verbose
    printf("Filter a: conjugate pole/zero %d radius\n", k);
    printf("abs(approx_delEsqdelrpak-delEsqdelrpa(%d)=%g\n",
           k,approx_delEsqdelrpak-delEsqdelrpa(k));
  endif
  if abs(approx_delEsqdelrpak-delEsqdelrpa(k)) > tol
    error("abs(approx_delEsqdelrpak(=%g)-delEsqdelrpa(%d)(=%g)) > %g",
          approx_delEsqdelrpak,k,delEsqdelrpa(k),tol);
  endif
  delk=circshift(delk,1);
endfor
for k=1:Qon2
  % delEsqdelthetapa
  EsqacPdelk2 = ...
    parallel_allpass_delayEsq(a+(delk/2),V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  EsqacMdelk2 = ...
    parallel_allpass_delayEsq(a-(delk/2),V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  approx_delEsqdelthetapak=(EsqacPdelk2-EsqacMdelk2)/del;
  if verbose
    printf("Filter a: conjugate pole/zero %d angle\n", k);
    printf("abs(approx_delEsqdelthetapak-delEsqdelthetapa(%d)=%g\n",
           k,approx_delEsqdelthetapak-delEsqdelthetapa(k));
  endif
  if abs(approx_delEsqdelthetapak-delEsqdelthetapa(k)) > tol
    error("abs(approx_delEsqdelthetapak(=%g)-delEsqdelthetapa(%d)(=%g)) > %g",
          approx_delEsqdelthetapak,k,delEsqdelthetapa(k),tol);
  endif
  delk=circshift(delk,1);
endfor

% Compare diagonal of Hessian with calculated values
for k=1:V
  % del2EsqdelRpa2
  [EsqacPdelk2,gradEsqacPdelk2] = ...
    parallel_allpass_delayEsq(a+(delk/2),V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  [EsqacMdelk2,gradEsqacMdelk2] = ...
    parallel_allpass_delayEsq(a-(delk/2),V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  approx_del2EsqdelRpak2=(gradEsqacPdelk2(k)-gradEsqacMdelk2(k))/del;
  if verbose
    printf("Filter a: real pole/zero %d\n", k); 
    printf("abs(approx_del2EsqdelRpak2-del2EsqdelRpa2(%d)=%g\n",
           k,approx_del2EsqdelRpak2-del2EsqdelRpa2(k));
  endif
  if abs(approx_del2EsqdelRpak2-del2EsqdelRpa2(k)) > tol
    error("abs(approx_del2EsqdelRpak2(=%g)-del2EsqdelRpa2(%d)(=%g)) > %g",
          approx_del2EsqdelRpak2,k,del2EsqdelRpa2(k),tol);
  endif
  delk=circshift(delk,1);
endfor
tol=1e-6;
for k=1:Qon2
  % del2Esqdelrpa2
  [EsqacPdelk2,gradEsqacPdelk2] = ...
    parallel_allpass_delayEsq(a+(delk/2),V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  [EsqacMdelk2,gradEsqacMdelk2] = ...
    parallel_allpass_delayEsq(a-(delk/2),V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  approx_del2Esqdelrpak2=(gradEsqacPdelk2(V+k)-gradEsqacMdelk2(V+k))/del;
  if verbose
    printf("Filter a: conjugate pole/zero %d radius\n", k);
    printf("abs(approx_del2Esqdelrpak2-del2Esqdelrpa2(%d)=%g\n",
           k,approx_del2Esqdelrpak2-del2Esqdelrpa2(k));
  endif
  if abs(approx_del2Esqdelrpak2-del2Esqdelrpa2(k)) > tol
    error("abs(approx_del2Esqdelrpak2(=%g)-del2Esqdelrpa2(%d)(=%g)) > %g",
          approx_del2Esqdelrpak2,k,del2Esqdelrpa2(k),tol);
  endif
  delk=circshift(delk,1);
endfor
tol=1e-6;
for k=1:Qon2
  % del2Esqdelthetapa2
  [EsqacPdelk2,gradEsqacPdelk2] = ...
    parallel_allpass_delayEsq(a+(delk/2),V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  [EsqacMdelk2,gradEsqacMdelk2] = ...
    parallel_allpass_delayEsq(a-(delk/2),V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  approx_del2Esqdelthetapak2 = ...
    (gradEsqacPdelk2(V+Qon2+k)-gradEsqacMdelk2(V+Qon2+k))/del;
  if verbose
    printf("Filter a: conjugate pole/zero %d angle\n", k);
    printf("approx_del2Esqdelthetapak2-del2Esqdelthetapa2(%d)=%g\n",
           k,approx_del2Esqdelthetapak2-del2Esqdelthetapa2(k));
  endif
  if abs(approx_del2Esqdelthetapak2-del2Esqdelthetapa2(k)) > tol
    error("abs(approx_del2Esqdelthetapak2(=%g)-del2Esqdelthetapa2(%d)(=%g))>%g",
          approx_del2Esqdelthetapak2,k,del2Esqdelthetapa2(k),tol);
  endif
  delk=circshift(delk,1);
endfor

% Done
diary off
movefile parallel_allpass_delayEsq_test.diary.tmp ...
       parallel_allpass_delayEsq_test.diary;
