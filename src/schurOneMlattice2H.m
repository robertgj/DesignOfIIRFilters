function [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2] = ...
  schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc)
% [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2] = ...
%   schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc)
% Find the complex response and partial derivatives for a Schur one-multiplier
% lattice filter. The outputs are intermediate results in the calculation of
% the squared-magnitude and group-delay responses and partial derivatives.
% The state transition matrix, A, is assumed to lower-Hessenberg.
% Inputs:
%  w - column vector of angular frequencies   
%  A,B,C,D - state variable description of the lattice filter
%  dAdkc,dBdkc,dCdkc,dDdkc - cell arrays of the gradients of A,B,C,D wrt [k,c]
% Outputs:
%  H - complex vector of the response over w
%  dHdkc - complex matrix of the gradients of H wrt [k,c] over w
%  dHdw - complex vector derivative of H wrt w
%  d2Hdwdkc - complex matrix of the mixed second derivatives of H
%  diagd2Hdkc2 - complex matrix of the diagonal of the matrix of second
%                derivatives of H wrt [k,c]
%  diagd3Hdwdkc2 - complex matrix of the diagonal of the matrix of second
%                  derivatives of H wrt [k,c] and wrt w

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

warning("Using Octave m-file version of function schurOneMlattice2H");
  
  % Sanity checks
  if (nargin>9) || (nargout>6) ...
    || ((nargout<=2) && (nargin<5)) ...
    || ((nargout>2) && (nargin<9))
    print_usage("[H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2] = ...\n\
                   schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc)");
  endif
  if nargin<=5
    dAdkc=[];dBdkc=[];dCdkc=[];dDdkc=[];
  endif

  % Loop over w calculating the complex response then
  % convert the resulting cell array to the output matrixes
  schurOneMlattice2H_loop([],A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
  if nargout==1
    H=arrayfun(@schurOneMlattice2H_loop,w,'UniformOutput',true);
  elseif nargout==2
    [H,dHdw]=arrayfun(@schurOneMlattice2H_loop,w,'UniformOutput',true);
  elseif nargout==3
    [H,dHdw,dHdkc]=arrayfun(@schurOneMlattice2H_loop,w,'UniformOutput',false);
    H=cell2mat(H);
    dHdw=cell2mat(dHdw);
    dHdkc=cell2mat(dHdkc);
  elseif nargout==4
    [H,dHdw,dHdkc,d2Hdwdkc] = ...
      arrayfun(@schurOneMlattice2H_loop,w,'UniformOutput',false);
    H=cell2mat(H);
    dHdw=cell2mat(dHdw);
    dHdkc=cell2mat(dHdkc);
    d2Hdwdkc=cell2mat(d2Hdwdkc);
  elseif nargout==5
    [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2] = ...
      arrayfun(@schurOneMlattice2H_loop,w,'UniformOutput',false);
    H=cell2mat(H);
    dHdw=cell2mat(dHdw);
    dHdkc=cell2mat(dHdkc);
    d2Hdwdkc=cell2mat(d2Hdwdkc);
    diagd2Hdkc2=cell2mat(diagd2Hdkc2);
  else
    [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2] = ...
      arrayfun(@schurOneMlattice2H_loop,w,'UniformOutput',false);
    H=cell2mat(H);
    dHdw=cell2mat(dHdw);
    dHdkc=cell2mat(dHdkc);
    d2Hdwdkc=cell2mat(d2Hdwdkc);
    diagd2Hdkc2=cell2mat(diagd2Hdkc2);
    diagd3Hdwdkc2=cell2mat(diagd3Hdwdkc2);
  endif
endfunction

function [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2] = ...
           schurOneMlattice2H_loop(w,_A,_B,_C,_D,_dAdkc,_dBdkc,_dCdkc,_dDdkc)
  
  persistent A B C D dAdkc dBdkc dCdkc dDdkc
  persistent is_lower_hessenberg Nkc Nk dCdc dDdc
  persistent init_done=false
  if nargin==9
    A=_A; B=_B; C=_C; D=_D;
    dAdkc=_dAdkc; dBdkc=_dBdkc; dCdkc=_dCdkc; dDdkc=_dDdkc;
    if (nargout<0) || (nargout>5)
      error("(nargout<0) || (nargout>5)");
    endif
    Nkc=length(dAdkc);
    Nk=rows(A);
    % Assumptions for a one-multiplier lattice
    A_is_lower_hessenberg=all(all(triu(A,2)==0));
    if ~A_is_lower_hessenberg
      error("Expected A to be lower Hessenberg!");
    endif
    dCdc=zeros(Nk,Nk);
    init_done=true;
    return;
  elseif init_done==false
    error("init_done==false");
  endif
  if ~isscalar(w)
    error("w is not a scalar");
  endif
  
  % Find the resolvent
  R=complex_zhong_inverse((exp(j*w)*eye(Nk))-A);
  
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

  % Find dHdkc
  RB=R*B;
  dHdk=zeros(1,Nk);
  for m=1:Nk
    dHdk(m)=CR*dAdkc{m}*RB;
  endfor
  % For the one-multiplier Schur lattice only dBdk{Nk}(Nk) is non-zero
  dHdk(Nk)=dHdk(Nk)+(CR*dBdkc{Nk});
  % Construct dCdc and dDdc
  for l=1:Nk
    dCdc(l,l)=dCdkc{l+Nk}(l);
  endfor
  dDdc=dDdkc{Nkc};
  % Note the non-conjugate matrix transpose ".'"
  dHdc=[dCdc*RB;dDdc].';
  dHdkc=[dHdk,dHdc];
  if nargout==3
    return;
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
  d2Hdwdkc=[d2Hdwdk,d2Hdwdc];
  if nargout==4
    return;
  endif

  % Find diagd2Hdkc2 (diagonal of the the Hessian of H wrt [k,c]
  diagd2Hdkc2=zeros(1,Nkc);
  for m=1:Nk 
    diagd2Hdkc2(m)=2*CR*dAdkc{m}*R*dAdkc{m}*RB;
  endfor
  diagd2Hdkc2(Nk)=diagd2Hdkc2(Nk)+(2*CR*dAdkc{Nk}*R*dBdkc{Nk});
  if nargout==5
    return;
  endif

  % Find diagd3Hdwdkc2 (diagonal of the the partial derivative of H wrt [w,k,c]
  diagd3Hdwdkc2=zeros(1,Nkc);
  RR=R*R;
  for m=1:Nk 
    diagd3Hdwdkc2(m)=-2*jexpjw*((CRR*dAdkc{m}*R*dAdkc{m}*RB) + ...
                                (CR*dAdkc{m}*RR*dAdkc{m}*RB) + ...
                                (CR*dAdkc{m}*R*dAdkc{m}*RRB));


  endfor
  diagd3Hdwdkc2(Nk)=diagd3Hdwdkc2(Nk)-(2*jexpjw*((CRR*dAdkc{Nk}*R*dBdkc{Nk})+...
                                                 (CR*dAdkc{Nk}*RR*dBdkc{Nk})));

endfunction
