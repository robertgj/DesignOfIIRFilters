% benchmark_iirA_freqz_test.m
% Copyright (C) 2022-2026 Robert G. Jenssen

test_common;

delete("benchmark_iirA_freqz_test.diary");
delete("benchmark_iirA_freqz_test.diary.tmp");
diary benchmark_iirA_freqz_test.diary.tmp

tic;

strf="benchmark_iirA_freqz_test";

%
% Initial coefficients from schurOneMPAlattice_socp_slb_bandpass_hilbert_test.m
%
A1k = [  -0.4562840864,   0.8402776683,  -0.3098215977,   0.1703087020, ... 
          0.6486396502,  -0.3793485882,   0.2190654451,   0.4501243760, ... 
         -0.3484852669,   0.2581545686 ];
A1epsilon = [   1,  1,  1, -1,  1,  1, -1, -1,  1,  1 ];
A1p = [   0.8217705222,   1.3448925517,   0.3962130094,   0.5458258785, ... 
          0.6482552939,   0.2992675148,   0.4461416003,   0.5574153336, ... 
          0.9052099184,   1.3022977381 ];
A2k = [  -0.8098958551,   0.8848410408,  -0.3758498446,   0.1423917229, ... 
          0.6652786728,  -0.3507843601,   0.2265736413,   0.4519170720, ... 
         -0.3337929337,   0.2615546729 ];
A2epsilon = [  1,  1,  1, -1, -1, -1, -1,  1,  1, -1 ];
A2p = [   0.3458017784,   1.0669847741,   0.2637361869,   0.3915711630, ... 
          0.4519326757,   1.0080347657,   0.6988387619,   0.8800641193, ... 
          0.5407126703,   0.7650787419 ];
A1d = [   1.0000000000,  -1.5197027047,   1.4848359353,   0.3956466620, ... 
         -1.8161329898,   2.2125503124,  -0.6845245159,  -0.6323659945, ... 
          1.2174609748,  -0.7175790872,   0.2581545686 ]';
A2d = [   1.0000000000,  -2.2664872182,   2.1042431350,   0.3573745969, ... 
         -2.7699727733,   2.9973575445,  -0.8904057394,  -1.0785732134, ... 
          1.6021025332,  -0.9037681994,   0.2615546729 ]';
difference=true;

[N,D]=schurOneMPAlattice2tf(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
[x,U,V,M,Q]=tf2x(N,D);R=1;

%
% n a power of 2
%
H_tim_2=[];
A_tim_2=[];
Asq_tim_2=[];
AsqDP_tim_2=[];

p=4:16;
nr2=2.^p;
for n=nr2,

  display(n);
  
  wa=(0:(n-1))'*pi/n;
  waDP=wa(1:floor(n/2));

  H=freqz(N,D,n);
  t0=clock();
  for l=1:10, 
    H=freqz(N,D,n);
  endfor
  t1=clock();
  H_tim_2=[H_tim_2,etime(t1,t0)/l];
  
  A=iirA(wa,x,U,V,M,Q,R);
  t0=clock();
  for l=1:10, 
    A=iirA(wa,x,U,V,M,Q,R);
  endfor
  t1=clock();
  A_tim_2=[A_tim_2,etime(t1,t0)/l];
  
  Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  t0=clock();
  for l=1:10,
    Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  endfor
  t1=clock();
  Asq_tim_2=[Asq_tim_2,etime(t1,t0)/l];

  AsqDP=schurOneMPAlatticeDoublyPipelinedAsq(waDP,A1k,A2k,difference);
  t0=clock();
  for l=1:10,
    AsqDP=schurOneMPAlatticeDoublyPipelinedAsq(waDP,A1k,A2k,difference);
  endfor
  t1=clock();
  AsqDP_tim_2=[AsqDP_tim_2,etime(t1,t0)/l];

endfor

semilogy(p,H_tim_2,"-",p,A_tim_2,"--",p,Asq_tim_2,"-.",p,AsqDP_tim_2,":");
xlabel("Frequency vector length");
xticks([2:2:16]);
xticklabels ({"$2^{2}$","$2^{4}$","$2^{6}$","$2^{8}$", ...
              "$2^{10}$","$2^{12}$","$2^{14}$","$2^{16}$"})
ylabel("Mean execution time (seconds)");
legend("freqz","iirA","schurOneMPAlatticeAsq", ...
       "schurOneMPAlatticeDoublyPipelinedAsq");
legend("location","northwest");
legend("boxoff");
legend("right");
grid("on");
title(sprintf(["Mean execution time (%d runs) ", ...
               "freqz,iirA,schurOneMPAlatticeAsq,", ...
               "schurOneMPAlatticeDoublyPipelinedAsq"],l));
zticks([]);
print(strcat(strf,sprintf("_n_%d",n)),"-dpdflatex");
close

%
% Fix n and vary filter length
%

H_tim_m=[];
A_tim_m=[];
Asq_tim_m=[];
AsqDP_tim_m=[];

n=4000;
fpass=0.1;
npass=floor(fpass*(n-1)/0.5)+1;
mm=3:2:21;

for m=3:2:21

  display(m);
  
  [N,D]=butter(m,2*fpass);
  [x,U,V,M,Q]=tf2x(N,D);R=1;
  [a1,a2]=tf2pa(N,D);
  [A1k,A1epsilon,A1p,A1c] = tf2schurOneMlattice(flipud(a1(:)),a1(:));
  [A2k,A2epsilon,A2p,A2c] = tf2schurOneMlattice(flipud(a2(:)),a2(:));

  wa=(0:(n-1))'*pi/n;
  waDP=wa(1:floor(n/2));

  H=freqz(N,D,n);
  t0=clock();
  for l=1:10, 
    H=freqz(N,D,n);
  endfor
  t1=clock();
  H_tim_m=[H_tim_m,etime(t1,t0)/l];
  
  A=iirA(wa,x,U,V,M,Q,R);
  t0=clock();
  for l=1:10, 
    A=iirA(wa,x,U,V,M,Q,R);
  endfor
  t1=clock();
  A_tim_m=[A_tim_m,etime(t1,t0)/l];
  
  Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);
  t0=clock();
  for l=1:10,
    Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);
  endfor
  t1=clock();
  Asq_tim_m=[Asq_tim_m,etime(t1,t0)/l];

  AsqDP=schurOneMPAlatticeDoublyPipelinedAsq(waDP,A1k,A2k);
  t0=clock();
  for l=1:10,
    AsqDP=schurOneMPAlatticeDoublyPipelinedAsq(waDP,A1k,A2k);
  endfor
  t1=clock();
  AsqDP_tim_m=[AsqDP_tim_m,etime(t1,t0)/l];

endfor

semilogy(mm,H_tim_m,"-",mm,A_tim_m,"--",mm,Asq_tim_m,"-.",mm,AsqDP_tim_m,":");
xlabel("Filter order");
xticks(mm);
ylabel("Mean execution time (seconds)");
axis([3,21,0.0001,2]);
legend("freqz","iirA","schurOneMPAlatticeAsq", ...
       "schurOneMPAlatticeDoublyPipelinedAsq");
legend("location","northwest");
legend("boxoff");
legend("right");
grid("on");
title(sprintf(["Mean execution time (%d runs) ", ...
               "freqz,iirA,schurOneMPAlatticeAsq,", ...
               "schurOneMPAlatticeDoublyPipelinedAsq"],l));
zticks([]);
print(strcat(strf,sprintf("_m_%d",n)),"-dpdflatex");
close

% Done
toc;
eval(sprintf(["save %s.mat n x U V M Q R N D ", ...
              "AsqDP_tim_2 Asq_tim_2 A_tim_2 H_tim_2 ", ...
              "AsqDP_tim_m Asq_tim_m A_tim_m H_tim_m"],strf));

diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
