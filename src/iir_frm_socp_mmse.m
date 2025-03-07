function [xk,socp_iter,func_iter,feasible]= ...
         iir_frm_socp_mmse(vS,x0,xu,xl,U,V,M,Q,na,nc,Mmodel,Dmodel, ...
                           w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt, ...
                           maxiter,ftol,ctol,verbose)
% [xk,socp_iter,func_iter,feasible] =
%   iir_frm_socp_mmse(vS,x0,xu,xl,U,V,M,Q,na,nc,Mmodel,Dmodel, ...
%     w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt,maxiter,ftol,ctol,verbose)
%
% SOCP MMSE optimisation of a low pass FRM filter with constraints on the
% amplitude, and low pass group delay responses. The FRM model filter consists
% of an IIR filter in parallel with a delay. The FRM masking filters are
% linear phase (ie: symmetric).
%
% SeDuMi pars.eps=1e-6 instead of the default 1e-8 to avoid numerical problems
% with iir_frm_socp_slb_test.m
%
% See:
%
% "Optimal Design of IIR Frequency-Response-Masking Filters Using 
% Second-Order Cone Programming", W.-S.Lu and T.Hinamoto, IEEE
% Transactions on Circuits and Systems-I:Fundamental Theory and 
% Applications, Vol.50, No.11, Nov. 2003, pp.1401--1412
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   x0 - initial coefficient vector in the form:
%         [ pR(1:Vr);abs(p(1:Qron2));angle(p(1:Qron2));aak(1:una);aac(1:unc) ];
%         where pR represents real poles, p represents conjugate pole pairs of
%         an allpass model filter and aak and ack represent the coefficients of
%         linear phase odd length FIR masking filters with lengths na=(2*una)-1
%         and nc=(2*unc)-1 respectively
%   xu,xl - upper and lower constraints on the coefficients of the IIR filter
%   U - number of real zeros
%   V - number of real poles
%   M - number of conjugate zero pairs
%   Q - number of conjugate pole pairs
%   na - length of the FIR masking filter
%   nc - length of the FIR complementary masking filter
%   Mmodel - decimation factor of the IIR branch of the model filter
%   Dmodel - delay of the pure delay branch of the model filter
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

  if (nargin ~= 25) || (nargout ~= 4)
    print_usage("[xk,socp_iter,func_iter,feasible]= ...\n\
    iir_frm_socp_mmse(vS,x0,xu,xl,U,V,M,Q,na,nc,Mmodel,Dmodel, ...\n\
      w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt,maxiter,ftol,ctol,verbose)");
  endif

  %
  % Sanity checks
  %
  Nxk=length(x0);
  Niir=1+U+V+M+Q;
  na_is_odd=(mod(na,2)==1);
  nc_is_odd=(mod(nc,2)==1);
  if na_is_odd ~= nc_is_odd
    error("Expected na_is_odd == nc_is_odd");
  endif
  if na_is_odd
    una=(na+1)/2;
  else
    una=na/2;
  endif 
  if nc_is_odd
    unc=(nc+1)/2;
  else
    unc=nc/2;
  endif 
  Nfir=una+unc;
  if (Niir+Nfir ~= Nxk)
    error("Expected Niir+Nfir == Nxk");
  endif
  Nw=length(w);
  Nwt=length(Td);
  x0=x0(:);xu=xu(:);xl=xl(:);
  w=w(:);
  if length(x0) ~= Nxk
    error("Expected length(x0)(%d) == Vr+Qr+una+unc(%d)",length(x0),Nxk);
  endif
  if length(xu) ~= Niir
    error("Expected length(xu)(%d) == 1+U+V+M+Q(%d)",length(xu),Niir);
  endif
  if length(xl) ~= Niir
    error("Expected length(xl)(%d) == 1+U+V+M+Q(%d)",length(xl),Niir);
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
    vS=iir_frm_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 4) || (all(isfield(vS,{"al","au","tl","tu"}))==false)
    error("numfields(vS)=%d, expected 4 (al,au,tl and tu)",numfields(vS));
  endif

  % Initialise
  xk=x0(:);
  Asqk=[];Tk=[];feasible=false;
  socp_iter=0;func_iter=0;loop_iter=0;
  pars.eps=1e-6;
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

    % Find the response values and gradients
    [Asqk,Tk,gradAsqk,gradTk]=iir_frm(w,xk,U,V,M,Q,na,nc,Mmodel,Dmodel);
    Tk=Tk(1:Nwt);
    gradTk=gradTk(1:Nwt,:);
    func_iter = func_iter+1;

    %
    % Set up the SeDuMi problem. 
    % The vector to be minimised is [epsilon;beta;x] where epsilon is 
    % the MMSE error, beta is the coefficient step size and x is the 
    % coefficient difference vector.
    %

    % Linear coefficient constraints on pole radiuses (D'*xk+f>=0)
    Qon2=Q/2;
    D=[zeros(2+1+U,2*(V+Qon2)); ...
       -eye(V,V), eye(V,V), zeros(V,2*Qon2); ...
       zeros(M,2*(V+Qon2)); ...
       zeros(Qon2,2*V), -eye(Qon2,Qon2), eye(Qon2,Qon2); ...
       zeros(Qon2+Nfir,2*(V+Qon2))];
    f=[xu((1+U+1):(1+U+V))            - xk((1+U+1):(1+U+V)); ...
       xk((1+U+1):(1+U+V))            - xl((1+U+1):(1+U+V)); ...
       xu((1+U+V+M+1):(1+U+V+M+Qon2)) - xk((1+U+V+M+1):(1+U+V+M+Qon2)); ...
       xk((1+U+V+M+1):(1+U+V+M+Qon2)) - xl((1+U+V+M+1):(1+U+V+M+Qon2))];

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
    if verbose && ~iir_frm_slb_constraints_are_empty(vS)
      iir_frm_slb_show_constraints(vS,w,Asqk,Tk);
    endif
           
    % SeDuMi quadratic constraint matrixes

    % Step size constraints
    At_step=[[0;1;zeros(Nxk,1)], [zeros(2,Nxk);eye(Nxk,Nxk)]];
    At=[At, -At_step];
    ct=[ct;0;zeros(Nxk,1)];
    sedumiK.q=Nxk+1;

    % MMSE frequency response constraints
    b=[1;0;zeros(Nxk,1)];
    c=[Wa.*(Asqk-Asqd);Wt.*(Tk-Td);];
    d=0;
    At1=[zeros(Nw+Nwt,2), ...
         [gradAsqk.*kron(ones(1,Nxk),Wa); ...
          gradTk.*kron(ones(1,Nxk),Wt)]]';
    At=[At, -b, -At1];
    ct=[ct;d;c];
    sedumiK.q=[sedumiK.q, size(At1,2)+1];

    % Call SeDuMi
    bt=-[1;1;zeros(Nxk,1)];
    try
      [xs,ys,info]=sedumi(At,bt,ct,sedumiK,pars);
      printf("SeDuMi info.iter=%d, info.feasratio=%10.4g, r0=%10.4g\n", ...
             info.iter,info.feasratio,info.r0);
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
