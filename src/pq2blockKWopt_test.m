% pq2blockKWopt_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("pq2blockKWopt_test.diary");
unlink("pq2blockKWopt_test.diary.tmp");
diary pq2blockKWopt_test.diary.tmp

format short e

fc=0.2;
for N=1:20
  for t=1:2
    for delta=1:3:4

      % Find the state variable equations of an nth order Butterworth
      % filter implemented as a cascade of second order sections
      if t==1
        printf("Testing Butterworth low-pass filter: ");
        printf("N=%d, fc=%3.1f, delta=%3.1f\n",N,fc,delta);
        [b,a]=butter(N,fc*2);
        [dd,p1,p2,q1,q2]=butter2pq(N,fc);
      else
        printf("Testing Butterworth high-pass filter: ");
        printf("N=%d, fc=%3.1f, delta=%3.1f\n",N,fc,delta);
        [b,a]=butter(N,fc*2,"high");
        [dd,p1,p2,q1,q2]=butter2pq(N,fc,"high");
      endif

      % Block optimise the cascade
      [a11,a12,a21,a22,b1,b2,c1,c2]=pq2blockKWopt(dd,p1,p2,q1,q2,delta);
      
      % Convert back to transfer function form
      [A,B,C,D]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1,c2,dd);

      % Compare overall cascade noise gain with global optimum
      [K,W]=KW(A,B,C,D);
      printf("ngcasc=%f\n", sum(diag(K).*diag(W)));
      [Topt,Kopt,Wopt]=optKW(K,W,delta);
      printf("ngopt=%f\n", sum(diag(Kopt).*diag(Wopt)));
      
      % Check transfer function
      [bp,ap]=Abcd2tf(A,B,C,D);
      if 0
        printf("max(abs(bp-b))/eps = %f\n", max(abs(bp-b))/eps);
        printf("max(abs(ap-a))/eps = %f\n", max(abs(ap-a))/eps);
      else
        tol=192;
        if max(abs(bp-b)) > tol*eps
          error("max(abs(bp-b)) > %d*eps", max(abs(bp-b))/eps, tol);
        endif
        if max(abs(ap-a)) > tol*eps
          error("max(abs(ap-a))=%f*eps > %d*eps", max(abs(ap-a))/eps, tol);
        endif
      endif
      
    endfor
  endfor
endfor

diary off
movefile pq2blockKWopt_test.diary.tmp pq2blockKWopt_test.diary;
