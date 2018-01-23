function [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc,dCapdkc,dDapdkc] = ...
           schurOneMlattice2Abcd(k,epsilon,p,c)
% [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc,dCapdkc,dDapdkc] = ...
%   schurOneMlattice2Abcd(k,epsilon,p,c)
% Find the state variable representation of a Schur one-multiplier lattice
% filter. (Note that here the state scaling vector, p, is assumed to be fixed.
% In fact it is calculated from k when the design is complete).
%
% Inputs:
%  k       - the lattice filter one-multiplier coefficients
%  epsilon - the sign coefficients for each module
%  p       - the state scaling factors
%  c       - the numerator polynomial tap weights in the orthogonal basis
% Outputs:
%  [A,B;C,D]               - state variable description of the lattice filter
%  Cap,Dap                 - corresponding matrixes for the all-pass filter
%  dAdkc,dBdkc,dCdkc,dDdkc - cell vectors of the differentials of A, B, C and D
%  dCapdk,dDapdk           - cell vectors of the differentials of Cap and Dap    

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

  warning("Using Octave m-file version of function schurOneMlattice2Abcd()!");

  % Sanity checks
  if nargin~=4 || nargout<4
    print_usage ("[A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc,dCapdkc,dDapdkc]=\n\
                schurOneMlattice2Abcd(k,epsilon,p,c)");
  endif
  if length(k)~=length(epsilon) || ...
     length(k)~=length(p) || ...
     (length(k)+1)~=length(c)
    error("Input vector lengths inconsistent!");
  endif
  if isempty(k)
    error("k is empty!");    
  endif
  
  % Initialise
  k=k(:)';
  Nk=length(k);
  c=c(:)';
  Nc=length(c);
  Nkc=Nk+Nc;
  
  % Modules 1 to Nk
  ABCapDap=eye(Nk+1,Nk+1);
  for l=1:Nk
    ABCapDapm=eye(Nk+1,Nk+1);
    ABCapDapm(l:l+1,l:l+1)=[-k(l),1+(k(l)*epsilon(l));1-(k(l)*epsilon(l)),k(l)];
    ABCapDap=ABCapDapm*ABCapDap;
  endfor

  % Extract state variable description
  A=ABCapDap(1:Nk,1:Nk);
  B=ABCapDap(1:Nk,Nk+1);
  % Construct filter output
  C=c(1:Nk);
  D=c(Nk+1);
  % Construct all-pass output
  Cap=ABCapDap(Nk+1,1:Nk);
  Dap=ABCapDap(Nk+1,Nk+1);

  % Scale the states
  T=diag(p);
  invT=inv(T);
  A=invT*A*T;
  B=invT*B;
  C=C*T;
  Cap=Cap*T;

  % Done?
  if nargout <= 6
    return;
  endif

  % Calculate the differentials of A,B,C,D,Cap and Dap with respect to [k,c]
  % Find modules 1 to Nk (again!)
  ABCapDapm=cell(1,Nk);
  for l=1:Nk,
    ABCapDapm{l}=eye(Nk+1,Nk+1);
    ABCapDapm{l}(l:l+1,l:l+1)=[-k(l)              , 1+(k(l)*epsilon(l)); ...
                               1-(k(l)*epsilon(l)), k(l)];
  endfor
  % Find RHS cumulative product (index order is 1,2*1,...,(Nk-1)*...*1,Nk*...*1)
  prodABCapDapm_rhs=cell(1,Nk);
  prodABCapDapm_rhs{1}=ABCapDapm{1};
  for l=2:Nk,
    prodABCapDapm_rhs{l}=ABCapDapm{l}*prodABCapDapm_rhs{l-1};
  endfor
  % Find LHS cumulative product(index order is Nk*..*1,Nk*..*2,..,Nk*(Nk-1),Nk)
  prodABCapDapm_lhs=cell(1,Nk);
  prodABCapDapm_lhs{Nk}=ABCapDapm{Nk};
  for l=(Nk-1):-1:1,
    prodABCapDapm_lhs{l}=prodABCapDapm_lhs{l+1}*ABCapDapm{l};
  endfor
  % Find differentials with respect to k of the modules
  dABCapDapmdk=cell(1,Nk);
  for l=1:Nk,
    dABCapDapmdk{l}=zeros(Nk+1,Nk+1);
    dABCapDapmdk{l}(l:l+1,l:l+1)=[-1,epsilon(l);-epsilon(l),1];
  endfor
  % Find differentials with respect to k of [A,B;Cap,Dap]
  dABCapDapdk=cell(1,Nk);
  if Nk<2
    dABCapDapdk{1}=dABCapDapmdk{1};
  else
    dABCapDapdk{1}=prodABCapDapm_lhs{2}*dABCapDapmdk{1};
    for l=2:(Nk-1),
      dABCapDapdk{l}= ...
      prodABCapDapm_lhs{l+1}*dABCapDapmdk{l}*prodABCapDapm_rhs{l-1};
    endfor
    dABCapDapdk{Nk}=dABCapDapmdk{Nk}*prodABCapDapm_rhs{Nk-1};
  endif
  % Scale the states and make the output vectors
  dAdkc=cell(1,Nkc);
  dBdkc=cell(1,Nkc);
  dCdkc=cell(1,Nkc);
  dDdkc=cell(1,Nkc);
  dCapdkc=cell(1,Nkc);
  dDapdkc=cell(1,Nkc);
  for l=1:Nk,
    dAdkc{l}=invT*(dABCapDapdk{l}(1:Nk,1:Nk))*T;
    dBdkc{l}=invT*(dABCapDapdk{l}(1:Nk,Nk+1));
    dCapdkc{l}=(dABCapDapdk{l}(Nk+1,1:Nk))*T;
    dDapdkc{l}=dABCapDapdk{l}(Nk+1,Nk+1);
    dCdkc{l}=zeros(1,Nk);
    dDdkc{l}=0;
  endfor
  for l=1:Nk,
    dAdkc{l+Nk}=zeros(Nk,Nk);
    dBdkc{l+Nk}=zeros(Nk,1);
    dCapdkc{l+Nk}=zeros(1,Nk);
    dDapdkc{l+Nk}=0;
    dCdkc{l+Nk}=zeros(1,Nk);
    dCdkc{l+Nk}(l)=p(l);
    dDdkc{l+Nk}=0;
  endfor
  dAdkc{Nkc}=zeros(Nk,Nk);
  dBdkc{Nkc}=zeros(Nk,1);
  dCapdkc{Nkc}=zeros(1,Nk);
  dDapdkc{Nkc}=0;
  dCdkc{Nkc}=zeros(1,Nk);
  dDdkc{Nkc}=1;
  
endfunction
