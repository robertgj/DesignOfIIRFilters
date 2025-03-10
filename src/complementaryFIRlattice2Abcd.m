function [A,B,Ch,Dh,Cg,Dg,dAdkkhat,dBdkkhat,dChdkkhat,dDhdkkhat, ...
          dCgdkkhat,dDgdkkhat]=complementaryFIRlattice2Abcd(k,khat)
% [A,B,Ch,Dh,Cg,Dg]=complementaryFIRlattice2Abcd(k,khat)
% [A,B,Ch,Dh,Cg,Dg,dAdkkhat,dBdkkhat,dChdkkhat,dDhdkkhat, ...
%   dCgdkkhat,dDgdkkhat]=complementaryFIRlattice2Abcd(k,khat)
% Inputs:
%  k and khat are the complementary FIR lattice filter coefficients
% Outputs:
%  [A,B,Ch,Dh] is the state variable description of the FIR lattice filter
%  [A,B,Cg,Dg] is the state variable description of the complementary filter

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
  if (nargin~=2) || (nargout>12) 
    print_usage(["[A,B,Ch,Dh,Cg,Dg]=complementaryFIRlattice2Abcd(k,khat)\n", ...
 "[A,B,Ch,Dh,Cg,Dg,dAdkkhat,dBdkkhat,dChdkkhat,dDhdkkhat, ...\n", ...
 "  dCgdkkhat,dDgdkkhat]=complementaryFIRlattice2Abcd(k,khat)"]);
  endif
  if length(k) ~= length(khat)
    error("length(k) ~= length(khat)");
  endif
  if length(k)==1
    error("length(k)==1");
  endif
  
  % Initialise 
  k=k(:);
  khat=khat(:);
  N=length(k)-1;

  % Nodule 1 (input)
  ABCD=[zeros(2,N),[khat(1);k(1)];eye(N,N),zeros(N,1)];

  % Nodules 2 to N+1
  for l=2:N+1,
    mMod=eye(N+2,N+2);
    mMod(l:l+1,l:l+1)=[khat(l),k(l);k(l),-khat(l)];
    ABCD=mMod*ABCD;
  endfor

  % Extract state variable description
  A=ABCD(1:N,1:N);
  B=ABCD(1:N,N+1);
  % Construct filter output
  Cg=ABCD(N+1,1:N);
  Dg=ABCD(N+1,N+1);
  Ch=ABCD(N+2,1:N);
  Dh=ABCD(N+2,N+1);

  if nargout <= 6
    return;
  endif

  %
  % Calculate the differentials of A,B,Ch,Dh,Cg and Dg with respect to k and khat
  %

  % Find modules 1 to N+1 (again!)
  ABCDm=cell(1,N+1);
  ABCDm{1}=[zeros(2,N),[khat(1);k(1)];eye(N,N),zeros(N,1)];
  for l=2:N+1,
    ABCDm{l}=eye(N+2,N+2);
    ABCDm{l}(l:l+1,l:l+1)=[khat(l),k(l);k(l),-khat(l)];
  endfor

  % Find RHS cumulative product (index order is 1,2*1,...,N*...*1,(N+1)*...*1)
  prodABCDm_rhs=cell(1,N+1);
  prodABCDm_rhs{1}=ABCDm{1};
  for l=2:N+1,
    prodABCDm_rhs{l}=ABCDm{l}*prodABCDm_rhs{l-1};
  endfor

  % Find LHS cumulative product(index order is (N+1)*..*1,...,(N+1)*N,(N+1)
  prodABCDm_lhs=cell(1,N+1);
  prodABCDm_lhs{N+1}=ABCDm{N+1};
  for l=N:-1:1,
    prodABCDm_lhs{l}=prodABCDm_lhs{l+1}*ABCDm{l};
  endfor

  % Find differentials of the modules with respect to k
  dABCDmdk=cell(1,N+1);
  dABCDmdk{1}=[zeros(2,N),[0;1];zeros(N,N+1)];
  for l=2:N+1,
    dABCDmdk{l}=zeros(N+2,N+2);
    dABCDmdk{l}(l:l+1,l:l+1)=[0,1;1,0];
  endfor

  % Find differentials of the modules with respect to khat
  dABCDmdkhat=cell(1,N+1);
  dABCDmdkhat{1}=[zeros(2,N),[1;0];zeros(N,N+1)];
  for l=2:N+1,
    dABCDmdkhat{l}=zeros(N+2,N+2);
    dABCDmdkhat{l}(l:l+1,l:l+1)=[1,0;0,-1];
  endfor

  % Find overall differentials with respect to k
  dABCDdk=cell(1,N+1);
  dABCDdk{1}=prodABCDm_lhs{2}*dABCDmdk{1};
  for l=2:N,
    dABCDdk{l}=prodABCDm_lhs{l+1}*dABCDmdk{l}*prodABCDm_rhs{l-1};
  endfor
  dABCDdk{N+1}=dABCDmdk{N+1}*prodABCDm_rhs{N};
  
  % Find overall differentials with respect to khat
  dABCDdkhat=cell(1,N+1);
  dABCDdkhat{1}=prodABCDm_lhs{2}*dABCDmdkhat{1};
  for l=2:N,
    dABCDdkhat{l}=prodABCDm_lhs{l+1}*dABCDmdkhat{l}*prodABCDm_rhs{l-1};
  endfor
  dABCDdkhat{N+1}=dABCDmdkhat{N+1}*prodABCDm_rhs{N};
  
  % Make the output cell arrays
  dAdkkhat=cell(1,2*(N+1));
  dBdkkhat=cell(1,2*(N+1));
  dCgdkkhat=cell(1,2*(N+1));
  dDgdkkhat=cell(1,2*(N+1));
  dChdkkhat=cell(1,2*(N+1));
  dDhdkkhat=cell(1,2*(N+1));
  for l=1:N+1,
    dAdkkhat{l}=dABCDdk{l}(1:N,1:N);
    dAdkkhat{l+N+1}=dABCDdkhat{l}(1:N,1:N);

    dBdkkhat{l}=dABCDdk{l}(1:N,N+1);
    dBdkkhat{l+N+1}=dABCDdkhat{l}(1:N,N+1);

    dCgdkkhat{l}=dABCDdk{l}(N+1,1:N);
    dCgdkkhat{l+N+1}=dABCDdkhat{l}(N+1,1:N);

    dDgdkkhat{l}=dABCDdk{l}(N+1,N+1);
    dDgdkkhat{l+N+1}=dABCDdkhat{l}(N+1,N+1);

    dChdkkhat{l}=dABCDdk{l}(N+2,1:N);
    dChdkkhat{l+N+1}=dABCDdkhat{l}(N+2,1:N);

    dDhdkkhat{l}=dABCDdk{l}(N+2,N+1);
    dDhdkkhat{l+N+1}=dABCDdkhat{l}(N+2,N+1);
  endfor
  
endfunction
