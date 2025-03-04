% parallel_allpassP_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
% Check the phase response and gradient for the parallel
% combination of two allpass filters

test_common;

delete("parallel_allpassP_test.diary");
delete("parallel_allpassP_test.diary.tmp");
diary parallel_allpassP_test.diary.tmp

verbose=true

% Define the filters
Da=[  1.000000  0.191995 -0.144503 -0.190714 -0.045705  0.067090 ...
      0.053660 -0.003322 -0.025701 -0.012428  0.000637  0.002141 ]';

Db=[  1.0000   -0.193141  0.193610  0.108123  0.020141 -0.015857 ...
     -0.013205  0.005607  0.006790 -0.000266  0.001254  0.004703  0.002996 ]';

[aa,Va,Qa]=tf2a(Da);
[ab,Vb,Qb]=tf2a(Db);
Ra=2;
Rb=3;

%
% Check the phase response
%

% Use freqz to find the frequency response
[Ba,Aa]=a2tf(aa,Va,Qa,Ra);
[Bb,Ab]=a2tf(ab,Vb,Qb,Rb);
Aab=conv(Aa,Ab);
Bab=0.5*(conv(Ab,Ba)+conv(Bb,Aa));
Nw=1024;
[Hab_freqz,w]=freqz(Bab,Aab,Nw);
Hab_freqz2=freqz(Bab,Aab,w(1:600));
Pabf=unwrap(angle(Hab_freqz));

% ?!?!? 
% Phase unwrapping hack. For Ra=2, Rb=3, the pi phase shift in the
% freqz response at the singularities does not appear in the allpassP
% response. Is this a consequence of the folding implicit in the
% freqz(DFT) calculation of the response?
% ?!?!?
Pabf=Pabf(:);
Pab_freqz = Pabf - cumsum(pi*[0;diff(Pabf)>(pi/2)]) + ...
                   cumsum(pi*[0;diff(Pabf)<(-pi/2)]);

% Use parallel_allpassP to find the phase response
aa_ab=[aa(:);ab(:);];
Pab_allpass=parallel_allpassP(w,aa_ab,Va,Qa,Ra,Vb,Qb,Rb);

% Compare the squared-amplitude responses
maxAbsDelPeps=max(abs(Pab_allpass-Pab_freqz))/eps;
if maxAbsDelPeps > 384
  error("max(abs(Pab_allpass-Pab_freqz))/eps(=%d) > 384*eps",
        maxAbsDelPeps);
endif

%
% Check partial derivatives
%
fc=0.20;
wc=2*pi*fc;

% Check partial derivatives of the phase
[Pabc,gradPabc]=parallel_allpassP(wc,aa_ab,Va,Qa,Ra,Vb,Qb,Rb);

delPdelRpa=gradPabc(1:Va);
Qaon2=Qa/2;
delPdelrpa=gradPabc((Va+1):(Va+Qaon2));
delPdelthetapa=gradPabc((Va+Qaon2+1):(Va+Qa));

delPdelRpb=gradPabc((Va+Qa+1):(Va+Qa+Vb));
Qbon2=Qb/2;
delPdelrpb=gradPabc((Va+Qa+Vb+1):(Va+Qa+Vb+Qbon2));
delPdelthetapb=gradPabc((Va+Qa+Vb+Qbon2+1):(Va+Qa+Vb+Qb));

% Find approximate values
del=1e-6;
delk=[del;zeros(Va+Qa+Vb+Qb-1,1)];

% Filter a
for k=1:Va
  printf("Filter a: real pole/zero %d\n", k);

  % delPdelRpa
  [Pabcd,gradPabcd]=parallel_allpassP(wc,aa_ab+delk,Va,Qa,Ra,Vb,Qb,Rb);
  printf("delPdelRpa=%f, approx=%f, diff=%f\n",...
         delPdelRpa(k), (Pabcd-Pabc)/del,...
         delPdelRpa(k)-((Pabcd-Pabc)/del));

  delk=circshift(delk,1);
endfor
for k=1:Qaon2
  printf("Filter a: conjugate pole/zero %d radius\n", k);

  % delPdelrpa
  [Pabcd,gradPabcd]=parallel_allpassP(wc,aa_ab+delk,Va,Qa,Ra,Vb,Qb,Rb);
  printf("delPdelrpa=%f, approx=%f, diff=%f\n",...
         delPdelrpa(k), (Pabcd-Pabc)/del, ...
         delPdelrpa(k)-((Pabcd-Pabc)/del));

  delk=circshift(delk,1);
endfor
for k=1:Qaon2
  printf("Filter a: conjugate pole/zero %d angle\n", k);

  % delPdelthetapa
  [Pabcd,gradPabcd]=parallel_allpassP(wc,aa_ab+delk,Va,Qa,Ra,Vb,Qb,Rb);
  printf("delPdelthetapa=%f, approx=%f, diff=%f\n",...
         delPdelthetapa(k), (Pabcd-Pabc)/del,...
         delPdelthetapa(k)-((Pabcd-Pabc)/del));

  delk=circshift(delk,1);
endfor

% Filter b
for k=1:Vb
  printf("Filter b: real pole/zero %d\n", k);

  % delPdelRpb
  [Pabcd,gradPabcd]=parallel_allpassP(wc,aa_ab+delk,Va,Qa,Ra,Vb,Qb,Rb);
  printf("delPdelRpb=%f, approx=%f, diff=%f\n",...
         delPdelRpb(k), (Pabcd-Pabc)/del,...
         delPdelRpb(k)-((Pabcd-Pabc)/del));

  delk=circshift(delk,1);
endfor
for k=1:Qbon2
  printf("Filter b: conjugate pole/zero %d radius\n", k);

  % delPdelrpb
  [Pabcd,gradPabcd]=parallel_allpassP(wc,aa_ab+delk,Va,Qa,Ra,Vb,Qb,Rb);
  printf("delPdelrpb=%f, approx=%f, diff=%f\n",...
         delPdelrpb(k), (Pabcd-Pabc)/del, ...
         delPdelrpb(k)-((Pabcd-Pabc)/del));

  delk=circshift(delk,1);
endfor
for k=1:Qbon2
  printf("Filter b: conjugate pole/zero %d angle\n", k);

  % delPdelthetapb
  [Pabcd,gradPabcd]=parallel_allpassP(wc,aa_ab+delk,Va,Qa,Ra,Vb,Qb,Rb);
  printf("delPdelthetapb=%f, approx=%f, diff=%f\n",...
         delPdelthetapb(k), (Pabcd-Pabc)/del,...
         delPdelthetapb(k)-((Pabcd-Pabc)/del));

  delk=circshift(delk,1);
endfor

% Done
diary off
movefile parallel_allpassP_test.diary.tmp parallel_allpassP_test.diary;
