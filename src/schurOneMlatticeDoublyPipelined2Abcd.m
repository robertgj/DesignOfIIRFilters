function [A,B,C,D,Aap,Bap,Cap,Dap] = ...
  schurOneMlatticeDoublyPipelined2Abcd(k,epsilon,c)
% [A,B,C,D,Aap,Bap,Cap,Dap] = schurOneMlatticeDoublyPipelined2Abcd(k,epsilon,c)
% Find the state variable representation of a doubly-pipelined Schur
% one-multiplier lattice filter.
%
% Inputs:
%  k       - the lattice filter one-multiplier coefficients
%  epsilon - the sign coefficients for each module
%  c       - the numerator polynomial tap weights in the orthogonal basis
% Outputs:
%  [A,B;C,D] - state variable description of the doubly-pipelined Schur lattice
%              filter
%  [Aap,Bap;Cap,Dap] - corresponding matrixes for the all-pass filter

% Copyright (C) 2023 Robert G. Jenssen
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
  if nargin~=3 || nargout<4 || nargout>8
    print_usage("[A,B,C,D,Aap,Bap,Cap,Dap]= ...\n\
      schurOneMlatticeDoublyPipelined2Abcd(k,epsilon,c)");
  endif
  if isempty(k)
    error("k is empty!");
  endif
  if length(k)~=length(epsilon) || ...
     (length(k)+1)~=length(c)
    error("Input vector lengths inconsistent!");
  endif
  
  % Initialise
  Nc=length(c);
  Nk=length(k);
  Ns=(5*Nk)+2;

  % Initialise ABCD (move y0=c0*x(1) to c0*x(3))
  ABCD=[0,1,zeros(1,(5*Nk)+1);1,zeros(1,(5*Nk)+2);eye((5*Nk)+3)];
  
  % Modules 1 to Nk
  for n=1:Nk,
    ABCDm=eye((5*Nk)+5); 
    ABCDm(((5*n)-3):((5*n)+3),((5*n)-3):((5*n)+4))=zeros(7,8);
    ABCDm((5*n)-3,(5*n)+1)=-k(n);                 % xp(5n-3)=-kn*x(5n-1)+
    ABCDm((5*n)-3,(5*n)+4)=(1+(k(n)*epsilon(n))); %          (1+kn*en)
    ABCDm((5*n)-2,(5*n)-3)=1;                     % xp(5n-2)=y(n-1)
    ABCDm((5*n)-1,(5*n)-2)=1;                     % xp(5n-1)=yhat(n-1)
    if n==1
      ABCDm((5*n),(5*n)  )=c(1);                  % xp(5n)  =c0*x(5n-2)+
    else
      ABCDm((5*n),(5*n)  )=1;                     % xp(5n)  =x(5n-2)+
    endif
    ABCDm((5*n)  ,(5*n)+4)=c(n+1);                %          cn*x(5n+2)
    ABCDm((5*n+1),(5*n)+1)=(1-(k(n)*epsilon(n))); % xp(5n+1)=(1-(kn*en))*x(5n-2)+
    ABCDm((5*n+1),(5*n)+4)=k(n);                  %          kn*x(5n+2)
    ABCDm((5*n+2),(5*n)+2)=1;                     % y(n)    =x(5n)
    ABCDm((5*n+3),(5*n)+3)=1;                     % yhat(n) =x(5n+1)
    ABCD=ABCDm*ABCD;
  endfor
  
  % Finalize the state for filter input to state ((5*Nk)+2)
  ABCDm=[eye((5*Nk)+1),zeros((5*Nk)+1,4);zeros(3,((5*Nk)+5))];
  ABCDm((5*Nk)+2,(5*Nk)+5)=1; % xp(5Nk+2)=u
  ABCDm((5*Nk)+3,(5*Nk)+2)=1; % y=y(Nk)
  ABCDm((5*Nk)+4,(5*Nk)+3)=1; % yhat=yhat(Nk)
  ABCD=ABCDm*ABCD;

  % Extract the state variable description
  A=ABCD(1:Ns,1:Ns);
  B=ABCD(1:Ns,Ns+1);
  C=ABCD(Ns+1,1:Ns);
  D=ABCD(Ns+1,Ns+1);

  % Extract the all-pass state variable description
  v=setdiff(1:Ns,[5*(1:Nk),5*(1:Nk)-2],"sorted");
  ABCDap=[ABCD(v,v),ABCD(v,end);ABCD(end,v),ABCD(end,end)];
  Nap=rows(ABCDap)-1;
  Aap=ABCDap(1:Nap,1:Nap);
  Bap=ABCDap(1:Nap,Nap+1);
  Cap=ABCDap(Nap+1,1:Nap);
  Dap=ABCDap(Nap+1,Nap+1);
 
endfunction
