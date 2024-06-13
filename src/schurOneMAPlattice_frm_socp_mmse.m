function [k,u,v,socp_iter,func_iter,feasible]= ...
         schurOneMAPlattice_frm_socp_mmse ...
           (vS,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,
            kuv_u,kuv_l,kuv_active,dmax, ...
            wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
            maxiter,ftol,ctol,verbose)
% [k,u,v,socp_iter,func_iter,feasible]= ...
%         schurOneMAPlattice_frm_socp_mmse ...
%           (vS,k0,epsilon0,p0,c0,u0,v0,Mmodel,Dmodel,
%            kuv_u,kuv_l,kuv_active,dmax, ...
%            wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
%            maxiter,ftol,ctol,verbose)
%
% SOCP MMSE optimisation of an FRM filter with a model filter
% implemented as an allpass one-multiplier Schur lattice filter with
% constraints on the amplitude, phase and group delay responses
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu,pl,pu}
%   k0 - initial allpass filter multipliers
%   epsilon0,p0 - state scaling coefficients. These have no effect on the
%                 response but can improve numerical accuracy.
%   u0,v0 - initial unique FIR masking filter coefficients
%   Mmodel - model filter FRM decimation factor
%   Dmodel - nominal model filter delay
%   kuv_u,kuv_l - upper and lower bounds on the allpass filter coefficients
%   kuv_active - indexes of elements of coefficients being optimised
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
%   Pd - desired phase response
%   Pdu,Pdl - upper/lower mask for the desired phase response
%   Wp - phase response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   ftol - tolerance on coefficient updates
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   k,u,v - filter design
%   socp_iter - number of SOCP iterations
%   func_iter - number of function calls
%   feasible - design satisfies the constraints 

% Copyright (C) 2024 Robert G. Jenssen
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

  if (nargin ~= 31) || (nargout ~= 6)
    print_usage("[k,u,v,socp_iter,func_iter,feasible]= ...\n\
      schurOneMAPlattice_frm_socp_mmse(vS,k0,epsilon0,p0,u0,v0, ...\n\
             Mmodel,Dmodel,kuv_u,kuv_l,kuv_active,dmax, ...\n\
             wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...\n\
             maxiter,ftol,ctol,verbose)");
  endif

  %
  % Sanity checks on frequency response vectors
  %
  wa=wa(:);
  Nwa=length(wa);
  wt=wt(:);
  Nwt=length(wt);
  wp=wp(:);
  Nwp=length(wp);
  if isempty(wa) && isempty(wt) && isempty(wp)
    error("wa, wt and wp are empty");
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
  if ~isempty(Wp) && Nwp ~= length(Wt)
    error("Expected length(wp)(%d) == length(Wp)(%d)",Nwp,length(Wp));
  endif
  if isempty(vS)
    vS=schurOneMAPlattice_frm_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 6) || ...
         (all(isfield(vS,{"al","au","tl","tu","pl","pu"}))==false)
    error("numfields(vS)=%d, expected 6 (al,au,tl,tu,pl and pu)",numfields(vS));
  endif

  %
  % Sanity checks on coefficient vectors
  %
  k0=k0(:);u0=u0(:);v0=v0(:);kuv_u=kuv_u(:);kuv_l=kuv_l(:);
  Nk=length(k0);
  Nu=length(u0);
  Nv=length(v0);
  Nkuv=Nk+Nu+Nv;
  if (Nkuv==0)
    error("No active coefficients");
  endif
  if Nu ~= Nv
    error("Expected Nu(%d) == Nv(%d)",Nu,Nv);
  endif
  if length(kuv_u) ~= Nkuv
    error("Expected length(kuv_u)(%d) == Nkuv(%d)",length(kuv_u),Nkuv);
  endif
  if length(kuv_l) ~= Nkuv
    error("Expected length(kuv_l)(%d) == Nkuv(%d)",length(kuv_l),Nkuv);
  endif
  Nkuv_active=length(kuv_active);
  if isempty(kuv_active)
    k=k0;
    u=u0;
    v=v0;
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
  k=k0(:);u=u0(:);v=v0(:);kuv=[k;u;v];xkuv=kuv(kuv_active);

  % Initial squared response error
  [Esq,gradEsq]=schurOneMAPlattice_frmEsq ...
                  (k,epsilon0,p0,u,v,Mmodel,Dmodel,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
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
    % The vector to be minimised is [epsilon;beta;deltakuv] where epsilon is 
    % the MMSE error, beta is the coefficient step size and deltakuv is the 
    % coefficient difference vector.
    %
    bt=-[1;1;zeros(Nkuv_active,1)];

    % Linear constraints on reflection coefficients
    %   D'*[epsilon;beta;deltakuv]+f>=0
    % implementing:
    %   kuvu-(kuv+deltakuv) >= 0
    %   (kuv+deltakuv)-kuvl >= 0
    % In matrix form:
    %   |0 0 -I||epsilon  | + |kuv_u - kuv  | >= 0
    %   |0 0  I||beta     |   |kuv   - kuv_l|
    %           |deltakuv |
    D=[ zeros(2,2*Nkuv_active); [-eye(Nkuv_active), eye(Nkuv_active)] ];
    f=[ kuv_u(kuv_active)-kuv(kuv_active) ; kuv(kuv_active)-kuv_l(kuv_active)];
    
    % Squared amplitude linear constraints
    if ~isempty(vS.au)
      [Asq_au,gradAsq_au]=schurOneMAPlattice_frmAsq ...
                            (wa(vS.au),k,epsilon0,p0,u,v,Mmodel,Dmodel);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.au));-gradAsq_au(:,kuv_active)']];
      f=[f; Asqdu(vS.au)-Asq_au];
    endif
    if ~isempty(vS.al)
      [Asq_al,gradAsq_al]=schurOneMAPlattice_frmAsq ...
                            (wa(vS.al),k,epsilon0,p0,u,v,Mmodel,Dmodel);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.al));gradAsq_al(:,kuv_active)']];
      f=[f; Asq_al-Asqdl(vS.al)];
    endif

    % Group delay linear constraints
    if ~isempty(vS.tu)
      [T_tu,gradT_tu]=schurOneMAPlattice_frmT ...
                        (wt(vS.tu),k,epsilon0,p0,u,v,Mmodel,Dmodel);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tu));-gradT_tu(:,kuv_active)']];
      f=[f; Tdu(vS.tu)-T_tu];
    endif
    if ~isempty(vS.tl)
      [T_tl,gradT_tl]=schurOneMAPlattice_frmT ...
                        (wt(vS.tl),k,epsilon0,p0,u,v,Mmodel,Dmodel);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tl));gradT_tl(:,kuv_active)']];
      f=[f; T_tl-Tdl(vS.tl)];
    endif

    % Phase linear constraints
    if ~isempty(vS.pu) || ~isempty(vS.pl)
      [P,gradP]=schurOneMlatticeP(wp,k,epsilon0,p0,c);
      func_iter = func_iter+1;
    endif      
    if ~isempty(vS.pu)
      D=[D, [zeros(2,length(vS.pu));-gradP(vS.pu,kuv_active)']];
      f=[f; Pdu(vS.pu)-P(vS.pu)];
    endif
    if ~isempty(vS.pl)
      D=[D, [zeros(2,length(vS.pl)); gradP(vS.pl,kuv_active)']];
      f=[f; P(vS.pl)-Pdl(vS.pl)];
    endif

    % SeDuMi linear constraint matrixes
    At=-D;
    ct=f;
    sedumiK.l=columns(D);
           
    % SeDuMi quadratic constraint matrixes

    % Step size constraints
    At1=[zeros(2,Nkuv_active);eye(Nkuv_active)];
    b1=[0;1;zeros(Nkuv_active,1)];
    c1=zeros(Nkuv_active,1);
    d1=0;
    At=[At, -[b1, At1]];
    ct=[ct;d1;c1];
    sedumiK.q=size(At1,2)+1;

    % MMSE frequency response constraints
    At2=[zeros(2,1);gradEsq(kuv_active)'];
    b2=[1;0;zeros(Nkuv_active,1)];
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
      xkuv=[];
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
    xkuv=xkuv+delta;
    kuv(kuv_active)=xkuv;
    k=kuv(1:Nk);
    u=kuv((Nk+1):(Nk+Nu));
    v=kuv((Nk+Nu+1):(Nk+Nu+Nv));
    [Esq,gradEsq] = ...
      schurOneMAPlattice_frmEsq(k,epsilon0,p0,u,v,Mmodel,Dmodel, ...
                                wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    func_iter=func_iter+1;
    socp_iter=socp_iter+info.iter;
    if verbose
      printf("epsilon=%g\n",epsilon);
      printf("beta=%g\n",beta);
      printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
      printf("norm(delta)=%g\n",norm(delta));
      printf("k=[ ");printf("%g ",k');printf(" ]';\n"); 
      printf("u=[ ");printf("%g ",u');printf(" ]';\n"); 
      printf("v=[ ");printf("%g ",v');printf(" ]';\n"); 
      printf("norm(delta)/norm(xkuv)=%g\n",norm(delta)/norm(xkuv));
      printf("Esq= %g\n",Esq);
      printf("gradEsq=[");printf("%g ",gradEsq);printf("]\n");
      printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
      info
    endif
    if norm(delta)/norm(xkuv) < ftol
      printf("norm(delta)/norm(xkuv) < ftol\n");
      feasible=true;
      break;
    endif

  endwhile

endfunction
