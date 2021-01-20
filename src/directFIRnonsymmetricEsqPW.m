function [Esq,gradEsq,Q,q]=directFIRnonsymmetricEsqPW(h,waf,Adf,Tdf,Waf)
% [Esq,gradEsq,Q,q]=directFIRnonsymmetricEsqPW(h,waf,Adf,Tdf,Waf)
% Calculate the mean-squared-error of a direct-form non-symmetric FIR filter
% with a piece-wise list of band-edge angular frequencies, waf, desired
% amplitude responses, Adf, group-delay in samples, Tdf, and weighting
% function values, Waf.
%
% Inputs:
%   h - FIR impulse response
%   waf - angular frequencies of band edges in [0,pi] eg: [0 0.1 0.2 0.5]*2*pi
%   Adf - desired response, assumed to be 0 in stop bands, eg: [0 1 0]
%   Tdf - desired delay, an integral number of samples, assumed to be 0 in
%         stop bands, eg: [0 10 0]
%   Waf - weight in each band eg: [100 1 100]
%
% Outputs:
%   Esq - the squared error value at h, a scalar
%   gradEsq - gradient of the squared error value at h, a row vector
%   Q,q - gradEsq=2*h'*Q+2*q. h is (N+1)x1, q is 1x(N+1) and Q is (N+1)x(N+1)
  
% Copyright (C) 2020-2021 Robert G. Jenssen
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
  if (nargout > 4) || (nargin ~= 5)
    print_usage ...
      ("[Esq,gradEsq,Q,q]=directFIRnonsymmetricEsqPW(h,waf,Adf,Tdf,Waf)");
  endif
  if isempty(h)
    error("isempty(h)");
  endif
  if isempty(waf)
    error("waf is empty");
  endif
  if length(waf) ~= length(Adf)+1
      error("length(waf) ~= length(Adf)+1");
  endif
  if length(waf) ~= length(Tdf)+1
      error("length(waf) ~= length(Tdf)+1");
  endif
  if length(waf) ~= length(Waf)+1
    error("length(waf) ~= length(Waf)+1");
  endif
  if any(rem(Tdf,1)~=0)  
    error("any(rem(Tdf,1)~=0)");
  endif
  if any(Tdf>=length(h))
    error("any(Tdf>=length(h))");
  endif

  % Initialise
  h=h(:);
  N=length(h)-1;
  waf=waf(:);
  Adf=Adf(:);
  Tdf=Tdf(:);
  Waf=Waf(:);
  nN=0:N;

  % Find Q
  nn=(nN'-nN);
  intHH=zeros(length(waf),N+1,N+1);
  for l=1:length(waf)
    intHH(l,:,:)=(waf(l)*eye(N+1))+(sin(nn*waf(l))./(nn+eye(N+1)));
  endfor
  def_intHH=intHH(2:end,:,:)-intHH(1:(end-1),:,:);
  % Sum over the bands
  Q=reshape(sum(Waf.*def_intHH,1)/pi,[N+1,N+1]);
  % Check that Q is symmetric
  if ~issymmetric(Q)
    error("~issymmetric(Q)");
  endif

  % Find q
  nT=(nN-Tdf);
  wT=zeros(size(nT));
  nT1=nT;
  for l=1:rows(nT)
    v=find(nT(l,:)==0);
    wT(l,v)=waf(l+1)-waf(l);
    nT1(l,v)=1;
  endfor
  def_intH=-wT-((sin(nT.*waf(2:end))-sin(nT.*waf(1:(end-1))))./nT1);
  % Sum over the bands
  q=sum(Waf.*Adf.*def_intH,1)/pi;
  
  % Find the constant
  intc=sum(Adf.*Adf.*Waf.*diff(waf))/pi;

  % Find Esq
  Esq=(h'*Q*h)+(2*q*h)+intc;
  if Esq<0
    error("Esq<0");
  endif

  % Find gradEsq
  gradEsq=(2*(h')*Q)+(2*q);

endfunction
