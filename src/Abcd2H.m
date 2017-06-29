function [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2] = ...
  Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx)
% [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2] = ...
%   Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx)
%
% Find the complex response and partial derivatives of a state variable
% filter with respect to a vector of coefficients. The vector x represents
% internal coefficients of the filter. For example, for a one-multiplier
% Schur lattice filter, x may represent the concatenated vector [k,c] where
% k represents the lattice multipliers and c represents the tap coefficients.
% The outputs of this function are intermediate results in the calculation
% of the squared-magnitude and group-delay responses and partial derivatives
% of the coefficients of the original filter. The state variable filter A,B,C
% and D matrixes are assumed to be linear in the x coefficients so that the
% second derivatives d2Adx2,etc are all zero.
%
% Inputs:
%  w - column vector of angular frequencies   
%  A,B,C,D - state variable description of the filter
%  dAdx,dBdx,dCdx,dDdx - cell arrays of the gradients of A,B,C and D wrt x
%
% Outputs:
%  H - complex vector of the response over w
%  dHdw - complex vector derivative of H wrt w
%  dHdx - complex matrix of the gradients of H wrt x over w
%  d2Hdwdx - complex matrix of the mixed second derivatives of H
%  diagd2Hdx2 - complex matrix of the diagonal of the matrix of second
%               derivatives of H wrt x
%  diagd3Hdwdx2 - complex matrix of the diagonal of the matrix of second
%                 derivatives of H wrt x and w
%
% For each output the rows correspond to frequency vector, w, and the
% columns correspond to the coefficient vector, x.

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

  warning("Using Octave m-file version of function Abcd2H()!");
  
  % Sanity checks
  if (nargin>9) || (nargout>6) ...
    || ((nargout<=2) && (nargin<5)) ...
    || ((nargout>2) && (nargin<9))
    print_usage("[H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2] = ...\n\
                   Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx)");
  endif
  if nargin==5
    dAdx=[];dBdx=[];dCdx=[];dDdx=[];
  endif
  if isempty(A)
    error("A is empty");
  endif
  if (rows(A) ~= columns(A))
    error("rows(A) ~= columns(A)");
  endif
  if (rows(A) ~= rows(B))
    error("rows(A) ~= rows(B)");
  endif
  if (rows(A) ~= columns(C))
    error("rows(A) ~= columns(C)");
  endif
  if (length(D) ~= 1)
    error("length(D) ~= 1");
  endif

  % Initialise
  w=w(:);
 
  % Loop over w calculating the complex response then
  % convert the resulting cell array to the output matrixes
  Abcd2H_loop([],A,B,C,D,dAdx,dBdx,dCdx,dDdx);
  if nargout==1
    H=arrayfun(@Abcd2H_loop,w,'UniformOutput',true);
  elseif nargout==2
    [H,dHdw]=arrayfun(@Abcd2H_loop,w,'UniformOutput',true);
  elseif nargout==3
    [H,dHdw,dHdx]=arrayfun(@Abcd2H_loop,w,'UniformOutput',false);
    H=cell2mat(H);
    dHdw=cell2mat(dHdw);
    dHdx=cell2mat(dHdx);
  elseif nargout==4
    [H,dHdw,dHdx,d2Hdwdx] = ...
      arrayfun(@Abcd2H_loop,w,'UniformOutput',false);
    H=cell2mat(H);
    dHdw=cell2mat(dHdw);
    dHdx=cell2mat(dHdx);
    d2Hdwdx=cell2mat(d2Hdwdx);
  elseif nargout==5
    [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2] = ...
      arrayfun(@Abcd2H_loop,w,'UniformOutput',false);
    H=cell2mat(H);
    dHdw=cell2mat(dHdw);
    dHdx=cell2mat(dHdx);
    d2Hdwdx=cell2mat(d2Hdwdx);
    diagd2Hdx2=cell2mat(diagd2Hdx2);
  else
    [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2] = ...
      arrayfun(@Abcd2H_loop,w,'UniformOutput',false);
    H=cell2mat(H);
    dHdw=cell2mat(dHdw);
    dHdx=cell2mat(dHdx);
    d2Hdwdx=cell2mat(d2Hdwdx);
    diagd2Hdx2=cell2mat(diagd2Hdx2);
    diagd3Hdwdx2=cell2mat(diagd3Hdwdx2);
  endif
endfunction

function [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2] = ...
           Abcd2H_loop(w,_A,_B,_C,_D,_dAdx,_dBdx,_dCdx,_dDdx)
  
  persistent Nw A B C D dAdx dBdx dCdx dDdx Nout Nx Nk
  persistent init_done=false
  if nargin==9
    A=_A; B=_B; C=_C; D=_D;
    dAdx=_dAdx; dBdx=_dBdx; dCdx=_dCdx; dDdx=_dDdx;
    if (nargout<0) || (nargout>5)
      error("(nargout<0) || (nargout>5)");
    endif
    Nx=length(dAdx);
    Nk=rows(A);
    init_done=true;
    return;
  elseif init_done==false
    error("init_done==false");
  endif
  if ~isscalar(w)
    error("w is not a scalar");
  endif
  
  % Find the resolvent
  R=inv((exp(j*w)*eye(Nk))-A);
  
  % Find H
  CR=C*R;
  CRB=CR*B;
  H=CRB+D;
  if nargout==1
    return;
  endif

  % Find dHdw
  CRR=CR*R;
  CRRB=CRR*B;
  jexpjw=j*exp(j*w);
  dHdw=-jexpjw.*CRRB;
  if nargout==2
    return;
  endif

  % Find dHdx
  RB=R*B;
  dHdx=zeros(1,Nx);
  for l=1:Nx
    dHdx(l)=(dCdx{l}*RB)+(CR*dAdx{l}*RB)+(CR*dBdx{l})+dDdx{l};
  endfor
  if nargout==3
    return;
  endif

  % Find d2Hdwdx
  RRB=R*RB;
  d2Hdwdx=zeros(1,Nx);
  for l=1:Nx
    d2Hdwdx(l)=-jexpjw*((CRR*dAdx{l}*RB) + ...
                        (CR*dAdx{l}*RRB) + ...
                        (CRR*dBdx{l})    + ...
                        (dCdx{l}*RRB));
  endfor
  if nargout==4
    return;
  endif

  % Find diagd2Hdx2 (diagonal of the the Hessian of H wrt x)
  diagd2Hdx2=zeros(1,Nx);
  for l=1:Nx
    diagd2Hdx2(l)=(2*dCdx{l}*R*dAdx{l}*RB)    + ...
                  (2*dCdx{l}*R*dBdx{l})       + ...
                  (2*CR*dAdx{l}*R*dAdx{l}*RB) + ...
                  (2*CR*dAdx{l}*R*dBdx{l});
  endfor
  if nargout==5
    return;
  endif

  % Find diagd3Hdwdx2 (diagonal of the the partial derivatives of H wrt w,x)
  diagd3Hdwdx2=zeros(1,Nx);
  RR=R*R;
  for l=1:Nx
    diagd3Hdwdx2(l)=-2*jexpjw*((CRR*dAdx{l}*R*dAdx{l}*RB) + ...
                               (CR*dAdx{l}*RR*dAdx{l}*RB) + ...
                               (CR*dAdx{l}*R*dAdx{l}*RRB) + ...
                               (dCdx{l}*RR*dAdx{l}*RB)    + ...
                               (dCdx{l}*R*dAdx{l}*RRB)    + ...
                               (CRR*dAdx{l}*R*dBdx{l})    + ...
                               (CR*dAdx{l}*RR*dBdx{l})    + ...
                               (dCdx{l}*RR*dBdx{l}));
  endfor

endfunction
