function [xk,socp_iter,func_iter,feasible]=iir_frm_parallel_allpass_socp_mmse...
  (vS,x0,xu,xl,Vr,Qr,Vs,Qs,na,nc,Mmodel, ...
   w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt,maxiter,ftol,ctol,verbose)
% [xk,socp_iter,func_iter,feasible] = iir_frm_parallel_allpass_socp_mmse ...
%   (vS,x0,xu,xl,Vr,Qr,Vs,Qs,na,nc,Mmodel, ...
%    w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt,maxiter,ftol,ctol,verbose)
%
% SOCP MMSE optimisation of a low pass FRM filter with constraints on the
% amplitude, and low pass group delay responses. The FRM model filter consists
% of parallel allpass filters and FIR masking filters. See:
%
% "Optimal Design of IIR Frequency-Response-Masking Filters Using 
% Second-Order Cone Programming", W.-S.Lu and T.Hinamoto, IEEE
% Transactions on Circuits and Systems-I:Fundamental Theory and 
% Applications, Vol.50, No.11, Nov. 2003, pp.1401--1412
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   x0 - initial coefficient vector in the form:
%         [ pRr(1:Vr);abs(pCr(1:Qron2));angle(pCr(1:Qron2)); ...
%           pRs(1:Vs);abs(pCs(1:Qson2));angle(pCs(1:Qson2)); ...
%           aak(1:na);ack(1:nc) ];
%         where pR represents real poles, pC represents conjugate pole pairs of
%         an allpass model filter and aak and ack represent the coefficients of
%         the FIR masking filters
%   xu,xl - upper and lower constraints on the coefficients (allpass poles)
%   Vr - number of real poles of R(z)
%   Qr - number of conjugate pole pairs of R(z)
%   Vs - number of real poles of S(z)
%   Qs - number of conjugate pole pairs of S(z)
%   na - length of the FIR masking filter
%   nc - length of the FIR complementary masking filter
%   Mmodel - decimation factor of the model filter
%   w - angular frequencies of amplitude and pass-band delay response
%        in [0,pi]. 
%   Asqd - desired squared amplitude response
%   Asqdu,Asqdl - upper/lower mask for the desired squared amplitude response
%   Wa - squared amplitude response weight at each frequency
%   Td - desired passband group delay response
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay response weight at each frequency
%   maxiter - maximum number of SOCP iterations
%   ftol - tolerance on function value
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   xk - filter design
%   socp_iter - number of SOCP iterations
%   func_iter - number of function calls
%   feasible - x satisfies the constraints 

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

  if (nargin ~= 24) || (nargout ~= 4)
    print_usage(["[xk,socp_iter,func_iter,feasible]= ...\n", ...
 "  iir_frm_parallel_allpass_socp_mmse(vS,x0,xu,xl,Vr,Qr,Vs,Qs,na,nc,Mmodel, ...\n", ...
 "    w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt,maxiter,ftol,ctol,verbose)"]);
  endif

  %
  % Sanity checks
  %
  w=w(:);
  Nw=length(w);
  Nwt=length(Td);
  x0=x0(:);xu=xu(:);xl=xl(:);
  Nxk=Vr+Qr+Vs+Qs+na+nc;
  if length(x0) ~= Nxk
    error("Expected length(x0)(%d) == Vr+Qr+Vs+Qs+na+nc(%d)",length(x0),Nxk);
  endif
  if length(xu) ~= Nxk
    error("Expected length(xu)(%d) == Vr+Qr+Vs+Qs+na+nc(%d)",length(xu),Nxk);
  endif
  if length(xl) ~= Nxk
    error("Expected length(xl)(%d) == Vr+Qr+Vs+Qs+na+nc(%d)",length(xl),Nxk);
  endif
  if Nw ~= length(Asqd)
    error("Expected length(w)(%d) == length(Asqd)(%d)",Nw,length(Asqd));
  endif  
  if ~isempty(Asqdu) && Nw ~= length(Asqdu)
    error("Expected length(w)(%d) == length(Asqdu)(%d)",Nw,length(Asqdu));
  endif
  if ~isempty(Asqdl) && Nw ~= length(Asqdl)
    error("Expected lenth(w)(%d) == length(Asqdl)(%d)",Nw,length(Asqdl));
  endif
  if Nw ~= length(Wa)
    error("Expected length(w)(%d) == length(Wa)(%d)",Nw,length(Wa));
  endif
  if ~isempty(Tdu) && Nwt ~= length(Tdu)
    error("Expected length(Td)(%d) == length(Tdu)(%d)",Nwt,length(Tdu));
  endif
  if ~isempty(Tdl) && Nwt ~= length(Tdl)
    error("Expected length(Td)(%d) == length(Tdl)(%d)",Nwt,length(Tdl));
  endif
  if Nwt ~= length(Wt)
    error("Expected length(Td)(%d) == length(Wt)(%d)",Nwt,length(Wt));
  endif
  if isempty(vS)
    vS=iir_frm_parallel_allpass_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 4) || ...
         (all(isfield(vS,{"al","au","tl","tu"}))==false)
    error("numfields(vS)=%d, expected 4 (al,au,tl and tu)",numfields(vS));
  endif

  % Initialise
  xk=x0(:);
  Asqk=[];Tk=[];feasible=false;
  socp_iter=0;func_iter=0;loop_iter=0;
 
  %
  % Second Order Cone Programming (SQP) loop
  %
  while 1

    loop_iter=loop_iter+1;
    if loop_iter > maxiter
      error("maxiter exceeded");
    endif

    % Find the response values and gradients
    [Asqk,Tk,gradAsqk,gradTk]= ...
      iir_frm_parallel_allpass(w,xk,Vr,Qr,Vs,Qs,na,nc,Mmodel);
    Tk=Tk(1:Nwt);
    gradTk=gradTk(1:Nwt,:);
    func_iter = func_iter+1;

    %
    % Set up the SeDuMi problem. 
    % The vector to be minimised is [epsilon;beta;x] where epsilon is 
    % the MMSE error, beta is the coefficient step size and x is the 
    % coefficient difference vector.
    %

    % Linear coefficient stability constraints on allpass pole radiuses
    % namely xk+delta < xu and xk+delta > xl. In this case
    % the constraints are expressed as (D'*delta)+f >= 0.
    % There are 2*(Vr+(Qr/2)+Vs+(Qs/2)) pole radius constraints.
    Qron2=Qr/2;
    VQron2=Vr+Qron2;
    Qson2=Qs/2;
    VQson2=Vs+Qson2;
    D=[  zeros(2,2*(VQron2+VQson2)); ...
        -eye(VQron2,VQron2), eye(VQron2,VQron2), zeros(VQron2,2*VQson2);
         zeros(Qron2,2*(VQron2+VQson2)); ...
         zeros(VQson2,2*VQron2), -eye(VQson2,VQson2), eye(VQson2,VQson2);
         zeros(Qson2+na+nc,2*(VQron2+VQson2))];
    f=[xu(1:Vr)                          - xk(1:Vr); ...
       xk(1:Vr)                          - xl(1:Vr); ...
       xu((Vr+1):(Vr+Qron2))             - xk((Vr+1):(Vr+Qron2)); ...
       xk((Vr+1):(Vr+Qron2))             - xl((Vr+1):(Vr+Qron2)); ...
       xu((Vr+Qr+1):(Vr+Qr+Vs))          - xk((Vr+Qr+1):(Vr+Qr+Vs)); ...
       xk((Vr+Qr+1):(Vr+Qr+Vs))          - xl((Vr+Qr+1):(Vr+Qr+Vs)); ...
       xu((Vr+Qr+Vs+1):(Vr+Qr+Vs+Qson2)) - xk((Vr+Qr+Vs+1):(Vr+Qr+Vs+Qson2)); ...
       xk((Vr+Qr+Vs+1):(Vr+Qr+Vs+Qson2)) - xl((Vr+Qr+Vs+1):(Vr+Qr+Vs+Qson2))];

    % Squared amplitude linear constraints
    if ~isempty(vS.au)
      D=[D, [zeros(2,length(vS.au));-gradAsqk(vS.au,:)']];
      f=[f; Asqdu(vS.au)-Asqk(vS.au)];
    endif
    if ~isempty(vS.al)
      D=[D, [zeros(2,length(vS.al));gradAsqk(vS.al,:)']];
      f=[f; Asqk(vS.al)-Asqdl(vS.al)];
    endif

    % Group-delay linear constraints
    if ~isempty(vS.tu)
      D=[D, [zeros(2,length(vS.tu));-gradTk(vS.tu,:)']];
      f=[f; Tdu(vS.tu)-Tk(vS.tu)];
    endif
    if ~isempty(vS.tl)
      D=[D, [zeros(2,length(vS.tl));gradTk(vS.tl,:)']];
      f=[f; Tk(vS.tl)-Tdl(vS.tl)];
    endif

    % SeDuMi linear constraint matrixes
    At=-D;
    ct=f;
    sedumiK.l=columns(D);
    if verbose && ~iir_frm_parallel_allpass_slb_constraints_are_empty(vS)
      iir_frm_parallel_allpass_slb_show_constraints(vS,w,Asqk,Tk);
    endif
           
    % SeDuMi quadratic constraint matrixes

    % Step size constraints
    At_step=[[0;1;zeros(Nxk,1)], [zeros(2,Nxk);eye(Nxk,Nxk)]];
    At=[At, -At_step];
    ct=[ct;0;zeros(Nxk,1)];
    sedumiK.q=Nxk+1;

    % MMSE frequency response constraints
    b=[1;0;zeros(Nxk,1)];
    d=0;
    if isempty(Td)
      At1=[zeros(Nw,2), gradAsqk.*kron(ones(1,Nxk),Wa)]';
      c=Wa.*(Asqk-Asqd);
    else
      At1=[zeros(Nw+Nwt,2), ...
           [gradAsqk.*kron(ones(1,Nxk),Wa); ...
            gradTk.*kron(ones(1,Nxk),Wt)]]';
      c=[Wa.*(Asqk-Asqd);Wt.*(Tk-Td);];
    endif
    At=[At, -b, -At1];
    ct=[ct;d;c];
    sedumiK.q=[sedumiK.q, size(At1,2)+1];

    % Call SeDuMi
    bt=-[1;1;zeros(Nxk,1)];
    try
      pars.fid=0; % Suppress SeDuMi status output
      [xs,ys,info]=sedumi(At,bt,ct,sedumiK,pars);
      if verbose
        info
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
      xk=[];
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
    xk=xk+delta;
    socp_iter=socp_iter+info.iter;
    if verbose
      printf("epsilon=%g\n",epsilon);
      printf("beta=%g\n",beta);
      printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
      printf("norm(delta)=%g\n",norm(delta));
      printf("xk=[ ");printf("%g ",xk');printf(" ]';\n"); 
      printf("norm(delta)/norm(xk)=%g\n",norm(delta)/norm(xk));
      printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
      info
    endif
    if norm(delta)/norm(xk) < ftol
      printf("norm(delta)/norm(xk) < ftol\n");
      feasible=true;
      break;
    endif
  endwhile

endfunction
