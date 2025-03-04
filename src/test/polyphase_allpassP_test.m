% polyphase_allpassP_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
% Check the phase response and gradient for the polyphase
% combination of two allpass filters.
%
% Note the hack to fix phase shifts of pi in the freqz response
% at singularities. Is this due to folding of the response when
% calculated by a decimation-in-time-or-frequency FFT?

test_common;

delete("polyphase_allpassP_test.diary");
delete("polyphase_allpassP_test.diary.tmp");
diary polyphase_allpassP_test.diary.tmp


verbose=true

% Define the filters
Da=[  1.0000000  -0.2417770   0.1502374  -0.0954946   0.0755760 ...
     -0.0583735   0.0439859  -0.0278528   0.0024596 ];
Db=[  1.0000      2.4989e-01 -9.4678e-02  3.6513e-02 -3.0003e-02 ...
      1.8666e-02 -1.0464e-02  6.8495e-04  1.7134e-02 ];
[aa,Va,Qa]=tf2a(Da);
[ab,Vb,Qb]=tf2a(Db);
R=2;

%
% Check the phase response
%

% Use freqz to find the frequency response
[Ba,Aa]=a2tf(aa,Va,Qa,R);
[Bb,Ab]=a2tf(ab,Vb,Qb,R);
Aab=conv(Aa,Ab);
Bab=0.5*([conv(Ab,Ba);0]+[0;conv(Bb,Aa)]);
Nw=1024;
fap=0.20;
nap=ceil(fap*Nw/0.5)+1;
w=(0:(Nw-1))'*pi/Nw;
wa=w(1:(nap-1));
Hab_freqz=freqz(Bab,Aab,wa);
Pabf=unwrap(angle(Hab_freqz));
Pabf=Pabf(:);
if 0
  % If using w(0:(Nw-1)) allow for pi phase shifts in the
  % freqz response at singularities
  Pab_freqz = Pabf - cumsum(pi*[0;diff(Pabf)>( pi/2)]) + ...
              cumsum(pi*[0;diff(Pabf)<(-pi/2)]);
else
  Pab_freqz = Pabf;
endif

% Use polyphase_allpassP to find the phase response
aa_ab=[aa(:);ab(:);];
Pab_allpass=parallel_allpassP(wa,aa_ab,Va,Qa,R,Vb,Qb,R,true);

% Compare the squared-amplitude responses
maxAbsDelPeps=max(abs(Pab_allpass-Pab_freqz(:)))/eps;
if maxAbsDelPeps > 32
  error("max(abs(Pab_allpass-Pab_freqz(:)))/eps(=%g) > 32*eps",
        maxAbsDelPeps);
endif

%
% Check partial derivatives
%
fc=0.20;
wc=2*pi*fc;

% Check partial derivatives of the phase
[Pabc,gradPabc]=parallel_allpassP(wc,aa_ab,Va,Qa,R,Vb,Qb,R,true);

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
  [Pabcd,gradPabcd]=parallel_allpassP(wc,aa_ab+delk,Va,Qa,R,Vb,Qb,R,true);
  printf("delPdelRpa=%f, approx=%f, diff=%f\n",...
         delPdelRpa(k), (Pabcd-Pabc)/del,...
         delPdelRpa(k)-((Pabcd-Pabc)/del));

  delk=circshift(delk,1);
endfor
for k=1:Qaon2
  printf("Filter a: conjugate pole/zero %d radius\n", k);

  % delPdelrpa
  [Pabcd,gradPabcd]=parallel_allpassP(wc,aa_ab+delk,Va,Qa,R,Vb,Qb,R,true);
  printf("delPdelrpa=%f, approx=%f, diff=%f\n",...
         delPdelrpa(k), (Pabcd-Pabc)/del, ...
         delPdelrpa(k)-((Pabcd-Pabc)/del));

  delk=circshift(delk,1);
endfor
for k=1:Qaon2
  printf("Filter a: conjugate pole/zero %d angle\n", k);

  % delPdelthetapa
  [Pabcd,gradPabcd]=parallel_allpassP(wc,aa_ab+delk,Va,Qa,R,Vb,Qb,R,true);
  printf("delPdelthetapa=%f, approx=%f, diff=%f\n",...
         delPdelthetapa(k), (Pabcd-Pabc)/del,...
         delPdelthetapa(k)-((Pabcd-Pabc)/del));

  delk=circshift(delk,1);
endfor

% Filter b
for k=1:Vb
  printf("Filter b: real pole/zero %d\n", k);

  % delPdelRpb
  [Pabcd,gradPabcd]=parallel_allpassP(wc,aa_ab+delk,Va,Qa,R,Vb,Qb,R,true);
  printf("delPdelRpb=%f, approx=%f, diff=%f\n",...
         delPdelRpb(k), (Pabcd-Pabc)/del,...
         delPdelRpb(k)-((Pabcd-Pabc)/del));

  delk=circshift(delk,1);
endfor
for k=1:Qbon2
  printf("Filter b: conjugate pole/zero %d radius\n", k);

  % delPdelrpb
  [Pabcd,gradPabcd]=parallel_allpassP(wc,aa_ab+delk,Va,Qa,R,Vb,Qb,R,true);
  printf("delPdelrpb=%f, approx=%f, diff=%f\n",...
         delPdelrpb(k), (Pabcd-Pabc)/del, ...
         delPdelrpb(k)-((Pabcd-Pabc)/del));

  delk=circshift(delk,1);
endfor
for k=1:Qbon2
  printf("Filter b: conjugate pole/zero %d angle\n", k);

  % delPdelthetapb
  [Pabcd,gradPabcd]=parallel_allpassP(wc,aa_ab+delk,Va,Qa,R,Vb,Qb,R,true);
  printf("delPdelthetapb=%f, approx=%f, diff=%f\n",...
         delPdelthetapb(k), (Pabcd-Pabc)/del,...
         delPdelthetapb(k)-((Pabcd-Pabc)/del));

  delk=circshift(delk,1);
endfor

% Done
diary off
movefile polyphase_allpassP_test.diary.tmp polyphase_allpassP_test.diary;
