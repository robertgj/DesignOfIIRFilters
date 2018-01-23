% sos2pq_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("sos2pq_test.diary");
unlink("sos2pq_test.diary.tmp");
diary sos2pq_test.diary.tmp

format short e

% Specify elliptic low pass filter
fc=0.1;
dBpass=1
dBstop=40
fc=0.125

% Check sos2pq (the errors were found by experiment)
printf("Testing ellip. LP,fc=%f,dBpass=%f,dBstop=%f\n",fc,dBpass,dBstop);
b_err=[0,0.25,0.375,0.2657,0.2969,0.75,1.2188,4.125,7.250,14,14,52];
a_err=[0,0.25,6,6,36,28,256,544,640,896,3712,1792];

for N=1:12

  % Find the SOS for an elliptic filter
  [b,a]=ellip(N,dBpass,dBstop,2*fc);
  [sos,g]=tf2sos(b,a);
  
  % Find d-p-q second order section and transfer function coefficients
  printf("Testing N=%d\n", N);
  [dd,p1,p2,q1,q2]=sos2pq(sos,g);

  % Convert d-p-q sections to transfer function polynomials
  bpq=(kron(dd,ones(1,3)).*[ones(size(p1)),p1,p2])+[zeros(size(p1)),q1,q2];
  apq=[ones(size(p1)), p1, p2];
  Bpq=1;
  Apq=1;
  for k=1:floor(N/2)
    Bpq=conv(bpq(k,1:3),Bpq);
    Apq=conv(apq(k,1:3),Apq);
  endfor
  if rem(N,2)==1
    Bpq=conv(bpq(end,1:2),Bpq);
    Apq=conv(apq(end,1:2),Apq);
  endif

  % Check
  if length(Bpq) ~= (N+1)
    error("Expect length(Bpq) == (N+1)");
  endif
  if length(Apq) ~= (N+1)
    error("Expect length(Apq) == (N+1)");
  endif
  if 0
    printf("max(abs(b-Bpq))/eps=%f\n",max(abs(b-Bpq))/eps);
    printf("max(abs(a-Apq))/eps=%f\n",max(abs(a-Apq))/eps);
  endif
  if max(abs(b-Bpq)) > b_err(N)*eps
    error("max(abs(b-Bpq))=%f*eps > %f*eps",max(abs(b-Bpq))/eps,b_err(N));
  endif
  if max(abs(a-Apq)) > a_err(N)*eps
    error("max(abs(a-Apq))=%f*eps > %f*eps",max(abs(a-Apq))/eps,a_err(N));
  endif

endfor

% Done
diary off
movefile sos2pq_test.diary.tmp sos2pq_test.diary;
