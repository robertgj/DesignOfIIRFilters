% schurOneMAPlatticePipelined2Abcd_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen
%
% Test cases for the pipelined Schur one-multiplier all-pass lattice filter 

test_common;

strf="schurOneMAPlatticePipelined2Abcd_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% k empty
k=[];
try
  [Aap,Bap,Cap,Dap]=schurOneMAPlatticePipelined2Abcd(k);
catch
  printf("%s\n", lasterr());
end_try_catch

% Various 
fc=0.05;
for Nk=1:11
  printf("\nTesting Nk=%d\n",Nk);
  tol=Nk*4*eps;
  [n,d]=butter(Nk,2*fc);
  [k,epsilon,~,c]=tf2schurOneMlattice(n,d);
  kk=k(1:(Nk-1)).*k(2:Nk);
  kkr=round(kk*1024)/1024;

  % Filter transfer function
  try
    [Aap,Bap,Cap,Dap] = schurOneMAPlatticePipelined2Abcd(k,epsilon);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    error("%s\n", err.message);
  end_try_catch

  [nap,dap]=Abcd2tf(Aap,Bap,Cap,Dap);
  if max(abs(flipud(nap(:))-dap(:))) > tol
    error("max(abs(flipud(nap(:))-dap(:))) > tol");
  endif 
  if max(abs(dap-d)) > tol
    error("max(abs(dap-d)) > tol");
  endif

  % Repeat filter transfer function
  try
    [Aap,Bap,Cap,Dap] = schurOneMAPlatticePipelined2Abcd(k,epsilon,kk);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    error("%s\n", err.message);
  end_try_catch

  [nap,dap]=Abcd2tf(Aap,Bap,Cap,Dap);
  if max(abs(flipud(nap(:))-dap(:))) > tol
    error("max(abs(flipud(nap(:))-dap(:))) > tol");
  endif 
  if max(abs(dap-d)) > tol
    error("max(abs(dap-d)) > tol");
  endif

  % Matrix coefficient cell arrays 
  try
    [Aap,Bap,Cap,Dap,ABCDap0,ABCDapk,ABCDapkk] = ...
       schurOneMAPlatticePipelined2Abcd(k);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    error("%s\n", err.message);
  end_try_catch
  ABCDap=[Aap,Bap;Cap,Dap];
  cABCDap=ABCDap0;
  for s=1:Nk,
    cABCDap=cABCDap+(k(s)*ABCDapk{s});
  endfor
  for s=1:(Nk-1),
    cABCDap=cABCDap+(kk(s)*ABCDapkk{s});
  endfor
  if max(max(ABCDap-cABCDap))>eps
    error("max(max(ABCDap-cABCDap))>eps");
  endif

  % Repeat
  try
    [Aap,Bap,Cap,Dap,ABCDap0,ABCDapk,ABCDapkk] = ...
       schurOneMAPlatticePipelined2Abcd(k,epsilon,kkr);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    error("%s\n", err.message);
  end_try_catch
  ABCDap=[Aap,Bap;Cap,Dap];
  cABCDap=ABCDap0;
  for s=1:Nk,
    cABCDap=cABCDap+(k(s)*ABCDapk{s});
  endfor
  for s=1:(Nk-1),
    cABCDap=cABCDap+(kkr(s)*ABCDapkk{s});
  endfor
  if max(max(ABCDap-cABCDap))>eps
    error("max(max(ABCDap-cABCDap))>eps");
  endif

  % Check derivatives of Aap,etc wrt k
  del=1/(2^20);
  delk=zeros(size(k));
  delk(1)=del/2;
  [Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx] = ...
    schurOneMAPlatticePipelined2Abcd(k,epsilon,kk);
  dAapdk_max_err=zeros(1,Nk);
  dBapdk_max_err=zeros(1,Nk);
  dCapdk_max_err=zeros(1,Nk);
  dDapdk_max_err=zeros(1,Nk);
  for l=1:Nk,
    [AapP,BapP,CapP,DapP] = schurOneMAPlatticePipelined2Abcd(k+delk,epsilon,kk);
    [AapM,BapM,CapM,DapM] = schurOneMAPlatticePipelined2Abcd(k-delk,epsilon,kk);
    delk=circshift(delk,1);
    dAapdk_max_err(l)=max(max(abs(((AapP-AapM)/del)-dAapdx{l})));
    dBapdk_max_err(l)=max(abs(((BapP-BapM)/del)-dBapdx{l}));
    dCapdk_max_err(l)=max(abs(((CapP-CapM)/del)-dCapdx{l}));
    dDapdk_max_err(l)=max(abs(((DapP-DapM)/del)-dDapdx{l}));
  endfor
  if max(dAapdk_max_err) > eps
    error("max(dAapdk_max_err) > eps");
  endif
  if max(dBapdk_max_err) > eps
    error("max(dBapdk_max_err) > eps");
  endif
  if max(dCapdk_max_err) > eps
    error("max(dCapdk_max_err) > eps");
  endif
  if max(dDapdk_max_err) > eps
    error("max(dDapdk_max_err) > eps");
  endif

  % Check derivatives of Aap,etc wrt kk
  del=1/(2^20);
  delkk=zeros(size(kkr));
  delkk(1)=del/2;
  [Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx] = ...
    schurOneMAPlatticePipelined2Abcd(k,epsilon,kkr);
  dAapdkk_max_err=zeros(1,Nk-1);
  dBapdkk_max_err=zeros(1,Nk-1);
  dCapdkk_max_err=zeros(1,Nk-1);
  dDapdkk_max_err=zeros(1,Nk-1);
  for l=1:Nk-1,
    [AapP,BapP,CapP,DapP] = ...
      schurOneMAPlatticePipelined2Abcd(k,epsilon,kkr+delkk);
    [AapM,BapM,CapM,DapM] = ...
      schurOneMAPlatticePipelined2Abcd(k,epsilon,kkr-delkk);
    delkk=circshift(delkk,1);
    dAapdkk_max_err(l)=max(max(abs(((AapP-AapM)/del)-dAapdx{Nk+l})));
    dBapdkk_max_err(l)=max(abs(((BapP-BapM)/del)-dBapdx{Nk+l}));
    dCapdkk_max_err(l)=max(abs(((CapP-CapM)/del)-dCapdx{Nk+l}));
    dDapdkk_max_err(l)=max(abs(((DapP-DapM)/del)-dDapdx{Nk+l}));
  endfor
  if max(dAapdkk_max_err) > eps
    error("max(dAapdkk_max_err) > eps");
  endif                               
  if max(dBapdkk_max_err) > eps       
    error("max(dBapdkk_max_err) > eps");
  endif                               
  if max(dCapdkk_max_err) > eps       
    error("max(dCapdkk_max_err) > eps");
  endif                               
  if max(dDapdkk_max_err) > eps       
    error("max(dDapdkk_max_err) > eps");
  endif
  
endfor
  
% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
