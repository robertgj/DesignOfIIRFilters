function [F,F0,Fl]=schurOneMAPlattice2F(k,epsilon,p)
% F=schurOneMAPlattice2F(k,epsilon,p)
% Returns cell array F representing a factored state-variable description
% of an all-pass Schur one-multiplier lattice
%   |xp(1 )|                |x(1) |
%   |  .   |                |  .  |
%   |xp(Nk)| = [A,B;Cap,Dap]|x(Nk)|
%   | yap  |                | u   | 
% where:
%   [A,B;Cap,Dap] = F{Nk}* ...*F{1}
% and:
%   F{l}=F0{l}+(Fl{l}*k(l))
% where F0{l} and Fl{l} are constant matrixes.
% P is the state scaling matrix, P=diag([p,1]).
%
% If epsilon and/or p are not given, then they are assumed to be ones.

% Copyright (C) 2026 Robert G. Jenssen
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

  if (nargin==0) || (nargin>3) || (nargout==0) || (nargout==2) || (nargout>3)
    print_usage("[F,F0,Fl]=schurOneMlattice2F(k,epsilon,p)");
  endif
  if isempty(k)
    error("isempty(k)");
  endif
  if nargin<2
    epsilon=ones(size(k));
  endif
  if nargin<3
    p=ones(size(k));
  endif
  if length(k)~=length(epsilon)
    error("length(k)~=length(epsilon)");
  endif
  if length(k)~=length(p)
    error("length(k)~=length(p)");
  endif

  % Find allpass modules F{1} to F{Nk+1}
  Nk=length(k);
  P=[p(:);1];
  F=cell(1,Nk+1);
  F{1}=eye(Nk+1);
  F{1}(1,1)=P(1);
  for l=1:Nk,
    F{l+1}=eye(Nk+1);
    F{l+1}(l:l+1,l:l+1)=[-k(l)/P(l), (1+(k(l)*epsilon(l)))*P(l+1)/P(l); ...
                         1-(k(l)*epsilon(l)), k(l)*P(l+1)];
  endfor

  if nargout==3
    % F{l}=F0{l}+(k(l)*Fl{l})
    F0=cell(1,Nk+1);
    F0{1}=eye(Nk+1);
    F0{1}(1,1)=P(1);
    Fl=cell(1,Nk+1);
    Fl{1}=zeros(Nk+1);
    for l=1:Nk,
      F0{l+1}=eye(Nk+1);
      F0{l+1}(l:l+1,l:l+1)=[0, P(l+1)/P(l); ...
                            1, 0];
      Fl{l+1}=zeros(Nk+1);
      Fl{l+1}(l:l+1,l:l+1)=[-1/P(l), epsilon(l)*P(l+1)/P(l); ...
                            -epsilon(l), P(l+1)];
    endfor
  endif
  
endfunction
