function [next_vR,next_vS,exchanged] = ...
  iir_slb_exchange_constraints(vS,vR,x,U,V,M,Q,R,wa,Adu,Adl, ...
                               ws,Sdu,Sdl,wt,Tdu,Tdl,wp,Pdu,Pdl,ctol)
% [next_vR,next_vS,exchanged] = ...
%  iir_slb_exchange_constraints(vS,vR,x,U,V,M,Q,R,wa,Adu,Adl,...
%                               ws,Sdu,Sdl,wt,Tdu,Tdl,wp,Pdu,Pdl,ctol)
% Exchange constraints: calculate the new response and check 
% for violation of the constraints in vR. If any constraints 
% are violated then move the constraint with the greatest violation
% from vR to vS.

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

 
if (nargin ~= 21) || (nargout ~= 3)
  print_usage("[next_vR,next_vS,exchanged]=...\n\
         iir_slb_exchange_constraints(vS,vR, ...\n\
         x,U,V,M,Q,R,wa,Adu,Adl,ws,Sdu,Sdl,wt,Tdu,Tdl,wp,Pdu,Pdl,ctol)");
endif

next_vR = vR;
next_vS = vS;
exchanged = false;

% Amplitude lower constraint
vAl=[];Al=[];
vAl_max=-inf;
vAl_maxi=[];
if ~isempty(vR.al)
  Al=iirA(wa(vR.al),x,U,V,M,Q,R);
  vAl=find((Adl(vR.al)-ctol)>Al);
  if ~isempty(vAl)
    exchanged = true;
    [vAl_max,vAl_maxi]=max((Adl(vR.al)-ctol)-Al);
  endif
endif

% Amplitude upper constraint
vAu=[];Au=[];
vAu_max=-inf;
vAu_maxi=[];
if ~isempty(vR.au)
  Au=iirA(wa(vR.au),x,U,V,M,Q,R);
  vAu=find(Au>(Adu(vR.au)+ctol));
  if ~isempty(vAu)
    exchanged = true;
    [vAu_max,vAu_maxi]=max(Au-(Adu(vR.au)+ctol));
  endif
endif

% Amplitude stop-band lower constraint
vSl=[];Sl=[];
vSl_max=-inf;
vSl_maxi=[];
if ~isempty(vR.sl)
  Sl=iirA(ws(vR.sl),x,U,V,M,Q,R);
  vSl=find((Sdl(vR.sl)-ctol)>Sl);
  if ~isempty(vSl)
    exchanged = true;
    [vSl_max,vSl_maxi]=max((Sdl(vR.sl)-ctol)-Sl);
  endif
endif

% Amplitude stop-band upper constraint
vSu=[];Su=[];
vSu_max=-inf;
vSu_maxi=[];
if ~isempty(vR.su)
  Su=iirA(ws(vR.su),x,U,V,M,Q,R);
  vSu=find(Su>(Sdu(vR.su)+ctol));
  if ~isempty(vSu)
    exchanged = true;
    [vSu_max,vSu_maxi]=max(Su-(Sdu(vR.su)+ctol));
  endif
endif

% Group delay lower constraint
vTl=[];Tl=[];
vTl_max=-inf;
vTl_maxi=[];
if ~isempty(vR.tl)
  Tl=iirT(wt(vR.tl),x,U,V,M,Q,R);
  vTl=find((Tdl(vR.tl)-ctol)>Tl);
  if ~isempty(vTl)
    exchanged = true;
    [vTl_max,vTl_maxi]=max((Tdl(vR.tl)-ctol)-Tl);
  endif 
endif

% Group delay upper constraint
vTu=[];Tu=[];
vTu_max=-inf;
vTu_maxi=[];
if ~isempty(vR.tu)
  Tu=iirT(wt(vR.tu),x,U,V,M,Q,R);
  vTu=find(Tu>(Tdu(vR.tu)+ctol));
  if ~isempty(vTu)
    exchanged = true;
    [vTu_max,vTu_maxi]=max(Tu-(Tdu(vR.tu)+ctol));
  endif
endif

% Phase response lower constraint
vPl=[];Pl=[];
vPl_max=-inf;
vPl_maxi=[];
if ~isempty(vR.pl)
  Pl=iirP(wp(vR.pl),x,U,V,M,Q,R);
  vPl=find((Pdl(vR.pl)-ctol)>Pl);
  if ~isempty(vPl)
    exchanged = true;
    [vPl_max,vPl_maxi]=max((Pdl(vR.pl)-ctol)-Pl);
  endif 
endif

% Phase response upper constraint
vPu=[];Pu=[];
vPu_max=-inf;
vPu_maxi=[];
if ~isempty(vR.pu)
  Pu=iirP(wp(vR.pu),x,U,V,M,Q,R);
  vPu=find(Pu>(Pdu(vR.pu)+ctol));
  if ~isempty(vPu)
    exchanged = true;
    [vPu_max,vPu_maxi]=max(Pu-(Pdu(vR.pu)+ctol));
  endif
endif

% Return if no exchange
if exchanged == false
  printf("No vR constraints violated. No exchange with vS.\n");
  return;
endif

% Find the most violated constraint in vR
[violation, most_violated] = ...
max([vAl_max, vAu_max, vSl_max, vSu_max, vTl_max, vTu_max, vPl_max, vPu_max]);

% Move the most violated constraint to vS
if most_violated == 1
  next_vS.al=unique([vS.al;vR.al(vAl_maxi)]);
  next_vR.al(vAl_maxi)=[];
  printf("Exchanged constraint from vR.al(%d) to vS\n",vR.al(vAl_maxi));
elseif most_violated == 2
  next_vS.au=unique([vS.au;vR.au(vAu_maxi)]);
  next_vR.au(vAu_maxi)=[];
  printf("Exchanged constraint from vR.au(%d) to vS\n",vR.au(vAu_maxi));
elseif most_violated == 3
  next_vS.sl=unique([vS.sl;vR.sl(vSl_maxi)]);
  next_vR.sl(vSl_maxi)=[];
  printf("Exchanged constraint from vR.sl(%d) to vS\n",vR.sl(vSl_maxi));
elseif most_violated == 4
  next_vS.su=unique([vS.su;vR.su(vSu_maxi)]);
  next_vR.su(vSu_maxi)=[];
  printf("Exchanged constraint from vR.su(%d) to vS\n",vR.su(vSu_maxi));
elseif most_violated == 5
  next_vS.tl=unique([vS.tl;vR.tl(vTl_maxi)]);
  next_vR.tl(vTl_maxi)=[];
  printf("Exchanged constraint from vR.tl(%d) to vS\n",vR.tl(vTl_maxi));
elseif most_violated == 6
  next_vS.tu=unique([vS.tu;vR.tu(vTu_maxi)]);
  next_vR.tu(vTu_maxi)=[];
  printf("Exchanged constraint from vR.tu(%d) to vS\n",vR.tu(vTu_maxi));
elseif most_violated == 7
  next_vS.pl=unique([vS.pl;vR.pl(vPl_maxi)]);
  next_vR.pl(vPl_maxi)=[];
  printf("Exchanged constraint from vR.pl(%d) to vS\n",vR.pl(vPl_maxi));
elseif most_violated == 8
  next_vS.pu=unique([vS.pu;vR.pu(vPu_maxi)]);
  next_vR.pu(vPu_maxi)=[];
  printf("Exchanged constraint from vR.pu(%d) to vS\n",vR.pu(vPu_maxi));
else
  error("Illegal max. position!?!");
endif

endfunction
