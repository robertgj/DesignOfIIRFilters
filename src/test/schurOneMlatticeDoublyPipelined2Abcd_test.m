% schurOneMlatticeDoublyPipelined2Abcd_test.m
% Copyright (C) 2023 Robert G. Jenssen
%
% Test cases for the doubly pipelined Schur one-multiplier lattice filter 

test_common;

strf="schurOneMlatticeDoublyPipelined2Abcd_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% k empty
k=epsilon=c=[];
try
  [A,B,C,dd,Cap,ddap]=schurOneMlatticeDoublyPipelined2Abcd(k,epsilon,c);
catch
  printf("%s\n", lasterror().message);
end_try_catch

% Various 
tol=400*eps;
fc=0.05;
for Nk=1:9
  printf("\nTesting Nk=%d\n",Nk);
  [n,d]=butter(Nk,2*fc);
  [k,epsilon,~,c]=tf2schurOneMlattice(n,d);
  try
    [A,B,C,dd,Cap,ddap]=schurOneMlatticeDoublyPipelined2Abcd(k,epsilon,c);
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
  nzN=[kron(ones(1,Nk+1),[0,0,1]),0,0];
  if max(abs(N(find(~nzN)))) > tol
    error("max(abs(N(find(~nzN)))) > tol");
  endif 
  nzD=[kron(ones(1,Nk+1),[1,0,0]),0,0];
  if max(abs(D(find(~nzD)))) > tol
    error("max(abs(D(find(~nzD)))) > tol");
  endif 
  % Trim extra states 
  if max(abs(N(find(nzN))-n)) > tol
    error("max(abs(N(find(nzN))-n)) > tol");
  endif 
  if max(abs(D(find(nzD))-d)) > tol
    error("max(abs(D(find(nzD))-d)) > tol");
  endif
  % All-pass filter transfer function
  [Nap,Dap]=Abcd2tf(A,B,Cap,ddap);
  % Test extra states
  if max(abs(Nap(find(~nzN)))) > tol
    error("max(abs(Nap(find(~nzN)))) > tol");
  endif 
  if max(abs(Dap(find(~nzD)))) > tol
    error("max(abs(Dap(find(~nzD))))) > tol");
  endif 
  % Trim extra states 
  if max(abs(fliplr(Nap(find(nzN)))-Dap(find(nzD)))) > tol
    error("max(abs(fliplr(Nap(find(nzN)))-Dap(find(nzD)))) > tol");
  endif 
  if max(abs(Dap(find(nzD))-d)) > tol
    error("max(abs(Dap(find(nzD))-d)) > tol");
  endif
endfor
  
% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
