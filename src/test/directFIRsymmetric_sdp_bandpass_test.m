% directFIRsymmetric_sdp_bandpass_test.m
% Copyright (C) 2021 Robert G. Jenssen
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

delete("directFIRsymmetric_sdp_bandpass_test.diary");
delete("directFIRsymmetric_sdp_bandpass_test.diary.tmp");
diary directFIRsymmetric_sdp_bandpass_test.diary.tmp

%
% Initialise
%
strf="directFIRsymmetric_sdp_bandpass_test";

for M=15:16,
  fasl=0.05;fapl=0.15;fapu=0.25;fasu=0.35;
  deltap=1.54e-4;deltas=5e-3;
  Wap=1;Wat=0;Was=1;
  % Alternatively:
  %  deltap=1e-2;deltas=1e-3;
  %  Wap=1;Wat=0.01;Was=100;

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
  Objective= sum(nu+(deltas*y1(1))    +(deltas*y2(1))+ ...
                    ((deltap-1)*y3(1))+((deltap+1)*y4(1))+ ...
                    (deltas*y5(1))    +(deltas*y6(1)));

  % SDP constraint matrix
  [~,~,Q,q]=directFIRsymmetricEsqPW ...
              (zeros(M+1,1),2*pi*[0 fasl fapl fapu fasu 0.5], ...
               [0 0 1 0 0],[Was,Wat,Wap,Wat,Was]);
  q=q(:);
  FSDP=[nu, ((2*q)-y1+y2-y3+y4-y5+y6)' ; ((2*q)-y1+y2-y3+y4-y5+y6), 4*Q];

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
    sol=optimize(Constraints,Objective,Options);
  catch
    error("Caught YALMIP error");
  end_try_catch
  if sol.problem
    error("YALMIP failed : %s",sol.info);
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
  printf("sum[(Ai*xs+di)*ys]=%g\n", sumAixspdiys);
  if sumAixspdiys > 1e-5
    error("sum[(Ai*xs+di)*ys](%g)>1e-5\n",sumAixspdiys);
  endif

  % Extract filter impulse response
  hM=flipud([xs(1);xs(2:end)/2]);
  
  % Amplitude at local peaks
  nplot=20000;
  wa=(0:nplot)'*pi/nplot;
  nasl=floor(nplot*fasl/0.5)+1;
  napl=ceil(nplot*fapl/0.5)+1;
  napu=floor(nplot*fapu/0.5)+1;
  nasu=floor(nplot*fasu/0.5)+1;
  A=directFIRsymmetricA(wa,hM);
  vAl=local_max(-A);
  vAu=local_max(A);
  wAS=unique([wa(vAl);wa(vAu);wa([nasl,napl,napu,nasu])]);
  AS=directFIRsymmetricA(wAS,hM);
  printf("hM%2d:fAS=[ ",M);printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
  printf("hM%2d:AS=[ ",M);printf("%f ",20*log10(abs(AS)'));printf(" ] (dB)\n");

  %
  % Plot 
  %
  ax=plotyy(wa*0.5/pi,A,wa*0.5/pi,A);
  set(ax(1),'ycolor','black');
  set(ax(2),'ycolor','black');
  axis(ax(1),[0 0.5 1+(deltap*(6/5)*[-1 1])]);
  axis(ax(2),[0 0.5 deltas*(6/5)*[-1 1]]);
  ylabel("Amplitude");
  strt=sprintf("Tuan bandpass FIR : \
M=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g,deltap=%g,deltas=%g", ...
               M,fasl,fapl,fapu,fasu,deltap,deltas);
  title(strt);
  xlabel("Frequency");
  grid("on");
  print(sprintf("%s_hM%2d_response",strf,M),"-dpdflatex");
  close

  subplot(311)
  plot(wa(1:nasl)*0.5/pi,A(1:nasl));
  axis([0 fasl 0.01*[-1 1]]);
  grid("on");
  ylabel("Amplitude");
  strt=sprintf("Tuan band pass FIR : \
M=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g,deltap=%g,deltas=%g", ...
               M,fasl,fapl,fapu,fasu,deltap,deltas);
  title(strt);
  subplot(312)
  plot(wa(napl:napu)*0.5/pi,A(napl:napu));
  axis([fapl fapu 1+(0.0002*[-1 1])]);
  grid("on");
  ylabel("Amplitude");
  subplot(313)
  plot(wa(nasu:end)*0.5/pi,A(nasu:end));
  axis([fasu 0.5 0.01*[-1 1]]);
  grid("on");
  ylabel("Amplitude");
  xlabel("Frequency");
  print(sprintf("%s_hM%2d_pass_stop",strf,M),"-dpdflatex");
  close

  %
  % Save the results
  %
  fid=fopen(sprintf("%s_hM%2d.spec",strf,M),"wt");
  fprintf(fid,"M=%d %% M+1 distinct coefficients, order 2*M\n",M);
  fprintf(fid,"fasl=%g %% Amplitude lower stop band edge\n",fasl);
  fprintf(fid,"fapl=%g %% Amplitude lower pass band edge\n",fapl);
  fprintf(fid,"fapu=%g %% Amplitude upper pass band edge\n",fapu);
  fprintf(fid,"fasu=%g %% Amplitude upper stop band edge\n",fasu);
  fprintf(fid,"deltap=%g %% Amplitude pass band peak-to-peak ripple\n",deltap);
  fprintf(fid,"deltas=%g %% Amplitude stop band peak-to-peak ripple\n",deltas);
  fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
  fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
  fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
  fclose(fid);

  print_polynomial(hM,sprintf("hM%2d",M));
  print_polynomial(hM,sprintf("hM%2d",M),sprintf("%s_hM%2d_coef.m",strf,M));

  eval(sprintf("save directFIRsymmetric_sdp_bandpass_test_hM%2d.mat ...\n\
         M nplot fasl fapl fapu fasu deltap deltas Wap Wat Was hM",M));
endfor

% Done
diary off
movefile directFIRsymmetric_sdp_bandpass_test.diary.tmp ...
         directFIRsymmetric_sdp_bandpass_test.diary;

