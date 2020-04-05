% parallel_allpass_delayAsq_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
% Check the squared-magnitude response and gradient for the parallel
% combination of an allpass filter and a pure delay

test_common;

delete("parallel_allpass_delayAsq_test.diary");
delete("parallel_allpass_delayAsq_test.diary.tmp");
diary parallel_allpass_delayAsq_test.diary.tmp

verbose=false;

if 1
% Use the filter calculated by tarczynski_allpass_phase_shift_test.m
  Da = [  1.0000000000,  -0.4600541550,   0.3895171433,   0.1750041418, ... 
          0.0054307833,  -0.0609663877,  -0.0421198266,   0.0019489258, ... 
          0.0237825475,   0.0162337004,  -0.0003436796,  -0.0109619904 ]';
else
% Use the filter calculated by tarczynski_parallel_allpass_delay_test.m
  Da = [  1.0000000000,  -0.5293688883,   0.3581214335,   0.1868454361, ... 
          0.0310301175,  -0.0571095893,  -0.0703708398,  -0.0384386678, ...
         -0.0003605782,   0.0199157506,   0.0202940598,   0.0113549168, ... 
          0.0034443540 ]';
endif
[a,V,Q]=tf2a(Da);
R=1;
DD=length(Da)-2;
polyphase=false;

%
% Check empty response
%

[Asqa,gradAsqa]=parallel_allpass_delayAsq([],a,V,Q,R,DD);
if ~isempty(Asqa)
  error("Expected Asqa empty");
endif
if ~isempty(gradAsqa)
  error("Expected gradAsqa empty");
endif

%
% Check the squared-magnitude response
%

% Use freqz to find the frequency response
[Ba,Aa]=a2tf(a,V,Q,R);
n=1024;
w=(0:(n-1))'*pi/n;
Ha_freqz=freqz(Ba,Aa,w);
Asqa_freqz=abs(0.5*(Ha_freqz+exp(-j*w*DD))).^2;

% Use parallel_allpass_delayAsq to find the squared-magnitude response
Asqa_allpass=parallel_allpass_delayAsq(w,a,V,Q,R,DD,polyphase);

% Compare the squared-magnitude responses
maxAbsDelAsqeps=max(abs(Asqa_allpass-Asqa_freqz))/eps;
if maxAbsDelAsqeps > 38
  error("max(abs(Asqa_allpass-Asqa_freqz).^2)/eps(=%g) > 38",maxAbsDelAsqeps);
endif

%
% Check partial derivatives
%
fc=0.175;
wc=2*pi*fc;

% Check partial derivatives of the squared-magnitude
[Asqac,gradAsqac,diagHessAsqac]=...
  parallel_allpass_delayAsq(wc,a,V,Q,R,DD,polyphase);

delAsqdelRpa=gradAsqac(1:V);
Qon2=Q/2;
delAsqdelrpa=gradAsqac((V+1):(V+Qon2));
delAsqdelthetapa=gradAsqac((V+Qon2+1):end);
del2AsqdelRpa2=diagHessAsqac(1:V);
del2Asqdelrpa2=diagHessAsqac((V+1):(V+Qon2));
del2Asqdelthetapa2=diagHessAsqac((V+Qon2+1):end);

% Find approximate values
tol=2e-9;
del=1e-6;
delk=[del;zeros(V+Q-1,1)];

% Compare gradient with calculated values
for k=1:V
  % delAsqdelRpa
  AsqacPdelk2=parallel_allpass_delayAsq(wc,a+(delk/2),V,Q,R,DD,polyphase);
  AsqacMdelk2=parallel_allpass_delayAsq(wc,a-(delk/2),V,Q,R,DD,polyphase);
  approx_delAsqdelRpak=(AsqacPdelk2-AsqacMdelk2)/del;
  if verbose
    printf("Filter a: real pole/zero %d\n", k); 
    printf("abs(approx_delAsqdelRpak-delAsqdelRpa(%d)=%g\n",
           k,approx_delAsqdelRpak-delAsqdelRpa(k));
  endif
  if abs(approx_delAsqdelRpak-delAsqdelRpa(k)) > tol
    error("abs(approx_delAsqdelRpak(=%g)-delAsqdelRpa(%d)(=%g)) > %g",
          approx_delAsqdelRpak,k,delAsqdelRpa(k),tol);
  endif
  
  delk=shift(delk,1);
endfor
for k=1:Qon2
  % delAsqdelrpa
  AsqacPdelk2=parallel_allpass_delayAsq(wc,a+(delk/2),V,Q,R,DD,polyphase);
  AsqacMdelk2=parallel_allpass_delayAsq(wc,a-(delk/2),V,Q,R,DD,polyphase);
  approx_delAsqdelrpak=(AsqacPdelk2-AsqacMdelk2)/del;
  if verbose
    printf("Filter a: conjugate pole/zero %d radius\n", k);
    printf("abs(approx_delAsqdelrpak-delAsqdelrpa(%d)=%g\n",
           k,approx_delAsqdelrpak-delAsqdelrpa(k));
  endif
  if abs(approx_delAsqdelrpak-delAsqdelrpa(k)) > tol
    error("abs(approx_delAsqdelrpak(=%g)-delAsqdelrpa(%d)(=%g)) > %g",
          approx_delAsqdelrpak,k,delAsqdelrpa(k),tol);
  endif
  delk=shift(delk,1);
endfor
for k=1:Qon2
  % delAsqdelthetapa
  AsqacPdelk2=parallel_allpass_delayAsq(wc,a+(delk/2),V,Q,R,DD,polyphase);
  AsqacMdelk2=parallel_allpass_delayAsq(wc,a-(delk/2),V,Q,R,DD,polyphase);
  approx_delAsqdelthetapak=(AsqacPdelk2-AsqacMdelk2)/del;
  if verbose
    printf("Filter a: conjugate pole/zero %d angle\n", k);
    printf("abs(approx_delAsqdelthetapak-delAsqdelthetapa(%d)=%g\n",
           k,approx_delAsqdelthetapak-delAsqdelthetapa(k));
  endif
  if abs(approx_delAsqdelthetapak-delAsqdelthetapa(k)) > tol
    error("abs(approx_delAsqdelthetapak(=%g)-delAsqdelthetapa(%d)(=%g)) > %g",
          approx_delAsqdelthetapak,k,delAsqdelthetapa(k),tol);
  endif
  delk=shift(delk,1);
endfor

% Compare diagonal of Hessian with calculated values
for k=1:V
  % del2AsqdelRpa2
  [AsqacPdelk2,gradAsqacPdelk2] = ...
    parallel_allpass_delayAsq(wc,a+(delk/2),V,Q,R,DD,polyphase);
  [AsqacMdelk2,gradAsqacMdelk2] = ...
    parallel_allpass_delayAsq(wc,a-(delk/2),V,Q,R,DD,polyphase);
  approx_del2AsqdelRpak2=(gradAsqacPdelk2(k)-gradAsqacMdelk2(k))/del;
  if verbose
    printf("Filter a: real pole/zero %d\n", k); 
    printf("abs(approx_del2AsqdelRpak2-del2AsqdelRpa2(%d)=%g\n",
           k,approx_del2AsqdelRpak2-del2AsqdelRpa2(k));
  endif
  if abs(approx_del2AsqdelRpak2-del2AsqdelRpa2(k)) > tol
    error("abs(approx_del2AsqdelRpak2(=%g)-del2AsqdelRpa2(%d)(=%g)) > %g",
          approx_del2AsqdelRpak2,k,del2AsqdelRpa2(k),tol);
  endif
  delk=shift(delk,1);
endfor
tol=8e-9;
for k=1:Qon2
  % del2Asqdelrpa2
  [AsqacPdelk2,gradAsqacPdelk2] = ...
    parallel_allpass_delayAsq(wc,a+(delk/2),V,Q,R,DD,polyphase);
  [AsqacMdelk2,gradAsqacMdelk2] = ...
    parallel_allpass_delayAsq(wc,a-(delk/2),V,Q,R,DD,polyphase);
  approx_del2Asqdelrpak2=(gradAsqacPdelk2(V+k)-gradAsqacMdelk2(V+k))/del;
  if verbose
    printf("Filter a: conjugate pole/zero %d radius\n", k);
    printf("abs(approx_del2Asqdelrpak2-del2Asqdelrpa2(%d)=%g\n",
           k,approx_del2Asqdelrpak2-del2Asqdelrpa2(k));
  endif
  if abs(approx_del2Asqdelrpak2-del2Asqdelrpa2(k)) > tol
    error("abs(approx_del2Asqdelrpak2(=%g)-del2Asqdelrpa2(%d)(=%g)) > %g",
          approx_del2Asqdelrpak2,k,del2Asqdelrpa2(k),tol);
  endif
  delk=shift(delk,1);
endfor
tol=2e-7;
for k=1:Qon2
  % del2Asqdelthetapa2
  [AsqacPdelk2,gradAsqacPdelk2] = ...
    parallel_allpass_delayAsq(wc,a+(delk/2),V,Q,R,DD,polyphase);
  [AsqacMdelk2,gradAsqacMdelk2] = ...
    parallel_allpass_delayAsq(wc,a-(delk/2),V,Q,R,DD,polyphase);
  approx_del2Asqdelthetapak2 = ...
    (gradAsqacPdelk2(V+Qon2+k)-gradAsqacMdelk2(V+Qon2+k))/del;
  if verbose
    printf("Filter a: conjugate pole/zero %d angle\n", k);
    printf("approx_del2Asqdelthetapak2-del2Asqdelthetapa2(%d)=%g\n",
           k,approx_del2Asqdelthetapak2-del2Asqdelthetapa2(k));
  endif
  if abs(approx_del2Asqdelthetapak2-del2Asqdelthetapa2(k)) > tol
    error("abs(approx_del2Asqdelthetapak2(=%g)-del2Asqdelthetapa2(%d)(=%g))>%g",
          approx_del2Asqdelthetapak2,k,del2Asqdelthetapa2(k),tol);
  endif
  delk=shift(delk,1);
endfor

% Done
diary off
movefile parallel_allpass_delayAsq_test.diary.tmp ...
       parallel_allpass_delayAsq_test.diary;
