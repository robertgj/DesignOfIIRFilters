function [y,yu,yl]=flt2SD(x,nbits,ndigits,verbose)
% [y,yu,yl]=flt2SD(x,nbits,ndigits[,verbose])
% Convert an array of floating point numbers to values
% corresponding to nbits signed-digit numbers with ndigits
% non-zero ternary digits from {-1,0,1}. The elements of x are
% expected, but not required, to have -1<=x<=1. They are
% scaled to -2^(nbits-1) <= scaled_x <= 2^(nbits-1) before
% conversion by bin2SD(). The output is scaled back to -1<=x<=1.
% In other words, x is allowed to have abs(x)>1 with a mantissa
% of nbits binary digits and an implicit positive exponent.
  
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
  if ((nargout~=1) && (nargout~=3)) || ((nargin~=3) && (nargin~=4))
    print_usage("[y,yu,yl]=flt2SD(x,nbits,ndigits[,verbose])");
  endif
  if nargin==3
    verbose=false;
  endif
  max_nbits=floor(log2(flintmax())-2);
  if ~isscalar(nbits) && (any(size(x) ~= size(nbits)))
    error("Expect nbits to be a scalar or size(x) == size(nbits)");
  endif
  if (nbits<=0) || (nbits>max_nbits)
    error("Expected 0<nbits(%d)<=%d",nbits,max_nbits);
  endif
  if any(ndigits<0) || any(nbits<ndigits)
    error("Expected 0<ndigits<=nbits(%d)",nbits);
  endif
  if ~isscalar(ndigits) && (any(size(x) ~= size(ndigits)))
    error("Expect ndigits to be a scalar or size(x) == size(ndigits)");
  endif
  if ~isscalar(verbose)
    error("Expect verbose to be a scalar");
  endif

  % nbits, ndigits and verbose must have the same size as x or all be scalars
  if ~isscalar(nbits) || ~isscalar(ndigits)
    if isscalar(nbits)
      nbits=nbits*ones(size(x));
    endif
    if isscalar(ndigits)
      ndigits=ndigits*ones(size(x));
    endif
  endif

  % A hack to allow -1<=x<=1 by changing the sign of x for x>0
  xsign=(-(x>0))+(x<=0);
  xx=x.*xsign;

  % Scale xx to 2^(nbits-1)<= xx <=0
  nshift=2.^(nbits-1);
  nextra=x2nextra(xx,nshift);
  nscale=nshift./(2.^nextra);
  xxx=xx.*nscale;
  
  % Convert xxx to signed-digit representation and floating point equivalent
  y=arrayfun(@bin2SD,xxx,nbits,ndigits,"ErrorHandler",@bin2SD_error_handler);
  y=y./nscale;
  % Restore sign
  y=y.*xsign; 

  % Find bounds
  if nargout==3
    [yu_tmp,yl_tmp]=arrayfun(@bin2SDul,xxx,nbits,ndigits, ...
                     "ErrorHandler",@bin2SD_error_handler);
    yu_tmp=yu_tmp./nscale;
    yl_tmp=yl_tmp./nscale;
    % Restore sign
    yu_tmp=yu_tmp.*xsign;
    yl_tmp=yl_tmp.*xsign;
    % Reverse the sign hack
    yu=max(yu_tmp,yl_tmp);
    yl=min(yu_tmp,yl_tmp);
  endif
  
  % Done
  if verbose
    printf("flt2SD:converted x=[");printf("%g ",x);printf("] to ");
    printf("y=[");printf("%g ",y);printf("], ");
    printf("y.*nshift=[");printf("%d ",y.*nshift);printf("]\n");
    if nargout==3
      printf("yu=[");printf("%g ",yu);printf("], ");
      printf("yu.*nshift=[");printf("%d ",yu.*nshift);printf("]\n"); 
      printf("yl=[");printf("%g ",yl);printf("], ");
      printf("yl.*nshift=[");printf("%d ",yl.*nshift);printf("]\n");
    endif
    printf("\n");
  endif
  
endfunction

function y=bin2SD_error_handler(S,x,nbits,ndigits)
  fprintf(stderr,"\n\nbin2SD_error_handler():\n");
  fprintf(stderr,"S.identifier=%s\n",S.identifier);
  fprintf(stderr,"S.message=%s\n",S.message);
  fprintf(stderr,"S.index=%d\n",S.index);
  fprintf(stderr,"x=[");
  fprintf(stderr,"%g ",x);
  fprintf(stderr,"]\n");
  fprintf(stderr,"nbits=[");
  fprintf(stderr,"%d ",nbits);
  fprintf(stderr,"]\n");
  fprintf(stderr,"ndigits=[");
  fprintf(stderr,"%d ",ndigits);
  fprintf(stderr,"]\n");
endfunction
