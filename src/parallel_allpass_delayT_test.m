% parallel_allpass_delayT_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
% Check the group delay response and gradient for the parallel
% combination of an allpass filter and a pure delay

test_common;

unlink("parallel_allpass_delayT_test.diary");
unlink("parallel_allpass_delayT_test.diary.tmp");
diary parallel_allpass_delayT_test.diary.tmp

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

[Ta,gradTa]=parallel_allpass_delayT([],a,V,Q,R,DD);
if ~isempty(Ta)
  error("Expected Ta empty");
endif
if ~isempty(gradTa)
  error("Expected gradTa empty");
endif

%
% Check the group delay response
%

% Use freqz to find the frequency response
[Ba,Aa]=a2tf(a,V,Q,R);
n=1024;
[Ta_grpdelay,w]=grpdelay(Ba',Aa',n);
Ta_grpdelay=(Ta_grpdelay+DD)/2;

% Use parallel_allpass_delayT to find the group delay response
Ta_allpass=parallel_allpass_delayT(w,a,V,Q,R,DD,polyphase);

% Compare the group delay responses
maxAbsDelTeps=max(abs(Ta_allpass-Ta_grpdelay))/eps;
if maxAbsDelTeps > 3073
  error("max(abs(Ta_allpass-Ta_grpdelay).^2)/eps(=%g) > 3073",maxAbsDelTeps);
endif

%
% Check partial derivatives
%
fc=0.175;
wc=2*pi*fc;

% Check partial derivatives of the group delay
[Tac,gradTac,diagHessTac]=parallel_allpass_delayT(wc,a,V,Q,R,DD,polyphase);

delTdelRpa=gradTac(1:V);
Qon2=Q/2;
delTdelrpa=gradTac((V+1):(V+Qon2));
delTdelthetapa=gradTac((V+Qon2+1):end);
del2TdelRpa2=diagHessTac(1:V);
del2Tdelrpa2=diagHessTac((V+1):(V+Qon2));
del2Tdelthetapa2=diagHessTac((V+Qon2+1):end);

% Find approximate values
tol=4e-9;
del=1e-6;
delk=[del;zeros(V+Q-1,1)];

% Compare with calculated values
for k=1:V
  % delTdelRpa
  TacPdelk2=parallel_allpass_delayT(wc,a+(delk/2),V,Q,R,DD,polyphase);
  TacMdelk2=parallel_allpass_delayT(wc,a-(delk/2),V,Q,R,DD,polyphase);
  approx_delTdelRpak=(TacPdelk2-TacMdelk2)/del;
  if verbose
    printf("Filter a: real pole/zero %d\n", k);
    printf("abs(approx_delTdelRpak-delTdelRpa(%d))=%g\n",
           k,approx_delTdelRpak-delTdelRpa(k));
  endif
  if abs(approx_delTdelRpak-delTdelRpa(k)) > tol
    error("abs(approx_delTdelRpak(=%g)-delTdelRpa(%d)(=%g)) > %g",
          approx_delTdelRpak,k,delTdelRpa(k),tol);
  endif
  delk=shift(delk,1);
endfor
tol=2.1e-7;
for k=1:Qon2
  % delTdelrpa
  TacPdelk2=parallel_allpass_delayT(wc,a+(delk/2),V,Q,R,DD,polyphase);
  TacMdelk2=parallel_allpass_delayT(wc,a-(delk/2),V,Q,R,DD,polyphase);
  approx_delTdelrpak=(TacPdelk2-TacMdelk2)/del;
  if verbose
    printf("Filter a: conjugate pole/zero %d radius\n", k);
    printf("abs(approx_delTdelrpak-delTdelrpa(%d))=%g\n",
           k,approx_delTdelrpak-delTdelrpa(k));
  endif
  if abs(approx_delTdelrpak-delTdelrpa(k)) > tol
    error("abs(approx_delTdelrpak(=%g)-delTdelrpa(%d)(=%g)) > %g",
          approx_delTdelrpak,k,delTdelrpa(k),tol);
  endif
  delk=shift(delk,1);
endfor
for k=1:Qon2
  % delTdelthetapa
  TacPdelk2=parallel_allpass_delayT(wc,a+(delk/2),V,Q,R,DD,polyphase);
  TacMdelk2=parallel_allpass_delayT(wc,a-(delk/2),V,Q,R,DD,polyphase);
  approx_delTdelthetapak=(TacPdelk2-TacMdelk2)/del;
  if verbose
    printf("Filter a: conjugate pole/zero %d angle\n", k);
    printf("abs(approx_delTdelthetapak-delTdelthetapa(%d))=%g\n",
           k,approx_delTdelthetapak-delTdelthetapa(k));
  endif
  if abs(approx_delTdelthetapak-delTdelthetapa(k)) > tol
    error("abs(approx_delTdelthetapak(=%g)-delTdelthetapa(%d)(=%g)) > %g",
          approx_delTdelthetapak,k,delTdelthetapa(k),tol);
  endif
  delk=shift(delk,1);
endfor

% Compare diagonal of Hessian with calculated values
for k=1:V
  % del2TdelRpa2
  [TacPdelk2,gradTacPdelk2] = ...
    parallel_allpass_delayT(wc,a+(delk/2),V,Q,R,DD,polyphase);
  [TacMdelk2,gradTacMdelk2] = ...
    parallel_allpass_delayT(wc,a-(delk/2),V,Q,R,DD,polyphase);
  approx_del2TdelRpak2=(gradTacPdelk2(k)-gradTacMdelk2(k))/del;
  if verbose
    printf("Filter a: real pole/zero %d\n", k); 
    printf("abs(approx_del2TdelRpak2-del2TdelRpa2(%d)=%g\n",
           k,approx_del2TdelRpak2-del2TdelRpa2(k));
  endif
  if abs(approx_del2TdelRpak2-del2TdelRpa2(k)) > tol
    error("abs(approx_del2TdelRpak2(=%g)-del2TdelRpa2(%d)(=%g)) > %g",
          approx_del2TdelRpak2,k,del2TdelRpa2(k),tol);
  endif
  delk=shift(delk,1);
endfor
tol=2.7e-6;
for k=1:Qon2
  % del2Tdelrpa2
  [TacPdelk2,gradTacPdelk2] = ...
    parallel_allpass_delayT(wc,a+(delk/2),V,Q,R,DD,polyphase);
  [TacMdelk2,gradTacMdelk2] = ...
    parallel_allpass_delayT(wc,a-(delk/2),V,Q,R,DD,polyphase);
  approx_del2Tdelrpak2=(gradTacPdelk2(V+k)-gradTacMdelk2(V+k))/del;
  if verbose
    printf("Filter a: conjugate pole/zero %d radius\n", k);
    printf("abs(approx_del2Tdelrpak2-del2Tdelrpa2(%d)=%g\n",
           k,approx_del2Tdelrpak2-del2Tdelrpa2(k));
  endif
  if abs(approx_del2Tdelrpak2-del2Tdelrpa2(k)) > tol
    error("abs(approx_del2Tdelrpak2(=%g)-del2Tdelrpa2(%d)(=%g)) > %g",
          approx_del2Tdelrpak2,k,del2Tdelrpa2(k),tol);
  endif
  delk=shift(delk,1);
endfor
tol=6e-7;
for k=1:Qon2
  % del2Tdelthetapa2
  [TacPdelk2,gradTacPdelk2] = ...
    parallel_allpass_delayT(wc,a+(delk/2),V,Q,R,DD,polyphase);
  [TacMdelk2,gradTacMdelk2] = ...
    parallel_allpass_delayT(wc,a-(delk/2),V,Q,R,DD,polyphase);
  approx_del2Tdelthetapak2 = ...
    (gradTacPdelk2(V+Qon2+k)-gradTacMdelk2(V+Qon2+k))/del;
  if verbose
    printf("Filter a: conjugate pole/zero %d angle\n", k);
    printf("approx_del2Tdelthetapak2-del2Tdelthetapa2(%d)=%g\n",
           k,approx_del2Tdelthetapak2-del2Tdelthetapa2(k));
  endif
  if abs(approx_del2Tdelthetapak2-del2Tdelthetapa2(k)) > tol
    error("abs(approx_del2Tdelthetapak2(=%g)-del2Tdelthetapa2(%d)(=%g))>%g",
          approx_del2Tdelthetapak2,k,del2Tdelthetapa2(k),tol);
  endif
  delk=shift(delk,1);
endfor

% Done
diary off
movefile parallel_allpass_delayT_test.diary.tmp ...
       parallel_allpass_delayT_test.diary;
