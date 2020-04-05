% polyphase_allpass_mmse_error_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
% Check the MMSE error and gradient for the polyphase
% combination of two allpass filters

test_common;

delete("polyphase_allpass_mmse_error_test.diary");
delete("polyphase_allpass_mmse_error_test.diary.tmp");
diary polyphase_allpass_mmse_error_test.diary.tmp


verbose=true

% Define the filters
Da=[  1 -0.241332     0.143073    -0.0987151   0.0713625 ...
        -0.0520244    0.0374542   -0.026202    0.0175032 ...
        -0.0108774    0.00594168  -0.00219399]';
Db=[  1  0.249873    -0.0875688    0.0456447  -0.0265908 ...
         0.0158547   -0.00918635   0.00488877 -0.00212948 ...
         0.000421648  0.000587837 -0.00135729]';

[aa,Va,Qa]=tf2a(Da);
[ab,Vb,Qb]=tf2a(Db);
aa_ab=[aa(:);ab(:);];
polyphase=true;
Ra=2;
Rb=2;
K=2;
Ksq=K^2;

% Define the frequency edges and weighting factors
fap=0.22
Wap=1
fas=0.28
Was=1000
ftp=0.22
Wtp=10
td=22

% Frequency vectors
% The freqz function returns phase modulo 2*pi so, when using that
% function, first find the response over the whole frequency range and
% then select the required frequencies.
n=1000;

% Desired pass-band squared magnitude response
% (Do not use wa=0 because of zero coefficient gradients).
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=Ksq*[ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)]/Ksq;

% Desired pass-band group delay response
ntp=ceil(n*ftp/0.5)+1;
Td=td*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

%
% Check the MMSE error
%

% Use freqz and grpdelay to find the frequency response.
[Ba,Aa]=a2tf(aa,Va,Qa,Ra);
[Bb,Ab]=a2tf(ab,Vb,Qb,Rb);
Aab=conv(Aa,Ab);
if polyphase
  Bab=(conv(Aa,[0;Bb])+conv([Ba;0],Ab))/2;
else
  Bab=(conv(Aa,Bb)+conv(Ba,Ab))/2;
endif
[H_freqz,wa]=freqz(Bab,Aab,n);
H_freqz=H_freqz(:);
Asqwa_freqz=abs(K*H_freqz(:)).^2;
[T_grpdelay,wt]=grpdelay(Bab,Aab,n);
wt=wt(1:ntp);
Twt_grpdelay=T_grpdelay(1:ntp);

% Check frequency responses
Asqwa_allpass=parallel_allpassAsq(wa,aa_ab,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
maxAbsAsqwa_freqz_allpass_eps=max(abs(Asqwa_freqz-Asqwa_allpass))/eps;
if maxAbsAsqwa_freqz_allpass_eps > 100
  error("max(abs(Asqwa_freqz-Asqwa_allpass))/eps(=%g)>100\n",
          maxAbsAsqwa_freqz_allpass_eps);
endif

Twt_allpass=parallel_allpassT(wt,aa_ab,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
maxAbsTwt_grpdelay_allpass_eps=max(abs(Twt_grpdelay-Twt_allpass))/eps;
if maxAbsTwt_grpdelay_allpass_eps > 192
  error("max(abs(Twt_grpdelay-Twt_allpass))/eps(=%g)>192\n",
          maxAbsTwt_grpdelay_allpass_eps);
endif

%
% Find the freqz MMSE error
%

% Passband amplitude
AsqwaMAsqd=Asqwa_freqz-(Asqd);
Ewa_freqz=sum(diff(wa).*((Wa(1:(n-1)).*(AsqwaMAsqd(1:n-1).^2)) + ...
                         (Wa(2:end).*(AsqwaMAsqd(2:end).^2))))/2;

% Passband group delay
TwtMTd=Twt_grpdelay-Td;
Ewt_grpdelay=sum(diff(wt).*((Wt(1:(ntp-1)).*(TwtMTd(1:(ntp-1)).^2)) + ...
                            (Wt(2:end).*(TwtMTd(2:end).^2))))/2;

% Total
Eab_test = Ewa_freqz + Ewt_grpdelay;

% Use parallel_allpass_mmse_error to find the MMSE error
Eab_allpass=parallel_allpass_mmse_error ...
  (aa_ab,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,wa,Asqd,Wa,wt,Td,Wt);

% Compare the MMSE error values
absEeps=abs(Eab_test-Eab_allpass)/eps;
if absEeps > 198
  error("abs(Eab_test-Eab_allpass)/eps(=%g) > 198", absEeps);
endif

%
% Check partial derivatives of the MMSE error
%
[Eabc,gradEabc]=...
  parallel_allpass_mmse_error(aa_ab,K,Va,Qa,Ra,Vb,Qb,Rb,...
                              polyphase,wa,Asqd,Wa,wt,Td,Wt);

delEdelRpa=gradEabc(1:Va);
Qaon2=Qa/2;
delEdelrpa=gradEabc((Va+1):(Va+Qaon2));
delEdelthetapa=gradEabc((Va+Qaon2+1):(Va+Qa));

delEdelRpb=gradEabc((Va+Qa+1):(Va+Qa+Vb));
Qbon2=Qb/2;
delEdelrpb=gradEabc((Va+Qa+Vb+1):(Va+Qa+Vb+Qbon2));
delEdelthetapb=gradEabc((Va+Qa+Vb+Qbon2+1):(Va+Qa+Vb+Qb));

% Find approximate values
del=1e-8;
delk=[del;zeros(Va+Qa+Vb+Qb-1,1)];

% Filter a
for k=1:Va
  printf("Filter a: real pole/zero %d\n", k);

  % delPdelRpa
  [Eabcd,gradEabcd]=...
    parallel_allpass_mmse_error(aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb,...
                                polyphase,wa,Asqd,Wa,wt,Td,Wt);
  printf("delEdelRpa=%g, approx=%g, diff=%g\n",...
         delEdelRpa(k), (Eabcd-Eabc)/del,...
         delEdelRpa(k)-((Eabcd-Eabc)/del));

  delk=shift(delk,1);
endfor
for k=1:Qaon2
  printf("Filter a: conjugate pole/zero %d radius\n", k);

  % delPdelrpa
  [Eabcd,gradEabcd]=...
    parallel_allpass_mmse_error(aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb,...
                                polyphase,wa,Asqd,Wa,wt,Td,Wt);
  printf("delEdelrpa=%g, approx=%g, diff=%g\n",...
         delEdelrpa(k), (Eabcd-Eabc)/del, ...
         delEdelrpa(k)-((Eabcd-Eabc)/del));

  delk=shift(delk,1);
endfor
for k=1:Qaon2
  printf("Filter a: conjugate pole/zero %d angle\n", k);

  % delPdelthetapa
  [Eabcd,gradEabcd]=...
    parallel_allpass_mmse_error(aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb,...
                                polyphase,wa,Asqd,Wa,wt,Td,Wt);
  printf("delPdelthetapa=%g, approx=%g, diff=%g\n",...
         delEdelthetapa(k), (Eabcd-Eabc)/del,...
         delEdelthetapa(k)-((Eabcd-Eabc)/del));

  delk=shift(delk,1);
endfor

% Filter b
for k=1:Vb
  printf("Filter b: real pole/zero %d\n", k);

  % delPdelRpb
  [Eabcd,gradEabcd]=...
    parallel_allpass_mmse_error(aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb,...
                                polyphase,wa,Asqd,Wa,wt,Td,Wt);
  printf("delEdelRpb=%g, approx=%g, diff=%g\n",...
         delEdelRpb(k), (Eabcd-Eabc)/del,...
         delEdelRpb(k)-((Eabcd-Eabc)/del));

  delk=shift(delk,1);
endfor
for k=1:Qbon2
  printf("Filter b: conjugate pole/zero %d radius\n", k);

  % delPdelrpb
  [Eabcd,gradEabcd]=...
    parallel_allpass_mmse_error(aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb,...
                                polyphase,wa,Asqd,Wa,wt,Td,Wt);
  printf("delEdelrpb=%g, approx=%g, diff=%g\n",...
         delEdelrpb(k), (Eabcd-Eabc)/del, ...
         delEdelrpb(k)-((Eabcd-Eabc)/del));

  delk=shift(delk,1);
endfor
for k=1:Qbon2
  printf("Filter b: conjugate pole/zero %d angle\n", k);

  % delPdelthetapb
  [Eabcd,gradEabcd]=...
    parallel_allpass_mmse_error(aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb,...
                                polyphase,wa,Asqd,Wa,wt,Td,Wt);
  printf("delPdelthetapb=%g, approx=%g, diff=%g\n",...
         delEdelthetapb(k), (Eabcd-Eabc)/del,...
         delEdelthetapb(k)-((Eabcd-Eabc)/del));

  delk=shift(delk,1);
endfor

% Done
diary off
movefile polyphase_allpass_mmse_error_test.diary.tmp ...
         polyphase_allpass_mmse_error_test.diary;
