% parallel_allpass_mmse_error_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
% Check the MMSE error and gradient for the parallel
% combination of two allpass filters

test_common;

unlink("parallel_allpass_mmse_error_test.diary");
unlink("parallel_allpass_mmse_error_test.diary.tmp");
diary parallel_allpass_mmse_error_test.diary.tmp

format compact

verbose=true

% Define the filters
Da=[  1.000000  0.191995 -0.144503 -0.190714 -0.045705  0.067090 ...
      0.053660 -0.003322 -0.025701 -0.012428  0.000637  0.002141 ]';

Db=[  1.0000   -0.193141  0.193610  0.108123  0.020141 -0.015857 ...
     -0.013205  0.005607  0.006790 -0.000266  0.001254  0.004703  0.002996 ]';

[aa,Va,Qa]=tf2a(Da);
[ab,Vb,Qb]=tf2a(Db);
aa_ab=[aa(:);ab(:);];
polyphase=false;
Ra=2;
Rb=3;
K=3;

% Define the frequency edges and weighting factors
fap=0.15
Wap=1
fas=0.2
Was=400
ftp=0.175
Wtp=100
tp=11.5*(Ra+Rb)/2

% Frequency vectors
% The freqz function returns phase modulo 2*pi so, when using that
% function, first find the response over the whole frequency range and
% then select the required frequencies.
n=1000;

% Desired pass-band squared magnitude response
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Desired pass-band group delay response
ntp=ceil(n*ftp/0.5)+1;
Td=tp*ones(ntp,1);
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
[T_grpdelay,wt]=grpdelay(Bab,Aab,n);
wt=wt(1:ntp);
Twt_grpdelay=T_grpdelay(1:ntp);

% Check squared-magnitude response
Asqwa_freqz=(K*abs(H_freqz(:))).^2;
Asqwa_allpass=parallel_allpassAsq(wa,aa_ab,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
maxAbsAsqwa_freqz_allpass_eps=max(abs(Asqwa_freqz-Asqwa_allpass))/eps;
if maxAbsAsqwa_freqz_allpass_eps > 1000
  error("max(abs(Asqwa_freqz-Asqwa_allpass))/eps(=%g)>1000\n",
          maxAbsAsqwa_freqz_allpass_eps);
endif

% Check group-delay response
Twt_allpass=parallel_allpassT(wt,aa_ab,Va,Qa,Ra,Vb,Qb,Rb,polyphase);
maxAbsTwt_grpdelay_allpass_eps = max(abs(Twt_grpdelay-Twt_allpass))/eps;
if maxAbsTwt_grpdelay_allpass_eps > 745824
  error("max(abs(Twt_grpdelay-Twt_allpass))/eps(=%g)>745824\n",
          maxAbsTwt_grpdelay_allpass_eps);
endif

%
% Find the freqz MMSE error
%

% Squared-magnitude
AsqwaMAsqd=Asqwa_freqz-Asqd;
Ewa_freqz=sum(diff(wa).*((Wa(1:(n-1)).*(AsqwaMAsqd(1:(n-1)).^2)) + ...
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
if absEeps > 375808
  error("abs(Eab_test-Eab_allpass)/eps(=%g) > 375808", absEeps);
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
del=1e-6;
delk=[del;zeros(Va+Qa+Vb+Qb-1,1)];

% Filter a
for k=1:Va
  printf("Filter a: real pole/zero %d\n", k);

  % delPdelRpa
  [Eabcd,gradEabcd]=...
    parallel_allpass_mmse_error(aa_ab+delk,K,Va,Qa,Ra,Vb,Qb,Rb,...
                                polyphase,wa,Asqd,Wa,wt,Td,Wt);
  printf("delEdelRpa=%f, approx=%f, diff=%f\n",...
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
  printf("delEdelrpa=%f, approx=%f, diff=%f\n",...
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
  printf("delPdelthetapa=%f, approx=%f, diff=%f\n",...
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
  printf("delEdelRpb=%f, approx=%f, diff=%f\n",...
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
  printf("delEdelrpb=%f, approx=%f, diff=%f\n",...
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
  printf("delPdelthetapb=%f, approx=%f, diff=%f\n",...
         delEdelthetapb(k), (Eabcd-Eabc)/del,...
         delEdelthetapb(k)-((Eabcd-Eabc)/del));

  delk=shift(delk,1);
endfor

% Done
diary off
movefile parallel_allpass_mmse_error_test.diary.tmp ...
         parallel_allpass_mmse_error_test.diary;
