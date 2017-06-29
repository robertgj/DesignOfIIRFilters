function vS=parallel_allpass_slb_update_constraints ...
              (A2,A2du,A2dl,Wa,T,Tdu,Tdl,Wt,tol)

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
  if (nargin != 9) || (nargout != 1)
    print_usage("vS=parallel_allpass_slb_update_constraints ...\n\
      (A2,A2du,A2dl,Wa,T,Tdu,Tdl,Wt,tol)");
  endif
  if length(A2) ~= length(A2du)
    error("length(A2) ~= length(A2du)");
  endif
  if length(A2) ~= length(A2dl)
    error("length(A2) ~= length(A2dl)");
  endif
  if length(A2) ~= length(Wa)
    error("length(A2) ~= length(Wa)");
  endif
  if length(T) < length(Tdu)
    error("length(T) < length(Tdu)");
  endif
  if length(Tdu) ~= length(Tdl)
    error("length(Tdu) ~= length(Tdl)");
  endif
  if length(Tdl) ~= length(Wt)
    error("length(Tdl) ~= length(Wt)");
  endif

  % Find amplitude lower constraint violations
  if isempty(A2dl)
    vS.al=[];
  else
    vA2l=local_max(A2dl-A2);
    vS.al=vA2l(find((A2dl(vA2l)-A2(vA2l))>tol));
    vS.al=vS.al(find(Wa(vS.al)!=0));
  endif

  % Find amplitude upper constraint violations
  if isempty(A2du)
    vS.au=[];
  else
    vA2u=local_max(A2-A2du);
    vS.au=vA2u(find((A2(vA2u)-A2du(vA2u))>tol));
    vS.au=vS.au(find(Wa(vS.au)!=0));
  endif

  % Find group delay lower constraint violations
  if isempty(Tdl)
    vS.tl=[];
  else
    vTl=local_max(Tdl-T(1:length(Wt)));
    vS.tl=vTl(find((Tdl(vTl)-T(vTl))>tol));
    vS.tl=vS.tl(find(Wt(vS.tl)!=0));
  endif
  
  % Find group delay upper constraint violations
  if isempty(Tdu)
    vS.tu=[];
  else
    vTu=local_max(T(1:length(Wt))-Tdu);
    vS.tu=vTu(find((T(vTu)-Tdu(vTu))>tol));
    vS.tu=vS.tu(find(Wt(vS.tu)!=0));
  endif

  % Do not want size 0x1 ?!?!?!
  if isempty(vS.al) 
    vS.al=[];
  endif
  if isempty(vS.au) 
    vS.au=[];
  endif
  if isempty(vS.tl) 
    vS.tl=[];
  endif
  if isempty(vS.tu) 
    vS.tu=[];
  endif

endfunction
