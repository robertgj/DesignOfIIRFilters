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

strf="schurOneMPAlatticeDoublyPipelinedDelay_kyp_Dinh_lowpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_start;

use_best_k_found=true
use_hessEsq=true
use_scs=false
use_sedumi=false
maxiter_kyp=10;

if use_best_k_found
  maxiter_succ_approx=0;
  printf("\n\nUsing best k found!\n\n");
  % 10*log10(min(Asq))(pass)=-0.331296,10*log10(max(Asq))(stop)=-42.7558
  Esq=0.000131448
  gradEsq = [ -0.00655808, -0.00377028, -0.00264169, -0.0016867, ... 
              -0.000461548 ];
  diagHessEsq = [ 0.315655, 0.104005, 0.0614165, 0.036003, ... 
                  0.0248532 ];
  k0 = [  -0.5815122254,  0.3900417137,  0.2137485273,  0.0895397490, ... 
           0.0223971683 ];
  k = [  -0.5770686529,  0.3940698309,  0.2182758868,  0.0901685142, ... 
          0.0214995587 ];
  list_norm_dk = [   0.0022970793, 0.0017075211, 0.0011682445, 0.0008964977, ... 
                     0.0006518973, 0.0005112176, 0.0003862657, 0.0002661836, ... 
                     0.0001815319, 0.0001239226 ]';
  list_Esq = [   0.0001798933, 0.0001651090, 0.0001548097, 0.0001470092, ... 
                 0.0001415475, 0.0001375176, 0.0001347093, 0.0001329596, ... 
                 0.0001319202, 0.0001314477 ]';
  list_Asq_min = [   0.9155525165, 0.9186398417, 0.9209210228, 0.9227218284, ... 
                     0.9240291563, 0.9250167957, 0.9257189320, 0.9261633508, ... 
                     0.9264301565, 0.9265533524 ]';
  list_Asq_max = [   0.0000558283, 0.0000534988, 0.0000532188, 0.0000535293, ... 
                     0.0000541042, 0.0000544039, 0.0000543669, 0.0000539887, ... 
                     0.0000535184, 0.0000530176 ]';
  list_k{1} = [  -0.5805012205,  0.3908169335,  0.2155992008,  0.0899325194, ... 
                  0.0221247430 ];
  list_k{2} = [  -0.5796674620,  0.3915011322,  0.2169209433,  0.0899942405, ... 
                  0.0220855704 ];
  list_k{3} = [  -0.5789694556,  0.3920921179,  0.2176465149,  0.0899537875, ... 
                  0.0220704775 ];
  list_k{4} = [  -0.5783904942,  0.3926027526,  0.2180997512,  0.0899524749, ... 
                  0.0220221134 ];
  list_k{5} = [  -0.5779418882,  0.3930339268,  0.2182715340,  0.0899774949, ... 
                  0.0219344996 ];
  list_k{6} = [  -0.5775997011,  0.3933844651,  0.2183508663,  0.0900332662, ... 
                  0.0218250902 ];
  list_k{7} = [  -0.5773528064,  0.3936592336,  0.2183660887,  0.0900767625, ... 
                  0.0217220233 ];
  list_k{8} = [  -0.5771969213,  0.3938541074,  0.2183502749,  0.0901042179, ... 
                  0.0216349953 ];
  list_k{9} = [  -0.5771063109,  0.3939866333,  0.2183206606,  0.0901341735, ... 
                  0.0215614689 ];
  list_k{10} = [ -0.5770686529,  0.3940698309,  0.2182758868,  0.0901685142, ... 
                  0.0214995587 ];
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
    [Esq,gradEsq] = ...
        schurOneMPAlatticeDoublyPipelinedEsq(k,kDD,diff,wplot/2,Ad,Wa);
    Esqkdk=Esq+(gradEsq(1:N)*(dk'));
  endif

  % Solve for the SDP variables
  rho=10^floor(log10(Esq));
  ctol=1e-5;
  Constraints=[ (-1+ctol)<=(k+dk)<=(1-ctol), ...
                  dEsq_p<=0,       dEsq_s<=0, ...
                  Esq_p+dEsq_p>=0, Esq_s+dEsq_s>=0, ...
                  bFzm_p<=ctol,    dQ_p>=0, ...
                  bFzm_s<=ctol,    dQ_s>=0 ];
  Objective=real(Esqkdk + (rho*norm(dz)^2));
  if use_scs
    Options=sdpsettings("solver","scs-direct","scs.max_iters",20000,
                        "scs.eps_abs",tol,"scs.eps_rel",tol);
  elseif use_sedumi
    Options=sdpsettings("solver","sedumi","sedumi.eps",tol);
  else
    Options=sdpsettings("solver","sdpt3","maxit",100,"gaptol",tol);
  endif
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
