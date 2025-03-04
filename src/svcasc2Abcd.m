function [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=...
  svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1,c2,dd)
% [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1,c2,dd)
% Find the state variable equations and gradients of a cascade of second order
% sections. The resulting matrix is ordered with the first section
% (a11(1), a12(1) etc) at the cascade input. If the order is odd then the
% last section is first order.
%
% For two sections the cascaded state variable equations are:
%   x1'=A1*x1+B1*u
%   y1 =C1*x1+D1*u
%   x2'=A2*x2+B2*y1
%   y2 =C2*x2+D2*y1
% In expanded form:
%   x1'=   A1*x1 + 0*x2 +   B1*u
%   x2'=B2*C1*x1 +A2*x2 +B2*D1*u
%   y2 =D2*C1*x1 +C2*x2 +D2*D1*u
% or:
%   _  _    _     _   _     _  __
%   |x1'|= |1 0  0 | |A1 0 B1||x1|
%   |x2'|= |0 A2 B2|*|0  1 0 ||x2|
%   |y2'|= |0 C2 D2| |C1 0 D1||u |
%   -   -  -       - -       --  -
%
% The gradients are ordered by section:
%    dAda11(1),dAda12(1),dAda21(1),dAda22(1),dBdb(1) etc.
%
% An odd order filter will have a surplus row in the state-transition matrix.
% This function will attempt to remove that row but it may fail to do so when
% the the state-variable cascade second-order sections are not in direct form.

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
  if nargin ~= 9
    print_usage...
("[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1,c2,dd)");
  endif
  sections=length(dd);
  if sections ~= length(a11) || sections ~= length(a12) || ...
     sections ~= length(a21) || sections ~= length(a22) || ...
     sections ~= length(b1)  || sections ~= length(b2)  || ...
     sections ~= length(c1)  || sections ~= length(c2)  || ...
     sections ~= length(b1)  || sections ~= length(b2)
    error("Expect section coefficient vectors to have equal length!");
  endif
  
  % Cascade matrix combination
  [A,B,C,D]=svcasc2Abcd_loop(a11,a12,a21,a22,b1,b2,c1,c2,dd,0);
  
  % If the 2nd-order state variable sections were derived from an odd
  % order filter then there may be an unused state variable. Remove it.
  zero_column=0;
  for k=1:columns(A)
    if all(A(:,k)==0) && ((C(k)==0) || (B(k)==0))
      zero_column=k;
      A(:,zero_column)=[];
      A(zero_column,:)=[];
      B(zero_column)=[];
      C(zero_column)=[];
      break;
    endif
  endfor
  
  if nargout == 4
    return;
  endif

  % Use brute force to find the gradients of the state variable matrixes
  coef_per_section=nargin;
  dAdx=cell(1,sections*coef_per_section);
  dBdx=cell(1,sections*coef_per_section);
  dCdx=cell(1,sections*coef_per_section);
  dDdx=cell(1,sections*coef_per_section);
  for k=1:sections
    % Initialise this section
    m=(k-1)*coef_per_section;
    d_a11=a11; d_a11(k)=0;
    d_a12=a12; d_a12(k)=0;
    d_a21=a21; d_a21(k)=0;
    d_a22=a22; d_a22(k)=0;
    d_b1=b1;   d_b1(k)=0;
    d_b2=b2;   d_b2(k)=0;
    d_c1=c1;   d_c1(k)=0;
    d_c2=c2;   d_c2(k)=0;
    d_dd=dd;   d_dd(k)=0;
    % a11
    d_a11(k)=1;
    [dAdx{1+m},dBdx{1+m},dCdx{1+m},dDdx{1+m}]=...
      svcasc2Abcd_loop(d_a11,d_a12,d_a21,d_a22,d_b1,d_b2,d_c1,d_c2,d_dd,k);
    d_a11(k)=0;    
    % a12
    d_a12(k)=1;
    [dAdx{2+m},dBdx{2+m},dCdx{2+m},dDdx{2+m}]=...
      svcasc2Abcd_loop(d_a11,d_a12,d_a21,d_a22,d_b1,d_b2,d_c1,d_c2,d_dd,k);
    d_a12(k)=0;
    % a21
    d_a21(k)=1;
    [dAdx{3+m},dBdx{3+m},dCdx{3+m},dDdx{3+m}]=...
      svcasc2Abcd_loop(d_a11,d_a12,d_a21,d_a22,d_b1,d_b2,d_c1,d_c2,d_dd,k);
    d_a21(k)=0;
    % a22
    d_a22(k)=1;
    [dAdx{4+m},dBdx{4+m},dCdx{4+m},dDdx{4+m}]=...
      svcasc2Abcd_loop(d_a11,d_a12,d_a21,d_a22,d_b1,d_b2,d_c1,d_c2,d_dd,k);
    d_a22(k)=0;
    % b1
    d_b1(k)=1;
    [dAdx{5+m},dBdx{5+m},dCdx{5+m},dDdx{5+m}]=...
      svcasc2Abcd_loop(d_a11,d_a12,d_a21,d_a22,d_b1,d_b2,d_c1,d_c2,d_dd,k);
    d_b1(k)=0;
    % b2
    d_b2(k)=1;
    [dAdx{6+m},dBdx{6+m},dCdx{6+m},dDdx{6+m}]=...
      svcasc2Abcd_loop(d_a11,d_a12,d_a21,d_a22,d_b1,d_b2,d_c1,d_c2,d_dd,k);
    d_b2(k)=0;
    % c1
    d_c1(k)=1;
    [dAdx{7+m},dBdx{7+m},dCdx{7+m},dDdx{7+m}]=...
      svcasc2Abcd_loop(d_a11,d_a12,d_a21,d_a22,d_b1,d_b2,d_c1,d_c2,d_dd,k);
    d_c1(k)=0;
    % c2
    d_c2(k)=1;
    [dAdx{8+m},dBdx{8+m},dCdx{8+m},dDdx{8+m}]=...
      svcasc2Abcd_loop(d_a11,d_a12,d_a21,d_a22,d_b1,d_b2,d_c1,d_c2,d_dd,k);
    d_c2(k)=0;
    % dd
    d_dd(k)=1;
    [dAdx{9+m},dBdx{9+m},dCdx{9+m},dDdx{9+m}]=...
      svcasc2Abcd_loop(d_a11,d_a12,d_a21,d_a22,d_b1,d_b2,d_c1,d_c2,d_dd,k);
    d_dd(k)=0;
  endfor
  
  % Remove the unused state
  if zero_column~=0
    for k=1:(sections*coef_per_section)
      dAdx{k}(:,zero_column)=[];
      dAdx{k}(zero_column,:)=[];
      dBdx{k}(zero_column)=[];
      dCdx{k}(zero_column)=[];
    endfor
  endif

endfunction

function [A,B,C,D]=svcasc2Abcd_loop(a11,a12,a21,a22,b1,b2,c1,c2,dd,zk)
  sections=length(dd);
  if zk==1
    ABCDk=zeros((sections*2)+1);
  else
    ABCDk=eye((sections*2)+1);
  endif
  krange=(1:2);
  ABCDk(krange,krange) = [a11(1), a12(1); a21(1), a22(1)];
  ABCDk(krange,end) = [b1(1); b2(1)];
  ABCDk(end,krange) = [c1(1), c2(1)];
  ABCDk(end,end) = dd(1);
  for k=2:sections
    if zk==k
      ABCD_nextk=zeros(size(ABCDk));
    else
      ABCD_nextk=eye(size(ABCDk));
    endif
    krange=krange+2;
    ABCD_nextk(krange,krange) = [a11(k), a12(k); a21(k), a22(k)];
    ABCD_nextk(krange,end) = [b1(k); b2(k)];
    ABCD_nextk(end,krange) = [c1(k), c2(k)];
    ABCD_nextk(end,end)= dd(k);
    ABCDk=ABCD_nextk*ABCDk;
  endfor
  A=ABCDk(1:(end-1),1:(end-1));
  B=ABCDk(1:(end-1),end);
  C=ABCDk(end,1:(end-1));
  D=ABCDk(end,end);
endfunction
