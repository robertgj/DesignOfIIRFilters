function [ak,bk,socp_iter,func_iter,feasible]= ...
  allpass2ndOrderCascade_socp(a0,b0,tau,wa,Ad,Wa,resp,maxiter,tol,verbose)
% [ak,bk,socp_iter,func_iter,feasible] = ...
%   allpass2ndOrderCascade_socp(a0,b0,tau,wa,Ad,Wa,resp,maxiter,tol,verbose)
%
% Design of a low pass filter consisting of the parallel combination of two 
% allpass filters, each implemented as a cascade of second order
% sections. The design is optimised with SOCP with constraints
% on the filter frequency. See:
%   "Optimal Design of IIR Frequency-Response-Masking Filters Using 
%   Second-Order Cone Programming", W.-S.Lu and T.Hinamoto,
%   IEEE Transactions on Circuits and Systems-I:Fundamental Theory and 
%   Applications, Vol.50, No.11, Nov. 2003, pp.1401--1412
%
% Inputs:
%   a0 - initial coefficient vector in the form:
%         [ [a0] a11 a12 a21 a22 a31 ... ]
%         a0 only appears if the filter order is odd and the first
%         section is first-order.
%   b0 - initial coefficient vector
%   tau - pole magnitude stability constraint
%   wa - angular frequencies of the desired response
%        in [0,pi]. 
%   Ad - desired frequency response
%   Wa - response weight at each frequency
%   resp - string for type of response calculation. Currently "complex"
%          or "sqmag"
%   maxiter - maximum number of SQP iterations
%   tol - tolerance
%   verbose -
%
% Outputs:
%   ak - allpass filter design 
%   bk - allpass filter design 
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
if (nargin != 10) || (nargout < 2)
  print_usage("[ak,bk,socp_iter,func_iter,feasible]= ...\n\
  allpass2ndOrderCascade_socp(a0,b0,tau,wa,Ad,Wa,resp,maxiter,tol,verbose)");
endif
if isempty(wa)
  error("wa is emtpy");
endif
Nwa=length(wa);
if Nwa != length(Ad)
  error("Expected length(wa)(%d) == length(Ad)(%d)",Nwa,length(Ad));
endif  
if Nwa != length(Wa)
  error("Expected length(wa)(%d) == length(Wa)(%d)",Nwa,length(Wa));
endif
if tau<0 || tau>=1
  error("Invalid pole magnitude stability constraint tau(%g)",tau);
endif

% Initialise
ma=length(a0);
ak=a0(:);
mb=length(b0);
bk=b0(:);
mx=ma+mb;
feasible=false;
socp_iter=0;func_iter=0;loop_iter=0;
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

  % Complex frequency response and gradient
  [aAmpk,gradaAmpk]=allpass2ndOrderCascade(ak,wa);
  [bAmpk,gradbAmpk]=allpass2ndOrderCascade(bk,wa);
  Ampk=(aAmpk+bAmpk)/2;
  gradAmpk=[gradaAmpk,gradbAmpk]/2;
  func_iter = func_iter+2;

  %
  % Set up the SeDuMi problem. The vector to be minimised is
  % [epsilon;beta;da] where epsilon is the maximum error, beta
  % is the coefficient step size and da is the coefficient
  % difference vector.
  %

  %
  % Linear constraints
  %
  
  % Constraints on the coefficients of the second order sections
  [aC,ae]=stability2ndOrderCascade(ma);
  [bC,be]=stability2ndOrderCascade(mb);
  C=[aC,zeros(rows(aC),columns(bC));zeros(rows(bC),columns(aC)),bC];
  e=[ae;be];
  D=[zeros(2,rows(C)); C'];
  xk=[ak;bk];
  f=C*xk+(1-tau)*e;

  % SeDuMi linear constraint matrixes
  At=-D;
  ct=f;
  sedumiK.l=columns(D);
  if verbose
    printf("Added %d linear constraints\n",sedumiK.l);
  endif
  
  %
  % SeDuMi quadratic constraint matrixes
  %

  % Step size constraints
  ct=[ct;0;zeros(mx,1)];
  bt_step=[0;1;zeros(mx,1)];
  At_step=[zeros(2,mx);eye(mx,mx)];
  At=[At, -[bt_step,At_step]];
  sedumiK.q=(1+mx);

  if strcmp(resp,"complex")
    % Response constraints : |(gradA'*(x-xk))+A-Ad|| <= epsilon
    d_c_resp=[0;Wa.*real(Ampk-Ad);Wa.*imag(Ampk-Ad)];
    ct=[ct; d_c_resp];
    bt_resp=[1,0,zeros(1,mx)];
    At_resp=[zeros(Nwa,2), real(gradAmpk).*kron(ones(1,mx),Wa); ...
             zeros(Nwa,2), imag(gradAmpk).*kron(ones(1,mx),Wa)];
    At=[At, -[bt_resp;At_resp]'];
    sedumiK.q=[sedumiK.q, (1+(2*Nwa))];
  elseif strcmp(resp,"sqmag")
    A2=abs(Ampk).^2;
    A2d=abs(Ad).^2;
    gradA2=(2*kron(real(Ampk),ones(1,mx)).*real(gradAmpk)) + ...
           (2*kron(imag(Ampk),ones(1,mx)).*imag(gradAmpk));
    Wa2=Wa.^2;
    d_c_resp=[0;Wa2.*(A2-A2d)];
    ct=[ct; d_c_resp];
    bt_resp=[1,0,zeros(1,mx)];
    At_resp=[zeros(Nwa,2), gradA2.*kron(ones(1,mx),Wa2)];
    At=[At, -[bt_resp;At_resp]'];
    sedumiK.q=[sedumiK.q, (1+Nwa)];    
  else
    error("Unknown resp type : %s",resp);
  endif
  
  % Call SeDuMi
  bt=-[1;1;zeros(mx,1)];
  [xs,ys,info]=sedumi(At,bt,ct,sedumiK,pars);
  if info.pinf 
    error("SeDuMi primary problem infeasible"); 
  elseif info.dinf
    error("SeDuMi dual problem infeasible"); 
  elseif info.numerr == 1
    error("SeDuMi premature termination"); 
  elseif info.numerr == 2 
    error("SeDuMi numerical failure"); 
  endif 
  if isfield(info,"iter")
    printf("info.iter=%d\n",info.iter);
  endif
  if isfield(info,"feasratio")
    printf("info.feasratio=%d\n",info.feasratio);
  endif
  
  % Extract results
  epsilon=ys(1);
  beta=ys(2);
  dxk=ys(3:end);
  xk=dxk+xk;
  dak=dxk(1:ma);
  ak=ak+dak;
  dbk=dxk((ma+1):end);
  bk=bk+dbk;
  socp_iter=socp_iter+info.iter;
  if verbose
    printf("epsilon=%g\n",epsilon);
    printf("beta=%g\n",beta);
    printf("dak=[ ");printf("%g ",dak');printf(" ]';\n"); 
    printf("norm(dak)=%g\n",norm(dak));
    printf("ak=[ ");printf("%g ",ak');printf(" ]';\n");
    printf("dbk=[ ");printf("%g ",dbk');printf(" ]';\n"); 
    printf("norm(dbk)=%g\n",norm(dbk));
    printf("bk=[ ");printf("%g ",bk');printf(" ]';\n");
    printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
  endif
  if norm(dxk)/norm(xk) < tol
    printf("norm(dak)/norm(ak) < tol\n");
    feasible=true;
    break;
  endif
endwhile

endfunction
