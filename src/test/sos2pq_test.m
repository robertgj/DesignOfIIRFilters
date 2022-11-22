% sos2pq_test.m
% Copyright (C) 2017-2022 Robert G. Jenssen

test_common;

delete("sos2pq_test.diary");
delete("sos2pq_test.diary.tmp");
diary sos2pq_test.diary.tmp


% Acceptable errors (*eps)
a_err=500;b_err=2;
    
for ftype={"iir","fir","mixed","mixed2"}
  for N=1:12
    % Specify low pass filter
    fp=0.125;
    [b,a]=butter(N,2*fp);
    if strcmp("iir",ftype)
      % Find the SOS for an IIR filter
      printf("Testing IIR, N=%d\n",N);
    elseif strcmp("fir",ftype)
      % Find the SOS for an FIR filter
      printf("Testing FIR, N=%d\n",N);
      a=[1,zeros(1,N)];
    elseif strcmp("mixed",ftype)
      % Find the SOS for an IIR/FIR filter
      printf("Testing mixed IIR/FIR, N=%d\n",N);
      b=[b(2:end),0];
    elseif strcmp("mixed2",ftype)
      % Find the SOS for an FIR/IIR filter (tf2sos() fails here!)
      printf("Testing mixed2 FIR/IIR, N=%d\n",N);
      a=[a(2:end),0];
      % Normalise to a(1)
      b=b/a(1);
      a=a/a(1);      
    else
      error("Unknown ftype %s",ftype{1});
    endif
    
    % Find d-p-q second order section and transfer function coefficients
    [sos,g]=tf2sos(b,a);
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

    if max(abs(b-Bpq)) > b_err*eps
      error("max(abs(b-Bpq))=%f*eps > %f*eps",max(abs(b-Bpq))/eps,b_err);
    endif
    if max(abs(a-Apq)) > a_err*eps
      error("max(abs(a-Apq))=%f*eps > %f*eps",max(abs(a-Apq))/eps,a_err);
    endif

  endfor
endfor

% Done
diary off
movefile sos2pq_test.diary.tmp sos2pq_test.diary;
