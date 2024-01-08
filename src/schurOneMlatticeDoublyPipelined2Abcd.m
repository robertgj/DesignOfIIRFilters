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

% Copyright (C) 2023-2024 Robert G. Jenssen
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
  if nargin>3 || nargout<4 || nargout>8
    print_usage("[A,B,C,D,Aap,Bap,Cap,Dap]= ...\n\
      schurOneMlatticeDoublyPipelined2Abcd(k,epsilon,c)");
  endif
  if isempty(k)
    error("k is empty!");
  endif
  if nargin==1
    epsilon=ones(length(k),1);
  endif
  if nargin==1 || nargin==2
    c=zeros(length(k)+1,1);
  endif
  if length(k)~=length(epsilon) || ...
     (length(k)+1)~=length(c)
    error("Input vector lengths inconsistent!");
  endif
  
  % Initialise
  Nk=length(k);
  Ns=(3*Nk)+2;

  % Initialise ABCD
  ABCD=[0,1,zeros(1,Ns-1); ...
        c(1+0),zeros(1,Ns); ...
        eye(Ns+1)];
  
  % Modules 1 to Nk
  for l=1:Nk,
    ABCDl=[[0,              -k(l),0,0,0,(1+epsilon(l)*k(l))]; ...
           [1,                  0,0,0,0,             c(1+l)]; ...
           [0,(1-epsilon(l)*k(l)),0,0,0,               k(l)]];
    ABCDm=[[eye((3*l)-2),zeros((3*l)-2,(3*(Nk-l))+7)];...
           [zeros(3,(3*l)-2),ABCDl,zeros(3,(3*(Nk-l))+1)];...
           [zeros((3*(Nk-l))+4,(3*l)+1),eye((3*(Nk-l))+4)]];
    ABCD=ABCDm*ABCD;
  endfor
           
  % Finalize the state for filter input to state x((3*Nk)+2)
  ABCDm=[[eye(Ns-1),zeros(Ns-1,4)]; ...
         [zeros(3,Ns-1),[0,0,0,1; ...
                         1,0,0,0; ...
                         0,1,0,0]]];
  ABCD=ABCDm*ABCD;

  % Extract the state variable description
  A=ABCD(1:Ns,1:Ns);
  B=ABCD(1:Ns,Ns+1);
  C=ABCD(Ns+1,1:Ns);
  D=ABCD(Ns+1,Ns+1);

  % Extract the all-pass state variable description
  v=setdiff(1:Ns,3*(1:Nk),"sorted");
  Aap=A(v,v);
  Bap=B(v);
  Cap=ABCD(Ns+2,v);
  Dap=ABCD(Ns+2,Ns+1);
 
endfunction
