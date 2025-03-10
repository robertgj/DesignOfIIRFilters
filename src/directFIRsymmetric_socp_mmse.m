function [hM,socp_iter,func_iter,feasible]=directFIRsymmetric_socp_mmse ...
           (vS,hM0,hM0_active,na,wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose)
% function [hM,socp_iter,func_iter,feasible]=directFIRsymmetric_socp_mmse ...
%  (vS,hM0,hM0_active,na,wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose)
%
% SOCP MMSE optimisation of a direct-form symmetric filter with
% constraints on the amplitude response.
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au}
%   hM0 - initial distinct direct-form symmetric FIR filter coefficients
%   hM0_active - indexes of elements of coefficients being optimised
%   na - not used
%   wa - angular frequencies of the amplitude response
%   Ad - desired amplitude response
%   Adu,Adl - upper/lower mask for the desired amplitude response
%   Wa - amplitude response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   ftol - tolerance on function value
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   hM - distinct direct-form symmetric FIR filter coefficients
%   socp_iter - number of SOCP calls
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
 "directFIRsymmetric_socp_mmse(vS,hM0,hM_active,na, ...\n", ...
 "                             wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose)"]);
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

%
% Sanity checks on coefficient vectors
%
hM0=hM0(:);
NhM=length(hM0);
if (NhM==0)
  error("No active coefficients");
endif
NhM_active=length(hM0_active);
if isempty(hM0_active)
  hM=hM0;
  func_iter=0;
  socp_iter=0;
  feasible=true;
  return;
endif

%
% Initialise loop
%
socp_iter=0;func_iter=0;loop_iter=0;feasible=false;
% Coefficient vector being optimised
hM=hM0(:);hM_active=hM0_active;
% Initial squared response error
[Esq,gradEsq]=directFIRsymmetricEsq(hM,wa,Ad,Wa);
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
% Second Order Cone Programming (SOCP) loop
%
while 1

  loop_iter=loop_iter+1;
  if loop_iter > maxiter
    error("maxiter exceeded");
  endif

  %
  % Set up the SeDuMi problem. 
  % The vector to be minimised is [epsilon;beta;deltahM] where epsilon is 
  % the MMSE error, beta is the coefficient step size and deltahM is the 
  % coefficient difference vector.
  %
  bt=-[1;1;zeros(NhM_active,1)];

  % Amplitude linear constraints
  D=[];f=[];
  if ~isempty(vS.au)
    [A_au,gradA_au]=directFIRsymmetricA(wa(vS.au),hM);
    func_iter = func_iter+1;
    D=[[zeros(2,length(vS.au));-gradA_au(:,hM_active)']];
    f=[Adu(vS.au)-A_au];
  endif
  if ~isempty(vS.al)
    [A_al,gradA_al]=directFIRsymmetricA(wa(vS.al),hM);
    func_iter = func_iter+1;
    D=[D,[zeros(2,length(vS.al));gradA_al(:,hM_active)']];
    f=[f;A_al-Adl(vS.al)];
  endif

  % SeDuMi linear constraint matrixes
  At=-D;
  ct=f;
  sedumiK.l=columns(D);
         
  % SeDuMi quadratic constraint matrixes

  % Step size constraints
  At1=[zeros(2,NhM_active);eye(NhM_active)];
  b1=[0;1;zeros(NhM_active,1)];
  c1=zeros(NhM_active,1);
  d1=0;
  At=[At, -[b1, At1]];
  ct=[ct;d1;c1];
  sedumiK.q=size(At1,2)+1;

  % MMSE frequency response constraints
  At2=[zeros(2,1);gradEsq(hM_active)'];
  b2=[1;0;zeros(NhM_active,1)];
  c2=Esq;
  d2=0;
  At=[At, -[b2, At2]];
  ct=[ct;d2;c2];
  sedumiK.q=[sedumiK.q, size(At2,2)+1];

  % Call SeDuMi
  try
    [xs,ys,info]=sedumi(At,bt,ct,sedumiK,pars);
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
  socp_iter=socp_iter+info.iter;
  epsilon=ys(1);
  beta=ys(2);
  delta=ys(3:end);
  hM(hM_active)=hM(hM_active)+delta;
  [Esq,gradEsq]=directFIRsymmetricEsq(hM,wa,Ad,Wa);
  func_iter=func_iter+1;
  if verbose
    printf("epsilon=%g\n",epsilon);
    printf("beta=%g\n",beta);
    printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
    printf("norm(delta)=%g\n",norm(delta));
    printf("hM=[ ");printf("%g ",hM');printf(" ]';\n"); 
    printf("norm(delta)/norm(hM)=%g\n",norm(delta)/norm(hM));
    printf("Esq= %g\n",Esq);
    printf("gradEsq=[");printf("%g ",gradEsq);printf("]\n");
    printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
    info
  endif
  if norm(delta)/norm(hM) < ftol
    printf("norm(delta)/norm(hM) < ftol\n");
    feasible=true;
    break;
  endif

endwhile

endfunction
