function [next_vR,next_vS,exchanged] = ...
         deczky1_slb_exchange_constraints(vS,vR,x,U,V,M,Q,R, ...
                                          wa,Adu,Adl,wt,Tdu,Tdl,wx,tol)
% [next_vR,next_vS,exchanged] = ...
%  deczky1_slb_exchange_constraints(vS,vR,x,U,V,M,Q,R, ...
%                                   wa,Adu,Adl,wt,Tdu,Tdl,wx,tol)
% Exchange constraints: calculate the new response and check 
% for violation of the constraints in vR. If any constraints 
% are violated then move the constraint with the greatest violation
% from vR to vS.

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

 
if (nargin ~= 16) || (nargout ~= 3)
  print_usage("[next_vR,next_vS,exchanged]=...\n\
         deczky1_slb_exchange_constraints(vS,vR, ...\n\
           x,U,V,M,Q,R,wa,Adu,Adl,wt,Tdu,Tdl,wx,tol)");
endif

next_vR = vR;
next_vS = vS;
exchanged = false;
vAl_max=-inf;
vAu_max=-inf;
vTl_max=-inf;
vTu_max=-inf;
vAx_max=-inf;

% Amplitude lower constraint
vAl=[];Al=[];
if ~isempty(vR.al)
  Al=iirA(wa(vR.al),x,U,V,M,Q,R);
  vAl=find((Adl(vR.al)-tol)>Al);
  if ~isempty(vAl)
    exchanged = true;
    [vAl_max,vAl_maxi]=max((Adl(vR.al)-tol)-Al);
  endif
endif

% Amplitude upper constraint
vAu=[];Au=[];
if ~isempty(vR.au)
  Au=iirA(wa(vR.au),x,U,V,M,Q,R);
  vAu=find(Au>(Adu(vR.au)+tol));
  if ~isempty(vAu)
    exchanged = true;
    [vAu_max,vAu_maxi]=max(Au-(Adu(vR.au)+tol));
  endif
endif

% Group delay lower constraint
vTl=[];Tl=[];
if ~isempty(vR.tl)
  Tl=iirT(wt(vR.tl),x,U,V,M,Q,R);
  vTl=find((Tdl(vR.tl)-tol)>Tl);
  if ~isempty(vTl)
    exchanged = true;
    [vTl_max,vTl_maxi]=max((Tdl(vR.tl)-tol)-Tl);
  endif 
endif

% Group delay upper constraint
vTu=[];Tu=[];
if ~isempty(vR.tu)
  Tu=iirT(wt(vR.tu),x,U,V,M,Q,R);
  vTu=find(Tu>(Tdu(vR.tu)+tol));
  if ~isempty(vTu)
    exchanged = true;
    [vTu_max,vTu_maxi]=max(Tu-(Tdu(vR.tu)+tol));
  endif
endif

% Amplitude transition band derivative constraint
vAx=[];
if ~isempty(vR.ax)
  delAdelw=iirdelAdelw(wx(vR.ax),x,U,V,M,Q,R);
  vAx=find(delAdelw>tol);
  if ~isempty(vAx)
    exchanged = true;
    [vAx_max,vAx_maxi]=max(delAdelw-tol);
  endif
endif

% Return if no exchange
if exchanged == false
  printf("No vR constraints violated. No exchange with vS.\n");
  return;
endif

% Find the most violated constraint in vR
[violation, most_violated] = max([vAl_max, vAu_max, vTl_max, vTu_max, vAx_max]);

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
  next_vS.tl=unique([vS.tl;vR.tl(vTl_maxi)]);
  next_vR.tl(vTl_maxi)=[];
  printf("Exchanged constraint from vR.tl(%d) to vS\n",vR.tl(vTl_maxi));
elseif most_violated == 4
  next_vS.tu=unique([vS.tu;vR.tu(vTu_maxi)]);
  next_vR.tu(vTu_maxi)=[];
  printf("Exchanged constraint from vR.tu(%d) to vS\n",vR.tu(vTu_maxi));
elseif most_violated == 5
  next_vS.ax=unique([vS.ax;vR.ax(vAx_maxi)]);
  next_vR.ax(vAx_maxi)=[];
  printf("Exchanged constraint from vR.ax(%d) to vS\n",vR.ax(vAx_maxi));
else
  error("Illegal max. position!?!");
endif

endfunction
