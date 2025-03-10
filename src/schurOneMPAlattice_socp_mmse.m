function [A1k,A2k,socp_iter,func_iter,feasible]= ...
  schurOneMPAlattice_socp_mmse(vS,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                               difference, ...
                               k_u,k_l,k_active,dmax, ...
                               wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                               wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
                               maxiter,ftol,ctol,verbose)
% [A1k,A2k,socp_iter,func_iter,feasible] =
% schurOneMPAlattice_socp_mmse(vS,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
%                              difference, ...
%                              k_u,k_l,k_active,dmax, ...
%                              wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                              wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
%                              maxiter,ftol,ctol,verbose)
%
% SOCP MMSE optimisation of a one-multiplier Schur lattice filter with
% constraints on the amplitude, and low pass group delay responses. 
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu,pl,pu,dl,du}
%   A1k0,A2k0 - initial allpass filter multipliers
%   A1epsilon0,A2epsilon0, - initial allpass filter multiplier signs
%   A1p0,A2p0 - state scaling coefficients. These have no effect on the
%               response but can improve numerical accuracy.
%   difference - use the difference of the all-pass filter outputs
%   k_u,k_l - upper and lower bounds on the allpass filter coefficients
%   k_active - indexes of elements of coefficients being optimised
%   dmax - for compatibility with SQP. Not used.
%   wa - angular frequencies of the squared-magnitude response
%   Asqd - desired squared amplitude response
%   Asqdu,Asqdl - upper/lower mask for the desired squared amplitude response
%   Wa - squared amplitude response weight at each frequency
%   wt - angular frequencies of the delay response
%   Td - desired group delay response
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay response weight at each frequency
%   wp - angular frequencies of the phase response
%   Pd - desired passband phase response
%   Pdu,Pdl - upper/lower mask for the desired phase response
%   Wp - phase response weight at each frequency
%   wd - angular frequencies of dAsqdw response 
%   Dd - desired dAsqdw response
%   Ddu,Ddl - upper/lower mask for the desired dAsqdw response
%   Wd - dAsqdw response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   ftol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   A1k,A2k - filter design
%   socp_iter - number of SOCP iterations
%   func_iter - number of function calls
%   feasible - design satisfies the constraints
%
% If tol is a structure then the tol.dtol field is the minimum relative
% step size and the tol.stol field sets the SeDuMi pars.eps field (the
% default is 1e-8). This is a hack to deal with filters for which the
% desired stop-band attenuation of the squared amplitude response is more
% than 80dB.

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

  if (nargin ~= 36) || (nargout ~= 5)
    print_usage(...
["[A1k,A2k,socp_iter,func_iter,feasible]=schurOneMPAlattice_socp_mmse ...\n", ...
 "(vS,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference, ...\n", ...
 " k_u,k_l,k_active,dmax, ...\n", ...
 " wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...\n", ...
 " wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...\n", ...
 " maxiter,ftol,ctol,verbose)"]);
  endif

  %
  % Sanity checks on frequency response vectors
  %
  wa=wa(:);wt=wt(:);wp=wp(:);wd=wd(:);
  Nwa=length(wa);
  Nwt=length(wt);
  Nwp=length(wp);
  Nwd=length(wd);
  if isempty(wa)
    error("wa empty");
  endif
  if Nwa ~= length(Asqd)
    error("Expected length(wa)(%d) == length(Asqd)(%d)",Nwa,length(Asqd));
  endif  
  if ~isempty(Asqdu) && Nwa ~= length(Asqdu)
    error("Expected length(wa)(%d) == length(Asqdu)(%d)",Nwa,length(Asqdu));
  endif
  if ~isempty(Asqdl) && Nwa ~= length(Asqdl)
    error("Expected lenth(wa)(%d) == length(Asqdl)(%d)",Nwa,length(Asqdl));
  endif
  if Nwa ~= length(Wa)
    error("Expected length(wa)(%d) == length(Wa)(%d)",Nwa,length(Wa));
  endif
  if ~isempty(Td) && Nwt ~= length(Td)
    error("Expected length(wt)(%d) == length(Td)(%d)",Nwt,length(Td));
  endif
  if ~isempty(Tdu) && Nwt ~= length(Tdu)
    error("Expected length(wt)(%d) == length(Tdu)(%d)",Nwt,length(Tdu));
  endif
  if ~isempty(Tdl) && Nwt ~= length(Tdl)
    error("Expected length(wt)(%d) == length(Tdl)(%d)",Nwt,length(Tdl));
  endif
  if ~isempty(Wt) && Nwt ~= length(Wt)
    error("Expected length(wt)(%d) == length(Wt)(%d)",Nwt,length(Wt));
  endif
  if ~isempty(Pd) && Nwp ~= length(Pd)
    error("Expected length(wp)(%d) == length(Pd)(%d)",Nwp,length(Pd));
  endif
  if ~isempty(Pdu) && Nwp ~= length(Pdu)
    error("Expected length(wp)(%d) == length(Pdu)(%d)",Nwp,length(Pdu));
  endif
  if ~isempty(Pdl) && Nwp ~= length(Pdl)
    error("Expected length(wp)(%d) == length(Pdl)(%d)",Nwp,length(Pdl));
  endif
  if ~isempty(Wp) && Nwp ~= length(Wp)
    error("Expected length(wp)(%d) == length(Wp)(%d)",Nwp,length(Wp));
  endif
  if ~isempty(Dd) && Nwd ~= length(Dd)
    error("Expected length(wd)(%d) == length(Dd)(%d)",Nwd,length(Dd));
  endif
  if ~isempty(Ddu) && Nwd ~= length(Ddu)
    error("Expected length(wd)(%d) == length(Ddu)(%d)",Nwd,length(Ddu));
  endif
  if ~isempty(Ddl) && Nwd ~= length(Ddl)
    error("Expected length(wd)(%d) == length(Ddl)(%d)",Nwd,length(Ddl));
  endif
  if ~isempty(Wd) && Nwd ~= length(Wd)
    error("Expected length(wd)(%d) == length(Wd)(%d)",Nwd,length(Wd));
  endif
  if isempty(vS)
    vS=schurOneMPAlattice_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 8) || ...
         (all(isfield(vS,{"al","au","tl","tu","pl","pu","dl","du"}))==false)
    error("numfields(vS)=%d, expected 8 (al,au,tl,tu,pl,pu,dl and du)", ...
          numfields(vS));
  endif
  if isstruct(ftol)
    if all(isfield(ftol,{"dtol","stol"})) == false
      error("Expect ftol structure to have fields dtol and stol");
    endif
    dtol=ftol.dtol;
    pars.eps=ftol.stol;
    if verbose
      fprintf(stderr,"Warning! SeDuMi pars.eps set to %g\n",pars.eps);
    endif
  else
    dtol=ftol;
  endif

  %
  % Sanity checks on coefficient vectors
  %
  A1k0=A1k0(:);A2k0=A2k0(:);k_u=k_u(:);k_l=k_l(:);
  NA1k=length(A1k0);
  NA2k=length(A2k0);
  Nk=NA1k+NA2k;
  if (Nk==0)
    error("No active coefficients");
  endif
  if length(k_u) ~= Nk
    error("Expected length(k_u)(%d) == Nk(%d)",length(k_u),Nk);
  endif
  if length(k_l) ~= Nk
    error("Expected length(k_l)(%d) == Nk(%d)",length(k_l),Nk);
  endif
  Nk_active=length(k_active);
  if isempty(k_active)
    A1k=A1k0;
    A2k=A2k0;
    socp_iter=0;
    func_iter=0;
    feasible=true;
    return;
  endif

  %
  % Initialise loop
  %
  socp_iter=0;func_iter=0;loop_iter=0;feasible=false;
  % Coefficient vector being optimised
  A1k=A1k0(:);A2k=A2k0(:);k=[A1k;A2k];xk=k(k_active);
  % Initial squared response error
  [Esq,gradEsq]=schurOneMPAlatticeEsq ...
                  (A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0,...
                   difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
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
    % The vector to be minimised is [epsilon;beta;deltak] where epsilon is 
    % the MMSE error, beta is the coefficient step size and deltak is the 
    % coefficient difference vector.
    %
    bt=-[1;1;zeros(Nk_active,1)];

    % Linear constraints on reflection coefficients
    %   D'*[epsilon;beta;deltak]+f>=0
    % implementing:
    %   ku-(k+deltak) >= 0
    %   (k+deltak)-kl >= 0
    % In matrix form:
    %   |0 0 -I||epsilon | + |k_u - k  | >= 0
    %   |0 0  I||beta    |   |k   - k_l|
    %           |deltak  |
    D=[ zeros(2,2*Nk_active); [-eye(Nk_active), eye(Nk_active)] ];
    f=[ k_u(k_active)-k(k_active) ; k(k_active)-k_l(k_active)];
    
    % Squared amplitude linear constraints
    if ~isempty(vS.au)
      [Asq_au,gradAsq_au] = ...
      schurOneMPAlatticeAsq(wa(vS.au), ...
                            A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0,difference);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.au));-gradAsq_au(:,k_active)']];
      f=[f; Asqdu(vS.au)-Asq_au];
    endif
    if ~isempty(vS.al)
      [Asq_al,gradAsq_al] = ...
      schurOneMPAlatticeAsq(wa(vS.al), ...
                            A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0,difference);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.al));gradAsq_al(:,k_active)']];
      f=[f; Asq_al-Asqdl(vS.al)];
    endif

    % Group delay linear constraints
    if ~isempty(vS.tu)
      [T_tu,gradT_tu] = ...
      schurOneMPAlatticeT(wt(vS.tu), ...
                          A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tu));-gradT_tu(:,k_active)']];
      f=[f; Tdu(vS.tu)-T_tu];
    endif
    if ~isempty(vS.tl)
      [T_tl,gradT_tl] = ...
      schurOneMPAlatticeT(wt(vS.tl), ...
                          A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0,difference);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tl));gradT_tl(:,k_active)']];
      f=[f; T_tl-Tdl(vS.tl)];
    endif

    % Phase linear constraints
    % (computed across wp to allow for phase unwrapping)
    if ~isempty(vS.pu) || ~isempty(vS.pl)
      [P,gradP] = schurOneMPAlatticeP ...
        (wp,A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0,difference);
      func_iter = func_iter+1;
    endif
    if ~isempty(vS.pu)
      D=[D, [zeros(2,length(vS.pu));-gradP(vS.pu,k_active)']];
      f=[f;                          Pdu(vS.pu)-P(vS.pu)];
    endif
    if ~isempty(vS.pl)
      D=[D, [zeros(2,length(vS.pl)); gradP(vS.pl,k_active)']];
      f=[f;                          P(vS.pl)-Pdl(vS.pl)];
    endif

    % dAsqdw linear constraints
    if ~isempty(vS.du)
      [dAsqdw_du,graddAsqdw_du] = ...
         schurOneMPAlatticedAsqdw ...
           (wd(vS.du),A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0,difference);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.du));-graddAsqdw_du(:,k_active)']];
      f=[f; Ddu(vS.du)-dAsqdw_du];
    endif
    if ~isempty(vS.dl)
      [dAsqdw_dl,graddAsqdw_dl] = ...
         schurOneMPAlatticedAsqdw ...
           (wd(vS.dl),A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0,difference);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.dl));graddAsqdw_dl(:,k_active)']];
      f=[f; dAsqdw_dl-Ddl(vS.dl)];
    endif

    % SeDuMi linear constraint matrixes
    At=-D;
    ct=f;
    sedumiK.l=columns(D);

    %
    % SeDuMi quadratic constraint matrixes
    %

    % Step size constraints
    At1=[zeros(2,Nk_active);eye(Nk_active)];
    b1=[0;1;zeros(Nk_active,1)];
    c1=zeros(Nk_active,1);
    d1=0;
    At=[At, -[b1, At1]];
    ct=[ct;d1;c1];
    sedumiK.q=size(At1,2)+1;

    % MMSE frequency response constraints
    At2=[zeros(2,1);gradEsq(k_active)'];
    b2=[1;0;zeros(Nk_active,1)];
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
      xk=[];
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
    xk=xk+delta;
    k(k_active)=xk;
    A1k=k(1:NA1k);
    A2k=k((NA1k+1):end);
    [Esq,gradEsq] = ...
      schurOneMPAlatticeEsq(A1k,A1epsilon0,A1p0,A2k,A2epsilon0,A2p0, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    func_iter=func_iter+1;
    socp_iter=socp_iter+info.iter;
    if verbose
      printf("epsilon=%g\n",epsilon);
      printf("beta=%g\n",beta);
      printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
      printf("norm(delta)=%g\n",norm(delta));
      printf("A1k=[ ");printf("%g ",A1k');printf(" ]';\n"); 
      printf("A2k=[ ");printf("%g ",A2k');printf(" ]';\n"); 
      printf("norm(delta)/norm(xk)=%g\n",norm(delta)/norm(xk));
      printf("Esq= %g\n",Esq);
      printf("gradEsq=[");printf("%g ",gradEsq);printf("]\n");
      printf("loop_iter=%d, func_iter=%d, socp_iter=%d\n", ...
             loop_iter,func_iter,socp_iter);
      info
    endif
    if norm(delta)/norm(xk) < dtol
      printf("norm(delta)/norm(xk) < dtol\n");
      feasible=true;
      break;
    endif

  endwhile

endfunction
