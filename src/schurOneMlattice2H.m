function [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2,d2Hdydx,d3Hdwdydx]=...
  schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adydx)
% [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2,d2Hdydx,d3Hdwdydx] = ...
%   schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adydx)
% Find the complex response and partial derivatives for a Schur one-multiplier
% lattice filter. The outputs are intermediate results in the calculation of
% the squared-magnitude and group-delay responses and partial derivatives.
% The state transition matrix, A, is assumed to lower-Hessenberg.
% For the Schur one-multiplier lattice, d2Bdydx,d2Cdydx,d2Ddydx are zero.
% See schurOneMAPlattice2H() for the Schur one-multiplier all-pass lattice.
%
% Inputs:
%  w - column vector of angular frequencies   
%  A,B,C,D - state variable description of the lattice filter
%  dAdkc,dBdkc,dCdkc,dDdkc - cell arrays of the gradients of A,B,C,D wrt [k,c]
%  d2Adydx - cell array of the second derivatives of A wrt [k,c]
%
% Outputs:
%  H - complex vector of the response over w
%  dHdkc - complex matrix of the gradients of H wrt [k,c] over w
%  dHdw - complex vector derivative of H wrt w
%  d2Hdwdkc - complex matrix of the mixed second derivatives of H
%  diagd2Hdkc2 - complex matrix of the diagonal of the matrix of second
%                derivatives of H wrt [k,c]
%  diagd3Hdwdkc2 - complex matrix of the diagonal of the matrix of second
%                  derivatives of H wrt [k,c] and wrt w
%  d2Hdydx - complex matrix of the second derivatives of H wrt [k,c]
%  d3Hdwdydx - complex matrix of the second derivatives of H wrt [k,c] and wrt w

% Copyright (C) 2017-2025 Robert G. Jenssen
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

  warning("Using m-file version of function schurOneMlattice2H");
  
  % Sanity checks
  if (nargin>10) || (nargout>8) ...
    || ((nargout<=2) && (nargin<5)) ...
    || ((nargout>=3) && (nargout<=6) && (nargin<9)) ...
    || ((nargout>=7) && (nargin<10))
    print_usage ...
(["[H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2,d2Hdydx,d3Hdwdydx] = ...\n", ...
 "     schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adydx)"]);
  endif
  if rows(A)~=columns(A)
    error("rows(A)~=columns(A)");
  endif
  if rows(A)~=rows(B)
    error("rows(A)~=rows(B)");
  endif
  if columns(A)~=columns(C)
    error("columns(A)~=columns(C)");
  endif
  if ~isscalar(D)
    error(" ~isscalar(D)");
  endif

  % Sanity checks on the Schur one-multiplier structure
  Nk=rows(A);
  Nkc=(2*Nk)+1; % Number of coefficients
  % Check A is lower Hessenberg
  if ~istril(A(1:(Nk-1),2:Nk))
    error("A is not lower Hessenberg!");
  endif
  % Check dAdkc
  if (nargin>=6)
    if length(dAdkc) ~= Nkc
      error("length(dAdkc) ~= Nkc");
    endif
    for l=(Nk+1):Nkc,
      if any(any(dAdkc{l}~=0))
        error("any(any(dAdkc{l(%d)}~=0)) !",l);
      endif
    endfor
    if any(dBdkc{Nk}(1:(Nk-1))~=0)
        error("any(dBdkc{Nk}(1 to (Nk-1))~=0) !");      
    endif
  endif  
  % Check B
  if any(B(1:(Nk-1))~=0)
    error("any(B(1 to (Nk-1))~=0) !");
  endif
  % Check dBdkc1
  if (nargin>=7)
    if length(dBdkc) ~= Nkc
      error("length(dBdkc) ~= Nkc");
    endif
    for l=[1:(Nk-1),(Nk+1):Nkc],
      if any(dBdkc{l}~=0) 
        error("any(dBdkc{l(%d)}~=0) !",l);
      endif
    endfor
    if any(dBdkc{Nk}(1:(Nk-1))~=0)
        error("any(dBdkc{Nk}(1 to (Nk-1))~=0) !");      
    endif
  endif  
  % Check dCdkc
  if (nargin>=8)
    if length(dCdkc) ~= Nkc
      error("length(dCdkc) ~= Nkc");
    endif
    for l=1:Nk
      if any(dCdkc{l}~=0)
        error("any(dCdkc{l}~=0) !");
      endif
    endfor
  endif
  % Check dDdkc
  if (nargin>=9)
    if length(dDdkc) ~= Nkc
      error("length(dDdkc) ~= Nkc");
    endif
    for l=1:(Nkc-1)
      if dDdkc{l}~=0
        error("dDdkc{l(%d)}~=0 !",l);
      endif
    endfor
  endif
  % Check d2Adydx
  if (nargin>=10)
    if rows(d2Adydx) ~= Nkc
      error("rows(d2Adydx) ~= Nkc");
    endif
    if columns(d2Adydx) ~= Nkc
      error("columns(d2Adydx) ~= Nkc");
    endif
  endif
  
  % Initialise
  w=w(:);
  Nw=length(w); % Number of frequencies
  Nk=rows(A);   % Number of states
  Nkc=(2*Nk)+1; % Number of coefficients
  if nargin<=5
    dAdkc=[];dBdkc=[];dCdkc=[];dDdkc=[];
  endif
  if nargin<=9
    d2Adydx=[];
  endif
  if nargout>=1
    H=zeros(Nw,1);
  endif
  if nargout>=2
    dHdw=zeros(Nw,1);
  endif
  if nargout>=3
    dHdkc=zeros(Nw,Nkc);
  endif
  if nargout>=4
    d2Hdwdkc=zeros(Nw,Nkc);
  endif
  if nargout>=5
    diagd2Hdkc2=zeros(Nw,Nkc);
  endif
  if nargout>=6
    diagd3Hdwdkc2=zeros(Nw,Nkc);
  endif
  if nargout>=7
    d2Hdydx=zeros(Nw,Nkc,Nkc);
  endif
  if nargout>=8
    d3Hdwdydx=zeros(Nw,Nkc,Nkc);
  endif

  if exist("complex_zhong_inverse","file") == 3
    zhong_hndl=@complex_zhong_inverse;
  else
    warning("Using builtin function inv()!");
    zhong_hndl=@inv;
  endif
    
  % Loop over w calculating the complex response then
  for l=1:Nw,
    % Find the resolvent
    R=zhong_hndl((exp(j*w(l))*eye(Nk))-A);
          
    % Find H
    CR=C*R;
    CRB=CR*B;
    H(l)=CRB+D;
    if nargout==1
      continue;
    endif

    % Find dHdw
    CRR=CR*R;
    CRRB=CRR*B;
    jexpjw=j*exp(j*w(l));
    dHdw(l)=-jexpjw.*CRRB;
    if nargout==2
      continue;
    endif

    % Find dHdkc
    RB=R*B;
    dHdk=zeros(1,Nk);
    for m=1:Nk
      dHdk(m)=CR*dAdkc{m}*RB;
    endfor
    % For the one-multiplier Schur lattice only dBdk{Nk}(Nk) is non-zero
    dHdk(Nk)=dHdk(Nk)+(CR*dBdkc{Nk});
    % Construct dCdc and dDdc
    dCdc=zeros(Nk,Nk);
    for m=1:Nk
      dCdc(m,m)=dCdkc{Nk+m}(m);
    endfor
    dDdc=dDdkc{Nkc};
    % Note the non-conjugate matrix transpose ".'"
    dHdc=[dCdc*RB;dDdc].';
    dHdkc(l,:)=[dHdk,dHdc];
    if nargout==3
      continue;
    endif

    % Find d2Hdwdkc
    RRB=R*RB;
    d2Hdwdk=zeros(1,Nk);
    for m=1:Nk
      d2Hdwdk(m)=-jexpjw*((CRR*dAdkc{m}*RB)+(CR*dAdkc{m}*RRB));
    endfor
    d2Hdwdk(Nk)=d2Hdwdk(Nk)-jexpjw*(CRR*dBdkc{Nk});
    % Note the non-conjugate matrix transpose ".'".
    d2Hdwdc=[-jexpjw*dCdc*RRB;0].';
    d2Hdwdkc(l,:)=[d2Hdwdk,d2Hdwdc];
    if nargout==4
      continue;
    endif

    % Find diagd2Hdkc2 (diagonal of the the Hessian of H wrt [k,c]
    for m=1:Nk 
      diagd2Hdkc2(l,m)=(2*CR*dAdkc{m}*R*dAdkc{m}*RB);
    endfor
    diagd2Hdkc2(l,Nk)=diagd2Hdkc2(l,Nk)+(2*CR*dAdkc{Nk}*R*dBdkc{Nk});
    if nargout==5
      continue;
    endif

    % Find diagd3Hdwdkc2 (diagonal of the the derivatives of H wrt [w,k,c])
    RR=R*R;
    for m=1:Nk 
      diagd3Hdwdkc2(l,m)=-jexpjw*( (2*CRR*dAdkc{m}*R*dAdkc{m}*RB) + ...
                                   (2*CR*dAdkc{m}*RR*dAdkc{m}*RB) + ...
                                   (2*CR*dAdkc{m}*R*dAdkc{m}*RRB) );
    endfor
    diagd3Hdwdkc2(l,Nk)=diagd3Hdwdkc2(l,Nk)- ...
                        (2*jexpjw*((CRR*dAdkc{Nk}*R*dBdkc{Nk})+...
                                   (CR*dAdkc{Nk}*RR*dBdkc{Nk})));
    if nargout==6
      continue;
    endif
    
    % Find d2Hdydx (second partial derivatives of H wrt x and y)
    % dAdkc is non-zero for 1<=m<=Nk
    for m=1:Nk
      for n=m:Nk
        d2Hdydx(l,m,n)=(CR*dAdkc{m}*R*dAdkc{n}*RB) + ...
                       (CR*dAdkc{n}*R*dAdkc{m}*RB) + ...
                       (CR*d2Adydx{m,n}*RB);
        d2Hdydx(l,n,m)=d2Hdydx(l,m,n);
      endfor
    endfor
    % dAdkc is non-zero for 1<=m<=Nk and dBdkc is non-zero for Nk
    for m=1:(Nk-1)
      d2Hdydx(l,m,Nk)=d2Hdydx(l,m,Nk) + (CR*dAdkc{m}*R*dBdkc{Nk});
      d2Hdydx(l,Nk,m)=d2Hdydx(l,m,Nk);
    endfor
    d2Hdydx(l,Nk,Nk)=d2Hdydx(l,Nk,Nk) + (2*CR*dAdkc{Nk}*R*dBdkc{Nk});
    % dAdkc is non-zero for 1<=m<=Nk and dCdkc is non-zero for Nk+1<=m
    for m=1:Nk
      for n=1:(Nk+1)
        d2Hdydx(l,m,Nk+n)=(dCdkc{Nk+n}*R*dAdkc{m}*RB);
        d2Hdydx(l,Nk+n,m)=d2Hdydx(l,m,Nk+n);
      endfor
    endfor
    % dBdkc is non-zero for Nk and dCdkc is non-zero for Nk+1<=m
    for n=1:(Nk+1)
      d2Hdydx(l,Nk,Nk+n)=d2Hdydx(l,Nk,Nk+n)+(dCdkc{Nk+n}*R*dBdkc{Nk});
      d2Hdydx(l,Nk+n,Nk)=d2Hdydx(l,Nk,Nk+n);
    endfor
    if nargout==7
      continue;
    endif

    % Find d3Hdwdydx (second partial derivatives of H wrt x, y and w)
    % dAdkc is non-zero for 1<=m<=Nk
    for m=1:Nk
      for n=m:Nk
        d3Hdwdydx(l,m,n)=-jexpjw*( (CRR*dAdkc{n}*R*dAdkc{m}*RB) + ...
                                   (CR*dAdkc{n}*RR*dAdkc{m}*RB) + ...
                                   (CR*dAdkc{n}*R*dAdkc{m}*RRB) + ...
                                   (CRR*dAdkc{m}*R*dAdkc{n}*RB) + ...
                                   (CR*dAdkc{m}*RR*dAdkc{n}*RB) + ...
                                   (CR*dAdkc{m}*R*dAdkc{n}*RRB) + ...
                                   (CRR*d2Adydx{m,n}*RB)        + ...
                                   (CR*d2Adydx{m,n}*RRB) );
        d3Hdwdydx(l,n,m)=d3Hdwdydx(l,m,n);
      endfor
    endfor
    % dAdkc is non-zero for 1<=m<=Nk and dBdkc is non-zero for Nk
    for m=1:(Nk-1)
      d3Hdwdydx(l,m,Nk)= ...
          d3Hdwdydx(l,m,Nk) - (jexpjw*( (CRR*dAdkc{m}*R*dBdkc{Nk})+...
                                        (CR*dAdkc{m}*RR*dBdkc{Nk}) ));
      d3Hdwdydx(l,Nk,m)=d3Hdwdydx(l,m,Nk);
    endfor
    d3Hdwdydx(l,Nk,Nk)= ...
      d3Hdwdydx(l,Nk,Nk) - (jexpjw*2*( (CRR*dAdkc{Nk}*R*dBdkc{Nk})+...
                                       (CR*dAdkc{Nk}*RR*dBdkc{Nk}) ));
    % dAdkc is non-zero for 1<=m<=Nk and dCdkc is non-zero for Nk+1<=m
    for m=1:Nk
      for n=1:(Nk+1)
        d3Hdwdydx(l,m,Nk+n)=-jexpjw*( (dCdkc{Nk+n}*RR*dAdkc{m}*RB) + ...
                                      (dCdkc{Nk+n}*R*dAdkc{m}*RRB) );
        d3Hdwdydx(l,Nk+n,m)=d3Hdwdydx(l,m,Nk+n);
      endfor
    endfor
    % dBdkc is non-zero for Nk and dCdkc is non-zero for Nk+1<=m
    for n=1:(Nk+1)
      d3Hdwdydx(l,Nk,Nk+n)=d3Hdwdydx(l,Nk,Nk+n)- ...
                           (jexpjw*(dCdkc{Nk+n}*RR*dBdkc{Nk}));
      d3Hdwdydx(l,Nk+n,Nk)=d3Hdwdydx(l,Nk,Nk+n);
    endfor
    
  endfor
  
endfunction
