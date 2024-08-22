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
use_updateHessEsqBfgs=false
use_scs=false
use_sedumi=false
maxiter_kyp=10;

if use_best_k_found
  maxiter_succ_approx=0;
  printf("\n\nUsing best k found!\n\n");
  % 10*log10(min(Asq))(pass)=-0.32959,10*log10(max(Asq))(stop)=-42.7963
  Esq=0.000129941
  gradEsq = [ -0.00648956, -0.00373311, -0.00261081, -0.00166774, -0.000454683 ];
  diagHessEsq = [ 0.313481, 0.104108, 0.0628018, 0.0369148, 0.0261127 ];
  k0 = [ -0.5815122254, 0.3900417137, 0.2137485273, 0.0895397490, ... 
          0.0223971683 ];
  k = [ -0.5770026749, 0.3941398414, 0.2185757093, 0.0901622396, ... 
         0.0215800814 ];
  list_norm_dk = [ 0.0023064941, 0.0017160195, 0.0012725966, 0.0009100554, ... 
                   0.0006545067, 0.0005218448, 0.0003883387, 0.0002799004, ... 
                   0.0001955235, 0.0001273214 ]';
  list_Esq = [ 0.0001798226, 0.0001650135, 0.0001542653, 0.0001463806, ... 
               0.0001408849, 0.0001367323, 0.0001338441, 0.0001319218, ... 
               0.0001306216, 0.0001299408 ]';
  list_Asq_min = [ 0.9155661016, 0.9186597134, 0.9210360994, 0.9228599621, ... 
                   0.9241778147, 0.9251976996, 0.9259203938, 0.9264091429, ... 
                   0.9267415152, 0.9269173194 ]';
  list_Asq_max = [ 0.0000559619, 0.0000534483, 0.0000523381, 0.0000527285, ... 
                   0.0000534862, 0.0000539074, 0.0000537779, 0.0000535718, ... 
                   0.0000530642, 0.0000525253 ]';
  list_k{1} = [  -0.5804986088,  0.3908109036,  0.2155971127,  0.0899788598, ... 
                  0.0220959091 ];
  list_k{2} = [  -0.5796657828,  0.3915032571,  0.2169269644,  0.0900260010, ... 
                  0.0220636228 ];
  list_k{3} = [  -0.5789663858,  0.3921121946,  0.2177937979,  0.0899405999, ... 
                  0.0220927301 ];
  list_k{4} = [  -0.5783821531,  0.3926291731,  0.2182609750,  0.0899380983, ... 
                  0.0220560485 ];
  list_k{5} = [  -0.5779319110,  0.3930603570,  0.2184389121,  0.0899759163, ... 
                  0.0219745036 ];
  list_k{6} = [  -0.5775796296,  0.3934157247,  0.2185372592,  0.0900283490, ... 
                  0.0218769729 ];
  list_k{7} = [  -0.5773330125,  0.3936946100,  0.2185815560,  0.0900700766, ... 
                  0.0217847421 ];
  list_k{8} = [  -0.5771623482,  0.3938980764,  0.2185809832,  0.0901033237, ... 
                  0.0217028050 ];
  list_k{9} = [  -0.5770549074,  0.3940438488,  0.2185918540,  0.0901325694, ... 
                  0.0216360007 ];
  list_k{10} = [ -0.5770026749,  0.3941398414,  0.2185757093,  0.0901622396, ... 
                  0.0215800814 ];
  % Elapsed time is 788.029 seconds.
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
    Esqkdk=Esq+(gradEsq(1:N)*(dk'))+(dk*hessEsq(1:N,1:N)*(dk')/2);
  elseif use_updateHessEsqBfgs
    if m==1
      Esqkdk=Esq+(gradEsq(1:N)*(dk'))+(dk*hessEsq(1:N,1:N)*(dk')/2);
    else
      gmma=gradEsq(1:N)-last_gradEsq;
      last_gradEsq=gradEsq(1:N);
      [W,invW]=updateWbfgs(value(dk),gmma,W,invW);
      Esqkdk=Esq+(gradEsq(1:N)*(dk'))+(dk*W(1:N,1:N)*(dk')/2);
    endif
  else
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
