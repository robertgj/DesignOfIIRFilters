% parallel_allpassT_test.m
% Copyright (C) 2017 Robert G. Jenssen
% Check the group delay response and gradient for the parallel
% combination of two allpass filters

test_common;

unlink("parallel_allpassT_test.diary");
unlink("parallel_allpassT_test.diary.tmp");
diary parallel_allpassT_test.diary.tmp

format compact

% Define the filters
Da=[  1.000000  0.191995 -0.144503 -0.190714 -0.045705  0.067090 ...
      0.053660 -0.003322 -0.025701 -0.012428  0.000637  0.002141 ]';

Db=[  1.0000   -0.193141  0.193610  0.108123  0.020141 -0.015857 ...
     -0.013205  0.005607  0.006790 -0.000266  0.001254  0.004703  0.002996 ]';

[aa,Va,Qa]=tf2a(Da);
[ab,Vb,Qb]=tf2a(Db);
Ra=2;
Rb=3;
polyphase=true;

%
% Check the group delay response
%

% Use grpdelay to find the group delay response
[Ba,Aa]=a2tf(aa,Va,Qa,Ra);
[Bb,Ab]=a2tf(ab,Vb,Qb,Rb);
Aab=conv(Aa,Ab);
Bab=0.5*(conv(Ab,[Ba;0])+conv([0;Bb],Aa));
Nw=1024;
Tab_grpdelay=grpdelay(Bab,Aab,Nw);

% Alternative calculation
[Ta,w]=grpdelay(Ba,Aa,Nw);
[Tb,w]=grpdelay(Bb,Ab,Nw);
if polyphase
  Tpoly=1;
else
  Tpoly=0;
endif
Tab_alt=(Ta+Tb+Tpoly)/2;

% Use parallel_allpassT to find the group delay response
aa_ab=[aa(:);ab(:);];
Tab_allpass=parallel_allpassT(w,aa_ab,Va,Qa,Ra,Vb,Qb,Rb,polyphase);

% Compare the group delay responses
maxAbsDelT=max(abs(Tab_allpass-Tab_alt));
if maxAbsDelT > 320*eps
  warning("max(abs(Tab_allpass-Tab_alt))/eps(=%d) > 320*eps",
          maxAbsDelT/eps);
endif

%
% Check partial derivatives
%
fc=0.20;
wc=2*pi*fc;

% Check partial derivatives of the group delay
[Tab,gradTab]=parallel_allpassT(wc,aa_ab,Va,Qa,Ra,Vb,Qb,Rb,polyphase);

delTdelRpa=gradTab(1:Va);
Qaon2=Qa/2;
delTdelrpa=gradTab((Va+1):(Va+Qaon2));
delTdelthetapa=gradTab((Va+Qaon2+1):(Va+Qa));

delTdelRpb=gradTab((Va+Qa+1):(Va+Qa+Vb));
Qbon2=Qb/2;
delTdelrpb=gradTab((Va+Qa+Vb+1):(Va+Qa+Vb+Qbon2));
delTdelthetapb=gradTab((Va+Qa+Vb+Qbon2+1):(Va+Qa+Vb+Qb));

% Find approximate values
tol=7e-9;
del=1e-6;
delk=[del;zeros(Va+Qa+Vb+Qb-1,1)];

% Filter a
for k=1:Va
  % delTdelRpa
  TabPd2=parallel_allpassT(wc,aa_ab+(delk/2),Va,Qa,Ra,Vb,Qb,Rb,polyphase);
  TabMd2=parallel_allpassT(wc,aa_ab-(delk/2),Va,Qa,Ra,Vb,Qb,Rb,polyphase);
  approx_delTdelRpak=(TabPd2-TabMd2)/del;
  diff_delTdelRpak=delTdelRpa(k)-approx_delTdelRpak;
  if abs(diff_delTdelRpak)>tol
    error("Filter a: real pole/zero %d\n\
delTdelRpa=%g, approx=%g, diff=%g\n",
          k, delTdelRpa(k), approx_delTdelRpak, diff_delTdelRpak);
  endif
  delk=shift(delk,1);
endfor
for k=1:Qaon2
  % delTdelrpa
  TabPd2=parallel_allpassT(wc,aa_ab+(delk/2),Va,Qa,Ra,Vb,Qb,Rb,polyphase);
  TabMd2=parallel_allpassT(wc,aa_ab-(delk/2),Va,Qa,Ra,Vb,Qb,Rb,polyphase);
  approx_delTdelrpak=(TabPd2-TabMd2)/del;
  diff_delTdelrpak=delTdelrpa(k)-approx_delTdelrpak;
  if abs(diff_delTdelrpak)>tol
    error("Filter a: conjugate pole/zero %d radius\n\
delTdelrpa=%g, approx=%g, diff=%g\n",
          k, delTdelrpa(k), approx_delTdelrpak, diff_delTdelrpak);
  endif
  delk=shift(delk,1);
endfor
for k=1:Qaon2
  % delTdelthetapa
  TabPd2=parallel_allpassT(wc,aa_ab+(delk/2),Va,Qa,Ra,Vb,Qb,Rb,polyphase);
  TabMd2=parallel_allpassT(wc,aa_ab-(delk/2),Va,Qa,Ra,Vb,Qb,Rb,polyphase);
  approx_delTdelthetapak=(TabPd2-TabMd2)/del;
  diff_delTdelthetapak=delTdelthetapa(k)-approx_delTdelthetapak;
  if abs(diff_delTdelthetapak)>tol
    error("Filter a: conjugate pole/zero %d angle\n\
delTdelthetapa=%g, approx=%g, diff=%g\n",
          k, delTdelthetapa(k), approx_delTdelthetapak, diff_delTdelthetapak);
  endif
  delk=shift(delk,1);
endfor

% Filter b
for k=1:Vb
  % delTdelRpb
  TabPd2=parallel_allpassT(wc,aa_ab+(delk/2),Va,Qa,Ra,Vb,Qb,Rb,polyphase);
  TabMd2=parallel_allpassT(wc,aa_ab-(delk/2),Va,Qa,Ra,Vb,Qb,Rb,polyphase);
  approx_delTdelRpbk=(TabPd2-TabMd2)/del;
  diff_delTdelRpbk=delTdelRpb(k)-approx_delTdelRpbk;
  if abs(diff_delTdelRpbk)>tol
    error("Filter b: real pole/zero %d\n\
delTdelRpb=%g, approx=%g, diff=%g\n",
          k, delTdelRpb(k), approx_delTdelRpbk, diff_delTdelRpbk);
  endif
  delk=shift(delk,1);
endfor
for k=1:Qbon2
  % delTdelrpb
  TabPd2=parallel_allpassT(wc,aa_ab+(delk/2),Va,Qa,Ra,Vb,Qb,Rb,polyphase);
  TabMd2=parallel_allpassT(wc,aa_ab-(delk/2),Va,Qa,Ra,Vb,Qb,Rb,polyphase);
  approx_delTdelrpbk=(TabPd2-TabMd2)/del;
  diff_delTdelrpbk=delTdelrpb(k)-approx_delTdelrpbk;
  if abs(diff_delTdelrpbk)>tol
    error("Filter b: conjugate pole/zero %d radius\n\
delTdelrpb=%g, approx=%g, diff=%g\n",
          k, delTdelrpb(k), approx_delTdelrpbk, diff_delTdelrpbk);
  endif
  delk=shift(delk,1);
endfor
for k=1:Qbon2
  % delTdelthetapb
  TabPd2=parallel_allpassT(wc,aa_ab+(delk/2),Va,Qa,Ra,Vb,Qb,Rb,polyphase);
  TabMd2=parallel_allpassT(wc,aa_ab-(delk/2),Va,Qa,Ra,Vb,Qb,Rb,polyphase);
  approx_delTdelthetapbk=(TabPd2-TabMd2)/del;
  diff_delTdelthetapbk=delTdelthetapb(k)-approx_delTdelthetapbk;
  if abs(diff_delTdelthetapbk)>tol
    error("Filter b: conjugate pole/zero %d angle\n\
delTdelthetapb=%g, approx=%g, diff=%g\n",
          k, delTdelthetapb(k), approx_delTdelthetapbk, diff_delTdelthetapbk);
  endif
  delk=shift(delk,1);
endfor

% Done
diary off
movefile parallel_allpassT_test.diary.tmp parallel_allpassT_test.diary;
