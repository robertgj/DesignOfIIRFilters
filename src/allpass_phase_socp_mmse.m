function [ak,socp_iter,func_iter,feasible]= ...
         allpass_phase_socp_mmse(vS,a0,au,al,Va,Qa,Ra, ...
                                 wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose)
% [ak,socp_iter,func_iter,feasible] = ...
%   allpass_phase_socp_mmse(vS,a0,au,al,Va,Qa,Ra, ...
%                           wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose)
%
% SOCP MMSE optimisation of an all-pass phase equaliser with frequency
% constraints on the phase response.
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu,pl,pu}
%   a0 - initial all-pass filter coefficient vector in the form:
%         [ Rpa(1:Va) rpa(1:(Qa/2)) thetapa(1:(Qa/2))]
%         where Rpa are the radiuses of the real poles of the filter and
%         {rpa,thetapa} the polar coordinates of a pair of complex
%         conjugate poles of the filter.
%   au - upper constraints on the pole radiuses of the all-pass filter
%   al - lower constraints on the pole radiuses of the all-pass filter
%   Va - number of real poles of the allpass filter 
%   Qa - number of complex poles of the allpass filter
%   Ra - decimation factor. The poles, pk, are roots of [z^Ra-pk].
%   wp - angular frequencies of desired phase response
%   Pd - desired phase response
%   Pdu,Pdl - upper and lower mask for the phase response
%   Wp - phase response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   ftol - tolerance on the relative step size to accept the result
%   ctol - tolerance on the constraints
%   verbose -
%
% Outputs:
%   ak - all-pass equaliser design
%   socp_iter - number of SOCP iterations
%   func_iter - number of function calls
%   feasible - ak satisfies the constraints 
%

% Copyright (C) 2018-2025 Robert G. Jenssen
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
if (nargout > 4) || (nargin ~= 16)
  print_usage("[ak,socp_iter,func_iter,feasible]= ...\n\
  allpass_phase_socp_mmse(vS,a0,au,al,Va,Qa,Ra, ...\n\
                          wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose)");
endif
wp=wp(:);
Nwp=length(wp);
if isempty(wp)
  error("isempty(wp)");
endif
Na=Va+Qa;

if isempty(vS)
  vS.pl=[];vS.pu=[];
elseif (numfields(vS) ~= 2) ||  ...
       (all(isfield(vS,{"pl","pu"}))==false)
  error("numfields(vS)=%d, expected 2 (pl and pu)",numfields(vS));
endif

if length(a0) ~= Na
  error("Expected length(a0)(%d) == Va(%d)+Qa(%d)",length(a0),Va,Qa);
endif
if length(au) ~= Na
  error("Expected length(abu)(%d) == length(a0)(%d)",length(au),Na);
endif
if length(al) ~= Na
  error("Expected length(al(%d) == length(a0)(%d)",length(al),Na);
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

% Initialise
ak=a0(:);
au=au(:);
al=al(:);
onesa=ones(1,Na);
feasible=false;
socp_iter=0;func_iter=0;loop_iter=0;
pars.fid=0;

%
% Second Order Cone Programming (SOCP) loop
%
while 1

  loop_iter=loop_iter+1;
  if loop_iter > maxiter
    error("maxiter exceeded");
  endif

  % All-pass filter phase response
  [Pawp,gradPawp]=allpassP(wp,ak,Va,Qa,Ra);
  func_iter = func_iter+1;
  
  %
  % Set up the SeDuMi problem.
  % The vector to be minimised is [epsilon;beta;da] where epsilon is 
  % the sqared error, beta is the coefficient step size and da is the 
  % coefficient difference vector, a-ak.
  %
  
  % Linear coefficient stability constraints on pole radiuses
  Qaon2=Qa/2;
  D=[zeros(2,2*(Va+Qaon2)); ...
     -eye(Va,Va), eye(Va,Va), zeros(Va,2*Qaon2); ...
     zeros(Qaon2,2*Va), -eye(Qaon2,Qaon2), eye(Qaon2,Qaon2); ...
     zeros(Qaon2,2*(Va+Qaon2))];
  f=[au(1:Va)              - ak(1:Va); ...
     ak(1:Va)              - al(1:Va); ...
     au((Va+1):(Va+Qaon2)) - ak((Va+1):(Va+Qaon2)); ...
     ak((Va+1):(Va+Qaon2)) - al((Va+1):(Va+Qaon2))];

  % Add linear constraints on the phase response
  if ~isempty(vS.pu)
    D=[D, [zeros(2,length(vS.pu));-gradPawp(vS.pu,:)']];
    f=[f; Pdu(vS.pu)-Pawp(vS.pu)];
  endif
  if ~isempty(vS.pl)
    D=[D, [zeros(2,length(vS.pl)); gradPawp(vS.pl,:)']];
    f=[f; Pawp(vS.pl)-Pdl(vS.pl)];
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
  At_err=[zeros(Nwp,2), gradPawp.*kron(ones(1,Na),Wp) ]';
  c=Wp.*(Pawp-Pd);
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
    printf("loop_iter=%d,func_iter=%d, socp_iter=%d\n", ...
           loop_iter,func_iter,socp_iter);
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
  if norm(delta)/norm(ak) < ftol
    printf("norm(delta)/norm(ak) < ftol\nSolution is feasible!\n");
    feasible=true;
    break;
  endif
endwhile

endfunction
