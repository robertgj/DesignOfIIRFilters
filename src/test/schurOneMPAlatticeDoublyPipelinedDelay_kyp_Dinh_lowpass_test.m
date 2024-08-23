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
maxiter_kyp=25;

if use_best_k_found
  maxiter_succ_approx=0;
  printf("\n\nUsing best k found!\n\n");
  % 10*log10(min(Asq))(pass)=-0.125778,10*log10(max(Asq))(stop)=-42.451
  Esq=2.76167e-05
  gradEsq = [ -0.000694631, -0.000397877, -5.04744e-05, 0.000100928, ...
              0.000305314 ];
  diagHessEsq = [ 0.0897052, 0.0676464, 0.0670896, 0.0501674, 0.0601683 ];
  k0 = [ -0.5887890122, 0.3794825489, 0.2077136416, 0.0867433777, 0.0216280074 ];
  k =  [ -0.5581320557, 0.4148180690, 0.2277800520, 0.0909440762, 0.0187465729 ];
  list_norm_dk = [  0.0038950834, 0.0031780402, 0.0027776118, 0.0025136353, ... 
                    0.0023621686, 0.0022575812, 0.0021518500, 0.0020340222, ... 
                    0.0020236654, 0.0019418155, 0.0018977484, 0.0018489167, ... 
                    0.0023246788, 0.0021078254, 0.0021491981, 0.0021056174, ... 
                    0.0020733987, 0.0020332928, 0.0019790179, 0.0019137834, ... 
                    0.0018914079, 0.0018286418, 0.0017706060, 0.0017010061, ... 
                    0.0016396338 ]';
  list_Esq = [  0.0003601350, 0.0003104653, 0.0002702141, 0.0002365145, ... 
                0.0002080069, 0.0001836281, 0.0001627392, 0.0001449441, ... 
                0.0001290925, 0.0001153842, 0.0001033454, 0.0000927991, ... 
                0.0000820729, 0.0000727082, 0.0000643451, 0.0000571678, ... 
                0.0000510526, 0.0000458967, 0.0000416036, 0.0000380712, ... 
                0.0000351018, 0.0000326765, 0.0000306812, 0.0000290275, ... 
                0.0000276167 ]';
  list_Asq_min = [  0.8867946582, 0.8936303278, 0.8996844397, 0.9052115297, ... 
                    0.9102891722, 0.9149907889, 0.9193485372, 0.9233557364, ... 
                    0.9272112034, 0.9308098353, 0.9342232397, 0.9374570489, ... 
                    0.9411035931, 0.9445636215, 0.9479903970, 0.9512499168, ... 
                    0.9543479624, 0.9572684549, 0.9599873768, 0.9624684039, ... 
                    0.9647882873, 0.9668306880, 0.9686079585, 0.9701347691, ... 
                    0.9714538936 ]';
  list_Asq_max = [  0.0000347159, 0.0000416972, 0.0000479018, 0.0000520924, ... 
                    0.0000553452, 0.0000579516, 0.0000597605, 0.0000602947, ... 
                    0.0000615117, 0.0000616016, 0.0000616674, 0.0000612638, ... 
                    0.0000653424, 0.0000650711, 0.0000658979, 0.0000660373, ... 
                    0.0000660319, 0.0000657373, 0.0000647381, 0.0000626218, ... 
                    0.0000613908, 0.0000581019, 0.0000540896, 0.0000537418, ... 
                    0.0000568717 ]';
else
  maxiter_succ_approx=maxiter_kyp;
endif

for m=1:maxiter_succ_approx,

  % Constant part of the pass band constraint matrix
  P_p=zeros(size(P_p));
  Q_p=zeros(size(Q_p));
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
  P_s=zeros(size(P_s));
  Q_s=zeros(size(Q_s));
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
