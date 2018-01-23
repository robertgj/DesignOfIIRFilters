function [k,khat,socp_iter,func_iter,feasible]= ...
  complementaryFIRlattice_socp_mmse(vS,k0,khat0, ...
                                    kkhat_u,kkhat_l,kkhat_active,dmax, ...
                                    wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                    wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose)
% [k,c,socp_iter,func_iter,feasible] =
% complementaryFIRlattice_socp_mmse(vS,k0,khat0, ...
%                                   kkhat_u,kkhat_l,kkhat_active,dmax, ...
%                                   wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                                   wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose)
%
% SOCP MMSE optimisation of a complementary FIR lattice filter with
% constraints on the amplitude, phase and group delay responses. 
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   k0,khat0 - initial complementary FIR lattice filter coefficients
%   kkhat_u,kkhat_l - upper and lower bounds on the allpass filter coefficients
%   kkhat_active - indexes of elements of coefficients being optimised
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
%   tol - tolerance
%   verbose - 
%
% Outputs:
%   k,khat - filter design
%   socp_iter - number of SOCP iterations
%   func_iter - number of function calls
%   feasible - design satisfies the constraints 

% Copyright (C) 2017,2018 Robert G. Jenssen
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

  if (nargin ~= 25) || (nargout ~= 5)
    print_usage("[k,khat,socp_iter,func_iter,feasible]= ...\n\
      complementaryFIRlattice_socp_mmse(vS,k0,khat0, ...\n\
                                 kkhat_u,kkhat_l,kkhat_active,dmax, ...\n\
                                 wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...\n\
                                 wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose)");
  endif

  %
  % Sanity checks on frequency response vectors
  %
  wa=wa(:);wt=wt(:);wp=wp(:);
  Nwa=length(wa);
  Nwt=length(wt);
  Nwp=length(wp);
  if isempty(wa) && isempty(wt)
    error("wa and wt empty");
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
    vS=complementaryFIRlattice_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 6) || ...
         (all(isfield(vS,{"al","au","tl","tu","pl","pu"}))==false)
    error("numfields(vS)=%d, expected 6 (al,au,tl,tu,pl and pu)",numfields(vS));
  endif

  %
  % Sanity checks on coefficient vectors
  %
  k0=k0(:);khat0=khat0(:);kkhat_u=kkhat_u(:);kkhat_l=kkhat_l(:);
  Nk=length(k0);
  if (Nk==0)
    error("No active coefficients");
  endif
  if length(k0) ~= length(khat0)
    error("length(k0) ~= length(khat0)");
  endif
  Nkkhat=2*Nk;
  if length(kkhat_u) ~= Nkkhat
    error("length(kkhat_u)(%d) ~= Nkkhat(%d)",length(kkhat_u),Nkkhat);
  endif
  if length(kkhat_l) ~= Nkkhat
    error("length(kkhat_l)(%d) ~= Nkkhat(%d)",length(kkhat_l),Nkkhat);
  endif
  Nkkhat_active=length(kkhat_active);
  if isempty(kkhat_active)
    k=k0;
    khat=khat0;
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
  k=k0(:);khat=khat0(:);kkhat=[k;khat];xkkhat=kkhat(kkhat_active);
  % Initial squared response error
  [Esq,gradEsq]=complementaryFIRlatticeEsq(k,khat,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
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
    % The vector to be minimised is [epsilon;beta;deltakkhat] where epsilon is 
    % the MMSE error, beta is the coefficient step size and deltakkhat is the 
    % coefficient difference vector.
    %
    bt=-[1;1;zeros(Nkkhat_active,1)];

    % Linear constraints on reflection coefficients
    %   D'*[epsilon;beta;deltakkhat]+f>=0
    % implementing:
    %   kkhatu-(kkhat+deltakkhat) >= 0
    %   (kkhat+deltakkhat)-kkhatl >= 0
    % In matrix form:
    %   |0 0 -I||epsilon | + |kkhat_u - kkhat  | >= 0
    %   |0 0  I||beta    |   |kkhat   - kkhat_l|
    %           |deltakkhat |
    D=[ zeros(2,2*Nkkhat_active); ...
        [-eye(Nkkhat_active), eye(Nkkhat_active)] ];
    f=[ kkhat_u(kkhat_active)-kkhat(kkhat_active) ; ...
        kkhat(kkhat_active)-kkhat_l(kkhat_active)];
    
    % Squared amplitude linear constraints
    if ~isempty(vS.au)
      [Asq_au,gradAsq_au]=complementaryFIRlatticeAsq(wa(vS.au),k,khat);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.au));-gradAsq_au(:,kkhat_active)']];
      f=[f; Asqdu(vS.au)-Asq_au];
    endif
    if ~isempty(vS.al)
      [Asq_al,gradAsq_al]=complementaryFIRlatticeAsq(wa(vS.al),k,khat);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.al));gradAsq_al(:,kkhat_active)']];
      f=[f; Asq_al-Asqdl(vS.al)];
    endif

    % Group delay linear constraints
    if ~isempty(vS.tu)
      [T_tu,gradT_tu]=complementaryFIRlatticeT(wt(vS.tu),k,khat);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tu));-gradT_tu(:,kkhat_active)']];
      f=[f; Tdu(vS.tu)-T_tu];
    endif
    if ~isempty(vS.tl)
      [T_tl,gradT_tl]=complementaryFIRlatticeT(wt(vS.tl),k,khat);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tl));gradT_tl(:,kkhat_active)']];
      f=[f; T_tl-Tdl(vS.tl)];
    endif

    % Phase linear constraints
    if ~isempty(vS.pu)
      [P_pu,gradP_pu]=complementaryFIRlatticeP(wp(vS.pu),k,khat);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.pu));-gradP_pu(:,kkhat_active)']];
      f=[f; Pdu(vS.pu)-P_pu];
    endif
    if ~isempty(vS.pl)
      [P_pl,gradP_pl]=complementaryFIRlatticeP(wp(vS.pl),k,khat);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.pl));gradP_pl(:,kkhat_active)']];
      f=[f; P_pl-Pdl(vS.pl)];
    endif

    % SeDuMi linear constraint matrixes
    At=-D;
    ct=f;
    sedumiK.l=columns(D);
           
    % SeDuMi quadratic constraint matrixes

    % Step size constraints
    At1=[zeros(2,Nkkhat_active);eye(Nkkhat_active)];
    b1=[0;1;zeros(Nkkhat_active,1)];
    c1=zeros(Nkkhat_active,1);
    d1=0;
    At=[At, -[b1, At1]];
    ct=[ct;d1;c1];
    sedumiK.q=size(At1,2)+1;

    % MMSE frequency response constraints
    At2=[zeros(2,1);gradEsq(kkhat_active)'];
    b2=[1;0;zeros(Nkkhat_active,1)];
    c2=Esq;
    d2=0;
    At=[At, -[b2, At2]];
    ct=[ct;d2;c2];
    sedumiK.q=[sedumiK.q, size(At2,2)+1];

    % Call SeDuMi
    try
      [xs,ys,info]=sedumi(At,bt,ct,sedumiK,pars);
      if verbose
        printf("SeDuMi info.iter=%d, info.feasratio=%6.4g\n",
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
      xkkhat=[];
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
    xkkhat=xkkhat+delta;
    kkhat(kkhat_active)=xkkhat;
    k=kkhat(1:Nk);
    khat=kkhat((Nk+1):end);
    [Esq,gradEsq] = ...
      complementaryFIRlatticeEsq(k,khat,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    func_iter=func_iter+1;
    socp_iter=socp_iter+info.iter;
    if verbose
      printf("epsilon=%g\n",epsilon);
      printf("beta=%g\n",beta);
      printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
      printf("norm(delta)=%g\n",norm(delta));
      printf("k=[ ");printf("%g ",k');printf(" ]';\n"); 
      printf("khat=[ ");printf("%g ",khat');printf(" ]';\n"); 
      printf("norm(delta)/norm(xkkhat)=%g\n",norm(delta)/norm(xkkhat));
      printf("Esq= %g\n",Esq);
      printf("gradEsq=[");printf("%g ",gradEsq);printf("]\n");
      printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
      info
    endif
    if norm(delta)/norm(xkkhat) < tol
      printf("norm(delta)/norm(xkkhat) < tol\n");
      feasible=true;
      break;
    endif

  endwhile

endfunction
