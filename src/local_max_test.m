% local_max_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("local_max_test.diary");
unlink("local_max_test.diary.tmp");
diary local_max_test.diary.tmp


% Check empty
x=local_max([]);
if ~isempty(x)
  error("Expected x empty");
endif

% Check one element
x=local_max([pi]);
if (length(x) ~= 1) || (x(1) ~= 1)
  error("Expected x(1)=1");
endif

% Check equal elements
x=local_max([1 2 3 3 3 2 1]);
if (length(x) ~= 1) || (x(1) ~= 5)
  error("Expected x(1)=5");
endif

% Filter specification
nN=9;dbap=3;dbas=20;fap=0.2;
[N,D]=ellip(nN,dbap,dbas,fap*2);

% Constraints on response that will fail
n=4000;nap=ceil(fap*2*n)+1;tol=1e-6;
Adu=[0.9*ones(nap,1);10^-(1.1*dbas/20)*ones(n-nap,1)];
Adl=[10^-(0.9*dbap/20)*ones(nap,1);tol*ones(n-nap,1)];

% Amplitude response
[H,wa]=freqz(N,D,n);
A=abs(H);

% Location of peaks of amplitude response
Sau=local_max(A);
Sal=local_max(-A);

% Location of peaks of failing constraints
vSau=Sau(find(A(Sau)-Adu(Sau)>tol));
vSal=Sal(find(Adl(Sal)-A(Sal)>tol));

% Plot response
plot(wa*0.5/pi,20*log10(abs(A)),"-b");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -25 5]);
title("Test local\\_max.m with a 9th order elliptical filter");
hold on

% Plot response peaks
plot(wa*0.5/pi,20*log10(abs(Adu)),"-g")
plot(wa*0.5/pi,20*log10(abs(Adl)),"-r")

% Plot constraints
plot(wa(Sau)*0.5/pi,20*log10(abs(A(Sau))),"*g")
plot(wa(Sal)*0.5/pi,20*log10(abs(A(Sal))),"xr")

% Plot peaks of failing constraints
plot(wa(vSau)*0.5/pi,20*log10(abs(A(vSau))),"og")
plot(wa(vSal)*0.5/pi,20*log10(abs(A(vSal))),"or")

% Print results
printf("Sau=[");printf("%d ",Sau);printf("]\n");
printf("vSau=[");printf("%d ",vSau);printf("]\n");
printf("Sal=[");printf("%d ",Sal);printf("]\n");
printf("vSal=[");printf("%d ",vSal);printf("]\n");

% Done
print("local_max_test","-dpdflatex");
axis([0.194 0.206 -25 5]);
print("local_max_test_detail","-dpdflatex");
close
diary off
movefile local_max_test.diary.tmp local_max_test.diary;
