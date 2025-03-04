function X=fixResultNaN(X)
% X=fixResultNaN(X)
% Set NaN to 0 in results from iirA, iirT and iirP

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

  [m,n,l]=size(X);
  ndim=sum([m,n,l]>1); 
  if ndim==0
    if isnan(X)
      X=0;
    endif
  elseif ndim==1
    if any(isnan(X))
      iw=find(isnan(X));
      X(iw)=0;
    endif
  elseif ndim==2
    if any(any(isnan(X)))
      [row,col]=find(isnan(X));
      for p=1:length(row)
        X(row(p),col(p))=0;
      endfor
    endif
  elseif ndim==3
    if any(any(any(isnan(X))))
      for k=1:m
        if any(any(isnan(X(k,:,:))))
          aX=X(k,:,:);
          [row,col]=find(isnan(aX));
          for p=1:length(row)
            aX(row(p),col(p))=0;
          endfor
          X(k,:,:)=aX;
        endif
      endfor
    endif
  endif

endfunction
