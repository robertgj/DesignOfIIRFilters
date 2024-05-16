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
  k0 = [ -0.5815122254,  0.3900417137,  0.2137485273,  0.0895397490, ... 
          0.0223971683 ];
  k = [ -0.5782966668,  0.3929108170,  0.2174962383,  0.0897015762, ... 
         0.0215175151 ];
  list_norm_dk = [ 0.0018689601, 0.0014811112, 0.0009572312, 0.0006335061, ... 
                   0.0004488948, 0.0002973509, 0.0001785430, 0.0001058809, ... 
                   0.0000623757, 0.0000843881, 0.0000783915, 0.0000821900 ]';
  list_Esq = [ 0.0001848364, 0.0001714509, 0.0001627856, 0.0001572384, ... 
               0.0001533229, 0.0001507668, 0.0001492429, 0.0001484174, ... 
               0.0001479984, 0.0001477754, 0.0001476617, 0.0001475338 ]';
  list_Asq_min = [ 0.9145632592, 0.9173283983, 0.9192070850, 0.9204506954, ... 
                   0.9213482480, 0.9219424881, 0.9222989434, 0.9224920668, ... 
                   0.9225887895, 0.9226389777, 0.9226632113, 0.9226907239 ]';
  list_Asq_max = [ 0.0000523333, 0.0000490581, 0.0000474329, 0.0000470649, ... 
                   0.0000474694, 0.0000476813, 0.0000476877, 0.0000476031, ... 
                   0.0000472041, 0.0000470243, 0.0000468607, 0.0000466705 ]';
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

  % Solve for the SDP variables
  [Esq,gradEsq,diagHessEsq]= ...
    schurOneMPAlatticeEsq(k,k1,k1,kDD,kDD1,kDD1,diff,wplot,Ad,Wa);
  Esqkdk=Esq+sum(gradEsq(1:N).*dk)+sum(dk.*diagHessEsq(1:N).*dk/2);
  rho=10^floor(log10(Esq)-1);
  c1=tol;c2=1e4;c3=tol;
  Constraints=[ (-1+tol)<=(k+dk)<=(1-tol), ...
                dEsq_p<=0, ...
                dEsq_s<=0, ...
                bFzm_p<=tol, dQ_p>=0, dS_p>=0, ...
                bFzm_s<=tol, dQ_s>=0, dS_s>=0, ...
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
  elseif m==maxiter
    error("Failed at maxiter!");
  endif

endfor
 
schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_finish;

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
