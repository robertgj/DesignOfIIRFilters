function [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td)
% [Hw,gradHw]=frm2ndOrderCascade(w,xk,M,td,tau)
% Calculate the zero-phase response and gradient with respect to
% the coefficients for a frequency response masking filter with
% the model filter denominator polynomial implemented as a cascade
% of 2nd order sections.
% 
% Inputs:
%   w - angular frequencies for response
%   xk - vector of coefficients
%   mn - the order of the model filter numerator polynomial
%   mr - the order of the model filter denominator polynomial
%   na - the number of masking filter coefficients
%   nc - the number of complementary masking filter coefficients
%   M - decimation factor of the IIR model filter
%   td - passband delay of the IIR model filter
% Outputs:
%   Hw - zero-phase response at angular frequencies w
%   gradHw - gradient of Hw at w

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

  %
  % Sanity checks
  %
  if nargin ~= 8
    print_usage("[Hw,gradHw]=frm2ndOrderCascade(w,x,mn,mr,na,nc,M,td);");
  endif
  if isempty(w)
    Hw=[];
    gradHw=[];
    return;
  endif
  % Check length of na and nc
  na_is_odd=(mod(na,2)==1);
  nc_is_odd=(mod(nc,2)==1);
  if na_is_odd ~= nc_is_odd
    error("Expected na_is_odd == nc_is_odd");
  endif
  % Check length of xk
  mnp1=mn+1;
  if na_is_odd
    una=(na+1)/2;
  else
    una=na/2;
  endif 
  if nc_is_odd
    unc=(nc+1)/2;
  else
    unc=nc/2;
  endif 
  if length(xk) ~= (mnp1+mr+una+unc)
    error("Expected length(xk) == (mnp1+mr+una+unc)");
  endif
  
  %
  % FRM filter zero-phase frequency response
  %

  % Initialise and extract coefficients
  w=w(:);
  Nw=length(w);
  xk=xk(:);
  ak=xk(1:mnp1);
  mr_is_odd=(mod(mr,2)==1);
  L=floor(mr/2);
  if mr > 0
    dk=xk((mnp1+1):(mnp1+mr));
  else
    dk=1;
  endif
  aak=xk((mnp1+mr+1):(mnp1+mr+una));
  ack=xk((mnp1+mr+una+1):(mnp1+mr+una+unc));
  
  % Model filter numerator frequency response
  vMw=exp(-j*kron(((0:mn)-td)*M,w));
  akMw=vMw*ak;

  % Model filter denominator frequency response
  if mr_is_odd
    dk0=dk(1);
    v1=exp(-j*M*w);
    dkMw=(1+dk0*v1);
    if L==0
      dki=[0;0];
    else
      dki=reshape(dk(2:end),2,L);
    endif
  else
    dkMw=ones(Nw,1);
    if L==0
      dki=[0;0];
    else
      dki=reshape(dk,2,L);
    endif
  endif
  % v2 is length(w)-by-2, dki is 2-by-L
  v2=[exp(-j*M*w) exp(-j*2*M*w)];
  dkMw=dkMw.*prod(1+(v2*dki),2);

  % Model filter frequency response
  HaMw=akMw./dkMw;

  % FIR masking filter, FMa
  if na_is_odd
    ca=[ones(Nw,1) 2*cos(kron((1:((na-1)/2)),w))];
  else
    ca=2*cos(kron(((1/2):((na-1)/2)),w));
  endif

  % Complementary FIR masking filter, FMc
  if nc_is_odd
    cc=[ones(Nw,1) 2*cos(kron((1:((nc-1)/2)),w))];
  else
    cc=2*cos(kron(((1/2):((nc-1)/2)),w));
  endif

  % Overall frequency response
  yw=ca*aak-cc*ack;
  Hw=(HaMw.*yw)+cc*ack;

  %
  % Gradient of overall frequency response, length(w)-by-length(xk)
  %

  % delHaMwdela (nw-by-mn)
  delHaMwdela=vMw./kron(dkMw,ones(1,mnp1));

  % delHaMwdeld (nw-by-mr)
  if mr_is_odd
    delHaMwdeld0=-HaMw.*v1./(1+dk0*v1);
  else
    delHaMwdeld0=zeros(Nw,0);
  endif
  if L==0
    delHaMwdeld=delHaMwdeld0;
  else
    HaMw2L=kron(HaMw,ones(1,2*L));
    Lv2=kron(ones(1,L),v2);
    v2dki2=kron(1+(v2*dki),ones(1,2));
    delHaMwdeld=[delHaMwdeld0 -(HaMw2L.*Lv2./v2dki2)];
  endif
  % Gradient (nw-by-(mnp1+mr+na+nc)
  gradHw=[kron(ones(1,mnp1),yw).*delHaMwdela, ...
          kron(ones(1,mr),yw).*delHaMwdeld, ...
          kron(ones(1,columns(ca)),HaMw).*ca, ...
          kron(ones(1,columns(cc)),(1-HaMw)).*cc];

endfunction  
