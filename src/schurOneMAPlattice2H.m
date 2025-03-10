function [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx,d3Hdwdydx] = ...
  schurOneMAPlattice2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
                      d2Adydx,d2Capdydx)
% [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx,d3Hdwdydx] = ...
%   schurOneMAPlattice2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
%                        d2Adydx,d2Capdydx)
% Find the complex response and partial derivatives for an all-pass Schur
% one-multiplier lattice filter. The outputs are intermediate results in the
% calculation of the squared-magnitude and group-delay responses and partial
% derivatives. The state transition matrix, A, is assumed to be lower
% Hessenberg. For the Schur one-multiplier lattice the second derivatives
% d2Capdk2=0, d2Bdydx=0 and d2Dapdydx=0.
%
% Inputs:
%  w - column vector of angular frequencies   
%  A,B,Cap,Dap - state variable description of the allpass lattice filter
%  dAdk - cell array of matrixes of the differentials of A wrt k
%  dBdk - cell array of column vectors of the differentials of B wrt k
%  dCapdk - cell array of row vectors of the differentials of C wrt k
%  dDapdk - cell array of the scalar differential of Dap wrt k
%  d2Adydx - cell array of matrixes of the second differentials of A wrt k
%  d2Capdydx - cell array of matrixes of the second differentials of Cap wrt k
% Outputs:
%  H - complex vector of response wrt w
%  dHdw - complex vector of the derivative of the complex response wrt w
%  dHdk - complex matrix of the derivative of the complex response wrt k
%  d2Hdwdk - complex matrix of the derivative of the complex response wrt k and w
%  diagd2Hdk2,diagd3Hdwdk2 - diagonals of the complex matrixes of the mixed
%                            second derivatives of the response
%  d2Hdk2,d3Hdwdk2 - complex matrixes of the mixed second derivatives of the
%                    response

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
  
  warning("Using m-file version of function schurOneMAPlattice2H");
  
  % Sanity checks
  if (nargin>11) || (nargout>8) ...
    || ((nargout<=2) && (nargin<5)) ...
    || (((nargout>=3) && (nargout<=6)) && (nargin<9)) ...
    || ((nargout>=7) && (nargin<11))
    nargin
    nargout
    print_usage ...
(["[H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx,d3Hdwdydx]= ...\n", ...
 " schurOneMAPlattice2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk,d2Adydx,d2Capdydx)"]);
  endif

  % Initialise
  w=w(:);
  Nw=length(w);
  expjw=exp(j*w);
  jexpjw=j*expjw;
  Nk=rows(A);
  H=[];
  dHdw=[];
  dHdk=[];
  d2Hdwdk=[];
  diagd2Hdk2=[];
  diagd3Hdwdk2=[];
  d2Hdydx=[];
  d3Hdwdydx=[];
  if nargout>=1
    H=zeros(Nw,1);
  endif
  if nargout>=2
    dHdw=zeros(Nw,1);
  endif
  if nargout>=3
    dHdk=zeros(Nw,Nk);
  endif
  if nargout>=4
    d2Hdwdk=zeros(Nw,Nk);
  endif
  if nargout>=5
    diagd2Hdk2=zeros(Nw,Nk);
  endif
  if nargout>=6
    diagd3Hdwdk2=zeros(Nw,Nk);
  endif
  if nargout>=7
    d2Hdydx=zeros(Nw,Nk,Nk);
  endif
  if nargout>=8
    d3Hdwdydx=zeros(Nw,Nk,Nk);
  endif
    
  if exist("complex_zhong_inverse","file") == 3
    zhong_hndl=@complex_zhong_inverse;
  else
    warning("Using builtin function inv()!");
    zhong_hndl=@inv;
  endif
    
  % Loop over w calculating the complex response
  for l=1:Nw,

    % Find the resolvent at w
    R=zhong_hndl((expjw(l)*eye(Nk))-A);
    RR=R*R;
    RB=R*B;
    RRB=R*RB;
    CapR=Cap*R;
    CapRB=Cap*RB;
    CapRR=Cap*RR;
    CapRRB=Cap*RRB;
  
    if nargout>=1
      H(l)=CapRB+Dap;
    endif
    if nargout>=2
      dHdw(l)=-jexpjw(l).*CapRRB;
    endif
    if nargout>=3
      for m=1:Nk
        % For the one-multiplier Schur lattice only dBdk{Nk}(Nk) is non-zero
        dHdk(l,m)=(dCapdk{m}*RB)+(CapR*dAdk{m}*RB);
      endfor
      dHdk(l,Nk)=dHdk(l,Nk)+(CapR*dBdk{Nk})+dDapdk{Nk};
    endif
    if nargout>=4
      for m=1:Nk
        d2Hdwdk(l,m)= ...
            -jexpjw(l)*((dCapdk{m}*RRB)+(CapRR*dAdk{m}*RB)+(CapR*dAdk{m}*RRB));
      endfor
      d2Hdwdk(l,Nk)=d2Hdwdk(l,Nk)-(j*expjw(l)*CapRR*dBdk{Nk});
    endif
    if nargout>=5
      for m=1:Nk 
        diagd2Hdk2(l,m)=(2*dCapdk{m}*R*dAdk{m}*RB)    + ...
                        (2*CapR*dAdk{m}*R*dAdk{m}*RB);
      endfor
      diagd2Hdk2(l,Nk)=diagd2Hdk2(l,Nk) + (2*dCapdk{Nk}*R*dBdk{Nk}) + ...
                                          (2*CapR*dAdk{Nk}*R*dBdk{Nk});
    endif
    if nargout>=6
      for m=1:Nk 
        diagd3Hdwdk2(l,m)=-jexpjw(l)*( (2*dCapdk{m}*R*dAdk{m}*RRB)    + ...
                                       (2*dCapdk{m}*RR*dAdk{m}*RB)    + ...
                                       (2*CapR*dAdk{m}*R*dAdk{m}*RRB) + ...
                                       (2*CapR*dAdk{m}*RR*dAdk{m}*RB) + ...
                                       (2*CapRR*dAdk{m}*R*dAdk{m}*RB)   );
      endfor
      diagd3Hdwdk2(l,Nk)=diagd3Hdwdk2(l,Nk) + ...
                         (-jexpjw(l)*( (2*dCapdk{Nk}*RR*dBdk{Nk})    + ...
                                       (2*CapR*dAdk{Nk}*RR*dBdk{Nk}) + ...
                                       (2*CapRR*dAdk{Nk}*R*dBdk{Nk})   ));
    endif
    if nargout>=7
      for m=1:Nk
        for n=m:Nk
          d2Hdydx(l,m,n)= (d2Capdydx{m,n}*RB)         + ...
                          (dCapdk{m}*R*dAdk{n}*RB)    + ...
                          (dCapdk{n}*R*dAdk{m}*RB)    + ...
                          (CapR*dAdk{m}*R*dAdk{n}*RB) + ...
                          (CapR*dAdk{n}*R*dAdk{m}*RB) + ...
                          (CapR*d2Adydx{m,n}*RB);
          d2Hdydx(l,n,m) = d2Hdydx(l,m,n);
        endfor
      endfor
      % dAdk is non-zero for 1<=m<=Nk and dBdk is non-zero for Nk
      for m=1:(Nk-1)
        d2Hdydx(l,m,Nk)=d2Hdydx(l,m,Nk)            + ...
                        (dCapdk{m}*R*dBdk{Nk})     + ...
                        (CapR*dAdk{m}*R*dBdk{Nk});
        d2Hdydx(l,Nk,m)=d2Hdydx(l,m,Nk);
      endfor
      d2Hdydx(l,Nk,Nk)=d2Hdydx(l,Nk,Nk)            + ...
                       (2*dCapdk{Nk}*R*dBdk{Nk})   + ... 
                       (2*CapR*dAdk{Nk}*R*dBdk{Nk});
    endif
    
    if nargout>=8
      for m=1:Nk
        for n=m:Nk
          d3Hdwdydx(l,m,n) = -jexpjw(l)*( (d2Capdydx{m,n}*RRB)         + ...
                                          (CapRR*d2Adydx{m,n}*RB)      + ...
                                          (CapR*d2Adydx{m,n}*RRB)      + ...
                                          (dCapdk{m}*RR*dAdk{n}*RB)    + ...
                                          (dCapdk{m}*R*dAdk{n}*RRB)    + ...
                                          (dCapdk{n}*RR*dAdk{m}*RB)    + ...
                                          (dCapdk{n}*R*dAdk{m}*RRB)    + ...
                                          (CapRR*dAdk{m}*R*dAdk{n}*RB) + ...
                                          (CapR*dAdk{m}*RR*dAdk{n}*RB) + ...
                                          (CapR*dAdk{m}*R*dAdk{n}*RRB) + ...
                                          (CapRR*dAdk{n}*R*dAdk{m}*RB) + ...
                                          (CapR*dAdk{n}*RR*dAdk{m}*RB) + ...
                                          (CapR*dAdk{n}*R*dAdk{m}*RRB)   );
          d3Hdwdydx(l,n,m) = d3Hdwdydx(l,m,n);
        endfor
      endfor
      % dAdk is non-zero for 1<=m<=Nk and dBdk is non-zero for Nk
      for m=1:(Nk-1),
        d3Hdwdydx(l,m,Nk) = d3Hdwdydx(l,m,Nk)                        + ...
                            (-jexpjw(l)*( (dCapdk{m}*RR*dBdk{Nk})    + ...
                                          (CapR*dAdk{m}*RR*dBdk{Nk}) + ... 
                                          (CapRR*dAdk{m}*R*dBdk{Nk})   ));
        d3Hdwdydx(l,Nk,m) = d3Hdwdydx(l,m,Nk);
      endfor
      d3Hdwdydx(l,Nk,Nk)=d3Hdwdydx(l,Nk,Nk)                             + ...
                            (-jexpjw(l)*( (2*dCapdk{Nk}*RR*dBdk{Nk})    + ...
                                          (2*CapR*dAdk{Nk}*RR*dBdk{Nk}) + ... 
                                          (2*CapRR*dAdk{Nk}*R*dBdk{Nk})   ));
    endif
   
  endfor

endfunction

