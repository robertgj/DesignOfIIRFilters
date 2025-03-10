function [fM,k0,k1,socp_iter,func_iter,feasible]= ...
  johanssonOneMlattice_socp_mmse(vS,fM_0,k0_0,epsilon0,k1_0,epsilon1, ...
                                 fMk_u,fMk_l,fMk_active,dmax, ...
                                 wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose)
% [fM,k0,k1,socp_iter,func_iter,feasible] =
%   johanssonOneMlattice_socp_mmse(vS,fM_0,k0_0,epsilon0,k1_0,epsilon1, ...
%                                  fMk_u,fMk_l,fMk_active,dmax, ...
%                                  wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose)
%
% SOCP MMSE optimisation of a Johansson and Saramaki cascade allpass band-stop
% filter with the all-pass filters implemented as one-multiplier lattice
% filters and with constraints on the amplitude response.
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   k0_0,k1_0 - initial allpass filter multipliers
%   epsilon0,epsilon1 - state scaling coefficients. These have no effect on the
%                       response but can improve numerical accuracy.
%   fMk_u,fMk_l - upper and lower bounds on the allpass filter coefficients
%   fMk_active - indexes of elements of coefficients being optimised
%   dmax - for compatibility with SQP. Not used.
%   wa - angular frequencies of the squared-magnitude response
%   Ad - desired amplitude response
%   Adu,Adl - upper/lower mask for the desired amplitude response
%   Wa - amplitude response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   ftol - tolerance on function value
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   fM,k0,k1 - filter design
%   socp_iter - number of SOCP iterations
%   func_iter - number of function calls
%   feasible - design satisfies the constraints 

% Copyright (C) 2019-2025 Robert G. Jenssen
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

  if (nargin ~= 19) || (nargout ~= 6)
    print_usage(["[fM,k0,k1,socp_iter,func_iter,feasible]= ...\n", ...
 "      johanssonOneMlattice_socp_mmse(vS,fM_0,k0_0,epsilon0,k1_0,epsilon1, ...\n", ...
 "                                     fMk_u,fMk_l,fMk_active,dmax, ...\n", ...
 "                                     wa,Ad,Adu,Adl,Wa, ...\n", ...
 "                                     maxiter,ftol,ctol,verbose)"]);
  endif

  %
  % Sanity checks on frequency response vectors
  %
  wa=wa(:);
  Nwa=length(wa);
  if isempty(wa)
    error("wa empty");
  endif
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
    vS=johanssonOneMlattice_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 2) || ...
         (all(isfield(vS,{"al","au"}))==false)
    error("numfields(vS)=%d, expected 2 (al and au)",numfields(vS));
  endif
  if isstruct(ftol)
    if all(isfield(ftol,{"dtol","stol"})) == false
      error("Expect ftol structure to have fields dtol and stol");
    endif
    dtol=ftol.dtol;
    pars.eps=ftol.stol;
    if verbose
      printf("Using dtol=%g,pars.eps=%g\n",dtol,pars.eps);
    endif
  else
    dtol=ftol;
  endif

  %
  % Sanity checks on coefficient vectors
  %
  fM=fM_0(:);k0=k0_0(:);k1=k1_0(:);
  fMk_u=fMk_u(:);fMk_l=fMk_l(:);fMk_active=fMk_active(:);
  NfM=length(fM);
  RfM=1:NfM;
  Nk0=length(k0);
  Rk0=NfM+(1:Nk0);
  Nk1=length(k1);
  Rk1=(NfM+Nk0)+(1:Nk1);
  NfMk=NfM+Nk0+Nk1;
  if (NfMk==0)
    error("No coefficients");
  endif
  if length(fMk_u) ~= NfMk
    error("Expected length(fMk_u)(%d) == NfMk(%d)",length(fMk_u),NfMk);
  endif
  if length(fMk_l) ~= NfMk
    error("Expected length(fMk_l)(%d) == NfMk(%d)",length(fMk_l),NfMk);
  endif
  NfMk_active=length(fMk_active);
  if isempty(fMk_active)
    fM=fM_0;
    k0=k0_0;
    k1=k1_0;
    sqp_iter=0;
    func_iter=0;
    feasible=true;
    return;
  endif

  %
  % Initialise loop
  %
  socp_iter=0;func_iter=0;loop_iter=0;feasible=false;
  % Coefficient vector being optimised
  fMk=[fM;k0;k1];
  if verbose
    printf("initial fM=[ ");printf("%g ",fMk(RfM)');printf("]\n");
    printf("initial k0=[ ");printf("%g ",fMk(Rk0)');printf("]\n");
    printf("initial k1=[ ");printf("%g ",fMk(Rk1)');printf("]\n");
    printf("initial fMk_active=[ ");printf("%d ",fMk_active(:)');printf("]\n");
  endif 
  xfMk=fMk(fMk_active);
  % Initial response error
  [Esq,gradEsq]=johanssonOneMlatticeEsq(fM,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);
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
  % Second Order Cone Programming (SQP) loop
  %
  while 1

    loop_iter=loop_iter+1;
    if loop_iter > maxiter
      error("maxiter exceeded");
    endif

    %
    % Set up the SeDuMi problem. 
    % The vector to be minimised is [epsilon;beta;deltakc] where epsilon is 
    % the MMSE error, beta is the coefficient step size and deltakc is the 
    % coefficient difference vector.
    %
    bt=-[1;1;zeros(NfMk_active,1)];

    % Linear constraints on reflection coefficients
    %   D'*[epsilon;beta;deltakc]+f>=0
    % implementing:
    %   fMk_u-(fMk+deltafMk) >= 0
    %   (fMk+deltafMk)-fMk_l >= 0
    % In matrix form:
    %   |0 0 -I||epsilon | + |fMk_u - fMk  | >= 0
    %   |0 0  I||beta    |   |fMk   - fMk_l|
    %           |deltakc |
    D=[ zeros(2,2*NfMk_active); [-eye(NfMk_active), eye(NfMk_active)] ];
    f=[ fMk_u(fMk_active)-fMk(fMk_active) ; fMk(fMk_active)-fMk_l(fMk_active)];
    
    % Squared amplitude linear constraints
    if ~isempty(vS.au)
      [A_au,gradA_au]=johanssonOneMlatticeAzp(wa(vS.au), ...
                                              fM,k0,epsilon0,k1,epsilon1);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.au));-gradA_au(:,fMk_active)']];
      f=[f; Adu(vS.au)-A_au];
    endif
    if ~isempty(vS.al)
      [A_al,gradA_al]=johanssonOneMlatticeAzp(wa(vS.al), ...
                                              fM,k0,epsilon0,k1,epsilon1);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.al));gradA_al(:,fMk_active)']];
      f=[f; A_al-Adl(vS.al)];
    endif

    % SeDuMi linear constraint matrixes
    At=-D;
    ct=f;
    sedumiK.l=columns(D);
           
    % SeDuMi quadratic constraint matrixes

    % Step size constraints
    At1=[zeros(2,NfMk_active);eye(NfMk_active)];
    b1=[0;1;zeros(NfMk_active,1)];
    c1=zeros(NfMk_active,1);
    d1=0;
    At=[At, -[b1, At1]];
    ct=[ct;d1;c1];
    sedumiK.q=size(At1,2)+1;

    % MMSE frequency response constraints
    At2=[zeros(2,1);gradEsq(fMk_active)'];
    b2=[1;0;zeros(NfMk_active,1)];
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
      xfMk=[];
      feasible=false;
      err=lasterror();
      for e=1:length(err.stack)
        fprintf(stderr,"Called %s at line %d\n", ...
                err.stack(e).name,err.stack(e).line);
      endfor
      error("%s\n", err.message);
    end_try_catch
    
    % Extract results
    epsilon=ys(1);
    beta=ys(2);
    delta=ys(3:end);
    xfMk=xfMk+delta;
    fMk(fMk_active)=xfMk;
    fM=fMk(RfM);
    k0=fMk(Rk0);
    k1=fMk(Rk1);
    [Esq,gradEsq]=johanssonOneMlatticeEsq(fM,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);
    func_iter=func_iter+1;
    socp_iter=socp_iter+info.iter;
    if verbose
      printf("epsilon=%g\n",epsilon);
      printf("beta=%g\n",beta);
      printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
      printf("norm(delta)=%g\n",norm(delta));
      printf("fM=[ ");printf("%g ",fM');printf(" ]';\n"); 
      printf("k0=[ ");printf("%g ",k0');printf(" ]';\n"); 
      printf("k1=[ ");printf("%g ",k1');printf(" ]';\n"); 
      printf("norm(delta)/norm(xfMk)=%g\n",norm(delta)/norm(xfMk));
      printf("Esq= %g\n",Esq);
      printf("gradEsq=[");printf("%g ",gradEsq);printf("]\n");
      gradEsq
      delta
      printf("gradEsq*delta=%g\n",gradEsq(fMk_active)*delta);
      printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
      info
    endif
    if norm(delta)/norm(xfMk) < dtol
      printf("norm(delta)/norm(xfMk) < dtol\n");
      feasible=true;
      break;
    endif

  endwhile

endfunction
