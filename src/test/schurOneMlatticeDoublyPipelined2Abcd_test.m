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
fc=0.05;
for Nk=1:13
  tol=(Nk^3)*eps;
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
  % Enumerate the extra states
  nzD=1:3:((3*Nk)+2);
  zD=setdiff(1:((5*Nk)+3),nzD,"sorted");
  nzN=nzD+2;
  zN=setdiff(1:((5*Nk)+3),nzN,"sorted");
  % Filter transfer function
  [N,D]=Abcd2tf(A,B,C,dd);
  % Test extra states
  if max(abs(N(zN))) > tol
    error("max(abs(N(zN))) > tol");
  endif 
  if max(abs(D(zD))) > tol
    error("max(abs(D(zD))) > tol");
  endif 
  % Test transfer function
  if max(abs(N(nzN)-n)) > tol
    error("max(abs(N(nzN)-n)) > tol");
  endif
  if max(abs(D(nzD)-d)) > tol
    error("max(abs(D(nzD)-d)) > tol");
  endif
  % All-pass filter transfer function (remove states only used in butter output)
  v=setdiff(1:((5*Nk)+2),[5*(1:Nk),5*(1:Nk)-2],"sorted");
  Aap=A(v,v);
  Bap=B(v);
  Cap=Cap(v);
  [Nap,Dap]=Abcd2tf(Aap,Bap,Cap,ddap);
  if max(abs(fliplr(Nap)-Dap)) > tol
    error("max(abs(fliplr(Nap)-Dap)) > tol");
  endif 
  if max(abs(Dap(nzD)-d)) > tol
    error("max(abs(Dap(nzD)-d)) > tol");
  endif 
endfor
  
% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
