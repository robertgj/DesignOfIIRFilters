function wx=halleyFIRsymmetricA(wa,hM,Ax)
% wx=halleyFIRsymmetricA(wa,hM,Ax)
% Given the distinct coefficients of an even-order FIR filter, hM, and an
% approximate angular frequencies, wa, use Halleys method to find the 
% frequencies, wx, corresponding to Ax. If Ax is empty or not given then
% find the peaks (zeros of the gradient) near the frequencies in wa.
%
% Writing fn=f(x(n)) and f'=df(x)/dx, Newtons method is: x(n+1)=x(n)-[fn/fn']
% and Halleys method is: x(n+1)=x(n)-(fn/fn')/[1-((fn/fn')*(fn''/(2fn')))]
%
% Inputs:
%   wa - approximate angular frequencies
%   hM - distinct coefficients of a symmetric FIR filter polynomial, [h0 ... hM]
%   Ax - amplitudes at which to find the corresponding angular frequencies
% Outputs:
%   wx - angular frequencies corresponding to Ax
  
% Copyright (C) 2020 Robert G. Jenssen
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

  if (nargout > 1) || ((nargin ~= 2) && (nargin~=3))
    print_usage("wx=halleyFIRsymmetricA(wa,hM) (find peaks)\n\
wx=halleyFIRsymmetricA(wa,hM,Ax) (find wx for values Ax)");
  endif
  if isempty(wa)
    wx=[];
    return;
  endif
  if isempty(hM)
    error("hM is empty");
  endif
  if nargin==2
    Ax=zeros(size(wa));
  elseif nargin==3 && length(wa)~=length(Ax)
    error("Expected length(wa)~=length(Ax)");
  endif

  tol=1e-12;
  maxiter=12;
  verbose=false;
  
  wa=wa(:);
  hM=hM(:);
  Ax=Ax(:);
  M=length(hM)-1;
  M1=(M:-1:1);
  wx=wa;
  lastwx=wa;

  for k=1:maxiter,
    M1wx=M1.*wx;
    cosM1wx=cos(M1wx);
    sinM1wx=sin(M1wx);
    Awx=[2*cosM1wx,ones(size(wx))]*hM;
    dAwxdw=[-2*M1.*sinM1wx,zeros(size(wx))]*hM;
    d2Awxdw2=[-2*(M1.^2).*cosM1wx,zeros(size(wx))]*hM;
    d3Awxdw3=[2*(M1.^3).*sinM1wx,zeros(size(wx))]*hM;
  
    if nargin==2
      fonfp=dAwxdw./d2Awxdw2;
      fpponfp=d3Awxdw3./d2Awxdw2;
    else
      fonfp=(Awx-Ax)./dAwxdw;
      fpponfp=d2Awxdw2./dAwxdw;
    endif
    
    wx=lastwx-(fonfp./(1-(0.5*fonfp.*fpponfp)));

    iwx=find(isinf(wx));
    wx(iwx)=lastwx(iwx); 
    iwx=find(isnan(wx));
    wx(iwx)=lastwx(iwx); 

    if verbose
      printf("At k=%d,wx=[",k);printf(" %g",wx');printf("]\n");
      printf("Awx-Ax=[");printf(" %g",(Awx(:)-Ax(:))');printf("]\n");
    endif
    
    if norm(wx-lastwx)<tol
      break;
    endif
    
    lastwx=wx;
    
    if k==maxiter
      error("k==maxiter");
    endif
  endfor
  
endfunction
