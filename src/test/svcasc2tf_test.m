% svcasc2tf_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("svcasc2tf_test.diary");
delete("svcasc2tf_test.diary.tmp");
diary svcasc2tf_test.diary.tmp


fc=0.1;
for N=1:20
  for t=1:2
    % Find the state variable equations of an nth order Butterworth
    % filter implemented as a cascade of second order sections
    if t==1
      [b,a]=butter(N,fc*2);
      [dd,p1,p2,q1,q2]=butter2pq(N,fc);
    else
      [b,a]=butter(N,fc*2,"high");
      [dd,p1,p2,q1,q2]=butter2pq(N,fc,"high");
    endif
    [a11,a12,a21,a22,b1,b2,c1,c2]=pq2svcasc(p1,p2,q1,q2,"min");

    % Find the polynomial transfer function of the filter
    [B,A]=svcasc2tf(a11,a12,a21,a22,b1,b2,c1,c2,dd);

    % Check
    if 0
      printf("max(abs((b-B)./B))/eps=%f\n",max(abs((b-B)./B))/eps);
      printf("max(abs((a-A)./A))/eps=%f\n",max(abs((a-A)./A))/eps);
    else
      if max(abs((b-B)./B)) > 580*eps
        error("max(abs((b-B)./B))=%f*eps > 580*eps",max(abs((b-B)./B))/eps);
      endif
      if max(abs((a-A)./A)) > 20*eps
        error("max(abs((a-A)./A))=%f*eps > 20*eps",max(abs((a-A)./A))/eps);
      endif
    endif

  endfor
endfor

diary off
movefile svcasc2tf_test.diary.tmp svcasc2tf_test.diary;
