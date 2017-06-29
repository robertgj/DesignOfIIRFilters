function[char]=labudde(A)
% [char]=labudde(A)
% The following code computes the coefficients of the
% characteristic polynomial of a complex matrix A by
% using Labudde's Method. It uses Algorithm 5 of chapter 6
% INPUT: a complex matrix
% OUTPUT: coefficients of characteristic polynomial

% Modified for Octave from Appendix B of the Ph.D. thesis of
% R. Rehman, "Numerical Computation of the Characteristic
% Polynomial of a Complex Matrix", downloaded from
% http://www.lib.ncsu.edu/resolver/1840.16/6262
  
  warning("Using Octave m-file version of function labudde()!");

  % Step 1: Use Matlab's hess function to reduce A to
  % hessenberg form.
  H=hess(A);
  [n,n] = size(H);

  % k=n produces all coefficients, if some initial low
  % order coefficients are required, k can be changed.
  k=n;

  % c matrix stores coefficients of characteristic
  % polynomials of principal submatrices of H
  c = zeros(n,k);
  c(1,1) = -H(1,1);

  % gamma stores subdiagonal entries of H
  gamma=zeros(n,1);
  for s = 2:n
    gamma(s) = H(s,s-1);
  endfor

  for m=2:n
    for j=1:k
      if(j<=m)
        if(j==1)
          c(m,j) = c(m-1,j)-H(m,m);
        else
          Prod = gamma(m)*ones(j-1,1);
          Sum = 0;
          if(j>2)
            for s=1:j-2
              Prod(s+1)= Prod(s)*gamma(m-s);
              Sum = Sum+(H(m-s,m)*Prod(s)*c(m-s-1,j-s-1));
            endfor
            Sum = Sum+(H(m-j+1,m)*Prod(j-1));
          endif
          if(j==2)
            Sum = H(m-j+1,m)*Prod(j-1);
          endif
          c(m,j) = c(m-1,j)-H(m,m)*c(m-1,j-1)-Sum;
        endif
      endif
    endfor
  endfor
  char=c(end,:);

endfunction
