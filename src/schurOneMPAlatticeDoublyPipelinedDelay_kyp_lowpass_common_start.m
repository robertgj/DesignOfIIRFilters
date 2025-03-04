% schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_start.m
% Copyright (C) 2024-2025 Robert G. Jenssen

% Filter specification
tol=5e-6,N=5,DD=4,fap=0.10,Wap=0.1,fas=0.20,Was=200

% Frequency points
nplot=1000;
fplot=0.5*(0:(nplot-1))'/nplot;
wplot=2*pi*fplot;
nap=ceil(fap*nplot/0.5)+1;
nas=floor(fas*nplot/0.5)+1;

% Frequency vectors
Ad=[ones(nap,1);zeros(nplot-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(nplot-nas+1,1)];
Td=[];
Wt=[];

% Initial allpass filter
Da0=schurOneMPAlatticeDelay_wise_lowpass(N,DD,fap,fas,Was);
print_polynomial(Da0,"Da0");

% Calculate initial response
[Ha0,wplot]=freqz(flipud(Da0),Da0,nplot);
NDD=[zeros(DD,1);1];
[HDD,wplot]=freqz(NDD,1,nplot);
H0_p=(Ha0-HDD)/2;
logH0_p=20*log10(abs(H0_p));
H0_s=(Ha0+HDD)/2;
logH0_s=20*log10(abs(H0_s));

[Ta0,wplot]=delayz(flipud(Da0(:)),Da0(:),nplot);
TDD=DD*ones(size(Ta0));
T0=(Ta0+TDD)/2;

% Plot initial response
ax=plotyy(fplot,logH0_s,fplot,logH0_s);
ylabel("Amplitude response(dB)");
xlabel("Frequency");
axis(ax(1),[0 0.5 -1 0]);
axis(ax(2),[0 0.5 -60 -35]);
grid("on");
tstr=sprintf("Initial response of parallel all-pass filter and delay : \
N=%d, DD=%d",N, DD);
title(tstr);
print(strcat(strf,"_initial_response"),"-dpdflatex");
close
%
% Initial filter z^-2 parallel doubly pipelined all-pass and delay implementation
%
DaDD=[zeros((2*DD)+2,1);1];
[ADD,BDD,CDD,DDD]=tf2Abcd(DaDD,1);
nDD=rows(ADD);
% Initial filter reflection coefficients
k0=schurdecomp(Da0);
print_polynomial(k0,"k0");
% Initial filter z^-2 doubly pipelined state variable all-pass implementation
[apAi,apBi,apCi,apDi,apA0,apAm] = schurOneMAPlatticeDoublyPipelined2Abcd(k0); 
napA=rows(apAi);
A=[[apAi,zeros(napA,nDD)];[zeros(nDD,napA),ADD]];
n=rows(A);
if n~=((2*N)+2+(2*DD)+2)
  error("n~=((2*N)+2+(2*DD)+2)");
endif
B=[apBi;BDD];
C_p=0.5*[apCi,-CDD];
C_s=0.5*[apCi, CDD];
D=[apDi+DDD];
% Sanity checks on the z^-2 doubly pipelined implementation
nplot2=2*nplot;
fplot2=0.5*(0:(nplot-1))'/nplot2;
wplot2=2*pi*fplot2;
H02_p=Abcd2H(wplot2,A,B,C_p,D);
logH02_p=20*log10(abs(H02_p));
H02_s=Abcd2H(wplot2,A,B,C_s,D);
logH02_s=20*log10(abs(H02_s));
if max(abs(abs(H0_p)-abs(H02_p))) > 20*eps
  error("max(abs(abs(H0_p)-abs(H02_p))) > 20*eps");
endif
if max(abs(abs(H0_s)-abs(H02_s))) > 20*eps
  error("max(abs(abs(H0_s)-abs(H02_s))) > 20*eps");
endif
uP_s=((unwrap(arg(H02_s)+(wplot2*((2*DD)+2)))/pi)- ...
      ((unwrap(arg(H0_s)+wplot*DD)/pi)))(1:nap);
if max(abs(uP_s)) > 20*eps
  error("max(abs(uP_s)) > 20*eps");
endif
% Calculate initial Asq, Esq and gradient
k1=ones(length(k0),1);kDD=zeros(DD,1);kDD1=ones(DD,1);diff=false;
Asq=schurOneMPAlatticeAsq(wplot,k0,k1,k1,kDD,kDD1,kDD1);
printf("10*log10(min(Asq))(pass)=%g,10*log10(max(Asq))(stop)=%g\n", ...
        10*log10(min(Asq(1:nap))),10*log10(max(Asq(nas:end))));
[Esq,gradEsq,diagHessEsq,hessEsq]= ...
  schurOneMPAlatticeEsq(k0,k1,k1,kDD,kDD1,kDD1,diff,wplot,Ad,Wa);
printf("Esq=%g\n",Esq);
print_polynomial(gradEsq(1:N),"gradEsq","%g");
print_polynomial(diagHessEsq(1:N),"diagHessEsq","%g");
 % Initialise BFGS update
last_gradEsq=zeros(size(gradEsq(1:N)));
W=diag(diagHessEsq(1:N));
invW=diag(1./diagHessEsq(1:N));

%
% Find initial values for Esq_p,Esq_s,P_p,P_p,Q_p,Q_s,XYZ_p,XYZ_s
%
Phi=[-1,0;0,1];

% Pass band with z^-2 (frequencies scaled by 0.5)
Psi_p=[0, 1; 1,-2*cos(2*pi*fap/2)];
Esq_p=tol*ceil((max(abs(H0_p(1:nap)))^2)/tol);
dP_p=sdpvar(n,n,"symmetric","real");
dQ_p=sdpvar(n,n,"symmetric","real");
if 0
  dXYZ_p=sdpvar((2*n)+1,n,"full","real");
else
  dX_p=sdpvar(n,n,"symmetric","real");
  dY_p=sdpvar(n,n,"symmetric","real");
  dZ_p=sdpvar(1,n,"full","real");
  dXYZ_p=[dX_p;dY_p;dZ_p];
endif
L_p=(kron(Phi,dP_p)+kron(Psi_p,dQ_p));
U_p=[[-eye(n),A,B,zeros(n,1)];[zeros(1,n),C_p,D,-1]]';
V_p=[[dXYZ_p,zeros((2*n)+1,1)];[zeros(1,n),1]]';
UV_p=U_p*V_p;
F_p=[[L_p,zeros(2*n,2)]; [zeros(2,2*n),diag([-Esq_p,1])]] + UV_p+(UV_p');

% Stop band with z^-2 (frequencies scaled by 0.5)
f1=fas/2;
f2=(1-fas)/2;
wc_s=2*pi*(f2+f1)/2;
wm_s=2*pi*(f2-f1)/2;
ec_s=exp(i*wc_s);
Psi_s=[0,conj(ec_s);ec_s,-2*cos(wm_s)];
Esq_s=tol*ceil((max(abs(H0_s(nas:end)))^2)/tol);
dP_s=sdpvar(n,n,"symmetric","real");
dQ_s=sdpvar(n,n,"symmetric","real");
if 0
  dXYZ_s=sdpvar((2*n)+1,n,"full","real");
else
  dX_s=sdpvar(n,n,"symmetric","real");
  dY_s=sdpvar(n,n,"symmetric","real");
  dZ_s=sdpvar(1,n,"full","real");
  dXYZ_s=[dX_s;dY_s;dZ_s];
endif
L_s=(kron(Phi,dP_s)+kron(Psi_s,dQ_s));
U_s=[[-eye(n),A,B,zeros(n,1)];[zeros(1,n),C_s,D,-1]]';
V_s=[[dXYZ_s,zeros((2*n)+1,1)];[zeros(1,n),1]]';
UV_s=U_s*V_s;
F_s=[[L_s,zeros(2*n,2)]; [zeros(2,2*n),diag([-Esq_s,1])]] + UV_s+(UV_s');

% Solve for the initial SDP variables
Constraints=[ F_p<=tol, dQ_p>=0, F_s<=tol, dQ_s>=0 ];
Options=sdpsettings("solver","sedumi","sedumi.eps",tol);
Objective=[];
sol=optimize(Constraints,Objective,Options)
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
printf("Initial Esq_p=%g, Esq_s=%g\n\n",Esq_p,Esq_s);

% Initialise pass band constraints
P_p=value(dP_p);
Q_p=value(dQ_p);
XYZ_p=value(dXYZ_p);

% Initialise stop band constraints
P_s=value(dP_s);
Q_s=value(dQ_s);
XYZ_s=value(dXYZ_s);

% Reflection coefficients
k=k0;
dk=sdpvar(1,N,"full","real");

% State transition matrix
dapA=zeros(napA);
for mm=1:N,
  dapA=dapA+(dk(mm)*apAm{mm});
endfor
dA=[[dapA,zeros(napA,nDD)];[zeros(nDD,napA),zeros(nDD)]];

% Pass band constraints
dEsq_p=sdpvar(1,1,"full","real");

% Stop band constraints
dEsq_s=sdpvar(1,1,"full","real");

% Make a vector of SDP decision variables
dz=[dEsq_p;dEsq_s;vec(dk); ...
    vec(dP_p);vec(dQ_p);vec(dXYZ_p); ...
    vec(dP_s);vec(dQ_s);vec(dXYZ_s)];

% Store norm(dk) and Esq in a list
list_norm_dk=[];
list_Esq=[];
list_Asq_min=[];
list_Asq_max=[];
list_k=cell();
