% yalmip_kyp_test.m
% Copyright (C) 2021 Robert G. Jenssen

test_common;

delete("yalmip_kyp_test.diary");
delete("yalmip_kyp_test.diary.tmp");
diary yalmip_kyp_test.diary.tmp

pkg load symbolic optim

tic;

strf="yalmip_kyp_test";

% Low-pass filter specification
N=30;d=10;fap=0.1;Wap=1;Wat=0.0001;fas=0.2;Was=1;

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
e_c=e^(j*pi*(fap+fas));
c_h=2*cos(pi*(fas-fap));

%
% Use YALMIP to solve for a quadratic constraint on the amplitude response
%
printf("\nUsing YALMIP to solve for a quadratic constraint on the amplitude\n");
[~,~,G,g]=directFIRnonsymmetricEsqPW ...
            (zeros(N+1,1),[0,fap,fas,0.5]*2*pi,[1,0,0],[d,0,0],[Wap,Wat,Was]);
L=chol(G)';
l=(g*inv(L'));
% Call YALMIP
x=sdpvar(1,N+1);
Constraints=[];
Objective=norm((x*L)+l);
Options=sdpsettings('solver','sedumi');
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
h=value(x);
% Plot response
[H,w]=freqz(h,1,nplot);
[T,w]=grpdelay(h,1,nplot);
subplot(211);
plot(w*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("KYP quadratic non-symmetric FIR filter : \
N=%d,d=%d,fap=%g,Wap=%g,Wat=%g,fas=%g,Was=%g",N,d,fap,Wap,Wat,fas,Was);
title(strt);
subplot(212);
plot(w(1:nap)*0.5/pi,T(1:nap));
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 d-0.4 d+0.4]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

%
% Check constraints on frequency response with KYP
%
printf("\nUsing YALMIP to check frequency response with KYP\n");
Hz=freqz(h-hz,1,nplot);
del=1e-5;
Asq_max=max(abs(H).^2)+del;
Asq_pu=max(abs(H(1:nap)).^2)+del;
Asq_z=max(abs(Hz(1:nap)).^2)+del;
Asq_tu=max(abs(H(nap:nas)).^2)+del;
Asq_tl=min(abs(H(nap:nas)).^2)-(del/200);
Asq_s=max(abs(H(nas:end)).^2)+(del/200);
printf("Asq_max=%6.4f,Asq_pu=%6.4f,Asq_z=%6.4f,Asq_s=%10.4g\n", ...
       Asq_max,Asq_pu,Asq_z,Asq_s);
C=h(end:-1:2);
D=h(1);
CD=[C,D;zeros(size(C)),ones(size(D))];
C_dD=[C-C_d,D;zeros(size(C)),ones(size(D))];

for use_AB_plus_Theta=0:1
  % Check overall constraint on maximum amplitude
  printf("\nChecking maximum amplitude constraint\n");
  P_max=sdpvar(N,N,"symmetric");
  Q_max=sdpvar(N,N,"symmetric");
  if use_AB_plus_Theta
    F_max=sdpvar(N+1,N+1,"symmetric");
    F_max=((AB')*[-P_max,Q_max;Q_max,P_max+(2*Q_max)]*AB) + ...
          ((CD')*[1,0;0,-Asq_max]*CD);
  else
    F_max=sdpvar(N+2,N+2,"symmetric");
    F_max=[[((AB')*[-P_max, Q_max; Q_max,P_max+(2*Q_max)]*AB) + ...
            diag([zeros(1,N),-Asq_max]),[C,D]']; ...
           [C,D,-1]];
  endif
  Constraints_max=[F_max<=0,Q_max>=0];
  sol=optimize(Constraints_max,[],Options);
  if sol.problem
    error("YALMIP failed maximum amplitude constraint : %s",sol.info);
  endif
  check(Constraints_max)
  if ~isdefinite(value(Q_max))
    error("Q_max not positive semi-definite");
  endif
  if ~isdefinite(-value(F_max))
    error("F_max not negative semi-definite");
  endif

  % Passband constraints
  % Constraint on maximum pass band amplitude
  printf("\nChecking maximum pass band amplitude constraint\n");
  P_pu=sdpvar(N,N,"symmetric");
  Q_pu=sdpvar(N,N,"symmetric");
  if use_AB_plus_Theta
    F_pu=sdpvar(N+1,N+1,"symmetric");
    F_pu=((AB')*[-P_pu,Q_pu;Q_pu,P_pu-(c_p*Q_pu)]*AB)+((CD')*[1,0;0,-Asq_pu]*CD);
  else
    F_pu=sdpvar(N+2,N+2,"symmetric");
    F_pu=[[((AB')*[-P_pu, Q_pu; Q_pu,P_pu-(c_p*Q_pu)]*AB) + ...
           diag([zeros(1,N),-Asq_pu]),[C,D]']; ...
          [C,D,-1]];
  endif
  Constraints_pu=[F_pu<=0,Q_pu>=0];
  sol=optimize(Constraints_pu,[],Options);
  if sol.problem
    error("YALMIP failed maximum pass band amplitude constraint : %s",sol.info);
  endif
  check(Constraints_pu)
  if ~isdefinite(value(Q_pu))
    error("Q_pu not positive semi-definite");
  endif
  if ~isdefinite(-value(F_pu))
    error("F_pu not negative semi-definite");
  endif

  % Constraint on maximum pass band amplitude of h-hz
  printf("\nChecking maximum pass band amplitude of h-hz constraint\n");
  P_z=sdpvar(N,N,"symmetric");
  Q_z=sdpvar(N,N,"symmetric");
  if use_AB_plus_Theta
    F_z=sdpvar(N+1,N+1,"symmetric");
    F_z=((AB')*[-P_z,Q_z;Q_z,P_z-(c_p*Q_z)]*AB)+((C_dD')*[1,0;0,-Asq_z]*C_dD);
  else
    F_z=sdpvar(N+2,N+2,"symmetric");
    F_z=[[((AB')*[-P_z, Q_z; Q_z,P_z-(c_p*Q_z)]*AB) + ...
          diag([zeros(1,N),-Asq_z]),[C-C_d,D]']; ...
         [C-C_d,D,-1]];
  endif
  Constraints_z=[F_z<=0,Q_z>=0];
  sol=optimize(Constraints_z,[],Options);
  if sol.problem
    error("YALMIP failed maximum pass band amplitude of h-hz constraint : %s",...
          sol.info);
  endif
  check(Constraints_z)
  if ~isdefinite(value(Q_z))
    error("Q_z not positive semi-definite");
  endif
  if ~isdefinite(-value(F_z))
    error("F_z not negative semi-definite");
  endif

  % Check combined pass band constraints
  printf("\nChecking combined pass band amplitude constraints\n");
  Constraints_p=[F_pu<=0,Q_pu>=0,F_z<=0,Q_z>=0];
  sol=optimize(Constraints_p,[],Options);
  if sol.problem
    error("YALMIP failed pass band constraints : %s",sol.info);
  endif
  check(Constraints_p)
  if ~isdefinite(value(Q_pu))
    error("Q_pu not positive semi-definite");
  endif
  if ~isdefinite(-value(F_pu))
    error("F_pu not negative semi-definite");
  endif
  if ~isdefinite(value(Q_z))
    error("Q_z not positive semi-definite");
  endif
  if ~isdefinite(-value(F_z))
    error("F_z not negative semi-definite");
  endif

  % Transition band constraint
  printf("\nChecking transition band constraint\n");
  P_tu=sdpvar(N,N,"symmetric");
  Q_tu=sdpvar(N,N,"symmetric");
  if use_AB_plus_Theta
    F_tu=sdpvar(N+1,N+1,"hermitian","complex");
    F_tu=((AB')*[-P_tu,e_c*Q_tu;Q_tu/e_c,P_tu-(c_h*Q_tu)]*AB) + ...
         ((CD')*[1,0;0,-Asq_tu]*CD);
  else
    F_tu=sdpvar(N+2,N+2,"hermitian","complex");
    F_tu=[[((AB')*[-P_tu,e_c*Q_tu;Q_tu/e_c,P_tu-(c_h*Q_tu)]*AB) + ...
           diag([zeros(1,N),-Asq_tu]),[C,D]']; ...
          [C,D,-1]];
  endif
  Constraints_t=[F_tu<=0,Q_tu>=0];
  sol=optimize(Constraints_t,[],Options);
  if sol.problem
    error("YALMIP failed transition band constraint : %s",sol.info);
  endif
  check(Constraints_t)
  if ~isdefinite(value(Q_tu))
    error("Q_tu not positive semi-definite");
  endif
  if ~isdefinite(-value(F_tu))
    error("F_tu not negative semi-definite");
  endif

  % Stopband constraint
  printf("\nChecking stop band constraint\n");
  P_s=sdpvar(N,N,"symmetric");
  Q_s=sdpvar(N,N,"symmetric");
  if 1 || use_AB_plus_Theta
    F_s=sdpvar(N+1,N+1,"symmetric");
    F_s=((AB')*[-P_s,-Q_s;-Q_s,P_s+(c_s*Q_s)]*AB)+((CD')*[1,0;0,-Asq_s]*CD);
  else
    % This fails with numerical problems !?!?!
    F_s=sdpvar(N+2,N+2,"symmetric");
    F_s=[[((AB')*[-P_s,-Q_s;-Q_s,P_s+(c_s*Q_s)]*AB) + ...
          diag([zeros(1,N),-Asq_s]),[C,D]'];...
         [C,D,-1]];
  endif
  Constraints_s=[F_s<=0,Q_s>=0];
  sol=optimize(Constraints_s,[],Options);
  if sol.problem
    error("YALMIP failed stop band constraints: %s",sol.info);
  endif
  check(Constraints_s)
  if ~isdefinite(value(Q_s))
    error("Q_s not positive semi-definite");
  endif
  if ~isdefinite(-value(F_s))
    error("F_s not negative semi-definite");
  endif
endfor

%
% Design filter with KYP and stop band amplitude constraint
%
printf("\nUsing YALMIP to design filter with stop band amplitude constraint\n");
[~,~,G,g]=directFIRnonsymmetricEsqPW(zeros(N+1,1),[0,fap,fas,0.5]*2*pi, ...
                                     [1,0,0],[floor(N/2),0,0],[Wap,Wat,Was]);
L=chol(G)';
l=(g*inv(L'));
Esq_s=5e-5;
C=sdpvar(1,N);
D=sdpvar(1,1);
% Stop band amplitude constraint
P_s=sdpvar(N,N,'symmetric');
Q_s=sdpvar(N,N,'symmetric');
F_s=sdpvar(N+2,N+2,'symmetric');
F_s=[[((AB')*[-P_s,-Q_s;-Q_s,P_s+(c_s*Q_s)]*AB) + ...
      diag([zeros(1,N),-Esq_s]),[C,D]']; ...
     [C,D,-1]];
% Solve
Constraints=[F_s<=0,Q_s>=0];
Objective=norm((fliplr([C,D])*L)+l);
Options=sdpsettings('solver','sedumi');
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
if ~isdefinite(value(Q_s))
  error("Q_s not positive semi-definite");
endif
if ~isdefinite(-value(F_s))
  error("F_s not negative semi-definite");
endif
% Plot h_amp response
h_amp=value(fliplr([C,D]));
[H_amp,w]=freqz(h_amp,1,nplot);
[T_amp,w]=grpdelay(h_amp,1,nplot);
subplot(211);
plot(w*0.5/pi,20*log10(abs(H_amp)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("KYP non-symmetric FIR filter : N=%d,d=%d,fap=%g,fas=%g",
             N,d,fap,fas);
title(strt);
subplot(212);
plot(w(1:nap)*0.5/pi,T_amp(1:nap));
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 floor(N/2)-0.1 floor(N/2)+0.1]);
grid("on");
print(strcat(strf,"_amp_response"),"-dpdflatex");
close

%
% Design filter with KYP. In the pass-band the filter designed has
% response constraint |H(w)-e^(-j*w*d)|^2<Esq_z.
%
printf("\nUsing YALMIP to design filter with generalised KYP\n");
Esq_s=1e-5;
Esq_z=1e-5;
C=sdpvar(1,N);
D=sdpvar(1,1);
P_z=sdpvar(N,N,'symmetric');
Q_z=sdpvar(N,N,'symmetric');
F_z=sdpvar(N+2,N+2,'symmetric');
F_z=[[((AB')*[-P_z, Q_z; Q_z,P_z-(c_p*Q_z)]*AB) + ...
      diag([zeros(1,N),-Esq_z]),[C-C_d,D]']; ...
     [C-C_d,D,-1]];
P_s=sdpvar(N,N,'symmetric');
Q_s=sdpvar(N,N,'symmetric');
F_s=sdpvar(N+2,N+2,'symmetric');
F_s=[[((AB')*[-P_s,-Q_s;-Q_s,P_s+(c_s*Q_s)]*AB) + ...
      diag([zeros(1,N),-Esq_s]),[C,D]']; ...
     [C,D,-1]];
Constraints=[F_z<=0;Q_z>=0,F_s<=0,Q_s>=0];
Options=sdpsettings('solver','sedumi');
sol=optimize(Constraints,[],Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
h_kyp=value(fliplr([C,D]));
% Sanity checks
check(Constraints)
if ~isdefinite(value(Q_z))
  error("Q_z not positive semi-definite");
endif
if ~isdefinite(-value(F_z))
  error("F_z not negative semi-definite");
endif
if ~isdefinite(value(Q_s))
  error("Q_s not positive semi-definite");
endif
if ~isdefinite(-value(F_s))
  error("F_s not negative semi-definite");
endif
% Plot h_kyp response
h_kyp=value(fliplr([C,D]));
[H_kyp,w]=freqz(h_kyp,1,nplot);
[T_kyp,w]=grpdelay(h_kyp,1,nplot);
subplot(211);
plot(w*0.5/pi,20*log10(abs(H_kyp)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("KYP non-symmetric FIR filter : N=%d,d=%d,fap=%g,fas=%g",
             N,d,fap,fas);
title(strt);
subplot(212);
plot(w(1:nap)*0.5/pi,T_kyp(1:nap));
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 d-0.1 d+0.1]);
grid("on");
print(strcat(strf,"_kyp_response"),"-dpdflatex");
close

% Save 
print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%13.10f");
print_polynomial(h_amp,"h_amp","%13.10f");
print_polynomial(h_amp,"h_amp",strcat(strf,"_h_amp_coef.m"),"%13.10f");
print_polynomial(h_kyp,"h_kyp","%13.10f");
print_polynomial(h_kyp,"h_kyp",strcat(strf,"_h_kyp_coef.m"),"%13.10f");

% Done
diary off
movefile yalmip_kyp_test.diary.tmp yalmip_kyp_test.diary;
