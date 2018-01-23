function [hM,socp_iter,func_iter,feasible]=directFIRhilbert_mmsePW ...
           (vS,hM0,hM_active,na,wa,Ad,Adu,Adl,Wa,maxiter,tol,verbose)
% [hM,socp_iter,func_iter,feasible]=directFIRhilbert_mmsePW ...
%  (vS,hM0,hM_active,na,wa,Ad,Adu,Adl,Wa,maxiter,tol,verbose)
% MMSE optimisation of a direct-form, order 4M FIR Hilbert filter with
% constraints on the amplitude response. The desired amplitude response
% is assumed to be piece-wise constant with band-edges at the indices
% na in the array of angular frequencies, wa.
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au}
%   hM0 - initial M distinct hilbert FIR polynomial coefficients
%   hM_active - not used (for compatibility with truncation search)
%   na - indexes of band edges in wa
%   wa - angular frequencies of the amplitude response
%   Ad - the desired amplitude response
%   Adu,Adl - upper/lower mask for the desired amplitude response
%   Wa - amplitude response weight at each frequency
%
% Outputs:
%   hM - filter design
%   socp_iter,func_iter - not used (for compatibility with directFIRhilbert_slb)
%   feasible - true if the design satisfies the constraints

% Copyright (C) 2017,2018 Robert G. Jenssen
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

  if (nargin ~= 12) || (nargout ~= 4)
    print_usage ...
      ("[hM,socp_iter,func_iter,feasible]=directFIRhilbert_mmsePW ...\n\
                (vS,hM0,hM_active,na,wa,Ad,Adu,Adl,Wa,maxiter,tol,verbose)");
  endif
  
  %
  % Sanity checks on coefficient vectors
  %
  hM0=hM0(:);
  if isempty(hM0)
    error("hM0 empty");
  endif
  
  %
  % Sanity checks on frequency response vectors
  %
  wa=wa(:);
  Nwa=length(wa);
  Ad=Ad(:);
  Adu=Adu(:);
  Adl=Adl(:);
  if isempty(wa)
    error("wa empty");
  endif
  if Nwa ~= length(Ad)
    error("Expected length(wa)(%d) == length(Ad)(%d)",Nwa,length(Ad));
  endif
  if Nwa ~= length(Adu)
    error("Expected length(wa)(%d) == length(Adu)(%d)",Nwa,length(Adu));
  endif
  if Nwa ~= length(Adl)
    error("Expected lenth(wa)(%d) == length(Adl)(%d)",Nwa,length(Adl));
  endif
  if Nwa ~= length(Wa)
    error("Expected length(wa)(%d) == length(Wa)(%d)",Nwa,length(Wa));
  endif
  if any(na>Nwa)
    error("na>Nwa");
  endif
  if isempty(vS)
    vS=directFIRhilbert_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 2) || ...
         (all(isfield(vS,{"al","au"}))==false)
    error("numfields(vS)=%d, expected 2 (al,au)",numfields(vS));
  endif
  if any(vS.al>Nwa)
    error("vS.al>Nwa");
  endif
  if any(vS.au>Nwa)
    error("vS.au>Nwa");
  endif

  %
  % Initialise
  %
  hM=[];
  socp_iter=0;
  func_iter=0;
  feasible=false;
  
  %
  % Find the gradient of the mean-squared-error
  %
  % nb contains the locations of values in the piece-wise constant bands
  nb=na(1:(end-1))+1;
  [~,~,Q,q]=directFIRhilbertEsqPW(hM0,wa(na),Ad(nb),Wa(nb));
  
  %
  % Find the amplitude gradients at the constraint frequencies
  %
  [~,gradAl]=directFIRhilbertA(wa(vS.al),hM0);
  [~,gradAu]=directFIRhilbertA(wa(vS.au),hM0);
  
  %
  % Solve for the hM coefficients. The matrix equation is:
  %    _    _ _ _   _ _
  %    |Q G'| |h|   |C|
  %    |G 0 |*|l| = |D| 
  %    -    - - -   - -
  % Where h is the column vector of coefficients and l is the
  % column vector of Lagrange multipliers. 
  G=[gradAl;gradAu];
  b=[-2*q';Adl(vS.al);Adu(vS.au)];
  A=[2*Q,G';G,zeros(rows(G))];
  if rank(A) ~= rows(A)
    hM=[];
    warning("rank(A) ~= rows(A)");
    return;
  endif
  x=A\b;
  hM=x(1:length(hM0));
  feasible=true;

endfunction
