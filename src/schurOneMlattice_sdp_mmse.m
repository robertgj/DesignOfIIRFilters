function [k_min,c_min,socp_iter,func_iter,feasible]= ...
  schurOneMlattice_sdp_mmse(vS,k0,epsilon0,p0,c0, ...
                            kc_u,kc_l,kc_active,kc_delta, ...
                            wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                            wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose)
% [k_min,c_min,socp_iter,func_iter,feasible] =
%   schurOneMlattice_sdp_mmse(vS,k0,epsilon0,p0,c0, ...
%                             kc_u,kc_l,kc_active,kc_delta, ...
%                             wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                             wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose)
%
% SDP optimisation of a one-multiplier Schur lattice filter with integer
% coefficients and constraints on the amplitude, phase and group delay
% responses.
%
% The objective function minimised is:
% (0.5*(kc0+kc_delta.*y)'*hessEsq*(kc0+kc_delta.*y))+(gradEsq*(kc0+kc_delta.*y))
% where y is -1 or 1 and the off-diagonal elements of hessEsq are found by
% numerical approximation.
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
%   wp - angular frequencies of the delay response
%   Pd - desired passband group delay response
%   Pdu,Pdl - upper/lower mask for the desired phase response
%   Wp - phase response weight at each frequency
%   maxiter - not used
%   tol - tolerance
%   verbose - 
%
% Outputs:
%   k_min,c_min - filter design
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

  if (nargin ~= 27) || (nargout ~= 5)
    print_usage("[k,c,socp_iter,func_iter,feasible]= ...\n\
  schurOneMlattice_sdp_mmse(vS,k0,epsilon0,p0,c0, ...\n\
                            kc_u,kc_l,kc_active,kc_delta, ...\n\
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
    vS=schurOneMlattice_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 6) || ...
         (all(isfield(vS,{"al","au","tl","tu","pl","pu"}))==false)
    error("numfields(vS)=%d, expected 6 (al,au,tl,tu,pl and pu)",numfields(vS));
  endif
  Nresp=length(vS.al)+length(vS.au)+ ...
        length(vS.tl)+length(vS.tu)+ ...
        length(vS.pl)+length(vS.pu);

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
  [Esq0,gradEsq0]=schurOneMlatticeEsq(k0,epsilon0,p0,c0, ...
                                      wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  func_iter=func_iter+1;
  if verbose
    printf("Initial Esq=%g\n",Esq0);
    printf("Initial gradEsq=[");printf("%g ",gradEsq0);printf("]\n");
  endif

  %
  % Numerical approximation to hessEsq0
  %
  del=tol*10;
  % del-squared-Esq-del-k-m-del-c
  for m=1:Nk
    delk=zeros(size(k0));
    delk(m)=del/2;
    [~,gradEsq_mnPdel2]=schurOneMlatticeEsq(k0+delk,epsilon0,p0,c0, ...
                                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [~,gradEsq_mnMdel2]=schurOneMlatticeEsq(k0-delk,epsilon0,p0,c0, ...
                                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delk=shift(delk,1);
    hessEsq0(m,:)=(gradEsq_mnPdel2-gradEsq_mnMdel2)/del;
  endfor 
  % del-squared-Esq-del-k-del-c-m
  for m=1:Nc
    delc=zeros(size(c0));
    delc(m)=del/2;
    [~,gradEsq_mnPdel2]=schurOneMlatticeEsq(k0,epsilon0,p0,c0+delc, ...
                                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    [~,gradEsq_mnMdel2]=schurOneMlatticeEsq(k0,epsilon0,p0,c0-delc, ...
                                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    delc=shift(delc,1);
    hessEsq0(m+Nk,:)=(gradEsq_mnPdel2-gradEsq_mnMdel2)/del;
  endfor
  func_iter=func_iter+Nkc;
  % Sanity check
  if ~isdefinite(hessEsq0(Nkc_active,Nkc_active))
    error("hessEsq0(Nkc_active,Nkc_active) is not positive definite");
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
  if 1
    D=[];
    f=[];
  else
    D=[ [zeros(MM,Nkc_active); -eye(Nkc_active)], ...
        [zeros(MM,Nkc_active);  eye(Nkc_active)] ];
    f=[ kc_u(kc_active)-kc0(kc_active); ...
        kc0(kc_active)-kc_l(kc_active) ];
  endif
  
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
    [T_tu,gradT_tu]=schurOneMlatticeP(wt(vS.tu),k0,epsilon0,p0,c0);
    func_iter = func_iter+1;
    gradT_tu_delta=gradT_tu.*kron(ones(length(vS.tu),1),kc_delta');
    D=[D,[zeros(MM,length(vS.tu));-gradT_tu_delta(:,kc_active)']];
    f=[f;Tdu(vS.tu)-T_tu];
  endif
  if ~isempty(vS.tl) 
    [T_tl,gradT_tl]=schurOneMlatticeP(wt(vS.tl),k0,epsilon0,p0,c0);
    func_iter = func_iter+1;
    gradT_tl_delta=gradT_tl.*kron(ones(length(vS.tl),1),kc_delta');
    D=[D,[zeros(MM,length(vS.tl));gradT_tl_delta(:,kc_active)']];
    f=[f;T_tl-Tdl(vS.tl)];
  endif

  % Approximate phase linear constraints 
  if ~isempty(vS.pu)
    [P_pu,gradP_pu]=schurOneMlatticeP(wp(vS.pu),k0,epsilon0,p0,c0);
    func_iter = func_iter+1;
    gradP_pu_delta=gradP_pu.*kron(ones(length(vS.pu),1),kc_delta');
    D=[D,[zeros(MM,length(vS.pu));-gradP_pu_delta(:,kc_active)']];
    f=[f;Pdu(vS.pu)-P_pu];
  endif
  if ~isempty(vS.pl) 
    [P_pl,gradP_pl]=schurOneMlatticeP(wp(vS.pl),k0,epsilon0,p0,c0);
    func_iter = func_iter+1;
    gradP_pl_delta=gradP_pl.*kron(ones(length(vS.pl),1),kc_delta');
    D=[D,[zeros(MM,length(vS.pl));gradP_pl_delta(:,kc_active)']];
    f=[f;P_pl-Pdl(vS.pl)];
  endif

  % Triangle inequalities (in the SeDuMi form: Dy+f>=0)
  Fn=zeros(Nkc_active+1);
  Fn(find(triu(ones(Nkc_active+1),1)))=1:NN;
  byyY=ones(4*MM,1);
  AyyY=zeros(4*MM,NN);
  nn=-3;
  for m=1:(Nkc_active-1),
    for n=(m+1):Nkc_active,
      nn=nn+4;
      % y(m)+y(n)+Y(m,n) + 1 >= 0
      AyyY(nn,Fn(m,Nkc_active+1))=1; 
      AyyY(nn,Fn(n,Nkc_active+1))=1;
      AyyY(nn,Fn(m,n))=1;
      % y(m)-y(n)-Y(m,n) + 1 >= 0
      AyyY(nn+1,Fn(m,Nkc_active+1))=1; 
      AyyY(nn+1,Fn(n,Nkc_active+1))=-1;
      AyyY(nn+1,Fn(m,n))=-1; 
      % -y(m)-y(n)+Y(m,n) + 1 >= 0
      AyyY(nn+2,Fn(m,Nkc_active+1))=-1; 
      AyyY(nn+2,Fn(n,Nkc_active+1))=-1;
      AyyY(nn+2,Fn(m,n))=1;
      % -y(m)+y(n)-Y(m,n) + 1 >= 0
      AyyY(nn+3,Fn(m,Nkc_active+1))=-1; 
      AyyY(nn+3,Fn(n,Nkc_active+1))=1;
      AyyY(nn+3,Fn(m,n))=-1;
    endfor
  endfor

  % Minimise cc*y
  [Fr,Fc]=find(triu(ones(Nkc_active+1),1));
  cc=zeros(1,NN); 
  xkc0=kc0(kc_active);
  xkc_delta=kc_delta(kc_active);
  q=gradEsq0(kc_active);
  Q=hessEsq0(kc_active,kc_active);
 for k=1:MM,
    cc(m)=Q(Fr(m),Fc(m))*xkc_delta(Fr(m))*xkc_delta(Fc(m));
  endfor
  cc((MM+1):NN)=(((xkc0')*Q)+q).*(xkc_delta');

  % Positive definite constraint
  F0=eye(Nkc_active+1);
  F=cell(NN,1);
  for m=1:NN,
    F{m}=zeros(size(F0));
    F{m}(Fr(m),Fc(m))=1;
    F{m}(Fc(m),Fr(m))=1;
  endfor
  At=zeros(size(vec(F0),1),NN);
  for m=1:NN,
    At(:,m)=-vec(F{m});
  endfor

  % SeDuMi variables
  Att=[-D';-AyyY;At];
  btt=-cc;
  ctt=[f;byyY;vec(F0)];
  K.l=rows(D')+rows(AyyY);
  K.s=size(F0,1);

  % Call SeDuMi
  try
    [x,yy,info]=sedumi(Att,btt,ctt,K,pars);
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
  y=yy((MM+1):NN);
  kc_min=zeros(size(kc0));
  kc_min(kc_active)=xkc0+(sign(y).*xkc_delta);
  k_min=kc_min(1:Nk);
  c_min=kc_min((Nk+1):end);
  socp_iter=info.iter;
  feasible=true;
  if verbose
    printf("y=[ ");printf("%13.10f ",y');printf(" ]';\n"); 
    printf("k_min=[ ");printf("%15.12f ",k_min');printf(" ]';\n"); 
    printf("c_min=[ ");printf("%15.12f ",c_min');printf(" ]';\n"); 
    Esq=schurOneMlatticeEsq(k_min,epsilon0,p0,c_min, ...
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    func_iter=func_iter+1;
    printf("Esq= %g\n",Esq);
    printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
    info
  endif

endfunction
