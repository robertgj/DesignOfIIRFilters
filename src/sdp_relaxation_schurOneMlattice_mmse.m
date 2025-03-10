function [k_min,c_min,socp_iter,func_iter,feasible]= ...
  sdp_relaxation_schurOneMlattice_mmse(vS,k0,epsilon0,p0,c0, ...
                            kc_u,kc_l,kc_active,kc_delta, ...
                            wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                            wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
                            maxiter,ftol,ctol,verbose)
% [k_min,c_min,socp_iter,func_iter,feasible] =
%   sdp_relaxation_schurOneMlattice_mmse(vS,k0,epsilon0,p0,c0, ...
%                             kc_u,kc_l,kc_active,kc_delta, ...
%                             wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                             wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
%                             maxiter,ftol,ctol,verbose)
%
% SDP optimisation of a one-multiplier Schur lattice filter with integer
% coefficients and constraints on the amplitude, phase and group delay
% responses.
%
% The objective function minimised is:
% (0.5*(kc0+kc_delta.*y)'*hessEsq*(kc0+kc_delta.*y))+(gradEsq*(kc0+kc_delta.*y))
% where y is -1 or 1.
%
% The response inequalities are of the form:
%   (Asqdu-Asq) - gradAsq*(kc_delta.*y) >= 0
%   (Asq-Asqdl) + gradAsq*(kc_delta.*y) >= 0
% where Asq is the squared magnitude response at kc0, Asqdl and Asqdu are
% the desired lower and upper bounds on Asq and gradAsq is the gradient of
% the squared magnitude response at kc0.
%
% It may be necessary to adjust param.eqTolerance and param.SDPsolverEpsilon
%
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   k0 - initial allpass filter multipliers
%   epsilon0,p0 - state scaling coefficients. These have no effect on the
%                 response but can improve numerical accuracy.
%   c0 - initial numerator tap coefficients
%   kc_u,kc_l - upper and lower bounds on the allpass filter coefficients
%   kc_active - indexes of elements of coefficients being optimised
%   kc_delta - the truncated coefficients are kc0+(kc_delta.*y) 
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
%   maxiter - not used
%   ftol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   k_min,c_min - filter design
%   socp_iter - number of SOCP iterations
%   func_iter - number of function calls
%   feasible - design satisfies the constraints 
%
% If ftol is a structure then the ftol.dtol field is the minimum relative
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

  if (nargin ~= 33) || (nargout ~= 5)
    print_usage(["[k,c,socp_iter,func_iter,feasible]= ...\n", ...
 "  sdp_relaxation_schurOneMlattice_mmse(vS,k0,epsilon0,p0,c0, ...\n", ...
 "                            kc_u,kc_l,kc_active,kc_delta, ...\n", ...
 "                            wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...\n", ...
 "                            wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...\n", ...
 "                            maxiter,ftol,ctol,verbose)"]);
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
    vS=schurOneMlattice_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 8) || ...
         (all(isfield(vS,{"al","au","tl","tu","pl","pu","dl","du"}))==false)
    error("numfields(vS)=%d, expected 8 (al,au,tl,tu,pl,pu,dl and du)", ...
          numfields(vS));
  endif
  if isstruct(ftol)
    if all(isfield(ftol,{"dtol","stol"})) == false
      error("Expect ftol structure to have fields dtol and stol");
    endif
    pars.eps=ftol.stol;
    if verbose
      fprintf(stderr,"Warning! SeDuMi pars.eps set to %g\n",pars.eps);
    endif
  endif

  Nresp=length(vS.al)+length(vS.au) + ...
        length(vS.tl)+length(vS.tu) + ...
        length(vS.pl)+length(vS.pu) + ...
        length(vS.dl)+length(vS.du);

  %
  % Sanity checks on coefficient vectors
  %
  k0=k0(:);c0=c0(:);kc_u=kc_u(:);kc_l=kc_l(:);
  kc_active=kc_active(:);
  kc_delta=kc_delta(:);
  Nk=length(k0);
  Nc=length(c0);
  Nkc=Nk+Nc;
  if (Nkc==0)
    error("No active coefficients");
  endif
  if (Nk+1) ~= Nc
    error("Expected Nk(%d)+1 == Nc(%d)",Nk,Nc);
  endif
  if length(kc_u) ~= Nkc
    error("Expected length(kc_u)(%d) == Nkc(%d)",length(kc_u),Nkc);
  endif
  if length(kc_l) ~= Nkc
    error("Expected length(kc_l)(%d) == Nkc(%d)",length(kc_l),Nkc);
  endif
  if length(kc_delta) ~= Nkc
    error("Expected length(kc_delta)(%d) == Nkc(%d)",length(kc_delta),Nkc);
  endif

  %
  % Initialise
  %
  socp_iter=0;func_iter=0;feasible=false;
  % SeDuMi logging output destination
  if verbose
    pars.fid=2;
  else
    pars.fid=0;
  endif
  
  % Coefficient vector being optimised
  kc0=[k0(:);c0(:)];
  Nkc_active=length(kc_active);
  if isempty(kc_active)
    error("kc_active empty");
  endif
  if any(kc_active>Nkc)
    error("kc_active>Nkc");
  endif
  if any((kc0+kc_delta) > kc_u)
    error("any((kc0+kc_delta) > kc_u)");
  endif
  if any((kc0-kc_delta) < kc_l)
    error("any((kc0-kc_delta) < kc_l)");
  endif

  %
  % Initial squared response error and gradient
  %
  [Esq0,gradEsq0,~,hessEsq0]=schurOneMlatticeEsq(k0,epsilon0,p0,c0, ...
                                                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  func_iter=func_iter+1;
  if verbose
    printf("Initial Esq=%g\n",Esq0);
    printf("Initial gradEsq=[");printf("%g ",gradEsq0);printf("]\n");
  endif

  %
  % Set up the SeDuMi problem.
  %   minimise cc*yy 
  %   subject to [Y,y;y',1] is positive definite
  %   where 1. Y is symmetric and the diagonal elements of Y are 1,
  %         2. yy is the concatenation of the vector of distinct off diagonal
  %            of elements of Y with y
  %         3. kc0+(kc0_delta.*sign(y)) is the new filter design
  %
  MM=Nkc_active*(Nkc_active-1)/2;
  NN=MM+Nkc_active;
  
  % Linear constraints on reflection coefficients
  %   D'*deltakc+f>=0
  % implementing:
  %   kcu-(kc+deltakc) >= 0
  %   (kc+deltakc)-kcl >= 0
  D=[ [zeros(MM,Nkc_active); -diag(kc_delta(kc_active))], ...
      [zeros(MM,Nkc_active);  diag(kc_delta(kc_active))] ];
  f=[ kc_u(kc_active)-kc0(kc_active); ...
      kc0(kc_active)-kc_l(kc_active) ];
  
  % Approximate squared-amplitude linear constraints (SeDuMi format is Dx+f>=0): 
  %   -Asq-gradAsq*(kc0_delta.*y) + Asqdu >= 0
  %    Asq+gradAsq*(kc0_delta.*y) - Asqdl >= 0
  if ~isempty(vS.au)
    [Asq_au,gradAsq_au]=schurOneMlatticeAsq(wa(vS.au),k0,epsilon0,p0,c0);
    func_iter = func_iter+1;
    gradAsq_au_delta=gradAsq_au.*kron(ones(length(vS.au),1),kc_delta');
    D=[D,[zeros(MM,length(vS.au));-gradAsq_au_delta(:,kc_active)']];
    f=[f;Asqdu(vS.au)-Asq_au];
  endif
  if ~isempty(vS.al) 
    [Asq_al,gradAsq_al]=schurOneMlatticeAsq(wa(vS.al),k0,epsilon0,p0,c0);
    func_iter = func_iter+1;
    gradAsq_al_delta=gradAsq_al.*kron(ones(length(vS.al),1),kc_delta');
    D=[D,[zeros(MM,length(vS.al));gradAsq_al_delta(:,kc_active)']];
    f=[f;Asq_al-Asqdl(vS.al)];
  endif
  
  % Approximate group-delay linear constraints 
  if ~isempty(vS.tu)
    [T_tu,gradT_tu]=schurOneMlatticeT(wt(vS.tu),k0,epsilon0,p0,c0);
    func_iter = func_iter+1;
    gradT_tu_delta=gradT_tu.*kron(ones(length(vS.tu),1),kc_delta');
    D=[D,[zeros(MM,length(vS.tu));-gradT_tu_delta(:,kc_active)']];
    f=[f;Tdu(vS.tu)-T_tu];
  endif
  if ~isempty(vS.tl) 
    [T_tl,gradT_tl]=schurOneMlatticeT(wt(vS.tl),k0,epsilon0,p0,c0);
    func_iter = func_iter+1;
    gradT_tl_delta=gradT_tl.*kron(ones(length(vS.tl),1),kc_delta');
    D=[D,[zeros(MM,length(vS.tl));gradT_tl_delta(:,kc_active)']];
    f=[f;T_tl-Tdl(vS.tl)];
  endif

  % Approximate phase linear constraints
  if ~isempty(vS.pu) || ~isempty(vS.pl)
    [P,gradP]=schurOneMlatticeP(wp,k,epsilon0,p0,c);
    func_iter = func_iter+1;
  endif
  if ~isempty(vS.pu)
    gradP_pu_delta=gradP(vS.pu).*kron(ones(length(vS.pu),1),kc_delta');
    D=[D,[zeros(MM,length(vS.pu));-gradP_pu_delta(:,kc_active)']];
    f=[f;                          Pdu(vS.pu)-P(vS.pu)];
  endif
  if ~isempty(vS.pl) 
    gradP_pl_delta=gradP(vS.pl).*kron(ones(length(vS.pl),1),kc_delta');
    D=[D,[zeros(MM,length(vS.pl)); gradP_pl_delta(:,kc_active)']];
    f=[f;                          P(vS.pl)-Pdl(vS.pl)];
  endif
 
  % Approximate dAsqdw linear constraints
  if ~isempty(vS.du)
    [dAsqdw_du,graddAsqdw_du] = ...
       schurOneMlatticedAsqdw(wd(vS.du),k0,epsilon0,p0,c0);
    func_iter = func_iter+1;
    graddAsqdw_du_delta=graddAsqdw_du.*kron(ones(length(vS.du),1),kc_delta');
    D=[D,[zeros(MM,length(vS.du));-graddAsqdw_du_delta(:,kc_active)']];
    f=[f;Ddu(vS.du)-dAsqdw_du];
  endif
  if ~isempty(vS.dl) 
    [dAsqdw_dl,graddAsqdw_dl] = ...
       schurOneMlatticedAsqdw(wd(vS.dl),k0,epsilon0,p0,c0);
    func_iter = func_iter+1;
    graddAsqdw_dl_delta=graddAsqdw_dl.*kron(ones(length(vS.dl),1),kc_delta');
    D=[D,[zeros(MM,length(vS.dl));graddAsqdw_dl_delta(:,kc_active)']];
    f=[f;dAsqdw_dl-Ddl(vS.dl)];
  endif

  % Triangle inequalities (in the SeDuMi form: Dy+f>=0)
  Fn=zeros(Nkc_active+1);
  Fn(find(triu(ones(Nkc_active+1),1)))=1:NN;
  byyY=ones(4*MM,1);
  AyyY=zeros(NN,4*MM);
  nn=-3;
  for m=1:(Nkc_active-1),
    for n=(m+1):Nkc_active,
      nn=nn+4;
      % y(m)+y(n)+Y(m,n) + 1 >= 0
      AyyY(Fn(m,Nkc_active+1), nn)=1; 
      AyyY(Fn(n,Nkc_active+1), nn)=1;
      AyyY(Fn(m,n)           , nn)=1;
      % y(m)-y(n)-Y(m,n) + 1 >= 0
      AyyY(Fn(m,Nkc_active+1), nn+1)=1; 
      AyyY(Fn(n,Nkc_active+1), nn+1)=-1;
      AyyY(Fn(m,n)           , nn+1)=-1; 
      % -y(m)-y(n)+Y(m,n) + 1 >= 0
      AyyY(Fn(m,Nkc_active+1), nn+2)=-1; 
      AyyY(Fn(n,Nkc_active+1), nn+2)=-1;
      AyyY(Fn(m,n),            nn+2)=1;
      % -y(m)+y(n)-Y(m,n) + 1 >= 0
      AyyY(Fn(m,Nkc_active+1), nn+3)=-1; 
      AyyY(Fn(n,Nkc_active+1), nn+3)=1;
      AyyY(Fn(m,n)           , nn+3)=-1;
    endfor
  endfor

  % Minimise the filter response MMSE error
  xkc0=kc0(kc_active);
  xkc_delta=kc_delta(kc_active);
  q=gradEsq0(kc_active);
  Q=hessEsq0(kc_active,kc_active);
  Fhat=find(triu(ones(Nkc_active),1));
  Qhat=Q.*(xkc_delta*(xkc_delta'));
  cc=zeros(NN,1); 
  cc(1:MM)=Qhat(Fhat);
  cc((MM+1):NN)=(((xkc0')*Q)+q).*(xkc_delta');

  % Positive definite constraint
  F0=eye(Nkc_active+1);
  F=cell(NN,1);
  [Fr,Fc]=find(triu(ones(Nkc_active+1),1));
  for m=1:NN,
    F{m}=zeros(size(F0));
    F{m}(Fr(m),Fc(m))=1;
    F{m}(Fc(m),Fr(m))=1;
  endfor
  As=zeros(NN,size(vec(F0),1));
  for m=1:NN,
    As(m,:)=-vec(F{m});
  endfor

  % SeDuMi variables
  Att=[-[D,AyyY], As];
  btt=-cc;
  ctt=[[f;byyY];vec(F0)];
  K.l=columns(D)+columns(AyyY);
  K.s=size(F0,1);

  use_SOCP_objective=false;
  if use_SOCP_objective
    % SOCP minimisation of the objective function with x=[delta;epsilon]
    % such that |As'*x+c|<=[zeros;1]'*x
    %   1. SeDuMi has numerical problems
    %   2. [yy,y] doesn't go to -1,1 in the triangle inequalities 
    D=[D;zeros(1,columns(D))];
    AyyY=[AyyY;zeros(1,columns(AyyY))];
    As=[As;zeros(1,columns(As))];
    Aq=[cc;0];
    bq=[zeros(size(cc));1];
    cq=Esq0+(diag(Q)'*(xkc_delta.^2)/2);
    dq=0;

    Att=[-[D,AyyY],-[bq,Aq], As];
    btt=-bq;
    ctt=[[f;byyY];[dq;cq];vec(F0)];
    K.l=columns(D)+columns(AyyY);
    K.q=2;
    K.s=size(F0,1);
    % Avoid Sedumi "Run into numerical problems" warning
    pars.eps=1e-6;
    fprintf(stderr,"Warning! SeDuMi pars.eps set to %g\n",pars.eps);
  endif

  % Call SeDuMi
  try
    [xs,ys,info]=sedumi(Att,btt,ctt,K,pars);
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
    k_min=[];
    c_min=[];
    feasible=false;
    err=lasterror();
    for e=1:length(err.stack)
      fprintf(stderr,"Called %s at line %d\n", ...
              err.stack(e).name,err.stack(e).line);
    endfor
    error("%s\n", err.message);
  end_try_catch
  
  % Extract results
  y=ys((MM+1):NN);
  kc_min=kc0;
  kc_min(kc_active)=xkc0+(sign(y).*xkc_delta);
  k_min=kc_min(1:Nk);
  c_min=kc_min((Nk+1):end);
  socp_iter=info.iter;
  feasible=true;
  if verbose
    if use_SOCP_objective, printf("epsilon=%g\n", ys(end)); end;
    printf("y=[ ");printf("%13.10f ",y');printf(" ]';\n"); 
    printf("k_min=[ ");printf("%15.12f ",k_min');printf(" ]';\n"); 
    printf("c_min=[ ");printf("%15.12f ",c_min');printf(" ]';\n"); 
    Esq=schurOneMlatticeEsq(k_min,epsilon0,p0,c_min, ...
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    func_iter=func_iter+1;
    printf("Esq= %g\n",Esq);
    printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
    info
  endif

endfunction
