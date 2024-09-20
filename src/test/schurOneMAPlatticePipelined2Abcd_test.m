% schurOneMAPlatticePipelined2Abcd_test.m
% Copyright (C) 2024 Robert G. Jenssen
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
  printf("%s\n", lasterror().message);
end_try_catch

% Various 
fc=0.05;
for Nk=1:11
  printf("\nTesting Nk=%d\n",Nk);
  tol=Nk*4*eps;
  [n,d]=butter(Nk,2*fc);
  [k,epsilon,~,c]=tf2schurOneMlattice(n,d);
  try
    kk=k(1:(Nk-1)).*k(2:Nk);
    [Aap,Bap,Cap,Dap] = schurOneMAPlatticePipelined2Abcd(k);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    printf("%s\n", err.message);
  end_try_catch

  % Filter transfer function
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
    printf("%s\n", err.message);
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
    kk=k(1:(Nk-1)).*k(2:Nk);
    [Aap,Bap,Cap,Dap,ABCDap0,ABCDapk,ABCDapkk] = ...
       schurOneMAPlatticePipelined2Abcd(k,kk);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    printf("%s\n", err.message);
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
  
endfor
  
% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
