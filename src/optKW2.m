function [T,Kopt,Wopt]=optKW2(K,W,delta)
% function [T,Kopt,Wopt]=optKW2(K,W,delta) 
% Given 2 by 2 covariance and noise gain matrices K and W, and
% the scaling parameter, delta, optKW2 finds the transformation, T,
% giving minium round off noise. This function may fail for
% second order sections that implement the first order section
% of an odd length transfer function.

% Copyright (C) 2017,2018 Robert G. Jenssen
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

  % First check the input arguments
  if (nargin ~= 3)
    print_usage("[T,Kopt,Wopt]=optKW2(K,W,delta)");
  end 
  [m,n]=size(K);
  if ((m~=n) || (m~=2))
    error("K must be 2 by 2");
  end 
  [m,n]=size(W);
  if ((m~=n) || (m~=2))
    error("W must be 2 by 2");
  end 
  
  % Cholesky transformation
  if K(2,2) == 0   
    error("K(2,2) == 0");
  endif
  TC=[sqrt((K(1,1)*K(2,2)-K(1,2)*K(1,2))/K(2,2)), K(1,2)/sqrt(K(2,2))];
  TC=[TC; 0, sqrt(K(2,2))];
  K1=inv(TC)*K*inv(TC');
  W1=TC'*W*TC;

  % Diagonalise W
  if (abs(W1(1,1) - W1(2,2)) < 100*eps)
    theta = pi/4;
  else
    theta = 0.5*atan2(2*W1(1,2), (W1(1,1)-W1(2,2)));
  end
  R=[cos(theta) -sin(theta); sin(theta) cos(theta)];
  W2=inv(R)*W1*R;
  if W2(1,1) == 0
    error("W2(1,1) == 0");
  endif

  % Balance K and W so that K*W(i,i) = K*W(j,j) for all i,j
  mu=sqrt(W2(2,2)/W2(1,1));
  S=delta*0.5*[sqrt(1+mu) -sqrt(1+mu); sqrt((1+mu)/mu) sqrt((1+mu)/mu)];

  % The optimising transformation is
  T=TC*R*S;

  % Find the optimised Kopt, Wopt
  Kopt=inv(T)*K*inv(T)';
  Wopt=T'*W*T;

endfunction
