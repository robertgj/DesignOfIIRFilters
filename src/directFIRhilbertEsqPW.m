function [Esq,gradEsq,Q,q]=directFIRhilbertEsqPW(hM,waf,Adf,Waf)
% [Esq,gradEsq,Q,q]=directFIRhilbertEsqPW(hM,waf,Adf,Waf)
% Inputs:
%   hM - M distinct coefficients of an order 4M, Hilbert FIR filter polynomial
%   waf - angular frequencies of band edges in [0,pi] eg: [0.05 0.45]*2*pi
%   Adf - desired amplitude in each band (for compatibility. Should be 1!).
%   Waf - weights in each band
%
% Outputs:
%   Esq - the squared error value at hM, a scalar
%   gradEsq - gradient of the squared error value at hM, a row vector
%   Q,q - gradEsq=2*hM'*Q+2*q where hM is Mx1, q is 1xM and Q is MxM
  
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

  if (nargout > 4) || ((nargin ~= 2) && (nargin ~= 3) && (nargin ~=4))
    print_usage("[Esq,gradEsq,Q,q]=directFIRhilbertEsqPW(hM,waf,Adf,Waf)");
  endif
  if isempty(hM)
    error("hM is empty");
  endif
  if isempty(waf)
    error("waf is empty");
  endif
  if nargin == 2
    Adf=ones(length(waf)-1,1);
    Waf=Adf;
  elseif nargin == 3
    Waf=ones(length(waf)-1,1);
  endif
  if length(waf) ~= (length(Adf)+1)
    error("length(waf) ~= (length(Adf)+1)");
  endif
  if length(waf) ~= (length(Waf)+1)
    error("length(waf) ~= (length(Waf)+1)");
  endif
    
  hM=hM(:);
  M=length(hM);
  waf=waf(:);
  Adf=Adf(:);
  Waf=Waf(:);
  m2Mp1=(2*(0:(M-1)))+1;
  lpm=(m2Mp1')+m2Mp1;
  lmm=(m2Mp1')-m2Mp1;

  % Find q
  % Find the values of the unweighted indefinite integral at the band edges
  intdelAdfelhM=-2*cos(m2Mp1.*waf)./m2Mp1;
  % Sum over the bands
  q=-sum((Waf.*Adf).*(intdelAdfelhM(2:end,:)-intdelAdfelhM(1:(end-1),:)),1)/pi;

  % Find Q
  % Find the values of the unweighted indefinite integral at the band edges
  intAdfelAdfelhM=zeros(length(waf),M,M);
  for l=1:length(waf)
    intAdfelAdfelhM(l,:,:) =  (2*waf(l)*eye(M)) ...
                              +(2*sin(lmm*waf(l))./(lmm+eye(M))) ...
                              -(2*sin(lpm*waf(l))./lpm);
  endfor
  % Find the definite integrals over each band
  def_intAdfelAdfelhM=intAdfelAdfelhM(2:end,:,:)-intAdfelAdfelhM(1:(end-1),:,:);
  % Sum over the bands
  Q=reshape(sum(Waf.*def_intAdfelAdfelhM,1)/pi,[M,M]);
  % Check
  if ~isdefinite(Q)
    error("~isdefinite(Q)");
  endif
  
  % Find the constant
  intc=sum((Adf.*Adf.*Waf).*(waf(2:end)-waf(1:(end-1))),1)/pi;

  % Find Esq
  Esq=(hM'*Q*hM)+(2*q*hM)+intc;

  % Find gradEsq
  gradEsq=(2*(hM')*Q)+(2*q);

endfunction
