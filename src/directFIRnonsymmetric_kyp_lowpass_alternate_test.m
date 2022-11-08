% directFIRnonsymmetric_kyp_lowpass_alternate_test.m
% Copyright (C) 2021-2022 Robert G. Jenssen
%
% Experiments on SDP design of a direct-form FIR lowpass filter with the
% KYP lemma. See Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma: Unified
% Frequency Domain Inequalities With Design Applications", T. Iwasaki
% and S. Hara, IEEE Transactions on Automatic Control, Vol. 50, No. 1,
% January 2005, pp. 41–59
%
% Note that:
% 1. The YALMIP, Octave, Symbolic Toolbox and SymPy combination
% requires that the KYP constraints have rows enclosed in square brackets.
% 2. In altspec=2:3 I optimise Esq_s or Esq_z with a constraint. I found that
% optimising with Esq_z or Esq_s as the objective function caused "Run into
% numerical problems" warnings.
% 3. It seems that is best to optimise with an empty objective function and
% with constraints found by trial-and-error.
% 4. Expanding the KYP constraint with the kron() function seems to give
% better results than doing it "by-hand".

test_common;

strf="directFIRnonsymmetric_kyp_lowpass_alternate_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Alternative filter specifications
for altspec=1:9
  printf("\n\n altspec=%d\n\n",altspec);
  if altspec==1
    % Example of Iwasaki and Hara
    N=30,d=10,fap=0.15,fas=0.2,Esq_max=1,Esq_z=0.00567,Esq_s=1e-4
    constrain_Esq_max=false
    optimise_Esq_s=false
    optimise_Esq_z=false
    Objective=[];
  elseif altspec==2
    N=30,d=N/2,fap=0.15,fas=0.2,Esq_max=1,Esq_z=1e-3,Esq_s=1e-3
    constrain_Esq_max=false
    optimise_Esq_s=false
    optimise_Esq_z=false
    Objective=[];
  elseif altspec==3
    N=30,d=10,fap=0.15,fas=0.2,Esq_max=1,Esq_z=0.00569,Esq_opt=1e-4
    constrain_Esq_max=false
    optimise_Esq_z=false
    optimise_Esq_s=true
    Esq_s=sdpvar(1,1);
    Objective=[];
  elseif altspec==4
    N=30,d=10,fap=0.15,fas=0.2,Esq_max=1,Esq_s=1e-4,Esq_opt=0.00569
    constrain_Esq_max=false
    optimise_Esq_s=false
    optimise_Esq_z=true
    Esq_z=sdpvar(1,1);
    Objective=[]; 
  elseif altspec==5
    N=30,d=10,fap=0.15,fas=0.2,Esq_max=1.1,Esq_z=0.07598^2,Esq_s=1e-4
    constrain_Esq_max=true
    optimise_Esq_s=false
    optimise_Esq_z=false
    Objective=[];
  elseif altspec==6
    N=54,d=N/2,fap=0.15,fas=0.2,Esq_max=1,Esq_z=1e-5,Esq_s=1e-5
    constrain_Esq_max=false
    optimise_Esq_s=false
    optimise_Esq_z=false
    Objective=[];
  elseif altspec==7
    N=30,fap=0.1,d=10,fas=0.2,Esq_max=1,Esq_z=1e-6,Esq_s=1e-4
    constrain_Esq_max=true
    optimise_Esq_s=false
    optimise_Esq_z=false
    Objective=[];
  elseif altspec==8
    N=30,fap=0.1,d=10,fas=0.2,Esq_max=1.02,Esq_z=1e-3,Esq_s=1e-6
    constrain_Esq_max=true
    optimise_Esq_s=false
    optimise_Esq_z=false
    Objective=[];
  elseif altspec==9
    N=30,fap=0.1,d=10,fas=0.2,Esq_max=1.02,Esq_z=2e-3,Esq_s=2e-6
    constrain_Esq_max=true
    optimise_Esq_s=false
    optimise_Esq_z=false
  else
    error("altspec %d unknown\n",altspec);
  endif

  % Common constants
  A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
  B=[zeros(N-1,1);1];
  AB=[A,B;eye(N),zeros(N,1)];
  C_d=zeros(1,N);
  C_d(N-d+1)=1;
  Phi=[-1,0;0,1];
  Psi_max=[0,1;1,2];
  c_p=2*cos(2*pi*fap);
  Psi_z=[0,1;1,-c_p];
  c_s=2*cos(2*pi*fas);
  Psi_s=[0,-1;-1,c_s];
  
  % Filter impulse response
  if (2*d)==N
    Cd1=sdpvar(1,d+1);
    CD=[Cd1,Cd1(d:-1:1)];
  else
    CD=sdpvar(1,N+1);
  endif
  CD_d=CD-[C_d,0];

  if altspec==9
    % The Objective function is the total weighted squared error
    Wap=1,Wat=0.0001,Was=1000
    [~,~,G,g]=directFIRnonsymmetricEsqPW ...
              (zeros(N+1,1),[0,fap,fas,0.5]*2*pi,[1,0,0],[d,0,0],[Wap,Wat,Was]);
    Objective=(fliplr(CD)*G*fliplr(CD)')+(2*fliplr(CD)*g')+(2*fap);
  endif
  
  % Set up constraints
  if constrain_Esq_max
    % Maximum amplitude constraint
    P_max=sdpvar(N,N,"symmetric","real");
    Q_max=sdpvar(N,N,"symmetric","real");
    F_max=sdpvar(N+2,N+2,"symmetric","real");
    F_max=[[((AB')*(kron(Phi,P_max)+kron(Psi_max,Q_max))*AB) + ...
            diag([zeros(1,N),-Esq_max]),CD']; ...
           [CD,-1]];
  endif
  % Pass band constraint on the error |H(w)-e^(-j*w*d)|
  P_z=sdpvar(N,N,"symmetric","real");
  Q_z=sdpvar(N,N,"symmetric","real");
  F_z=sdpvar(N+2,N+2,"symmetric","real");
  F_z=[[((AB')*(kron(Phi,P_z)+kron(Psi_z,Q_z))*AB) + ...
        diag([zeros(1,N),-Esq_z]),CD_d']; ...
       [CD_d,-1]];
  % Stop band constraint 
  P_s=sdpvar(N,N,"symmetric","real");
  Q_s=sdpvar(N,N,"symmetric","real");
  F_s=sdpvar(N+2,N+2,"symmetric","real");
  F_s=[[((AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB) + ...
        diag([zeros(1,N),-Esq_s]),CD']; ...
       [CD,-1]];
  
  % Solve with YALMIP
  Constraints=[F_z<=0,Q_z>=0,F_s<=0,Q_s>=0];
  Options=sdpsettings("solver","sedumi");
  if constrain_Esq_max
    Constraints=[Constraints,F_max<=0,Q_max>=0];
  endif
  if optimise_Esq_s
    Constraints=[Constraints,Esq_s<=Esq_opt];
  elseif optimise_Esq_z
    Constraints=[Constraints,Esq_z<=Esq_opt];
  endif
  sol=optimize(Constraints,Objective,Options)
  if sol.problem
    error("YALMIP failed!");
  endif
  check(Constraints)

  % Plot amplitude response
  nplot=1000;
  nap=(fap*nplot/0.5)+1;
  nas=(fas*nplot/0.5)+1;
  h=value(fliplr(CD));
  [H,w]=freqz(h,1,nplot);
  [T,w]=grpdelay(h,1,nplot);
  plot(w*0.5/pi,20*log10(abs(H)));
  ylabel("Amplitude(dB)");
  xlabel("Frequency");
  grid("on");
  axis([0 0.5 -80 10]);
  strt=sprintf("N=%d,d=%d,fap=%g,fas=%g,Esq\\_z=%g,Esq\\_s=%g", ...
               N,d,fap,fas,value(Esq_z),value(Esq_s));
  if constrain_Esq_max
    strt=sprintf("%s,Esq\\_max=%g",strt,Esq_max);
  endif
  title(strt);
  print(sprintf("%s_h%02d_response",strf,altspec),"-dpdflatex");
  close

  % Plot pass band amplitude, phase and delay
  subplot(311)
  plot(w(1:nap)*0.5/pi,20*log10(abs(H(1:nap))));
  axis([0 fap]);
  grid("on");
  ylabel("Amplitude(dB)");
  title(strt);
  subplot(312)
  plot(w(1:nap)*0.5/pi, ...
       unwrap(mod((w(1:nap)*d)+unwrap(arg(H(1:nap))),2*pi))/(pi))
  axis([0 fap]);
  grid("on");
  ylabel("Phase error(rad./$\\pi$)");
  subplot(313)
  [T,w]=grpdelay(h,1,nplot);
  plot(w(1:nap)*0.5/pi,T(1:nap));
  axis([0 fap]);
  ylabel("Delay(samples)");
  grid("on");
  xlabel("Frequency");
  print(sprintf("%s_h%02d_passband",strf,altspec),"-dpdflatex");
  close

  % Check maximum squared-amplitude response
  printf("max(abs(H))^2=%8.6f\n",max(abs(H))^2);
  printf("max(Asq_z)^2=%11.6g\n",max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)))^2);
  printf("max(abs(H(1:nap)))^2=%8.6f\n",max(abs(H(1:nap)))^2);
  printf("min(abs(H(1:nap)))^2=%8.6f\n",min(abs(H(1:nap)))^2);
  printf("max(abs(H(nap:nas)))^2=%8.6f\n",max(abs(H(nap:nas)))^2);
  printf("min(abs(H(nap:nas)))^2=%11.6g\n",min(abs(H(nap:nas)))^2);
  printf("max(abs(H(nas:end)))^2=%11.6g\n",max(abs(H(nas:end)))^2);

  % Save results
  print_polynomial(h,sprintf("h%02d",altspec),"%13.10f");
  print_polynomial(h,sprintf("h%02d",altspec), ...
                   sprintf("%s_h%02d_coef.m",strf,altspec),"%13.10f");
endfor

% Done
toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
