function [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2] = ...
           schurOneMAPlattice2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk)
% [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2] = ...
%   schurOneMAPlattice2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk)
% Find the complex response and partial derivatives for an all-pass Schur
% one-multiplier lattice filter. The outputs are intermediate results in the
% calculation of the squared-magnitude and group-delay responses and partial
% derivatives. The state transition matrix, A, is assumed to lower-Hessenberg.
% Inputs:
%  w - column vector of angular frequencies   
%  A,B,Cap,Dap - state variable description of the allpass lattice filter
%  dAdk - cell array of matrixes of the differentials of A wrt k
%  dBdk - cell array of column vectors of the differentials of B wrt k
%  dCapdk - cell array of row vectors of the differentials of C wrt k
%  dDapdk - cell array of the scalar differential of Dap wrt k
% Outputs:
%  H - complex vector of response wrt w
%  dHdw - complex vector of the derivative of the complex response wrt w
%  dHdk - complex matrix of the derivative of the complex response wrt k and w
%  d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2 - complex matrixes of the mixed second
%                                    derivatives of the response
%
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
  
warning("Using Octave m-file version of function schurOneMAPlattice2H");
  
  % Sanity checks
  if (nargin>9) || (nargout>6) ...
    || ((nargout<=2) && (nargin<5)) ...
    || ((nargout>2) && (nargin<9))
    print_usage("[H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2] = ...\n\
      schurOneMAPlattice2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk)");
  endif
  if nargin<=5
    dAdk=[];dBdk=[];dCapdk=[];dDapdk=[];
  endif

  % Initialise
  w=w(:);
  Nw=length(w);
  Nk=length(dAdk);

  % Loop over w calculating the complex response
  schurOneMAPlattice2H_loop([],A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
  if nargout==1
    H=arrayfun(@schurOneMAPlattice2H_loop,w,'UniformOutput',true);
  elseif nargout==2
    [H,dHdw]=arrayfun(@schurOneMAPlattice2H_loop,w,'UniformOutput',true);
  elseif nargout==3
    [H,dHdw,dHdk]=arrayfun(@schurOneMAPlattice2H_loop,w,'UniformOutput',false);
    H=cell2mat(H);
    dHdw=cell2mat(dHdw);
    dHdk=cell2mat(dHdk);
  elseif nargout==4
    [H,dHdw,dHdk,d2Hdwdk] = ...
      arrayfun(@schurOneMAPlattice2H_loop,w,'UniformOutput',false);
    H=cell2mat(H);
    dHdw=cell2mat(dHdw);
    dHdk=cell2mat(dHdk);
    d2Hdwdk=cell2mat(d2Hdwdk);
  elseif nargout==5
    [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2] = ...
      arrayfun(@schurOneMAPlattice2H_loop,w,'UniformOutput',false);
    H=cell2mat(H);
    dHdw=cell2mat(dHdw);
    dHdk=cell2mat(dHdk);
    d2Hdwdk=cell2mat(d2Hdwdk);
    diagd2Hdk2=cell2mat(diagd2Hdk2);
  elseif nargout==6
    [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2] = ...
      arrayfun(@schurOneMAPlattice2H_loop,w,'UniformOutput',false);
    H=cell2mat(H);
    dHdw=cell2mat(dHdw);
    dHdk=cell2mat(dHdk);
    d2Hdwdk=cell2mat(d2Hdwdk);
    diagd2Hdk2=cell2mat(diagd2Hdk2);
    diagd3Hdwdk2=cell2mat(diagd3Hdwdk2);
  endif
endfunction

function [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2]= ...
  schurOneMAPlattice2H_loop(w,_A,_B,_Cap,_Dap,_dAdk,_dBdk,_dCapdk,_dDapdk)
  
  persistent Nw A B Cap Dap dAdk dBdk dCapdk dDapdk
  persistent H dHdw dHdk d2Hdwdk diagd2Hdk2 diagd3Hdwdk2 Nk
  persistent init_done=false
  if nargin==9
    A=_A; B=_B; Cap=_Cap; Dap=_Dap;
    dAdk=_dAdk; dBdk=_dBdk; dCapdk=_dCapdk; dDapdk=_dDapdk;
    if (nargout<0) || (nargout>4)
      error("(nargout<0) || (nargout>4)");
    endif
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
  R=complex_zhong_inverse((exp(j*w)*eye(rows(A)))-A);
  
  % Find H
  CapR=Cap*R;
  CapRB=CapR*B;
  H=CapRB+Dap;
  if nargout==1
    return;
  endif

  % Find dHdw
  CapRR=CapR*R;
  CapRRB=CapRR*B;
  jexpjw=j*exp(j*w);
  dHdw=-jexpjw.*CapRRB;
  if nargout==2
    return;
  endif

  % Find dHdk
  RB=R*B;
  dHdk=zeros(1,Nk);
  for m=1:Nk
    % For the one-multiplier Schur lattice only dBdk{Nk}(Nk) is non-zero
    dHdk(m)=(dCapdk{m}*RB)+(CapR*dAdk{m}*RB);
  endfor
  dHdk(Nk)=dHdk(Nk)+(CapR*dBdk{Nk})+dDapdk{Nk};
  if nargout==3
    return;
  endif

  % Find d2Hdwdk
  RRB=R*RB;
  d2Hdwdk=zeros(1,Nk);
  for m=1:Nk
    d2Hdwdk(m)=-jexpjw*((dCapdk{m}*RRB)+(CapRR*dAdk{m}*RB)+(CapR*dAdk{m}*RRB));
  endfor
  d2Hdwdk(Nk)=d2Hdwdk(Nk)-(jexpjw*CapRR*dBdk{Nk});
  if nargout==4
    return;
  endif

  % Find diagd2Hdk2 (diagonal of the the Hessian of H wrt k)
  diagd2Hdk2=zeros(1,Nk);
  for m=1:Nk 
    diagd2Hdk2(m)=2*((dCapdk{m}*R*dAdk{m}*RB)+(CapR*dAdk{m}*R*dAdk{m}*RB));
  endfor
  diagd2Hdk2(Nk)=diagd2Hdk2(Nk)+...
                 (2*((dCapdk{Nk}*R*dBdk{Nk})+(CapR*dAdk{Nk}*R*dBdk{Nk})));
  if nargout==5
    return;
  endif

  % Find diagd3Hdwdk2 (diagonal of the the partial derivative of H wrt [w,k])
  diagd3Hdwdk2=zeros(1,Nk);
  RR=R*R;
  for m=1:Nk 
    diagd3Hdwdk2(m)=-2*jexpjw*((CapRR*dAdk{m}*R*dAdk{m}*RB) + ...
                               (CapR*dAdk{m}*RR*dAdk{m}*RB) + ...
                               (CapR*dAdk{m}*R*dAdk{m}*RRB) + ...
                               (dCapdk{m}*RR*dAdk{m}*RB) + ...
                               (dCapdk{m}*R*dAdk{m}*RRB));
  endfor
  diagd3Hdwdk2(Nk)=diagd3Hdwdk2(Nk)-...
                    (2*jexpjw*((CapRR*dAdk{Nk}*R*dBdk{Nk})+...
                               (CapR*dAdk{Nk}*RR*dBdk{Nk})+...
                               (dCapdk{Nk}*RR*dBdk{Nk})));
                               
endfunction
