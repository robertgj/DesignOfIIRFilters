function [A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
          d2Adydx,d2Bdydx,d2Capdydx,d2Dapdydx]= ...
           schurOneMAPlattice2Abcd(k,epsilon,p)
% [A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk,d2Adydx,d2Bdydx,d2Capdydx,d2Dapdydx]= ...
%   schurOneMAPlattice2Abcd(k,epsilon,p)
% Find the state variable representation of an all-pass Schur one-multiplier
% lattice filter. (Note that here the state scaling vector, p, is assumed to
% be fixed. In fact it is calculated from k when the design is complete).
%
% Inputs:
%  k       - the lattice filter one-multiplier coefficients
%  epsilon - the sign coefficients for each module
%  p       - the state scaling factors
% Outputs:
%  [A,B;Cap,Dap]           - state variable description of the lattice filter
%  dAdk,dBdk,dCapdk,dDapdk - cell vectors of the differentials of A,B,Cap and Dap
%  d2Adydx,d2Bdydx,d2Capdydx,d2Dapdydx - cell vectors of the second differentials

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
  if nargin<1 || nargin>3 || nargout<4
    print_usage ...
      (["[A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...\n", ...
 " d2Adydx,d2Bdydx,d2Capdydx,d2Dapdydx]=schurOneMAPlattice2Abcd(k,epsilon,p)"]);
  endif
  if nargin<2
    epsilon=ones(size(k));
  endif
  if nargin<3
    p=ones(size(k));
  endif
  if (length(k)~=length(epsilon)) || (length(k)~=length(p))
    error("Input vector lengths inconsistent!");
  endif

  % Initialise dummy tap coefficients, c
  Nk=length(k);
  cdummy=zeros(1,Nk+1);
  if isrow(k)
    cdummy=transpose(cdummy);
  endif

  if nargout<=4
    % Find the state variable matrixes
    [A,B,~,~,Cap,Dap] = schurOneMlattice2Abcd(k,epsilon,p,cdummy);
  elseif nargout<=8
    [A,B,~,~,Cap,Dap,dAdkc,dBdkc,~,~,dCapdkc,dDapdkc]=...
       schurOneMlattice2Abcd(k,epsilon,p,cdummy);
  else
    [A,B,~,~,Cap,Dap,dAdkc,dBdkc,~,~,dCapdkc,dDapdkc, ...
     d2Adkdc,d2Bdkdc,~,~,d2Capdkdc,d2Dapdkdc]=...
       schurOneMlattice2Abcd(k,epsilon,p,cdummy);
  endif

  if nargout>4
    % Remove the gradients of c
    dAdk=cell(1,Nk);
    dBdk=cell(1,Nk);
    dCapdk=cell(1,Nk);
    dDapdk=cell(1,Nk);
    for m=1:Nk
      dAdk{m}=dAdkc{m}(1:Nk,1:Nk);
      dBdk{m}=dBdkc{m}(1:Nk,1);
      dCapdk{m}=dCapdkc{m}(1,1:Nk);
      dDapdk{m}=dDapdkc{m}(1,1);
    endfor
  endif
  
  if nargout>8
    % Remove the gradients of c
    d2Adydx=cell(Nk,Nk);
    d2Bdydx=cell(Nk,Nk);
    d2Capdydx=cell(Nk,Nk);
    d2Dapdydx=cell(Nk,Nk);
    for m=1:Nk
      for n=1:Nk
      d2Adydx{m,n}=d2Adkdc{m,n}(1:Nk,1:Nk);
      d2Bdydx{m,n}=d2Bdkdc{m,n}(1:Nk,1);
      d2Capdydx{m,n}=d2Capdkdc{m,n}(1,1:Nk);
      d2Dapdydx{m,n}=d2Dapdkdc{m,n}(1,1);
      endfor
    endfor
  endif
    
endfunction
