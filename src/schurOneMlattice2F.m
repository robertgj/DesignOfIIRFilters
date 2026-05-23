function F=schurOneMlattice2F(k,epsilon,p,c)
% F=schurOneMlattice2F(k,epsilon,p,c)
% Returns cell array F with the factored state variable description (FSVD) of
% a tapped one-multiplier Schur lattice filter with both the tapped and
% all-pass outputs:
%   |xp(1 )|                    |x(1) |
%   |  .   |                    |  .  |
%   |xp(Nk)| = [A,B;Cap,Dap;C,D]|x(Nk)|
%   |yap   |                    |u    | 
%   |y     |
% where [A,B;Cap,Dap;C,D]=F{Nk+1}*...*F{1}.
% P is the state scaling matrix, P=diag([p,1]).
  
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
  
  if (nargin~=4) || (nargout>1)
    print_usage("F=schurOneMlattice2F(k,epsilon,p,c)");
  endif
  if isempty(k)
    error("isempty(k)");
  endif
  if length(k)~=length(epsilon)
    error("length(k)~=length(epsilon)");
  endif
  if length(k)~=length(p)
    error("length(k)~=length(p)");
  endif
  if (length(k)+1)~=length(c)
    error("(length(k)+1)~=length(c)");
  endif
  
  % Find allpass modules F{1} to F{Nk+1}
  Nk=length(k);
  P=[p(:);1];
  F=cell(1,Nk+1);

  F{1}=[[P(1),zeros(1,Nk)]; ...
        [c(1)*P(1),zeros(1,Nk)]; ...
        [zeros(Nk,1),eye(Nk)]];
  for l=1:Nk,
    F{l+1}=eye(Nk+2);
    F{l+1}(l:l+2,l:l+2)=[[-k(l), 0, (1+(k(l)*epsilon(l)))*P(l+1)]/P(l); ...
                         1-(k(l)*epsilon(l)), 0, k(l)*P(l+1); ...
                         0, 1, c(l+1)*P(l+1)];   
  endfor
  
endfunction
