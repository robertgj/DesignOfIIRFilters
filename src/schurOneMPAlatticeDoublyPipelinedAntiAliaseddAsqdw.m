function [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
  schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
    (w,A1k,A2k,difference,B1k,B2k)
% [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
%   schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
%    (w,A1k,A2k,difference,B1k,B2k)
%
% Calculate the gradient of the squared-magnitude response and gradients of the
% parallel combination of two Schur one-multiplier all-pass doubly-pipelined
% lattice filters followed by a parallel-allpass anti-aliasing filter.
%
% Inputs:
%  w - column vector of angular frequencies
%  A1k,A2k - doubly-pipelined parallel-allpass filter one-multiplier allpass
%  difference - return the response for the difference of the all-pass filters
%  B1k,B2k - anti-aliasing parallel-allpass filter one-multiplier allpass
%
% Outputs:
%   dAsqdw - the gradient of the squared magnitude response wrt w at w
%   graddAsqdw - the gradients of dAsqdw with respect to k=[A1k,A2k,B1k,B2k]
%   diagHessdAsqdw - diagonal of the Hessian of dAsqdw with respect to k
%   hessdAsqdw - Hessian of dAsqdw with respect to k as a [Nw,Nk,Nk]-matrix

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
if (nargin ~= 6) || (nargout > 4) 
  print_usage("[dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw]= ...\n\
    schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...\n\
      (w,A1k,A2k,difference,B1k,B2k)\n");
endif
if length(w) == 0
  dAsqdw=[]; graddAsqdw=[]; diagHessdAsqdw=[]; hessdAsqdw=[];
  return;
endif

A1k=A1k(:);
A2k=A2k(:);
B1k=B1k(:);
B2k=B2k(:);
NA1k=length(A1k);
NA2k=length(A2k);
NAk=NA1k+NA2k;
NB1k=length(B1k);
NB2k=length(B2k);
NBk=NB1k+NB2k;
Nk=NAk+NBk;
A1ones=ones(size(A1k));
A2ones=ones(size(A2k));
B1ones=ones(size(B1k));
B2ones=ones(size(B2k));
A12ones=ones(1,length(A1k)+length(A2k));
B12ones=ones(1,length(B1k)+length(B2k));

if nargout==1
  A12Asq = schurOneMPAlatticeDoublyPipelinedAsq(w,A1k,A2k,difference);
  B12Asq = schurOneMPAlatticeAsq(w,B1k,B1ones,B1ones,B2k,B2ones,B2ones);
  A12dAsqdw = schurOneMPAlatticeDoublyPipelineddAsqdw(w,A1k,A2k,difference);
  B12dAsqdw = schurOneMPAlatticedAsqdw(w,B1k,B1ones,B1ones,B2k,B2ones,B2ones);
  
  dAsqdw=(A12dAsqdw.*B12Asq)+(A12Asq.*B12dAsqdw);

elseif nargout==2
  [A12Asq,gradA12Asq] = ...
    schurOneMPAlatticeDoublyPipelinedAsq(w,A1k,A2k,difference);
  [B12Asq,gradB12Asq] = ...
    schurOneMPAlatticeAsq(w,B1k,B1ones,B1ones,B2k,B2ones,B2ones);
  [A12dAsqdw,gradA12dAsqdw] = ...
    schurOneMPAlatticeDoublyPipelineddAsqdw(w,A1k,A2k,difference);
  [B12dAsqdw,gradB12dAsqdw] = ...
    schurOneMPAlatticedAsqdw(w,B1k,B1ones,B1ones,B2k,B2ones,B2ones);
  
  kA12Asq = kron(A12Asq,B12ones);
  kA12dAsqdw = kron(A12dAsqdw,B12ones);
  kB12Asq = kron(B12Asq,A12ones);
  kB12dAsqdw = kron(B12dAsqdw,A12ones);
  
  dAsqdw=(A12dAsqdw.*B12Asq)+(A12Asq.*B12dAsqdw);
  graddAsqdw=[gradA12dAsqdw.*kB12Asq, kA12Asq.*gradB12dAsqdw] + ...
             [gradA12Asq.*kB12dAsqdw, kA12dAsqdw.*gradB12Asq];

elseif nargout==3
  [A12Asq,gradA12Asq,diagHessA12Asq] = ...
    schurOneMPAlatticeDoublyPipelinedAsq(w,A1k,A2k,difference);
  [B12Asq,gradB12Asq,diagHessB12Asq] = ...
    schurOneMPAlatticeAsq(w,B1k,B1ones,B1ones,B2k,B2ones,B2ones);
  [A12dAsqdw,gradA12dAsqdw,diagHessA12dAsqdw] = ...
    schurOneMPAlatticeDoublyPipelineddAsqdw(w,A1k,A2k,difference);
  [B12dAsqdw,gradB12dAsqdw,diagHessB12dAsqdw] = ...
    schurOneMPAlatticedAsqdw(w,B1k,B1ones,B1ones,B2k,B2ones,B2ones);

  kA12Asq = kron(A12Asq,B12ones);
  kA12dAsqdw = kron(A12dAsqdw,B12ones);
  kB12Asq = kron(B12Asq,A12ones);
  kB12dAsqdw = kron(B12dAsqdw,A12ones);
  
  dAsqdw = (A12dAsqdw.*B12Asq)+(A12Asq.*B12dAsqdw);
  graddAsqdw = [gradA12dAsqdw.*kB12Asq, kA12Asq.*gradB12dAsqdw] + ...
               [gradA12Asq.*kB12dAsqdw, kA12dAsqdw.*gradB12Asq];
  % gradA12Asq.*gradB12dAsqdw etc. are 0
  diagHessdAsqdw = ...
    [diagHessA12dAsqdw.*kB12Asq, kA12Asq.*diagHessB12dAsqdw] + ...
    [diagHessA12Asq.*kB12dAsqdw, kA12dAsqdw.*diagHessB12Asq];
  
elseif nargout==4
  [A12Asq,gradA12Asq,diagHessA12Asq,hessA12Asq] = ...
    schurOneMPAlatticeDoublyPipelinedAsq(w,A1k,A2k,difference);
  [B12Asq,gradB12Asq,diagHessB12Asq,hessB12Asq] = ...
    schurOneMPAlatticeAsq(w,B1k,B1ones,B1ones,B2k,B2ones,B2ones);
  [A12dAsqdw,gradA12dAsqdw,diagHessA12dAsqdw,hessA12dAsqdw] = ...
    schurOneMPAlatticeDoublyPipelineddAsqdw(w,A1k,A2k,difference);
  [B12dAsqdw,gradB12dAsqdw,diagHessB12dAsqdw,hessB12dAsqdw] = ...
    schurOneMPAlatticedAsqdw(w,B1k,B1ones,B1ones,B2k,B2ones,B2ones);

  kA12Asq = kron(A12Asq,B12ones);
  kA12dAsqdw = kron(A12dAsqdw,B12ones);
  kB12Asq = kron(B12Asq,A12ones);
  kB12dAsqdw = kron(B12dAsqdw,A12ones);
  
  dAsqdw = (A12dAsqdw.*B12Asq)+(A12Asq.*B12dAsqdw);
  graddAsqdw = [gradA12dAsqdw.*kB12Asq, kA12Asq.*gradB12dAsqdw] + ...
               [gradA12Asq.*kB12dAsqdw, kA12dAsqdw.*gradB12Asq];
  diagHessdAsqdw = ...
    [diagHessA12dAsqdw.*kB12Asq, kA12Asq.*diagHessB12dAsqdw] + ...
    [diagHessA12Asq.*kB12dAsqdw, kA12dAsqdw.*diagHessB12Asq];
  
  hessdAsqdw=zeros(length(w),Nk,Nk);
  for l=1:length(w),
    hessdAsqdw(l,:,:) = ...
        [squeeze(hessA12dAsqdw(l,:,:)*B12Asq(l)), zeros(NAk,NBk); ...
         zeros(NBk,NAk), A12Asq(l)*squeeze(hessB12dAsqdw(l,:,:))] + ...
        [squeeze(hessA12Asq(l,:,:)*B12dAsqdw(l)), zeros(NAk,NBk) ; ...
         zeros(NBk,NAk), A12dAsqdw(l)*squeeze(hessB12Asq(l,:,:))];
  endfor
  
endif    

endfunction
