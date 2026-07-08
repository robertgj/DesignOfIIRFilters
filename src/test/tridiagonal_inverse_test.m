% tridiagonal_inverse_test.m
%
% Find the LU decomposition of a tridiagonal system, A=L*U:
%  _                    _     _               _   _                    _ 
%  |d(1) e(1)            |   |1                |  |u(1) e(1)            |
%  |c(2) d(2)  .         |   |l(2) 1           |  |     u(2)  .         |
%  |       .   .         | = |     l(3) 1      |  |       .   .         |
%  |       .   .  e(n-1) |   |         .  .    |  |           .  e(n-1) |
%  |_        c(n) d(n)  _|   |_         l(n) 1_|  |_             u(n)  _|
%
% Then invert L and U to find A^{-1}=U^{-1}*L^{-1}. See:
% [1] Section 4.3,"Matrix Calculations",3rd Edn,Golub and Van Loan
% [2] Section 9.6,"Accuracy and Stability of Numerical Algorithms",2002,Higham
%
% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="tridiagonal_inverse_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Sanity checks
c=1:3;d=1:4;e=1:3;
try
  tridiagonal_inverse(c,d,e);
catch
  printf("Caught no output arguments!\n")
end_try_catch
try
  A=tridiagonal_inverse(c,d);
catch
  printf("Caught insufficient input arguments!\n")
end_try_catch
try
  A=tridiagonal_inverse(c,d,e,5);
catch
  printf("Caught too many input arguments!\n")
end_try_catch
try
  [A,B]=tridiagonal_inverse(c,d,e);
catch
  printf("Incorrect number of output arguments!\n")
end_try_catch
try
  [A,B,C,D]=tridiagonal_inverse(c,d,e);
catch
  printf("Incorrect number of output arguments!\n")
end_try_catch
try
  [A,B,C,D,E,F]=tridiagonal_inverse(c,d,e);
catch
  printf("Incorrect number of output arguments!\n")
end_try_catch
try
  A=tridiagonal_inverse(c,e,d);
catch
  printf("Incorrect length input arguments!\n")
end_try_catch

%
% Run for an Nxnxn array of N nxn matrixes 
%
tol=1e-11;
for N=[1,10],
  for n=2:30,

    % Initialise Nxnxn array
    reprand();
    e=reprand(N,n)-0.5;
    d=reprand(N,n)-0.5;
    c=reprand(N,n)-0.5;
    A=zeros(N,n,n);
    A(:,1,[1:2])=[d(:,1),e(:,1)];
    for m=2:(n-1)
      A(:,m,[(m-1):(m+1)])=[c(:,m),d(:,m),e(:,m)];
    endfor
    A(:,n,[(n-1):n])=[c(:,n),d(:,n)];

    % Call tridiagonal_inverse
    [invA,invU,invL,L,U] = tridiagonal_inverse(c(:,2:n),d,e(:,1:(n-1)));
                                                     
    % Sanity check on L and U
    for m=1:N,
      max_diff=max(max(abs((squeeze(L(m,:,:))*squeeze(U(m,:,:))- ...
                            squeeze(A(m,:,:))))));
      if max_diff > tol
        error("At m=%d, max(max(abs((L*U)-A)))(%g*tol) > tol",m,max_diff/tol);
      endif
    endfor

    % Sanity check on invL
    for m=1:N,
      max_diff=max(max(abs((squeeze(invL(m,:,:))*squeeze(L(m,:,:)))-eye(n))));
      if max_diff > tol
        error("m=%d,max(max(abs((invL*L)-eye(n))))(%g*tol) > tol", ...
              m,max_diff/tol);
      endif
    endfor
    
    % Sanity check on invU
    for m=1:N,
      max_diff=max(max(abs((squeeze(invU(m,:,:))*squeeze(U(m,:,:)))-eye(n))));
      if max_diff > tol
        error("m=%d,max(max(abs((invU*U)-eye(n))))(%g*tol) > tol", ...
              m,max_diff/tol);
      endif
    endfor
    
    % Sanity check on invU*invL
    for m=1:N,
      max_diff = max(max(abs((squeeze(A(m,:,:))*squeeze(invU(m,:,:))* ...
                              squeeze(invL(m,:,:)))-eye(n))));
      if max_diff > tol
        error("m=%d,max(max(abs((A*invU*invL)-eye(n))))(%g*tol) > tol", ...
              m,max_diff/tol);
      endif
    endfor
    
    % Sanity check on invA
    if N==1
      A=squeeze(A);
      max_diff = max(max(abs((A*invA)-eye(n))));
      if max_diff > tol
        error("m=%d,max(max(abs((A*invA)-eye(n))))(%g*tol) > tol", ...
              m,max_diff/tol);
      endif
    else
      for m=1:N,
        max_diff = ...
            max(max(abs((squeeze(A(m,:,:))*squeeze(invA(m,:,:)))-eye(n))));
        if max_diff > tol
          error("m=%d,max(max(abs((A*invA)-eye(n))))(%g*tol) > tol", ...
                m,max_diff/tol);
        endif
      endfor
    endif
  endfor
endfor

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
