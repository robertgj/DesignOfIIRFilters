function [abk,socp_iter,func_iter,feasible]= ...
         parallel_allpass_socp_mmse(vS,ab0,abu,abl,K,Va,Qa,Ra,Vb,Qb,Rb, ...
                                    polyphase,difference, ...
                                    wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                    wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose)
% [xk,socp_iter,func_iter,feasible] = ...
%   parallel_allpass_socp_mmse(vS,ab0,abu,abl,K,Va,Qa,Ra,Vb,Qb,Rb, ...
%                              polyphase,difference, ...
%                              wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                              wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose)
%
% SOCP MMSE optimisation with multiple frequency constraints
% on the amplitude, phase and group delay responses of a filter consisting
% of the parallel combination of two allpass filters. The allpass filters are
% defined by the real and complex conjugate pole locations.
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu,pl,pu}
%   ab0 - initial coefficient vector in the form:
%         [ RpA(1:Va) rpA(1:(Qa/2)) thetapA(1:(Qa/2)) ...
%           RpB(1:Vb) rpB(1:(Qb/2)) thetapB(1:(Qb/2))]
%         where RpA are the radiuses of the real poles of the A
%         filter and {rpA,thetapA} the polar coordinates of a pair
%         of complex conjugate poles of the A filter. Similarly for
%         the B filter.
%   abu - upper constraints on the pole radiuses of the A and B allpass filters
%   abl - lower constraints on the pole radiuses of the A and B allpass filters
%   K - scale factor
%   Va - number of real poles of the A allpass filter 
%   Qa - number of complex poles of the A allpass filter
%   Ra - decimation factor. The poles, pk, are roots of [z^Ra-pk].
%   Vb - number of real poles of the B allpass filter 
%   Qb - number of complex poles of the B allpass filter
%   Rb - decimation factor
%   polyphase -  Use a polyphase structure:
%                  A(z) = A1(z^R)+(z^-1)*Asq(z^R)+..+(z^-(R-1))*AR(z^R)
%                At present only Ra==Rb==2 is supported.
%  difference - return the response for the difference of the all-pass filters
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
%   wp - angular frequencies of desired pass-band phase response in [0,pi]. 
%   Pd - desired pass-band group delay response
%   Pdu,Pdl - upper and lower mask for the pass-band phase response
%   Wp - pass-band phase response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   ftol - tolerance on the relative step size to accept the result
%   ctol - tolerance on constraints
%   verbose -
%
% Outputs:
%   abk - filter design 
%   socp_iter - number of SOCP iterations
%   func_iter - number of function calls
%   feasible - abk satisfies the constraints 
%
% If ftol is a structure then the ftol.dtol field is the minimum relative
% step size and the ftol.stol field sets the SeDuMi pars.eps field (the
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

%
% Sanity checks
%
if (nargout > 4) || (nargin ~= 32)
  print_usage(["[abk,socp_iter,func_iter,feasible]= ...\n", ...
 "  parallel_allpass_socp_mmse(vS,ab0,abu,abl,K,Va,Qa,Ra,Vb,Qb,Rb, ...\n", ...
 "                             polyphase,difference, ...\n", ...
 "                             wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...\n", ...
 "                             wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose)"]);
endif
wa=wa(:);
Nwa=length(wa);
wt=wt(:);
Nwt=length(wt);
wp=wp(:);
Nwp=length(wp);
Nab=Va+Qa+Vb+Qb;

if isempty(vS)
  vS.al=[];vS.au=[];vS.tl=[];vS.tu=[];vS.pl=[];vS.pu=[];
elseif (numfields(vS) ~= 6) ||  ...
       (all(isfield(vS,{"al","au","tl","tu","pl","pu"}))==false)
  error("numfields(vS)=%d, expected 6 (al,au,tl,tu,pl and pu)",numfields(vS));
endif

if length(ab0) ~= Nab
  error("Expected length(ab0)(%d) == Va(%d)+Qa(%d)+Vb(%d)+Qb(%d)", ...
        length(ab0),Va,Qa,Vb,Qb);
endif
if length(abu) ~= Nab
  error("Expected length(abu)(%d) == length(ab0)(%d)",length(abu),Nab);
endif
if length(abl) ~= Nab
  error("Expected length(abl(%d) == length(ab0)(%d)",length(abl),Nab);
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
  error("Expected length(wt)(%d) == length(Wt)(%d)",Nwt,length(Wt));
endif
if Nwp ~= length(Pd)
  error("Expected length(wp)(%d) == length(Pd)(%d)",Nwp,length(Pd));
endif  
if (~isempty(vS.pu)) && (Nwp ~= length(Pdu))
  error("Expected length(wp)(%d) == length(Pdu)(%d)",Nwp,length(Pdu));
endif  
if (~isempty(vS.pl)) && (Nwp ~= length(Pdl))
  error("Expected length(wp)(%d) == length(Pdl)(%d)",Nwp,length(Pdl));
endif  
if Nwp ~= length(Wp)
  error("Expected length(wp)(%d) == length(Wp)(%d)",Nwp,length(Wp));
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

% Initialise
abk=ab0(:);
abu=abu(:);
abl=abl(:);
onesab=ones(1,Nab);
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

  % Parallel allpass filter pass-band squared-magnitude response
  if ~isempty(wa)
    [Asqwa,gradAsqwa]=parallel_allpassAsq(wa,abk,K,Va,Qa,Ra,Vb,Qb,Rb, ...
                                          polyphase,difference);
    func_iter = func_iter+1;
  else
    Asqwa=[];
    gradAsqwa=[];
  endif;
  
  % Parallel allpass filter pass-band group-delay response
  if ~isempty(wt)
    [Twt,gradTwt]=parallel_allpassT(wt,abk,Va,Qa,Ra,Vb,Qb,Rb, ...
                                    polyphase,difference);
    func_iter = func_iter+1;
  else
    Twt=[];
    gradTwt=[];
  endif;
  
  % Parallel allpass filter pass-band phase response
  if ~isempty(wp)
    [Pwp,gradPwp]=parallel_allpassP(wp,abk,Va,Qa,Ra,Vb,Qb,Rb, ...
                                    polyphase,difference);
    func_iter = func_iter+1;
  else
    Pwp=[];
    gradPwp=[];
  endif;
  
  %
  % Set up the SeDuMi problem.
  % The vector to be minimised is [epsilon;beta;dab] where epsilon is 
  % the sqared error, beta is the coefficient step size and dab is the 
  % coefficient difference vector, ab-abk.
  %
  
  % Linear coefficient stability constraints on pole radiuses
  Qaon2=Qa/2;
  Qbon2=Qb/2;
  D=[zeros(2,2*(Va+Qaon2+Vb+Qbon2)); ...
     -eye(Va,Va), eye(Va,Va), zeros(Va,2*(Qaon2+Vb+Qbon2)); ...
     zeros(Qaon2,2*Va), -eye(Qaon2,Qaon2), eye(Qaon2,Qaon2), ...
                                           zeros(Qaon2,2*(Vb+Qbon2)); ...
     zeros(Qaon2,2*(Va+Qaon2+Vb+Qbon2)); ...
     zeros(Vb,2*(Va+Qaon2)), -eye(Vb,Vb), eye(Vb,Vb), zeros(Vb,2*Qbon2); ...
     zeros(Qbon2,2*(Va+Qaon2+Vb)), -eye(Qbon2,Qbon2), eye(Qbon2,Qbon2); ... 
     zeros(Qbon2,2*(Va+Qaon2+Vb+Qbon2))];
  f=[abu(1:Va)                          - abk(1:Va); ...
     abk(1:Va)                          - abl(1:Va); ...
     abu((Va+1):(Va+Qaon2))             - abk((Va+1):(Va+Qaon2)); ...
     abk((Va+1):(Va+Qaon2))             - abl((Va+1):(Va+Qaon2)); ...
     abu((Va+Qa+1):(Va+Qa+Vb))          - abk((Va+Qa+1):(Va+Qa+Vb)); ...
     abk((Va+Qa+1):(Va+Qa+Vb))          - abl((Va+Qa+1):(Va+Qa+Vb)); ...
     abu((Va+Qa+Vb+1):(Va+Qa+Vb+Qbon2)) - abk((Va+Qa+Vb+1):(Va+Qa+Vb+Qbon2)); ...
     abk((Va+Qa+Vb+1):(Va+Qa+Vb+Qbon2)) - abl((Va+Qa+Vb+1):(Va+Qa+Vb+Qbon2))];

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
    
  % Phase linear constraints
  if ~isempty(vS.pu)
    D=[D, [zeros(2,length(vS.pu));-gradPwp(vS.pu,:)']];
    f=[f; Pdu(vS.pu)-Pwp(vS.pu)];
  endif
  if ~isempty(vS.pl)
    D=[D, [zeros(2,length(vS.pl));gradPwp(vS.pl,:)']];
    f=[f; Pwp(vS.pl)-Pdl(vS.pl)];
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
  bt_step=[0;1;zeros(Nab,1)];
  At_step=[zeros(2,Nab);eye(Nab,Nab)];
  At=[At, -[bt_step, At_step]];
  ct=[ct;0;zeros(Nab,1)];
  sedumiK.q=Nab+1;

  % Sum error over frequency
  b_err=[1;0;zeros(Nab,1)];
  At_err=[zeros(Nwa+Nwt+Nwp,2), [gradAsqwa.*kron(ones(1,Nab),Wa); ...
                                 gradTwt.*kron(ones(1,Nab),Wt); ...
                                 gradPwp.*kron(ones(1,Nab),Wp)] ]';
  c=[Wa.*(Asqwa-Asqd);Wt.*(Twt-Td);Wp.*(Pwp-Pd)];
  d=0;
  At=[At, -b_err, -At_err];
  ct=[ct;d;c];
  sedumiK.q=[sedumiK.q, (columns(At_err)+1)];

  % Call SeDuMi
  bt=-[1;1;zeros(Nab,1)];
  [xs,ys,info]=sedumi(At,bt,ct,sedumiK,pars);

  % Extract results
  epsilon=ys(1);
  beta=ys(2);
  delta=ys(3:end);
  delta=delta(:);
  socp_iter=socp_iter+info.iter;
  abk=abk+delta;                
  
  % Report
  if verbose
   printf("abk=[ ");printf("%g ",abk');printf(" ]';\n");
    printf("epsilon=%g\n",epsilon);
    printf("beta=%g\n",beta);
    printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
    printf("norm(delta)=%g\n",norm(delta)); 
    printf("loop_iter=%d,func_iter=%d, socp_iter=%d\n", ...
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
  if norm(delta)/norm(abk) < dtol
    printf("norm(delta)/norm(abk) < dtol\nSolution is feasible!\n");
    feasible=true;
    break;
  endif
endwhile

endfunction
