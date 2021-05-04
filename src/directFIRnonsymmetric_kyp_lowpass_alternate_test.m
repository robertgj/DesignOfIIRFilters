% directFIRnonsymmetric_kyp_lowpass_alternate_test.m
% Copyright (C) 2021 Robert G. Jenssen

% SDP design of a direct-form FIR lowpass filter with the KYP lemma.
% See Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma: Unified
% Frequency Domain Inequalities With Design Applications", T. Iwasaki
% and S. Hara, IEEE Transactions on Automatic Control, Vol. 50, No. 1,
% January 2005, pp. 41–59
%
% Note that the YALMIP, Octave, Symbolic Toolbox and SymPy combination
% requires that the KYP constraints have rows enclosed in square brackets.

test_common;

delete("directFIRnonsymmetric_kyp_lowpass_alternate_test.diary");
delete("directFIRnonsymmetric_kyp_lowpass_alternate_test.diary.tmp");
diary directFIRnonsymmetric_kyp_lowpass_alternate_test.diary.tmp

pkg load symbolic optim

tic;

strf="directFIRnonsymmetric_kyp_lowpass_alternate_test";

% Alternative filter specifications
for altspec=1:7,
  printf("\n\n altspec=%d\n\n",altspec);
  if altspec==1
    % Example of Iwasaki and Hara
    N=30,d=10,fap=0.15,fas=0.2,Esq_s=1e-4,Esq_max=1.1
    constrain_Esq_max=false
    optimise_Esq_z=true
    optimise_Esq_s=false
    Esq_z=sdpvar(1,1);
    C=sdpvar(1,N);
    D=sdpvar(1,1);
    Objective=Esq_z;
  elseif altspec==2
    % Gives epsilon_p=0.056869 (as in I+W example), epsilon_s=0.01342
    N=30,fap=0.15,d=10;fas=0.20,Esq_max=1.1,Esq_z=0.0569^2,Esq_s=1.8e-4
    constrain_Esq_max=false
    optimise_Esq_z=false
    optimise_Esq_s=false
    C=sdpvar(1,N);
    D=sdpvar(1,1);
    Objective=[];
  elseif altspec==3
    % Gives epsilon_p=0.08776, epsilon_s=0.010
    N=30,fap=0.15,d=10,fas=0.20,Esq_max=1.1,Esq_z=0.09^2,Esq_s=1.16725e-4
    constrain_Esq_max=false
    optimise_Esq_z=false
    optimise_Esq_s=false
    C=sdpvar(1,N);
    D=sdpvar(1,1);
    Objective=[];
  elseif altspec==4
    N=30,fap=0.15,d=10,fas=0.2,Esq_max=1.1,Esq_z=0.07598^2,Esq_s=0.01^2
    constrain_Esq_max=true
    optimise_Esq_z=false
    optimise_Esq_s=false
    C=sdpvar(1,N);
    D=sdpvar(1,1);
    Objective=[];
  elseif altspec==5
    N=30,fap=0.1,d=10,fas=0.2,Esq_max=1,Esq_z=1e-6,Esq_s=1e-4
    constrain_Esq_max=true
    optimise_Esq_z=false
    optimise_Esq_s=false
    C=sdpvar(1,N);
    D=sdpvar(1,1);
    Objective=[];
  elseif altspec==6
    N=30,fap=0.1,d=10,fas=0.2,Esq_max=1.02,Esq_z=1e-2,Esq_s=1e-5
    Wap=1,Wat=0.0001,Was=1000
    [~,~,G,g]=directFIRnonsymmetricEsqPW ...
              (zeros(N+1,1),[0,fap,fas,0.5]*2*pi,[1,0,0],[d,0,0],[Wap,Wat,Was]);
    L=chol(G)';
    l=(g*inv(L'));
    constrain_Esq_max=true
    optimise_Esq_z=false
    optimise_Esq_s=false
    C=sdpvar(1,N);
    D=sdpvar(1,1);
    Objective=norm((fliplr([C,D])*L)+l);
  elseif altspec==7
    % Example of Iwasaki and Hara optimising Esq_s instead of Esq_z
    N=30,d=10,fap=0.15,fas=0.2,Esq_max=1.1,Esq_z=0.05^2
    constrain_Esq_max=true
    optimise_Esq_z=false
    optimise_Esq_s=true
    Esq_s=sdpvar(1,1);
    C=sdpvar(1,N);
    D=sdpvar(1,1);
    Objective=Esq_s;
  endif

  % Common constants
  nplot=1000;
  nap=(fap*nplot/0.5)+1;
  nas=(fas*nplot/0.5)+1;
  hz=zeros(1,N+1);
  hz(d+1)=1;
  A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
  B=[zeros(N-1,1);1];
  AB=[A,B;eye(N),zeros(N,1)];
  C_d=zeros(1,N);
  C_d(N-d+1)=1;
  c_p=2*cos(2*pi*fap);
  c_s=2*cos(2*pi*fas);

  % Set up constraints
  % Maximum amplitude constraint
  P_max=sdpvar(N,N,"symmetric");
  Q_max=sdpvar(N,N,"symmetric");
  F_max=sdpvar(N+2,N+2,"symmetric");
  F_max=[[((AB')*[-P_max,Q_max;Q_max,P_max+(2*Q_max)]*AB) + ...
          diag([zeros(1,N),-Esq_max]),[C,D]']; ...
         [C,D,-1]];
  % Pass band constraint on the error |H(w)-e^(-j*w*d)|
  P_z=sdpvar(N,N,'symmetric');
  Q_z=sdpvar(N,N,'symmetric');
  F_z=sdpvar(N+2,N+2,'symmetric');
  F_z=[[((AB')*[-P_z, Q_z; Q_z,P_z-(c_p*Q_z)]*AB) + ...
        diag([zeros(1,N),-Esq_z]),[C-C_d,D]']; ...
       [C-C_d,D,-1]];
  % Stop band constraint 
  P_s=sdpvar(N,N,'symmetric');
  Q_s=sdpvar(N,N,'symmetric');
  F_s=sdpvar(N+2,N+2,'symmetric');
  F_s=[[((AB')*[-P_s,-Q_s;-Q_s,P_s+(c_s*Q_s)]*AB) + ...
        diag([zeros(1,N),-Esq_s]),[C,D]']; ...
       [C,D,-1]];

  % Solve with YALMIP
  Constraints=[F_z<=0,Q_z>=0,F_s<=0,Q_s>=0];
  Options=sdpsettings('solver','sedumi');
  if constrain_Esq_max
    Constraints=[F_max<=0,Q_max>=0,Constraints];
  endif
  if optimise_Esq_s
    pOptions=sdpsettings(Options,'removeequalities',1);
    [pConstraints,pObjective]=primalize(Constraints,-Objective);
    sol=optimize(pConstraints,pObjective,pOptions);
    check(pConstraints)
  else
    sol=optimize(Constraints,Objective,Options)
    check(Constraints)
  endif
  if sol.problem==4
    warning("YALMIP warning : %s",sol.info);
  elseif sol.problem
    error("YALMIP failed : %s",sol.info);
  endif

  % Plot amplitude response
  h=value(fliplr([C,D]));
  [H,w]=freqz(h,1,nplot);
  [T,w]=grpdelay(h,1,nplot);
  plot(w*0.5/pi,20*log10(abs(H)));
  ylabel("Amplitude(dB)");
  xlabel("Frequency");
  grid("on");
  strt=sprintf("KYP non-symmetric FIR filter : \
N=%d,d=%d,fap=%g,Esq\\_z=%g,fas=%g,Esq\\_s=%g", ...
               N,d,fap,value(Esq_z),fas,value(Esq_s));
  title(strt);
  print(sprintf("%s_h%1d_response",strf,altspec),"-dpdflatex");
  close

  % Plot pass band amplitude, phase and delay
  subplot(311)
  plot(w(1:nap)*0.5/pi,20*log10(abs(H(1:nap))));
  axis([0 fap]);
  grid("on");
  ylabel("Amplitude(dB)");
  strt=sprintf("KYP non-symmetric FIR filter pass band : \
N=%d,d=%d,fap=%g,Esq_z=%g",N,d,fap,value(Esq_z));
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
  print(sprintf("%s_h%1d_passband",strf,altspec),"-dpdflatex");
  close

  % Check maximum squared-amplitude response
  printf("max(abs(H))=%8.6f\n",max(abs(H)));
  printf("sqrt(max(Asq_z))=%11.6g\n",max(abs(H(1:nap)-e.^(-j*w(1:nap)*d))));
  printf("max(abs(H(1:nap)))=%8.6f\n",max(abs(H(1:nap))));
  printf("min(abs(H(1:nap)))=%8.6f\n",min(abs(H(1:nap))));
  printf("max(abs(H(nap:nas)))=%8.6f\n",max(abs(H(nap:nas))));
  printf("min(abs(H(nap:nas)))=%11.6g\n",min(abs(H(nap:nas))));
  printf("max(abs(H(nas:end)))=%11.6g\n",max(abs(H(nas:end))));

  % Save results
  fid=fopen(sprintf("%s_h%1d.spec",strf,altspec),"wt");
  fprintf(fid,"N=%d %% FIR filter order\n",N);
  fprintf(fid,"d=%d %% Nominal FIR filter delay\n",d);
  if constrain_Esq_max
    fprintf(fid,"Esq_max=%g %% Overall maximum squared amplitude\n",Esq_max);
  endif
  fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
  if ~optimise_Esq_z
    fprintf(fid,"Esq_z=%g %% Squared amplitude passband-delay error\n", ...
            value(Esq_z));
  endif
  fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
  fprintf(fid,"Esq_s=%g %% Squared amplitude stop band error\n",value(Esq_s));
  fclose(fid);

  print_polynomial(h,sprintf("h%1d",altspec),"%13.10f");
  print_polynomial(h,sprintf("h%1d",altspec), ...
                   sprintf("%s_h%1d_coef.m",strf,altspec),"%13.10f");
endfor

% Done
toc;
diary off
movefile directFIRnonsymmetric_kyp_lowpass_alternate_test.diary.tmp ...
         directFIRnonsymmetric_kyp_lowpass_alternate_test.diary;
