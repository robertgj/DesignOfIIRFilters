function [ak,socp_iter,func_iter,feasible]= ...
  parallel_allpass_delay_socp_mmse(vS,a0,au,al,dmax,V,Q,R,DD, ...
                                   wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                   maxiter,tol,ctol,verbose)
% [ak,socp_iter,func_iter,feasible] = ...
%   parallel_allpass_delay_socp_mmse(vS,a0,au,al,dmax,V,Q,R,DD, ...
%                                    wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                                    maxiter,tol,ctol,verbose)
%
% SOCP MMSE optimisation with multiple frequency constraints
% on the amplitude and group delay responses of a filter consisting of the
% parallel combination of an allpass filter and a pure delay. The allpass
% filter is defined by the real and complex conjugate pole locations.
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   ab0 - initial coefficient vector in the form:
%         [ Rp(1:V) rp(1:(Q/2)) thetap(1:(Q/2)) ]
%         where Rp are the radiuses of the real poles of the allpass
%         filter and {rp,thetap} the polar coordinates of a pair
%         of complex conjugate poles of the allpass filter.
%   au - upper constraints on the pole radiuses of the allpass filter
%   al - lower constraints on the pole radiuses of the allpass filter
%   dmax - maximum coefficient step size (unused)
%   V - number of real poles of the allpass filter 
%   Q - number of complex poles of the allpass filter
%   R - decimation factor. The poles, pk, are roots of [z^R-pk].
%   DD - samples of delay in the delay branch
%   wa - angular frequencies of desired pass-band squared amplitude response
%        in [0,pi]. 
%   Asqd - desired pass-band squared amplitude response
%   Asqdu,Asqdl - upper and lower mask for the desired pass-band squared
%               amplitude response
%   Wa - pass-band squared amplitude response weight at each frequency
%   wt - angular frequencies of desired pass-band group delay response
%        in [0,pi]. 
%   Td - desired pass-band group delay response
%   Tdu,Tdl - upper and lower mask for the pass-band group delay response
%   Wt - pass-band group delay response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   tol - tolerance on coefficient update
%   ctol - tolerance on constraints (unused)
%   verbose -
%
% Outputs:
%   ak - filter design 
%   socp_iter - number of SOCP iterations
%   func_iter - number of function calls
%   feasible - abk satisfies the constraints 

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

%
% Sanity checks
%
if nargin ~= 23
  print_usage("[ak,socp_iter,func_iter,feasible]= ...\n\
    parallel_allpass_delay_socp_mmse(vS,a0,au,al,dmax,V,Q,R,DD, ...\n\
                                     wa,Asqd,Asqdu,Asqdl,Wa, ...\n\
                                     wt,Td,Tdu,Tdl,Wt, ...\n\
                                     maxiter,tol,ctol,verbose)");
endif
wa=wa(:);
Nwa=length(wa);
wt=wt(:);
Nwt=length(wt);
Na=V+Q;

if isempty(vS)
  vS=parallel_allpass_delay_slb_set_empty_constraints();
elseif (numfields(vS) ~= 4) || (all(isfield(vS,{"al","au","tl","tu"}))==false)
  error("numfields(vS)=%d, expected 4 (al,au,tl and tu)",numfields(vS));
endif

if length(a0) ~= Na
  error("Expected length(a0)(%d) == V(%d)+Q(%d)",length(a0),V,Q);
endif
if length(au) ~= Na
  error("Expected length(au)(%d) == length(a0)(%d)",length(au),Na);
endif
if length(al) ~= Na
  error("Expected length(al(%d) == length(a0)(%d)",length(al),Na);
endif
if Nwa ~= length(Asqd)
  error("Expected length(wa)(%d) == length(Asqd)(%d)",Nwa,length(Asqd));
endif  
if (~isempty(vS.au)) && (Nwa ~= length(Asqdu))
  error("Expected length(wa)(%d) == length(Asqdu)(%d)",Nwa,length(Asqdu));
endif  
if (~isempty(vS.al)) && (Nwa ~= length(Asqdl))
  error("Expected length(wa)(%d) == length(Asqdl)(%d)",Nwa,length(Asqdl));
endif  
if Nwa ~= length(Wa)
  error("Expected length(wa)(%d) == length(Wa)(%d)",Nwa,length(Wa));
endif
if Nwt ~= length(Td)
  error("Expected length(wt)(%d) == length(Td)(%d)",Nwt,length(Td));
endif  
if (~isempty(vS.tu)) && (Nwt ~= length(Tdu))
  error("Expected length(wt)(%d) == length(Tdu)(%d)",Nwt,length(Tdu));
endif  
if (~isempty(vS.tl)) && (Nwt ~= length(Tdl))
  error("Expected length(wt)(%d) == length(Tdl)(%d)",Nwt,length(Tdl));
endif  
if Nwt ~= length(Wt)
  error("Expected length(wt)(%d) == length(Wt)(%d)",Nwa,length(Wt));
endif

% Initialise
ak=a0(:);
au=au(:);
al=al(:);
onesa=ones(1,Na);
feasible=false;
socp_iter=0;func_iter=0;loop_iter=0;
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

  % Parallel allpass filter amplitude pass-band squared-magnitude response
  if ~isempty(wa)
    [Asqwa,gradAsqwa]=parallel_allpass_delayAsq(wa,ak,V,Q,R,DD);
    func_iter = func_iter+1;
  else
    Asqwa=[];
    gradAsqwa=[];
  endif;
  
  % Parallel allpass filter phase pass-band phase response
  if ~isempty(wt)
    [Twt,gradTwt]=parallel_allpass_delayT(wt,ak,V,Q,R,DD);
    func_iter = func_iter+1;
  else
    Twt=[];
    gradTwt=[];
  endif;
  
  %
  % Set up the SeDuMi problem.
  % The vector to be minimised is [epsilon;beta;dab] where epsilon is 
  % the sqared error, beta is the coefficient step size and dab is the 
  % coefficient difference vector, ab-abk.
  %
  
  % Linear coefficient stability constraints on pole radiuses
  Qon2=Q/2;
  D=[zeros(2,2*(V+Qon2)); ...
     -eye(V,V), eye(V,V), zeros(V,Q); ...
     zeros(Qon2,2*V), -eye(Qon2,Qon2), eye(Qon2,Qon2); ...
     zeros(Qon2,2*(V+Qon2))];
  f=[au(1:V)            - ak(1:V); ...
     ak(1:V)            - al(1:V); ...
     au((V+1):(V+Qon2)) - ak((V+1):(V+Qon2)); ...
     ak((V+1):(V+Qon2)) - al((V+1):(V+Qon2))];

  % Add linear constraints on the response
  % Squared amplitude linear constraints
  if ~isempty(vS.au)
    D=[D, [zeros(2,length(vS.au));-gradAsqwa(vS.au,:)']];
    f=[f; Asqdu(vS.au)-Asqwa(vS.au)];
  endif
  if ~isempty(vS.al)
    D=[D, [zeros(2,length(vS.al));gradAsqwa(vS.al,:)']];
    f=[f; Asqwa(vS.al)-Asqdl(vS.al)];
  endif
  % Group-delay linear constraints
  if ~isempty(vS.tu)
    D=[D, [zeros(2,length(vS.tu));-gradTwt(vS.tu,:)']];
    f=[f; Tdu(vS.tu)-Twt(vS.tu)];
  endif
  if ~isempty(vS.tl)
    D=[D, [zeros(2,length(vS.tl));gradTwt(vS.tl,:)']];
    f=[f; Twt(vS.tl)-Tdl(vS.tl)];
  endif
    
  % SeDuMi linear constraint matrixes
  At=-D;
  ct=f;
  sedumiK.l=columns(D);
  if verbose
    printf("Added %d linear constraints\n",sedumiK.l);
  endif

  % SeDuMi quadratic constraint matrixes

  % Step size constraints
  bt_step=[0;1;zeros(Na,1)];
  At_step=[zeros(2,Na);eye(Na,Na)];
  At=[At, -[bt_step, At_step]];
  ct=[ct;0;zeros(Na,1)];
  sedumiK.q=Na+1;

  % Sum error over frequency
  b_err=[1;0;zeros(Na,1)];
  At_err=[zeros(Nwa+Nwt,2), [gradAsqwa.*kron(ones(1,Na),Wa); ...
                             gradTwt.*kron(ones(1,Na),Wt)] ]';
  c=[Wa.*(Asqwa-Asqd);Wt.*(Twt-Td)];
  d=0;
  At=[At, -b_err, -At_err];
  ct=[ct;d;c];
  sedumiK.q=[sedumiK.q, (columns(At_err)+1)];

  % Call SeDuMi
  bt=-[1;1;zeros(Na,1)];
  [xs,ys,info]=sedumi(At,bt,ct,sedumiK,pars);

  % Extract results
  epsilon=ys(1);
  beta=ys(2);
  delta=ys(3:end);
  delta=delta(:);
  socp_iter=socp_iter+info.iter;
  ak=ak+delta;                
  
  % Report
  if verbose
   printf("ak=[ ");printf("%g ",ak');printf(" ]';\n");
    printf("epsilon=%g\n",epsilon);
    printf("beta=%g\n",beta);
    printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
    printf("norm(delta)=%g\n",norm(delta)); 
    printf("loop_iter=%d,func_iter=%d, socp_iter=%d\n",
           loop_iter,func_iter,socp_iter);
    info
  endif
  if info.numerr == 1
    error("SeDuMi premature termination"); 
  elseif info.numerr == 2 
    error("SeDuMi numerical failure"); 
  elseif info.pinf 
    error("SeDuMi primary problem infeasible"); 
  elseif info.dinf
    error("SeDuMi dual problem infeasible"); 
  endif 
  if norm(delta)/norm(ak) < tol
    printf("norm(delta)/norm(ak) < tol\nSolution is feasible!\n");
    feasible=true;
    break;
  endif
endwhile

endfunction
