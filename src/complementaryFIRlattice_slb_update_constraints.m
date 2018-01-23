function vS=complementaryFIRlattice_slb_update_constraints ...
              (Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,P,Pdu,Pdl,Wp,tol)
% vS=complementaryFIRlattice_slb_update_constraints ...
%       (Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,P,Pdu,Pdl,Wp,tol)
  
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
  if (nargin != 13) || (nargout != 1)
    print_usage("vS=complementaryFIRlattice_slb_update_constraints ...\n\
      (Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,P,Pdu,Pdl,Wp,tol)");
  endif
  if length(Asq) ~= length(Asqdu)
    error("length(Asq) ~= length(Asqdu)");
  endif
  if length(Asq) ~= length(Asqdl)
    error("length(Asq) ~= length(Asqdl)");
  endif
  if length(Asq) ~= length(Wa)
    error("length(Asq) ~= length(Wa)");
  endif
  if length(T) ~= length(Tdu)
    error("length(T) ~= length(Tdu)");
  endif
  if length(Tdu) ~= length(Tdl)
    error("length(Tdu) ~= length(Tdl)");
  endif
  if length(Tdl) ~= length(Wt)
    error("length(Tdl) ~= length(Wt)");
  endif
  if length(P) ~= length(Pdu)
    error("length(P) ~= length(Pdu)");
  endif
  if length(Pdu) ~= length(Pdl)
    error("length(Pdu) ~= length(Pdl)");
  endif
  if length(Pdl) ~= length(Wp)
    error("length(Pdl) ~= length(Wp)");
  endif
  
  vS=complementaryFIRlattice_slb_set_empty_constraints();

  % Find amplitude constraint violations
  if ~isempty(Asq)
    % Find amplitude lower constraint violations
    vAsql=local_max(Asqdl-Asq);
    vS.al=vAsql(find((Asqdl(vAsql)-Asq(vAsql))>tol));
    vS.al=vS.al(find(Wa(vS.al)!=0));
    % Find amplitude upper constraint violations
    vAsqu=local_max(Asq-Asqdu);
    vS.au=vAsqu(find((Asq(vAsqu)-Asqdu(vAsqu))>tol));
    vS.au=vS.au(find(Wa(vS.au)!=0));
  endif

  % Find group delay constraint violations
  if ~isempty(T)
    % Find group delay lower constraint violations
    vTl=local_max(Tdl-T);
    vS.tl=vTl(find((Tdl(vTl)-T(vTl))>tol));
    vS.tl=vS.tl(find(Wt(vS.tl)!=0));
    % Find group delay upper constraint violations
    vTu=local_max(T-Tdu);
    vS.tu=vTu(find((T(vTu)-Tdu(vTu))>tol));
    vS.tu=vS.tu(find(Wt(vS.tu)!=0));
  endif

  % Find phase constraint violations
  if ~isempty(P)
    % Find phase lower constraint violations
    vPl=local_max(Pdl-P);
    vS.pl=vPl(find((Pdl(vPl)-P(vPl))>tol));
    vS.pl=vS.pl(find(Wp(vS.pl)!=0));
    % Find phase upper constraint violations
    vPu=local_max(P-Pdu);
    vS.pu=vPu(find((P(vPu)-Pdu(vPu))>tol));
    vS.pu=vS.pu(find(Wp(vS.pu)!=0));
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
  if isempty(vS.pl) 
    vS.pl=[];
  endif
  if isempty(vS.pu) 
    vS.pu=[];
  endif

endfunction
