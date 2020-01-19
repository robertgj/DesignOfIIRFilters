function x = local_max(c)
% x = local_max(c)
% Based on the local_max(x) function of I.W.Selesnick from:
% http://dsp.rice.edu/files/software/ConstrainedLeastSquaresAllprogs.tar.zip

  if nargin~=1 || nargout>1
    print_usage("x=local_max(c)");
  endif
  % Sanity checks
  if isempty(c)
    x=[];
    return;
  elseif length(c)==1
    x=[1];
    return;
  endif

  % Find the locations of local maximums
  s = size(c); 
  c = [c(:)].';
  N = length(c);
  b1 = c(1:N-1)<=c(2:N);
  b2 = c(1:N-1)>c(2:N);
  x = find(b1(1:N-2)&b2(2:N-1))+1;
  if c(1)>c(2),
    x = [x, 1];
  endif
  if c(N)>c(N-1),
    x = [x, N];
  endif
  x = sort(x);
  x = x(:);

endfunction
