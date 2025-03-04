% butt3OneMPA_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
% 
% Test case for a high-pass 3rd order Butterworth filter implemented as the
% parallel combination of two one-multiplier allpass lattice filters

test_common;

strf="butt3OneMPA_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tol=1e-10

% fc is the filter cutoff as a fraction of the sampling frequency
fc=200
fs=48000
N=2^14;
f=(0:(N-1))'/(2*N);
w=2*pi*f;

% Direct form
[n,d]=butter(3,2*fc/fs,"high")
H=freqz(n,d,w);

% All-pass Gray and Markel decomposition
p=qroots(d);
r=p(end);
k=allpass_GM1_pole2coef(r)
e=-1
[a,b,c,dd]=allpass_GM1_coef2Abcd(k,e)
h1=Abcd2H(w,a,b,c,dd);

r2=abs(p(1));
theta2=angle(p(1));
[k1,k2]=allpass_GM2_pole2coef(r2,theta2,"complex")
e1=-1
e2=-1
[a2,b2,c2,d2]=allpass_GM2_coef2Abcd(k1,e1,k2,e2)
h2=Abcd2H(w,a2,b2,c2,d2);
if max(abs(((h2-h1)/2)-H)) > tol
  error("max(abs(((h2-h1)/2)-H)) > tol");
endif


% Schur lattice decomposition
[n,d]=butter(3,2*fc/fs)
[A1Star,A2Star]=tf2pa(n,d)
A1=fliplr(A1Star)
A2=fliplr(A2Star)
[A1k,A1epsilon,A1p,A1c,A1S] = tf2schurOneMlattice(A1,A1Star)
[A2k,A2epsilon,A2p,A2c,A2S] = tf2schurOneMlattice(A2,A2Star)
Asq=schurOneMPAlatticeAsq(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,true);
if max(abs(Asq-(abs(H).^2))) > tol
  error("max(abs(Asq-(abs(H).^2))) > tol");
endif

% Convert Schur lattice to state variable
[A1sv,B1sv,C1sv,D1sv]=schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p)
H1sv=Abcd2H(w,A1sv,B1sv,C1sv,D1sv);
[A2sv,B2sv,C2sv,D2sv]=schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p)
H2sv=Abcd2H(w,A2sv,B2sv,C2sv,D2sv);
if max(abs(((H1sv-H2sv)/2)-H)) > tol
  error("max(abs(((H1sv-H2sv)/2)-H)) > tol");
endif

diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
