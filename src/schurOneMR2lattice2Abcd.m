function [A,B,C,D,Aap,Bap,Cap,Dap,ABCD0,ABCDk,ABCDc,ABCDap0,ABCDapk] = ...
            schurOneMR2lattice2Abcd(k,epsilon,c)
% [A,B,C,D,Aap,Bap,Cap,Dap,ABCD0,ABCDk,ABCDc,ABCDap0,ABCDapk] = ...
%    schurOneMR2lattice2Abcd(k,epsilon,c)
%
% Return the retimed state variable description of a Schur one-multiplier
% lattice filter having a transfer function denominator with terms only in
% z^-2.  The number of filter states in the tapped lattice filter is
% increased from N to N+(N/2)-1 where N is the filter order, assumed
% to be even. The filter states are not scaled. The IIR filter tap state
% update calculations have the form x=p*q+r*s+t. The all-pass lattice state
% update calculations have the form x=p*q+r*s.
%
% Inputs:
%  k - lattice section multiplier coefficients ([0,k(2),0,k(4),0,...,0,k(N)])
%  epsilon - lattice section sign coefficients
%  c - numerator polynomial tap weights in the Schur orthogonal basis
% Outputs:
%  [A,B,C,D] - state variable description of the tapped lattice filter
%  [Aap,Bap,Cap,Dap] - state variable description of the all-pass lattice filter
%  ABCD0 - constant values in [A,B,C,D]
%  ABCDk - cell array of N coefficient matrixes of k in [A,B,C,D]
%  ABCDapc - cell array of N+1 coefficient matrixes of c in [Aap,Bap,Cap,Dap]
%  ABCDap0 - constant values in [Aap,Bap,Cap,Dap]
%  ABCDapk - cell array of coefficient matrixes of k in [Aap,Bap,Cap,Dap]
  
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

  % ?? Calculate matrix coefficients first? Then calculate A,B,C,D etc? ??
  
  % Sanity checks
  if (nargin ~= 3) || (nargout < 4) || (nargout > 13)
    print_usage ...
    (["[A,B,C,D,Aap,Bap,Cap,Dap,ABCD0,ABCDk,ABCDc,ABCDap0,ABCDapk]= ", ...
 "       schurOneMR2lattice2Abcd(k,epsilon,c)"]);
  endif
  N=length(k);
  if N<2
    error("Expected length(k)>=2!");
  endif
  if (N~=length(epsilon)) || ((1+N)~=length(c))
    error("Input vector lengths inconsistent!");
  endif
  if mod(N,2)
    error("Expected length(k) even");
  endif
  if any(k(1:2:N))
    error("Expected all(k(1:2:N))==0")
  endif

  k=k(:)';
  epsilon=epsilon(:)';
  c=c(:)';

  % Allocate storage
  Non2=N/2;
  NS=N+Non2-1;
  A=zeros(NS,NS);
  B=zeros(NS,1);
  C=zeros(1,NS);
  pek=ones(size(k))+(epsilon.*k);
  mek=ones(size(k))-(epsilon.*k);
  
  % Special case for N=2
  if N==2
    % Tapped filter
    A(1,2)=1;
    A(2,1)=-k(2);
    B(2)=pek(2);
    C(1)=c(1);
    C(2)=c(2);
    D=c(3);
    if nargout == 4
      return;
    endif
    % All-pass filter
    Aap=A;
    Bap=B;
    Cap=[mek(2),0];
    Dap=k(2);
    if nargout <= 8
      return;
    endif
    % Tapped filter coefficient matrixes
    A0=[0,1;0,0];B0=[0;1];C0=[0,0];D0=0; ABCD0=[A0,B0;C0,D0];
    ABCDk=cell(1,N);
    ABCDk{1}=zeros(NS+1);
    ABCDk{2}=[[0,0,0];[-1,0,epsilon(2)];[0,0,0]];
    ABCDc=cell(1,N+1);
    ABCDc{1}=[[0,0,0];[0,0,0];[1,0,0]];
    ABCDc{2}=[[0,0,0];[0,0,0];[0,1,0]];
    ABCDc{3}=[[0,0,0];[0,0,0];[0,0,1]];
    if nargout <= 11
      return;
    endif
    % All-pass filter coefficient matrixes
    Aap0=A0;Bap0=B0;Cap0=[1,0];Dap0=0; ABCDap0=[Aap0,Bap0;Cap0,Dap0];
    ABCDapk=cell(1,N);
    ABCDapk{1}=zeros(NS+1);
    ABCDapk{2}=[[0,0,0];[-1,0,epsilon(2)];[-epsilon(2),0,1]];
    return;
  endif

  %
  % Tapped filter
  %

  % Initial module
  % x(1)=x(2)
  A(1,2)=1;
  % Tap coefficient:
  % x(4)=c(3)*x(5)+c(2)*x(2)+c(1)*x(1)
  A(4,5)=c(3);
  A(4,2)=c(2);
  A(4,1)=c(1);
  % One-multiplier sections:
  % x(2)=pek(2)*x(5)-k(2)*x(1)
  A(2,1)=-k(2);
  A(2,5)=pek(2);
  % x(3)=mek(2)*x(1)+k(2)*x(5)
  A(3,1)=mek(2);
  A(3,5)=k(2);
  
  % Repeated modules
  for n=2:(Non2-1)
    % Tap coefficients:
    % x(3n+1)=c(2n+1)*x(3n+2)+c(2n)*x(3n-1)+x(3n-2)
    A((3*n)+1,(3*n)+2)=c((2*n)+1);
    A((3*n)+1,(3*n)-1)=c(2*n);
    A((3*n)+1,(3*n)-2)=1;
    
    % One-multiplier sections:
    % x(3n-1)=pek(2n)*x(3n+2)-k(2n)*x(3n-3)
    A((3*n)-1,(3*n)+2)=pek(2*n);
    A((3*n)-1,(3*n)-3)=-k(2*n);
    % x(3n)=mek(2n)*x(3n-3)+k(2n)*x(3n+2)
    A(3*n,(3*n)+2)=k(2*n);
    A(3*n,(3*n)-3)=mek(2*n);
  endfor
  
  % Final module
  % x((3N/2)-1)=pek(N)*u - k(N)*x((3N/2)-3)
  A((3*Non2)-1,(3*Non2)-3)=-k(N);
  B((3*Non2)-1)=pek(N);
  % Tapped output
  % y=c(N+1)*u+c(N)*x((3N/2)-1)+x((3N/2)-2)
  C((3*Non2)-1)=c(N);
  C((3*Non2)-2)=1;
  D=c(N+1);

  if nargout == 4
    return;
  endif

  %
  % All pass filter
  %
  % yap=Cap*x+Dap*u
  Bap=zeros(columns(A),1);
  Bap((3*Non2)-1)=pek(N);
  Cap=zeros(1,rows(A));
  Cap(1,(3*Non2)-3)=mek(N);
  Dap=k(N);
  % Only use the all-pass states
  indexABCap=sort([1,(3*(1:Non2))-1,3*(1:(Non2-1))]);
  Aap=A(indexABCap,indexABCap); 
  Bap=Bap(indexABCap);
  Cap=Cap(indexABCap);

  if nargout <= 8
    return;
  endif

  %
  % Tapped filter matrix coefficients
  %
  ABCD0=zeros(NS+1);
  ABCDk = cell(1,N);
  for n=1:N,
    ABCDk{n}=zeros(NS+1);
  endfor
  ABCDc = cell(1,N+1);
  for n=1:N,
    ABCDc{n}=zeros(NS+1);
  endfor

  % Initial module
  % x(1)=x(2)
  ABCD0(1,2)=1;
  % Tap coefficient:
  % One-multiplier sections:
  % x(2)=pek(2)*x(5)-k(2)*x(1)
  ABCD0(2,5)=1;
  ABCDk{2}(2,5)=epsilon(2);  
  ABCDk{2}(2,1)=-1; 
  % x(3)=mek(2)*x(1)+k(2)*x(5)
  ABCD0(3,1)=1;
  ABCDk{2}(3,1)=-epsilon(2);
  ABCDk{2}(3,5)=1; 
  % x(4)=c(3)*x(5)+c(2)*x(2)+c(1)*x(1)
  ABCDc{3}(4,5)=1;
  ABCDc{2}(4,2)=1;
  ABCDc{1}(4,1)=1;
 
  % Repeated modules
  for n=2:(Non2-1)
    % One-multiplier sections:
    % x(3n-1)=pek(2n)*x(3n+2)-k(2n)*x(3n-3)
    ABCD0((3*n)-1,(3*n)+2)=1;
    ABCDk{2*n}((3*n)-1,(3*n)+2)=epsilon(2*n);
    ABCDk{2*n}((3*n)-1,(3*n)-3)=-1;
    % x(3n)=mek(2n)*x(3n-3)+k(2n)*x(3n+2)
    ABCD0(3*n,(3*n)-3)=1;
    ABCDk{2*n}(3*n,(3*n)-3)=-epsilon(2*n);
    ABCDk{2*n}(3*n,(3*n)+2)=1;
    % Tap coefficients:
    % x(3n+1)=c(2n+1)*x(3n+2)+c(2n)*x(3n-1)+x(3n-2)
    ABCD0((3*n)+1,(3*n)-2)=1;
    ABCDc{2*n}((3*n)+1,(3*n)-1)=1;
    ABCDc{(2*n)+1}((3*n)+1,(3*n)+2)=1;
  endfor
  
  % Final module
  % x(NS)=pek(N)*u - k(N)*x(NS-2)
  ABCD0(NS,NS+1)=1;
  ABCDk{N}(NS,NS+1)=epsilon(N);
  ABCDk{N}(NS,NS-2)=-1;
  % Tapped output
  % y=c(N+1)*u+c(N)*x(NS)+x(NS-1)
  ABCD0(NS+1,NS-1)=1; 
  ABCDc{N}(NS+1,NS)=1;
  ABCDc{N+1}(NS+1,NS+1)=1;

  if nargout <= 11
    return;
  endif

  %
  % All pass filter matrix coefficients
  %
  ABCDap0=zeros(N+1);
  ABCDapk=cell(1,N);
  for n=1:N,
    ABCDapk{n}=zeros(N+1);
  endfor
  
  % Initial module
  % x(1)=x(2)
  ABCDap0(1,2)=1;
  
  % Repeated modules
  for n=1:(Non2-1)
    % One-multiplier sections:
    % x(2n)=-k(2n)*x(2n-1)+pek(2n)*x(2n+2)
    ABCDap0(2*n,(2*n)+2)=1;
    ABCDapk{2*n}(2*n,(2*n)+2)=epsilon(2*n);
    ABCDapk{2*n}(2*n,(2*n)-1)=-1;
    % x(2n+1)=mek(2n)*x(2n-1)+k(2n)*x(2n+2)
    ABCDap0((2*n)+1,(2*n)-1)=1;
    ABCDapk{2*n}((2*n)+1,(2*n)-1)=-epsilon(2*n);
    ABCDapk{2*n}((2*n)+1,(2*n)+2)=1;
  endfor
  
  % Final module
  % x(N)=pek(N)*u - k(N)*x(N-1)
  ABCDap0(N,N+1)=1;
  ABCDapk{N}(N,N+1)=epsilon(N);
  ABCDapk{N}(N,N-1)=-1;
  % yap=mek(N)*x(N-1)+k(N)*u
  ABCDap0(N+1,N-1)=1;
  ABCDapk{N}(N+1,N-1)=-epsilon(N);
  ABCDapk{N}(N+1,N+1)=1;

endfunction
