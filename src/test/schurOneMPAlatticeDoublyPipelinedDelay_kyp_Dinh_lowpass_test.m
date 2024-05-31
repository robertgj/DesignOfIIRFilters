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
use_hessEsq=true
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
  k0 = [  -0.5815122254, 0.3900417137, 0.2137485273, 0.0895397490, ... 
           0.0223971683 ];
  k = [  -0.5751931231, 0.3958062355, 0.2181833337, 0.0904527117, ... 
          0.0206682574 ];
  list_norm_dk = [   0.0024508435, 0.0018498824, 0.0014472826, 0.0011030371, ... 
                     0.0009018763, 0.0007482201, 0.0006187905, 0.0005078939, ... 
                     0.0003819572, 0.0002886002, 0.0002065488, 0.0001353615 ]';
  list_Esq = [   0.0001774012, 0.0001605855, 0.0001480695, 0.0001388145, ... 
                 0.0001317300, 0.0001264229, 0.0001224100, 0.0001193007, ... 
                 0.0001171416, 0.0001155425, 0.0001145079, 0.0001139210 ]';
  list_Asq_min = [   0.9160780864, 0.9196520188, 0.9224878348, 0.9247005962, ... 
                     0.9264675487, 0.9278384875, 0.9289048960, 0.9297493495, ... 
                     0.9303466582, 0.9307936991, 0.9310866602, 0.9312546086 ]';
  list_Asq_max = [   0.0000571210, 0.0000561099, 0.0000556120, 0.0000561561, ... 
                     0.0000570025, 0.0000575181, 0.0000577061, 0.0000576596, ... 
                     0.0000575132, 0.0000572355, 0.0000568936, 0.0000565053 ]';
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
  Constraints=[ (-1+tol)<=(k+dk)<=(1-tol), ...
                dEsq_p<=0,    dEsq_s<=0, ...
                bFzm_p<=ctol, dQ_p>=0, ...
                bFzm_s<=ctol, dQ_s>=0 ];
  Objective=real(Esqkdk + (rho*norm(dz)^2));
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
