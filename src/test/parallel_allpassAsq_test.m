% parallel_allpassAsq_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
% Check the squared-magnitude response and gradient for the parallel
% combination of two allpass filters

test_common;

delete("parallel_allpassAsq_test.diary");
delete("parallel_allpassAsq_test.diary.tmp");
diary parallel_allpassAsq_test.diary.tmp


% Define the filters
Da=[  1.000000  0.191995 -0.144503 -0.190714 -0.045705  0.067090 ...
      0.053660 -0.003322 -0.025701 -0.012428  0.000637  0.002141 ]';

Db=[  1.0000   -0.193141  0.193610  0.108123  0.020141 -0.015857 ...
     -0.013205  0.005607  0.006790 -0.000266  0.001254  0.004703  0.002996 ]';
K=2;

[aa,Va,Qa]=tf2a(Da);
[ab,Vb,Qb]=tf2a(Db);
polyphase=true;
if polyphase
  Ra=2;
  Rb=3;
else
  Ra=2;
  Rb=2;
endif

%
% Check the squared-magnitude response
%

% Use freqz to find the frequency response
[Ba,Aa]=a2tf(aa,Va,Qa,Ra);
[Bb,Ab]=a2tf(ab,Vb,Qb,Rb);
Aab=conv(Aa,Ab);
if polyphase
  Bab=(conv(Ab,[Ba;0])+conv([0;Bb],Aa))/2;
else
  Bab=(conv(Ab,Ba)+conv(Bb,Aa))/2;
endif
Nw=1024;
w=(0:(Nw-1))*pi/Nw;
Hab_freqz=freqz(Bab,Aab,w);
Asqab_freqz=(K*abs(Hab_freqz(:))).^2;

% Use parallel_allpassAsq to find the squared-magnitude response
aa_ab=[aa(:);ab(:);];
Asqab_allpass=parallel_allpassAsq(w,aa_ab,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase);

% Compare the squared-amplitude responses
maxAbsDelAsqeps=max(abs(Asqab_allpass-Asqab_freqz))/eps;
if maxAbsDelAsqeps > 500
  error("max(abs(Asqab_allpass-Asqab_freqz))/eps(=%g) > 500",
        maxAbsDelAsqeps);
endif

% Repeat with polyphase=false,difference=true
Babm=(conv(Ab,Ba)-conv(Bb,Aa))/2;
Habm_freqz=freqz(Babm,Aab,w);
Asqabm_freqz=(K*abs(Habm_freqz(:))).^2;
% Use parallel_allpassAsq to find the squared-magnitude response
aa_ab=[aa(:);ab(:);];
Asqabm_allpass=parallel_allpassAsq(w,aa_ab,K,Va,Qa,Ra,Vb,Qb,Rb,false,true);
% Compare the squared-amplitude responses
maxAbsDelAsqM=max(abs(Asqabm_allpass-Asqabm_freqz));
if maxAbsDelAsqM > 500*eps
  error("max(abs(Asqabm_allpass-Asqabm_freqz))(=%g*eps) > 500*eps",
        maxAbsDelAsqM/eps);
endif

%
% Check partial derivatives
%
fc=0.20;
wc=2*pi*fc;

% Check partial derivatives of the phase
[Asqabc,gradAsqabc]=parallel_allpassAsq(wc,aa_ab,K,Va,Qa,Ra,Vb,Qb,Rb);

delAsqdelRpa=gradAsqabc(1:Va);
Qaon2=Qa/2;
delAsqdelrpa=gradAsqabc((Va+1):(Va+Qaon2));
delAsqdelthetapa=gradAsqabc((Va+Qaon2+1):(Va+Qa));

delAsqdelRpb=gradAsqabc((Va+Qa+1):(Va+Qa+Vb));
Qbon2=Qb/2;
delAsqdelrpb=gradAsqabc((Va+Qa+Vb+1):(Va+Qa+Vb+Qbon2));
delAsqdelthetapb=gradAsqabc((Va+Qa+Vb+Qbon2+1):(Va+Qa+Vb+Qb));

% Find approximate values
del=1e-6;
delk=[del;zeros(Va+Qa+Vb+Qb-1,1)];

% Filter a
for k=1:Va
  printf("Filter a: real pole/zero %d\n", k);

  % delPdelRpa
  [Asqabcd,gradAsqabcd]=parallel_allpassAsq(wc,aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb);
  printf("delAsqdelRpa=%f, approx=%f, diff=%f\n",...
         delAsqdelRpa(k), (Asqabcd-Asqabc)/del,...
         delAsqdelRpa(k)-((Asqabcd-Asqabc)/del));

  delk=circshift(delk,1);
endfor
for k=1:Qaon2
  printf("Filter a: conjugate pole/zero %d radius\n", k);

  % delPdelrpa
  [Asqabcd,gradAsqabcd]=parallel_allpassAsq(wc,aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb);
  printf("delAsqdelrpa=%f, approx=%f, diff=%f\n",...
         delAsqdelrpa(k), (Asqabcd-Asqabc)/del, ...
         delAsqdelrpa(k)-((Asqabcd-Asqabc)/del));

  delk=circshift(delk,1);
endfor
for k=1:Qaon2
  printf("Filter a: conjugate pole/zero %d angle\n", k);

  % delPdelthetapa
  [Asqabcd,gradAsqabcd]=parallel_allpassAsq(wc,aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb);
  printf("delPdelthetapa=%f, approx=%f, diff=%f\n",...
         delAsqdelthetapa(k), (Asqabcd-Asqabc)/del,...
         delAsqdelthetapa(k)-((Asqabcd-Asqabc)/del));

  delk=circshift(delk,1);
endfor

% Filter b
for k=1:Vb
  printf("Filter b: real pole/zero %d\n", k);

  % delPdelRpb
  [Asqabcd,gradAsqabcd]=parallel_allpassAsq(wc,aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb);
  printf("delAsqdelRpb=%f, approx=%f, diff=%f\n",...
         delAsqdelRpb(k), (Asqabcd-Asqabc)/del,...
         delAsqdelRpb(k)-((Asqabcd-Asqabc)/del));

  delk=circshift(delk,1);
endfor
for k=1:Qbon2
  printf("Filter b: conjugate pole/zero %d radius\n", k);

  % delPdelrpb
  [Asqabcd,gradAsqabcd]=parallel_allpassAsq(wc,aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb);
  printf("delAsqdelrpb=%f, approx=%f, diff=%f\n",...
         delAsqdelrpb(k), (Asqabcd-Asqabc)/del, ...
         delAsqdelrpb(k)-((Asqabcd-Asqabc)/del));

  delk=circshift(delk,1);
endfor
for k=1:Qbon2
  printf("Filter b: conjugate pole/zero %d angle\n", k);

  % delPdelthetapb
  [Asqabcd,gradAsqabcd]=parallel_allpassAsq(wc,aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb);
  printf("delPdelthetapb=%f, approx=%f, diff=%f\n",...
         delAsqdelthetapb(k), (Asqabcd-Asqabc)/del,...
         delAsqdelthetapb(k)-((Asqabcd-Asqabc)/del));

  delk=circshift(delk,1);
endfor

% Done
diary off
movefile parallel_allpassAsq_test.diary.tmp parallel_allpassAsq_test.diary;
