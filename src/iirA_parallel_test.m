% iirA_parallel_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("iirA_parallel_test.diary");
unlink("iirA_parallel_test.diary.tmp");
diary iirA_parallel_test.diary.tmp

% The parallel package is not supported on Windows
try
  pkg load parallel
catch
  error("Loading the parallel package failed!\n");
end_try_catch

format compact

naverage=10;

% Define a filter
fc=0.10;U=2;V=2;M=20;Q=8;R=3;tol=1e-9;
x0=[  0.0089234, ...
      0.5000000,  ...
     -0.5000000,  ...
      0.5000000,  ...
     -0.5000000,  ...
     -0.5000000, -0.5000000,  0.5000000,  0.5000000,  0.5000000, ...
      0.5000000,  0.5000000,  0.5000000,  0.5000000,  0.8000000, ...
      0.6700726,  0.7205564,  0.8963898,  1.1980053,  1.3738387, ...
      1.4243225,  2.7644677,  2.8149515,  2.9907849,  1.9896753, ...
     -0.9698147, -0.8442244,  0.4511337,  0.4242641, ...
      1.8917946,  1.7780303,  1.2325954,  0.7853982 ]';

Np=nproc-1;
nlen=6;
maxchunks=16;
nplot=zeros(nlen,maxchunks);
parallel_threshold=zeros(nlen,maxchunks);
A_time=zeros(nlen,maxchunks);
Ap_time=zeros(nlen,maxchunks);
gradA_time=zeros(nlen,maxchunks);
gradAp_time=zeros(nlen,maxchunks);
for k=1:nlen
  for l=1:maxchunks

    % Initialise
    nplot(k,l)=2^(10+k);
    parallel_threshold(k,l)=floor(nplot(k,l)/l);
    w=(0:(nplot(k,l)-1))*pi/nplot(k,l);

    % Test amplitude
    for m=1:naverage
      tic();
      Ap=iirA_parallel(w,x0,U,V,M,Q,R,tol,Np,parallel_threshold(k,l));
      Ap_time(k,l)+=toc()/naverage;
      tic();
      A=iirA(w,x0,U,V,M,Q,R,tol);
      A_time(k,l)+=toc()/naverage;
      if max(abs(Ap-A))~=0
        error("max(abs(Ap-A))=%g,nplot=%d,parallel_threshold=%d",
              max(abs(Ap-A)),nplot(k,l),parallel_threshold(k,l));
      endif
    endfor

    % Test gradients of amplitude
    for m=1:naverage
      tic();
      [Ap,gradAp]=iirA_parallel(w,x0,U,V,M,Q,R,tol,Np,parallel_threshold(k,l));
      gradAp_time(k,l)+=toc()/naverage;
      tic();
      [A,gradA]=iirA(w,x0,U,V,M,Q,R,tol);
      gradA_time(k,l)+=toc()/naverage;
      if max(abs(gradAp-gradA))~=0
        error("max(max(abs(gradAp-gradA)))=%g,nplot=%d,parallel_threshold=%d",
              max(max(abs(gradAp-gradA))),nplot(k,l),parallel_threshold(k,l));
      endif
    endfor
    
  endfor
endfor

% Show results
nplot
parallel_threshold
Ap_time_to_A_time=Ap_time./A_time
gradAp_time_to_gradA_time=gradAp_time./gradA_time

% Done
diary off
movefile iirA_parallel_test.diary.tmp iirA_parallel_test.diary;
