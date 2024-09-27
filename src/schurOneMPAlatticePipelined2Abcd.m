function [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=schurOneMPAlatticePipelined2Abcd ...
    (A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk,difference)
% [A,B,C,D,dAdx,dBdx,dCdx,dDdx] = schurOneMPAlatticePipelined2Abcd ...
%  (A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk,difference)
%
% Find the state variable description of the parallel combination of two Schur
% one-multiplier pipelined all-pass lattice filters.
%
% Nominally, A1kk=A1k(1:(end-1)).*A1k(2:end), A2kk=A2k(1:(end-1)).*A2k(2:end)
% If not, then the actual individual filter responses may not be all-pass.
%
% Inputs:
%   w - column vector of angular frequencies
%   A1k,A1epsilon,A1kk - filter 1 one-multiplier allpass section coefficients
%   A2k,A1epsilon,A2kk - filter 2 one-multiplier allpass section coefficients
%   difference - return the response for the difference of the all-pass filters
% Outputs:
%   [A,B;C,D] - the state variable description
%   dAdx, etc - the derivatives of the state variable matrixes wrt
%                 x=[A1k(:);A1kk(:);A2k(:);A2kk(:)]

% Copyright (C) 2024 Robert G. Jenssen
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

  %
  % Sanity checks
  %
  if ((nargin ~= 6) && (nargin ~= 7)) || ((nargout ~= 4) && (nargout ~= 8)) 
    print_usage("[A,B,C,D] = schurOneMPAlatticePipelined2Abcd ...\n\
  (A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk)\n\
[A,B,C,D,dAdx,dBdx,dCdx,dDdx] = schurOneMPAlatticePipelined2Abcd ...\n\
  (A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk,difference)");
  endif
  if nargin == 6
    difference = false;
  endif
  if length(A1k) ~= length(A1epsilon)
    error("length(A1k) ~= length(A1epsilon)");
  endif
  if length(A1k) ~= length(A1kk)+1
    error("length(A1k) ~= length(A1kk)+1");
  endif
  if length(A2k) ~= length(A2epsilon)
    error("length(A2k) ~= length(A2epsilon)");
  endif
  if length(A2k) ~= length(A2kk)+1
    error("length(A2k) ~= length(A2kk)+1");
  endif

  A1Nk=length(A1k);
  A1Nkk=length(A1kk);
  A2Nk=length(A2k);
  A2Nkk=length(A2kk);

  if nargout == 4
    [A1Aap,A1Bap,A1Cap,A1Dap]= ...
       schurOneMAPlatticePipelined2Abcd(A1k,A1epsilon,A1kk);
    [A2Aap,A2Bap,A2Cap,A2Dap]= ...
      schurOneMAPlatticePipelined2Abcd(A2k,A2epsilon,A2kk);
  elseif nargout == 8
    [A1Aap,A1Bap,A1Cap,A1Dap,A1dAapdx,A1dBapdx,A1dCapdx,A1dDapdx]=...
      schurOneMAPlatticePipelined2Abcd(A1k,A1epsilon,A1kk);
    [A2Aap,A2Bap,A2Cap,A2Dap,A2dAapdx,A2dBapdx,A2dCapdx,A2dDapdx]=...
      schurOneMAPlatticePipelined2Abcd(A2k,A2epsilon,A2kk);
  endif    
   
  if difference
    mm=-1;
  else
    mm=1;
  endif

  A=[A1Aap,zeros(A1Nk,A2Nk);zeros(A2Nk,A1Nk),A2Aap];
  B=[A1Bap;A2Bap];
  C=0.5*[A1Cap,mm*A2Cap];
  D=0.5*(A1Dap+(mm*A2Dap));
  
  if nargout == 4
    return;
  endif

  dAdx=cell(1,A1Nk+A1Nkk+A2Nk+A2Nkk);
  for s=1:(A1Nk+A1Nkk)
    dAdx{s}=[A1dAapdx{s},zeros(A1Nk,A2Nk);zeros(A2Nk,A1Nk+A2Nk)];
  endfor
  for s=1:(A2Nk+A2Nkk)
    dAdx{A1Nk+A1Nkk+s}=[zeros(A1Nk,A1Nk+A2Nk);zeros(A2Nk,A1Nk),A2dAapdx{s}];
  endfor
  
  dBdx=cell(1,A1Nk+A1Nkk+A2Nk+A2Nkk);
  for s=1:(A1Nk+A1Nkk)
    dBdx{s}=[A1dBapdx{s};zeros(A2Nk,1)];
  endfor
  for s=1:(A2Nk+A2Nkk)
    dBdx{A1Nk+A1Nkk+s}=[zeros(A1Nk,1);A2dBapdx{s}];
  endfor
  
  dCdx=cell(1,A1Nk+A1Nkk+A2Nk+A2Nkk);
  for s=1:(A1Nk+A1Nkk)
    dCdx{s}=[0.5*A1dCapdx{s},zeros(1,A2Nk)];
  endfor 
  for s=1:(A2Nk+A2Nkk)
    dCdx{A1Nk+A1Nkk+s}=[zeros(1,A1Nk),0.5*mm*A2dCapdx{s}];
  endfor 
  
  dDdx=cell(1,A1Nk+A1Nkk+A2Nk+A2Nkk);
  for s=1:(A1Nk+A1Nkk)
    dDdx{s}=0.5*A1dDapdx{s};
  endfor 
  for s=1:(A2Nk+A2Nkk)
    dDdx{A1Nk+A1Nkk+s}=0.5*mm*A2dDapdx{s};
  endfor 
  
endfunction
