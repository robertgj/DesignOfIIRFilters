function [hM,socp_iter,func_iter,feasible]=...
         sdp_relaxation_directFIRhilbert_mmsePW ...
           (vS,hM0,hM0_delta,na,wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose)
% function [hM,socp_iter,func_iter,feasible]=...
%   sdp_relaxation_directFIRhilbert_mmsePW ...
%  (vS,hM0,hM0_delta,na,wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose)
%
% SDP MMSE optimisation of the scaled integer coefficients of a direct-form
% Hilbert FIR filter with constraints on the amplitude response. The desired
% response is assumed to be piece-wise constant with band-edges defined by
% wa(na). The integer values, y in {-1,1}, are found by an SDP relaxation of
% Y=yy' with linear triangle inequality constraints on y and Y.
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au}
%   hM0 - initial distinct direct-form Hilbert FIR filter coefficients
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
%   hM - distinct direct-form Hilbert FIR filter coefficients
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
 "  sdp_relaxation_directFIRhilbert_mmsePW(vS,hM0,hM_delta,na, ...\n", ...
 "                                         wa,Ad,Adu,Adl,Wa, ...\n", ...
 "                                         maxiter,ftol,ctol,verbose)"]);
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
    vS=directFIRhilbert_slb_set_empty_constraints();
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
  NhM_delta=hM0_delta(:);
  NhM=length(hM0);
  if (NhM==0)
    error("No active coefficients");
  endif

  %
  % Initialise
  %
  socp_iter=0;func_iter=0;feasible=false;
  % Coefficient vector being optimised
  hM=hM0(:);
  % Initial squared response error
  nb=na(1:(end-1))+1;
  [Esq,gradEsq,Q,q]=directFIRhilbertEsqPW(hM,wa(na),Ad(nb),Wa(nb));
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
  MM=NhM*(NhM-1)/2;
  NN=MM+NhM;

  % Approximate amplitude linear constraints (SeDuMi format is Dx+f>=0): 
  %   -A-gradA*(delta.*y) + Adu >= 0
  %    A+gradA*(delta.*y) - Adl >= 0
  D=[];f=[];
  if ~isempty(vS.au)
    [A_au,gradA_au]=directFIRhilbertA(wa(vS.au),hM);
    func_iter = func_iter+1;
    gradA_au_delta=gradA_au.*kron(ones(length(vS.au),1),hM0_delta');
    D=[D,[zeros(MM,length(vS.au));-gradA_au_delta']];
    f=[f;Adu(vS.au)-A_au];
  endif
  if ~isempty(vS.al)
    [A_al,gradA_al]=directFIRhilbertA(wa(vS.al),hM);
    func_iter = func_iter+1;
    gradA_al_delta=gradA_al.*kron(ones(length(vS.al),1),hM0_delta');
    D=[D,[zeros(MM,length(vS.al));gradA_al_delta']];
    f=[f;A_al-Adl(vS.al)];
  endif

  % Triangle inequalities (in the SeDuMi form: Dy+f>=0)
  [Fr,Fc]=find(triu(ones(NhM+1),1));
  Fn=zeros(NhM+1);
  Fn(find(triu(ones(NhM+1),1)))=1:NN;
  
  byyY=ones(4*MM,1);
  AyyY=zeros(4*MM,NN);
  nn=-3;
  for k=1:(NhM-1),
    for l=(k+1):NhM,
      nn=nn+4;
      % y(k)+y(l)+Y(k,l) + 1 >= 0
      AyyY(nn,Fn(k,NhM+1))=1; 
      AyyY(nn,Fn(l,NhM+1))=1;
      AyyY(nn,Fn(k,l))=1;
      % y(k)-y(l)-Y(k,l) + 1 >= 0
      AyyY(nn+1,Fn(k,NhM+1))=1; 
      AyyY(nn+1,Fn(l,NhM+1))=-1;
      AyyY(nn+1,Fn(k,l))=-1; 
      % -y(k)-y(l)+Y(k,l) + 1 >= 0
      AyyY(nn+2,Fn(k,NhM+1))=-1; 
      AyyY(nn+2,Fn(l,NhM+1))=-1;
      AyyY(nn+2,Fn(k,l))=1;
      % -y(k)+y(l)-Y(k,l) + 1 >= 0
      AyyY(nn+3,Fn(k,NhM+1))=-1; 
      AyyY(nn+3,Fn(l,NhM+1))=1;
      AyyY(nn+3,Fn(k,l))=-1;
    endfor
  endfor

  % Minimise c*y
  c=zeros(1,NN);
  for k=1:MM,
    c(k)=2*Q(Fr(k),Fc(k))*hM0_delta(Fr(k))*hM0_delta(Fc(k));
  endfor
  c((MM+1):NN)=2*(((hM0')*Q)+q).*(hM0_delta');

  % Positive definite constraint
  F0=eye(NhM+1);
  F=cell(NN,1);
  for k=1:NN,
    F{k}=zeros(size(F0));
    F{k}(Fr(k),Fc(k))=1;
    F{k}(Fc(k),Fr(k))=1;
  endfor
  At=zeros(size(vec(F0),1),NN);
  for k=1:NN,
    At(:,k)=-vec(F{k});
  endfor

  % SeDuMi variables
  Att=[-D';-AyyY;At];
  btt=-c;
  ctt=[f;byyY;vec(F0)];
  K.l=rows(D')+rows(AyyY);
  K.s=size(F0,1);

  % Call SeDuMi
  try
    [x,yy,info]=sedumi(Att,btt,ctt,K,pars);
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
  y=yy((MM+1):NN);
  hM=hM0+(sign(y).*hM0_delta);
  socp_iter=info.iter;
  feasible=true;
  if verbose
    printf("y=[ ");printf("%13.10f ",y');printf(" ]';\n"); 
    printf("hM=[ ");printf("%15.12f ",hM');printf(" ]';\n"); 
    [Esq,gradEsq]=directFIRhilbertEsqPW(hM,wa(na),Ad(nb),Wa(nb));
    func_iter=func_iter+1;
    printf("Esq= %g\n",Esq);
    printf("gradEsq=[");printf("%g ",gradEsq);printf("]\n");
    printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
    info
  endif

endfunction
