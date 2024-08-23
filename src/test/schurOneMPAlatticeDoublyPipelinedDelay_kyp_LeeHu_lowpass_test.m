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
maxiter_kyp=25;

S_p=eye(n+1);
S_s=eye(n+1);

dS_p=sdpvar(n+1,n+1,"symmetric","real");
dS_s=sdpvar(n+1,n+1,"symmetric","real");

if use_best_k_found
  maxiter_succ_approx=0;
  printf("\n\nUsing best k found!\n\n");
  % 10*log10(min(Asq))(pass)=-0.109816,10*log10(max(Asq))(stop)=-41.4697
  Esq=2.30611e-05
  gradEsq = [ -0.000487483, -0.000292445, 6.20595e-05, 0.000126383, ... 
               0.000254077 ];
  diagHessEsq = [ 0.0813394, 0.0741255, 0.074537, 0.0562085, 0.0692805 ];
  k0 = [ -0.5887890122, 0.3794825489, 0.2077136416, 0.0867433777, 0.0216280074 ];
  k = [  -0.5531425649, 0.4162986274, 0.2261626103, 0.0883903661, 0.0158271344 ];
  list_norm_dk = [ 0.0036142439, 0.0032519436, 0.0027737164, 0.0026656736, ... 
                   0.0028818947, 0.0029485529, 0.0028832254, 0.0027293723, ... 
                   0.0026058859, 0.0024833616, 0.0029742127, 0.0024644818, ... 
                   0.0023835245, 0.0022791884, 0.0021858618, 0.0020857839, ... 
                   0.0020732142, 0.0019147283, 0.0015923027, 0.0019106206, ... 
                   0.0014119452, 0.0015685145, 0.0012229675, 0.0006027462, ... 
                   0.0010900897 ]';
  list_Esq = [     0.0003638497, 0.0003109768, 0.0002683220, 0.0002328638, ... 
                   0.0001997472, 0.0001700092, 0.0001444210, 0.0001232627, ... 
                   0.0001056612, 0.0000910541, 0.0000764423, 0.0000658860, ... 
                   0.0000571249, 0.0000499616, 0.0000441010, 0.0000393444, ... 
                   0.0000353486, 0.0000322386, 0.0000300481, 0.0000278220, ... 
                   0.0000264184, 0.0000250796, 0.0000241622, 0.0000237485, ... 
                   0.0000230611 ]';
  list_Asq_min = [ 0.8863443967, 0.8937810554, 0.9003811945, 0.9063466764, ... 
                   0.9124072652, 0.9183818449, 0.9240585746, 0.9292471511, ... 
                   0.9340161350, 0.9383879289, 0.9432967814, 0.9472801760, ... 
                   0.9509706287, 0.9543472860, 0.9574481402, 0.9602816057, ... 
                   0.9629897201, 0.9653680609, 0.9672428436, 0.9694254845, ... 
                   0.9709130452, 0.9724689944, 0.9735841850, 0.9741069608, ... 
                   0.9750310492 ]';
  list_Asq_max = [ 0.0000365186, 0.0000446442, 0.0000561561, 0.0000577718, ... 
                   0.0000569531, 0.0000557392, 0.0000551809, 0.0000546452, ... 
                   0.0000545290, 0.0000545654, 0.0000635809, 0.0000666204, ... 
                   0.0000684979, 0.0000697355, 0.0000709316, 0.0000715509, ... 
                   0.0000734208, 0.0000735775, 0.0000708965, 0.0000719929, ... 
                   0.0000688896, 0.0000677685, 0.0000671616, 0.0000694116, ... 
                   0.0000712894 ]';
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
  P_s=zeros(size(P_s));
  Q_s=zeros(size(Q_s));
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
