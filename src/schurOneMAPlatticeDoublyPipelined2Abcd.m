function [apA,apB,apC,apD,apA0,apAl] = schurOneMAPlatticeDoublyPipelined2Abcd(k)
% [apA,apB,apC,apD,apA0,apAl] = schurOneMAPlatticeDoublyPipelined2Abcd(k)
% Find the state variable representation of a doubly-pipelined Schur
% one-multiplier lattice all-pass filter.
%
% Inputs:
%  k       - the lattice filter one-multiplier coefficients
% Outputs:
%  [apA,apB;apC,apD] - state variable description of the doubly-pipelined Schur
%                      all-pass lattice filter
%  apA0,apAl - corresponding basis matrixes for the all-pass filter:
%              apA=apA0 + sum_over_l k(l)*apAl{l}

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
  if nargin~=1 || nargout<4 || nargout>6
    print_usage ...
    ("[apA,apB,apC,apD,apA0,apAl]=schurOneMAPlatticeDoublyPipelined2Abcd(k)");
  endif
  if isempty(k)
    error("k is empty!");
  endif

  %
  % Build a state variabl description of the allpass filter
  %
  N=length(k);
  % Modules 1 to N have Ns states
  Ns=(2*N)+2;
  apAl=cell(N,1);
  apA0=[[0,1,zeros(1,Ns-2)];zeros(Ns-1,Ns)];
  for l=1:N, 
    apA0(2*l,(2*l)+2)=1;
    apA0((2*l)+1,(2*l)-1)=1;
    apAl{l}=zeros(Ns,Ns);
    apAl{l}(2*l,(2*l)-1)=-1;
    apAl{l}(2*l,(2*l)+2)=1;
    apAl{l}(2*l+1,(2*l)-1)=-1;
    apAl{l}(2*l+1,(2*l)+2)=1;
  endfor

  apA=apA0;
  for l=1:N, 
    apA=apA+(k(l)*apAl{l});
  endfor
  apB=[zeros(Ns-1,1);1];
  apC=[zeros(1,Ns-2),1,0];
  apD=0;
  
endfunction
