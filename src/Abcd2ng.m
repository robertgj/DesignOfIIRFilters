function [ng,As,Bs,Cs,Ds,Ts]=Abcd2ng(A,B,C,D,delta,tol)
% [ng,As,Bs,Cs,Ds,Ts]=Abcd2ng(A,B,C,D,delta,tol)
% Abcd2ng is a utility function that, given a state variable
% description, returns the noise gain and scaled description.
% States that do not contribute to round-off noise are excluded.
% delta should be chosen to provide a compromise between round-off
% noise and arithmetic overflow.
  
% Copyright (C) 2018-2025 Robert G. Jenssen
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

  if (nargin<4) || (nargin > 6) || (nargout>6)
    print_usage("[ng,As,Bs,Cs,Ds,Ts]=Abcd2ng(A,B,C,D,delta,tol)");
  endif
  if nargin==4
    delta=1;
    tol=1e-12;
  elseif nargin==5
    tol=1e-12;
  endif

  % Calculate the covariance matrixes
  [K,W]=KW(A,B,C,D);

  % Scale the state variable description
  Ts=delta*sqrt(diag(K));
  Ts(find(abs(Ts)<tol))=1;
  Ts=diag(Ts);
  invTs=inv(Ts);
  As=invTs*A*Ts;
  Bs=invTs*B;
  Cs=C*Ts;
  Ds=D;
  
  % Select the scaled states that contribute to round-off noise
  z=[As,Bs];
  stsel=ones(rows(z),1);
  for r=1:rows(z)
    z0=abs(z(r,:))<tol;
    z1=abs(abs(z(r,:))-1)<tol;
    if (sum(z1)==1 && sum(z0)==(columns(z)-1)) || (sum(z0)==columns(z))
      stsel(r)=0;
    endif
  endfor
  
  % Calculate the round-off noise gain
  ng=sum(diag(K.*W).*stsel);
  
endfunction
