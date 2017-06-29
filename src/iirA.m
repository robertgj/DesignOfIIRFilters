function [A,gradA,hessA]=iirA(w,x,U,V,M,Q,R,tol)
% [A,gradA,hessA]=iirA(w,x,U,V,M,Q,R,tol)
% Given the U real zeros, V real poles, M conjugate zeros and 
% Q conjugate poles of an IIR filter with decimation R find the 
% magnitude response, A, gradients and second derivatives at 
% angular frequency w. x is the vector [K R0 Rp r0 theta0 rp thetap]
% of coefficients of the filter. K is a gain factor. R0 is a vector
% of U real zero radiuses, Rp is a vector of V real pole radiuses.
% r0 is a vector of M/2 zero radiuses and theta0 is a vector of M/2
% zero angles that together define M/2 conjugate pairs of zeros. 
% Likewise, rp is a vector of Q/2 pole radiuses and thetap is a 
% vector of Q/2 pole angles that together define Q/2 conjugate 
% pairs of poles. The tol argument allows for errors in the complex 
% number calculations required if the real or complex poles have 
% radius less than zero.
%
% TODO: Add an option to only calculate the diagonal of the Hessian
%
% Inputs:
%   w - vector of angular frequencies
%   x - coefficient vector 
%       [k; 
%        zR(1:U); 
%        pR(1:V); 
%        abs(z(1:Mon2)); angle(z(1:Mon2)); 
%        abs(p(1:Qon2)); angle(p(1:Qon2))];
%       where k is the gain coefficient, zR and pR represent real
%       zeros and poles and z and p represent conjugate zero and pole
%       pairs. 
%   U - number of real zeros
%   V - number of real poles
%   M - number of conjugate zero pairs
%   Q - number of conjugate pole pairs
%   R - decimation factor, pole pairs are for z^R
%   tol - tolerance for maximum imaginary component of a real value
%
% Outputs:
%   A - amplitude response at angular frequencies, w
%   gradA - gradient of amplitude response at angular frequencies, w,
%           with respect to x
%   hessA - hessian of amplitude response at angular frequencies, w,
%           with respect to x
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
%
%   4. NaN is quietly set to 0
%
%   5. For R>1 the gradients of A for real and complex poles at 0 are undefined 
% 
% References:
% [1] A.G.Deczky, "Synthesis of recusive digital filters using the
% minimum p-error criterion" IEEE Trans. Audio Electroacoust.,
% Vol. AU-20, pp. 257-263, October 1972
% [2] M.A.Richards, "Applications of Deczkys Program for Recursive
% Filter Design to the Design of Recursive Decimators" IEEE Trans.
% ASSP-30 No. 5, pp. 811-814, October 1982

% Copyright (C) 2017 Robert G. Jenssen
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
if (nargin<7) || (nargin>8) || (nargout>3)
  print_usage ("[A,gradA,hessA]=iirA(w,x,U,V,M,Q,R,tol)");
endif
if nargin == 7
  tol=1e-9;
endif
if ~isscalar(U)
  error ("Expect U scalar");
endif
if ~isscalar(V)
  error ("Expect V scalar");
endif
if ~isscalar(M)
  error ("Expect M scalar");
endif
if ~isscalar(Q)
  error ("Expect Q scalar");
endif
if ~isscalar(R)
  error ("Expect R scalar");
endif
if ~isscalar(tol)
  error ("Expect tol scalar");
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

% Allow empty frequency vector
if isempty(w) || (nargout==0)
  A=[]; gradA=[]; hessA=[]; return;
endif
% For K==0
if x(1)==0
  A=zeros(length(w),1);
  gradA=zeros(length(w),length(x));
  return;
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

% Sanity checks on x
if iscomplex(x)
  error("Complex coefficient found in x!");
endif
if (R>=2) && (nargout>=2) && any(Rp==0)
  error("Gradient of Rp==0 undefined when R>=2!");
endif
if (R>=2) && (nargout>=2) && any(rp==0)
  error("Gradient of rp==0 undefined when R>=2!");
endif

% In the following, the real zero coefficients are organised as
% (Nw, U), the real pole coefficients are organised as (Nw, V, R),
% the conjugate zero polynomial coefficients are organised 
% as (Nw, Mon2) and the conjugate pole polynomial coefficients 
% are organised as (Nw, Qon2, R)

% For real zeros
wZ=kron(w,ones(1,U));
coswZ=cos(wZ);
kR0=kron(ones(Nw,1),R0);
kR02=kron(ones(Nw,1),R0.^2);

% For real poles
kRp=kron(ones(Nw,1),Rp);
kRp=reshape(kron(ones(1,R),kRp),Nw,V,R);
kRps=kron(ones(Nw,1),Rp.^s);
kRps=reshape(kron(ones(1,R),kRps),Nw,V,R);
kRp2s=kron(ones(Nw,1),Rp.^(2*s));
kRp2s=reshape(kron(ones(1,R),kRp2s),Nw,V,R);
wP=kron(ones(1,R),kron(w,ones(1,V)));
spiPR=s*2*pi*kron(0:(R-1),ones(Nw,V));
kcoswP=reshape(cos(wP-spiPR),Nw,V,R);

% For conjugate zeros
kr0=kron(ones(Nw,1),r0);
kr02=kron(ones(Nw,1),r0.^2);
kr03=kron(ones(Nw,1),r0.^3);
theta0=kron(ones(Nw,1),theta0);
w0=kron(w,ones(1,Mon2));
cosw0Ptheta0=cos(w0+theta0);
cosw0Mtheta0=cos(w0-theta0);

% For conjugate poles create Nw-by-Qon2-by-R 3-D arrays
krp=kron(ones(Nw,1),rp);
krp=reshape(kron(ones(1,R),krp),Nw,Qon2,R);
krps=kron(ones(Nw,1),rp.^s);
krps=reshape(kron(ones(1,R),krps),Nw,Qon2,R);
krp2s=kron(ones(Nw,1),rp.^(2*s));
krp2s=reshape(kron(ones(1,R),krp2s),Nw,Qon2,R);
wp=kron(ones(1,R),kron(w,ones(1,Qon2)));
sthetap=kron(ones(1,R),kron(ones(Nw,1),s*thetap));
spipR=s*2*pi*kron(0:(R-1),ones(Nw,Qon2));
kcoswpPsthetap=reshape(cos(wp+sthetap+spipR),Nw,Qon2,R);
kcoswpMsthetap=reshape(cos(wp-sthetap-spipR),Nw,Qon2,R);

% Make w the column matrix dimension of the outputs
A=zeros(Nw,1);

% Amplitude
numAR0=1-(2*kR0.*coswZ)+kR02;
denomARp=1-(2*kRps.*kcoswP)+kRp2s;
if any(any(denomARp == 0))
  error("denomARp has zero entry");
endif
numAzplus=1-(2*kr0.*cosw0Ptheta0)+kr02;
numAzminus=1-(2*kr0.*cosw0Mtheta0)+kr02;
denomAplus=1-(2*krps.*kcoswpPsthetap)+krp2s;
if any(any(denomAplus == 0))
  error("denomAplus has zero entry");
endif
denomAminus=1-(2*krps.*kcoswpMsthetap)+krp2s;
if any(any(denomAminus == 0))
  error("denomAminus has zero entry");
endif

%
% Magnitude response
%
numA=prod(sqrt(numAR0),2);
numA=numA.*prod(sqrt(numAzplus.*numAzminus),2);
if max(abs(imag(numA)))>tol
  error("abs(imag(numA))>tol!");
endif
denomA=prod(prod(sqrt(denomARp),3),2);
% !!!! OBSCURE CODE WARNING !!!!
% Use abs to force the positive branch of sqrt
denomA=denomA.*prod(prod(sqrt(abs(denomAminus.*denomAplus)),3),2);
max_imag_denomA=max(abs(imag(denomA)));
if max_imag_denomA>tol
  error("max(abs(imag(denomA)))(=%g)>tol!",max_imag_denomA);
endif
A=real(K*numA./denomA);
% Sanity checks on A
A=fixResultNaN(A);
if any(isinf(A))
  error("A has inf!");
endif
if nargout==1
  return;
endif

%
% Gradient of magnitude response
%

% For real poles
Rps1=zeros(size(Rp));
iRpnz=find(Rp~=0);
Rps1(iRpnz)=Rp(iRpnz).^(s-1);
kRps1=kron(ones(Nw,1),Rps1);
kRps1=reshape(kron(ones(1,R),kRps1),Nw,V,R);
kRp2s1=kRps1.*kRps;
kRp3s1=kRp2s1.*kRps;

% For conjugate zeros
sinw0Ptheta0=sin(w0+theta0);
sinw0Mtheta0=sin(w0-theta0);

% For conjugate poles
rps1=zeros(size(rp));
irpnz=find(rp~=0);
rps1(irpnz)=rp(irpnz).^(s-1);
krps1=kron(ones(Nw,1),rps1);
krps1=reshape(kron(ones(1,R),krps1),Nw,Qon2,R);
krp2s1=krps1.*krps;
krp3s1=krp2s1.*krps;
ksinwpPsthetap=reshape(sin(wp+sthetap+spipR),Nw,Qon2,R);
ksinwpMsthetap=reshape(sin(wp-sthetap-spipR),Nw,Qon2,R);
kAZ=kron(A,ones(1,U));
kAP=kron(A,ones(1,V));
kA0=kron(A,ones(1,Mon2));
kAp=kron(A,ones(1,Qon2));

% delA/delK
delAdelK=A/K;

% delA/delR0
delAdelR0=kAZ.*(kR0-coswZ)./numAR0;

% delA/delRp
numdelAdelRp=kRp2s1-(kRps1.*kcoswP);
delAdelRp=-s*kAP.*sum(numdelAdelRp./denomARp,3);

% delA/delr0
delAdelr0=kA0.*(((kr0-cosw0Mtheta0)./numAzminus)+...
               ((kr0-cosw0Ptheta0)./numAzplus));

% delA/deltheta0
delAdeltheta0=kA0.*(((kr0.*sinw0Ptheta0)./numAzplus)-...
		    ((kr0.*sinw0Mtheta0)./numAzminus));

% delA/delrp
numdelAdelrpplus=krp2s1-(krps1.*kcoswpPsthetap);
numdelAdelrpminus=krp2s1-(krps1.*kcoswpMsthetap);
delAdelrp=-s*kAp.*sum((numdelAdelrpplus./denomAplus)+...
                      (numdelAdelrpminus./denomAminus),3);

% delA/delthetap
numdelAdelthetapplus=krps.*ksinwpPsthetap;
numdelAdelthetapminus=krps.*ksinwpMsthetap;
delAdelthetap=-s*kAp.*sum((numdelAdelthetapplus./denomAplus)-...
                          (numdelAdelthetapminus./denomAminus),3);

% Make gradA
gradA=zeros(Nw,1+UVMQ);
gradA(:,1)=delAdelK;
gradA(:,(1+1):(1+U))=delAdelR0;
gradA(:,(1+U+1):(1+UV))=delAdelRp;
gradA(:,(1+UV+1):(1+UVMon2))=delAdelr0;
gradA(:,(1+UVMon2+1):(1+UVM))=delAdeltheta0;
gradA(:,(1+UVM+1):(1+UVMQon2))=delAdelrp;
gradA(:,(1+UVMQon2+1):(1+UVMQ))=delAdelthetap;

% Sanity checks on gradA
gradA=fixResultNaN(gradA);
if any(any(isinf(gradA)))
  error("gradA has inf!");
endif
max_imag_gradA=max(max(abs(imag(gradA))));
if max_imag_gradA>tol
  error("max(abs(imag(gradA)))(=%g)>tol!",max_imag_gradA);
endif
gradA=real(gradA);
if nargout==2
  return;
endif

%
% Hessian of magnitude response
%

% !!!! OBSCURE CODE WARNING !!!!
%
% We want to convert gradA, delr0factor etc from Nw*Mon2 to Nw*Mon2*Mon2 
% or Nw*Qon2*Mon2 with the indexes varying in opposite directions. 
%
% 1. Making the del2Adeltheta0delr0 etc sub-matrixes
%  For the hessian, we wish to multiply, say, delAdelrp (which is 
%  Nw*Qon2) by delr0factor (which is Nw*Mon2). delAdelrp must be reshaped
%  to Nw*Qon2*Mon2 with rp varying down the second index (column of the 
%  Qon2*Mon2 matrix for a given w). delr0factor must be reshaped to 
%  Nw*Qon2*Mon2 with kr0 varying down the third index (row of the Qon2*Mon2
%  matrix for a given w).
%
%  Suppose Mon2=4, Qon2=3, Nw=8, r=kron(1:Mon2,ones(Nw,1)) and
%  t=kron(1:Qon2,ones(Nw,1)). We wish to reshape r to 
%  Nw*Qon2*Mon2 with each Qon2*Mon2 matrix becoming  
%  [1 2 3 4; 1 2 3 4; 1 2 3 4] and reshape t to Nw*Qon2*Mon2 with 
%  each Qon2*Mon2 matrix becoming [1 1 1 1; 2 2 2 2; 3 3 3 3;]. 
%  Do this with
%
%    t=permute(reshape(kron(t',ones(1,Mon2)),Qon2,Mon2,Nw),[3,1,2])
%    r=permute(reshape(kron(r',ones(Qon2,1)),Qon2,Mon2,Nw),[3,1,2])
%
%  t' and r' are used because reshape takes elements down columns. 
%  Here for del2Adelrpdelr0 the delr0factor indexes like r and delAdelrp 
%  indexes like t.
%
% 2. Making the diagonal correction matrixes.
%  Some sub-matrixes have a correction term on the diagonal. Suppose
%  a Nw*Qon2 matrix is x=[1 2 3; 4 5 6; 7 8 9] then we want a 
%  Nw*Qon2*Qon2 matrix with the first Qon2*Qon2 matrix
%  [ 1 0 0; 0 2 0; 0 0 3] etc. This can be contrived by multiplication
%  with m=[1 0 0 0 0 0 0 0 0; 0 0 0 0 1 0 0 0 0; 0 0 0 0 0 0 0 0 1] as 
%
%    m=zeros(Qon2,Qon2,Qon2)
%    for k=1:Qon2, m(k,k,k)=1; endfor
%    m=reshape(m,Qon2,Qon2*Qon2)
%
%  or avoiding the for loop
%
%    m=eye((Qon2+1)*Qon2, Qon2)
%    m=reshape(m, Qon2, (Qon2+1)*Qon2)
%    m=m(:,1:(Qon2*Qon2))
%
%  Then:
%    y=permute(reshape((x*m)',Qon2,Qon2,Nw),[3,1,2])
%
%  So for y(1,:,:) (collapsing the Octave output somewhat):
%    ans(:,:,1) =  1   0   0
%    ans(:,:,2) =  0   2   0
%    ans(:,:,3) =  0   0   3


% Utility matrixes for the diagonal corrections
DU=zeros(U,U,U);
for k=1:U, DU(k,k,k)=1; endfor
DU=reshape(DU,U,U*U);
DV=zeros(V,V,V);
for k=1:V, DV(k,k,k)=1; endfor
DV=reshape(DV,V,V*V);
DMon2=zeros(Mon2,Mon2,Mon2);
for k=1:Mon2, DMon2(k,k,k)=1; endfor
DMon2=reshape(DMon2,Mon2,Mon2*Mon2);
DQon2=zeros(Qon2,Qon2,Qon2);
for k=1:Qon2, DQon2(k,k,k)=1; endfor
DQon2=reshape(DQon2,Qon2,Qon2*Qon2);


% Common factor for kR0 has dimensions (Nw,U,U), (Nw,V,U), 
% (Nw,Mon2,U) or (Nw,Qon2,U)
delR0factor=(kR0-coswZ)./numAR0;
hdelR0Ufactor=...
permute(reshape(kron(delR0factor',ones(U,1)),U,U,Nw),[3,1,2]);
hdelR0Vfactor=...
permute(reshape(kron(delR0factor',ones(V,1)),V,U,Nw),[3,1,2]);
hdelR0Mfactor=...
permute(reshape(kron(delR0factor',ones(Mon2,1)),Mon2,U,Nw),[3,1,2]);
hdelR0Qfactor=...
permute(reshape(kron(delR0factor',ones(Qon2,1)),Qon2,U,Nw),[3,1,2]);

% hdel2AdelR02
hdelAdelR0=...
permute(reshape(kron(delAdelR0',ones(1,U)),U,U,Nw),[3,1,2]);
hdel2AdelR02=hdelAdelR0.*hdelR0Ufactor;
% Add correction on diagonal
delR0Cfactor=(kron(A,ones(1,U)).*((sin(wZ)./numAR0).^2)) - ...
    (delAdelR0.*delR0factor);
hdelR0Cfactor=permute(reshape((delR0Cfactor*DU)',U,U,Nw),[3,1,2]);
hdel2AdelR02=hdel2AdelR02+hdelR0Cfactor;

% hdel2AdelRpdelR0
hdelAdelRpVU=...
permute(reshape(kron(delAdelRp',ones(1,U)),V,U,Nw),[3,1,2]);
hdel2AdelRpdelR0=hdelAdelRpVU.*hdelR0Vfactor;

% hdel2Adelr0delR0
hdelAdelr0MU=...
permute(reshape(kron(delAdelr0',ones(1,U)),Mon2,U,Nw),[3,1,2]);
hdel2Adelr0delR0=hdelAdelr0MU.*hdelR0Mfactor;

% hdel2Adeltheta0delR0
hdelAdeltheta0MU=...
permute(reshape(kron(delAdeltheta0',ones(1,U)),Mon2,U,Nw),[3,1,2]);
hdel2Adeltheta0delR0=hdelAdeltheta0MU.*hdelR0Mfactor;

% hdel2AdelrpdelR0
hdelAdelrpQU=...
permute(reshape(kron(delAdelrp',ones(1,U)),Qon2,U,Nw),[3,1,2]);
hdel2AdelrpdelR0=hdelAdelrpQU.*hdelR0Qfactor;

% hdel2AdelthetapdelR0
hdelAdelthetapQU=...
permute(reshape(kron(delAdelthetap',ones(1,U)),Qon2,U,Nw),[3,1,2]);
hdel2AdelthetapdelR0=hdelAdelthetapQU.*hdelR0Qfactor;


% Common factor for kRp has dimensions (Nw,U,V), (Nw,V,V), 
% (Nw,Mon2,V) or (Nw,Qon2,V)
kRp2s1Rps1coswP=kRp2s1-(kRps1.*kcoswP);
delRpfactor=sum(kRp2s1Rps1coswP./denomARp,3);
hdelRpUfactor=...
permute(reshape(kron(delRpfactor',ones(U,1)),U,V,Nw),[3,1,2]);
hdelRpVfactor=...
permute(reshape(kron(delRpfactor',ones(V,1)),V,V,Nw),[3,1,2]);
hdelRpMfactor=...
permute(reshape(kron(delRpfactor',ones(Mon2,1)),Mon2,V,Nw),[3,1,2]);
hdelRpQfactor=...
permute(reshape(kron(delRpfactor',ones(Qon2,1)),Qon2,V,Nw),[3,1,2]);

% hdel2AdelRp2
hdelAdelRp=permute(reshape(kron(delAdelRp',ones(1,V)),V,V,Nw),[3,1,2]);
hdel2AdelRp2=-s*hdelAdelRp.*hdelRpVfactor;
% Add correction on diagonal
Rps2=zeros(size(Rp));
Rps2(iRpnz)=Rp(iRpnz).^(s-2);
kRps2=kron(ones(Nw,1),Rps2);
kRps2=reshape(kron(ones(1,R),kRps2),Nw,V,R);
kRp3s=kRp2s.*kRps;
kcoswP2=kcoswP.^2;
delRpCfactor=kRp3s+(s-3)*kRp2s.*kcoswP+(2*kcoswP2-2*s+1).*kRps+(s-1)*kcoswP;
delRpCfactor=kRps2.*delRpCfactor./(denomARp.^2);
delRpCfactor=sum(delRpCfactor,3);
hdelRpCfactor=permute(reshape((delRpCfactor*DV)',V,V,Nw),[3,1,2]);
AV=permute(reshape(kron(A',ones(V)),V,V,Nw),[3,1,2]);
hdel2AdelRp2=hdel2AdelRp2 + (s*AV.*hdelRpCfactor);

% hdel2Adelr0delRp
hdelAdelr0MV=...
permute(reshape(kron(delAdelr0',ones(1,V)),Mon2,V,Nw),[3,1,2]);
hdel2Adelr0delRp=-s*hdelAdelr0MV.*hdelRpMfactor;

% hdel2Adeltheta0delRp
hdelAdeltheta0MV=...
permute(reshape(kron(delAdeltheta0',ones(1,V)),Mon2,V,Nw),[3,1,2]);
hdel2Adeltheta0delRp=-s*hdelAdeltheta0MV.*hdelRpMfactor;

% hdel2AdelrpdelRp
hdelAdelrpQV=...
permute(reshape(kron(delAdelrp',ones(1,V)),Qon2,V,Nw),[3,1,2]);
hdel2AdelrpdelRp=-s*hdelAdelrpQV.*hdelRpQfactor;

% hdel2AdelthetapdelRp
hdelAdelthetapQV=...
permute(reshape(kron(delAdelthetap',ones(1,V)),Qon2,V,Nw),[3,1,2]);
hdel2AdelthetapdelRp=-s*hdelAdelthetapQV.*hdelRpQfactor;


% Common factor for kr0 has dimensions (Nw,Mon2,Mon2) or (Nw,Qon2,Mon2)
delr0factor=((kr0-cosw0Ptheta0)./numAzplus)+((kr0-cosw0Mtheta0)./numAzminus);
hdelr0Mfactor=...
permute(reshape(kron(delr0factor',ones(Mon2,1)),Mon2,Mon2,Nw),[3,1,2]);
hdelr0Qfactor=...
permute(reshape(kron(delr0factor',ones(Qon2,1)),Qon2,Mon2,Nw),[3,1,2]);

% hdel2Adelr02
hdelAdelr0=...
permute(reshape(kron(delAdelr0',ones(1,Mon2)),Mon2,Mon2,Nw),[3,1,2]);
hdel2Adelr02=hdelAdelr0.*hdelr0Mfactor;
% Add correction on diagonal
delr0Cfactor=(2*(sinw0Ptheta0./numAzplus).^2)-(1./numAzplus)+ ...
    (2*(sinw0Mtheta0./numAzminus).^2)-(1./numAzminus);
hdelr0Cfactor=permute(reshape((delr0Cfactor*DMon2)',Mon2,Mon2,Nw),[3,1,2]);
AMon2=permute(reshape(kron(A',ones(Mon2)),Mon2,Mon2,Nw),[3,1,2]);
hdel2Adelr02=hdel2Adelr02 + (AMon2.*hdelr0Cfactor);


% hdel2Adeltheta0delr0
hdelAdeltheta0=...
permute(reshape(kron(delAdeltheta0',ones(1,Mon2)),Mon2,Mon2,Nw),[3,1,2]);
hdel2Adeltheta0delr0=hdelAdeltheta0.*hdelr0Mfactor;
% Add correction on diagonal
deltheta0delr0Cfactor=(1-kr02).* ...
    ((sinw0Ptheta0./(numAzplus.^2))-(sinw0Mtheta0./(numAzminus.^2)));
hdeltheta0delr0Cfactor= ...
permute(reshape((deltheta0delr0Cfactor*DMon2)',Mon2,Mon2,Nw),[3,1,2]);
hdel2Adeltheta0delr0=hdel2Adeltheta0delr0+(AMon2.*hdeltheta0delr0Cfactor);


% hdel2Adelrpdelr0
hdelAdelrpQM=...
permute(reshape(kron(delAdelrp',ones(1,Mon2)),Qon2,Mon2,Nw),[3,1,2]);
hdel2Adelrpdelr0=hdelAdelrpQM.*hdelr0Qfactor;


% hdel2Adelthetapdelr0
hdelAdelthetapQM=...
permute(reshape(kron(delAdelthetap',ones(1,Mon2)),Qon2,Mon2,Nw),[3,1,2]);
hdel2Adelthetapdelr0=hdelAdelthetapQM.*hdelr0Qfactor;


% Common factor for theta0 has dimensions (Nw,Mon2,Mon2)
deltheta0factor=(kr0.*sinw0Ptheta0./numAzplus)-(kr0.*sinw0Mtheta0./numAzminus);
hdeltheta0Mfactor=...
permute(reshape(kron(deltheta0factor',ones(Mon2,1)),Mon2,Mon2,Nw),[3,1,2]);
hdeltheta0Qfactor=...
permute(reshape(kron(deltheta0factor',ones(Qon2,1)),Qon2,Mon2,Nw),[3,1,2]);


% hdel2Adeltheta02
hdelAdeltheta0=...
permute(reshape(kron(delAdeltheta0',ones(1,Mon2)),Mon2,Mon2,Nw),[3,1,2]);
hdel2Adeltheta02=hdelAdeltheta0.*hdeltheta0Mfactor;
% Add correction on diagonal
deltheta0Cfactor= ...
    ((((kr0+(kr03)).*cosw0Ptheta0)-(2*(kr02)))./(numAzplus.^2)) + ...
    ((((kr0+(kr03)).*cosw0Mtheta0)-(2*(kr02)))./(numAzminus.^2));
hdeltheta0Cfactor= ...
permute(reshape((deltheta0Cfactor*DMon2)',Mon2,Mon2,Nw),[3,1,2]);
hdel2Adeltheta02=hdel2Adeltheta02 + (AMon2.*hdeltheta0Cfactor);


% hdel2Adelrpdeltheta0
hdel2Adelrpdeltheta0=hdelAdelrpQM.*hdeltheta0Qfactor;


% hdel2Adelthetapdeltheta0
hdel2Adelthetapdeltheta0=hdelAdelthetapQM.*hdeltheta0Qfactor;


% Common factor for krp has dimensions (Nw,Qon2,Qon2)
krp2s1rps1coswpPsthetap=krp2s1-(krps1.*kcoswpPsthetap);
krp2s1rps1coswpMsthetap=krp2s1-(krps1.*kcoswpMsthetap);
delrpfactor=sum((krp2s1rps1coswpPsthetap./denomAplus)+ ...
                (krp2s1rps1coswpMsthetap./denomAminus),3);
hdelrpQfactor=...
permute(reshape(kron(delrpfactor',ones(Qon2,1)),Qon2,Qon2,Nw),[3,1,2]);

% hdel2Adelrp2
hdelAdelrp=...
permute(reshape(kron(delAdelrp',ones(1,Qon2)),Qon2,Qon2,Nw),[3,1,2]);
hdel2Adelrp2= -s*hdelAdelrp.*hdelrpQfactor;
% Add correction on diagonal
rps2=zeros(size(rp));
rps2(irpnz)=rp(irpnz).^(s-2);
krps2=kron(ones(Nw,1),rps2);
krps2=reshape(kron(ones(1,R),krps2),Nw,Qon2,R);
krp2s2=krps2.*krps;
delrpCfactor=(((2*s-1)*krp2s2-(s-1)*krps2.*kcoswpMsthetap)./denomAminus) - ...
             (2*s*(krp2s1rps1coswpMsthetap./denomAminus).^2) + ...
             (((2*s-1)*krp2s2-(s-1)*krps2.*kcoswpPsthetap)./denomAplus) - ...
             (2*s*(krp2s1rps1coswpPsthetap./denomAplus).^2);
delrpCfactor=sum(delrpCfactor,3);
hdelrpCfactor=permute(reshape((delrpCfactor*DQon2)',Qon2,Qon2,Nw),[3,1,2]);
AQon2=permute(reshape(kron(A',ones(Qon2)),Qon2,Qon2,Nw),[3,1,2]);
hdel2Adelrp2=hdel2Adelrp2 - (s*AQon2.*hdelrpCfactor);

% hdel2Adelthetapdelrp
hdelAdelthetap= ...
permute(reshape(kron(delAdelthetap',ones(1,Qon2)),Qon2,Qon2,Nw),[3,1,2]);
hdel2Adelthetapdelrp= -s*hdelAdelthetap.*hdelrpQfactor;
% Add correction on diagonal
delthetapdelrpCfactor=(ksinwpPsthetap.* ...
    ((1./denomAplus)-((2*krp.*krp2s1rps1coswpPsthetap)./(denomAplus.^2)))) - ...
    (ksinwpMsthetap.* ...
     ((1./denomAminus)-((2*krp.*krp2s1rps1coswpMsthetap)./(denomAminus.^2))));
delthetapdelrpCfactor=delthetapdelrpCfactor.*krps1*s;
delthetapdelrpCfactor=sum(delthetapdelrpCfactor,3);
hdelthetapdelrpCfactor= ...
permute(reshape((delthetapdelrpCfactor*DQon2)',Qon2,Qon2,Nw),[3,1,2]);
hdel2Adelthetapdelrp=hdel2Adelthetapdelrp - (s*AQon2.*hdelthetapdelrpCfactor);

% Common factor for thetap has dimensions (Nw,Qon2,Qon2)
delthetapfactor=sum(krps.*((ksinwpPsthetap./denomAplus)- ...
                           (ksinwpMsthetap./denomAminus)),3);
hdelthetapQfactor= ...
permute(reshape(kron(delthetapfactor',ones(Qon2,1)),Qon2,Qon2,Nw),[3,1,2]);

% hdel2Adelthetap2
hdel2Adelthetap2= -s*hdelAdelthetap.*hdelthetapQfactor;
% Add correction on diagonal
delthetapCfactor=(kcoswpPsthetap./denomAplus) - ...
             (2*krps.*((ksinwpPsthetap./denomAplus).^2)) + ...
             (kcoswpMsthetap./denomAminus) - ...
             (2*krps.*((ksinwpMsthetap./denomAminus).^2));
delthetapCfactor=delthetapCfactor.*krps*s;
delthetapCfactor=sum(delthetapCfactor,3);
hdelthetapCfactor= ...
permute(reshape((delthetapCfactor*DQon2)',Qon2,Qon2,Nw),[3,1,2]);
hdel2Adelthetap2=hdel2Adelthetap2 - (s*AQon2.*hdelthetapCfactor);


% Make the Hessian of the magnitude response
hessA=zeros(Nw,1+UVMQ,1+UVMQ);

% K column
hessA(:,(1+1):(1+UVMQ),1)=gradA(:,(1+1):(1+UVMQ))/K;

% delAdelR0 column
hessA(:,(1+1):(1+U),(1+1):(1+U))=hdel2AdelR02;
hessA(:,(1+U+1):(1+UV),(1+1):(1+U))=hdel2AdelRpdelR0;
hessA(:,(1+UV+1):(1+UVMon2),(1+1):(1+U))=hdel2Adelr0delR0;
hessA(:,(1+UVMon2+1):(1+UVM),(1+1):(1+U))=hdel2Adeltheta0delR0;
hessA(:,(1+UVM+1):(1+UVMQon2),(1+1):(1+U))=hdel2AdelrpdelR0;
hessA(:,(1+UVMQon2+1):(1+UVMQ),(1+1):(1+U))=hdel2AdelthetapdelR0;

% delAdelRp column
hessA(:,(1+U+1):(1+UV),(1+U+1):(1+UV))=hdel2AdelRp2;
hessA(:,(1+UV+1):(1+UVMon2),(1+U+1):(1+UV))=hdel2Adelr0delRp;
hessA(:,(1+UVMon2+1):(1+UVM),(1+U+1):(1+UV))=hdel2Adeltheta0delRp;
hessA(:,(1+UVM+1):(1+UVMQon2),(1+U+1):(1+UV))=hdel2AdelrpdelRp;
hessA(:,(1+UVMQon2+1):(1+UVMQ),(1+U+1):(1+UV))=hdel2AdelthetapdelRp;

% delAdelr0 column
hessA(:,(1+UV+1):(1+UVMon2),(1+UV+1):(1+UVMon2))=hdel2Adelr02;
hessA(:,(1+UVMon2+1):(1+UVM),(1+UV+1):(1+UVMon2))=hdel2Adeltheta0delr0;
hessA(:,(1+UVM+1):(1+UVMQon2),(1+UV+1):(1+UVMon2))=hdel2Adelrpdelr0;
hessA(:,(1+UVMQon2+1):(1+UVMQ),(1+UV+1):(1+UVMon2))=hdel2Adelthetapdelr0;

% delAdeltheta0 column
hessA(:,(1+UVMon2+1):(1+UVM),(1+UVMon2+1):(1+UVM))=hdel2Adeltheta02;
hessA(:,(1+UVM+1):(1+UVMQon2),(1+UVMon2+1):(1+UVM))=hdel2Adelrpdeltheta0;
hessA(:,(1+UVMQon2+1):(1+UVMQ),(1+UVMon2+1):(1+UVM))=hdel2Adelthetapdeltheta0;

% delAdelrp column
hessA(:,(1+UVM+1):(1+UVMQon2),(1+UVM+1):(1+UVMQon2))=hdel2Adelrp2;
hessA(:,(1+UVMQon2+1):(1+UVMQ),(1+UVM+1):(1+UVMQon2))=hdel2Adelthetapdelrp;

% delAdelthetap column
hessA(:,(1+UVMQon2+1):(1+UVMQ),(1+UVMQon2+1):(1+UVMQ))=hdel2Adelthetap2;


% K row
hessA(:,1,(1+1):(1+UVMQ))=gradA(:,(1+1):(1+UVMQ))/K;

% delAdelR0 row
hessA(:,(1+1):(1+U),(1+U+1):(1+UV))= ...
    permute(hdel2AdelRpdelR0,[1, 3, 2]);
hessA(:,(1+1):(1+U),(1+UV+1):(1+UVMon2))= ...
    permute(hdel2Adelr0delR0,[1, 3, 2]);
hessA(:,(1+1):(1+U),(1+UVMon2+1):(1+UVM))= ...
    permute(hdel2Adeltheta0delR0,[1, 3, 2]);
hessA(:,(1+1):(1+U),(1+UVM+1):(1+UVMQon2))= ...
    permute(hdel2AdelrpdelR0,[1, 3, 2]);
hessA(:,(1+1):(1+U),(1+UVMQon2+1):(1+UVMQ))= ...
    permute(hdel2AdelthetapdelR0,[1, 3, 2]);

% delAdelRp row
hessA(:,(1+U+1):(1+UV),(1+UV+1):(1+UVMon2))= ...
    permute(hdel2Adelr0delRp,[1, 3, 2]);
hessA(:,(1+U+1):(1+UV),(1+UVMon2+1):(1+UVM))= ...
    permute(hdel2Adeltheta0delRp,[1, 3, 2]);
hessA(:,(1+U+1):(1+UV),(1+UVM+1):(1+UVMQon2))= ...
    permute(hdel2AdelrpdelRp,[1, 3, 2]);
hessA(:,(1+U+1):(1+UV),(1+UVMQon2+1):(1+UVMQ))= ...
    permute(hdel2AdelthetapdelRp,[1, 3, 2]);

% delAdelr0 row
hessA(:,(1+UV+1):(1+UVMon2),(1+UVMon2+1):(1+UVM))= ...
    permute(hdel2Adeltheta0delr0,[1, 3, 2]);
hessA(:,(1+UV+1):(1+UVMon2),(1+UVM+1):(1+UVMQon2))= ...
    permute(hdel2Adelrpdelr0,[1, 3, 2]);
hessA(:,(1+UV+1):(1+UVMon2),(1+UVMQon2+1):(1+UVMQ))= ...
    permute(hdel2Adelthetapdelr0,[1, 3, 2]);

% delAdeltheta0 row
hessA(:,(1+UVMon2+1):(1+UVM),(1+UVM+1):(1+UVMQon2))= ...
    permute(hdel2Adelrpdeltheta0, [1, 3, 2]);
hessA(:,(1+UVMon2+1):(1+UVM),(1+UVMQon2+1):(1+UVMQ))= ...
    permute(hdel2Adelthetapdeltheta0, [1, 3, 2]);

% delAdelrp row
hessA(:,(1+UVM+1):(1+UVMQon2),(1+UVMQon2+1):(1+UVMQ))= ...
    permute(hdel2Adelthetapdelrp, [1, 3, 2]);


% Remove a redundant frequency dimension
sizeH=size(hessA);
if sizeH(1) == 1
  hessA=reshape(hessA,sizeH(2),sizeH(3));
endif

% Sanity checks on hessA
hessA=fixResultNaN(hessA);
if any(any(any(isinf(hessA))))
  error("hessA has inf!");
endif
max_imag_hessA=max(max(max(abs(imag(hessA)))));
if max_imag_hessA>tol
  error("max(max(abs(imag(hessA))))(=%g)>tol!",max_imag_hessA);
endif
hessA=real(hessA);

endfunction
