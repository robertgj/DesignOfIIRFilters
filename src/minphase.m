function [y,ssp,iter] = minphase(h);
% [y,ssp,iter] = minphase(h);
% minphase.m m-file for extracting the minimum phase factor from the 
% linear-phase filter h. Input: h = (h(0) h(1)...h(N)] (row vector) 
% where the h vector is the right half of a linear-phase FIR filter.
% It is presumed that any unit-circle zeros of h are of even multiplicity. 
% Copyright (c) January 2002  by  H. J. Orchard and A. N. Willson, Jr.

if 0
  % By default, use this minphase.m script rather than minphase.oct
  warning("Using Octave m-file version of function minphase()!");
endif

h=h(:)';
y = [1 zeros(1,length(h)-1)];  % Initialize y (poly. with all zeros at z = 0)
ssp = realmax;                 % a large number (for previous norm)
ss = ssp/2;                    % smaller large no. (for current norm)
iter = 0;  d = 0;              % Initialize iter. counter & correction vector
while ( ss < ssp )
  y = y + d';   ssp = ss;      % Update  y  and move old norm(d) value
  iter = iter + 1;             % Increment the iteration count
  Ar = toeplitz([y(1), zeros(1,length(h)-1)], y);
  Al = fliplr(toeplitz([y(length(h)), zeros(1,length(h)-1)], fliplr(y)));
  A = Al + Ar;                 % Create the A matrix
  b = h' - Al*y';              % and create the b vector
  d = A\b;                     % Solve  Ad = b  for the correction vector d 
  ss = norm(d);                % Get norm to see if were still decreasing
end;
