% schurOneMlattice_kyp_Dinh_lowpass_R2_test.m
%
% Design of an R=2 one-multiplier Schur lattice low-pass filter with
% BMI constraints derived from the KYP lemma solved by the convex
% approximation of Dinh et al. using YALMIP.
%
% For tp=nN-3:
%  nN     rows(A_s)   rows(F_s)     rows(A_z)         rows(F_z)
%         (3nN/2)-1              (3nN/2)-1+(nN-3)   
%   8        11          24            16               34
%  10        14          30            21               44
%  12        17          36            26               54
%  14        20          42            31               64
%  16        23          48            36               74
% 
% See:
% [1] "Generalised KYP Lemma: Unified Frequency Domain Inequalities With Design
%      Applications", T. Iwasaki and S. Hara, IEEE Trans. Control,
%      Vol. 50 No. 1, January 2005, pp 41-59
% [2] "Combining Convex–Concave Decompositions and Linearization Approaches for
%      Solving BMIs, With Application to Static Output Feedback", Dinh et al.
%      July, 2011. Available at:
%      https://set.kuleuven.be/optec/Software/softwarefiles/bmipaper
%
% Copyright (C) 2025 Robert G. Jenssen

test_common;

pkg load optim;

strf="schurOneMlattice_kyp_Dinh_lowpass_R2_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Start
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Filter specification
maxiter_kyp=25,tol=5e-5,k_max=0.999
nN=8,R=2,fap=0.1,fas=0.2,Was=1,tp=5

if rem(nN,2)
  error("Expect nN even!");
endif

% Frequency points
n=1000;
f=0.5*(0:(n-1))'/n;
w=2*pi*f;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Frequency vectors
wa=w;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Wa=[ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Unconstrained minimisation
[n0,d0R]=tf_wise_lowpass(nN,R,fap,fas,Was);

% Plot the initial response
H0=freqz(n0,d0R,w);
T0=delayz(n0,d0R,w);
subplot(211);
[ax,h1,h2]=plotyy(f,20*log10(abs(H0)),f,20*log10(abs(H0)));
axis(ax(1),[0 0.5 -0.2 0.2]);
axis(ax(2),[0 0.5 -60 -40]);
ylabel("Amplitude(dB)");
grid("on");
strI=sprintf(["Initial response of tapped Schur lattice filter : ", ...
              "nN=%d, fap=%g, tp=%g, fas=%g"], nN,fap,tp,fas);
title(strI);
subplot(212);
plot(w*0.5/pi,T0);
axis([0 0.5 0 20]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
zticks([]);
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

% Plot the initial filter poles and zeros
zplane(roots(n0),roots(d0R));
strP=sprintf(["Pole-zero plot of initial tapped Schur lattice filter : ", ...
              "nN=%d, fap=%g, tp=%g, fas=%g"], ...
             nN,fap,tp,fas);
title(strP);
grid("on");
zticks([]);
print(strcat(strf,"_initial_pz"),"-dpdflatex");
close

% Find the lattice k0 and c0 coefficients with fixed epsilon0=1
[k0,~,~,c0]=tf2schurOneMlattice(n0,d0R,ones(nN,1));
k0_ones=ones(size(k0));

% Sanity check
Asq0=schurOneMlatticeAsq(w,k0,k0_ones,k0_ones,c0);
if max(abs(sqrt(Asq0)-abs(H0))) > 100*eps
  error("max(abs(sqrt(Asq0)-abs(H0)))(%g*eps) > 100*eps", ...
        max(abs(sqrt(Asq0)-abs(H0)))/eps);
endif

% ABCD corresponds to [A,B;C,D] and ABCDk{m} represents dABCDdk{m}
[A0,B0,C0,D0,~,~,~,~,ABCD0,ABCDk,ABCDc]= ...
  schurOneMR2lattice2Abcd(k0,k0_ones,c0);
Ak=cell(1,nN);
Bk=cell(1,nN);
Ck=cell(1,nN);
Dk=cell(1,nN);
for mm=1:nN,
  Ak{mm}=ABCDk{mm}(1:rows(A0),1:columns(A0));
  Bk{mm}=ABCDk{mm}(1:rows(A0),columns(A0)+1);
  Ck{mm}=ABCDk{mm}(rows(A0)+1,1:columns(A0));
  Dk{mm}=ABCDk{mm}(rows(A0)+1,columns(A0)+1);
endfor
Ac=cell(1,nN+1);
Bc=cell(1,nN+1);
Cc=cell(1,nN+1);
Dc=cell(1,nN+1);
for mm=1:(nN+1),
  Ac{mm}=ABCDc{mm}(1:rows(A0),1:columns(A0));
  Bc{mm}=ABCDc{mm}(1:rows(A0),columns(A0)+1);
  Cc{mm}=ABCDc{mm}(rows(A0)+1,1:columns(A0));
  Dc{mm}=ABCDc{mm}(rows(A0)+1,columns(A0)+1);
endfor
% Sanity check
Acheck=ABCD0(1:rows(A0),1:columns(A0));
Bcheck=ABCD0(1:rows(A0),columns(A0)+1);
Ccheck=ABCD0(rows(A0)+1,1:columns(A0));
Dcheck=ABCD0(rows(A0)+1,columns(A0)+1);
for mm=1:nN,
  Acheck=Acheck+(k0(mm)*Ak{mm});
  Bcheck=Bcheck+(k0(mm)*Bk{mm});
  Ccheck=Ccheck+(k0(mm)*Ck{mm});
  Dcheck=Dcheck+(k0(mm)*Dk{mm});
endfor
for mm=1:(nN+1),
  Acheck=Acheck+(c0(mm)*Ac{mm});
  Bcheck=Bcheck+(c0(mm)*Bc{mm});
  Ccheck=Ccheck+(c0(mm)*Cc{mm});
  Dcheck=Dcheck+(c0(mm)*Dc{mm});
endfor
if max(max(abs(Acheck-A0))) > eps
  error("max(max(abs(Acheck-A0)))(%g*eps) > eps",max(max(abs(Acheck-A0)))/eps);
endif
if max(abs(Bcheck-B0)) > eps
  error("max(abs(Bcheck-B0))(%g*eps) > eps",max(abs(Bcheck-B0))/eps);
endif
if max(abs(Ccheck-C0)) > eps
  error("max(abs(Ccheck-C0))(%g*eps) > eps",max(abs(Ccheck-C0))/eps);
endif
if max(abs(Dcheck-D0)) > eps
  error("max(abs(Dcheck-D0))(%g*eps) > eps",max(abs(Dcheck-D0))/eps);
endif


%
% Initial R=2 Schur one-multiplier lattice lowpass filter implementation
%
% Stop band filter
A_s=A0;
B_s=B0;
C_s=C0;
D_s=D0;
% In the pass-band compare the output to a delay of tp samples
Ndelay=[zeros(tp,1);1];
[Adelay,Bdelay,Cdelay,Ddelay]=tf2Abcd(Ndelay,1);
A_z=[[A0,zeros(rows(A0),columns(Adelay))]; ...
     [zeros(rows(Adelay),columns(A0)),Adelay]];
B_z=[B0;Bdelay];
C_z=[C0,-Cdelay];
D_z=(D0-Ddelay);
% Sanity check on the R=2 Schur one-multiplier lattice lowpass filter
H0_z=Abcd2H(w,A_z,B_z,C_z,D_z);
H0_s=Abcd2H(w,A_s,B_s,C_s,D_s);
if max(abs(abs(H0-H0_s))) > 2e4*eps
  error("max(abs(abs(H0)-abs(H0_s)))(%g*eps) > 2e4*eps", ...
        max(abs(abs(H0-H0_s)))/eps);
endif
if max(abs(H0_s-exp(-j*w*tp)-H0_z)) > 100*eps
  error("max(abs(H0_s-exp(-j*w*tp)-H0_z))(%g*eps) > 100*eps", ...
        max(abs(H0_s-exp(-j*w*tp)-H0_z))/eps);
endif

% Calculate initial Asq, Esq and gradient
Asq=schurOneMlatticeAsq(wa,k0,k0_ones,k0_ones,c0);
printf("10*log10(max(Asq(pass)))=%g dB\n",10*log10(max(Asq(1:nap))));
printf("10*log10(min(Asq(pass)))=%g dB\n",10*log10(min(Asq(1:nap))));
printf("10*log10(max(Asq(stop)))=%g dB\n",10*log10(max(Asq(nas:end))));
[Esq,gradEsq]=schurOneMlatticeEsq(k0,k0_ones,k0_ones,c0,wa,Asqd,Wa);
printf("Esq=%g\n",Esq);
print_polynomial(gradEsq,"gradEsq","%g");

%
% Find initial values for Esq_z,Esq_s,P_z,P_z,Q_z,Q_s,XYZ_z,XYZ_s
%
Phi=[-1,0;0,1];

% Pass band 
Psi_z=[0, 1; 1,-2*cos(2*pi*fap)];
Esq_z=tol*ceil((max(abs(H0_z(1:nap)))^2)/tol);
n_z=rows(A_z);
P_z=sdpvar(n_z,n_z,"symmetric","real");
Q_z=sdpvar(n_z,n_z,"symmetric","real");
dX_z=sdpvar(n_z,n_z,"symmetric","real");
dY_z=sdpvar(n_z,n_z,"symmetric","real");
dZ_z=sdpvar(1,n_z,"full","real");
dXYZ_z=[dX_z;dY_z;dZ_z];
L_z=(kron(Phi,P_z)+kron(Psi_z,Q_z));
U_z=[[-eye(n_z),A_z,B_z,zeros(n_z,1)];[zeros(1,n_z),C_z,D_z,-1]]';
V_z=[[dXYZ_z,zeros((2*n_z)+1,1)];[zeros(1,n_z),1]]';
UV_z=U_z*V_z;
F_z=[[L_z,zeros(2*n_z,2)];  ...
     [zeros(2,2*n_z),diag([-Esq_z,1])]] + UV_z+(UV_z');

% Stop band 
Psi_s=[0,-1;-1,2*cos(2*pi*fas)];
Esq_s=tol*ceil((max(abs(H0_s(nas:end)))^2)/tol);
n_s=rows(A_s);
P_s=sdpvar(n_s,n_s,"symmetric","real");
Q_s=sdpvar(n_s,n_s,"symmetric","real");
dX_s=sdpvar(n_s,n_s,"symmetric","real");
dY_s=sdpvar(n_s,n_s,"symmetric","real");
dZ_s=sdpvar(1,n_s,"full","real");
dXYZ_s=[dX_s;dY_s;dZ_s];
L_s=(kron(Phi,P_s)+kron(Psi_s,Q_s));
U_s=[[-eye(n_s),A_s,B_s,zeros(n_s,1)]; ...
     [zeros(1,n_s),C_s,D_s,-1]]';
V_s=[[dXYZ_s,zeros((2*n_s)+1,1)]; ...
     [zeros(1,n_s),1]]';
UV_s=U_s*V_s;
F_s=[[L_s,zeros(2*n_s,2)]; ...
     [zeros(2,2*n_s),diag([-Esq_s,1])]] + UV_s+(UV_s');

% Solve for the initial SDP variables
Constraints=[ F_z<=tol, Q_z>=0, F_s<=tol, Q_s>=0 ];
Options=sdpsettings("solver","sedumi","sedumi.eps",tol);
Objective=[];
sol=optimize(Constraints,Objective,Options)
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
printf("Initial Esq_z=%g, Esq_s=%g\n\n",Esq_z,Esq_s);

% Initialise pass band constraints
XYZ_z=value(dXYZ_z);

% Initialise stop band constraints
XYZ_s=value(dXYZ_s);

% Initialise lattice SDP variables
% Reflection coefficients
k=k0;
dk=[];
for mm=R:R:nN,
  dk=[dk, 0, sdpvar(1,1,"full","real")];  
endfor
% Tap coefficients
c=c0;
dc=sdpvar(1,nN+1,"full","real");

% State variable Delta ABCD variables
dA=zeros(rows(A0),columns(A0));
dB=zeros(rows(B0),1);
dC=zeros(1,columns(C0));
dD=zeros(1,1);
for mm=1:nN,
  dA=dA+(dk(mm)*Ak{mm});
  dB=dB+(dk(mm)*Bk{mm});
  dC=dC+(dk(mm)*Ck{mm});
  dD=dD+(dk(mm)*Dk{mm});
endfor
for mm=1:(nN+1),
  dA=dA+(dc(mm)*Ac{mm});
  dB=dB+(dc(mm)*Bc{mm});
  dC=dC+(dc(mm)*Cc{mm});
  dD=dD+(dc(mm)*Dc{mm});
endfor
dA_s=dA;
dB_s=dB;
dC_s=dC;
dD_s=dD;
dA_z=[[dA,zeros(rows(dA),columns(Adelay))]; ...
      [zeros(rows(Adelay),columns(dA)),zeros(size(Adelay))]];
dB_z=[dB;zeros(size(Bdelay))];
dC_z=[dC,zeros(size(Cdelay))];
dD_z=dD;

% Pass band constraints
dEsq_z=sdpvar(1,1,"full","real");

% Stop band constraints
dEsq_s=sdpvar(1,1,"full","real");

% Make a vector of SDP decision variables
dkc=[dk,dc];
dz=[dEsq_z;dEsq_s;vec(dk);vec(dc);vec(dXYZ_z);vec(dXYZ_s)];

% Initialise lists of norm(dk), Esq, etc
list_Objective=[];
list_norm_dz=[];
list_norm_dkc=[];
list_Esq=[];
list_Esq_z=[];
list_Esq_s=[];
list_Asq_max_pass=[];
list_Asq_min_pass=[];
list_Asq_max_stop=[];
list_k=cell();
list_c=cell();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Main loop
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for m=1:maxiter_kyp,

  % Constant part of the pass band constraint matrix
  Lzm_z=kron(Phi,P_z)+kron(Psi_z,Q_z);
  Uzm_z=[[-eye(n_z),A_z,B_z,zeros(n_z,1)]; ...
         [zeros(1,n_z),C_z,D_z,-1]];
  Vzm_z=[[XYZ_z,zeros((2*n_z)+1,1)]; ...
         [zeros(1,n_z),1]];
  VplusUzm_z=(Uzm_z+(Vzm_z'))/sqrt(2);
  UminusVzm_z=(Uzm_z-(Vzm_z'))/sqrt(2);
  Fzm_z=[[[[Lzm_z,zeros(2*n_z,2)]; ...
           [zeros(1,2*n_z),-Esq_z,0]; ...
           [zeros(1,(2*n_z)+1),1]],(VplusUzm_z')]; ...
         [VplusUzm_z,-eye(n_z+1)]] - ...
        [[(UminusVzm_z')*UminusVzm_z,zeros(2*(n_z+1),n_z+1)]; ...
         [zeros(n_z+1,2*(n_z+1)),zeros(n_z+1)]];

  % Linear part of the pass band constraint matrix
  gLzm_z=zeros(size(Lzm_z));
  gUzm_z=[[zeros(n_z),dA_z,dB_z,zeros(n_z,1)]; ...
          [zeros(1,n_z),dC_z,dD_z,0]];
  gVzm_z=[[dXYZ_z,zeros((2*n_z)+1,1)]; ...
          [zeros(1,n_z),0]];
  gVplusUzm_z=(gUzm_z+(gVzm_z'))/sqrt(2);
  gUminusVzm_z=(gUzm_z-(gVzm_z'))/sqrt(2);
  gFzm_z=[[[[gLzm_z,zeros(2*n_z,2)]; ...
            [zeros(1,2*n_z),-dEsq_z,0]; ...
            [zeros(1,(2*n_z)+1),0]],(gVplusUzm_z')]; ...
          [gVplusUzm_z,zeros(n_z+1)]] - ...
         [[(gUminusVzm_z')*UminusVzm_z,zeros(2*(n_z+1),n_z+1)]; ...
          [zeros(n_z+1,2*(n_z+1)),zeros(n_z+1)]] - ...
         [[(UminusVzm_z')*gUminusVzm_z,zeros(2*(n_z+1),n_z+1)]; ...
          [zeros(n_z+1,2*(n_z+1)),zeros(n_z+1)]];
  
  % Construct pass band constraint matrix
  bFzm_z=Fzm_z+gFzm_z;

  % Constant part of the stop band constraint matrix
  Lzm_s=kron(Phi,P_s)+kron(Psi_s,Q_s);
  Uzm_s=[[-eye(n_s),A_s,B_s,zeros(n_s,1)]; ...
         [zeros(1,n_s),C_s,D_s,-1]];
  Vzm_s=[[XYZ_s,zeros((2*n_s)+1,1)]; ...
         [zeros(1,n_s),1]];
  VplusUzm_s=(Uzm_s+(Vzm_s'))/sqrt(2);
  UminusVzm_s=(Uzm_s-(Vzm_s'))/sqrt(2);
  Fzm_s=[[[[Lzm_s,zeros(2*n_s,2)]; ...
           [zeros(1,2*n_s),-Esq_s,0]; ...
           [zeros(1,(2*n_s)+1),1]],(VplusUzm_s')]; ...
         [VplusUzm_s,-eye(n_s+1)]] - ...
        [[(UminusVzm_s')*UminusVzm_s,zeros(2*(n_s+1),n_s+1)]; ...
         [zeros(n_s+1,2*(n_s+1)),zeros(n_s+1)]];

  % Linear part of the stop band constraint matrix
  gLzm_s=zeros(size(Lzm_s));
  gUzm_s=[[zeros(n_s),dA_s,dB_s,zeros(n_s,1)]; ...
          [zeros(1,n_s),dC_s,dD_s,0]];
  gVzm_s=[[dXYZ_s,zeros((2*n_s)+1,1)]; ...
          [zeros(1,n_s),0]];
  gVplusUzm_s=(gUzm_s+(gVzm_s'))/sqrt(2);
  gUminusVzm_s=(gUzm_s-(gVzm_s'))/sqrt(2);
  gFzm_s=[[[[gLzm_s,zeros(2*n_s,2)]; ...
            [zeros(1,2*n_s),-dEsq_s,0]; ...
            [zeros(1,(2*n_s)+1),0]],(gVplusUzm_s')]; ...
          [gVplusUzm_s,zeros(n_s+1)]] - ...
         [[(gUminusVzm_s')*UminusVzm_s,zeros(2*(n_s+1),n_s+1)]; ...
          [zeros(n_s+1,2*(n_s+1)),zeros(n_s+1)]] - ...
         [[(UminusVzm_s')*gUminusVzm_s,zeros(2*(n_s+1),n_s+1)]; ...
          [zeros(n_s+1,2*(n_s+1)),zeros(n_s+1)]];

  % Construct stop band constraint matrix
  bFzm_s=Fzm_s+gFzm_s;
  
  if m==1,
    printf("rows(Lzm_z)=%d\n",rows(Lzm_z));
    printf("rows(Fzm_z)=%d\n",rows(Fzm_z));
    printf("rows(Lzm_s)=%d\n",rows(Lzm_s));
    printf("rows(Fzm_s)=%d\n",rows(Fzm_s));
  endif

  % Solve for the SDP variables
  rho=10^floor(log10(norm(Esq_z+Was*Esq_s)));
  printf("Using rho=%g, Esq_z=%g, Esq_s=%g\n",rho,Esq_z,Esq_s);
  Objective=norm(Esq_z+dEsq_z)+Was*norm(Esq_s+dEsq_s)+real(rho*norm(dz)^2);
  Constraints=[ (-k_max)<=(k+dk)<=k_max, ...
                bFzm_z<=tol,    Q_z>=0, ...
                bFzm_s<=tol,    Q_s>=0 ];
  Options=sdpsettings("solver","sdpt3","maxit",200,"gaptol",tol);
  sol=optimize(Constraints,Objective,Options)
  if sol.problem
    error("YALMIP failed");
  endif

  % Sanity checks
  check(Constraints)
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Main loop update
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Update coefficients
  k=k+value(dk);
  c=c+value(dc);

  % Update state transition matrix
  A=ABCD0(1:rows(A0),1:columns(A0));
  B=ABCD0(1:rows(A0),columns(A0)+1);
  C=ABCD0(rows(A0)+1,1:columns(A0));
  D=ABCD0(rows(A0)+1,columns(A0)+1);
  for mm=1:nN,
    A=A+(k(mm)*Ak{mm});
    B=B+(k(mm)*Bk{mm});
    C=C+(k(mm)*Ck{mm});
    D=D+(k(mm)*Dk{mm});
  endfor
  for mm=1:(nN+1),
    A=A+(c(mm)*Ac{mm});
    B=B+(c(mm)*Bc{mm});
    C=C+(c(mm)*Cc{mm});
    D=D+(c(mm)*Dc{mm});
  endfor
  A_s=A;
  B_s=B;
  C_s=C;
  D_s=D;
  A_z=[[A,zeros(rows(A),columns(Adelay))]; ...
       [zeros(rows(Adelay),columns(A)),Adelay]];
  B_z=[B;Bdelay];
  C_z=[C,-Cdelay];
  D_z=(D-Ddelay);

  % Update pass band SDP variables
  Esq_z=Esq_z+value(dEsq_z);
  XYZ_z=XYZ_z+value(dXYZ_z);

  % Update stop band SDP variables
  Esq_s=Esq_s+value(dEsq_s);
  XYZ_s=XYZ_s+value(dXYZ_s);

  printf("m=%d : Esq_z=%g, dEsq_z=%g, Esq_s=%g, dEsq_s=%g\n", ...
         m,Esq_z,value(dEsq_z),Esq_s,value(dEsq_s));

  printf("value(Objective)=%g\n",value(Objective));

  printf("norm(value(dz))=%g\n",norm(value(dz)));
  printf("norm(value(dkc))=%g\n",norm(value(dkc)));

  print_polynomial(value(dk),"dk","%g");
  print_polynomial(k,"k","%g");

  print_polynomial(value(dc),"dc","%g");
  print_polynomial(c,"c","%g");

  Asq=schurOneMlatticeAsq(w,k,k0_ones,k0_ones,c);
  printf("10*log10(max(Asq(pass)))=%g dB\n",10*log10(max(Asq(1:nap))));
  printf("10*log10(min(Asq(pass)))=%g dB\n",10*log10(min(Asq(1:nap))));
  printf("10*log10(max(Asq(stop)))=%g dB\n",10*log10(max(Asq(nas:end))));

  [Esq,gradEsq]=schurOneMlatticeEsq(k,k0_ones,k0_ones,c,wa,Asqd,Wa);
  printf("Esq=%g\n",Esq);
  print_polynomial(gradEsq,"gradEsq","%g");
  printf("\n");

  list_Objective=[list_Objective;value(Objective)];
  list_norm_dz=[list_norm_dz;norm(value(dz))];
  list_norm_dkc=[list_norm_dkc;norm(value(dkc))];
  list_Esq=[list_Esq;Esq];
  list_Esq_z=[list_Esq_z;Esq_z];
  list_Esq_s=[list_Esq_s;Esq_s]; 
  list_Asq_max_pass=[list_Asq_max_pass;max(Asq(1:nap))];
  list_Asq_min_pass=[list_Asq_min_pass;min(Asq(1:nap))];
  list_Asq_max_stop=[list_Asq_max_stop;max(Asq(nas:end))];
  list_k{length(list_k)+1}=k;
  list_c{length(list_c)+1}=c;

  % Exit criterion
  if norm(value(dz)) < tol
    break;
  elseif m==maxiter_kyp
    warning("Exiting at maxiter_kyp!");
    break;
  endif

endfor
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Finish
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find all-pass denominator polynomial
[n1,d1R]=schurOneMlattice2tf(k,k0_ones,k0_ones,c);

Asq1=schurOneMlatticeAsq(w,k,k0_ones,k0_ones,c);
printf("10*log10(max(Asq(pass)))=%g dB\n",10*log10(max(Asq(1:nap))));
printf("10*log10(min(Asq(pass)))=%g dB\n",10*log10(min(Asq(1:nap))));
printf("10*log10(max(Asq(stop)))=%g dB\n",10*log10(max(Asq(nas:end))));

T1=schurOneMlatticeT(w,k,k0_ones,k0_ones,c);
printf("min(T1(pass))=%g,max(T1(pass))=%g\n",min(T1(1:nap)),max(T1(1:nap)));

[Esq,gradEsq]=schurOneMlatticeEsq(k0,k0_ones,k0_ones,c0,wa,Asqd,Wa);
printf("Esq=%g\n",Esq);
print_polynomial(gradEsq,"gradEsq","%g");

% Plot response
subplot(211)
[ax,h1,h2]=plotyy(f,10*log10(Asq1),f,10*log10(Asq1));
ylabel("Amplitude(dB)");
axis(ax(1),[0 0.5 -1 1]);
axis(ax(2),[0 0.5 -50 -30]);
grid("on");
strP=sprintf(["Response of tapped Schur lattice filter : ", ...
              "nN=%d, fap=%g, tp=%g, fas=%g"], nN,fap,tp,fas);
title(strP);
subplot(212)
plot(f,T1);
ylabel("Delay(samples)");
axis([0 0.5 0 20]);
grid("on");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot convergence
list_len=length(list_norm_dkc);
if list_len ~= length(list_Esq)
  error("list_len ~= length(list_Esq)");
endif
[ax,h1,h2]=plotyy(1:list_len,list_norm_dkc,1:list_len,list_Esq);
set(h1,"linestyle","-");
set(h2,"linestyle","-.");
legend("$\\mathnorm{\\Delta_{\\boldsymbol{x}}}$","$\\mathcal{E}^2$");
legend("box","off");
legend("location","northeast");
ylabel(ax(1),"$\\mathnorm{\\Delta_{\\boldsymbol{x}}}$");
ylabel(ax(2),"$\\mathcal{E}^2$");
xlabel("Iteration");
axis(ax(1),[0 list_len 0 0.03]);
axis(ax(2),[0 list_len 0 0.015]);
grid("on");
strP=sprintf(["Convergence of tapped Schur lattice filter : ", ...
              "nN=%d, fap=%g, tp=%g, fas=%g"], nN,fap,tp,fas);
title(strP);
zticks([]);
print(strcat(strf,"_convergence"),"-dpdflatex");
close

% Plot Esq_s and Esq_z
list_len=length(list_Esq_s);
if list_len ~= length(list_Esq_z)
  error("list_len ~= length(list_Esq_z)");
endif
[ax,h1,h2]=plotyy(1:list_len,list_Esq_z,1:list_len,list_Esq_s);
set(h1,"linestyle","-");
set(h2,"linestyle","-.");
legend("$\\mathcal{E}_{z}^2$","$\\mathcal{E}_{s}^2$");
legend("box","off");
legend("location","northeast");
ylabel(ax(1),"$\\mathcal{E}_{z}^2$");
ylabel(ax(2),"$\\mathcal{E}_{s}^2$");
xlabel("Iteration");
axis(ax(1),[0 list_len 0 0.08]);
axis(ax(2),[0 list_len 0 0.008]);
grid("on");
strP=sprintf(["Esq_z and Esq_s  of tapped Schur lattice filter : ", ...
              "nN=%d, fap=%g, tp=%g, fas=%g"], nN,fap,tp,fas);
title(strP);
zticks([]);
print(strcat(strf,"_Esq_z_Esq_s"),"-dpdflatex");
close

% Plot amplitude min,max
list_len=length(list_Asq_min_pass);
if list_len ~= length(list_Asq_max_stop)
  error("list_len ~= length(list_Asq_max_stop)");
endif
[ax,h1,h2]=plotyy(1:list_len,10*log10(list_Asq_min_pass), ...
                  1:list_len,10*log10(list_Asq_max_stop));
set(h1,"linestyle","-");
set(h2,"linestyle","-.");
legend("$A_{min}$(dB)","$A_{max}$(dB)");
legend("box","off");
legend("location","north");
ylabel(ax(1),"Minimum Amplitude(dB)");
ylabel(ax(2),"Maximum Amplitude(dB)");
axis(ax(1),[0 list_len -1.4 0]);
axis(ax(2),[0 list_len -42 -28]);
xlabel("Iteration");
grid("on");
strP=sprintf(["Pass-band $A_{min}$(dB) and stop-band $A_{max}$(dB) of ", ...
              "tapped Schur lattice filter and delay : ", ...
              "nN=%d, fap=%g, tp=%g, fas=%g"], ...
             nN,fap,tp,fas);
title(strP);
zticks([]);
print(strcat(strf,"_Asq_min_max"),"-dpdflatex");
close

% Plot poles and zeros
zplane(roots(n1),roots(d1R));
strP=sprintf(["Pole-zero plot of tapped Schur lattice filter : ", ...
              "nN=%d, fap=%g, tp=%g, fas=%g"], ...
             nN,fap,tp,fas);
title(strP);
grid("on");
zticks([]);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Save the results
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%g %% General tolerance\n",tol);
fprintf(fid,"maxiter_kyp=%d %% Maximum number of KYP iterations\n",maxiter_kyp);
fprintf(fid,"nN=%d %% Tapped Schur lattice filter order\n",nN);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fprintf(fid,"tp=%g %% Nominal pass band group-delay(samples)\n",tp);
fclose(fid);

print_polynomial(n0,"n0");
print_polynomial(n0,"n0",strcat(strf,"_n0_coef.m"));
print_polynomial(d0R,"d0R");
print_polynomial(d0R,"d0R",strcat(strf,"_d0R_coef.m"));
print_polynomial(k0,"k0");
print_polynomial(k0,"k0",strcat(strf,"_k0_coef.m"));
print_polynomial(c0,"c0");
print_polynomial(c0,"c0",strcat(strf,"_c0_coef.m"));
print_polynomial(k,"k");
print_polynomial(k,"k",strcat(strf,"_k_coef.m"));
print_polynomial(c,"c");
print_polynomial(c,"c",strcat(strf,"_c_coef.m"));
print_polynomial(n1,"n1");
print_polynomial(n1,"n1",strcat(strf,"_n1_coef.m"));
print_polynomial(d1R,"d1R");
print_polynomial(d1R,"d1R",strcat(strf,"_d1R_coef.m"));

print_polynomial(list_Objective,"list_Objective");
print_polynomial(list_norm_dz,"list_norm_dz");
print_polynomial(list_norm_dkc,"list_norm_dkc");
print_polynomial(list_Esq,"list_Esq");
print_polynomial(list_Esq_z,"list_Esq_z");
print_polynomial(list_Esq_s,"list_Esq_s");
print_polynomial(list_Asq_max_pass,"list_Asq_max_pass");
print_polynomial(list_Asq_min_pass,"list_Asq_min_pass");
print_polynomial(list_Asq_max_stop,"list_Asq_max_stop");
for u=1:length(list_k)
  print_polynomial(list_k{u},sprintf("list_k{%d}",u));
endfor
for u=1:length(list_c)
  print_polynomial(list_c{u},sprintf("list_c{%d}",u));
endfor

eval(sprintf(["save %s.mat n tol nN R maxiter_kyp ", ...
              "fap fas Was tp k0 c0 n0 d0R k c n1 d1R"], strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
