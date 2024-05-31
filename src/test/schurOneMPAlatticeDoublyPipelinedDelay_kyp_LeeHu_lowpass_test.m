% schurOneMPAlatticeDoublyPipelinedDelay_kyp_LeeHu_lowpass_test.m
% Copyright (C) 2024 Robert G. Jenssen
%
% Design a Schur one-multiplier all-pass filter with the Finsler
% transformation of the KYP lemma and the BMI convex over-approximation
% of Lee and Hu. See: "A sequential parametric convex approximation method
% for solving bilinear matrix inequalities", D. Lee and J. Hu, July, 2016,
% https://engineering.purdue.edu/~jianghai/Publication/OPTL2018_BMI.pdf
%
% m    rows(A)     rows(F)        rows(S)        rows(bF)
%    2*((N+D)+2)  2*rows(A)+2    rows(A)+1   4*(rows(A)+1) [16*m+12]
% 4      18          38             19               76
% 5      22          46             23               92
% 6      26          54             27              108
% 7      30          62             31              124
% 8      34          68             35              140

test_common;

use_best_k_found=true;
use_hessEsq=true
maxiter_kyp=12;

strf="schurOneMPAlatticeDoublyPipelinedDelay_kyp_LeeHu_lowpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_start;

S_p=eye(n+1);
S_s=eye(n+1);

dS_p=sdpvar(n+1,n+1,"symmetric","real");
dS_s=sdpvar(n+1,n+1,"symmetric","real");

if use_best_k_found
  maxiter_succ_approx=0;
  printf("\n\nUsing best k found!\n\n");
  k0 = [  -0.5815122254, 0.3900417137, 0.2137485273, 0.0895397490, ... 
           0.0223971683 ];
  k = [  -0.5747517063, 0.3955017952, 0.2181781846, 0.0900569089, ... 
          0.0202773534 ];
  list_norm_dk = [   0.0024135977, 0.0021353366, 0.0015107267, 0.0010875663, ... 
                     0.0008755810, 0.0006963759, 0.0005505977, 0.0004303958, ... 
                     0.0003296017, 0.0002428979, 0.0001764147, 0.0001089167 ]';
  list_Esq = [   0.0001775905, 0.0001581065, 0.0001449461, 0.0001361558, ... 
                 0.0001295400, 0.0001245549, 0.0001208506, 0.0001180984, ... 
                 0.0001161074, 0.0001147035, 0.0001137393, 0.0001131667 ]';
  list_Asq_min = [   0.9160509212, 0.9202571441, 0.9233098082, 0.9254546316, ... 
                     0.9271294113, 0.9284292616, 0.9294184494, 0.9301661221, ... 
                     0.9307137246, 0.9311033886, 0.9313728921, 0.9315329967 ]';
  list_Asq_max = [   0.0000573476, 0.0000561014, 0.0000567298, 0.0000569969, ... 
                     0.0000569471, 0.0000571784, 0.0000574817, 0.0000576007, ... 
                     0.0000574393, 0.0000573325, 0.0000572528, 0.0000572491 ]';
else
  maxiter_succ_approx=maxiter_kyp;
endif

for m=1:maxiter_succ_approx,

  % Constant part of the pass band constraint matrix
  Lzm_p=kron(Phi,P_p)+kron(Psi_p,Q_p);
  Uzm_p=[[-eye(n),A,B,zeros(n,1)]; ...
         [zeros(1,n),C_p,D,-1]];
  Vzm_p=[[XYZ_p,zeros((2*n)+1,1)]; ...
         [zeros(1,n),1]];
  VUzm_p=Vzm_p*Uzm_p;
  Fzm_p=[[Lzm_p,zeros(2*n,2)]; ...
         [zeros(1,2*n),-Esq_p,0]; ...
         [zeros(1,(2*n)+1),1]] + ...
        VUzm_p + (VUzm_p');

  % Linear part of the pass band constraint matrix
  gLzm_p=kron(Phi,dP_p)+kron(Psi_p,dQ_p);
  gUzm_p=[[zeros(n),dA,zeros(n,1),zeros(n,1)]; ...
          [zeros(1,n),zeros(1,n),0,0]];
  gVzm_p=[[dXYZ_p,zeros((2*n)+1,1)]; ...
          [zeros(1,n),0]];
  gVUzm_p=(gVzm_p*Uzm_p)+(Vzm_p*gUzm_p);
  gFzm_p=[[gLzm_p,zeros(2*n,1),zeros(2*n,1)]; ...
          [zeros(1,2*n),-dEsq_p,0]; ...
          [zeros(1,2*n),0,0]] + ...
         gVUzm_p + (gVUzm_p');

  % Construct pass band constraint matrix
  SgVzm_p=S_p*(gVzm_p');
  bFzm_p=[[(Fzm_p+gFzm_p),(SgVzm_p'),gUzm_p']; ...
          [SgVzm_p,(-(2*S_p)+dS_p),zeros(n+1)]; ...
          [gUzm_p,zeros(n+1),-dS_p]];

  % Constant part of the stop band constraint matrix
  Lzm_s=kron(Phi,P_s)+kron(Psi_s,Q_s);
  Uzm_s=[[-eye(n),A,B,zeros(n,1)]; ...
         [zeros(1,n),C_s,D,-1]];
  Vzm_s=[[XYZ_s,zeros((2*n)+1,1)]; ...
         [zeros(1,n),1]];
  VUzm_s=Vzm_s*Uzm_s;
  Fzm_s=[[Lzm_s,zeros(2*n,2)]; ...
         [zeros(1,2*n),-Esq_s,0]; ...
         [zeros(1,(2*n)+1),1]] + ...
        VUzm_s + (VUzm_s');

  % Linear part of the stop band constraint matrix
  gLzm_s=kron(Phi,dP_s)+kron(Psi_s,dQ_s);
  gUzm_s=[[zeros(n),dA,zeros(n,1),zeros(n,1)]; ...
          [zeros(1,n),zeros(1,n),0,0]];
  gVzm_s=[[dXYZ_s,zeros((2*n)+1,1)]; ...
          [zeros(1,n),0]];
  gVUzm_s=(gVzm_s*Uzm_s)+(Vzm_s*gUzm_s);
  gFzm_s=[[gLzm_s,zeros(2*n,1),zeros(2*n,1)]; ...
          [zeros(1,2*n),-dEsq_s,0]; ...
          [zeros(1,2*n),0,0]] + ...
         gVUzm_s + (gVUzm_s');

  % Construct stop band constraint matrix
  SgVzm_s=S_s*(gVzm_s');
  bFzm_s=[[(Fzm_s+gFzm_s),(SgVzm_s'),gUzm_s']; ...
          [SgVzm_s,(-(2*S_s)+dS_s),zeros(n+1)]; ...
          [gUzm_s,zeros(n+1),-dS_s]];

  % Define objective function
  if use_hessEsq
    [Esq,gradEsq,~,hessEsq]= ...
       schurOneMPAlatticeDoublyPipelinedEsq(k,kDD,diff,wplot/2,Ad,Wa);
    Esqkdk=Esq+(gradEsq(1:N)*(dk'))+(dk*hessEsq(1:N,1:N)*(dk')/2);
  else
    [Esq,gradEsq]=schurOneMPAlatticeDoublyPipelinedEsq(k,kDD,diff,wplot/2,Ad,Wa);
    Esqkdk=Esq+(gradEsq(1:N)*(dk'));
  endif

  % Solve for the SDP variables
  rho=10^floor(log10(Esq));
  ctol=1e-5;
  c1=ctol;c2=1e4;c3=ctol;
  Constraints=[ (-1+tol)<=(k+dk)<=(1-tol), ...
                dEsq_p<=0, ...
                dEsq_s<=0, ...
                bFzm_p<=ctol, dQ_p>=0, dS_p>=0, ...
                bFzm_s<=ctol, dQ_s>=0, dS_s>=0, ...
                c1*eye(n+1)<=dS_p<=c2*eye(n+1), ...
                c1*eye(n+1)<=dS_s<=c2*eye(n+1), ...
                ((-2*S_p)+dS_p)<=-c3*eye(n+1), ...
                ((-2*S_s)+dS_s)<=-c3*eye(n+1) ];
  Objective=real(Esqkdk + (rho*norm(dz)^2));
  Options=sdpsettings("solver","sdpt3","maxit",100,"gaptol",tol);
  sol=optimize(Constraints,Objective,Options)
  if sol.problem
    error("YALMIP failed");
  endif
  
  % Sanity checks
  check(Constraints)
  
  S_p=value(dS_p);
  S_s=value(dS_s);

  schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_update;

  % Exit criterion
  if norm(value(dk)) < tol
    break;
  elseif m==maxiter_kyp
    warning("Exiting at maxiter_kyp!");
    break;
  endif

endfor
 
schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_finish;

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
