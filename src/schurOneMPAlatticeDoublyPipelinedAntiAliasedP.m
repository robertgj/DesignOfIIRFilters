function [P,gradP,diagHessP,hessP] = ...
  schurOneMPAlatticeDoublyPipelinedAntiAliasedP(w,A1k,A2k,difference,B1k,B2k)
% [P,gradP,diagHessP,hessP] = ...
%   schurOneMPAlatticeDoublyPipelinedAntiAliasedP(w,A1k,A2k,difference,B1k,B2k)
%
% Calculate the phase response and gradients of the parallel
% combination of two Schur one-multiplier all-pass doubly-pipelined lattice
% filters followed by a parallel-allpass anti-aliasing filter.
%
% Inputs:
%  w - column vector of angular frequencies
%  A1k,A2k - doubly-pipelined parallel-allpass filter one-multiplier allpass
%  difference - return the response for the difference of the all-pass filters
%  B1k,B2k - anti-aliasing parallel-allpass filter one-multiplier allpass
%
% Outputs:
%   P - the phase response at w
%   gradP - the gradients of P with respect to k=[A1k,A2k,B1k,B2k]
%   diagHessP - diagonal of the Hessian of P with respect to k
%   hessP - Hessian of P with respect to k as a [Nw,Nk,Nk]-matrix

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
  print_usage("[P,gradP,diagHessP,hessP]= ...\n\
    schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...\n\
      (w,A1k,A2k,difference,B1k,B2k)\n");
endif
if length(w) == 0
  P=[]; gradP=[]; diagHessP=[]; hessP=[];
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
  A12P = schurOneMPAlatticeDoublyPipelinedP(w,A1k,A2k,difference);
  B12P = schurOneMPAlatticeP(w,B1k,B1ones,B1ones,B2k,B2ones,B2ones);
  
  P=A12P+B12P;

elseif nargout==2
  [A12P,gradA12P] = ...
    schurOneMPAlatticeDoublyPipelinedP(w,A1k,A2k,difference);
  [B12P,gradB12P] = ...
    schurOneMPAlatticeP(w,B1k,B1ones,B1ones,B2k,B2ones,B2ones);
  
  P=A12P+B12P;
  gradP=[gradA12P,gradB12P];

elseif nargout==3
  [A12P,gradA12P,diagHessA12P] = ...
    schurOneMPAlatticeDoublyPipelinedP(w,A1k,A2k,difference);
  [B12P,gradB12P,diagHessB12P] = ...
    schurOneMPAlatticeP(w,B1k,B1ones,B1ones,B2k,B2ones,B2ones);
  
  P=A12P+B12P;
  gradP=[gradA12P,gradB12P];
  diagHessP=[diagHessA12P,diagHessB12P];
  
elseif nargout==4
  [A12P,gradA12P,diagHessA12P,hessA12P] = ...
    schurOneMPAlatticeDoublyPipelinedP(w,A1k,A2k,difference);
  [B12P,gradB12P,diagHessB12P,hessB12P] = ...
    schurOneMPAlatticeP(w,B1k,B1ones,B1ones,B2k,B2ones,B2ones);
  
  P=A12P+B12P;
  gradP=[gradA12P,gradB12P];
  diagHessP=[diagHessA12P,diagHessB12P];

  hessP=zeros(length(w),Nk,Nk);
  hessP(:,1:NAk,1:NAk) = hessA12P;
  hessP(:,NAk+(1:NBk),NAk+(1:NBk)) = hessB12P;

endif    

endfunction
