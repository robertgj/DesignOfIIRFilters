function [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw]= ...
  H2dAsqdw(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx)
% [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw]= ...
%  H2dAsqdw(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx)
% A helper function that calculates the gradient of the squared-amplitude
% with respect to frequency of a filter with the complex frequency response,
% H, and gradients, dHdw, etc. found by functions like schurOneMlattice2H.
% 
% Inputs:
%   H - complex frequency response over angular frequency, w
%   dHdw - gradient of the complex frequency response wrt w
%   dHdx - gradients of complex frequency response wrt x
%   d2Hdwdx - gradients of dHdw wrt to x
%   diagd2Hdx2 - diagonal of the Hessian of H wrt to x
%   diagd3Hdwdx2 - diagonal of the gradient of the Hessian of H wrt to w
%   d2Hdydx - Hessian of H wrt to x and y
%   d3Hdwdydx - gradient of the Hessian of H wrt to w
%
% Outputs:
%   dAsqdw - the group delay response at w
%   graddAsqdw - the gradients of dAsqdw with respect to x
%   diagHessdAsqdw - diagonal of the Hessian of dAsqdw with respect to x
%   hessdAsqdw - Hessian of dAsqdw with respect to x and y

% Copyright (C) 2024-2025 Robert G. Jenssen
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
  if (nargout==0)                 || ...
     ((nargout==1) && (nargin<2)) || ...
     ((nargout==2) && (nargin<4)) || ...
     ((nargout==3) && (nargin<6)) || ...
     ((nargout==4) && (nargin<8)) || ...
     (nargout>4)
    print_usage("[dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw]= ...\n\
      H2dAsqdw(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx)");
  endif
  Nw=length(H);
  if (nargin >= 1) && (Nw ~= rows(H))
    error("Nw ~= length(H)");
  endif
  if (nargin >= 2) && (Nw ~= rows(dHdw))
    error("Nw ~= length(dHdw)");
  endif
  if (nargin >= 3) && (Nw ~= rows(dHdx))
    error("Nw ~= rows(dHdx)");
  endif
  if (nargin >= 4) && (Nw ~= rows(d2Hdwdx))
    error("Nw ~= rows(d2Hdwdx)");
  endif
  if (nargin >= 5) && (Nw ~= rows(diagd2Hdx2))
    error("Nw ~= rows(diagd2Hdx2)");
  endif
  if (nargin >= 6) && (Nw ~= rows(diagd3Hdwdx2))
    error("Nw ~= rows(diagd3Hdwdx2)");
  endif
  if (nargin >= 4) && (columns(dHdx) ~= columns(d2Hdwdx))
    error("columns(dHdx) ~= columns(d2Hdwdx)");
  endif
  if (nargin >= 5) && (columns(dHdx) ~= columns(diagd2Hdx2))
    error("columns(dHdx) ~= columns(diagd2Hdx2)");
  endif
  if (nargin >= 6) && (columns(dHdx) ~= columns(diagd3Hdwdx2))
    error("columns(dHdx) ~= columns(diagd3Hdwdx2)");
  endif
  if nargin >= 7
    sz_d2Hdydx=size(d2Hdydx);
    if Nw ~= sz_d2Hdydx(1)
      error("Nw ~= sz_d2Hdydx(1)");
    endif
    if columns(dHdx) ~= sz_d2Hdydx(2)
      error("columns(dHdx) ~= sz_d2Hdydx(2)");
    endif
    if columns(dHdx) ~= sz_d2Hdydx(3)
      error("columns(dHdx) ~= sz_d2Hdydx(3)");
    endif
  endif
  if nargin >= 8
    sz_d3Hdwdydx=size(d3Hdwdydx);
    if Nw ~= sz_d3Hdwdydx(1)
      error("Nw ~= sz_d3Hdwdydx(1)");
    endif
    if columns(dHdx) ~= sz_d3Hdwdydx(2)
      error("columns(dHdx) ~= sz_d3Hdwdydx(2)");
    endif
    if columns(dHdx) ~= sz_d3Hdwdydx(3)
      error("columns(dHdx) ~= sz_d3Hdwdydx(3)");
    endif
  endif

  if Nw == 0
    dAsqdw=[]; graddAsqdw=[]; diagHessdAsqdw=[]; hessdAsqdw=[];
    return;
  endif

  % Find dAsqdw
  rH=real(H);
  iH=imag(H);
  rdHdw=real(dHdw);
  idHdw=imag(dHdw);

  dAsqdw=2*((iH.*idHdw)+(rH.*rdHdw));

  if nargout==1
    return;
  endif

  % Find graddAsqdw
  Nx=columns(dHdx);
  kiH=kron(iH,ones(1,Nx));
  krH=kron(rH,ones(1,Nx));
  kidHdw=kron(idHdw,ones(1,Nx));
  krdHdw=kron(rdHdw,ones(1,Nx));
  idHdx=imag(dHdx);
  rdHdx=real(dHdx);
  id2Hdwdx=imag(d2Hdwdx);
  rd2Hdwdx=real(d2Hdwdx);
  
  graddAsqdw=2*( (idHdx.*kidHdw) + (kiH.*id2Hdwdx) + ...
                 (rdHdx.*krdHdw) + (krH.*rd2Hdwdx)   );

  if nargout==2
    return;
  endif

  % Find diagHessdAsqdw
  gradAsq=2*((kiH.*idHdx)+(krH.*rdHdx));
  rd2Hdx2=real(diagd2Hdx2);
  id2Hdx2=imag(diagd2Hdx2);
  rd3Hdwdx2=real(diagd3Hdwdx2);
  id3Hdwdx2=imag(diagd3Hdwdx2);
  diagHessdAsqdw = 2*( (id2Hdx2.*kidHdw) + (idHdx.*id2Hdwdx) + ...
                       (idHdx.*id2Hdwdx) + (kiH.*id3Hdwdx2)  + ... 
                       (rd2Hdx2.*krdHdw) + (rdHdx.*rd2Hdwdx) + ...
                       (rdHdx.*rd2Hdwdx) + (krH.*rd3Hdwdx2)    );
 
  if nargout==3
    return;
  endif

  % Find hessdAsqdw
  kkiH=reshape(kron(kiH,ones(1,Nx)),sz_d2Hdydx);
  kkrH=reshape(kron(krH,ones(1,Nx)),sz_d2Hdydx);

  kidHdx=reshape(kron(idHdx,ones(1,Nx)),sz_d2Hdydx);
  krdHdx=reshape(kron(rdHdx,ones(1,Nx)),sz_d2Hdydx);
  
  kidHdy=reshape(kron(ones(1,Nx),idHdx),sz_d2Hdydx);
  krdHdy=reshape(kron(ones(1,Nx),rdHdx),sz_d2Hdydx);
 
  kkidHdw=reshape(kron(kidHdw,ones(1,Nx)),sz_d2Hdydx);
  kkrdHdw=reshape(kron(krdHdw,ones(1,Nx)),sz_d2Hdydx);

  kid2Hdwdx=reshape(kron(id2Hdwdx,ones(1,Nx)),sz_d2Hdydx);
  krd2Hdwdx=reshape(kron(rd2Hdwdx,ones(1,Nx)),sz_d2Hdydx);

  kid2Hdwdy=reshape(kron(ones(1,Nx),id2Hdwdx),sz_d2Hdydx);
  krd2Hdwdy=reshape(kron(ones(1,Nx),rd2Hdwdx),sz_d2Hdydx);
  
  id2Hdydx=imag(d2Hdydx);
  rd2Hdydx=real(d2Hdydx);

  id3Hdwdydx=imag(d3Hdwdydx);
  rd3Hdwdydx=real(d3Hdwdydx);

  hessdAsqdw = 2*( (id2Hdydx.*kkidHdw) + (kidHdx.*kid2Hdwdy) + ...
                   (kidHdy.*kid2Hdwdx) + (kkiH.*id3Hdwdydx)  + ... 
                   (rd2Hdydx.*kkrdHdw) + (krdHdx.*krd2Hdwdy) + ...
                   (krdHdy.*krd2Hdwdx) + (kkrH.*rd3Hdwdydx)    );
  
  for l=1:Nw,
    if ~issymmetric(squeeze(hessdAsqdw(l,:,:)),10*eps)
      squeeze(hessdAsqdw(2,:,:))
      error("hessdAsqdw is not symmetric at l=%d",l);
    endif 
      hessdAsqdw(l,:,:) = ...
        (squeeze(hessdAsqdw(l,:,:))+(squeeze(hessdAsqdw(l,:,:)).'))/2;
  endfor
  
endfunction
