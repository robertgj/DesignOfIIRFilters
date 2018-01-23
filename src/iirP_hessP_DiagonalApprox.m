function hessP_diag_approx=iirP_hessP_DiagonalApprox(w,x,U,V,M,Q,R,tol)
% hessP_diag_approx=iirP_hessP_DiagonalApprox(w,x,U,V,M,Q,R,tol)
% Given the U real zeros, V real poles, M conjugate zeros and 
% Q conjugate poles of an IIR filter with decimation R find an
% approximation to the diagonal of the Hessian matrix at 
% angular frequency w. x is the vector [K R0 Rp r0 theta0 rp thetap]
% of coefficients of the filter. K is a gain factor. R0 is a vector
% of U real zero radiuses, Rp is a vector of V real pole radiuses.
% r0 is a vector of M/2 zero radiuses and theta0 is a vector of M/2
% zero angles that together define M/2 conjugate pairs of zeros. 
% Likewise, rp is a vector of Q/2 pole radiuses and thetap is a 
% vector of Q/2 pole angles that together define Q/2 conjugate 
% pairs of poles.
%
% !!! NOTE WELL !!! :
%
%   1. For multiple frequencies results are returned with
%      frequency varying in dimension 1.
%
%   2. The gradients are with respect to the filter coefficients, 
%      NOT the frequency.
%
%   3. Note the Hessian is defined as:
%        del2fdelx1delx1  del2fdelx1delx2  del2fdelx1delx3 ...
%        del2fdelx2delx1  del2fdelx2delx2  del2fdelx2delx3 ...
%        etc

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
if nargin<7 || nargout>3
  print_usage("hessP_diag_approx=iirP_hessP_DiagonalApprox(w,x,U,V,M,Q,R[,tol])");
endif
if nargin == 7
  tol=1e-9;
endif
if length(x) ~= 1+U+V+Q+M
  error ("Expect length(x) == 1+U+V+Q+M");
endif
if rem(M,2)
  error ("Expected an even number of conjugate zeros");
endif
if rem(Q,2)
  error ("Expected an even number of conjugate poles");
endif

% Sanity checks on x
if (iscomplex(x) != 0)
  error("Complex coefficient found in x!");
endif

% Allow empty frequency vector
if isempty(w)
  hessP_diag_approx=[]; return;
endif

% Constants
s=1/R;
w=w(:);
Nw=length(w);
Mon2=M/2;
Qon2=Q/2;
UV=U+V;
UVMon2=UV+Mon2;
UVM=UV+M;
UVMQon2=UVM+Qon2;
UVMQ=UVM+Q;
N=1+UVMQ;

% Extract coefficients from x
K=x(1);
R0=x((1+1):(1+U));
R0=R0(:)';
Rp=x((1+U+1):(1+UV));
Rp=Rp(:)';
r0=x((1+UV+1):(1+UVMon2));
r0=r0(:)';
theta0=x((1+UVMon2+1):(1+UVM));
theta0=theta0(:)';
rp=x((1+UVM+1):(1+UVMQon2));
rp=rp(:)';
thetap=x((1+UVMQon2+1):(1+UVMQ));
thetap=thetap(:)';

diag_hessPD=zeros(Nw,N);
[P,gradP]=iirP(w,[K R0 Rp r0 theta0 rp thetap],U,V,M,Q,R);

% K
[PD,gradPD]=iirP(w,[K+tol R0 Rp r0 theta0 rp thetap],U,V,M,Q,R);
diag_hessPD(:,1)=(gradPD(:,1)-gradP(:,1))/tol;

% Real zeros
for k=1:U
  delk=[zeros(1,k-1) tol zeros(1,(U-k))];
  [PD,gradPD]=iirP(w,[K R0+delk Rp r0 theta0 rp thetap],U,V,M,Q,R);
  hessPD(:,1+k)=(gradPD(:,1+k)-gradP(:,1+k))/tol;
endfor

% Real poles
for k=1:V
  delk=[zeros(1,k-1) tol zeros(1,(V-k))];
  [PD,gradPD]=iirP(w,[K R0 Rp+delk r0 theta0 rp thetap],U,V,M,Q,R);
  hessPD(:,1+U+k)=(gradPD(:,1+U+k)-gradP(:,1+U+k))/tol;
endfor

% Conjugate zeros
for k=1:Mon2
  delk=[zeros(1,k-1) tol zeros(1,(Mon2-k))];

  [PD,gradPD]=iirP(w,[K R0 Rp r0+delk theta0 rp thetap],U,V,M,Q,R);
  hessPD(:,1+U+V+k)=(gradPD(:,1+U+V+k)-gradP(:,1+U+V+k))/tol;

  [PD,gradPD]=iirP(w,[K R0 Rp r0 theta0+delk rp thetap],U,V,M,Q,R);
  hessPD(:,1+U+V+Mon2+k)=(gradPD(:,1+U+V+Mon2+k)-gradP(:,1+U+V+Mon2+k))/tol;
endfor

% Conjugate poles
for k=1:Qon2
  delk=[zeros(1,k-1) tol zeros(1,(Qon2-k))];

  [PD,gradPD]=iirP(w,[K R0 Rp r0 theta0 rp+delk thetap],U,V,M,Q,R);
  hessPD(:,1+U+V+M+k)=(gradPD(:,1+U+V+M+k)-gradP(:,1+U+V+M+k))/tol;

  [PD,gradPD]=iirP(w,[K R0 Rp r0 theta0 rp thetap+delk],U,V,M,Q,R);
  hessPD(:,1+U+V+M+Qon2+k)= ...
  (gradPD(:,1+U+V+M+Qon2+k)-gradP(:,1+U+V+M+Qon2+k))/tol;
endfor

% Convert to Nw-by-(N-by-N diagonal arrays)
% Suppose Nw=5, N=3 and the Hessian diagonal components are
% calulated in an Nw-by-N array:
%  N=3
%  Nw=5
%  t=reshape(1:(Nw*N),N,Nw)'
% Convert to Nw-by-N-by-N diagonal arrays by:
%  tt=kron(t,[1 zeros(1,N)])
%  ttt=tt(:,1:(N*N))'
%  tttt=reshape(ttt',5,3,3)
hessPD_1=kron(hessPD,[1 zeros(1,N)]);
hessPD_2=hessPD_1(:,1:(N*N))';
hessP_diag_approx=reshape(hessPD_2',Nw,N,N);

% If necessary, convert to matrix
sizeH=size(hessP_diag_approx);
if sizeH(1) == 1
  hessP_diag_approx=reshape(hessP_diag_approx,sizeH(2),sizeH(3));
endif

endfunction
