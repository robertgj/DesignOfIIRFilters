% schurOneMlatticeDoublyPipelined2Abcd_test.m
% Copyright (C) 2023-2024 Robert G. Jenssen
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
  [A,B,C,D,Aap,Bap,Cap,Dap]=schurOneMlatticeDoublyPipelined2Abcd(k,epsilon,c);
catch
  printf("%s\n", lasterror().message);
end_try_catch

% Check arguments
k=rand(6,1);
try
  [A,B,C,D,Aap,Bap,Cap,Dap]=schurOneMlatticeDoublyPipelined2Abcd(k);
catch
  printf("%s\n", lasterror().message);
end_try_catch
epsilon=ones(length(k),1);
try
  [A,B,C,D,Aap,Bap,Cap,Dap]=schurOneMlatticeDoublyPipelined2Abcd(k,epsilon);
catch
  printf("%s\n", lasterror().message);
end_try_catch

% Various 
fc=0.05;
for Nk=1:13
  tol=(Nk^3)*eps;
  printf("\nTesting Nk=%d\n",Nk);
  [n,dd]=butter(Nk,2*fc);
  [k,epsilon,~,c]=tf2schurOneMlattice(n,dd);
  try
    [A,B,C,D,Aap,Bap,Cap,DDap]= ...
       schurOneMlatticeDoublyPipelined2Abcd(k,epsilon,c);
  catch
    err=lasterror();
    for e=1:length(err.stack)
      printf("Called %s at line %d\n", ...
             err.stack(e).name,err.stack(e).line);
    endfor
    printf("%s\n", err.message);
  end_try_catch
  % Enumerate the extra states
  nzD=1:2:(3*Nk);
  zD=setdiff(1:((3*Nk)+3),nzD,"sorted");
  nzD=nzD(1:(Nk+1));
  nzN=nzD+2;
  zN=setdiff(1:((3*Nk)+3),nzN,"sorted");
  nzN=nzN(1:(Nk+1));
  % Filter transfer function
  [N,DD]=Abcd2tf(A,B,C,D);
  % Test extra states
  if max(abs(N(zN))) > tol
    error("max(abs(N(zN))) > tol");
  endif 
  if max(abs(DD(zD))) > tol
    error("max(abs(DD(zD))) > tol");
  endif 
  % Test transfer function
  if max(abs(N(nzN)-n)) > tol
    error("max(abs(N(nzN)-n)) > tol");
  endif
  if max(abs(DD(nzD)-dd)) > tol
    error("max(abs(DD(nzD)-dd)) > tol");
  endif
  % All-pass filter transfer function 
  [Nap,DDap]=Abcd2tf(Aap,Bap,Cap,DDap);
  if max(abs(fliplr(Nap)-DDap)) > tol
    error("max(abs(fliplr(Nap)-Dap)) > tol");
  endif 
  if max(abs(DDap(nzD)-dd)) > tol
    error("max(abs(DDap(nzD)-dd)) > tol");
  endif 
endfor
  
% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
