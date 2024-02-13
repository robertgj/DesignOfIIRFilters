function [next_vR,next_vS,exchanged] = ...
          schurNSPAlattice_slb_exchange_constraints(vS,vR,Asq,Asqdu,Asqdl, ...
                                                      T,Tdu,Tdl,P,Pdu,Pdl,tol)
% [next_vR,next_vS,exchanged] = ...
%  schurNSPAlattice_slb_exchange_constraints(vS,vR,Asq,Asqdu,Asqdl, ...
%                                              T,Tdu,Tdl,P,Pdu,Pdl,tol)
% Check for violation of the constraints in vR. If any constraints are violated
% then move the constraint with the greatest violation from vR to vS.

% Copyright (C) 2023-2024 Robert G. Jenssen
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
  if (nargin ~= 12) || (nargout ~= 3)
    print_usage("[next_vR,next_vS,exchanged]= ...\n\
schurNSPAlattice_slb_exchange_constraints(vS,vR,Asq,Asqdu,Asqdl, ...\n\
                                            T,Tdu,Tdl,P,Pdu,Pdl,tol)");
  endif
  if all(isfield(vS,{"al","au","tl","tu","pl","pu"})) == false
    error("Expect fields vS.al, vS.au, vS.tl, vS.tu, vS.pl and vS.pu");
  endif
  if all(isfield(vR,{"al","au","tl","tu","pl","pu"})) == false
    error("Expect fields vR.al, vR.au, vR.tl, vR.tu, vR.pl and vR.pu");
  endif
  if isempty(Asq) && isempty(T) && isempty(P)
    error("Asq,T and P are empty");
  endif
  if length(Asq) ~= length(Asqdu)
    error("length(Asq) ~= length(Asqdu)");
  endif
  if length(Asq) ~= length(Asqdl)
    error("length(Asq) ~= length(Asqdl)");
  endif
  if length(T) ~= length(Tdu)
    error("length(T) ~= length(Tdu)");
  endif
  if length(Tdu) ~= length(Tdl)
    error("length(Tdu) ~= length(Tdl)");
  endif
  if length(P) ~= length(Pdu)
    error("length(P) ~= length(Pdu)");
  endif
  if length(Pdu) ~= length(Pdl)
    error("length(Pdu) ~= length(Pdl)");
  endif

  % Initialise
  next_vR = vR;
  next_vS = vS;
  exchanged = false; 

  % Amplitude constraints
  vAsql_max=-inf;
  vAsql_maxi=[];
  vAsqu_max=-inf;
  vAsqu_maxi=[];
  if ~isempty(Asq)
    % Amplitude lower constraint
    Asql=Asq(vR.al);
    Asqdl=Asqdl(vR.al);  
    vAsql=[];
    if ~isempty(vR.al)
      vAsql=find((Asqdl-Asql)>tol);
      if ~isempty(vAsql)
        exchanged = true;
        [vAsql_max,vAsql_maxi]=max(Asqdl-Asql-tol);
      endif
    endif
    % Amplitude upper constraint
    Asqu=Asq(vR.au); 
    Asqdu=Asqdu(vR.au); 
    vAsqu=[];
    if ~isempty(vR.au)
      vAsqu=find((Asqu-Asqdu)>tol);
      if ~isempty(vAsqu)
        exchanged = true;
        [vAsqu_max,vAsqu_maxi]=max(Asqu-Asqdu-tol);
      endif
    endif
  endif

  % Group delay constraints
  vTl_max=-inf;
  vTl_maxi=[];
  vTu_max=-inf;
  vTu_maxi=[];
  if ~isempty(T)
    % Group delay lower constraint
    Tl=T(vR.tl);
    Tdl=Tdl(vR.tl);  
    vTl=[];
    if ~isempty(vR.tl)
      vTl=find((Tdl-Tl)>tol);
      if ~isempty(vTl)
        exchanged = true;
        [vTl_max,vTl_maxi]=max(Tdl-Tl-tol);
      endif 
    endif
    % Group delay upper constraint
    Tu=T(vR.tu);
    Tdu=Tdu(vR.tu); 
    vTu=[];
    if ~isempty(vR.tu)
      vTu=find((Tu-Tdu)>tol);
      if ~isempty(vTu)
        exchanged = true;
        [vTu_max,vTu_maxi]=max(Tu-Tdu-tol);
      endif
    endif
  endif
  
  % Phase constraints
  vPl_max=-inf;
  vPl_maxi=[];
  vPu_max=-inf;
  vPu_maxi=[];
  if ~isempty(P)
    % Phase lower constraint
    Pl=P(vR.pl);
    Pdl=Pdl(vR.pl);  
    vPl=[];
    if ~isempty(vR.pl)
      vPl=find((Pdl-Pl)>tol);
      if ~isempty(vPl)
        exchanged = true;
        [vPl_max,vPl_maxi]=max(Pdl-Pl-tol);
      endif 
    endif
    % Phase upper constraint
    Pu=P(vR.pu);
    Pdu=Pdu(vR.pu); 
    vPu=[];
    if ~isempty(vR.pu)
      vPu=find((Pu-Pdu)>tol);
      if ~isempty(vPu)
        exchanged = true;
        [vPu_max,vPu_maxi]=max(Pu-Pdu-tol);
      endif
    endif
  endif
  
  % Return if no exchange
  if exchanged == false
    printf("No vR constraints violated. No exchange with vS.\n");
    return;
  endif

  % Find the most violated constraint in vR
  [violation, most_violated] = ...
    max([vAsql_max, vAsqu_max, vTl_max, vTu_max, vPl_max, vPu_max]);

  % Move the most violated constraint to vS
  if most_violated == 1
    next_vS.al=unique([vS.al;vR.al(vAsql_maxi)]);
    next_vR.al(vAsql_maxi)=[];
    printf("Exchanged constraint from vR.al(%d) to vS\n",vR.al(vAsql_maxi));
  elseif most_violated == 2
    next_vS.au=unique([vS.au;vR.au(vAsqu_maxi)]);
    next_vR.au(vAsqu_maxi)=[];
    printf("Exchanged constraint from vR.au(%d) to vS\n",vR.au(vAsqu_maxi));
  elseif most_violated == 3
    next_vS.tl=unique([vS.tl;vR.tl(vTl_maxi)]);
    next_vR.tl(vTl_maxi)=[];
    printf("Exchanged constraint from vR.tl(%d) to vS\n",vR.tl(vTl_maxi));
  elseif most_violated == 4
    next_vS.tu=unique([vS.tu;vR.tu(vTu_maxi)]);
    next_vR.tu(vTu_maxi)=[];
    printf("Exchanged constraint from vR.tu(%d) to vS\n",vR.tu(vTu_maxi));
  elseif most_violated == 5
    next_vS.pl=unique([vS.pl;vR.pl(vPl_maxi)]);
    next_vR.pl(vPl_maxi)=[];
    printf("Exchanged constraint from vR.pl(%d) to vS\n",vR.pl(vPl_maxi));
  elseif most_violated == 6
    next_vS.pu=unique([vS.pu;vR.pu(vPu_maxi)]);
    next_vR.pu(vPu_maxi)=[];
    printf("Exchanged constraint from vR.pu(%d) to vS\n",vR.pu(vPu_maxi));
  else
    error("Illegal max. position!?!");
  endif

endfunction
