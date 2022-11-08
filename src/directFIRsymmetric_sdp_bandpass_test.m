% directFIRsymmetric_sdp_bandpass_test.m
% Copyright (C) 2021-2022 Robert G. Jenssen
%
% See: "Efficient Large-Scale Filter/Filterbank Design via LMI
% Characterization of Trigonometric Curves", H. D. Tuan, T. T. Son,
% B. Vo and T. Q. Nguyen, IEEE Transactions on Signal Processing,
% Vol. 55, No. 9, September 2007, pp. 4393--4404
%
% Filter design is Figure 4 of: "GENERALIZING THE KYP LEMMA TO MULTIPLE
% FREQUENCY INTERVALS", GOELE PIPELEERS, TETSUYA IWASAKI, AND SHINJI HARA, 
% SIAM J. CONTROL OPTIM., Vol. 52, No. 6, pp. 3618–3638

test_common;

strf="directFIRsymmetric_sdp_bandpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

%
% Initialise
%

show_dB=false;
ignore_numerical_problems=false;

for M=[15,30,80],
  if M==15
    fasl=0.05;fapl=0.15;fapu=0.25;fasu=0.35;
    deltap=0.0002;deltas=0.005;
    Wasl=1;Watl=1;Wap=4;Watu=1;Wasu=1;
  elseif M==30
    fasl=0.10;fapl=0.15;fapu=0.25;fasu=0.30;
    deltap=0.001;deltas=10^(-50/20);
    Wasl=1;Watl=1;Wap=4;Watu=1;Wasu=1;
  elseif M==80
    fasl=0.15;fapl=0.175;fapu=0.275;fasu=0.30;
    deltap=0.0005;deltas=0.001;
    Wasl=1;Watl=1;Wap=4;Watu=1;Wasu=1;
  endif

  dBap=20*log10((1+deltap)/(1-deltap));
  dBas=-20*log10(deltas);
  
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
  y5=sdpvar(M+1,1);
  y6=sdpvar(M+1,1);
  Objective= sum(nu+ ...
                 (deltas*y1(1))    +(deltas*y2(1))+ ...
                 ((deltap-1)*y3(1))+((deltap+1)*y4(1))+ ...
                 (deltas*y5(1))    +(deltas*y6(1)));

  % SDP constraint matrix
  [~,~,Q,q]=directFIRsymmetricEsqPW(zeros(M+1,1), ...
                                    2*pi*[0,fasl,fapl,fapu,fasu,0.5], ...
                                    [0 0 1 0 0], ...
                                    [Wasl,Watl,Wap,Watu,Wasu]);
  if ~isdefinite(Q)
    error("Q is not positive semi-definite")
  endif
  q=q(:);
  FSDP=[nu,                        ((2*q)-y1+y2-y3+y4-y5+y6)' ; ...
        ((2*q)-y1+y2-y3+y4-y5+y6), 4*Q];

  % Conic constraints
  cosa1=cos(2*pi*fasl);
  cosb1=1;
  cosa2=cos(2*pi*fasl);
  cosb2=1;
  cosa3=cos(2*pi*fapu);
  cosb3=cos(2*pi*fapl);
  cosa4=cos(2*pi*fapu);
  cosb4=cos(2*pi*fapl);
  cosa5=-1;
  cosb5=cos(2*pi*fasu);
  cosa6=-1;
  cosb6=cos(2*pi*fasu);
  % T0k
  T0k_y1=sdpvar(k+1,k+1);
  T0k_y1=zeros(k+1,k+1);
  T0k_y2=sdpvar(k+1,k+1);
  T0k_y2=zeros(k+1,k+1);
  T0k_y3=sdpvar(k+1,k+1);
  T0k_y3=zeros(k+1,k+1);
  T0k_y4=sdpvar(k+1,k+1);
  T0k_y4=zeros(k+1,k+1);
  T0k_y5=sdpvar(k+1,k+1);
  T0k_y5=zeros(k+1,k+1);
  T0k_y6=sdpvar(k+1,k+1);
  T0k_y6=zeros(k+1,k+1);
  for m=0:M,
    T0k_y1=T0k_y1+(y1(m+1)*E0k{m+1});
    T0k_y2=T0k_y2+(y2(m+1)*E0k{m+1});
    T0k_y3=T0k_y3+(y3(m+1)*E0k{m+1});
    T0k_y4=T0k_y4+(y4(m+1)*E0k{m+1});
    T0k_y5=T0k_y5+(y5(m+1)*E0k{m+1});
    T0k_y6=T0k_y6+(y6(m+1)*E0k{m+1});
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
    T0km1_y5=sdpvar(k,k);
    T0km1_y5=zeros(k,k);
    T0km1_y6=sdpvar(k,k);
    T0km1_y6=zeros(k,k);
    for m=0:(M-2),
      T0km1_y1=T0km1_y1+(y1(m+1)*E0km1{m+1});
      T0km1_y2=T0km1_y2+(y2(m+1)*E0km1{m+1});
      T0km1_y3=T0km1_y3+(y3(m+1)*E0km1{m+1});
      T0km1_y4=T0km1_y4+(y4(m+1)*E0km1{m+1});
      T0km1_y5=T0km1_y5+(y5(m+1)*E0km1{m+1});
      T0km1_y6=T0km1_y6+(y6(m+1)*E0km1{m+1});
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
    T1km1_y5=sdpvar(k,k);
    T1km1_y5=zeros(k,k);
    T1km1_y6=sdpvar(k,k);
    T1km1_y6=zeros(k,k);
    for m=0:(M-1),
      T1km1_y1=T1km1_y1+(y1(m+1)*E1km1{m+1});
      T1km1_y2=T1km1_y2+(y2(m+1)*E1km1{m+1});
      T1km1_y3=T1km1_y3+(y3(m+1)*E1km1{m+1});
      T1km1_y4=T1km1_y4+(y4(m+1)*E1km1{m+1});
      T1km1_y5=T1km1_y5+(y5(m+1)*E1km1{m+1});
      T1km1_y6=T1km1_y6+(y6(m+1)*E1km1{m+1});
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
    T2km1_y5=sdpvar(k,k);
    T2km1_y5=zeros(k,k);
    T2km1_y6=sdpvar(k,k);
    T2km1_y6=zeros(k,k);
    for m=0:M,
      T2km1_y1=T2km1_y1+(y1(m+1)*E2km1{m+1});
      T2km1_y2=T2km1_y2+(y2(m+1)*E2km1{m+1});
      T2km1_y3=T2km1_y3+(y3(m+1)*E2km1{m+1});
      T2km1_y4=T2km1_y4+(y4(m+1)*E2km1{m+1});
      T2km1_y5=T2km1_y5+(y5(m+1)*E2km1{m+1});
      T2km1_y6=T2km1_y6+(y6(m+1)*E2km1{m+1});
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
    Fabk_y5=sdpvar(k,k);
    Fabk_y5=((cosa5+cosb5)*T1km1_y5)-(T2km1_y5/2)-((0.5+(cosa5*cosb5))*T0km1_y5);
    Fabk_y6=sdpvar(k,k);
    Fabk_y6=((cosa6+cosb6)*T1km1_y6)-(T2km1_y6/2)-((0.5+(cosa6*cosb6))*T0km1_y6);

    Constraints=[FSDP>=0, ...
                 T0k_y1>=0, Fabk_y1>=0, ...
                 T0k_y2>=0, Fabk_y2>=0, ...
                 T0k_y3>=0, Fabk_y3>=0, ...
                 T0k_y4>=0, Fabk_y4>=0, ...
                 T0k_y5>=0, Fabk_y5>=0, ...
                 T0k_y6>=0, Fabk_y6>=0];
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
    T1k_y5=sdpvar(k+1,k+1);
    T1k_y5=zeros(k+1,k+1);
    T1k_y6=sdpvar(k+1,k+1);
    T1k_y6=zeros(k+1,k+1);
    for m=0:M,
      T1k_y1=T1k_y1+(y1(m+1)*E1k{m+1});
      T1k_y2=T1k_y2+(y2(m+1)*E1k{m+1});
      T1k_y3=T1k_y3+(y3(m+1)*E1k{m+1});
      T1k_y4=T1k_y4+(y4(m+1)*E1k{m+1});
      T1k_y5=T1k_y5+(y5(m+1)*E1k{m+1});
      T1k_y6=T1k_y6+(y6(m+1)*E1k{m+1});
    endfor
    
    Constraints=[FSDP>=0, ...
                 (cosb1*T0k_y1)>=T1k_y1, T1k_y1>=(cosa1*T0k_y1), ...
                 (cosb2*T0k_y2)>=T1k_y2, T1k_y2>=(cosa2*T0k_y2), ...
                 (cosb3*T0k_y3)>=T1k_y3, T1k_y3>=(cosa3*T0k_y3), ...
                 (cosb4*T0k_y4)>=T1k_y4, T1k_y4>=(cosa4*T0k_y4), ...
                 (cosb5*T0k_y5)>=T1k_y5, T1k_y5>=(cosa5*T0k_y5), ...
                 (cosb6*T0k_y6)>=T1k_y6, T1k_y6>=(cosa6*T0k_y6)];
  endif


  %
  % Call YALMIP
  %
  try
    Options=sdpsettings('solver','sedumi');
    sol=optimize(Constraints,Objective,Options)
  catch
    error("Caught YALMIP error : M=%d",M);
  end_try_catch
  if sol.problem && ~((sol.problem==4) && ignore_numerical_problems)
    error("YALMIP failed : M=%d",M);
  endif
  % Find xs (left division fails here ?!?!?)
  xs=-0.5*inv(Q)*((2*q)-value(y1-y2+y3-y4+y5-y6));
  
  % Sanity checks
  check(Constraints)
  printf("nu=%g\n",value(nu))
  sumAixspdiys= ...
    [ xs+[deltas;zeros(M,1)]]'*value(y1) + ...
    [-xs+[deltas;zeros(M,1)]]'*value(y2) + ...
    [ xs+[(deltap-1);zeros(M,1)]]'*value(y3) + ...
    [-xs+[(deltap+1);zeros(M,1)]]'*value(y4) + ...
    [ xs+[deltas;zeros(M,1)]]'*value(y5) + ...
    [-xs+[deltas;zeros(M,1)]]'*value(y6);
  printf("sum((Ai*xs+di)*ys)=%g\n", sumAixspdiys);
  tol=4e-6;
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
  nplot=2000;
  nasl=floor(nplot*fasl/0.5)+1;
  napl=ceil(nplot*fapl/0.5)+1;
  napu=floor(nplot*fapu/0.5)+1;
  nasu=floor(nplot*fasu/0.5)+1;
  fa=(0:nplot)'*0.5/nplot;
  A=directFIRsymmetricA(2*pi*fa,hM);
  if show_dB
    ax=plotyy(fa, 20*log10(abs(A)), fa, 20*log10(abs(A)));
    if M==15
      axis(ax(1),[0 0.5 (0.002*[-1 1])]);
    elseif M==30
      axis(ax(1),[0 0.5 (0.01*[-1 1])]);
    elseif M==80
      axis(ax(1),[0 0.5 (0.01*[-1 1])]);
    endif
    axis(ax(2),[0 0.5 -70 -30]);
    ylabel("Amplitude(dB)");
  else
    ax=plotyy(fa,A,fa,A);
    if M==15
      axis(ax(1),[0 0.5 1+(0.0004*[-1 1])]);
      axis(ax(2),[0 0.5 0.01*[-1 1]]);
    elseif M==30
      axis(ax(1),[0 0.5 1+(0.002*[-1 1])]);
      axis(ax(2),[0 0.5 0.004*[-1 1]]);
    elseif M==80
       axis(ax(1),[0 0.5 1+(0.001*[-1 1])]);
       axis(ax(2),[0 0.5 0.002*[-1 1]]);
    endif
    ylabel("Amplitude");
  endif
  set(ax(1),"ycolor","black");
  set(ax(2),"ycolor","black");
  if show_dB
    strt=sprintf("Tuan band-pass FIR : \
M=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g,dBap=%g,dBas=%g,Wap=%g", ...
                 M,fasl,fapl,fapu,fasu,dBap,dBas,Wap);
  else
    strt=sprintf("Tuan band-pass FIR : \
M=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g,deltap=%g,deltas=%g,Wap=%g", ...
                 M,fasl,fapl,fapu,fasu,deltap,deltas,Wap);
  endif
  title(strt);
  xlabel("Frequency");
  grid("on");
  print(sprintf("%s_hM%2d_dual_response",strf,M),"-dpdflatex");
  close

  plot(fa, 20*log10(abs(A)));
  axis([0,0.5,-dBas-10,10]);
  xlabel("Frequency");
  ylabel("Amplitude");
  grid("on");
  title(strt);
  print(sprintf("%s_hM%2d_response",strf,M),"-dpdflatex");
  close
  
  % Amplitude at local peaks
  vAl=local_max(-A);
  vAu=local_max(A);
  fAS=unique([fa(vAl);fa(vAu);fa([nasl,napl,napu,nasu])]);
  AS=directFIRsymmetricA(2*pi*fAS,hM);

  [maxAsl,ifmaxAsl]=max(abs(A(1:nasl)));             fmaxAsl=fa(0     +ifmaxAsl);
  [minAtl,ifminAtl]=min(abs(A((nasl+1):(napl-1))));  fminAtl=fa(nasl  +ifminAtl);
  [maxAtl,ifmaxAtl]=max(abs(A((nasl+1):(napl-1))));  fmaxAtl=fa(nasl  +ifmaxAtl);
  [maxAp,ifmaxAp]=max(abs(A(napl:napu)));            fmaxAp= fa(napl-1+ifmaxAp);
  [minAp,ifminAp]=min(abs(A(napl:napu)));            fminAp= fa(napl-1+ifminAp);
  [maxAtu,ifmaxAtu]=max(abs(A((napu+1):(nasu-1))));  fmaxAtu=fa(napu  +ifmaxAtu);
  [minAtu,ifminAtu]=min(abs(A((napu+1):(nasu-1))));  fminAtu=fa(napu  +ifminAtu);
  [maxAsu,ifmaxAsu]=max(abs(A(nasu:end)));           fmaxAsu=fa(nasu-1+ifmaxAsu);
  
  if show_dB
    printf("hM%2d:fAS=[ ",M);printf("%f ",fAS');printf(" ] (fs==1)\n");
    printf("hM%2d:AS=[ ",M);printf("%f ",20*log10(abs(AS)'));printf(" ] (dB)\n");
    printf("max. lower stop-band amplitude %g (dB) at %g\n", ...
           20*log10(maxAsl),fmaxAsl);
    printf("min. lower trans.-band amplitude %g (dB) at %g\n", ...
           20*log10(minAtl),fminAtl);
    printf("max. lower trans.-band amplitude %g (dB) at %g\n", ...
           20*log10(maxAtl),fmaxAtl);
    printf("max. pass-band amplitude %g (dB) at %g\n", ...
           20*log10(maxAp),fmaxAp);
    printf("min. pass-band amplitude %g (dB) at %g\n", ...
           20*log10(minAp),fminAp);
    printf("max. upper trans.-band amplitude %g (dB) at %g\n", ...
           20*log10(maxAtu),fmaxAtu);
    printf("min. upper trans.-band amplitude %g (dB) at %g\n", ...
           20*log10(minAtu),fminAtu);
    printf("max. upper stop-band amplitude %g (dB) at %g\n", ...
           20*log10(maxAsu),fmaxAsu);
  else
    printf("hM%2d:fAS=[ ",M);printf("%f ",fAS');printf(" ] (fs==1)\n");
    printf("hM%2d:AS=[ ",M);printf("%f ",abs(AS)');printf(" ]\n");
    printf("max. lower stop-band amplitude %g at %g\n", maxAsl,fmaxAsl);
    printf("min. lower trans.-band amplitude %g at %g\n", minAtl,fminAtl);
    printf("max. lower trans.-band amplitude %g at %g\n", maxAtl,fmaxAtl);
    printf("max. pass-band amplitude %g at %g\n",  maxAp,fmaxAp);
    printf("min. pass-band amplitude %g at %g\n",  minAp,fminAp);
    printf("max. upper trans.-band amplitude %g at %g\n", maxAtu,fmaxAtu);
    printf("min. upper trans.-band amplitude %g at %g\n", minAtu,fminAtu);
    printf("max. upper stop-band amplitude %g at %g\n", maxAsu,fmaxAsu);
  endif

  % Sanity checks
  [Esq,~,Q,q]=directFIRsymmetricEsqPW(hM,2*pi*[0,fasl,fapl,fapu,fasu,0.5], ...
                                      [0 0 1 0 0],[1,1,1,1,1]);
  printf("hM%2d:Esq %g\n",M,Esq);
  Esq_err=abs(Esq-((hM'*Q*hM)+(2*q*hM)+(2*(fapu-fapl))));
  if Esq_err > eps
    error("Esq_err(%g) > eps",Esq_err);
  endif
  [Esq,~,Q,q]=directFIRsymmetricEsqPW(hM,2*pi*[0,fasl,fapl,fapu,fasu,0.5], ...
                                      [0 0 1 0 0],[Wasl,Watl,Wap,Watu,Wasu]);
  printf("hM%2d:Esq(weighted) %g\n",M,Esq);
  Esq_err=abs(Esq-((hM'*Q*hM)+(2*q*hM)+(2*(fapu-fapl)*Wap)));
  if Esq_err > eps
    error("Esq_err(weighted)(%g) > eps",Esq_err);
  endif

  %
  % Save the results
  %
  fid=fopen(sprintf("%s_hM%2d.spec",strf,M),"wt");
  fprintf(fid,"M=%d %% M+1 distinct coefficients, FIR filter order 2*M\n",M);
  fprintf(fid,"fasl=%g %% Amplitude lower stop band edge\n",fasl);
  fprintf(fid,"fapl=%g %% Amplitude lower pass band edge\n",fapl);
  fprintf(fid,"fapu=%g %% Amplitude upper pass band edge\n",fapu);
  fprintf(fid,"fasu=%g %% Amplitude upper stop band edge\n",fasu);
  fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple(dB)\n",dBap);
  fprintf(fid,"deltap=%g %% Amplitude pass band peak ripple(dB)\n",deltap);
  fprintf(fid,"dBas=%g %% Amplitude stop band peak ripple(dB)\n",dBas);
  fprintf(fid,"deltas=%g %% Amplitude stop band peak ripple(dB)\n",deltas);
  fprintf(fid,"Wasl=%g %% Amplitude lower stop band weight\n",Wasl);
  fprintf(fid,"Watl=%g %% Amplitude lower trans. band weight\n",Watl);
  fprintf(fid,"Wap =%g %% Amplitude pass band weight\n",Wap);
  fprintf(fid,"Watu=%g %% Amplitude upper trans. band weight\n",Watu);
  fprintf(fid,"Wasu=%g %% Amplitude upper stop band weight\n",Wasu);
  fclose(fid);

  print_polynomial(hM,sprintf("hM%2d",M));
  print_polynomial(hM,sprintf("hM%2d",M),sprintf("%s_hM%2d_coef.m",strf,M));

  eval(sprintf("save %s_hM%2d.mat M nplot fasl fapl fapu fasu dBap dBas \
Wasl Watl Wap Watu Wasu hM",strf,M));
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
