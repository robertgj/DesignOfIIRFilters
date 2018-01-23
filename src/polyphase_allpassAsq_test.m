% polyphase_allpassAsq_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
% Check the squared-magnitude response and gradient for the polyphase
% combination of two allpass filters

test_common;

unlink("polyphase_allpassAsq_test.diary");
unlink("polyphase_allpassAsq_test.diary.tmp");
diary polyphase_allpassAsq_test.diary.tmp

format compact

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
% Check the squared-magnitude response
%

% Use freqz to find the frequency response
[Ba,Aa]=a2tf(aa,Va,Qa,R);
[Bb,Ab]=a2tf(ab,Vb,Qb,R);
Aab=conv(Aa,Ab);
Bab=0.5*([conv(Ab,Ba);zeros(R-1,1)]+[zeros(R-1,1);conv(Bb,Aa)]);
Nw=1024;
w=(0:(Nw-1))*pi/Nw;
Hab_freqz=freqz(Bab,Aab,w);

% Use polyphase_allpassAsq to find the squared-magnitude response
aa_ab=[aa(:);ab(:);];
w=w(:);
Asqab_allpass=parallel_allpassAsq(w,aa_ab,Va,Qa,R,Vb,Qb,R,true);

% Compare the squared-amplitude responses
maxAbsDelAsqeps=max(abs(Asqab_allpass-(abs(Hab_freqz(:)).^2)))/eps;
if maxAbsDelAsqeps > 20
  error("max(abs(Asqab_allpass-(abs(Hab_freqz(:)).^2)))/eps(=%g) > 20",
        maxAbsDelAsqeps);
endif

%
% Check partial derivatives
%
fc=0.20;
wc=2*pi*fc;

% Check partial derivatives of the phase
[Asqabc,gradAsqabc]=parallel_allpassAsq(wc,aa_ab,Va,Qa,R,Vb,Qb,R,true);

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
  [Asqabcd,gradAsqabcd]=parallel_allpassAsq(wc,aa_ab+delk,Va,Qa,R,Vb,Qb,R,true);
  printf("delAsqdelRpa=%f, approx=%f, diff=%f\n",...
         delAsqdelRpa(k), (Asqabcd-Asqabc)/del, ...
         delAsqdelRpa(k)-((Asqabcd-Asqabc)/del));

  delk=shift(delk,1);
endfor
for k=1:Qaon2
  printf("Filter a: conjugate pole/zero %d radius\n", k);

  % delPdelrpa
  [Asqabcd,gradAsqabcd]=parallel_allpassAsq(wc,aa_ab+delk,Va,Qa,R,Vb,Qb,R,true);
  printf("delAsqdelrpa=%f, approx=%f, diff=%f\n",...
         delAsqdelrpa(k), (Asqabcd-Asqabc)/del, ...
         delAsqdelrpa(k)-((Asqabcd-Asqabc)/del));

  delk=shift(delk,1);
endfor
for k=1:Qaon2
  printf("Filter a: conjugate pole/zero %d angle\n", k);

  % delPdelthetapa
  [Asqabcd,gradAsqabcd]=parallel_allpassAsq(wc,aa_ab+delk,Va,Qa,R,Vb,Qb,R,true);
  printf("delPdelthetapa=%f, approx=%f, diff=%f\n",...
         delAsqdelthetapa(k), (Asqabcd-Asqabc)/del,...
         delAsqdelthetapa(k)-((Asqabcd-Asqabc)/del));

  delk=shift(delk,1);
endfor

% Filter b
for k=1:Vb
  printf("Filter b: real pole/zero %d\n", k);

  % delPdelRpb
  [Asqabcd,gradAsqabcd]=parallel_allpassAsq(wc,aa_ab+delk,Va,Qa,R,Vb,Qb,R,true);
  printf("delAsqdelRpb=%f, approx=%f, diff=%f\n",...
         delAsqdelRpb(k), (Asqabcd-Asqabc)/del,...
         delAsqdelRpb(k)-((Asqabcd-Asqabc)/del));

  delk=shift(delk,1);
endfor
for k=1:Qbon2
  printf("Filter b: conjugate pole/zero %d radius\n", k);

  % delPdelrpb
  [Asqabcd,gradAsqabcd]=parallel_allpassAsq(wc,aa_ab+delk,Va,Qa,R,Vb,Qb,R,true);
  printf("delAsqdelrpb=%f, approx=%f, diff=%f\n",...
         delAsqdelrpb(k), (Asqabcd-Asqabc)/del, ...
         delAsqdelrpb(k)-((Asqabcd-Asqabc)/del));

  delk=shift(delk,1);
endfor
for k=1:Qbon2
  printf("Filter b: conjugate pole/zero %d angle\n", k);

  % delPdelthetapb
  [Asqabcd,gradAsqabcd]=parallel_allpassAsq(wc,aa_ab+delk,Va,Qa,R,Vb,Qb,R,true);
  printf("delPdelthetapb=%f, approx=%f, diff=%f\n",...
         delAsqdelthetapb(k), (Asqabcd-Asqabc)/del,...
         delAsqdelthetapb(k)-((Asqabcd-Asqabc)/del));

  delk=shift(delk,1);
endfor

% Done
diary off
movefile polyphase_allpassAsq_test.diary.tmp polyphase_allpassAsq_test.diary;
