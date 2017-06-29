% allpass2ndOrderCascade_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("allpass2ndOrderCascade_test.diary");
unlink("allpass2ndOrderCascade_test.diary.tmp");
diary allpass2ndOrderCascade_test.diary.tmp

format compact

tol=1e-4;

% Define an odd-order cascade
Da = [  1.0000000   0.2720754  -0.0650616  -0.1982797  -0.1569593 ...
       -0.0380531   0.0540930   0.0731458   0.0400886   0.0018243 ...
       -0.0134044  -0.0085775 ]';
ma = length(Da)-1;
sosDa=tf2sos(Da,1);
for k=1:rows(sosDa)
  if sosDa(k,3) == 0
    sos1Da=sosDa(k,2);
    sosDa(k,:)=[];
  endif
endfor
sosDa=vec(sosDa(:,2:3)');

% Define an even-order cascade
Db = [  1.0000000  -0.2744550   0.1402831   0.1431500   0.0731533 ...
        0.0119103  -0.0131149  -0.0119635  -0.0057932  -0.0056367 ...
       -0.0086158  -0.0084756  -0.0042435 ]';
mb = length(Db)-1;
sosDb=tf2sos(Db,1);
sosDb=vec(sosDb(:,2:3)');

% Define parallel sum of allpass cascades
ab = [sos1Da;sosDa;sosDb];

% Check the corresponding polynomials for each allpass filter
Datf=casc2tf(ab(1:ma));
if max(abs(Datf-Da)) > 19*eps
  error("max(abs(Datf-Da))(=%g*eps) > 19*eps",max(abs(Datf-Da))/eps);
endif
Dbtf=casc2tf(ab((ma+1):end));
if max(abs(Dbtf-Db)) > 18*eps
  error("max(abs(Dbtf-Db))(=%g*eps) > 18*eps",max(abs(Dbtf-Db))/eps);
endif

% Test complex response
n=256;
[Hafreqz,w]=freqz(flipud(Da(:)),Da,n);
Hbfreqz=freqz(flipud(Db(:)),Db,n);
Ha=allpass2ndOrderCascade(ab(1:ma),w);
Hb=allpass2ndOrderCascade(ab((ma+1):end),w);
if max(abs(Hafreqz-Ha)) > 51*eps
  error("max(abs(Hafreqz-Ha))(=%g*eps) > 51*eps",max(abs(Hafreqz-Ha))/eps);
endif
if max(abs(Hbfreqz-Hb)) > 80*eps
  error("max(abs(Hbfreqz-Hb))(=%g*eps) > 80*eps",max(abs(Hbfreqz-Hb))/eps);
endif

Haplusbfreqz=0.5*(Hafreqz+Hbfreqz);
Haplusb=0.5*(Ha+Hb);
Nab=0.5*(conv(flipud(Da(:)),Db)+conv(flipud(Db(:)),Da));
Dab=conv(Da,Db);
Hab=freqz(Nab,Dab,n);
if max(abs(Haplusb-Hab)) > 60*eps
  error("max(abs(Haplusb-Hab))(=%g*eps) > 60*eps",max(abs(Haplusb-Hab))/eps);
endif

% Test group delay response
ftp=0.175;
ntp=0.175*n/0.5;
Tab=grpdelay(Nab,Dab,n);
Tab=Tab(1:(ntp-1));
Tgd=-diff(unwrap(arg(Haplusb(1:ntp))))./diff(w(1:ntp));
if max(abs((Tgd-Tab)./Tab)) > 5e-4
  error("max(abs((Tgd-Tab(1:(ntp-1)))./Tab)) > 5e-4")
endif

% Test gradient of response
wtest=0.1234*2*pi;
del=tol/10;
[Hat,gradHat]=allpass2ndOrderCascade(ab(1:ma),wtest);
[Hbt,gradHbt]=allpass2ndOrderCascade(ab((ma+1):end),wtest);
Haplusbt=0.5*(Hat+Hbt);
gradHaplusbt=0.5*[gradHat gradHbt];
gradHaplusbt_delk=zeros(1,ma+mb);
delk=[del;zeros(ma+mb-1,1)];
for k=1:ma
  HatPdelkon2=allpass2ndOrderCascade(ab(1:ma)+(delk(1:ma)/2),wtest);
  HatMdelkon2=allpass2ndOrderCascade(ab(1:ma)-(delk(1:ma)/2),wtest);
  gradHaplusbt_delk(k)=(HatPdelkon2-HatMdelkon2)/(2*del);
  if abs(gradHaplusbt(k)-gradHaplusbt_delk(k))/abs(gradHaplusbt(k)) > 2e-10
    error("abs(gradHab(%d)-gradHab_delk(%d))/abs(gradHab(%d))(=%g) > 2e-10\n",
          k,k,k,abs(gradHaplusbt(k)-gradHaplusbt_delk(k))/abs(gradHaplusbt(k)));
  endif
  delk=shift(delk,1);
endfor
for k=(ma+1):(ma+mb)
  HbtPdelkon2=allpass2ndOrderCascade(ab((ma+1):end)+(delk((ma+1):end)/2),wtest);
  HbtMdelkon2=allpass2ndOrderCascade(ab((ma+1):end)-(delk((ma+1):end)/2),wtest);
  gradHaplusbt_delk(k)=(HbtPdelkon2-HbtMdelkon2)/(2*del);
  if abs(gradHaplusbt(k)-gradHaplusbt_delk(k))/abs(gradHaplusbt(k)) > 25e-11
    error("abs(gradHab(%d)-gradHab_delk(%d))/abs(gradHab(%d))(=%g) > 25e-11\n",
          k,k,k,abs(gradHaplusbt(k)-gradHaplusbt_delk(k))/abs(gradHaplusbt(k)));
  endif
  delk=shift(delk,1);
endfor

% Done
diary off
movefile allpass2ndOrderCascade_test.diary.tmp allpass2ndOrderCascade_test.diary;
