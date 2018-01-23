function [x1,socp_iter,feasible]= ...
  lowpass2ndOrderCascade_socp(x0,tau,w,Hd,W,npass,nstop,resp,maxiter,tol,verbose)
% [x1,socp_iter,func_iter,feasible]= ...
% lowpass2ndOrderCascade_socp(x0,tau,w,Hd,W,npass,nstop,resp,maxiter,tol,verbose)
%
% Use the SeDuMi solver to find the coefficients of an IIR lowpass filter.
% The stability of the IIR filter is ensured by linear constraints on the
% coefficients of the second-order sections (and possibly one
% first-order section) comprising the denominator polynomial of the
% filter.
%
% Inputs:
%   x0 - initial filter design in a structure passed to pfx
%        * a IIR model filter numerator coefficients
%           a0 + a1*z^-1 + ... + an*z^-n
%        * d IIR model filter denominator coefficients
%           1 + d1*z^-1 + ... + dr*z^-r
%   tau - margin for the stability constraints on the IIR lowpass filter
%         denominator polynomial
%   w - response angular frequencies
%   Hd - desired response
%   W - response weights
%   npass - pass band edge index in w 
%   nstop - stop band edge index in w
%   resp - a string defining the type of response calculation
%           * "complex"  : use the complex response across the band
%           * "sqmag"    : use the squared-magnitude response across the band
%           * "mixed"    : use the complex response across the pass band and the
%                          squared-magnitude response across the stop band
%           * "separate" : use the complex response at each frequency
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

% Sanity checks
if nargin != 11
  print_usage("[x1,E,socp_iter,feasible]= ...\n\
  lowpass2ndOrderCascade_socp(x0,tau,w,Hd,W,npass,nstop,resp, ...\n\
                              maxiter,tol,verbose)");
endif
if all(isfield(x0,{"a","d"}))==false
  error("field missing from x0");
endif
if length(w) != length(Hd)
  error("Expect length(w) == length(Hd)");
endif
if length(w) != length(W)
  error("Expect length(w) == length(W)");
endif
if (0 > npass) || (npass > nstop) || (nstop>length(w))
  error("Expect 0<npass<nstop<length(w)");
endif

% Initialise
feasible=false;
socp_iter=0;func_iter=0;loop_iter=0; 
w=w(:);Nw=length(w);Hd=Hd(:);W=W(:);
if verbose
  pars.fid=2;
else
  pars.fid=0;
endif

% Filter coefficients and lengths
mnp1=length(x0.a);
mr=length(x0.d)-1;
mr_is_odd=(mod(mr,2)==1);
L=floor(mr/2);
Nxk=mnp1+mr;

% Frequency arrays
vw=exp(-j*kron((0:(mnp1-1)),w));
v1=exp(-j*w);
v2=[exp(-j*w) exp(-j*2*w)];

% Extract initial filter coefficients from x0
ak=x0.a(:);
ak=ak/x0.d(1);
% Convert dd to second order sections
dd=x0.d(:)/x0.d(1);
dk=tf2casc(dd);
dk=dk(:);
xk=[ak;dk];

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
  % FRM filter zero-phase frequency response
  %

  % Extract filter coefficients from xk
  ak=xk(1:(mnp1)); 
  dk=xk((mnp1+1):(mnp1+mr));

  % Numerator frequency response
  akw=vw*ak;

  % Denominator frequency response
  if mr_is_odd
    dk0=dk(1);
    dki=reshape(dk(2:end),2,L);
    dkw=(1+dk0*v1);
  else
    dki=reshape(dk,2,L);
    dkw=ones(Nw,1);
  endif
  % v2 is length(w)-by-2, dki is 2-by-L
  dkw=dkw.*prod(1+(v2*dki),2);

  % Overall filter frequency response
  Hw=akw./dkw;

  %
  % Gradient of overall frequency response, length(w)-by-length(xk)
  %
  
  % delHawdela (nw-by-mnp1)
  delHwdela=vw./kron(dkw,ones(1,mnp1));

  % delHaMwdeld (nw-by-mr)
  if mr_is_odd
    delHwdeld=-Hw.*v1./(1+dk0*v1);
  else
    delHwdeld=[];
  endif
  v2L=kron(ones(1,L),v2);
  delHwdeld=[delHwdeld, ...
             -kron(Hw,ones(1,L*2)).*v2L./kron(ones(1,2),(1+(v2*dki)))];

  % Gradient nw-by-(mnp1+mr)
  gradHw=[delHwdela delHwdeld];

  %
  % Set up the SeDuMi problem. 
  % The vector to be minimised is [epsilon;beta;delta] where epsilon is 
  % the minimax error, beta is the coefficient step size and delta is the 
  % coefficient difference vector.
  %

  % Linear stability constraints on denominator coefficients
  [C,e]=stability2ndOrderCascade(mr);
  % Allow for epsilon and beta in D
  D=[zeros(2,rows(C)); zeros(mnp1,rows(C)); C'];
  f=[zeros(rows(C),mnp1) C]*xk+(1-tau)*e;
  
  % SeDuMi linear constraint matrixes
  At=-D;
  ct=f;
  sedumiK.l=size(D,2);
  printf("Added %d linear constraints\n",sedumiK.l);

  % SeDuMi quadratic constraint matrixes
  % Step size constraints
  bt_step=[0;1;zeros(Nxk,1)];
  At_step=[zeros(2,Nxk);eye(Nxk,Nxk)];
  At=[ At -[bt_step At_step] ];
  ct=[ct;0;zeros(Nxk,1)];
  sedumiK.q=1+Nxk;

  % Frequency response constraints
  if strcmp(resp,"complex")
    % ||(gradHw'*(x-xk))+Hw-Hd|| <= epsilon
    d_c_resp=[0;W.*real(Hw-Hd);W.*imag(Hw-Hd)];
    ct=[ct; d_c_resp];
    bt_resp=[1 0 zeros(1,Nxk)];
    At_resp=[zeros(Nw,2) real(gradHw).*kron(ones(1,Nxk),W);
             zeros(Nw,2) imag(gradHw).*kron(ones(1,Nxk),W)];
    At=[At -[bt_resp;At_resp]'];
    sedumiK.q=[sedumiK.q (1+(2*Nw))];
  elseif strcmp(resp,"sqmag")
    % Ignore phase response
    Asq=abs(Hw).^2;
    Asqd=abs(Hd).^2;
    gradAsq=(2*kron(real(Hw),ones(1,Nxk)).*real(gradHw)) + ...
           (2*kron(imag(Hw),ones(1,Nxk)).*imag(gradHw));
    W2=W.^2;
    d_c_resp=[0;W2.*(Asq-Asqd)];
    ct=[ct; d_c_resp];
    bt_resp=[1 0 zeros(1,Nxk)];
    At_resp=[zeros(Nw,2) gradAsq.*kron(ones(1,Nxk),W2)];
    At=[At -[bt_resp;At_resp]'];
    sedumiK.q=[sedumiK.q (1+Nw)];    
  elseif strcmp(resp,"mixed")
    % Complex frequency response and gradient in the pass band
    Hpass=Hw(1:npass);
    gradHpass=gradHw(1:npass,:);
    Wpass=W(1:npass);
    Hdpass=Hd(1:npass);
    % Pass band constraints
    d_c_pass=[0; Wpass.*real(Hpass-Hdpass); Wpass.*imag(Hpass-Hdpass)];
    ct=[ct; d_c_pass];
    bt_pass=[1 0 zeros(1,Nxk)];
    At_pass=[zeros(npass,2) real(gradHpass).*kron(ones(1,Nxk),Wpass); ...
             zeros(npass,2) imag(gradHpass).*kron(ones(1,Nxk),Wpass)];
    At=[At -[bt_pass;At_pass]'];
    sedumiK.q=[sedumiK.q (1+(2*npass))];
    % Squared-magnitude frequency response and gradient in the stop band
    S2stop=abs(Hw(nstop:end)).^2;
    gradS2stop= ...
      (2*kron(real(Hw(nstop:end)),ones(1,Nxk)).*real(gradHw(nstop:end,:))) + ...
      (2*kron(imag(Hw(nstop:end)),ones(1,Nxk)).*imag(gradHw(nstop:end,:)));
    W2stop=W(nstop:end).^2;
    S2dstop=abs(Hd(nstop:end)).^2;
    % Stop band constraints
    d_c_stop=[0; W2stop.*(S2stop-S2dstop)];
    ct=[ct; d_c_stop];
    bt_stop=[1 0 zeros(1,Nxk)];
    At_stop=[zeros(Nw-nstop+1,2) gradS2stop.*kron(ones(1,Nxk),W2stop)];
    At=[At -[bt_stop;At_stop]'];
    sedumiK.q=[sedumiK.q (1+Nw-nstop+1)];
  elseif "separate"
    % Separate error constraints at each response frequency
    % Only works for length(w)=4 not 8!
    d_c_resp=kron(W.*real(Hw-Hd),[0;1;0])+kron(W.*imag(Hw-Hd),[0;0;1]);
    ct=[ct; d_c_resp];
    bt_resp = kron( kron(ones(Nw,1),[1, 0, zeros(1,Nxk)]), [1;0;0]);
    At_resp = [zeros(3*Nw,2), ...
               (kron(real(gradHw).*kron(W,ones(1,Nxk)), [0;1;0]) + ...
                kron(imag(gradHw).*kron(W,ones(1,Nxk)), [0;0;1]))];
    At=[At -(bt_resp+At_resp)'];
    sedumiK.q=[sedumiK.q (3*ones(1,Nw))];
  else
    error("Unknown response type (%s)",resp);
  endif
  
  %
  % Call SeDuMi
  %
  bt=-[1;1;zeros(Nxk,1)];
  [xs,ys,info]=sedumi(At,bt,ct,sedumiK,pars);
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
    printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
    info
  endif
  if norm(delta)/norm(xk) < tol
    printf("norm(delta)/norm(xk) < tol\n");
    feasible=true;
    break;
  endif
endwhile

%
% Construct output filter coefficients
%
x1.a=xk(1:(mnp1));
x1.a=x1.a(:);
x1.d=casc2tf(xk((mnp1+1):(mnp1+mr)));
x1.d=x1.d(:);

endfunction
