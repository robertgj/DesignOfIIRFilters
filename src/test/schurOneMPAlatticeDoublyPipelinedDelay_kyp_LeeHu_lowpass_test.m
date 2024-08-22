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

strf="schurOneMPAlatticeDoublyPipelinedDelay_kyp_LeeHu_lowpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

schurOneMPAlatticeDoublyPipelinedDelay_kyp_lowpass_common_start;

use_best_k_found=true;
use_hessEsq=true
use_sedumi=false
use_scs=false
maxiter_kyp=12;

S_p=eye(n+1);
S_s=eye(n+1);

dS_p=sdpvar(n+1,n+1,"symmetric","real");
dS_s=sdpvar(n+1,n+1,"symmetric","real");

if use_best_k_found
  maxiter_succ_approx=0;
  printf("\n\nUsing best k found!\n\n");
  % 10*log10(min(Asq))(pass)=-0.328362,10*log10(max(Asq))(stop)=-42.8517
  Esq=0.0001292
  gradEsq = [ -0.00644798, -0.00371873, -0.00259933, -0.00166523, -0.000463544 ];
  diagHessEsq = [ 0.311174, 0.10466, 0.0640905, 0.0372884, 0.0270482 ];
  k0 = [  -0.5815122254,  0.3900417137,  0.2137485273,  0.0895397490, ... 
          0.0223971683 ];
  k = [  -0.5766477696,  0.3940152264,  0.2184304179,  0.0898388513, ... 
         0.0212019281 ];
  list_norm_dk = [ 0.0022525596, 0.0018868553, 0.0012763264, 0.0008892737, ... 
                   0.0006502459, 0.0004741870, 0.0003200502, 0.0002414974, ... 
                   0.0001553948, 0.0000953045, 0.0000853003, 0.0000844263 ]';
  list_Esq = [ 0.0001801128, 0.0001633378, 0.0001522311, 0.0001447624, ... 
               0.0001394669, 0.0001356982, 0.0001332293, 0.0001314414, ... 
               0.0001303626, 0.0001297844, 0.0001294423, 0.0001292003 ]';
  list_Asq_min = [ 0.9155185559, 0.9190810455, 0.9215840886, 0.9233418149, ... 
                   0.9246243358, 0.9255545953, 0.9261703408, 0.9266200907, ... 
                   0.9268921600, 0.9270376995, 0.9271218928, 0.9271795543 ]';
  list_Asq_max = [ 0.0000561739, 0.0000537888, 0.0000526956, 0.0000523437, ... 
                   0.0000525246, 0.0000527690, 0.0000530190, 0.0000529366, ... 
                   0.0000528153, 0.0000526982, 0.0000523491, 0.0000518603 ]';
  list_k{1} = [  -0.5804775571,  0.3907833070,  0.2155394118,  0.0899214143, ... 
                 0.0220800098 ];
  list_k{2} = [  -0.5793689537,  0.3915043064,  0.2168649174,  0.0898303960, ... 
                 0.0218652268 ];
  list_k{3} = [  -0.5785388906,  0.3921106265,  0.2175957020,  0.0897493230, ... 
                 0.0216870098 ];
  list_k{4} = [  -0.5779214271,  0.3926010793,  0.2179759536,  0.0896647774, ... 
                 0.0215556195 ];
  list_k{5} = [  -0.5774564539,  0.3929826855,  0.2181976494,  0.0896117607, ... 
                 0.0214605586 ];
  list_k{6} = [  -0.5771217706,  0.3932833252,  0.2183274072,  0.0896015475, ... 
                 0.0213862972 ];
  list_k{7} = [  -0.5769100192,  0.3935093437,  0.2183861911,  0.0896288868, ... 
                 0.0213382747 ];
  list_k{8} = [  -0.5767633950,  0.3936884846,  0.2184264927,  0.0896615901, ... 
                 0.0212931397 ];
  list_k{9} = [  -0.5766820261,  0.3938100697,  0.2184417302,  0.0897003504, ... 
                 0.0212613723 ];
  list_k{10} = [ -0.5766444237,  0.3938870415,  0.2184398638,  0.0897366149, ... 
                 0.0212407381 ];
  list_k{11} = [ -0.5766383320,  0.3939537691,  0.2184331284,  0.0897849670, ... 
                 0.0212206594 ];
  list_k{12} = [ -0.5766477696,  0.3940152264,  0.2184304179,  0.0898388513, ... 
                 0.0212019281 ];
  % Elapsed time is 1671.89 seconds.
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
    Esqkdk=Esq+(gradEsq(1:N)*(dk'))+(dk*hessEsq(1:N,1:N)*(dk')/2);
  else
    Esqkdk=Esq+(gradEsq(1:N)*(dk'));
  endif

  % Solve for the SDP variables
  rho=10^floor(log10(Esq));
  ctol=1e-5;
  c1=ctol;c2=1e4;c3=ctol;
  Constraints=[ (-1+tol)<=(k+dk)<=(1-tol), ...
                dEsq_p<=0, ...
                dEsq_s<=0, ...
                Esq_p+dEsq_p>=0, ...
                Esq_s+dEsq_s>=0, ...
                bFzm_p<=ctol, dQ_p>=0, dS_p>=0, ...
                bFzm_s<=ctol, dQ_s>=0, dS_s>=0, ...
                c1*eye(n+1)<=dS_p<=c2*eye(n+1), ...
                c1*eye(n+1)<=dS_s<=c2*eye(n+1), ...
                ((-2*S_p)+dS_p)<=-c3*eye(n+1), ...
                ((-2*S_s)+dS_s)<=-c3*eye(n+1) ];
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
