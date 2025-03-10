function [x1,E,socp_iter,feasible]= ...
         frm2ndOrderCascade_socp(x0,M,td,tau,w,Hd,Wd,maxiter,tol,verbose)
% [x1,E,socp_iter,func_iter,feasible]= ...
%  frm2ndOrderCascade_socp(x0,M,td,tau,w,Hd,Wd,maxiter,tol,verbose)
%
% Use the SeDuMi solver to find the coefficients of an FRM filter with
% an IIR model filter and linear phase masking filters. The stability
% of the IIR filter is ensured by linear constraints on the
% coefficients of the second-order sections (and possibly one
% first-order section) comprising the denominator polynomial of the
% filter. The masking filters are assumed to be linear-phase and
% therefore symmetric.
%
% Inputs:
%   x0 - initial filter design in a structure passed to pfx
%        * a IIR model filter numerator coefficients
%           a0 + a1*z^-1 + ... + an*z^-n
%        * d IIR model filter denominator coefficients
%           1 + d1*z^-1 + ... + dr*z^-r
%        * aa symmetric FIR masking filter coefficients
%        * ac symmetric FIR complementary masking filter coefficients
%   M - decimation factor of the IIR model filter
%   td - passband delay of the IIR model filter
%   tau - margin for the stability constraints on the IIR model filter
%         denominator polynomial
%   w - response angular frequencies
%   Hd - desired zero-phase amplitude response
%   Wd - response weights
%   maxiter -
%   tol - 
%   verbose -
%
% Outputs:
%   x1 - filter design
%   E - response error for x1
%   socp_iter - iterations of the SeDuMi solver
%   feasible - true if the design succeeded
%
% See : "Optimal Design of IIR Frequency-Response-Masking Filters 
% Using Second-Order Cone Programming", W.-S.Lu and T.Hinamoto,  
% IEEE Transactions on Circuits and Systems-I:Fundamental Theory and 
% Applications, Vol. 50, No. 11, pp. 1401-1412, Nov. 2003

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

  % Sanity checks
  if nargin ~= 10
    print_usage(["[x1,E,socp_iter,feasible]= ...\n", ...
 "    frm2ndOrderCascade_socp(x0,M,td,tau,w,Hd,Wd,maxiter,tol,verbose)"]);
  endif
  if all(isfield(x0,{"a","d","aa","ac"}))==false
    error("field missing from x0");
  endif
  if length(w) ~= length(Hd)
    error("length(w) ~= length(Hd)");
  endif
  if length(w) ~= length(Wd)
    error("length(w) ~= length(Wd)");
  endif
  % Sanity checks on xk
  [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0);
  xk=xk(:);
  Nxk=length(xk);
  na_is_odd=(mod(na,2)==1);
  nc_is_odd=(mod(nc,2)==1);
  if na_is_odd ~= nc_is_odd
    error("Expected na_is_odd == nc_is_odd");
  endif
  mnp1=mn+1;
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
  niir=mnp1+mr;
  nfir=una+unc;
  if length(xk) ~= (niir+nfir)
    error("Expected length(xk) == (niir+nfir)");
  endif

  %
  % Initialise
  %
  x1=[];E=inf;feasible=false;
  socp_iter=0;func_iter=0;loop_iter=0; 
  w=w(:);Nw=length(w);
  Hd=Hd(:);Wd=Wd(:);

  % Initialise constraints
  
  % Allow for epsilon, beta0 and beta1 in D
  nmin=3;

  % Initialise linear constraint matrixes for the
  % coefficients of the denominator second order sections
  [C,e]=stability2ndOrderCascade(mr);
  D=[zeros(mnp1,rows(C)); C'; zeros(nfir,rows(C))];
  
  % Initialise IIR filter step size constraints
  bt_step_iir=[0;1;0;zeros(Nxk,1)];
  At_step_iir=[zeros(nmin,niir); eye(niir,niir); zeros(nfir,niir)];

  % Initialise FIR filter step size constraints
  bt_step_fir=[0;0;1;zeros(Nxk,1)];
  At_step_fir=[zeros(nmin+niir,nfir); eye(nfir,nfir)];
    
  %
  % Get the zero phase filter response and linear constraints for x0
  %
  [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td);
  Nxk=length(xk);

  %
  % Second Order Cone Programming (SQP) loop
  %
  while 1

    %
    % Limit number of loop iterations
    %
    loop_iter=loop_iter+1;
    if loop_iter > maxiter
      error("maxiter exceeded");
    endif

    %
    % Set up the SeDuMi problem. 
    % The vector to be minimised is [epsilon;beta0;beta1;delta] where 
    % epsilon is the minimax error, beta0 is the coefficient step size
    % of the IIR filter coefficients, beta1 is the step size of the FIR
    % masking filter coefficients and delta is the coefficient
    % difference vector.
    % 

    % SeDuMi linear constraint matrixes

    %
    % Linear stability constraints on the coefficients
    % of the denominator first and second order sections.
    %
    if mr == 0
      At=[];
      ct=[];
      sedumiK.l=0;
    else 
      At=-[zeros(nmin,columns(D)); D];
      f=[zeros(rows(C),mnp1) C zeros(rows(C),nfir)]*xk+(1-tau)*e;
      ct=f;
      sedumiK.l=columns(D);
    endif
    printf("Added %d linear constraints\n",sedumiK.l);

    % SeDuMi quadratic constraint matrixes

    % IIR filter step size constraints
    At=[At, -[bt_step_iir, At_step_iir]];
    ct=[ct;0;zeros(niir,1)];
    sedumiK.q=[(niir+1)];

    % FIR filter step size constraints
    At=[At, -[bt_step_fir At_step_fir]];
    ct=[ct;0;zeros(nfir,1)];
    sedumiK.q=[sedumiK.q, (nfir+1)];

    % Minimise error sum constraint
    d_c_resp=[0;Wd.*real(Hw-Hd);Wd.*imag(Hw-Hd)];
    ct=[ct; d_c_resp];
    bt_resp=[1;0;0;zeros(Nxk,1)];
    At_resp=[zeros(Nw,nmin) real(gradHw).*kron(ones(1,Nxk),Wd); ...
             zeros(Nw,nmin) imag(gradHw).*kron(ones(1,Nxk),Wd)]';
    At=[At -[bt_resp At_resp]];
    sedumiK.q=[sedumiK.q ((2*Nw)+1)];

    % All quadratic constraints added
    printf("Added %d quadratic constraints\n",length(sedumiK.q));

    %
    % Call SeDuMi
    %
    bt=-[ones(nmin,1);zeros(Nxk,1)];
    [xs,ys,info]=sedumi(At,bt,ct,sedumiK);
    socp_iter=socp_iter+info.iter;

    % Extract results
    epsilon=ys(1);
    beta_iir=ys(2);
    beta_fir=ys(3);
    delta=ys((nmin+1):end);
    xk=xk+delta;
    % !?!?!
    % This moves the second order sections around. It seems to help a lot! 
    % !?!?! 
    if 1
      dtmp=casc2tf(xk((mnp1+1):(mnp1+mr)));
      xk((mnp1+1):(mnp1+mr))=tf2casc(dtmp);
    endif
    % Show SeDuMi results
    [Hw,gradHw]=frm2ndOrderCascade(w,xk,mn,mr,na,nc,M,td);
    E=norm(abs(Hd-Hw),2);
    if verbose
      printf("epsilon(Sum of errors)=%g\n",epsilon);
      printf("beta(IIR)=%g\n",beta_iir);
      printf("beta(FIR)=%g\n",beta_fir);
      printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
      printf("norm(delta)=%g\n",norm(delta));
      printf("xk=[ ");printf("%g ",xk');printf(" ]';\n");
      printf("E= %g\n",E);
      printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
      info
    endif
    if info.numerr == 1
      warning("SeDuMi premature termination)"); 
      break;
    elseif info.numerr == 2 
      warning("SeDuMi numerical failure"); 
      break;
    elseif info.pinf 
      warning("SeDuMi primary problem infeasible"); 
      break;
    elseif info.dinf
      warning("SeDuMi dual problem infeasible"); 
      break;
    endif 

    % Loop termination conditions
    if norm(delta)/norm(xk) < tol
      x1=frm2ndOrderCascade_vec_to_struct(xk,mn,mr,na,nc);
      printf("norm(delta)/norm(xk) < tol\n");
      feasible=true;
      break;
    endif
  endwhile

endfunction
