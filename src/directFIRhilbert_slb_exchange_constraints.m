function [next_vR,next_vS,exchanged] = ...
           directFIRhilbert_slb_exchange_constraints(vS,vR,A,Adu,Adl,ctol)
% [next_vR,next_vS,exchanged] = ...
%  directFIRhilbert_slb_exchange_constraints(vS,vR,A,Adu,Adl,ctol)
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
  if (nargin ~= 6) || (nargout ~= 3)
    print_usage("[next_vR,next_vS,exchanged]= ...\n\
      directFIRhilbert_slb_exchange_constraints(vS,vR,A,Adu,Adl,ctol)");
  endif
  if all(isfield(vS,{"al","au"})) == false
    error("Expect fields vS.al and vS.au");
  endif
  if all(isfield(vR,{"al","au"})) == false
    error("Expect fields vR.al and vR.au");
  endif
  if isempty(A)
    error("A is empty");
  endif
  if length(A) ~= length(Adu)
    error("length(A) ~= length(Adu)");
  endif
  if length(A) ~= length(Adl)
    error("length(A) ~= length(Adl)");
  endif

  % Initialise
  next_vR = vR;
  next_vS = vS;
  exchanged = false; 

  % Amplitude constraints
  vAl_max=-inf;
  vAl_maxi=[];
  vAu_max=-inf;
  vAu_maxi=[];
  if ~isempty(A)
    % Amplitude lower constraint
    Al=A(vR.al);
    Adl=Adl(vR.al);  
    vAl=[];
    if ~isempty(vR.al)
      vAl=find((Adl-Al)>ctol);
      if ~isempty(vAl)
        exchanged = true;
        [vAl_max,vAl_maxi]=max(Adl-Al-ctol);
      endif
    endif
    % Amplitude upper constraint
    Au=A(vR.au); 
    Adu=Adu(vR.au); 
    vAu=[];
    if ~isempty(vR.au)
      vAu=find((Au-Adu)>ctol);
      if ~isempty(vAu)
        exchanged = true;
        [vAu_max,vAu_maxi]=max(Au-Adu-ctol);
      endif
    endif
  endif
  
  % Return if no exchange
  if exchanged == false
    printf("No vR constraints violated. No exchange with vS.\n");
    return;
  endif

  % Find the most violated constraint in vR
  [violation, most_violated] = max([vAl_max, vAu_max]);

  % Move the most violated constraint to vS
  if most_violated == 1
    next_vS.al=unique([vS.al;vR.al(vAl_maxi)]);
    next_vR.al(vAl_maxi)=[];
    printf("Exchanged constraint from vR.al(%d) to vS\n",vR.al(vAl_maxi));
  elseif most_violated == 2
    next_vS.au=unique([vS.au;vR.au(vAu_maxi)]);
    next_vR.au(vAu_maxi)=[];
    printf("Exchanged constraint from vR.au(%d) to vS\n",vR.au(vAu_maxi));
  else
    error("Illegal max. position!?!");
  endif

endfunction
