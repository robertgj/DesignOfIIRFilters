function [Esq,gradEsq,Q,q]=directFIRsymmetricEsqPW(hM,waf,Adf,Waf)
% [Esq,gradEsq,Q,q]=directFIRsymmetricEsqPW(hM,waf,Adf,Waf)
% Calculate the mean-squared-error of a direct-form symmetric FIR filter with
% a piece-wise list of band-edge angular frequencies, waf, desired amplitude
% responses, Adf, and weighting function values, Waf.
%
% Inputs:
%   hM - distinct coefficients of an even order, symmetric FIR filter polynomial
%   waf - angular frequencies of band edges in [0,pi] eg: [0 0.1 0.2 0.5]*2*pi
%   Adf - desired response, assumed to be 0 in stop bands, eg: [0 1 0]
%   Waf - weight in each band eg: [100 1 100]
%
% Outputs:
%   Esq - the squared error value at h, a scalar
%   gradEsq - gradient of the squared error value at h, a row vector
%   Q,q - gradEsq=2*hM'*Q+2*q. hM is (M+1)x1, q is 1x(M+1) and Q is (M+1)x(M+1)
  
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

  if (nargout > 4) || (nargin ~= 4)
    print_usage("[Esq,gradEsq,Q,q]=directFIRsymmetricEsqPW(hM,waf,Adf,Waf)");
  endif
  if isempty(hM)
    error("hM is empty");
  endif
  if isempty(waf)
    error("waf is empty");
  endif
  if length(waf) ~= length(Adf)+1
      error("length(waf) ~= length(Adf)+1");
    endif
  if length(waf) ~= length(Waf)+1
    error("length(waf) ~= length(Waf)+1");
  endif
    
  hM=hM(:);
  M=length(hM)-1;
  waf=waf(:);
  Adf=Adf(:);
  Waf=Waf(:);
  nM=M-(0:(M-1));
  nmM=((M-(0:M))+nM');  
  nm=((0:(M-1))')-(0:(M-1));

  % Find q
  % Find the values of the unweighted indefinite integral at the band edges
  intdelAdelhM=zeros(length(waf),M+1);
  intdelAdelhM(:,1:M)=2*sin(nM.*waf)./nM;
  intdelAdelhM(:,M+1)=waf;
  % Sum over the bands
  q=-sum((Waf.*Adf).*(intdelAdelhM(2:end,:)-intdelAdelhM(1:(end-1),:)),1)/pi;

  % Find Q
  % Find the values of the unweighted indefinite integral at the band edges
  intAdelAdelhM=zeros(length(waf),M+1,M+1);
  intAdelAdelhM(:,M+1,:)=intdelAdelhM;
  for l=1:length(waf)
    intAdelAdelhM(l,1:M,:)= (2*sin(nmM*waf(l))./nmM) ...
                           +[(2*sin(nm*waf(l))./(nm+eye(M))), zeros(M,1)]...
                           +[(2*waf(l)*eye(M)), zeros(M,1)];
  endfor

  % Find the definite integrals over each band
  def_intAdelAdelhM=intAdelAdelhM(2:end,:,:)-intAdelAdelhM(1:(end-1),:,:);
  
  % Sum over the bands
  Q=reshape(sum(Waf.*def_intAdelAdelhM,1)/pi,[M+1,M+1]);
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
