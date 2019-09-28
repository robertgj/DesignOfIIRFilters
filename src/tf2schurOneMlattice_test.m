% tf2schurOneMlattice_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("tf2schurOneMlattice_test.diary");
unlink("tf2schurOneMlattice_test.diary.tmp");
diary tf2schurOneMlattice_test.diary.tmp


% Low-pass fpass=0.2
norder=7;
fpass=0.2;
dBpass=0.5;
dBstop=60;
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2);
[k,epsilon,p,c]=tf2schurOneMlattice(n0,d0);
[A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1-n0)/eps > 2.005
  error("norm(n1-n0)/eps > 2.005");
endif
if norm(d1-d0)/eps > 7
  error("norm(d1-d0)/eps > 7");
endif
[nap1,dap1]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(nap1)-dap1)/eps > 10
  error("norm(fliplr(nap1)-dap1)/eps > 10");
endif
if norm(dap1-d0)/eps > 7
  error("norm(dap1-n0)/eps > 7");
endif

% High-pass fpass=0.2
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2,"high");
[k,epsilon,p,c]=tf2schurOneMlattice(n0,d0);
[A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1-n0)/eps > 3
  error("norm(n1-n0)/eps > 3");
endif
if norm(d1-d0)/eps > 1.9255
  error("norm(d1-d0)/eps > 1.9255");
endif
[nap1,dap1]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(nap1)-dap1)/eps > 2.2063
  error("norm(fliplr(nap1)-dap1)/eps > 2.2063");
endif
if norm(dap1-d0)/eps > 1.9255
  error("norm(dap1-d0)/eps > 1.9255");
endif

% All-pass filter fpass=0.2
[k,epsilon,p,c]=tf2schurOneMlattice(d0(length(d0):-1:1),d0);
[A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(fliplr(n1)-d0)/eps > 4.13
  error("norm(fliplr(n1)-d0)/eps > 4.13");
endif
if norm(d1-d0)/eps > 4.13
  error("norm(d1-d0)/eps > 4.13");
endif
[n2,d2]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(n2)-d2)/eps > 2.2063
  error("norm(fliplr(n2)-d2)/eps > 2.2063");
endif
if norm(fliplr(n2)-d0)/eps > 3.2
  error("norm(fliplr(n2)-d0)/eps > 3.2");
endif

% All-pass filter with pi phase shift fpass=0.2
[k,epsilon,p,c]=tf2schurOneMlattice(d0(length(d0):-1:1),-d0);
[A,B,C,D]=schurOneMlattice2Abcd(k,epsilon,p,c);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(fliplr(n1)+d0)/eps > 4.13
  error("norm(fliplr(n1)+d0)/eps > 4.13");
endif
if norm(d1-d0)/eps > 1.9255
  error("norm(d1-d0)/eps > 1.9255");
endif

% Low-pass fpass=0.1
fpass=0.1;
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2);
[k,epsilon,p,c]=tf2schurOneMlattice(n0,d0);
[A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1-n0)/eps > 0.4
  error("norm(n1-n0)/eps > 0.4");
endif
if norm(d1-d0)/eps > 50
  error("norm(d1-d0)/eps > 50");
endif
[nap1,dap1]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(nap1)-dap1)/eps > 50
  error("norm(fliplr(nap1)-dap1)/eps > 50");
endif
if norm(dap1-d0)/eps > 50
  error("norm(dap1-d0)/eps > 50");
endif

% High-pass fpass=0.1
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2,"high");
[k,epsilon,p,c]=tf2schurOneMlattice(n0,d0);
[A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1-n0)/eps > 50
  error("norm(n1-n0)/eps > 50");
endif
if norm(d1-d0)/eps > 50
  error("norm(d1-d0)/eps > 50");
endif
[nap1,dap1]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(nap1)-dap1)/eps > 50
  error("norm(fliplr(nap1)-dap1)/eps > 50");
endif
if norm(dap1-d0)/eps > 50
  error("norm(dap1-d0)/eps > 50");
endif

% All-pass filter fpass=0.1
[k,epsilon,p,c]=tf2schurOneMlattice(d0(length(d0):-1:1),d0);
[A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(fliplr(n1)-d0)/eps > 50
  error("norm(fliplr(n1)-d0)/eps > 50");
endif
if norm(fliplr(n1)-d1)/eps > 50
  error("norm(fliplr(n1)-d1)/eps > 50");
endif
[n2,d2]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(n2)-d2)/eps > 50
  error("norm(fliplr(n2)-d2)/eps > 50");
endif
if norm(fliplr(n2)-d0)/eps > 50
  error("norm(fliplr(n2)-d0)/eps > 50");
endif

% All-pass filter with pi phase shift fpass=0.1
[k,epsilon,p,c]=tf2schurOneMlattice(d0(length(d0):-1:1),-d0);
[A,B,C,D]=schurOneMlattice2Abcd(k,epsilon,p,c);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(fliplr(n1)+d0)/eps > 50
  error("norm(fliplr(n1)+d0)/eps > 50");
endif
if norm(d1-d0)/eps > 50
  error("norm(d1-d0)/eps > 50");
endif

% Done
diary off
movefile tf2schurOneMlattice_test.diary.tmp tf2schurOneMlattice_test.diary;
