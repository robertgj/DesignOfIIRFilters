% schurOneMPAlatticeDoublyPipelinedDelay_kyp_Dinh_lowpass_test.m
% Copyright (C) 2024 Robert G. Jenssen
%
% Design a Schur one-multiplier all-pass filter with the Finsler
% transformation of the KYP lemma and the BMI convex over-approximation
% of Dinh et al.. See: "Combining Convex–Concave Decompositions and
% Linearization Approaches for Solving BMIs, With Application to Static Output
% Feedback", July, 2011. Available at:
%   https://set.kuleuven.be/optec/Software/softwarefiles/bmipaper
%
% N    rows(A)     rows(F)
%    2*((N+DD)+2)  3*rows(A)+3
% 4      18          57
% 5      22          69
% 6      26          81
% 7      30          93
% 8      34         105

test_common;

use_best_k_found=true
maxiter_kyp=12;

strf="schurOneMPAlatticeDoublyPipelinedDelay_kyp_Dinh_lowpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_start;

if use_best_k_found
  maxiter_succ_approx=0;
  printf("\n\nUsing best k found!\n\n");
  k0 = [  -0.5815122254,   0.3900417137,   0.2137485273,   0.0895397490, ...
          0.0223971683 ];
  k = [  -0.5782998611,   0.3931457849,   0.2169255234,   0.0899513674, ...
          0.0213560913 ];
  list_norm_dk = [ 0.0015221431, 0.0010060201, 0.0007903048, 0.0006427362, ...
                   0.0005148136, 0.0003989500, 0.0002961254, 0.0002095585, ...
                   0.0001297589, 0.0000935183, 0.0000850062, 0.0000719651 ]';
  list_Esq = [ 0.0001863897, 0.0001763859, 0.0001687048, 0.0001626674, ...
               0.0001579908, 0.0001544765, 0.0001519480, 0.0001502354, ...
               0.0001492415, 0.0001486440, 0.0001481766, 0.0001478675 ]';
  list_Asq_min = [ 0.9142834294, 0.9163339585, 0.9179655734, 0.9192820168, ...
                   0.9203230396, 0.9211177289, 0.9216957998, 0.9220896216, ...
                   0.9223194145, 0.9224568193, 0.9225624382, 0.9226318525 ]';
  list_Asq_max = [ 0.0000549100, 0.0000537475, 0.0000532357, 0.0000528064, ...
                   0.0000522922, 0.0000516769, 0.0000509729, 0.0000501688, ...
                   0.0000495724, 0.0000489804, 0.0000483234, 0.0000478822 ]';
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
  VplusUzm_p=(Uzm_p+(Vzm_p'))/sqrt(2);
  UminusVzm_p=(Uzm_p-(Vzm_p'))/sqrt(2);
  Fzm_p=[[[[Lzm_p,zeros(2*n,2)]; ...
           [zeros(1,2*n),-Esq_p,0]; ...
           [zeros(1,(2*n)+1),1]],(VplusUzm_p')]; ...
         [VplusUzm_p,-eye(n+1)]] - ...
        [[(UminusVzm_p')*UminusVzm_p,zeros(2*(n+1),n+1)]; ...
         [zeros(n+1,2*(n+1)),zeros(n+1)]];

  % Linear part of the pass band constraint matrix
  gLzm_p=kron(Phi,dP_p)+kron(Psi_p,dQ_p);
  gUzm_p=[[zeros(n),dA,zeros(n,1),zeros(n,1)]; ...
          [zeros(1,n),zeros(1,n),0,0]];
  gVzm_p=[[dXYZ_p,zeros((2*n)+1,1)]; ...
          [zeros(1,n),0]];
  gVplusUzm_p=(gUzm_p+(gVzm_p'))/sqrt(2);
  gUminusVzm_p=(gUzm_p-(gVzm_p'))/sqrt(2);
  gFzm_p=[[[[gLzm_p,zeros(2*n,2)]; ...
            [zeros(1,2*n),-dEsq_p,0]; ...
            [zeros(1,(2*n)+1),0]],(gVplusUzm_p')]; ...
          [gVplusUzm_p,zeros(n+1)]] - ...
         [[(gUminusVzm_p')*UminusVzm_p,zeros(2*(n+1),n+1)]; ...
          [zeros(n+1,2*(n+1)),zeros(n+1)]] - ...
         [[(UminusVzm_p')*gUminusVzm_p,zeros(2*(n+1),n+1)]; ...
          [zeros(n+1,2*(n+1)),zeros(n+1)]];

  % Construct pass band constraint matrix
  bFzm_p=Fzm_p+gFzm_p;

  % Constant part of the stop band constraint matrix
  Lzm_s=kron(Phi,P_s)+kron(Psi_s,Q_s);
  Uzm_s=[[-eye(n),A,B,zeros(n,1)]; ...
         [zeros(1,n),C_s,D,-1]];
  Vzm_s=[[XYZ_s,zeros((2*n)+1,1)]; ...
         [zeros(1,n),1]];
  VplusUzm_s=(Uzm_s+(Vzm_s'))/sqrt(2);
  UminusVzm_s=(Uzm_s-(Vzm_s'))/sqrt(2);
  Fzm_s=[[[[Lzm_s,zeros(2*n,2)]; ...
           [zeros(1,2*n),-Esq_s,0]; ...
           [zeros(1,(2*n)+1),1]],(VplusUzm_s')]; ...
         [VplusUzm_s,-eye(n+1)]] - ...
        [[(UminusVzm_s')*UminusVzm_s,zeros(2*(n+1),n+1)]; ...
         [zeros(n+1,2*(n+1)),zeros(n+1)]];

  % Linear part of the stop band constraint matrix
  gLzm_s=kron(Phi,dP_s)+kron(Psi_s,dQ_s);
  gUzm_s=[[zeros(n),dA,zeros(n,1),zeros(n,1)]; ...
          [zeros(1,n),zeros(1,n),0,0]];
  gVzm_s=[[dXYZ_s,zeros((2*n)+1,1)]; ...
          [zeros(1,n),0]];
  gVplusUzm_s=(gUzm_s+(gVzm_s'))/sqrt(2);
  gUminusVzm_s=(gUzm_s-(gVzm_s'))/sqrt(2);
  gFzm_s=[[[[gLzm_s,zeros(2*n,2)]; ...
            [zeros(1,2*n),-dEsq_s,0]; ...
            [zeros(1,(2*n)+1),0]],(gVplusUzm_s')]; ...
          [gVplusUzm_s,zeros(n+1)]] - ...
         [[(gUminusVzm_s')*UminusVzm_s,zeros(2*(n+1),n+1)]; ...
          [zeros(n+1,2*(n+1)),zeros(n+1)]] - ...
         [[(UminusVzm_s')*gUminusVzm_s,zeros(2*(n+1),n+1)]; ...
          [zeros(n+1,2*(n+1)),zeros(n+1)]];

  % Construct stop band constraint matrix
  bFzm_s=Fzm_s+gFzm_s;
  
  if m==1,
    printf("rows(Lzm_p)=%d\n",rows(Lzm_p));
    printf("rows(Fzm_p)=%d\n",rows(Fzm_p));
    printf("rows(Lzm_s)=%d\n",rows(Lzm_s));
    printf("rows(Fzm_s)=%d\n",rows(Fzm_s));
  endif
   
  % Solve for the SDP variables
  [Esq,gradEsq,diagHessEsq]= ...
    schurOneMPAlatticeEsq(k,k1,k1,kDD,kDD1,kDD1,diff,wplot,Ad,Wa);
  Esqkdk=Esq+sum(gradEsq(1:N).*dk)+sum(dk.*diagHessEsq(1:N).*dk/2);
  Constraints=[ (-1+tol)<=(k+dk)<=(1-tol), ...
                dEsq_p<=0,   dEsq_s<=0, ...
                bFzm_p<=tol, dQ_p>=0, ...
                bFzm_s<=tol, dQ_s>=0 ];
  Objective=real(Esqkdk + (norm(dz)^2));
  Options=sdpsettings("solver","sdpt3","maxit",100,"gaptol",tol);
  sol=optimize(Constraints,Objective,Options)
  if sol.problem
    error("YALMIP failed");
  endif

  % Sanity checks
  check(Constraints)
  
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
