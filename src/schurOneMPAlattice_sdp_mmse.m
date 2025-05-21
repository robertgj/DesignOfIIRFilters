function [A1k_min,A2k_min,socp_iter,func_iter,feasible]= ...
  schurOneMPAlattice_sdp_mmse...
    (vS,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
     difference,k_u,k_l,k_active,k_delta, ...
     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
     wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd,maxiter,ftol,ctol,verbose)
% [A1k_min,A2k_min,socp_iter,func_iter,feasible] =
%   schurOneMPAlattice_sdp_mmse ...
%      (vS,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
%       difference,k_u,k_l,k_active,k_delta, ...
%       wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%       wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd,maxiter,ftol,ctol,verbose)
%
% SDP optimisation of a parallel one-multiplier Schur allpasslattice filter
% with integer coefficients and constraints on the amplitude, phase and
% group delay responses.
%
% The objective function minimised is:
% (0.5*(k0+k_delta.*y)'*hessEsq*(k0+k_delta.*y))+(gradEsq*(k0+k_delta.*y))
% where y is -1 or 1.
%
% The response inequalities are of the form:
%   (Asqdu-Asq) - gradAsq*(k_delta.*y) >= 0
%   (Asq-Asqdl) + gradAsq*(k_delta.*y) >= 0
% where Asq is the squared magnitude response at k0, Asqdl and Asqdu are
% the desired lower and upper bounds on Asq and gradAsq is the gradient of
% the squared magnitude response at k0.
%
% It may be necessary to adjust param.eqTolerance and param.SDPsolverEpsilon
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   A1k0 - initial allpass filter multipliers for allpass filter 1
%   A1epsilon0,A1p0 - state scaling coefficients for allpass filter 1
%   A2k0 - initial allpass filter multipliers for allpass filter 2
%   A2epsilon0,A2p0 - state scaling coefficients for allpass filter 2
%   difference - take sum(false) or difference(true) of the allpass filters
%   k_u,k_l - upper and lower bounds on the allpass filter coefficients
%   k_active - indexes of elements of coefficients being optimised
%   k_delta - the truncated coefficients are k0+(k_delta.*y) 
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
% The state scaling coefficients have no effect on the response but can
% improve numerical accuracy.
%
% Outputs:
%   A1k_min,A2k_min - filter design
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

if (nargin ~= 36) || (nargout ~= 5)
  print_usage(["[A1k,A2k,socp_iter,func_iter,feasible]= ...\n", ...
               "  schurOneMPAlattice_sdp_mmse ...\n", ...
               "    (vS, ...\n", ...
               "     A1k0,A1epsilon0,A1p0, ...\n", ...
               "     A2k0,A2epsilon0,A2p0 ...\n", ...
               "     difference,k_u,k_l,k_active,k_delta, ...\n", ...
               "     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...\n", ...
               "     wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...\n", ...
               "     maxiter,ftol,ctol,verbose)"]);
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
  vS=schurOneMPAlattice_slb_set_empty_constraints();
elseif (numfields(vS) ~= 8) || ...
       (all(isfield(vS,{"al","au","tl","tu","pl","pu","dl","du"})) == false)
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
A1k0=A1k0(:);A2k0=A2k0(:);k0=[A1k0;A2k0];
k_u=k_u(:);k_l=k_l(:);
k_active=k_active(:);
k_delta=k_delta(:);
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
if length(k_delta) ~= Nk
  error("Expected length(k_delta)(%d) == Nk(%d)",length(k_delta),Nk);
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
if isempty(k_active)
  error("k_active empty");
endif
if any(k_active>Nk)
  error("k_active>Nk");
endif
if any((k0+k_delta) > k_u)
  error("any((k0+k_delta) > k_u)");
endif
if any((k0-k_delta) < k_l)
  error("any((k0-k_delta) < k_l)");
endif

%
% Initial squared response error and gradient
%
[Esq0,gradEsq0,~,hessEsq0]= ...
  schurOneMPAlatticeEsq(A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                        difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
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
%         3. k0+(k0_delta.*sign(y)) is the new filter design
%
Nk_active=length(k_active);
NN=Nk_active*(Nk_active-1)/2;
if verbose
  printf("k_active=[ ");printf("%d ",k_active);printf("]\n");
  printf("Nk_active=%d,NN=%d,NN+Nk_active=%d\n",Nk_active,NN,NN+Nk_active);
endif

% Linear constraints on reflection coefficients
%   D'*deltak+f>=0
% implementing:
%   ku-(k+deltak) >= 0
%   (k+deltak)-kl >= 0
D=[ [zeros(NN,Nk_active); -diag(k_delta(k_active))], ...
    [zeros(NN,Nk_active);  diag(k_delta(k_active))] ];
f=[ k_u(k_active)-k0(k_active); ...
    k0(k_active)-k_l(k_active) ];

% Approximate squared-amplitude linear constraints (SeDuMi format is Dx+f>=0): 
%   -Asq-gradAsq*(k0_delta.*y) + Asqdu >= 0
%    Asq+gradAsq*(k0_delta.*y) - Asqdl >= 0
if ~isempty(vS.au)
  [Asq_au,gradAsq_au]=schurOneMPAlatticeAsq(wa(vS.au),A1k0,A1epsilon0,A1p0, ...
                                            A2k0,A2epsilon0,A2p0,difference);
  func_iter = func_iter+1;
  gradAsq_au_delta=gradAsq_au.*kron(ones(length(vS.au),1),k_delta');
  D=[D,[zeros(NN,length(vS.au));-gradAsq_au_delta(:,k_active)']];
  f=[f;Asqdu(vS.au)-Asq_au];
endif
if ~isempty(vS.al) 
  [Asq_al,gradAsq_al]=schurOneMPAlatticeAsq(wa(vS.al),A1k0,A1epsilon0,A1p0, ...
                                            A2k0,A2epsilon0,A2p0,difference);
  func_iter = func_iter+1;
  gradAsq_al_delta=gradAsq_al.*kron(ones(length(vS.al),1),k_delta');
  D=[D,[zeros(NN,length(vS.al));gradAsq_al_delta(:,k_active)']];
  f=[f;Asq_al-Asqdl(vS.al)];
endif

% Approximate group-delay linear constraints 
if ~isempty(vS.tu)
  [T_tu,gradT_tu]=schurOneMPAlatticeT(wt(vS.tu),A1k0,A1epsilon0,A1p0, ...
                                      A2k0,A2epsilon0,A2p0,difference);
  func_iter = func_iter+1;
  gradT_tu_delta=gradT_tu.*kron(ones(length(vS.tu),1),k_delta');
  D=[D,[zeros(NN,length(vS.tu));-gradT_tu_delta(:,k_active)']];
  f=[f;Tdu(vS.tu)-T_tu];
endif
if ~isempty(vS.tl) 
  [T_tl,gradT_tl]=schurOneMPAlatticeT(wt(vS.tl),A1k0,A1epsilon0,A1p0, ...
                                      A2k0,A2epsilon0,A2p0,difference);
  func_iter = func_iter+1;
  gradT_tl_delta=gradT_tl.*kron(ones(length(vS.tl),1),k_delta');
  D=[D,[zeros(NN,length(vS.tl));gradT_tl_delta(:,k_active)']];
  f=[f;T_tl-Tdl(vS.tl)];
endif

% Approximate phase linear constraints 
if ~isempty(vS.pu) || ~isempty(vS.pl)
  [P,gradP]=schurOneMPAlatticeP(wp,A1k0,A1epsilon0,A1p0, ...
                                A2k0,A2epsilon0,A2p0,difference);
  func_iter = func_iter+1;
endif      
if ~isempty(vS.pu) 
  gradP_pu_delta=gradP(vS.pu).*kron(ones(length(vS.pu),1),k_delta');
  D=[D,[zeros(NN,length(vS.pu));-gradP_pu_delta(:,k_active)']];
  f=[f;                          Pdu(vS.pu)-P(vS.pu)];
endif
if ~isempty(vS.pl) 
  gradP_pl_delta=gradP(vS.pl).*kron(ones(length(vS.pl),1),k_delta');
  D=[D,[zeros(NN,length(vS.pl)); gradP_pl_delta(:,k_active)']];
  f=[f;                          P(vS.pl)-Pdl(vS.pl)];
endif

% Approximate dAsqdw linear constraints 
if ~isempty(vS.du)
  [dAsqdw_du,graddAsqdw_du]= ...
     schurOneMPAlatticedAsqdw(wd(vS.du),A1k0,A1epsilon0,A1p0, ...
                              A2k0,A2epsilon0,A2p0,difference);
  func_iter = func_iter+1;
  graddAsqdw_du_delta=graddAsqdw_du.*kron(ones(length(vS.du),1),k_delta');
  D=[D,[zeros(NN,length(vS.du));-graddAsqdw_du_delta(:,k_active)']];
  f=[f;Ddu(vS.du)-dAsqdw_du];
endif
if ~isempty(vS.dl)
  [dAsqdw_dl,graddAsqdw_dl]= ...
     schurOneMPAlatticedAsqdw(wd(vS.dl),A1k0,A1epsilon0,A1p0, ...
                              A2k0,A2epsilon0,A2p0,difference);
  func_iter = func_iter+1;
  graddAsqdw_dl_delta=graddAsqdw_dl.*kron(ones(length(vS.dl),1),k_delta');
  D=[D,[zeros(NN,length(vS.dl));-graddAsqdw_dl_delta(:,k_active)']];
  f=[f;dAsqdw_dl-Ddl(vS.dl)];
endif

% Triangle inequalities (in the SeDuMi form: Dy+f>=0)
AyyY=[];
byyY=[];
if Nk_active >= 2
  Fn=zeros(Nk_active);
  Fn(find(triu(ones(Nk_active),1)))=1:NN;
  NN2=nchoosek(Nk_active,2);
  byyY=ones(4*NN2,1);
  AyyY=zeros(NN+Nk_active,4*NN2);
  nn=-3;
  for m=1:(Nk_active-1),
    for n=(m+1):Nk_active,
      nn=nn+4;
      % y(m)+y(n)+Y(m,n) + 1 >= 0
      AyyY(NN+m,    nn  )= 1; 
      AyyY(NN+n,    nn  )= 1;
      AyyY(Fn(m,n), nn  )= 1;
      % y(m)-y(n)-Y(m,n) + 1 >= 0
      AyyY(NN+m,    nn+1)= 1; 
      AyyY(NN+n,    nn+1)=-1;
      AyyY(Fn(m,n), nn+1)=-1; 
      % -y(m)-y(n)+Y(m,n) + 1 >= 0
      AyyY(NN+m,    nn+2)=-1; 
      AyyY(NN+n,    nn+2)=-1;
      AyyY(Fn(m,n), nn+2)= 1;
      % -y(m)+y(n)-Y(m,n) + 1 >= 0
      AyyY(NN+m,    nn+3)=-1; 
      AyyY(NN+n,    nn+3)= 1;
      AyyY(Fn(m,n), nn+3)=-1;
    endfor
  endfor
endif

% Minimise the filter response MMSE error
xk0=k0(k_active);
xk_delta=k_delta(k_active);
q=gradEsq0(k_active);
Q=hessEsq0(k_active,k_active);
Fhat=find(triu(ones(Nk_active),1));
Qhat=Q.*(xk_delta*(xk_delta.'));
cc=zeros(NN+Nk_active,1); 
cc(1:NN)=Qhat(Fhat);
cc((NN+1):(NN+Nk_active))=q.*(xk_delta.');

% Positive definite constraint
F0=eye(Nk_active+1);
F=cell(NN+Nk_active,1);
[Fr,Fc]=find(triu(ones(Nk_active+1),1));
for m=1:(NN+Nk_active),
  F{m}=zeros(size(F0));
  F{m}(Fr(m),Fc(m))=1;
  F{m}(Fc(m),Fr(m))=1;
endfor
cs=vec(F0);
As=zeros(NN+Nk_active,rows(cs));
for m=1:(NN+Nk_active),
  As(m,:)=-vec(F{m});
endfor

% SeDuMi variables
use_socp_constraint_on_Esq=false;
use_linear_constraint_on_Esq=false;

if use_linear_constraint_on_Esq && use_socp_constraint_on_Esq
  % Add SOCP constraint on ||Esq||<epsilon and minimise epsilon
  Aq=[cc;0];
  bq=[zeros(NN+Nk_active,1);1];
  cq=Esq0+(trace(Qhat)/2);
  dq=0;
  % Add linear constraint estimated_Esq>0
  At=[[-[D,AyyY,cc];zeros(1,columns(D)+columns(AyyY)+1)], ...
      -[bq,Aq],[As;zeros(1,length(vec(F0)))]];
  bt=-[zeros(NN+Nk_active,1);1];
  ct=[f;byyY;(Esq0+(trace(Qhat)/2));[dq;cq];cs];
  K.l=columns(D)+columns(AyyY)+1;
  K.q=[1+columns(Aq)];
  K.s=rows(F0);
  
elseif use_socp_constraint_on_Esq
  % Add SOCP constraint on ||Esq||<epsilon and minimise epsilon
  Aq=[cc;0];
  bq=[zeros(NN+Nk_active,1);1];
  cq=Esq0+(trace(Qhat)/2);
  dq=0;
  At=[[-[D,AyyY];zeros(1,columns(D)+columns(AyyY))], ...
      -[bq,Aq],[As;zeros(1,length(vec(F0)))]];
  bt=-[zeros(NN+Nk_active,1);1];
  ct=[f;byyY;[dq;cq];cs];
  K.l=columns(D)+columns(AyyY);
  K.q=[1+columns(Aq)];
  K.s=rows(F0);
  
elseif use_linear_constraint_on_Esq
  % Add linear constraint estimated_Esq>0
  At=[-[D,AyyY,cc],As];
  bt=-cc;
  ct=[f;byyY;(Esq0+(0.5*trace(Qhat)));cs];
  K.l=columns(D)+columns(AyyY)+1;
  K.s=size(F0,1);

else
  At=[-[D,AyyY],As];
  bt=-cc;
  ct=[f;byyY;cs];
  K.l=columns(D)+columns(AyyY);
  K.s=rows(F0);
endif

% Call SeDuMi
try
  [xs,ys,info]=sedumi(At,bt,ct,K,pars);
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
  if use_socp_constraint_on_Esq
    if (length(ys) ~= (NN+Nk_active+1))
      error("length(ys) ~= (NN+Nk_active+1)");
    endif
    printf("epsilon=%g\n",ys(NN+Nk_active+1));
  endif
catch
  A1k_min=[];
  A2k_min=[];
  feasible=false;
  err=lasterror();
  for e=1:length(err.stack)
    fprintf(stderr,"Called %s at line %d\n", ...
            err.stack(e).name,err.stack(e).line);
  endfor
  error("%s\n", err.message);
end_try_catch

% Extract results
y=ys((NN+1):(NN+Nk_active));
printf("y=[ ");printf("%13.10f ",y');printf(" ]';\n"); 
k_min=k0;
k_min(k_active)=xk0+(((y>=0)-(y<0)).*xk_delta);
A1k_min=k_min(1:NA1k);
A2k_min=k_min((NA1k+1):end);
socp_iter=info.iter;
feasible=true;
if verbose
  printf("A1k_min=[ ");printf("%15.12f ",A1k_min');printf(" ]';\n"); 
  printf("A2k_min=[ ");printf("%15.12f ",A2k_min');printf(" ]';\n"); 
  Esq=schurOneMPAlatticeEsq(A1k_min,A1epsilon0,A1p0, ...
                            A2k_min,A2epsilon0,A2p0,...
                            difference, ...
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  func_iter=func_iter+1;
  printf("Esq= %g\n",Esq);
  printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
  info
endif

endfunction
