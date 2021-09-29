% directFIRsymmetric_sdp_lowpass_test.m
% Copyright (C) 2021 Robert G. Jenssen
%
% See "Efficient Large-Scale Filter/Filterbank Design via LMI
% Characterization of Trigonometric Curves", H. D. Tuan, T. T. Son,
% B. Vo and T. Q. Nguyen, IEEE Transactions on Signal Processing,
% Vol. 55, No. 9, September 2007, pp. 4393--4404

test_common;

delete("directFIRsymmetric_sdp_lowpass_test.diary");
delete("directFIRsymmetric_sdp_lowpass_test.diary.tmp");
diary directFIRsymmetric_sdp_lowpass_test.diary.tmp

%
% Initialise
%
strf="directFIRsymmetric_sdp_lowpass_test";

% Low pass filter (See Tuan et al. Table I). If I ignore SeDuMi
% numerical problems and use M=200,dBap=0.3,Was=200,dBas=65 then the
% result resembles Tuan et al. Figure 3.
for M=200:201,
  fap=0.03;Wap=1;dBap=1;
  Wat=0;
  fas=0.0358;Was=100;dBas=60;

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
  deltap=1-(10^(-dBap/20));
  deltas=10^(-dBas/20);
  Objective= ...
  sum(nu+((deltap-1)*y1(1))+((deltap+1)*y2(1))+(deltas*y3(1))+(deltas*y4(1)));

  % SDP constraint matrix
  [~,~,Q,q]=directFIRsymmetricEsqPW ...
              (zeros(M+1,1),2*pi*[0 fap fas 0.5],[1 0 0],[Wap,Wat,Was]);
  q=q(:);
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
    Options=sdpsettings('solver','sedumi');
    sol=optimize(Constraints,Objective,Options);
  catch
    error("Caught YALMIP error");
  end_try_catch
  if sol.problem
    error("YALMIP failed : %s",sol.info);
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
  printf("sum[(Ai*xs+di)*ys]=%g\n", sumAixspdiys);
  if sumAixspdiys > 1e-6
    error("sum[(Ai*xs+di)*ys](%g)>1e-6\n",sumAixspdiys);
  endif

  % Extract filter impulse response
  hM=flipud([xs(1);xs(2:end)/2]);

  %
  % Plot 
  %
  nplot=20000;
  wa=(0:nplot)'*pi/nplot;
  nap=ceil(nplot*fap/0.5)+1;
  nas=floor(nplot*fas/0.5)+1;
  A=directFIRsymmetricA(wa,hM);
  ax=plotyy(wa(1:nap)*0.5/pi,A(1:nap),wa(nas:end)*0.5/pi,A(nas:end));
  set(ax(1),'ycolor','black');
  set(ax(2),'ycolor','black');
  axis(ax(1),[0 0.5 1+(0.2*[-1 1])]);
  axis(ax(2),[0 0.5 0.001*2*[-1 1]]);
  ylabel("Amplitude");
  strt=sprintf("Tuan lowpass FIR : \
M=%d,fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g",M,fap,dBap,Wap,fas,dBas,Was);
  title(strt);
  xlabel("Frequency");
  grid("on");
  print(sprintf("%s_hM%3d_response",strf,M),"-dpdflatex");
  close

  %
  % Save the results
  %
  fid=fopen(sprintf("%s_hM%3d.spec",strf,M),"wt");
  fprintf(fid,"M=%d %% M+1 distinct coefficients\n",M);
  fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
  fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple(dB)\n",dBap);
  fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
  fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
  fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
  fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple(dB)\n",dBas);
  fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
  fclose(fid);

  print_polynomial(hM,sprintf("hM%3d",M));
  print_polynomial(hM,sprintf("hM%3d",M),sprintf("%s_hM%3d_coef.m",strf,M));

  eval(sprintf("save directFIRsymmetric_sdp_lowpass_test_hM%3d.mat ...\n\
         M nplot fap Wap dBap Wat fas Was dBas hM",M));
endfor

% Done
diary off
movefile directFIRsymmetric_sdp_lowpass_test.diary.tmp ...
         directFIRsymmetric_sdp_lowpass_test.diary;

