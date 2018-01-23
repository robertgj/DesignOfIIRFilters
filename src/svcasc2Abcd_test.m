% svcasc2Abcd_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("svcasc2Abcd_test.diary");
unlink("svcasc2Abcd_test.diary.tmp");
diary svcasc2Abcd_test.diary.tmp

format short e

% Check A,B,C,D
fc=0.1;
for N=1:12
  for t=1:2
    
    % Find the state variable equations of an nth order Butterworth
    % filter implemented as a cascade of second order sections
    if t==1
      [n,d]=butter(N,fc*2);
      [dd,p1,p2,q1,q2]=butter2pq(N,fc);
    else
      [n,d]=butter(N,fc*2,"high");
      [dd,p1,p2,q1,q2]=butter2pq(N,fc,"high");
    endif
    [a11,a12,a21,a22,b1,b2,c1,c2]=pq2svcasc(p1,p2,q1,q2,"dir");

    % Find the overall state variable equations of the cascade
    [A,B,C,D]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1,c2,dd);

    % Find the polynomial transfer function of the filter
    [np,dp]=Abcd2tf(A,B,C,D);

    % Check
    if 0
      printf("max(abs(np-n))/eps=%f\n",max(abs(np-n))/eps);
      printf("max(abs(dp-d))/eps=%f\n",max(abs(dp-d))/eps);
    else
      if max(abs(np-n)) > 192*eps
        error("max(abs(np-n))=%f*eps > 192*eps",max(abs(np-n))/eps);
      endif
      if max(abs(dp-d)) > 256*eps
        error("max(abs(dp-d))=%f*eps > 256*eps",max(abs(dp-d))/eps);
      endif
    endif

  endfor
endfor

% Check gradients A,B,C,D wrt a11,a12 etc for even order filters
for N=2:2:10;
  sections=ceil(N/2);
  coef_per_section=9;
  delta=4;
  fc=0.1;
  [n,d]=butter(N,fc*2);
  [dd,p1,p2,q1,q2]=butter2pq(N,fc);
  if 1
    [a11,a12,a21,a22,b1,b2,c1,c2]=pq2blockKWopt(dd,p1,p2,q1,q2,delta);
  else
    [a11,a12,a21,a22,b1,b2,c1,c2]=pq2svcasc(p1,p2,q1,q2,"dir");
  endif
  [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1,c2,dd);
  del=1e-6;
  delc=zeros(size(a11));
  delc(1)=del/2;
  tol=del/1e3;
  for n=1:sections
    m=(n-1)*coef_per_section;
    % a11
    [AP,BP,CP,DP,dummy]=svcasc2Abcd(a11+delc,a12,a21,a22,b1,b2,c1,c2,dd);
    [AM,BM,CM,DM,dummy]=svcasc2Abcd(a11-delc,a12,a21,a22,b1,b2,c1,c2,dd);
    diff_Aa11=(AP-AM)/del;
    if max(max(abs(diff_Aa11-dAdx{1+m}))) > tol
      warning("max(max(abs(diff_Aa11-dAdx{1+%d}))) > tol",m);
    endif
    diff_Ba11=(BP-BM)/del;
    if max(max(abs(diff_Ba11-dBdx{1+m}))) > tol
      warning("max(max(abs(diff_Ba11-dBdx{1+%d}))) > tol",m);
    endif
    diff_Ca11=(CP-CM)/del;
    if max(max(abs(diff_Ca11-dCdx{1+m}))) > tol
      warning("max(max(abs(diff_Ca11-dCdx{1+%d}))) > tol",m);
    endif
    diff_Da11=(DP-DM)/del;
    if max(max(abs(diff_Da11-dDdx{1+m}))) > tol
      warning("max(max(abs(diff_Da11-dDdx{1+%d}))) > tol",m);
    endif
    % a12
    [AP,BP,CP,DP,dummy]=svcasc2Abcd(a11,a12+delc,a21,a22,b1,b2,c1,c2,dd);
    [AM,BM,CM,DM,dummy]=svcasc2Abcd(a11,a12-delc,a21,a22,b1,b2,c1,c2,dd);
    diff_Aa12=(AP-AM)/del;
    if max(max(abs(diff_Aa12-dAdx{2+m}))) > tol
      warning("max(max(abs(diff_Aa12-dAdx{2+%d}))) > tol",m);
    endif
    diff_Ba12=(BP-BM)/del;
    if max(max(abs(diff_Ba12-dBdx{2+m}))) > tol
      warning("max(max(abs(diff_Ba12-dBdx{2+%d}))) > tol",m);
    endif
    diff_Ca12=(CP-CM)/del;
    if max(max(abs(diff_Ca12-dCdx{2+m}))) > tol
      warning("max(max(abs(diff_Ca12-dCdx{2+%d}))) > tol",m);
    endif
    diff_Da12=(DP-DM)/del;
    if max(max(abs(diff_Da12-dDdx{2+m}))) > tol
      warning("max(max(abs(diff_Da12-dDdx{2+%d}))) > tol",m);
    endif
    % a21
    [AP,BP,CP,DP,dummy]=svcasc2Abcd(a11,a12,a21+delc,a22,b1,b2,c1,c2,dd);
    [AM,BM,CM,DM,dummy]=svcasc2Abcd(a11,a12,a21-delc,a22,b1,b2,c1,c2,dd);
    diff_Aa21=(AP-AM)/del;
    if max(max(abs(diff_Aa21-dAdx{3+m}))) > tol
      warning("max(max(abs(diff_Aa21-dAdx{3+%d}))) > tol",m);
    endif
    diff_Ba21=(BP-BM)/del;
    if max(max(abs(diff_Ba21-dBdx{3+m}))) > tol
      warning("max(max(abs(diff_Ba21-dBdx{3+%d}))) > tol",m);
    endif
    diff_Ca21=(CP-CM)/del;
    if max(max(abs(diff_Ca21-dCdx{3+m}))) > tol
      warning("max(max(abs(diff_Ca21-dCdx{3+%d}))) > tol",m);
    endif
    diff_Da21=(DP-DM)/del;
    if max(max(abs(diff_Da21-dDdx{3+m}))) > tol
      warning("max(max(abs(diff_Da21-dDdx{3+%d}))) > tol",m);
    endif
    % a22
    [AP,BP,CP,DP,dummy]=svcasc2Abcd(a11,a12,a21,a22+delc,b1,b2,c1,c2,dd);
    [AM,BM,CM,DM,dummy]=svcasc2Abcd(a11,a12,a21,a22-delc,b1,b2,c1,c2,dd);
    diff_Aa22=(AP-AM)/del;
    if max(max(abs(diff_Aa22-dAdx{4+m}))) > tol
      warning("max(max(abs(diff_Aa22-dAdx{4+%d}))) > tol",m);
    endif
    diff_Ba22=(BP-BM)/del;
    if max(max(abs(diff_Ba22-dBdx{4+m}))) > tol
      warning("max(max(abs(diff_Ba22-dBdx{4+%d}))) > tol",m);
    endif
    diff_Ca22=(CP-CM)/del;
    if max(max(abs(diff_Ca22-dCdx{4+m}))) > tol
      warning("max(max(abs(diff_Ca22-dCdx{4+%d}))) > tol",m);
    endif
    diff_Da22=(DP-DM)/del;
    if max(max(abs(diff_Da22-dDdx{4+m}))) > tol
      warning("max(max(abs(diff_Da22-dDdx{4+%d}))) > tol",m);
    endif
    % b1
    [AP,BP,CP,DP,dummy]=svcasc2Abcd(a11,a12,a21,a22,b1+delc,b2,c1,c2,dd);
    [AM,BM,CM,DM,dummy]=svcasc2Abcd(a11,a12,a21,a22,b1-delc,b2,c1,c2,dd);
    diff_Ab1=(AP-AM)/del;
    if max(max(abs(diff_Ab1-dAdx{5+m}))) > tol
      warning("max(max(abs(diff_Ab1-dAdx{5+%d}))) > tol",m);
    endif
    diff_Bb1=(BP-BM)/del;
    if max(max(abs(diff_Bb1-dBdx{5+m}))) > tol
      warning("max(max(abs(diff_Bb1-dBdx{5+%d}))) > tol",m);
    endif
    diff_Cb1=(CP-CM)/del;
    if max(max(abs(diff_Cb1-dCdx{5+m}))) > tol
      warning("max(max(abs(diff_Cb1-dCdx{5+%d}))) > tol",m);
    endif
    diff_Db1=(DP-DM)/del;
    if max(max(abs(diff_Db1-dDdx{5+m}))) > tol
      warning("max(max(abs(diff_Db1-dDdx{5+%d}))) > tol",m);
    endif
    % b2
    [AP,BP,CP,DP,dummy]=svcasc2Abcd(a11,a12,a21,a22,b1,b2+delc,c1,c2,dd);
    [AM,BM,CM,DM,dummy]=svcasc2Abcd(a11,a12,a21,a22,b1,b2-delc,c1,c2,dd);
    diff_Ab2=(AP-AM)/del;
    if max(max(abs(diff_Ab2-dAdx{6+m}))) > tol
      warning("max(max(abs(diff_Ab2-dAdx{6+%d}))) > tol",m);
    endif
    diff_Bb2=(BP-BM)/del;
    if max(max(abs(diff_Bb2-dBdx{6+m}))) > tol
      warning("max(max(abs(diff_Bb2-dBdx{6+%d}))) > tol",m);
    endif
    diff_Cb2=(CP-CM)/del;
    if max(max(abs(diff_Cb2-dCdx{6+m}))) > tol
      warning("max(max(abs(diff_Cb2-dCdx{6+%d}))) > tol",m);
    endif
    diff_Db2=(DP-DM)/del;
    if max(max(abs(diff_Db2-dDdx{6+m}))) > tol
      warning("max(max(abs(diff_Db2-dDdx{6+%d}))) > tol",m);
    endif
    % c1
    [AP,BP,CP,DP,dummy]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1+delc,c2,dd);
    [AM,BM,CM,DM,dummy]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1-delc,c2,dd);
    diff_Ac1=(AP-AM)/del;
    if max(max(abs(diff_Ac1-dAdx{7+m}))) > tol
      warning("max(max(abs(diff_Ac1-dAdx{7+%d}))) > tol",m);
    endif
    diff_Bc1=(BP-BM)/del;
    if max(max(abs(diff_Bc1-dBdx{7+m}))) > tol
      warning("max(max(abs(diff_Bc1-dBdx{7+%d}))) > tol",m);
    endif
    diff_Cc1=(CP-CM)/del;
    if max(max(abs(diff_Cc1-dCdx{7+m}))) > tol
      warning("max(max(abs(diff_Cc1-dCdx{7+%d}))) > tol",m);
    endif
    diff_Dc1=(DP-DM)/del;
    if max(max(abs(diff_Dc1-dDdx{7+m}))) > tol
      warning("max(max(abs(diff_Dc1-dDdx{7+%d}))) > tol",m);
    endif
    % c2
    [AP,BP,CP,DP,dummy]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1,c2+delc,dd);
    [AM,BM,CM,DM,dummy]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1,c2-delc,dd);
    diff_Ac2=(AP-AM)/del;
    if max(max(abs(diff_Ac2-dAdx{8+m}))) > tol
      warning("max(max(abs(diff_Ac2-dAdx{8+%d}))) > tol",m);
    endif
    diff_Bc2=(BP-BM)/del;
    if max(max(abs(diff_Bc2-dBdx{8+m}))) > tol
      warning("max(max(abs(diff_Bc2-dBdx{8+%d}))) > tol",m);
    endif
    diff_Cc2=(CP-CM)/del;
    if max(max(abs(diff_Cc2-dCdx{8+m}))) > tol
      warning("max(max(abs(diff_Cc2-dCdx{8+%d}))) > tol",m);
    endif
    diff_Dc2=(DP-DM)/del;
    if max(max(abs(diff_Dc2-dDdx{8+m}))) > tol
      warning("max(max(abs(diff_Dc2-dDdx{8+%d}))) > tol",m);
    endif
    % dd
    [AP,BP,CP,DP,dummy]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1,c2,dd+delc);
    [AM,BM,CM,DM,dummy]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1,c2,dd-delc);
    diff_Add=(AP-AM)/del;
    if max(max(abs(diff_Add-dAdx{9+m}))) > tol
      warning("max(max(abs(diff_Add-dAdx{9+%d}))) > tol",m);
    endif
    diff_Bdd=(BP-BM)/del;
    if max(max(abs(diff_Bdd-dBdx{9+m}))) > tol
      warning("max(max(abs(diff_Bdd-dBdx{9+%d}))) > tol",m);
    endif
    diff_Cdd=(CP-CM)/del;
    if max(max(abs(diff_Cdd-dCdx{9+m}))) > tol
      warning("max(max(abs(diff_Cdd-dCdx{9+%d}))) > tol",m);
    endif
    diff_Ddd=(DP-DM)/del;
    if max(max(abs(diff_Ddd-dDdx{9+m}))) > tol
      warning("max(max(abs(diff_Ddd-dDdx{9+%d}))) > tol",m);
    endif
    % Shift
    delc=shift(delc,1);
  endfor
endfor

% Done
diary off
movefile svcasc2Abcd_test.diary.tmp svcasc2Abcd_test.diary;
