function [hM,socp_iter,func_iter,feasible]= ...
           directFIRsymmetric_sdp_mmsePW ...
             (vS,hM0,hM0_delta,na,wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose)
% function [hM,socp_iter,func_iter,feasible]=...
%   directFIRsymmetric_sdp_mmsePW.m ...
%     (vS,hM0,hM0_delta,na,wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose)
%
% SDP MMSE optimisation of the scaled integer coefficients of a direct-form
% FIR filter with constraints on the amplitude response. The desired
% response is assumed to be piece-wise constant with band-edges defined by
% wa(na). The integer values, y in {-1,1}, are found by an SDP relaxation of
% Y=yy' with linear triangle inequality constraints on y and Y.
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au}
%   hM0 - initial distinct direct-form FIR filter coefficients
%   hM0_delta - limits of search space: hM=hM0+(y.*hM0_delta), y in {-1,1}
%   na - indexes of band edges in wa
%   wa - angular frequencies of the amplitude response
%   Ad - desired amplitude response
%   Adu,Adl - upper/lower mask for the desired amplitude response
%   Wa - amplitude response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   ftol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   hM - distinct direct-form FIR filter coefficients
%   socp_iter - SeDuMi iterations
%   func_iter - number of function calls
%   feasible - design satisfies the constraints 

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

if (nargin ~= 13) || (nargout ~= 4)
  print_usage(["[hM,socp_iter,func_iter,feasible]= ...\n", ...
               "  directFIRsymmetric_sdp_mmsePW(vS,hM0,hM0_delta,na, ...\n", ...
               "                              wa,Ad,Adu,Adl,Wa, ...\n", ...
               "                              maxiter,ftol,ctol,verbose)"]);
endif

%
% Sanity checks on frequency response vectors
%
wa=wa(:);
Nwa=length(wa);
if Nwa ~= length(Ad)
  error("Expected length(wa)(%d) == length(Ad)(%d)",Nwa,length(Ad));
endif  
if ~isempty(Adu) && Nwa ~= length(Adu)
  error("Expected length(wa)(%d) == length(Adu)(%d)",Nwa,length(Adu));
endif
if ~isempty(Adl) && Nwa ~= length(Adl)
  error("Expected lenth(wa)(%d) == length(Adl)(%d)",Nwa,length(Adl));
endif
if Nwa ~= length(Wa)
  error("Expected length(wa)(%d) == length(Wa)(%d)",Nwa,length(Wa));
endif
if isempty(vS)
  vS=directFIRsymmetric_slb_set_empty_constraints();
elseif (numfields(vS) ~= 2) || ...
       (all(isfield(vS,{"al","au"}))==false)
  error("numfields(vS)=%d, expected 2 (al,au)",numfields(vS));
endif
if length(hM0) ~= length(hM0_delta)
  error("length(hM0) ~= length(hM0_delta)");
endif

%
% Sanity checks on coefficient vectors
%
hM0=hM0(:);
hM0_delta=hM0_delta(:);
NhM=length(hM0);
if all(NhM == 0)
  error("No active coefficients : all(NhM == 0)");
endif
if all(hM0_delta == 0)
  error("No active coefficients : all(NhM0_delta == 0)");
endif

%
% Initialise
%
socp_iter=0;func_iter=0;feasible=false;
% Coefficient vector being optimised
hM=hM0(:);
% Initial squared response error
nb=na(1:(end-1))+1;
[Esq,gradEsq,Q]=directFIRsymmetricEsqPW(hM,wa(na),Ad(nb),Wa(nb));
func_iter=func_iter+1;
if verbose
  printf("Initial Esq=%g\n",Esq);
  printf("Initial gradEsq=[");printf("%g ",gradEsq);printf("]\n");
endif
% SeDuMi logging output destination
if verbose
  pars.fid=2;
else
  pars.fid=0;
endif

%
% Set up the SeDuMi problem:
%   minimise c*yy 
%   subject to [Y,y;y',1] is positive definite
%   where 1. Y is symmetric and the diagonal elements of Y are 1,
%         2. yy is the concatenation of the vector of distinct off diagonal
%            of elements of Y with y
%         3. hM0+(hM0_delta.*sign(y)) is the new filter design
%
hM_active=find(hM0_delta ~= 0);
NhM_active=length(hM_active);
NN=NhM_active*(NhM_active-1)/2;

% Approximate amplitude linear constraints (SeDuMi format is Dx+f>=0): 
%   -A-gradA*(delta.*y) + Adu >= 0
%    A+gradA*(delta.*y) - Adl >= 0
D=[];f=[];
if ~isempty(vS.au)
  [A_au,gradA_au]=directFIRsymmetricA(wa(vS.au),hM);
  func_iter = func_iter+1;
  gradA_au_delta=gradA_au.*kron(ones(length(vS.au),1),hM0_delta');
  D=[D,[zeros(NN,length(vS.au));-gradA_au_delta(:,hM_active)']];
  f=[f;Adu(vS.au)-A_au];
endif
if ~isempty(vS.al)
  [A_al,gradA_al]=directFIRsymmetricA(wa(vS.al),hM);
  func_iter = func_iter+1;
  gradA_al_delta=gradA_al.*kron(ones(length(vS.al),1),hM0_delta');
  D=[D,[zeros(NN,length(vS.al));gradA_al_delta(hM_active)']];
  f=[f;A_al-Adl(vS.al)];
endif

% Triangle inequalities (in the SeDuMi form: Dy+f>=0)
AyyY=[];
byyY=[];
if NhM_active >= 2
  Fn=zeros(NhM_active);
  Fn(find(triu(ones(NhM_active),1)))=1:NN;
  byyY=ones(4*NN,1);
  AyyY=zeros(NN+NhM_active,4*NN);
  nn=-3;
  for m=1:(NhM_active-1),
    for n=(m+1):NhM_active,
      nn=nn+4;
      % y(m)+y(n)+Y(m,n) + 1 >= 0
      AyyY(NN+m,    nn  )= 1; 
      AyyY(NN+n,    nn  )= 1;
      AyyY(Fn(m,n), nn  )= 1;
      % y(m)-y(n)-Y(m,n) + 1 >= 0
      AyyY(NN+m,    nn+1)= 1; 
      AyyY(NN+n,    nn+1)=-1;
      AyyY(Fn(m,n), nn+1)=-1; 
      % -y(m)-y(n)+Y(m,n) + 1 >= 0
      AyyY(NN+m,    nn+2)=-1; 
      AyyY(NN+n,    nn+2)=-1;
      AyyY(Fn(m,n), nn+2)= 1;
      % -y(m)+y(n)-Y(m,n) + 1 >= 0
      AyyY(NN+m,    nn+3)=-1; 
      AyyY(NN+n,    nn+3)= 1;
      AyyY(Fn(m,n), nn+3)=-1;
    endfor
  endfor
endif

% Minimise Esq
Qhat=Q(hM_active,hM_active).*(hM0_delta(hM_active)*(hM0_delta(hM_active).'));
Fhat=find(triu(ones(NhM_active),1));
cc=zeros(NN+NhM_active,1);
cc(1:NN)=Qhat(Fhat);
cc((NN+1):(NN+NhM_active))=gradEsq(hM_active).*(hM0_delta(hM_active).');

% Positive definite constraint
F0=eye(NhM_active+1);
F=cell(NN+NhM_active,1);
[Fr,Fc]=find(triu(ones(NhM_active+1),1));
for m=1:(NN+NhM_active),
  F{m}=zeros(size(F0));
  F{m}(Fr(m),Fc(m))=1;
  F{m}(Fc(m),Fr(m))=1;
endfor
cs=vec(F0);
As=zeros((NN+NhM_active),rows(cs));
for m=1:(NN+NhM_active),
  As(m,:)=-vec(F{m});
endfor

% SeDuMi variables
At=[-[D,AyyY], As];
bt=-cc;
ct=[ [f;byyY]; cs];
K.l=columns(D)+columns(AyyY);
K.s=rows(F0);

% Call SeDuMi
try
  [x,yy,info]=sedumi(At,bt,ct,K,pars);
  if verbose
    printf("SeDuMi info.iter=%d, info.feasratio=%6.4g\n", ...
           info.iter,info.feasratio);
  endif
  if info.pinf
    error("SeDuMi primary problem infeasible");
  endif
  if info.dinf
    error("SeDuMi dual problem infeasible");
  endif 
  if info.numerr == 1
    error("SeDuMi premature termination"); 
  elseif info.numerr == 2 
    error("SeDuMi numerical failure");
  elseif info.numerr
    error("SeDuMi info.numerr=%d",info.numerr);
  endif
catch
  hM=[];
  feasible=false;
  err=lasterror();
  for e=1:length(err.stack)
    fprintf(stderr,"Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("%s\n", err.message);
end_try_catch

% Extract results
y=yy((NN+1):(NN+NhM_active));
printf("y=[ ");printf("%13.10f ",y');printf(" ]';\n");
hM=hM0;
hM(hM_active)=hM0(hM_active)+(((y>=0)-(y<0)).*hM0_delta(hM_active));
socp_iter=info.iter;
feasible=true;
if verbose
  printf("hM=[ ");printf("%15.12f ",hM');printf(" ]';\n"); 
  [Esq,gradEsq]=directFIRsymmetricEsqPW(hM,wa(na),Ad(nb),Wa(nb));
  func_iter=func_iter+1;
  printf("Esq= %g\n",Esq);
  printf("gradEsq=[");printf("%g ",gradEsq);printf("]\n");
  printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
  info
endif

endfunction
