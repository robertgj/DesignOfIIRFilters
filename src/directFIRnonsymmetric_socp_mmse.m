function [h,socp_iter,func_iter,feasible]=directFIRnonsymmetric_socp_mmse ...
  (vS,h0,h_active,wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
   maxiter,ftol,ctol,verbose)
% [h,socp_iter,func_iter,feasible]=directFIRnonsymmetric_socp_mmse ...
%   (vS,h0,h_active,wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,...
%    maxiter,ftol,ctol,verbose)
%
% SOCP MMSE optimisation of a nonsymmetric FIR filter with
% constraints on the squared amplitude, and low pass group delay responses. 
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   h0 - initial nonsymmetric FIR filter coefficients
%   h_active - indexes of coefficients being optimised
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
%   ftol - tolerance on function value
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   h - filter design
%   socp_iter - number of SOCP iterations
%   func_iter - number of function calls
%   feasible - design satisfies the constraints
%
% If ftol is a structure then the ftol.dtol field is the minimum relative
% step size and the ftol.stol field sets the SeDuMi pars.eps field (the
% default is 1e-8). This is a hack to deal with filters for which the
% desired stop-band attenuation of the squared amplitude response is more
% than 80dB.

% Copyright (C) 2024-2025 Robert G. Jenssen
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

  if (nargin ~= 22) || (nargout ~= 4)
    print_usage ...
      (["[h,socp_iter,func_iter,feasible]=directFIRnonsymmetric_socp_mmse ...\n", ...
 "(vS,h0,h_active,wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,...\n", ...
 " maxiter,ftol,ctol,verbose)"]);
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
    vS=directFIRnonsymmetric_slb_set_empty_constraints();
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
  % Sanity checks on coefficient vector
  %
  h0=h0(:);
  if isempty(h0)
    error("h0 is empty");
  endif
  if isempty(h_active)
    h=h0;
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
  N=length(h0)-1;
  Nh_active=length(h_active);
  h=h0;
  % Initial squared response error
  [Esq,gradEsq]=directFIRnonsymmetricEsq(h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
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
    % The vector to be minimised is [epsilon;beta;deltah] where epsilon is 
    % the MMSE error, beta is the coefficient step size and deltah is the 
    % coefficient difference vector.
    %
    bt=-[1;1;zeros(Nh_active,1)];
    D=[];
    f=[];

    % Squared amplitude linear constraints
    if ~isempty(vS.au)
      [Asq_au,gradAsq_au] = directFIRnonsymmetricAsq(wa(vS.au),h);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.au));-gradAsq_au(:,h_active)']];
      f=[f; Asqdu(vS.au)-Asq_au];
    endif
    if ~isempty(vS.al)
      [Asq_al,gradAsq_al] = directFIRnonsymmetricAsq(wa(vS.al),h);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.al));gradAsq_al(:,h_active)']];
      f=[f; Asq_al-Asqdl(vS.al)];
    endif

    % Group delay linear constraints
    if ~isempty(vS.tu)
      [T_tu,gradT_tu] = directFIRnonsymmetricT(wt(vS.tu),h);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tu));-gradT_tu(:,h_active)']];
      f=[f; Tdu(vS.tu)-T_tu];
    endif
    if ~isempty(vS.tl)
      [T_tl,gradT_tl] = directFIRnonsymmetricT(wt(vS.tl),h);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tl));gradT_tl(:,h_active)']];
      f=[f; T_tl-Tdl(vS.tl)];
    endif

    % Phase linear constraints
    if ~isempty(vS.pu) || ~isempty(vS.pl)
      [P,gradP] = directFIRnonsymmetricP(wp,h);
      func_iter = func_iter+1;
    endif      
    if ~isempty(vS.pu)
      D=[D, [zeros(2,length(vS.pu));-gradP(vS.pu,h_active)']];
      f=[f; Pdu(vS.pu)-P(vS.pu)];
    endif
    if ~isempty(vS.pl)
      D=[D, [zeros(2,length(vS.pl));gradP(vS.pl,h_active)']];
      f=[f; P(vS.pl)-Pdl(vS.pl)];
    endif

    % SeDuMi linear constraint matrixes
    At=-D;
    ct=f;
    sedumiK.l=columns(D);
           
    % SeDuMi quadratic constraint matrixes

    % Step size constraints
    At1=[zeros(2,Nh_active);eye(Nh_active)];
    b1=[0;1;zeros(Nh_active,1)];
    c1=zeros(Nh_active,1);
    d1=0;
    At=[At, -[b1, At1]];
    ct=[ct;d1;c1];
    sedumiK.q=size(At1,2)+1;

    % MMSE frequency response constraints
    At2=[zeros(2,1);gradEsq(h_active)'];
    b2=[1;0;zeros(Nh_active,1)];
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
    h(h_active)=h(h_active)+delta;
    [Esq,gradEsq] = directFIRnonsymmetricEsq(h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    func_iter=func_iter+1;
    socp_iter=socp_iter+info.iter;
    if verbose
      printf("epsilon=%g\n",epsilon);
      printf("beta=%g\n",beta);
      printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
      printf("norm(delta)=%g\n",norm(delta));
      printf("norm(delta)/norm(h(h_active))=%g\n",norm(delta)/norm(h(h_active)));
      printf("h=[ ");printf("%g ",h);printf(" ]';\n"); 
      printf("Esq= %g\n",Esq);
      printf("gradEsq=[");printf("%g ",gradEsq);printf("]\n");
      printf("norm(gradEsq)=%g\n",norm(gradEsq));
      printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
      info
    endif
    if norm(delta)/norm(h(h_active)) < dtol
      printf("norm(delta)/norm(h(h_active)) < dtol\n");
      feasible=true;
      break;
    endif

  endwhile

endfunction
