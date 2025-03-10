function [hM,socp_iter,func_iter,feasible]=...
  directFIRsymmetric_mmsePW(vS,hM0,hM_active,na,wa,Ad,Adu,Adl,Wa, ...
                            maxiter,ftol,ctol,verbose)
% [hM,socp_iter,func_iter,feasible]=directFIRsymmetric_mmsePW ...
%  (vS,hM0,hM_active,na,wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose)
% MMSE optimisation of a direct-form symmetric even-order FIR filter with
% constraints on the amplitude response. The desired amplitude response
% is assumed to be piece-wise constant with band-edges at the indices
% na in the array of angular frequencies, wa.
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au}
%   hM0 - initial distinct symmetric FIR polynomial coefficients [h0,...,hM]
%   hM_active - coefficients that are allowed to vary(for truncation search)
%   na - indexes of band edges in wa
%   wa - angular frequencies of the amplitude response
%   Ad - desired amplitude response
%   Adu,Adl - upper/lower mask for the desired amplitude response
%   Wa - amplitude response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   ftol - tolerance on function value
%   ctol - tolerance on constraints
%   verbose -
%
% Outputs:
%   hM - filter design
%   socp_iter,func_iter - for compatibility
%   feasible - true if the design satisfies the constraints

% Copyright (C) 2017,2025 Robert G. Jenssen
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

  if (nargin ~= 13) || (nargout ~= 4)
    print_usage ...
      (["[hM,socp_iter,func_iter,feasible]=directFIRsymmetric_mmsePW ...\n", ...
 "                (vS,hM0,hM_active,na,wa,Ad,Adu,Adl,Wa, ...\n", ...
 "                 maxiter,ftol,ctol,verbose)"]);
  endif
  
  %
  % Sanity checks on coefficient vectors
  %
  hM0=hM0(:);
  if isempty(hM0)
    error("hM0 empty");
  endif
  if isempty(hM_active)
    hM=hM0;
    socp_iter=0;
    func_iter=0;
    feasible=true;
    return;
  endif
  hM_active=hM_active(:);
  if any(hM_active>length(hM0))
    error("hM_active>length(hM0)");
  endif
  % Find the inactive coefficient indexes
  hM_test=ones(length(hM0),1);
  hM_test(hM_active)=0;
  hM_inactive=find(hM_test);
  % Initialise
  hM=[];socp_iter=0;func_iter=0;feasible=false;
  
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
  if ~isempty(Adu) && Nwa ~= length(Adu)
    error("Expected length(wa)(%d) == length(Adu)(%d)",Nwa,length(Adu));
  endif
  if ~isempty(Adl) && Nwa ~= length(Adl)
    error("Expected lenth(wa)(%d) == length(Adl)(%d)",Nwa,length(Adl));
  endif
  if Nwa ~= length(Wa)
    error("Expected length(wa)(%d) == length(Wa)(%d)",Nwa,length(Wa));
  endif
  if any(na>Nwa)
    error("na>Nwa");
  endif
  if isempty(vS)
    vS=directFIRsymmetric_slb_set_empty_constraints();
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
  % Find the gradient of the mean-squared-error
  %
  % nb contains the locations of values in the piece-wise constant bands
  nb=na(1:(end-1))+1;
  waf=wa(na);Adf=Ad(nb);Waf=Wa(nb);
  [~,~,Q,q]=directFIRsymmetricEsqPW(hM0,waf,Adf,Waf);
  
  %
  % Find the amplitude gradients at the constraint frequencies
  %
  [~,gradAl]=directFIRsymmetricA(wa(vS.al),hM0);
  [~,gradAu]=directFIRsymmetricA(wa(vS.au),hM0);
  
  %
  % Solve for active hM coefficients. The matrix equation is:
  %    _    _ _ _   _ _
  %    |Q G'| |h|   |C|
  %    |G 0 |*|l| = |D| 
  %    -    - - -   - -
  % Where h is the column vector of active coefficients and l is the
  % column vector of Lagrange multipliers. If Na is the number of active
  % coefficients and Nc is the number of constraints, then Q is symmetric
  % Na-Na, G is Nc-Na, h is Na-1, l is Nc-1. The constraint amplitude
  % components due to the inactive coefficients are included in D.
  G=[gradAl;gradAu];
  if isempty(G)
    b=[-2*q(hM_active)';[Adl(vS.al);Adu(vS.au)]];
    A=2*Q(hM_active,hM_active);
  else
    b=[-2*q(hM_active)'; ...
       [Adl(vS.al);Adu(vS.au)]-(G(:,hM_inactive)*hM0(hM_inactive))];
    A=[2*Q(hM_active,hM_active),G(:,hM_active)';G(:,hM_active),zeros(rows(G))];
  endif
  if rank(A) ~= rows(A)
    error("rank(A)(%d) ~= rows(A)(%d)",rank(A),rows(A));
  endif
  x=A\b;
  hM=hM0;
  hM(hM_active)=x(1:length(hM_active));
  func_iter=1;
  feasible=true;

endfunction
