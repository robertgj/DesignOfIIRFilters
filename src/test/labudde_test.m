% labudde_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("labudde_test.diary");
delete("labudde_test.diary.tmp");
diary labudde_test.diary.tmp

check_octave_file("labudde");

% Find an elliptic filter
N=11;dbap=0.1;dbas=40;fc=0.05;
[n,d]=ellip(N,dbap,dbas,2*fc);
printf("d=[ "),printf("% 18.16f\n",d),printf("]\n");

% Find the state transition matrix
[A,B,C,D]=tf2Abcd(n,d);
printf("max(max(abs(A)))=%g\n",max(max(abs(A))));
printf("rcond(A)=%g\n",rcond(A));

% Compare with poly(A)
[nn,dd]=zp2tf([],eig(A),1);
pA=poly(A);
printf("poly(A)=[ "),printf("% 18.16f\n",pA),printf("]\n");
printf("norm(d-poly(A))=%g\n",norm(d-pA));

% Compare with La Budde's algorithm for finding the characteristic polynomial
lA=labudde(A);
printf("labudde(A)=[ "),printf("% 18.16f\n",lA),printf("]\n");
printf("norm(d(2:end)-labudde(A))=%g\n",norm(d(2:end)-lA));

% PCLS IIR band pass filter
n0=[  0.0122406745  0.0032335651  0.0284352513  0.0230594766 ...
      0.0559170855  0.0317107181  0.0344137852 -0.0051171498 ...
     -0.0029166417 -0.0414127710 -0.0707321368 -0.0996480133 ...
     -0.0576265162  0.0482735641  0.1363992301  0.1511324768 ...
      0.0537877610 -0.0393519010 -0.0985933689 -0.0671845011 ...
     -0.0342988274 ];
d0=[  1.0000000000  0.0000000000  1.8669208761  0.0000000000 ...
      2.2147829706  0.0000000000  2.2883188635  0.0000000000 ...
      2.0751642794  0.0000000000  1.5701398181  0.0000000000 ...
      1.0247030922  0.0000000000  0.5684534801  0.0000000000 ...
      0.2633896210  0.0000000000  0.0887207128  0.0000000000 ...
      0.0197382407 ];
[A,B,C,D]=tf2Abcd(n0,d0);
pA=poly(A);
printf("poly(A)=[ "),printf("% 18.16f\n",pA),printf("]\n");
printf("norm(d0-poly(A))=%g\n",norm(d0-pA));
lA=labudde(A);
printf("labudde(A)=[ "),printf("% 18.16f\n",lA),printf("]\n");
printf("norm(d0(2:end)-labudde(A))=%g\n",norm(d0(2:end)-lA));

% Done
diary off
movefile labudde_test.diary.tmp labudde_test.diary;
