% directFIRsymmetric_sdp_lowpass_test.m
% Copyright (C) 2021-2022 Robert G. Jenssen
%
% See "Efficient Large-Scale Filter/Filterbank Design via LMI
% Characterization of Trigonometric Curves", H. D. Tuan, T. T. Son,
% B. Vo and T. Q. Nguyen, IEEE Transactions on Signal Processing,
% Vol. 55, No. 9, September 2007, pp. 4393--4404

test_common;

strf="directFIRsymmetric_sdp_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

%
% Initialise
%

show_dB=false;
ignore_numerical_problems=false;

% Low pass filter
for M=[31,200],

  if M==31
    fap=0.05;fas=0.10;dBap=0.04;dBas=60;Wap=1;Wat=1;Was=1;
  elseif M==200
    % See Tuan et al. Table I and Figure 3.(fap=0.03,dBap=0.3,fas=0.358,dBas=60)
    fap=0.03;dBap=0.3;fas=0.0364;dBas=60;Wap=1;Wat=1;Was=1;
    if 0,
      ignore_numerical_problems=true;dBap=0.5;fas=0.0358; % This works
    elseif 0
      ignore_numerical_problems=true;M=212;fas=0.0358;
    elseif 0
      M=221;fas=0.0358;
    endif
  endif

  deltap=((10^(dBap/20))-1)/((10^(dBap/20))+1);
  deltas=10^(-dBas/20);
  
  %
  % Set up the YALMIP problem
  %

  % Initialise basis matrixes
  k=floor(M/2);
  if rem(round(M),2)==0
    [E0k,E0km1,E1km1,E2km1]=directFIRsymmetric_sdp_basis(M);
  else
    [E0k,E1k]=directFIRsymmetric_sdp_basis(M);
  endif

  % Objective 
  nu=sdpvar(1,1);
  y1=sdpvar(M+1,1);
  y2=sdpvar(M+1,1);
  y3=sdpvar(M+1,1);
  y4=sdpvar(M+1,1);
  Objective=sum(nu+((deltap-1)*y1(1))+((deltap+1)*y2(1))+ ...
                   (deltas   *y3(1))+ (deltas   *y4(1)));

  % SDP constraint matrix
  [~,~,Q,q]=directFIRsymmetricEsqPW ...
              (zeros(M+1,1),2*pi*[0 fap fas 0.5],[1 0 0],[Wap,Wat,Was]);
  q=q(:);
  if ~isdefinite(Q)
    error("Q is not positive semi-definite")
  endif
  FSDP=[nu, ((2*q)-y1+y2-y3+y4)' ; ((2*q)-y1+y2-y3+y4), 4*Q];

  % Conic constraints
  cosa1=cos(2*pi*fap);
  cosb1=1;
  cosa2=cos(2*pi*fap);
  cosb2=1;
  cosa3=-1;
  cosb3=cos(2*pi*fas);
  cosa4=-1;
  cosb4=cos(2*pi*fas);
  % T0k
  T0k_y1=sdpvar(k+1,k+1);
  T0k_y1=zeros(k+1,k+1);
  T0k_y2=sdpvar(k+1,k+1);
  T0k_y2=zeros(k+1,k+1);
  T0k_y3=sdpvar(k+1,k+1);
  T0k_y3=zeros(k+1,k+1);
  T0k_y4=sdpvar(k+1,k+1);
  T0k_y4=zeros(k+1,k+1);
  for m=0:M,
    T0k_y1=T0k_y1+(y1(m+1)*E0k{m+1});
    T0k_y2=T0k_y2+(y2(m+1)*E0k{m+1});
    T0k_y3=T0k_y3+(y3(m+1)*E0k{m+1});
    T0k_y4=T0k_y4+(y4(m+1)*E0k{m+1});
  endfor
  if rem(M,2)==0
    % T0km1
    T0km1_y1=sdpvar(k,k);
    T0km1_y1=zeros(k,k);
    T0km1_y2=sdpvar(k,k);
    T0km1_y2=zeros(k,k);
    T0km1_y3=sdpvar(k,k);
    T0km1_y3=zeros(k,k);
    T0km1_y4=sdpvar(k,k);
    T0km1_y4=zeros(k,k);
    for m=0:(M-2),
      T0km1_y1=T0km1_y1+(y1(m+1)*E0km1{m+1});
      T0km1_y2=T0km1_y2+(y2(m+1)*E0km1{m+1});
      T0km1_y3=T0km1_y3+(y3(m+1)*E0km1{m+1});
      T0km1_y4=T0km1_y4+(y4(m+1)*E0km1{m+1});
    endfor
    % T1km1
    T1km1_y1=sdpvar(k,k);
    T1km1_y1=zeros(k,k);
    T1km1_y2=sdpvar(k,k);
    T1km1_y2=zeros(k,k);
    T1km1_y3=sdpvar(k,k);
    T1km1_y3=zeros(k,k);
    T1km1_y4=sdpvar(k,k);
    T1km1_y4=zeros(k,k);
    for m=0:(M-1),
      T1km1_y1=T1km1_y1+(y1(m+1)*E1km1{m+1});
      T1km1_y2=T1km1_y2+(y2(m+1)*E1km1{m+1});
      T1km1_y3=T1km1_y3+(y3(m+1)*E1km1{m+1});
      T1km1_y4=T1km1_y4+(y4(m+1)*E1km1{m+1});
    endfor
    % T2km1
    T2km1_y1=sdpvar(k,k);
    T2km1_y1=zeros(k,k);
    T2km1_y2=sdpvar(k,k);
    T2km1_y2=zeros(k,k);
    T2km1_y3=sdpvar(k,k);
    T2km1_y3=zeros(k,k);
    T2km1_y4=sdpvar(k,k);
    T2km1_y4=zeros(k,k);
    for m=0:M,
      T2km1_y1=T2km1_y1+(y1(m+1)*E2km1{m+1});
      T2km1_y2=T2km1_y2+(y2(m+1)*E2km1{m+1});
      T2km1_y3=T2km1_y3+(y3(m+1)*E2km1{m+1});
      T2km1_y4=T2km1_y4+(y4(m+1)*E2km1{m+1});
    endfor
    
    % Fabk
    Fabk_y1=sdpvar(k,k);
    Fabk_y1=((cosa1+cosb1)*T1km1_y1)-(T2km1_y1/2)-((0.5+(cosa1*cosb1))*T0km1_y1);
    Fabk_y2=sdpvar(k,k);
    Fabk_y2=((cosa2+cosb2)*T1km1_y2)-(T2km1_y2/2)-((0.5+(cosa2*cosb2))*T0km1_y2);
    Fabk_y3=sdpvar(k,k);
    Fabk_y3=((cosa3+cosb3)*T1km1_y3)-(T2km1_y3/2)-((0.5+(cosa3*cosb3))*T0km1_y3);
    Fabk_y4=sdpvar(k,k);
    Fabk_y4=((cosa4+cosb4)*T1km1_y4)-(T2km1_y4/2)-((0.5+(cosa4*cosb4))*T0km1_y4);

    Constraints=[FSDP>=0, ...
                 T0k_y1>=0, Fabk_y1>=0, ...
                 T0k_y2>=0, Fabk_y2>=0, ...
                 T0k_y3>=0, Fabk_y3>=0, ...
                 T0k_y4>=0, Fabk_y4>=0];
  else
    % T1k
    T1k_y1=sdpvar(k+1,k+1);
    T1k_y1=zeros(k+1,k+1);
    T1k_y2=sdpvar(k+1,k+1);
    T1k_y2=zeros(k+1,k+1);
    T1k_y3=sdpvar(k+1,k+1);
    T1k_y3=zeros(k+1,k+1);
    T1k_y4=sdpvar(k+1,k+1);
    T1k_y4=zeros(k+1,k+1);
    for m=0:M,
      T1k_y1=T1k_y1+(y1(m+1)*E1k{m+1});
      T1k_y2=T1k_y2+(y2(m+1)*E1k{m+1});
      T1k_y3=T1k_y3+(y3(m+1)*E1k{m+1});
      T1k_y4=T1k_y4+(y4(m+1)*E1k{m+1});
    endfor
    
    Constraints=[FSDP>=0, ...
                 (cosb1*T0k_y1)>=T1k_y1, T1k_y1>=(cosa1*T0k_y1), ...
                 (cosb2*T0k_y2)>=T1k_y2, T1k_y2>=(cosa2*T0k_y2), ...
                 (cosb3*T0k_y3)>=T1k_y3, T1k_y3>=(cosa3*T0k_y3), ...
                 (cosb4*T0k_y4)>=T1k_y4, T1k_y4>=(cosa4*T0k_y4)];
  endif


  %
  % Call YALMIP
  %
  try
    Options=sdpsettings("solver","sedumi");
    sol=optimize(Constraints,Objective,Options)
  catch
    error("Caught YALMIP error : M=%d",M);
  end_try_catch
  if sol.problem && ~((sol.problem==4) && ignore_numerical_problems)
    error("YALMIP failed : M=%d",M);
  endif
  % Find xs (left division fails here ?!?!?)
  xs=-0.5*inv(Q)*((2*q)-value(y1-y2+y3-y4));
  
  % Sanity checks
  check(Constraints)
  printf("nu=%g\n",value(nu))
  sumAixspdiys=[ xs+[(deltap-1);zeros(M,1)]]'*value(y1) + ...
               [-xs+[(deltap+1);zeros(M,1)]]'*value(y2) + ...
               [ xs+[deltas;zeros(M,1)]]'*value(y3) + ...
               [-xs+[deltas;zeros(M,1)]]'*value(y4);
  printf("sum((Ai*xs+di)*ys)=%g\n", sumAixspdiys);
  tol=2.5e-8;
  if abs(sumAixspdiys) > tol
    stre=sprintf("M=%d, abs(sum(((Ai*xs)+di)*ys))(%g)>%g\n",M,abs(sumAixspdiys),tol);
    if ignore_numerical_problems
      warning(stre);
    else
      error(stre);
    endif
  endif

  % Extract filter impulse response
  hM=flipud([xs(1);xs(2:end)/2]);

  %
  % Plot 
  %
  nplot=20000;
  nap=ceil(nplot*fap/0.5)+1;
  nas=floor(nplot*fas/0.5)+1;
  fa=(0:nplot)'*0.5/nplot;
  A=directFIRsymmetricA(2*pi*fa,hM);
  if show_dB
    ax=plotyy(fa(1:nap),  20*log10(abs(A(1:nap))), ...
              fa(nas:end),20*log10(abs(A(nas:end))));
    if M==31
      axis(ax(1),[0 0.5 0.04*[-1 1]]);
    else
      axis(ax(1),[0 0.5 0.4*[-1 1]]);
    endif
    axis(ax(2),[0 0.5 -80 -40]);
    ylabel("Amplitude(dB)");
  else
    ax=plotyy(fa(1:nap), A(1:nap), fa(nas:end),A(nas:end));
    if M==31
      axis(ax(1),[0 0.5 1+(0.004*[-1 1])]);
      axis(ax(2),[0 0.5 0.002*[-1 1]]);
    else
      axis(ax(1),[0 0.5 1+(0.04*[-1 1])]);
      axis(ax(2),[0 0.5 0.002*[-1 1]]);
    endif
    ylabel("Amplitude");
  endif
  if show_dB
    strt=sprintf("Tuan low-pass FIR : \
M=%d,fap=%g,fas=%g,dBap=%g,dBas=%g",M,fap,fas,dBap,dBas);
  else
    strt=sprintf("Tuan low-pass FIR : \
M=%d,fap=%g,fas=%g,deltap=%g,deltas=%g",M,fap,fas,deltap,deltas);
  endif
  title(strt);
  xlabel("Frequency");
  grid("on");
  print(sprintf("%s_hM%03d_dual_response",strf,M),"-dpdflatex"); 
  close

  plot(fa, 20*log10(abs(A)));
  axis([0,0.5,-dBas-10,10]);
  xlabel("Frequency");
  ylabel("Amplitude");
  grid("on");
  title(strt);
  print(sprintf("%s_hM%03d_response",strf,M),"-dpdflatex");
  close
  
  % Max-min amplitudes
  [maxAp,ifmaxAp]=max(abs(A(1:nap)));           fmaxAp=fa(      ifmaxAp);
  [minAp,ifminAp]=min(abs(A(1:nap)));           fminAp=fa(      ifminAp);
  [maxAt,ifmaxAt]=max(abs(A((nap+1):(nas-1)))); fmaxAt=fa(nap  +ifmaxAt);
  [minAt,ifminAt]=min(abs(A((nap+1):(nas-1)))); fminAt=fa(nap  +ifminAt);
  [maxAs,ifmaxAs]=max(abs(A(nas:end)));         fmaxAs=fa(nas-1+ifmaxAs);
  
  if show_dB
    printf("max. pass-band   amplitude %g (dB) at %g\n", 20*log10(maxAp),fmaxAp);
    printf("min. pass-band   amplitude %g (dB) at %g\n", 20*log10(minAp),fminAp);
    printf("max. trans.-band amplitude %g (dB) at %g\n", 20*log10(maxAt),fmaxAt);
    printf("min. trans.-band amplitude %g (dB) at %g\n", 20*log10(minAt),fminAt);
    printf("max. stop-band   amplitude %g (dB) at %g\n", 20*log10(maxAs),fmaxAs);
  else
    printf("max. pass-band   amplitude %g at %g\n", maxAp,fmaxAp);
    printf("min. pass-band   amplitude %g at %g\n", minAp,fminAp);
    printf("max. trans.-band amplitude %g at %g\n", maxAt,fmaxAt);
    printf("min. trans.-band amplitude %g at %g\n", minAt,fminAt);
    printf("max. stop-band   amplitude %g at %g\n", maxAs,fmaxAs);
  endif
  
  % Sanity check
  [Esq,~,Q,q]=directFIRsymmetricEsqPW(hM,2*pi*[0,fap,fas,0.5], ...
                                      [1 0 0 ],[1,1,1]);
  printf("hM%2d:Esq %g\n",M,Esq);
  Esq_err=abs(Esq-((hM'*Q*hM)+(2*q*hM)+(2*fap)));
  if Esq_err > eps
    error("Esq_err(%g) > eps",Esq_err);
  endif
  [Esq,~,Q,q]=directFIRsymmetricEsqPW(hM,2*pi*[0,fap,fas,0.5], ...
                                      [1 0 0 ],[Wap,Wat,Was]);
  printf("hM%2d:Esq(weighted) %g\n",M,Esq);
  Esq_err=abs(Esq-((hM'*Q*hM)+(2*q*hM)+(2*fap*Wap)));
  if Esq_err > eps
    error("Esq_err(weighted)(%g) > eps",Esq_err);
  endif

  %
  % Save the results
  %
  fid=fopen(sprintf("%s_hM%03d.spec",strf,M),"wt");
  fprintf(fid,"M=%d %% M+1 distinct coefficients, FIR filter order 2*M\n",M);
  fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
  fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
  fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple(dB)\n",dBap);
  fprintf(fid,"deltap=%g %% Amplitude pass band peak ripple\n",deltap);
  fprintf(fid,"dBas=%g %% Amplitude stop band peak ripple(dB)\n",dBas);
  fprintf(fid,"deltas=%g %% Amplitude stop band peak ripple\n",deltas);
  fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
  fprintf(fid,"Wat=%g %% Amplitude trans. band weight\n",Wat);
  fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
  fclose(fid);

  print_polynomial(hM,sprintf("hM%03d",M));
  print_polynomial(hM,sprintf("hM%03d",M),sprintf("%s_hM%03d_coef.m",strf,M));

  eval(sprintf("save %s_hM%03d.mat M nplot fap fas dBap dBas deltap deltas \
Wap Wat Was hM",strf,M));
endfor

% Done
diary off
movefile(sprintf("%s.diary.tmp",strf), sprintf("%s.diary",strf));
