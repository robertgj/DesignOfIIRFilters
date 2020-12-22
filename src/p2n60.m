function n60 = p2n60(a,tol)
% n60 = p2n60(a,tol)
% Estimate the number of samples required for the impulse response of
% the filter with denominator polynomial a to decay to 1/1000.
%
% Approximate the filter transfer function by 1/(1-amax/z) where
% amax=max(abs(qroots(a))). The impulse response is 1, amax, amax^2, ...
% If (amax^n60)<0.001, then n60=ceil(-3/log10(amax))
  
  if (nargin~=1 && nargin~=2) || nargout>1
    print_usage("n60 = p2n60(a,tol)");
  endif

  if nargin==1
    tol=1e-6;
  endif

  amax=max(abs(qroots(a)));
  if amax>=(1-tol)
    error("amax(%g)>=(1-tol(%g))",amax,tol);
  endif

  n60=ceil(-3/log10(amax));

endfunction
