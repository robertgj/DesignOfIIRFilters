% directFIRsymmetric_sdp_basis_test.m
% Copyright (C) 2021 Robert G. Jenssen

test_common;

delete("directFIRsymmetric_sdp_basis_test.diary");
delete("directFIRsymmetric_sdp_basis_test.diary.tmp");
diary directFIRsymmetric_sdp_basis_test.diary.tmp

try
  [Ea]=directFIRsymmetric_sdp_basis(1,2);
catch
  printf("Caught nargin~=1\n");
end_try_catch;
try
  [Ea]=directFIRsymmetric_sdp_basis(1);
catch
  printf("Caught nargout~=2\n");
end_try_catch;
try
  [Ea]=directFIRsymmetric_sdp_basis(2);
catch
  printf("Caught nargout~=4\n");
end_try_catch;
try
  [Ea,Eb,Ec,Ed]=directFIRsymmetric_sdp_basis(0);
catch
  printf("Caught n<=0\n");
end_try_catch;

tol=80*eps;

for n=2:10:102;
  k=floor(n/2);
  [E0k,E0km1,E1km1,E2km1]=directFIRsymmetric_sdp_basis(n);
  for f=0:0.05:0.5,

    cosfkk=cos(2*pi*f*(0:k)').*cos(2*pi*f*(0:k));

    T0k_check=zeros(k+1,k+1);
    for m=0:n,
      if ~issymmetric(E0k{m+1})
        error("E0k{%d+1} not symmetric",m);
      endif
      T0k_check=T0k_check+(cos(2*pi*f*m)*E0k{m+1});
    endfor
    err=max(max(abs(T0k_check-cosfkk)));
    if err > tol
      error("Sanity check on T0k failed(%g)",err);
    endif
    
    T0km1_check=zeros(k,k);
    for m=0:n,
      if ~issymmetric(E0km1{m+1})
        error("E0km1{%d+1} not symmetric",m);
      endif
      T0km1_check=T0km1_check+(cos(2*pi*f*m)*E0km1{m+1});
    endfor
    err=max(max(abs(T0km1_check-cosfkk(1:k,1:k))));
    if err > tol
      error("Sanity check on T0km1 failed(%g)",err);
    endif

    T1km1_check=zeros(k,k);
    for m=0:n,
      if ~issymmetric(E1km1{m+1})
        error("E1km1{%d+1} not symmetric",m);
      endif
      T1km1_check=T1km1_check+(cos(2*pi*f*m)*E1km1{m+1});
    endfor
    err=max(max(abs(T1km1_check-(cos(2*pi*f)*cosfkk(1:k,1:k)))));
    if err > tol
      error("Sanity check on T1km1 failed(%g)",err);
    endif

    T2km1_check=zeros(k,k);
    for m=0:n,
      if ~issymmetric(E2km1{m+1})
        error("E2km1{%d+1} not symmetric",m);
      endif
      T2km1_check=T2km1_check+(cos(2*pi*f*m)*E2km1{m+1});
    endfor
    err=max(max(abs(T2km1_check-(cos(2*pi*2*f)*cosfkk(1:k,1:k)))));
    if err > tol
      error("Sanity check on T2km1 failed(%g)",err);
    endif
  endfor
endfor

for n=1:10:101;
  k=floor(n/2);
  [E0k,E1k]=directFIRsymmetric_sdp_basis(n);
  for f=0:0.05:0.5,

    cosfkk=cos(2*pi*f*(0:k)').*cos(2*pi*f*(0:k));

    T0k_check=zeros(k+1,k+1);
    for m=0:n,
      if ~issymmetric(E0k{m+1})
        error("E0k{%d+1} not symmetric",m);
      endif
      T0k_check=T0k_check+(cos(2*pi*f*m)*E0k{m+1});
    endfor
    err=max(max(abs(T0k_check-cosfkk)));
    if err > tol
      error("Sanity check on T0k failed(%g)",err);
    endif
    
    T1k_check=zeros(k+1,k+1);
    for m=0:n,
      if ~issymmetric(E1k{m+1})
        error("E1k{%d+1} not symmetric",m);
      endif
      T1k_check=T1k_check+(cos(2*pi*f*m)*E1k{m+1});
    endfor
    err=max(max(abs(T1k_check-(cos(2*pi*f)*cosfkk))));
    if err > tol
      error("Sanity check on T1k failed(%g)",err);
    endif
  endfor
endfor

% Done
diary off
movefile directFIRsymmetric_sdp_basis_test.diary.tmp ...
         directFIRsymmetric_sdp_basis_test.diary;

