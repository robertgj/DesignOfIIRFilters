function [A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
          socp_iter,func_iter,feasible]= ...
  schurNSPAlattice_socp_mmse(vS, ...
                             A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
                             A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
                             difference, ...
                             sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                             wa,Asqd,Asqdu,Asqdl,Wa, ...
                             wt,Td,Tdu,Tdl,Wt, ...
                             wp,Pd,Pdu,Pdl,Wp, ...
                             maxiter,ftol,ctol,verbose)
% [A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
%  socp_iter,func_iter,feasible]= ...
%  schurNSPAlattice_socp_mmse(vS, ...
%                             A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
%                             A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
%                             difference, ...
%                             sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
%                             wa,Asqd,Asqdu,Asqdl,Wa, ...
%                             wt,Td,Tdu,Tdl,Wt, ...
%                             wp,Pd,Pdu,Pdl,Wp, ...
%                             maxiter,ftol,ctol,verbose)
%
% SOCP MMSE optimisation of a normalised-scaled Schur lattice filter with
% constraints on the amplitude, group delay and phase responses. 
%
% Note that s00=sqrt(1-s20.^2) is not enforced since this is not, in general,
% possible with integer coefficients. If sxx_symmetric=false then the
% s20, s00, s02 and s22 coefficients are independent.
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu,pl,pu}
%   A1s20_0,A1s00_0,A1s02_0,A1s22_0 - initial A1 lattice coefficients
%   A2s20_0,A2s00_0,A2s02_0,A2s22_0 - initial A2 lattice coefficients
%   difference - use the difference of the all-pass filter outputs
%   sxx_u,sxx_l - upper and lower bounds on lattice coefficients
%   sxx_active - indexes of elements of s10,etc being optimised
%   sxx_symmetric - enforce s02=-s20 and s22=s00
%   dmax - for compatibility with SQP. Not used.
%   wa - angular frequencies of the squared-magnitude response
%   Asqd - desired squared amplitude response
%   Asqdu,Asqdl - upper/lower mask for the desired squared amplitude response
%   Wa - squared amplitude response weight at each frequency
%   wt - angular frequencies of the delay response
%   Td - desired group delay response
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay response weight at each frequency
%   wp - angular frequencies of the delay response
%   Pd - desired passband group delay response
%   Pdu,Pdl - upper/lower mask for the desired phase response
%   Wp - phase response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   ftol - tolerance on function
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22 - filter design
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

  if (nargin ~= 34) || (nargout ~= 11)
    print_usage ...
      (["A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...\n", ...
 "  socp_iter,func_iter,feasible]= ...\n", ...
 "  schurNSPAlattice_socp_mmse(vS, ...\n", ...
 "                             A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...\n", ...
 "                             A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...\n", ...
 "                             difference, ...\n", ...
 "                             sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...\n", ...
 "                             wa,Asqd,Asqdu,Asqdl,Wa, ...\n", ...
 "                             wt,Td,Tdu,Tdl,Wt, ...\n", ...
 "                             wp,Pd,Pdu,Pdl,Wp, ...\n", ...
 "                             maxiter,ftol,ctol,verbose)"]);
  endif

  %
  % Sanity checks on frequency response vectors
  %
  wa=wa(:);wt=wt(:);wp=wp(:);
  Nwa=length(wa);
  Nwt=length(wt);
  Nwp=length(wp);
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
  if isempty(vS)
    vS=schurNSPAlattice_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 6) || ...
         (all(isfield(vS,{"al","au","tl","tu","pl","pu"}))==false)
    error("numfields(vS)=%d, expected 6 (al,au,tl,tu,pl and pu)",numfields(vS));
  endif
  if isstruct(ftol)
    if all(isfield(ftol,{"dtol","stol"})) == false
      error("Expect ftol structure to have fields dtol and stol");
    endif
    dtol=ftol.dtol;
    pars.eps=ftol.stol;
  else
    dtol=ftol;
  endif

  %
  % Sanity checks on coefficient vectors
  %
  if length(A1s20_0) ~= length(A1s00_0)
    error("length(A1s20_0) ~= length(A1s00_0)");
  endif
  if length(A1s20_0) ~= length(A1s02_0)
    error("length(A1s20_0) ~= length(A1s02_0)");
  endif
  if length(A1s20_0) ~= length(A1s22_0)
    error("length(A1s20_0) ~= length(A1s22_0)");
  endif
  if length(A2s20_0) ~= length(A2s00_0)
    error("length(A2s20_0) ~= length(A2s00_0)");
  endif
  if length(A2s20_0) ~= length(A2s02_0)
    error("length(A2s20_0) ~= length(A2s02_0)");
  endif
  if length(A2s20_0) ~= length(A2s22_0)
    error("length(A2s20_0) ~= length(A2s22_0)");
  endif
  socp_iter=0;func_iter=0;feasible=false;
  A1s20=A1s20_0(:);A1s00=A1s00_0(:);
  A1s02=A1s02_0(:);A1s22=A1s22_0(:);
  A2s20=A2s20_0(:);A2s00=A2s00_0(:);
  A2s02=A2s02_0(:);A2s22=A2s22_0(:);
  NA1=length(A1s20);
  NA2=length(A2s20);
  NA=4*(NA1+NA2);
  if (NA==0)
    error("No coefficients");
  endif
  if length(sxx_u) ~= NA
    error("Expected length(sxx_u)(%d) == NA(%d)",length(sxx_u),NA);
  endif
  if length(sxx_l) ~= NA
    error("Expected length(sxx_l)(%d) == NA(%d)",length(sxx_l),NA);
  endif
  if isempty(sxx_active)
    socp_iter=0;
    func_iter=0;
    feasible=true;
    return;
  endif

  if sxx_symmetric
    % s02=-s20 and s22=s00
    A1s02=-A1s20;A1s22=A1s00;A2s02=-A2s20;A2s22=A2s00;
    sxx_symmetric_active=[(1:(2*NA1)),(((4*NA1)+(1:(2*NA2))))];
    sxx_active=intersect(sxx_active,sxx_symmetric_active);
  endif
  NA_active=length(sxx_active);
  sxx=[A1s20;A1s00;A1s02;A1s22;A2s20;A2s00;A2s02;A2s22];
  sxx=sxx(:);
  sxx_u=sxx_u(:);
  sxx_l=sxx_l(:);


  %
  % Initialise loop
  %
  socp_iter=0;func_iter=0;loop_iter=0;feasible=false;
  % Coefficient vector being optimised
  xsxx=sxx(sxx_active);
  % SeDuMi logging output destination
  if verbose
    pars.fid=2;
  else
    pars.fid=0;
  endif

  % Initial squared response error
  [Esq,gradEsq]= ...
    schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                        difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  func_iter=func_iter+1;
  if verbose
    printf("Initial Esq=%g\n",Esq);
    printf("Initial gradEsq=[");printf("%g ",gradEsq);printf("]\n");
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
    % The vector to be minimised is [epsilon;beta;deltak] where epsilon is 
    % the MMSE error, beta is the coefficient step size and deltak is the 
    % coefficient difference vector.
    %
    bt=-[1;1;zeros(NA_active,1)];

    % Linear constraints on reflection coefficients
    %   D'*[epsilon;beta;delta_sxx]+f>=0
    % implementing:
    %   sxx_u-(sxx+delta_sxx) >= 0
    %   (sxx+delta_sxx)-sxx_l >= 0
    % In matrix form:
    %   |0 0 -I||epsilon   | + |sxx_u - sxx  | >= 0
    %   |0 0  I||beta      |   |sxx   - sxx_l|
    %           |delta_sxx |
    D=[ zeros(2,2*NA_active); [-eye(NA_active), eye(NA_active)] ];
    f=[ sxx_u(sxx_active)-sxx(sxx_active) ; sxx(sxx_active)-sxx_l(sxx_active)];
    
    % Squared amplitude linear constraints
    if ~isempty(vS.au)
      [Asq_au,gradAsq_au] = ...
      schurNSPAlatticeAsq(wa(vS.au), ...
                          A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                          difference);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.au));-gradAsq_au(:,sxx_active)']];
      f=[f; Asqdu(vS.au)-Asq_au];
    endif
    if ~isempty(vS.al)
      [Asq_al,gradAsq_al] = ...
      schurNSPAlatticeAsq(wa(vS.al), ...
                          A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                          difference);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.al));gradAsq_al(:,sxx_active)']];
      f=[f; Asq_al-Asqdl(vS.al)];
    endif

    % Group delay linear constraints
    if ~isempty(vS.tu)
      [T_tu,gradT_tu] = ...
      schurNSPAlatticeT(wt(vS.tu), ...
                        A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                        difference);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tu));-gradT_tu(:,sxx_active)']];
      f=[f; Tdu(vS.tu)-T_tu];
    endif
    if ~isempty(vS.tl)
      [T_tl,gradT_tl] = ...
      schurNSPAlatticeT(wt(vS.tl), ...
                        A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                        difference);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tl));gradT_tl(:,sxx_active)']];
      f=[f; T_tl-Tdl(vS.tl)];
    endif

    % Phase linear constraints
    if ~isempty(vS.pu) || ~isempty(vS.pl)
      [P,gradP] =schurNSPAlatticeP ...
        (wp,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference);
    endif
    if ~isempty(vS.pu)
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.pu));-gradP(vS.pu,sxx_active)']];
      f=[f; Pdu(vS.pu)-P(vS.pu)];
    endif
    if ~isempty(vS.pl)
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.pl)); gradP(vS.pl,sxx_active)']];
      f=[f; P(vS.pl)-Pdl(vS.pl)];
    endif

    % SeDuMi linear constraint matrixes
    At=-D;
    ct=f;
    sedumiK.l=columns(D);
           
    % SeDuMi quadratic constraint matrixes

    % Step size constraints
    At1=[zeros(2,NA_active);eye(NA_active)];
    b1=[0;1;zeros(NA_active,1)];
    c1=zeros(NA_active,1);
    d1=0;
    At=[At, -[b1, At1]];
    ct=[ct;d1;c1];
    sedumiK.q=size(At1,2)+1;

    % MMSE frequency response constraints
    At2=[zeros(2,1);gradEsq(sxx_active)'];
    b2=[1;0;zeros(NA_active,1)];
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
      xsxx=[];
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
    xsxx=xsxx+delta;
    sxx(sxx_active)=xsxx;
    A1s20=sxx(1:NA1);
    A1s00=sxx((NA1)+(1:NA1));
    A2s20=sxx((4*NA1)+(1:NA2));
    A2s00=sxx((4*NA1)+(NA2)+(1:NA2));
    if sxx_symmetric
      A1s02=-A1s20;
      A1s22=A1s00;
      A2s02=-A2s20;
      A2s22=A2s00;
    else
      A1s02=sxx((2*NA1)+(1:NA1));
      A1s22=sxx((3*NA1)+(1:NA1));
      A2s02=sxx((4*NA1)+(2*NA2)+(1:NA2));
      A2s22=sxx((4*NA1)+(3*NA2)+(1:NA2));
    endif
    [Esq,gradEsq] = ...
      schurNSPAlatticeEsq(A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    func_iter=func_iter+1;
    socp_iter=socp_iter+info.iter;
    if verbose
      printf("epsilon=%g\n",epsilon);
      printf("beta=%g\n",beta);
      printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
      printf("norm(delta)=%g\n",norm(delta));
      printf("A1s20=[ ");printf("%g ",A1s20');printf(" ]';\n"); 
      printf("A1s00=[ ");printf("%g ",A1s00');printf(" ]';\n"); 
      printf("A1s02=[ ");printf("%g ",A1s02');printf(" ]';\n"); 
      printf("A1s22=[ ");printf("%g ",A1s22');printf(" ]';\n"); 
      printf("A2s20=[ ");printf("%g ",A2s20');printf(" ]';\n"); 
      printf("A2s00=[ ");printf("%g ",A2s00');printf(" ]';\n"); 
      printf("A2s02=[ ");printf("%g ",A2s02');printf(" ]';\n"); 
      printf("A2s22=[ ");printf("%g ",A2s22');printf(" ]';\n"); 
      printf("norm(delta)/norm(xsxx)=%g\n",norm(delta)/norm(xsxx));
      printf("Esq= %g\n",Esq);
      printf("gradEsq=[");printf("%g ",gradEsq(sxx_active));printf("]\n");
      printf("norm(gradEsq)=%g\n",norm(gradEsq(sxx_active)));
      printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
      Asq=schurNSPAlatticeAsq(wa, ...
                          A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                          difference);
      T=schurNSPAlatticeT(wt, ...
                          A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                          difference);
      P=schurNSPAlatticeP(wp, ...
                          A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                          difference);
      schurNSPAlattice_slb_show_constraints(vS,wa,Asq,wt,T,wp,P);
      info
    endif
    if (norm(delta)/norm(xsxx)) < dtol
      printf("norm(delta)/norm(xsxx) < dtol\n");
      feasible=true;
      break;
    endif

  endwhile

endfunction
