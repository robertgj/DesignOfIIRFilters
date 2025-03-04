function [A,B,C,D]=tfp2schurNSlattice2Abcd(n0,d0,p,s,delta)
% [A,B,C,D]=tfp2schurNSlattice2Abcd(n0,d0,p,s,delta)
% For H(z)=n0(z)/d0(z) and frequency transformation function 
% F(z)=s*z^(M)*p(z)/p(z^-1) find the state-variable filter 
% representation for H(F(z)). s=1(-1) for low-pass(stop). The
% intermediate representation of both the prototype and frequency
% transformation filters is a Schur normalised-scaled lattice.
% delta is the state scaling factor used to globally optimise the
% noise gain of the prototype state variable filter.
% See: C. T. Mullis and R. A. Roberts, "Roundoff Noise in 
% Digital Filters:Frequency Transformations and Invariants", 
% IEEE Trans. Acoustics Speech and Signal Processing, Vol. 24 No. 6,
% pp. 538-550, December 1976

% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Permission is hereby granted, free of charge, to any person
% obtaining a copy of this software and associated documentation
% files (the "Software"), to deal in the Software without restriction,
% including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software,
% and to permit persons to whom the Software is furnished to do so,
% subject to the following conditions: The above copyright notice and
% this permission notice shall be included in all copies or substantial
% portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  % Sanity checks
  if nargin ~= 5
    print_usage("[A,B,C,D]=tfp2schurNSlattice2Abcd(n0,d0,p,s,delta)");
  endif
  if abs(s)~= 1
    error("abs(s)~= 1");
  endif
  
  % Find the Schur normalised scaled state variable representation of 1/F(z)
  [ps10,ps11,ps20,ps00,ps02,ps22]=tf2schurNSlattice(p(length(p):-1:1),s*p);
  [Alpha,Beta,Gamma,Delta]=schurNSlattice2Abcd(ps10,ps11,ps20,ps00,ps02,ps22);

  % Globally optimise the noise gain of H(z)
  [s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n0,d0);
  [a,b,c,d]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
  [k,w]=KW(a,b,c,d);
  [topt,kopt,wopt]=optKW(k,w,delta);
  aopt=inv(topt)*a*topt;
  bopt=inv(topt)*b;
  copt=c*topt;
  dopt=d;

  % Find the state variable representation of H(F(z))
  In=eye(rows(aopt));
  invImDelta_a=inv(In-Delta*aopt);
  A=kron(In,Alpha)+kron(aopt*invImDelta_a,Beta*Gamma);
  B=kron(invImDelta_a*bopt,Beta);
  C=kron(copt*invImDelta_a,Gamma);
  D=dopt+(Delta*copt*invImDelta_a*bopt);

endfunction
