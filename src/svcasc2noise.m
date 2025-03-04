function [ng,hl2,xbits]=svcasc2noise(a11,a12,a21,a22,b1,b2,c1,c2,dd)
% [ng,hl2,xbits]=svcasc2noise(a11,a12,a21,a22,b1,b2,c1,c2,dd)
% svcasc2noise returns the section round-off noise gains, ng, and
% the section-to-output roundoff noise gains, hl2, and the optimum
% fractional extra number of bits per section, xbits, for a cascade of
% second order state variable sections.

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

  if nargin ~= 9
    print_usage("[ng,hl2,xbits]=svcasc2noise(a11,a12,a21,a22,b1,b2,c1,c2,dd)");
  endif
  sections=length(dd);
  if sections ~= length(a11) || sections ~= length(a12) || ...
     sections ~= length(a21) || sections ~= length(a22) || ...
     sections ~= length(b1)  || sections ~= length(b2)  || ...
     sections ~= length(c1)  || sections ~= length(c2)  || ...
     sections ~= length(b1)  || sections ~= length(b2)
    error("Expect section coefficient vectors to have equal length!");
  endif

  % Find the overall covariance matrixes
  [A,B,C,D]=svcasc2Abcd(a11,a12,a21,a22,b1,b2,c1,c2,dd);
  if rows(A) == ((2*sections)-1)
    % An odd order filter. Add an unused state.
    A=[A,zeros((2*sections)-1,1);zeros(1,2*sections)];
    B=[B;0];
    C=[C,0];
  endif
  [K,W]=KW(A,B,C,D);
    
  % Find the state roundoff noise to output noise gain by section
  ng=zeros(1,sections);
  for k=1:sections
    Ak=[a11(k), a12(k); a21(k), a22(k)];
    bk=[b1(k); b2(k)];
    ck=[c1(k), c2(k)];
    ddk=dd(k);
    l=(2*k)-1;
    Kk=K(l:l+1,l:l+1);
    Wk=W(l:l+1,l:l+1);
    ng(k)=sum(diag(Kk).*diag(Wk));
  endfor

  % Find the non-state roundoff noise variance due to cascaded
  % filtering of output roundoff noise of each section
  hl2=ones(1,sections);
  for k=1:(sections-1)
    [Ak,Bk,Ck,Dk]=svcasc2Abcd(a11((k+1):sections),a12((k+1):sections),
                              a21((k+1):sections),a22((k+1):sections), ...
                              b1((k+1):sections),b2((k+1):sections), ...
                              c1((k+1):sections),c2((k+1):sections), ...
                              dd((k+1):sections));
    [Kk,Wk]=KW(Ak,Bk,Ck,Dk);
    hl2(k)=Dk*Dk+Ck*Kk*Ck';
  end

  % Find the optimal fractional extra number of bits per section
  xbits = 0.5*(log2(ng)-mean(log2(ng)));
  
endfunction
