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
use_scs=false
use_sedumi=false
use_hessEsq=true
maxiter_kyp=12;

S_p=eye(n+1);
S_s=eye(n+1);

dS_p=sdpvar(n+1,n+1,"symmetric","real");
dS_s=sdpvar(n+1,n+1,"symmetric","real");

if use_best_k_found
  maxiter_succ_approx=0;
  printf("\n\nUsing best k found!\n\n");
  % 10*log10(min(Asq))(pass)=-0.329621,10*log10(max(Asq))(stop)=-42.7669
  Esq=0.000130244
  gradEsq = [ -0.00649697, -0.00374302, -0.00262102, -0.0016772, ... 
              -0.000465111 ];
  diagHessEsq = [ 0.312859, 0.104235, 0.0625501, 0.0364611, ... 
                  0.0258038 ];
  k0 = [  -0.5815122254,  0.3900417137,  0.2137485273,  0.0895397490, ... 
          0.0223971683 ];
  k = [  -0.5767489048,  0.3940083133,  0.2182357105,  0.0899134474, ... 
         0.0212450550 ];
  list_norm_dk = [   0.0022413738, 0.0018516455, 0.0012753333, 0.0008349626, ... 
                     0.0006526574, 0.0004572633, 0.0003212030, 0.0002143422, ... 
                     0.0001763643, 0.0001026072, 0.0000841566, 0.0000894283 ]';
  list_Esq = [   0.0001802411, 0.0001637251, 0.0001525449, 0.0001454303, ... 
                 0.0001400585, 0.0001364341, 0.0001339728, 0.0001324320, ... 
                 0.0001312509, 0.0001306251, 0.0001304232, 0.0001302443 ]';
  list_Asq_min = [   0.9154914234, 0.9189905778, 0.9215047117, 0.9231707137, ... 
                     0.9244672259, 0.9253586779, 0.9259718760, 0.9263595585, ... 
                     0.9266575459, 0.9268160367, 0.9268665499, 0.9269106299 ]';
  list_Asq_max = [   0.0000561813, 0.0000539487, 0.0000530504, 0.0000529332, ... 
                     0.0000532171, 0.0000533191, 0.0000535513, 0.0000537549, ... 
                     0.0000534505, 0.0000533087, 0.0000530802, 0.0000528821 ]';
  list_k{1} = [ -0.5804861724,  0.3907795106,  0.2155412747,  0.0898961818, ... 
                 0.0221045260 ];
  list_k{2} = [ -0.5794108652,  0.3914992468,  0.2168502940,  0.0898250737, ... 
                 0.0219155882 ];
  list_k{3} = [ -0.5785818811,  0.3921079906,  0.2175811830,  0.0897679473, ... 
                 0.0217388701 ];
  list_k{4} = [ -0.5780119530,  0.3925899991,  0.2179379667,  0.0897153496, ... 
                 0.0216391145 ];
  list_k{5} = [ -0.5775472878,  0.3929834983,  0.2181492453,  0.0896841111, ... 
                 0.0215411763 ];
  list_k{6} = [ -0.5772348239,  0.3932901810,  0.2182589849,  0.0896863706, ... 
                 0.0214680066 ];
  list_k{7} = [ -0.5770214310,  0.3935173671,  0.2183061371,  0.0897134097, ... 
                 0.0214126276 ];
  list_k{8} = [ -0.5768874014,  0.3936756289,  0.2183100701,  0.0897469388, ... 
                 0.0213702934 ];
  list_k{9} = [ -0.5767976908,  0.3938149609,  0.2183174421,  0.0897860612, ... 
                 0.0213249272 ];
  list_k{10} = [ -0.5767513696,  0.3938959308,  0.2183097629,  0.0898171082, ... 
                  0.0212965799 ];
  list_k{11} = [ -0.5767479120,  0.3939525470,  0.2182737600,  0.0898608334, ... 
                  0.0212709502 ];
  list_k{12} = [ -0.5767489048,  0.3940083133,  0.2182357105,  0.0899134474, ... 
                  0.0212450550 ];
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
