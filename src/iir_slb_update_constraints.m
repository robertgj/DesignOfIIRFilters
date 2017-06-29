function vS=iir_slb_update_constraints(x,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                                       ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt, ...
                                       wp,Pdu,Pdl,Wp,tol)

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

if (nargin != 23) || (nargout != 1)
  print_usage("vS=iir_slb_update_constraints(x,U,V,M,Q,R,...\n\
         wa,Adu,Adl,Wa,ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt,wp,Pdu,Pdl,Wp,tol)");
endif

% Amplitude response
A=iirA(wa,x,U,V,M,Q,R);

% Find amplitude lower constraint violations with local_max
vAl=local_max(Adl-A);
vS.al=vAl(find((Adl(vAl)-A(vAl))>tol));
vS.al=vS.al(find(Wa(vS.al)!=0));

% Find amplitude upper constraint violations
vAu=local_max(A-Adu);
vS.au=vAu(find((A(vAu)-Adu(vAu))>tol));
vS.au=vS.au(find(Wa(vS.au)!=0));

% Stop-band mplitude response
S=iirA(ws,x,U,V,M,Q,R);

% Find stop-band amplitude lower constraint violations with local_max
vSl=local_max(Sdl-S);
vS.sl=vSl(find((Sdl(vSl)-S(vSl))>tol));
vS.sl=vS.sl(find(Ws(vS.sl)!=0));

% Find stop-band amplitude upper constraint violations
vSu=local_max(S-Sdu);
vS.su=vSu(find((S(vSu)-Sdu(vSu))>tol));
vS.su=vS.su(find(Ws(vS.su)!=0));

% Group delay response
T=iirT(wt,x,U,V,M,Q,R);

% Find group delay lower constraint violations
vTl=local_max(Tdl-T);
vS.tl=vTl(find((Tdl(vTl)-T(vTl))>tol));
vS.tl=vS.tl(find(Wt(vS.tl)!=0));

% Find group delay upper constraint violations
vTu=local_max(T-Tdu);
vS.tu=vTu(find((T(vTu)-Tdu(vTu))>tol));
vS.tu=vS.tu(find(Wt(vS.tu)!=0));

% Phase response
P=iirP(wp,x,U,V,M,Q,R);

% Find phase response lower constraint violations
vPl=local_max(Pdl-P);
vS.pl=vPl(find((Pdl(vPl)-P(vPl))>tol));
vS.pl=vS.pl(find(Wp(vS.pl)!=0));

% Find phase response upper constraint violations
vPu=local_max(P-Pdu);
vS.pu=vPu(find((P(vPu)-Pdu(vPu))>tol));
vS.pu=vS.pu(find(Wp(vS.pu)!=0));

% Do not want size 0x1 ?!?!?!
if isempty(vS.al) 
  vS.al=[];
endif
if isempty(vS.au) 
  vS.au=[];
endif
if isempty(vS.sl) 
  vS.sl=[];
endif
if isempty(vS.su) 
  vS.su=[];
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
