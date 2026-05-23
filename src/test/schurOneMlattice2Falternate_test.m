% schurOneMlattice2Falternate_test.m
% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="schurOneMlattice2Falternate_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

function F=schurOneMlattice2Falternate(k,epsilon,p,c)
% F=schurOneMlattice2Falternate(k,epsilon,p,c)
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
  
  if (nargin~=4) || (nargout>3)
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
  
  % Find modules F{1} to F{(2*Nk)+1}
  Nk=length(k);
  P=[p(:);1];
  CS1=circshift(eye(Nk+2),[0,1]);
  CS3=circshift(eye(Nk+2),[0,3]);
  F=cell(1,(2*Nk)+1);

  F{1}=[[P(1),zeros(1,Nk)]; ...
        [c(1)*P(1),zeros(1,Nk)]; ...
        [zeros(Nk,1),eye(Nk)]];

  for l=1:Nk,
    F{2*l}=eye(Nk+2);
    F{2*l}(1:3,1:3)=[[-k(l), 0, (1+(k(l)*epsilon(l)))*P(l+1)]/P(l); ...
                     1-(k(l)*epsilon(l)), 0, k(l)*P(l+1); ...
                     0, 1, c(l+1)*P(l+1)];
    if l < Nk
      F{(2*l)+1}=CS1;
    else
      F{(2*l)+1}=CS3;
    endif
  endfor
  
endfunction


fap=0.1;fas=0.25;dBap=1;dBas=20;tol=10*eps;

for Nk=1:7,
  
  %
  % Create a filter
  %
  [n,d]=ellip(Nk,dBap,dBas,2*fap);
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);

  for w=1:3
    if w==1
      [A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,ones(size(k)),ones(size(k)),c);
      F=schurOneMlattice2Falternate(k,ones(size(k)),ones(size(k)),c);
    elseif w==2
      [A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,ones(size(k)),c);
      F=schurOneMlattice2Falternate(k,epsilon,ones(size(k)),c);
    else
      [A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c);
      F=schurOneMlattice2Falternate(k,epsilon,p,c);
    endif
    % Sanity checks
    if length(F) ~= (2*Nk)+1
      error("length(F) ~= (2*Nk)+1");
    endif
    
    ABCapDapCD=F{1};
    for l=2:length(F),
      ABCapDapCD=F{l}*ABCapDapCD;
    endfor
    
    if max(max(abs(ABCapDapCD-[A,B;Cap,Dap;C,D]))) > tol
      error("max(max(abs(ABCapDapCD-[A,B;Cap,Dap;C,D]))) > tol");
    endif

  endfor
  
  ABCD=ABCapDapCD([1:Nk,Nk+2],:);
  ABCapDap=ABCapDapCD(1:(Nk+1),:);
    
  % Tapped lattice
  [ntl,dtl]=Abcd2tf(ABCD(1:Nk,1:Nk),ABCD(1:Nk,Nk+1), ...
                    ABCD(Nk+1,1:Nk),ABCD(Nk+1,Nk+1));
  if max(max(abs(n-ntl))) > tol
    error("max(max(abs(n-ntl))) > tol");
  endif
  if max(max(abs(d-dtl))) > tol
    error("max(max(abs(d-dtl))) > tol");
  endif
  
  % All-pass lattice
  [nap,dap]=Abcd2tf(ABCapDap(1:Nk,1:Nk),ABCapDap(1:Nk,Nk+1), ...
                    ABCapDap(Nk+1,1:Nk),ABCapDap(Nk+1,Nk+1));
  if max(max(abs(d-fliplr(nap)))) > tol
    error("max(max(abs(d-fliplr(nap)))) > tol");
  endif
  if max(max(abs(d-dap))) > tol
    error("max(max(abs(d-dap))) > tol");
  endif
  
endfor

%
% Done
%
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
