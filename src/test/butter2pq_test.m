% butter2pq_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("butter2pq_test.diary");
delete("butter2pq_test.diary.tmp");
diary butter2pq_test.diary.tmp


fc=0.1;
for N=1:12
  for t=1:2,

    % Find d-p-q second order section and transfer function coefficients
    if t == 1
      printf("Testing butter2pq low-pass, N=%d,fc=%f\n", N, fc);
      [dd,p1,p2,q1,q2]=butter2pq(N,fc);
      [b,a]=butter(N,fc*2);
    else
      printf("Testing butter2pq high-pass, N=%d,fc=%f\n", N, fc);
      [dd,p1,p2,q1,q2]=butter2pq(N,fc,"high");
      [b,a]=butter(N,fc*2,"high");
    endif

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
    else
      if max(abs(b-Bpq)) > 200*eps
        error("max(abs(b-Bpq))=%f*eps > 200*eps",max(abs(b-Bpq))/eps);
      endif
      if max(abs(a-Apq)) > 200*eps
        error("max(abs(a-Apq))=%f*eps > 200*eps",max(abs(a-Apq))/eps);
      endif
    endif

  endfor % lowpass/highpass
endfor % N

% Done
diary off
movefile butter2pq_test.diary.tmp butter2pq_test.diary;
