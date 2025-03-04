function [next_vR,next_vS,exchanged] = ...
  schurOneMlattice_slb_exchange_constraints ...
    (vS,vR,Asq,Asqdu,Asqdl,T,Tdu,Tdl,P,Pdu,Pdl,dAsqdw,Ddu,Ddl,ctol)
% [next_vR,next_vS,exchanged] = ...
%  schurOneMlattice_slb_exchange_constraints ...
%    (vS,vR,Asq,Asqdu,Asqdl,T,Tdu,Tdl,P,Pdu,Pdl,dAsqdw,Ddu,Ddl,ctol)
% Check for violation of the constraints in vR. If any constraints are violated
% then move the constraint with the greatest violation from vR to vS.

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

  % Sanity checks
  if (nargin ~= 15) || (nargout ~= 3)
    print_usage("[next_vR,next_vS,exchanged]= ...\n\
schurOneMlattice_slb_exchange_constraints ...\n\
  (vS,vR,Asq,Asqdu,Asqdl,T,Tdu,Tdl,P,Pdu,Pdl,dAsqdw,Ddu,Ddl,ctol)");
  endif
  if all(isfield(vS,{"al","au","tl","tu","pl","pu","dl","du"})) == false
    error("Expect vS fields al, au, tl, tu, pl, pu, dl and du");
  endif
  if all(isfield(vR,{"al","au","tl","tu","pl","pu","dl","du"})) == false
    error("Expect vR fields al, au, tl, tu, pl, pu, dl and du");
  endif
  if isempty(Asq) && isempty(T) && isempty(P) && isempty(dAsqdw)
    error("Asq, T, P and dAsqdw are empty");
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
  if length(dAsqdw) ~= length(Ddu)
    error("length(dAsqdw) ~= length(Ddu)");
  endif
  if length(Ddu) ~= length(Ddl)
    error("length(Ddu) ~= length(Ddl)");
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
      vAsql=find((Asqdl-Asql)>ctol);
      if ~isempty(vAsql)
        exchanged = true;
        [vAsql_max,vAsql_maxi]=max(Asqdl-Asql-ctol);
      endif
    endif
    % Amplitude upper constraint
    Asqu=Asq(vR.au); 
    Asqdu=Asqdu(vR.au); 
    vAsqu=[];
    if ~isempty(vR.au)
      vAsqu=find((Asqu-Asqdu)>ctol);
      if ~isempty(vAsqu)
        exchanged = true;
        [vAsqu_max,vAsqu_maxi]=max(Asqu-Asqdu-ctol);
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
      vTl=find((Tdl-Tl)>ctol);
      if ~isempty(vTl)
        exchanged = true;
        [vTl_max,vTl_maxi]=max(Tdl-Tl-ctol);
      endif 
    endif
    % Group delay upper constraint
    Tu=T(vR.tu);
    Tdu=Tdu(vR.tu); 
    vTu=[];
    if ~isempty(vR.tu)
      vTu=find((Tu-Tdu)>ctol);
      if ~isempty(vTu)
        exchanged = true;
        [vTu_max,vTu_maxi]=max(Tu-Tdu-ctol);
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
      vPl=find((Pdl-Pl)>ctol);
      if ~isempty(vPl)
        exchanged = true;
        [vPl_max,vPl_maxi]=max(Pdl-Pl-ctol);
      endif 
    endif
    % Phase upper constraint
    Pu=P(vR.pu);
    Pdu=Pdu(vR.pu); 
    vPu=[];
    if ~isempty(vR.pu)
      vPu=find((Pu-Pdu)>ctol);
      if ~isempty(vPu)
        exchanged = true;
        [vPu_max,vPu_maxi]=max(Pu-Pdu-ctol);
      endif
    endif
  endif
  
  % dAsqdw constraints
  vDl_max=-inf;
  vDl_maxi=[];
  vDu_max=-inf;
  vDu_maxi=[];
  if ~isempty(dAsqdw)
    % dAsqdw lower constraint
    Dl=dAsqdw(vR.dl);
    Ddl=Ddl(vR.dl);  
    vDl=[];
    if ~isempty(vR.dl)
      vDl=find((Ddl-Dl)>ctol);
      if ~isempty(vDl)
        exchanged = true;
        [vDl_max,vDl_maxi]=max(Ddl-Dl-ctol);
      endif 
    endif
    % Phase upper constraint
    Du=dAsqdw(vR.du);
    Ddu=Ddu(vR.du); 
    vDu=[];
    if ~isempty(vR.du)
      vDu=find((Du-Ddu)>ctol);
      if ~isempty(vDu)
        exchanged = true;
        [vDu_max,vDu_maxi]=max(Du-Ddu-ctol);
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
    max([vAsql_max, vAsqu_max, vTl_max, vTu_max, ...
         vPl_max, vPu_max, vDl_max, vDu_max]);

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
  elseif most_violated == 7
    next_vS.dl=unique([vS.dl;vR.dl(vDl_maxi)]);
    next_vR.dl(vDl_maxi)=[];
    printf("Exchanged constraint from vR.dl(%d) to vS\n",vR.dl(vDl_maxi));
  elseif most_violated == 8
    next_vS.du=unique([vS.du;vR.du(vDu_maxi)]);
    next_vR.du(vDu_maxi)=[];
    printf("Exchanged constraint from vR.du(%d) to vS\n",vR.du(vDu_maxi));
  else
    error("Illegal max. position!?!");
  endif

endfunction
