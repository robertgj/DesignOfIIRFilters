% tf2schurOneMlatticePipelined_test.m
% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="tf2schurOneMlatticePipelined_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));


% Low-pass fpass=0.2
norder=7;
fpass=0.2;
dBpass=0.5;
dBstop=60;
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2);
[k,epsilon,c,kk,ck]=tf2schurOneMlatticePipelined(n0,d0);
[A,B,C,D,Cap,Dap]=schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1(1:length(n0))-n0) > 2*eps
  error("norm(n1(l:length(n0))-n0) > 2*eps");
endif
if norm(d1(1:length(d0))-d0) > 7*eps
  error("norm(d1(1:length(d0))-d0) > 7*eps");
endif
if max(abs(n1((length(n0)+1):end))) > eps
  error("max(abs(n1(length(n0)+1):end)) > eps");
endif
if max(abs(d1((length(d0)+1):end))) > eps
  error("max(abs(d1(length(d0)+1):end))) > eps");
endif
[nap1,dap1]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(nap1(1:length(d0)))-dap1(1:length(d0))) > 10*eps
  error("norm(fliplr(nap1(1:length(d0)))-dap1(1:length(d0))) > 10*eps");
endif
if norm(dap1(1:length(d0))-d0) > 7*eps
  error("norm(dap1(1:length(d0))-d0) > 7*eps");
endif
if max(abs(dap1((length(d0)+1):end))) > eps
  error("max(abs(dap1(length(d0)+1):end))) > eps");
endif
if max(abs(nap1((length(n0)+1):end))) > eps
  error("max(abs(nap1(length(n0)+1):end))) > eps");
endif

% High-pass fpass=0.2
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2,"high");
[k,epsilon,c,kk,ck]=tf2schurOneMlatticePipelined(n0,d0);
[A,B,C,D,Cap,Dap]=schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1(1:length(n0))-n0) > 2*eps
  error("norm(n1(l:length(n0))-n0) > 2*eps");
endif
if norm(d1(1:length(d0))-d0) > 2*eps
  error("norm(d1(1:length(d0))-d0) > 2*eps");
endif
if max(abs(n1((length(n0)+1):end))) > eps
  error("max(abs(n1(length(n0)+1):end)) > eps");
endif
if max(abs(d1((length(d0)+1):end))) > eps
  error("max(abs(d1(length(d0)+1):end))) > eps");
endif
[nap1,dap1]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(nap1(1:length(d0)))-dap1(1:length(d0))) > 10*eps
  error("norm(fliplr(nap1(1:length(d0)))-dap1(1:length(d0))) > 10*eps");
endif
if norm(dap1(1:length(d0))-d0) > 7*eps
  error("norm(dap1(1:length(d0))-d0) > 7*eps");
endif
if max(abs(dap1((length(d0)+1):end))) > eps
  error("max(abs(dap1(length(d0)+1):end))) > eps");
endif
if max(abs(nap1((length(n0)+1):end))) > eps
  error("max(abs(nap1(length(n0)+1):end))) > eps");
endif

% All-pass filter fpass=0.2
[k,epsilon,c,kk,ck]=tf2schurOneMlatticePipelined(d0(length(d0):-1:1),d0);
[A,B,C,D,Cap,Dap]=schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(fliplr(n1(1:length(d0)))-d1(1:length(d0))) > 10*eps
  error("norm(fliplr(n1(1:length(d0)))-d1(1:length(d0))) > 10*eps");
endif
if norm(d1(1:length(d0))-d0) > 7*eps
  error("norm(d1(1:length(d0))-d0) > 7*eps");
endif
if max(abs(d1((length(d0)+1):end))) > eps
  error("max(abs(d1(length(d0)+1):end))) > eps");
endif
if max(abs(n1((length(n0)+1):end))) > eps
  error("max(abs(n1(length(n0)+1):end))) > eps");
endif

% All-pass filter with pi phase shift fpass=0.2
[k,epsilon,c,kk,ck]=tf2schurOneMlatticePipelined(d0(length(d0):-1:1),-d0);
[A,B,C,D]=schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(fliplr(n1(1:length(d0)))+d1(1:length(d0))) > 10*eps
  error("norm(fliplr(n1(1:length(d0)))+d1(1:length(d0))) > 10*eps");
endif
if norm(d1(1:length(d0))-d0) > 7*eps
  error("norm(d1(1:length(d0))-d0) > 7*eps");
endif
if max(abs(d1((length(d0)+1):end))) > eps
  error("max(abs(d1(length(d0)+1):end))) > eps");
endif
if max(abs(n1((length(n0)+1):end))) > eps
  error("max(abs(n1(length(n0)+1):end))) > eps");
endif

% Low-pass fpass=0.1
fpass=0.1;
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2);
[k,epsilon,c,kk,ck]=tf2schurOneMlatticePipelined(n0,d0);
[A,B,C,D,Cap,Dap]=schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1(1:length(n0))-n0) > 2*eps
  error("norm(n1(l:length(n0))-n0) > 2*eps");
endif
if norm(d1(1:length(d0))-d0) > 10*eps
  error("norm(d1(1:length(d0))-d0) > 10*eps");
endif
if max(abs(n1((length(n0)+1):end))) > eps
  error("max(abs(n1(length(n0)+1):end)) > eps");
endif
if max(abs(d1((length(d0)+1):end))) > eps
  error("max(abs(d1(length(d0)+1):end))) > eps");
endif
[nap1,dap1]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(nap1(1:length(d0)))-dap1(1:length(d0))) > 20*eps
  error("norm(fliplr(nap1(1:length(d0)))-dap1(1:length(d0))) > 20*eps");
endif
if norm(dap1(1:length(d0))-d0) > 10*eps
  error("norm(dap1(1:length(d0))-d0) > 10*eps");
endif
if max(abs(dap1((length(d0)+1):end))) > eps
  error("max(abs(dap1(length(d0)+1):end))) > eps");
endif
if max(abs(nap1((length(n0)+1):end))) > eps
  error("max(abs(nap1(length(n0)+1):end))) > eps");
endif

% High-pass fpass=0.1
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2,"high");
[k,epsilon,c,kk,ck]=tf2schurOneMlatticePipelined(n0,d0);
[A,B,C,D,Cap,Dap]=schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(n1(1:length(n0))-n0) > 10*eps
  error("norm(n1(1:length(n0))-n0) > 10*eps");
endif
if norm(d1(1:length(d0))-d0) > 2*eps
  error("norm(d1(1:length(d0))-d0) > 2*eps");
endif
if max(abs(n1((length(n0)+1):end))) > eps
  error("max(abs(n1(length(n0)+1):end)) > eps");
endif
if max(abs(d1((length(d0)+1):end))) > eps
  error("max(abs(d1(length(d0)+1):end))) > eps");
endif
[nap1,dap1]=Abcd2tf(A,B,Cap,Dap);
if norm(fliplr(nap1(1:length(d0)))-dap1(1:length(d0))) > 10*eps
  error("norm(fliplr(nap1(1:length(d0)))-dap1(1:length(d0))) > 10*eps");
endif
if norm(dap1(1:length(d0))-d0) > 7*eps
  error("norm(dap1(1:length(d0))-d0) > 7*eps");
endif
if max(abs(dap1((length(d0)+1):end))) > eps
  error("max(abs(dap1(length(d0)+1):end))) > eps");
endif
if max(abs(nap1((length(n0)+1):end))) > eps
  error("max(abs(nap1(length(n0)+1):end))) > eps");
endif

% All-pass filter fpass=0.1
[k,epsilon,c,kk,ck]=tf2schurOneMlatticePipelined(d0(length(d0):-1:1),d0);
[A,B,C,D,Cap,Dap]=schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(fliplr(n1(1:length(d0)))-d1(1:length(d0))) > 10*eps
  error("norm(fliplr(n1(1:length(d0)))-d1(1:length(d0))) > 10*eps");
endif
if norm(d1(1:length(d0))-d0) > 7*eps
  error("norm(d1(1:length(d0))-d0) > 7*eps");
endif
if max(abs(d1((length(d0)+1):end))) > eps
  error("max(abs(d1(length(d0)+1):end))) > eps");
endif
if max(abs(n1((length(n0)+1):end))) > eps
  error("max(abs(n1(length(n0)+1):end))) > eps");
endif

% All-pass filter with pi phase shift fpass=0.1
[k,epsilon,c,kk,ck]=tf2schurOneMlatticePipelined(d0(length(d0):-1:1),-d0);
[A,B,C,D]=schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);
[n1,d1]=Abcd2tf(A,B,C,D);
if norm(fliplr(n1(1:length(d0)))+d1(1:length(d0))) > 10*eps
  error("norm(fliplr(n1(1:length(d0)))+d1(1:length(d0))) > 10*eps");
endif
if norm(d1(1:length(d0))-d0) > 7*eps
  error("norm(d1(1:length(d0))-d0) > 7*eps");
endif
if max(abs(d1((length(d0)+1):end))) > eps
  error("max(abs(d1(length(d0)+1):end))) > eps");
endif
if max(abs(n1((length(n0)+1):end))) > eps
  error("max(abs(n1(length(n0)+1):end))) > eps");
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
