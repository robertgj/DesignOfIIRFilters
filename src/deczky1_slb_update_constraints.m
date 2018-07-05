function vS=deczky1_slb_update_constraints(x,U,V,M,Q,R, ...
                                           wa,Adu,Adl,Wa,wt,Tdu,Tdl,Wt,wx,tol)
% Copyright (C) 2018 Robert G. Jenssen
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

if (nargin != 16) || (nargout != 1)
  print_usage("vS=deczky1_slb_update_constraints(x,U,V,M,Q,R,...\n\
         wa,Adu,Adl,Wa,wt,Tdu,Tdl,Wt,wx,tol)");
endif

% Amplitude response
A=iirA(wa,x,U,V,M,Q,R);

% Find amplitude lower constraint violations with local_max
vAl=local_max((Adl-A).*(Wa!=0));
vS.al=vAl(find((Adl(vAl)-A(vAl))>tol));

% Find amplitude upper constraint violations
vAu=local_max((A-Adu).*(Wa!=0));
vS.au=vAu(find((A(vAu)-Adu(vAu))>tol));

% Group delay response
T=iirT(wt,x,U,V,M,Q,R);

% Find group delay lower constraint violations
vTl=local_max((Tdl-T).*(Wt!=0));
vS.tl=vTl(find((Tdl(vTl)-T(vTl))>tol));

% Find group delay upper constraint violations
vTu=local_max((T-Tdu).*(Wt!=0));
vS.tu=vTu(find((T(vTu)-Tdu(vTu))>tol));

% Derivative of amplitude response in transition band
delAdelw=iirdelAdelw(wx,x,U,V,M,Q,R);
vAx=local_max(delAdelw-tol);
vS.ax=vAx(find(delAdelw(vAx)>tol));

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
if isempty(vS.ax) 
  vS.ax=[];
endif

endfunction
