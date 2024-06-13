function vS=directFIRhilbert_slb_update_constraints(A,Adu,Adl,ctol)
% vS=directFIRhilbert_slb_update_constraints(A,Adu,Adl,ctol)

% Copyright (C) 2017-2024 Robert G. Jenssen
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
  if (nargin ~= 4) || (nargout ~= 1)
    print_usage ...
      ("vS=directFIRhilbert_slb_update_constraints(A,Adu,Adl,ctol)");
  endif
  if length(A) ~= length(Adu)
    error("length(A) ~= length(Adu)");
  endif
  if length(A) ~= length(Adl)
    error("length(A) ~= length(Adl)");
  endif
  
  vS=directFIRhilbert_slb_set_empty_constraints();

  % Find amplitude constraint violations
  if ~isempty(A)
    % Find amplitude lower constraint violations
    vAl=local_max(Adl-A);
    vS.al=vAl(find((Adl(vAl)-A(vAl))>ctol));
    % Find amplitude upper constraint violations
    vAu=local_max(A-Adu);
    vS.au=vAu(find((A(vAu)-Adu(vAu))>ctol));
  endif

  % Do not want size 0x1 ?!?!?!
  if isempty(vS.al) 
    vS.al=[];
  endif
  if isempty(vS.au) 
    vS.au=[];
  endif

endfunction
