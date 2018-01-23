function [wpass,Hpass,Wpass,wstop,Hstop,Wstop,fadp,fads,faap,faas,facp,facs]=...
  frm_lowpass_vectors(n,M,D,d,fpass,fstop,dBas,Wap,Wapextra,Wasextra,Was,...
                      edge_factor,edge_ramp)
% [wpass,Hpass,Wpass,wstop,Hstop,Wstop,fadp,fads,faap,faas,facp,facs]=...
%  frm_lowpass_vectors(n,M,D,d,fpass,fstop,dBas,Wap,Wapextra,Wasextra,Was,...
%                      edge_factor,edge_ramp)
%
% Common code to calculate the frequency, amplitude and weight vectors
% for an FRM lowpass filter. Extra points can be allocated on either
% side of the transition band.
%   
% Inputs:
%   n - number of frequency points  
%   M - FRM model filter decimation factor
%   D - FRM model filter nominal delay
%   d - FRM masking filter nominal delay
%   fpass - Pass band edge
%   fstop - Stop band edge
%   dBas - Stop band attenuation in dB
%   Wap -  Pass band weight
%   Wapextra - Pass band amplitude weight for extra points
%   Wasextra - Stop band amplitude weight for extra points
%   Was - Stop band amplitude weight
%   edge_factor - Add extra frequencies near band edges
%   edge_ramp - if true, change the extra weights linearly from Wap to Wapextra
%
% Outputs:
%   wpass - pass band frequency points
%   Hpass - passband response
%   Wpass - passband weights
%   wstop - stop band frequency points
%   Hstop - stop band response
%   Wstop - stop band weights
%   fadp - model filter pass band edge
%   fads - model filter stop band edge
%   faap - masking filter pass band edge
%   faap - masking filter stop band edge
%   facp - complementary masking filter pass band edge
%   facs - complementary masking filter stop band edge

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

  % Sanity checks
  if (nargin ~= 13) || (nargout ~= 12)
    print_usage("[wpass,Apass,Wpass,wstop,Astop,Wstop, ...\n\
    fadp,fads,faap,faas,facp,facs]=frm_lowpass_vectors(n,M,D,d,...\n\
    fpass,fstop,dBas,Wap,Wapextra,Wasextra,Was,edge_factor,edge_ramp")
  endif

  % Model and masking filter edge frequencies
  if mod(fpass*M,1)>0.5
    m=ceil(fstop*M);
    fadp=m-(fstop*M);
    fads=m-(fpass*M);
    faap=((m-1)+fads)/M;
    faas=(m-fadp)/M;
    facp=(m-fads)/M;
    facs=(m+fadp)/M;
  else
    m=floor(fpass*M);
    fadp=(fpass*M)-m;
    fads=(fstop*M)-m;
    faap=(m+fadp)/M;
    faas=((m+1)-fads)/M;
    facp=(m-fadp)/M;
    facs=(m+fads)/M;
  endif
  
  % Desired passband magnitude response
  if edge_factor == 0
    npass=1+ceil(n*fpass/0.5);
    wpass=pi*(0:(npass-1))'/n;
    Wpass=Wap*ones(npass,1);
  else
    npass=1+ceil(n*fpass*(1-edge_factor)/0.5);
    wpass=pi*(0:(npass-1))'/n;
    npextra=floor(n/2);
    wpextra=pi*(fpass/0.5)*((1-edge_factor)+(edge_factor*(1:npextra)'/npextra));
    wpass=[wpass;wpextra];
    if edge_ramp
      Wpass=[Wap*ones(npass,1); ...
             (Wap*ones(npextra,1))+(Wapextra*(1:npextra)'/npextra)];
    else
      Wpass=[Wap*ones(npass,1);(Wap+Wapextra)*ones(npextra,1)];
    endif
  endif
  Hpass=exp(-j*wpass*((D*M)+d));
  
  % Desired stop-band magnitude response
  if edge_factor == 0
    nstop=floor(n*(0.5-fstop)/0.5)-1;
    wstop=pi*((n-nstop+1):n)'/n;
    Wstop=Was*ones(nstop,1);
  else
    nstop=floor(n*(0.5-(fstop*(1+edge_factor)))/0.5)-1;
    wstop=pi*((n-nstop+1):n)'/n;
    nsextra=floor(n/2);
    wsextra=pi*(fstop/0.5)*(1+(edge_factor*(0:(nsextra-1))'/nsextra));
    wstop=[wsextra;wstop];
    if edge_ramp
      Wstop=[(Was*ones(nsextra,1))+(Wasextra*(nsextra:-1:1)'/nsextra);...
             Was*ones(nstop,1)];
    else
      Wstop=[(Was+Wasextra)*ones(nsextra,1);Was*ones(nstop,1)];
    endif
  endif
  Hstop=(10^(-dBas/20))*exp(-j*wstop*((D*M)+d));

endfunction
