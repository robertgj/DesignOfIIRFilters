function [cof,cost,fiter] = ...
  bitflip(pcostfun,cof0,nbits,bitstart,msize,verbose,testcof)
% [cof,cost,fiter]=bitflip(pcostfun,cof0,nbits,bitstart,msize[,verbose,testcof])
%
% Bit-flipping algorithm for optimising the coefficients
% of a digital filter. This implementation uses the bitand()
% etc functions. Those functions assume that the coefficients
% are non-negative binary integers and that the LSB is bit 1.
%
% Inputs:
%   pcostfun - pointer to a function: "cost=pcostfun(cof)"
%   cof0 - initial coefficients with 0 <= cof0(k) < 2^nbits
%   nbits - number of bits in the coefficients
%   bitstart - first bit to alter with msize <= bitstart <= nbits
%   msize - 0 < mask size <= nbits (number of bits changed) 
%   verbose - optional
%   testcof - During testing, only flip this coefficient. Optional.
% Outputs:
%   cof - optimised coefficients
%   cost - cost for optimised coefficients
%   fiter - number of cost function iterations
%
% See "Two Approaches for fixed-point filter design: 'bit-flipping'
% algorithm and constrained down-hill Simplex method", A.Krukowski 
% and I.Kale, Proceedings ISSPA99, pp. 965-968.

% Copyright (C) 2017 Robert G. Jenssen
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

  warning("Using Octave m-file version of function bitflip()!");
  
  % Sanity checks
  if (nargin < 5) || (nargin > 7)
    print_usage("[cof,cost,fiter]=bitflip(pcostfun,cof0, ...\n\
                 nbits,bitstart,msize\[,verbose,testcof])");
  endif
  if nargin == 5
    verbose=false;
    do_testcof=false;
    testcof=-1;
  elseif nargin == 6
    do_testcof=false;
    testcof=-1;
  elseif nargin == 7
    do_testcof=true;
  endif
  if !is_function_handle(pcostfun)
    error("Expected function handle");
  endif
  max_nbits=floor(log2(flintmax()));
  if (nbits < 1) || (nbits > max_nbits)
    error("Expect 1 <= nbits(%d) <= max_nbits(%d)",nbits,max_nbits);
  endif
  if (bitstart < 1) || (bitstart > nbits)
    error("Expect 1 <= bitstart(%d) <= nbits(%d)",bitstart,nbits);
  endif
  if (msize < 1) || (msize > bitstart)
    error("Expect 1 <= msize(%d) <= bitstart(%d)",msize,bitstart);
  endif
  if do_testcof == true && ((testcof<1) || testcof>length(cof0))
    error("Invalid testcof(%d) of cof0(length %d)",testcof,length(cof0));
  endif

  % Initialise outputs
  cof=cof0(:)';
  cost=feval(pcostfun,cof0);
  fiter=0;
  if verbose
    printf("bitflip:initial cost=%g\n",cost);
  endif

  % Bit-flipping loop moving the mask from bitstart down to msize
  for bit=bitstart:-1:msize
    while true
      OK=false;
      mask_step=2^(bit-msize);
      mask_end=mask_step*((2^msize)-1);
      mask=bitxor(mask_end,(2^nbits)-1);
      % Loop over all coefficients
      for k=1:length(cof0)
        if do_testcof && (k ~= testcof)
          continue
        endif
        % Bit-flip within the mask
        newcof=cof;
        newcofkmask=bitand(cof(k),mask);
        for l=0:mask_step:mask_end
          % Make new coefficient
          newcof(k)= newcofkmask + l;
          % Calculate cost function
          newcost=feval(pcostfun,newcof);
          fiter=fiter+1;
          if newcost < cost 
            if verbose
              printf("bitflip:cof(%d)=0x%x:cost %f>%f for 0x%x\
(mask=0x%x,l=0x%x,bit=%d)\n",k,cof(k),cost,newcost,newcof(k),mask,l,bit);
            endif
            cost=newcost;
            cof(k)=newcof(k);
            OK=true;
          endif
        endfor
      endfor

      % No further improvement at this level
      if OK == false
        break;
      endif
    endwhile

  endfor

  if verbose
    printf("bitflip:final cost=%g,fiter=%d\n",cost,fiter);
  endif
  
endfunction
