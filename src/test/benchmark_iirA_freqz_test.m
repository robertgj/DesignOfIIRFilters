% benchmark_iirA_freqz_test.m
% Copyright (C) 2022 Robert G. Jenssen

test_common;

delete("benchmark_iirA_freqz_test.diary");
delete("benchmark_iirA_freqz_test.diary.tmp");
diary benchmark_iirA_freqz_test.diary.tmp

tic;

strf="benchmark_iirA_freqz_test";

%
% Initial coefficients from schurOneMPAlattice_socp_slb_bandpass_hilbert_test.m
%
A1k = [  -0.4135004229,   0.6119694730,   0.4794873904,  -0.5067394002, ... 
          0.7072993736,  -0.3010516772,  -0.0646071285,   0.3675203809, ... 
         -0.2563697410,   0.0890435079 ];
A1epsilon = [  -1,  -1,   1,   1,   1,   1,   1,  -1,  -1,  -1 ];
A1p = [   0.9856238388,   0.6348879426,   1.2940246193,   0.7675426769, ... 
          1.3414774959,   0.5554441242,   0.7578183494,   0.8084678865, ... 
          1.1887934672,   0.9145894817 ];
A2k = [  -0.7696310526,   0.7216132469,   0.4481643290,  -0.5762702648, ... 
          0.7320010792,  -0.2531067642,  -0.0688876567,   0.3754458362, ... 
         -0.2352692288,   0.1058925849 ];
A2epsilon = [  -1,  -1,   1,  -1,  -1,   1,  -1,   1,   1,  -1 ];
A2p = [   1.1896028264,   0.4292127269,   1.0673727377,   0.6588887134, ... 
          0.3416183554,   0.8684578679,   1.1248989931,   1.0499014585, ... 
          0.7074762197,   0.8991628915 ];
difference=true;
[N,D]=schurOneMPAlattice2tf(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
[x,U,V,M,Q]=tf2x(N,D);R=1;

%
% n a multiple of 200
%
Asq_tim=[];
H_tim=[];
A_tim=[];

nr=200:200:10000;
for n=nr,

  display(n);
  
  wa=(1:(n-1))'*pi/n;

  Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  t0=clock();
  for k=1:10,
    Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  endfor
  t1=clock();
  Asq_tim=[Asq_tim,etime(t1,t0)/k];

  H=freqz(N,D,n);
  t0=clock();
  for k=1:10, 
    H=freqz(N,D,n);
  endfor
  t1=clock();
  H_tim=[H_tim,etime(t1,t0)/k];
  
  A=iirA(wa,x,U,V,M,Q,R);
  t0=clock();
  for k=1:20, 
    A=iirA(wa,x,U,V,M,Q,R);
  endfor
  t1=clock();
  A_tim=[A_tim,etime(t1,t0)/k];
  
endfor

semilogy(nr,Asq_tim,"--",nr,A_tim,"-",nr,H_tim,"-.");
xlabel("Frequency vector length ($n$)");
ylabel("Mean execution time (seconds)");
legend("schurOneMPAlatticeAsq","iirA","freqz");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
title(sprintf ...
        ("Mean execution time (%d runs) schurOneMPAlatticeAsq,iirA,freqz",k));
print(strcat(strf,sprintf("_n_%d",n)),"-dpdflatex");
close

%
% n a power of 2
%
Asq_tim_2=[];
H_tim_2=[];
A_tim_2=[];

p=4:16;
nr2=2.^p;
for n=nr2,

  display(n);
  
  wa=(0:(n-1))'*pi/n;

  Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  t0=clock();
  for k=1:10,
    Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
  endfor
  t1=clock();
  Asq_tim_2=[Asq_tim_2,etime(t1,t0)/k];

  H=freqz(N,D,n);
  t0=clock();
  for k=1:10, 
    H=freqz(N,D,n);
  endfor
  t1=clock();
  H_tim_2=[H_tim_2,etime(t1,t0)/k];
  
  A=iirA(wa,x,U,V,M,Q,R);
  t0=clock();
  for k=1:20, 
    A=iirA(wa,x,U,V,M,Q,R);
  endfor
  t1=clock();
  A_tim_2=[A_tim_2,etime(t1,t0)/k];
  
endfor

semilogy(p,Asq_tim_2,"--",p,A_tim_2,"-",p,H_tim_2,"-.");
xlabel("Frequency vector length ($log_2 n$)");
ylabel("Mean execution time (seconds)");
legend("schurOneMPAlatticeAsq","iirA","freqz");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
title(sprintf ...
        ("Mean execution time (%d runs) schurOneMPAlatticeAsq,iirA,freqz",k));
print(strcat(strf,sprintf("_n_%d",n)),"-dpdflatex");
close

save benchmark_iirA_freqz_test.mat x U V M Q R N D ...
     Asq_tim A_tim H_tim Asq_tim_2 A_tim_2 H_tim_2

% Done
toc;
diary off
movefile benchmark_iirA_freqz_test.diary.tmp benchmark_iirA_freqz_test.diary;
