function [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx,d3Hdwdydx] = ...
           schurOneMAPlatticeDoublyPipelined2H(w,A,B,Cap,Dap,dAdk)
% [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx,d3Hdwdydx] = ...
%   schurOneMAPlatticeDoublyPipelined2H(w,A,B,Cap,Dap,dAdk)
% Find the complex response and partial derivatives with respect to
% frequency, w, and the reflection coefficients, k, for a doubly-pipelined
% all-pass Schur one-multiplier lattice filter. The B, Cap, Dap and dAdk
% matrixes are assumed to be constants. The dBdk, dCapdk and dDapdk
% derivatives wrt k are all zero. See Appendix J of DesignOfIIRFilters.pdf
%
% Inputs:
%  w - column vector of angular frequencies   
%  A,B,Cap,Dap - state variable description of the allpass lattice filter
%  dAdk - cell array of matrixes of the differentials of A wrt k
% Outputs:
%  H - complex column vector containing the frequency response 
%  dHdw - complex column vector of the derivative of the response wrt w
%  dHdk - complex matrix of the derivative of the response wrt k
%  d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2 - complex matrixes of the mixed second
%                                    derivatives of the response
%  d2Hdydx - complex matrix of the hessian of the response wrt the
%            reflection coefficients, k, with size [Nw,Nk,Nk]
%  d3Hdwdydx - complex matrix of the hessian of the response wrt the
%              reflection coefficients, k, and w with size [Nw,Nk,Nk]
  
% Copyright (C) 2024 Robert G. Jenssen
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
  if (nargin~=6) || (nargout>8)
    print_usage ...
    ("[H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx, d3Hdwdydx] = ...\n\
      schurOneMAPlatticeDoublyPipelined2H(w,A,B,Cap,Dap,dAdk)");
  endif

  % Sanity checks
  if rows(A) ~= columns(A)
    error("Expected rows(A) == columns(A)");
  endif
  if (rows(B) ~= rows(A)) || (columns(B) ~= 1)
    error("Expected rows(B) == rows(A) && columns(B) == 1");
  endif
  if (columns(Cap) ~= columns(A)) || (rows(Cap) ~= 1)
    error("Expected columns(Cap) == columns(A) && rows(Cap) == 1");
  endif
  if (columns(Cap) ~= columns(A)) || (rows(Cap) ~= 1)
    error("Expected columns(Cap) == columns(A) && rows(Cap) == 1");
  endif
  if (columns(Dap) ~= 1) || (rows(Dap) ~= 1)
    error("Expected columns(Dap) == 1 && rows(Dap) == 1");
  endif
  if rows(A) ~= ((2*length(dAdk))+2)
    error("Expected rows(A) == ((2*length(dAdk))+2)");
  endif
    
  % Initialise
  w=w(:);
  Nw=length(w);
  Nk=length(dAdk);
  Ns=rows(A);
  if Ns ~= ((2*Nk)+2)
    error("Expected Ns == ((2*Nk)+2)");
  endif
  dBdk=cell(Nk,1);
  dCapdk=cell(Nk,1);
  dDapdk=cell(1,1);
  for k=1:Nk,
    dBdk{k}=zeros(Ns,1);
    dCapdk{k}=zeros(1,Ns);
    dDapdk{k}=0;
  endfor

  % Loop over w calculating the complex response
  if nargout==1
    H=Abcd2H(w,A,B,Cap,Dap);
  elseif nargout==2
    [H,dHdw]=Abcd2H(w,A,B,Cap,Dap);
  elseif nargout==3
    [H,dHdw,dHdk]=Abcd2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
  elseif nargout==4
    [H,dHdw,dHdk,d2Hdwdk]=Abcd2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
  elseif nargout==5
    [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2]= ...
      Abcd2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
  elseif nargout==6
    [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2]= ...
      Abcd2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
  elseif nargout==7
    [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx]= ...
      Abcd2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
  elseif nargout==8
    [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx,d3Hdwdydx]= ...
      Abcd2H(w,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
  endif
  
endfunction
