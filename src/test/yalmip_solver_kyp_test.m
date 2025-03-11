% yalmip_solver_kyp_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="yalmip_solver_kyp_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

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
Phi=[-1,0;0,1];
C_d=zeros(1,N);
C_d(N-d+1)=1;
c_p=2*cos(2*pi*fap);
c_s=2*cos(2*pi*fas);
e_c=e^(j*pi*(fap+fas));
c_h=2*cos(pi*(fas-fap));

for solver_type=1:4

  switch(solver_type)
    % See solver options with, for example, ops=sdpsettings() then ops.sedumi
    case 1 
      solver_str="sedumi";
      Options=sdpsettings("solver",solver_str,"dualize",true);
    case 2
      solver_str="sdpt3";
      Options=sdpsettings("solver",solver_str,"dualize",true);
    case 3
      solver_str="scs-direct";
      Options=sdpsettings("solver",solver_str,"dualize",true, ...
                          "scs.max_iters",10000,  ...
                          "scs.eps_abs",1e-9,"scs.eps_rel",1e-9);
    case 4
      solver_str="scs-indirect";
      Options=sdpsettings("solver",solver_str, ...
                          "scs.max_iters",10000,  ...
                          "scs.eps_abs",1e-9,"scs.eps_rel",1e-9);
    otherwise
      error("Unknown solver type");
  endswitch

  solver_strf=strcat(strf,"_",solver_str);

  %
  % Design filter with KYP. In the pass-band the filter designed has
  % response constraint |H(w)-e^(-j*w*d)|^2<Esq_z.
  %
  printf("\nUsing YALMIP and %s with a generalised KYP constraint\n", ...
        solver_str);
  use_kron=true;
  Esq_z=1e-4;
  Esq_s=1e-6;
  C=sdpvar(1,N);
  D=sdpvar(1,1);
  P_z=sdpvar(N,N,"symmetric");
  Q_z=sdpvar(N,N,"symmetric");
  F_z=[[((AB')*(kron(Phi,P_z)+kron([0,1;1,-c_p],Q_z))*AB) + ...
        diag([zeros(1,N),-Esq_z]),[C-C_d,D]']; ...
       [C-C_d,D,-1]];
  P_s=sdpvar(N,N,"symmetric");
  Q_s=sdpvar(N,N,"symmetric");
  if use_kron
    F_s=[[((AB')*(kron(Phi,P_s)+kron([0,-1;-1,c_s],Q_s))*AB) + ...
          diag([zeros(1,N),-Esq_s]),[C,D]']; ...
         [C,D,-1]];
  else
    F_s=[[((AB')*[-P_s,-Q_s;-Q_s,P_s+(c_s*Q_s)]*AB) + ...
          diag([zeros(1,N),-Esq_s]),[C,D]']; ...
         [C,D,-1]];
  endif
  Constraints=[F_z<=0;Q_z>=0,F_s<=0,Q_s>=0];
  sol=optimize(Constraints,[],Options);
  if sol.problem
    warning("YALMIP failed : %s",sol.info);
    continue;
  endif
  h_kyp=value(fliplr([C,D]));
  % Sanity checks
  check(Constraints)
  if ~isdefinite(value(Q_z))
    warning("Q_z not positive semi-definite");
  endif
  if ~isdefinite(-value(F_z))
    warning("F_z not negative semi-definite");
  endif
  if ~isdefinite(value(Q_s))
    warning("Q_s not positive semi-definite");
  endif
  if ~isdefinite(-value(F_s))
    warning("F_s not negative semi-definite");
  endif
  % Plot h_kyp response
  h=value(fliplr([C,D]));
  [H,w]=freqz(h,1,nplot);
  [T,w]=delayz(h,1,nplot);
  subplot(211);
  plot(w*0.5/pi,20*log10(abs(H)));
  ylabel("Amplitude(dB)");
  axis([0 0.5 -80 5]);
  grid("on");
  strt=sprintf("KYP %s non-symmetric FIR filter : N=%d,d=%d,fap=%g,fas=%g", ...
               solver_str,N,d,fap,fas);
  title(strt);
  subplot(212);
  plot(w(1:nap)*0.5/pi,T(1:nap));
  ylabel("Delay(samples)");
  xlabel("Frequency");
  axis([0 0.5 d-0.1 d+0.1]);
  grid("on");
  print(strcat(solver_strf,"_response"),"-dpdflatex");
  close

  % Save 
  print_polynomial(h,"h","%13.10f");
  print_polynomial(h,"h",strcat(solver_strf,"_h_coef.m"),"%13.10f");
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));

