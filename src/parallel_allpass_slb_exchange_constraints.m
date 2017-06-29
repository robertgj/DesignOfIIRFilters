function [next_vR,next_vS,exchanged] = ...
  parallel_allpass_slb_exchange_constraints(vS,vR,A2,A2du,A2dl,T,Tdu,Tdl,tol)
% [next_vR,next_vS,exchanged] = ...
%   parallel_allpass_slb_exchange_constraints(vS,vR,A2,A2du,A2dl,T,Tdu,Tdl,tol)
% Check for violation of the constraints in vR. If any constraints are violated
% then move the constraint with the greatest violation from vR to vS.

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

  % Sanity checks
  if (nargin != 9) || (nargout != 3)
    print_usage("[next_vR,next_vS,exchanged]= ...\n\
  parallel_allpass_slb_exchange_constraints(vS,vR,A2,A2du,A2dl,T,Tdu,Tdl,tol)");
  endif
  if all(isfield(vS,{"al","au","tl","tu"})) == false
    error("Expect fields vS.al, vS.au, vS.tl and vS.tu");
  endif
  if all(isfield(vR,{"al","au","tl","tu"})) == false
    error("Expect fields vR.al, vR.au, vR.tl and vR.tu");
  endif
  if length(A2) ~= length(A2du)
    error("length(A2) ~= length(A2du)");
  endif
  if length(A2) ~= length(A2dl)
    error("length(A2) ~= length(A2dl)");
  endif
  if length(T) ~= length(Tdu)
    error("length(T) ~= length(Tdu)");
  endif
  if length(Tdu) ~= length(Tdl)
    error("length(Tdu) ~= length(Tdl)");
  endif

  % Initialise
  next_vR = vR;
  next_vS = vS;
  exchanged = false; 

  % Amplitude lower constraint
  A2l=A2(vR.al);
  A2dl=A2dl(vR.al);  
  vA2l=[];
  vA2l_max=-inf;
  if !isempty(vR.al)
    vA2l=find((A2dl-tol)>A2l);
    if !isempty(vA2l)
      exchanged = true;
      [vA2l_max,vA2l_maxi]=max((A2dl-tol)-A2l);
    endif
  endif

  % Amplitude upper constraint
  A2u=A2(vR.au); 
  A2du=A2du(vR.au); 
  vA2u=[];
  vA2u_max=-inf;
  if !isempty(vR.au)
    vA2u=find(A2u>(A2du+tol));
    if !isempty(vA2u)
      exchanged = true;
      [vA2u_max,vA2u_maxi]=max(A2u-(A2du+tol));
    endif
  endif

  % Group delay lower constraint
  Tl=T(vR.tl);
  Tdl=Tdl(vR.tl);  
  vTl=[];
  vTl_max=-inf;
  if !isempty(vR.tl)
    vTl=find((Tdl-tol)>Tl);
    if !isempty(vTl)
      exchanged = true;
      [vTl_max,vTl_maxi]=max((Tdl-tol)-Tl);
    endif 
  endif

  % Group delay upper constraint
  Tu=T(vR.tu);
  Tdu=Tdu(vR.tu); 
  vTu_max=-inf;
  vTu=[];
  if !isempty(vR.tu)
    vTu=find(Tu>(Tdu+tol));
    if !isempty(vTu)
      exchanged = true;
      [vTu_max,vTu_maxi]=max(Tu-(Tdu+tol));
    endif
  endif

  % Return if no exchange
  if exchanged == false
    printf("No vR constraints violated. No exchange with vS.\n");
    return;
  endif

  % Find the most violated constraint in vR
  [violation, most_violated] = max([vA2l_max, vA2u_max, vTl_max, vTu_max]);

  % Move the most violated constraint to vS
  if most_violated == 1
    next_vS.al=unique([vS.al;vR.al(vA2l_maxi)]);
    next_vR.al(vA2l_maxi)=[];
    printf("Exchanged constraint from vR.al(%d) to vS\n",vR.al(vA2l_maxi));
  elseif most_violated == 2
    next_vS.au=unique([vS.au;vR.au(vA2u_maxi)]);
    next_vR.au(vA2u_maxi)=[];
    printf("Exchanged constraint from vR.au(%d) to vS\n",vR.au(vA2u_maxi));
  elseif most_violated == 3
    next_vS.tl=unique([vS.tl;vR.tl(vTl_maxi)]);
    next_vR.tl(vTl_maxi)=[];
    printf("Exchanged constraint from vR.tl(%d) to vS\n",vR.tl(vTl_maxi));
  elseif most_violated == 4
    next_vS.tu=unique([vS.tu;vR.tu(vTu_maxi)]);
    next_vR.tu(vTu_maxi)=[];
    printf("Exchanged constraint from vR.tu(%d) to vS\n",vR.tu(vTu_maxi));
  else
    error("Illegal max. position!?!");
  endif

endfunction
