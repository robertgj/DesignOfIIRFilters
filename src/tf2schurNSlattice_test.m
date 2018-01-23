% tf2schurNSlattice_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("tf2schurNSlattice_test.diary");
unlink("tf2schurNSlattice_test.diary.tmp");
diary tf2schurNSlattice_test.diary.tmp

format short e

% No filter
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(1,1);
if (s10!=1) || (s11!=0) || (s20!=1) || (s00!=0) || (s02!=-1) || (s22!=0)
  error("Unexpected result for n=1,d=1!");
endif

% Short filter
norder=1;
fpass=0.2;
[n0,d0]=butter(norder,fpass*2);
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n0,d0);
[A,B,C,D,Cap,Dap]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1-n0)/eps > 0.25
  error("norm(n1-n0)>eps/4");
endif
if norm(d1-d0)/eps > 1
  error("norm(d1-d0)>eps");
endif

% Low-pass fpass=0.2
norder=7;
fpass=0.2;
dBpass=0.5;
dBstop=60;
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2);
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n0,d0);
[A,B,C,D,Cap,Dap]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1-n0)/eps > 1.5701
  error("norm(n1-n0)/eps > 1.5701");
endif
if norm(d1-d0)/eps > 6.1289
  error("norm(d1-d0)/eps > 6.1289");
endif
[nap1,dap1]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(nap1)-dap1)/eps > 13.923
  error("norm(fliplr(nap1)-dap1)/eps > 13.923");
endif
if norm(dap1-d0)/eps > 6.1289
  error("norm(dap1-n0)/eps > 6.1289");
endif

% High-pass fpass=0.2
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2,"high");
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n0,d0);
[A,B,C,D,Cap,Dap]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1-n0)/eps > 1.6350
  error("norm(n1-n0)/eps > 1.6350");
endif
if norm(d1-d0)/eps > 1.1445
  error("norm(d1-d0)/eps > 1.1445");
endif
[nap1,dap1]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(nap1)-dap1)/eps > 1.1513
  error("norm(fliplr(nap1)-dap1)/eps > 1.1513");
endif
if norm(dap1-d0)/eps > 1.1445
  error("norm(dap1-n0)/eps > 1.1445");
endif

% All-pass filter fpass=0.2
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(d0(length(d0):-1:1),d0);
[A,B,C,D,Cap,Dap]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(fliplr(n1)-d0)/eps > 1.8803
  error("norm(fliplr(n1)-d0)/eps > 1.8803");
endif
if norm(d1-d0)/eps > 1.1445
  error("norm(d1-d0)/eps > 1.1445");
endif
[n2,d2]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(n2)-d2)/eps > 1.1513
  error("norm(fliplr(n2)-d2)/eps > 1.1513");
endif
if norm(fliplr(n2)-d0)/eps > 1.5014
  error("norm(fliplr(n2)-d0)/eps > 1.5014");
endif

% All-pass filter with pi phase shift fpass=0.2
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(d0(length(d0):-1:1),-d0);
[A,B,C,D]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(fliplr(n1)+d0)/eps > 1.8803
  error("norm(fliplr(n1)+d0)/eps > 1.8803");
endif
if norm(d1-d0)/eps > 1.1445
  error("norm(d1-d0)/eps > 1.1445");
endif

% Low-pass fpass=0.1
fpass=0.1;
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2);
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n0,d0);
[A,B,C,D,Cap,Dap]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1-n0)/eps > 0.23002
  error("norm(n1-n0)/eps > 0.23002");
endif
if norm(d1-d0)/eps > 10.153
  error("norm(d1-d0)/eps > 10.153");
endif
[nap1,dap1]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(nap1)-dap1)/eps > 15.495
  error("norm(fliplr(nap1)-dap1)/eps > 15.495");
endif
if norm(dap1-d0)/eps > 10.153
  error("norm(dap1-n0)/eps > 10.153");
endif

% High-pass fpass=0.1
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2,"high");
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n0,d0);
[A,B,C,D,Cap,Dap]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1-n0)/eps > 12.210
  error("norm(n1-n0)/eps > 12.210");
endif
if norm(d1-d0)/eps > 10.372
  error("norm(d1-d0)/eps > 10.372");
endif
[nap1,dap1]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(nap1)-dap1)/eps > 9.5691
  error("norm(fliplr(nap1)-dap1)/eps > 9.5691");
endif
if norm(dap1-d0)/eps > 10.372
  error("norm(dap1-n0)/eps > 10.372");
endif

% All-pass filter fpass=0.1
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(d0(length(d0):-1:1),d0);
[A,B,C,D,Cap,Dap]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(fliplr(n1)-d0)/eps > 23.089
  error("norm(fliplr(n1)-d0)/eps > 23.089");
endif
if norm(d1-d0)/eps > 10.372
  error("norm(d1-d0)/eps > 10.372");
endif
[n2,d2]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(n2)-d2)/eps > 9.5691
  error("norm(fliplr(n2)-d2)/eps > 9.5691");
endif
if norm(fliplr(n2)-d0)/eps > 16.249
  error("norm(fliplr(n2)-d0)/eps > 16.249");
endif

% All-pass filter with pi phase shift fpass=0.1
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(d0(length(d0):-1:1),-d0);
[A,B,C,D]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(fliplr(n1)+d0)/eps > 23.089
  error("norm(fliplr(n1)+d0)/eps > 23.089");
endif
if norm(d1-d0)/eps > 10.372
  error("norm(d1-d0)/eps > 10.372");
endif

% Done
diary off
movefile tf2schurNSlattice_test.diary.tmp tf2schurNSlattice_test.diary;
