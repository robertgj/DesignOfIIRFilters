function [k,c,kk,ck,socp_iter,func_iter,feasible]= ...
  schurOneMlatticePipelined_socp_mmse ...
    (vS,k0,epsilon0,c0,kk0,ck0, ...
     kc_u,kc_l,kc_active,dmax, ...
     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
     wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
     maxiter,ftol,ctol,verbose)
% [k,c,kk,ck,socp_iter,func_iter,feasible] =
% schurOneMlatticePipelined_socp_mmse(vS,k0,epsilon0,c0,kk0,ck0, ...
%                            kc_u,kc_l,kc_active,dmax, ...
%                            wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                            wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
%                            maxiter,ftol,ctol,verbose)
%
% SOCP MMSE optimisation of a one-multiplier Schur lattice filter with
% constraints on the amplitude, phase and low pass group delay responses. 
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   k0 - initial allpass filter multipliers
%   epsilon0 - state scaling coefficients. These have no effect on the
%              response but can improve numerical accuracy.
%   c0 - initial numerator tap coefficients
%   kk0 - nominally k0(1:(Nk-1)).*k0(2:Nk)
%   ck0 - nominally c0(2:Nk).*k0(2:Nk) (where c(1)=c_{0}, ... , c(Nk+1)=c_{Nk})
%   kc_u,kc_l - upper and lower bounds on the allpass filter coefficients
%   kc_active - indexes of elements of coefficients being optimised
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
%   wd - angular frequencies of the dAsqdw response
%   Dd - desired passband dAsqdw response
%   Ddu,Ddl - upper/lower mask for the desired dAsqdw response
%   Wd - dAsqdw response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   ftol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   k,c - filter design
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

  if (nargin ~= 34) || (nargout ~= 7)
    print_usage(strcat("[k,c,kk,ck,socp_iter,func_iter,feasible]= ...\n",
                       "  schurOneMlatticePipelined_socp_mmse ...\n",
                       "    (vS,k0,epsilon0,c0,kk0,ck0, ...\n",
                       "     kc_u,kc_l,kc_active,dmax, ...\n",
                       "     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...\n",
                       "     wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd. ...\n",
                       "     maxiter,ftol,ctol,verbose)"));
  endif

  %
  % Sanity checks on frequency response vectors
  %
  wa=wa(:);wt=wt(:);wp=wp(:);wd=wd(:);
  Nwa=length(wa);
  Nwt=length(wt);
  Nwp=length(wp);
  Nwd=length(wd);
  if isempty(wa) && isempty(wt) && isempty(wp) && isempty(wd)
    error("wa, wt, wp and wd empty");
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
    vS=schurOneMlatticePipelined_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 8) || ...
         (all(isfield(vS,{"al","au","tl","tu","pl","pu","dl","du"}))==false)
    error("numfields(vS)=%d, expected 8 (al,au,tl,tu,pl,pu,dl and du)", ...
          numfields(vS));
  endif

  %
  % Sanity checks on coefficient vectors
  %
  k0=k0(:);c0=c0(:);kk0=kk0(:);ck0=ck0(:);
  kc_u=kc_u(:);kc_l=kc_l(:);
  Nk=length(k0);
  Nc=length(c0);
  Nkk=length(kk0);
  Nck=length(ck0);
  Nkc=Nk+Nc+Nkk+Nck;
  if (Nkc==0)
    error("No active coefficients");
  endif
  if (Nk+1) ~= Nc
    error("Expected Nk(%d)+1 == Nc(%d)",Nk,Nc);
  endif
  if (Nk-1) ~= Nkk
    error("Expected Nk(%d)-1 == Nkk(%d)",Nk,Nkk);
  endif
  if (Nk-1) ~= Nck
    error("Expected Nk(%d)-1 == Nck(%d)",Nk,Nck);
  endif
  if length(kc_u) ~= Nkc
    error("Expected length(kc_u)(%d) == Nkc(%d)",length(kc_u),Nkc);
  endif
  if length(kc_l) ~= Nkc
    error("Expected length(kc_l)(%d) == Nkc(%d)",length(kc_l),Nkc);
  endif
  Nkc_active=length(kc_active);
  if isempty(kc_active)
    k=k0(:);
    c=c0(:);
    kk=kk0(:);
    ck=ck0(:);
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
  k=k0(:);
  c=c0(:);
  kk=kk0(:);
  ck=ck0(:);
  kc=[k;c;kk;ck];
  xkc=kc(kc_active);
  % Initial squared response error
  [Esq,gradEsq]=schurOneMlatticePipelinedEsq ...
                  (k,epsilon0,c,kk,ck,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
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
    bt=-[1;1;zeros(Nkc_active,1)];

    % Linear constraints on reflection coefficients
    %   D'*[epsilon;beta;deltakc]+f>=0
    % implementing:
    %   kcu-(kc+deltakc) >= 0
    %   (kc+deltakc)-kcl >= 0
    % In matrix form:
    %   |0 0 -I||epsilon | + |kc_u - kc  | >= 0
    %   |0 0  I||beta    |   |kc   - kc_l|
    %           |deltakc |
    D=[ zeros(2,2*Nkc_active); [-eye(Nkc_active), eye(Nkc_active)] ];
    f=[ kc_u(kc_active)-kc(kc_active) ; kc(kc_active)-kc_l(kc_active)];
    
    % Squared amplitude linear constraints
    if ~isempty(vS.au)
      [Asq_au,gradAsq_au] = ...
         schurOneMlatticePipelinedAsq(wa(vS.au),k,epsilon0,c,kk,ck);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.au));-gradAsq_au(:,kc_active)']];
      f=[f; Asqdu(vS.au)-Asq_au];
    endif
    if ~isempty(vS.al)
      [Asq_al,gradAsq_al] = ...
         schurOneMlatticePipelinedAsq(wa(vS.al),k,epsilon0,c,kk,ck);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.al));gradAsq_al(:,kc_active)']];
      f=[f; Asq_al-Asqdl(vS.al)];
    endif

    % Group delay linear constraints
    if ~isempty(vS.tu)
      [T_tu,gradT_tu] = ...
         schurOneMlatticePipelinedT(wt(vS.tu),k,epsilon0,c,kk,ck);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tu));-gradT_tu(:,kc_active)']];
      f=[f; Tdu(vS.tu)-T_tu];
    endif
    if ~isempty(vS.tl)
      [T_tl,gradT_tl] = ...
         schurOneMlatticePipelinedT(wt(vS.tl),k,epsilon0,c,kk,ck);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tl));gradT_tl(:,kc_active)']];
      f=[f; T_tl-Tdl(vS.tl)];
    endif

    % Phase linear constraints
    if ~isempty(vS.pu) || ~isempty(vS.pl)
      [P,gradP] = ...
         schurOneMlatticePipelinedP(wp,k,epsilon0,c,kk,ck);
      func_iter = func_iter+1;
    endif      
    if ~isempty(vS.pu)
      D=[D, [zeros(2,length(vS.pu));-gradP(vS.pu,kc_active)']];
      f=[f;                          Pdu(vS.pu)-P(vS.pu)];
    endif
    if ~isempty(vS.pl)
      D=[D, [zeros(2,length(vS.pl)); gradP(vS.pl,kc_active)']];
      f=[f;                          P(vS.pl)-Pdl(vS.pl)];
    endif

    % dAsqdw linear constraints
    if ~isempty(vS.du)
      [dAsqdw_du,graddAsqdw_du] = ...
         schurOneMlatticePipelineddAsqdw(wd(vS.du),k,epsilon0,c,kk,ck);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.du));-graddAsqdw_du(:,kc_active)']];
      f=[f; Ddu(vS.du)-dAsqdw_du];
    endif
    if ~isempty(vS.dl)
      [dAsqdw_dl,graddAsqdw_dl] = ...
         schurOneMlatticePipelineddAsqdw(wd(vS.dl),k,epsilon0,c,kk,ck);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.dl));graddAsqdw_dl(:,kc_active)']];
      f=[f; dAsqdw_dl-Ddl(vS.dl)];
    endif

    % SeDuMi linear constraint matrixes
    At=-D;
    ct=f;
    sedumiK.l=columns(D);
           
    % SeDuMi quadratic constraint matrixes

    % Step size constraints
    At1=[zeros(2,Nkc_active);eye(Nkc_active)];
    b1=[0;1;zeros(Nkc_active,1)];
    c1=zeros(Nkc_active,1);
    d1=0;
    At=[At, -[b1, At1]];
    ct=[ct;d1;c1];
    sedumiK.q=size(At1,2)+1;

    % MMSE frequency response constraints
    At2=[zeros(2,1);gradEsq(kc_active)'];
    b2=[1;0;zeros(Nkc_active,1)];
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
      xkc=[];
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
    xkc=xkc+delta;
    kc(kc_active)=xkc;
    k=kc(1:Nk);
    c=kc((Nk+1):(Nk+Nc));
    kk=kc((Nk+Nc+1):(Nk+Nc+Nkk));
    ck=kc((Nk+Nc+Nkk+1):(Nk+Nc+Nkk+Nck));
    [Esq,gradEsq]=schurOneMlatticePipelinedEsq ...
                    (k,epsilon0,c,kk,ck,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    func_iter=func_iter+1;
    socp_iter=socp_iter+info.iter;
    if verbose
      printf("epsilon=%g\n",epsilon);
      printf("beta=%g\n",beta);
      printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
      printf("norm(delta)=%g\n",norm(delta));
      printf("k=[ ");printf("%g ",k');printf(" ]';\n"); 
      printf("c=[ ");printf("%g ",c');printf(" ]';\n"); 
      printf("kk=[ ");printf("%g ",kk');printf(" ]';\n"); 
      printf("ck=[ ");printf("%g ",ck');printf(" ]';\n"); 
      printf("norm(delta)/norm(xkc)=%g\n",norm(delta)/norm(xkc));
      printf("Esq= %g\n",Esq);
      printf("gradEsq=[");printf("%g ",gradEsq);printf("]\n");
      printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
      info
    endif
    if norm(delta)/norm(xkc) < ftol
      printf("Esq= %g\n",Esq);
      printf("norm(delta)/norm(xkc) < ftol\n");
      feasible=true;
      break;
    endif

  endwhile

endfunction
