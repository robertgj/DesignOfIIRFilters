% schurOneMlatticePipelined2Abcd_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen
%
% Test cases for the pipelined Schur one-multiplier lattice filter 

test_common;

strf="schurOneMlatticePipelined2Abcd_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% k empty
k=epsilon=c=[];
try
  [A,B,C,dd,Cap,ddap]=schurOneMlatticePipelined2Abcd(k,epsilon,c);
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
    [A,B,C,dd,Cap,ddap] = schurOneMlatticePipelined2Abcd(k,epsilon,c);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    printf("%s\n", err.message);
  end_try_catch

  % Filter transfer function
  [N,D]=Abcd2tf(A,B,C,dd);
  % Test extra states
  if max(abs(N((Nk+2):end))) > tol
    error("max(abs(N((Nk+2):end))) > tol");
  endif 
  if max(abs(D((Nk+2):end))) > tol
    error("max(abs(D((Nk+2):end))) > tol");
  endif 
  % Trim extra states 
  N=N(1:(Nk+1));
  D=D(1:(Nk+1));
  if max(abs(N-n)) > tol
    error("max(abs(N-n)) > tol");
  endif 
  if max(abs(D-d)) > tol
    error("max(abs(D-d)) > tol");
  endif
  % All-pass filter transfer function
  [Nap,Dap]=Abcd2tf(A,B,Cap,ddap);
  % Test extra states
  if max(abs(Nap((Nk+2):end))) > tol
    error("max(abs(Nap((Nk+2):end))) > tol");
  endif 
  if max(abs(Dap((Nk+2):end))) > tol
    error("max(abs(Dap((Nk+2):end))) > tol");
  endif 
  % Trim extra states 
  Nap=Nap(1:(Nk+1));
  Dap=Dap(1:(Nk+1));
  if max(abs(flipud(Nap(:))-Dap(:))) > tol
    error("max(abs(flipud(Nap(:))-Dap(:))) > tol");
  endif 
  if max(abs(Dap-d)) > tol
    error("max(abs(Dap-d)) > tol");
  endif

  % Matrix coefficient cell arrays 
  try
    kk=k(1:(Nk-1)).*k(2:Nk);
    ck=c(2:Nk).*k(2:Nk);
    [A,B,C,dd,Cap,ddap,ABCD0,ABCDk,ABCDc,ABCDkk,ABCDck] = ...
       schurOneMlatticePipelined2Abcd(k,epsilon,c);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    printf("%s\n", err.message);
  end_try_catch
  ABCD=[A,B;C,dd;Cap,ddap];
  cABCD=ABCD0;
  for s=1:Nk,
    cABCD=cABCD+(k(s)*ABCDk{s});
  endfor
  for s=1:(Nk+1),
    cABCD=cABCD+(c(s)*ABCDc{s});
  endfor
  for s=1:(Nk-1),
    cABCD=cABCD+(kk(s)*ABCDkk{s});
  endfor
  for s=1:(Nk-1),
    cABCD=cABCD+(ck(s)*ABCDck{s});
  endfor 
  if max(max(ABCD-cABCD))>eps
    error("max(max(ABCD-cABCD))>eps");
  endif

  % Repeat
  try
    kk=k(1:(Nk-1)).*k(2:Nk);
    ck=c(2:Nk).*k(2:Nk);
    [A,B,C,dd,Cap,ddap,ABCD0,ABCDk,ABCDc,ABCDkk,ABCDck] = ...
       schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    printf("%s\n", err.message);
  end_try_catch
  ABCD=[A,B;C,dd;Cap,ddap];
  cABCD=ABCD0;
  for s=1:Nk,
    cABCD=cABCD+(k(s)*ABCDk{s});
  endfor
  for s=1:(Nk+1),
    cABCD=cABCD+(c(s)*ABCDc{s});
  endfor
  for s=1:(Nk-1),
    cABCD=cABCD+(kk(s)*ABCDkk{s});
  endfor
  for s=1:(Nk-1),
    cABCD=cABCD+(ck(s)*ABCDck{s});
  endfor 
  if max(max(ABCD-cABCD))>eps
    error("max(max(ABCD-cABCD))>eps");
  endif
  
endfor
  
% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
