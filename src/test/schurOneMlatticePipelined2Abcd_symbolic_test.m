% schurOneMlatticePipelined2Abcd_symbolic_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
%
% Create symbolic descriptions of pipelined Schur one-multiplier all-pass filters

test_common;

pkg load symbolic

strf="schurOneMlatticePipelined2Abcd_symbolic_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

%
% Design a prototype lattice filters with no scaling by p or epsilon
%

tol_eps=20;dBas=40;fc=0.1;

for N=[1,2,3,6,7],
  
  [n,d]=cheby2(N,dBas,2*fc);
  [k,epsilon,~,c]=tf2schurOneMlattice(n,d);

  %
  % Define symbols
  %
  str_syms="c0 ";
  for l=1:N
    str_syms=strcat(str_syms,sprintf(" E%d k%d c%d",l,l,l));
  endfor
  eval(sprintf("syms %s",str_syms));
  for l=1:N,
    assume(sprintf("c%d",l),"real");
    assume(sprintf("k%d",l),"real");
    % BUG : octave/symbolic/SymPy (???) thinks e%d is 2.7183..., not a symbol
    assume(sprintf("E%d",l),"integer");
  endfor

  % Modules 1 to ceil(N/2)-1 have Ns states
  if rem(N,2)
    Ns=(3*ceil(N/2))-2;
  else
    Ns=3*N/2;
  endif

  M0=[[c0,zeros(1,Ns)];[1,zeros(1,Ns)];eye(Ns+1)];

  for l=1:(ceil(N/2)-1)
    eval(sprintf ...
(["rM%d=[[0,-k%d,0,0,-(1+E%d*k%d)*k%d,(1+E%d*k%d)*(1+E%d*k%d)];...\n", ...
 "     [1,     0,0,0,     -c%d*k%d,c%d*(1+E%d*k%d)];...\n", ...
 "     [0,1-E%d*k%d,0,0,  -k%d*k%d,k%d*(1+E%d*k%d)];...\n", ...
 "     [0,     0,0,1,            0,c%d];...\n", ...
 "     [0,     0,0,0,    1-E%d*k%d,k%d]];"],
                 l,(2*l)-1,(2*l)-1,(2*l)-1,2*l,(2*l)-1,(2*l)-1,2*l,2*l, ...
                 (2*l)-1,2*l,(2*l)-1,2*l,2*l, ...
                 (2*l)-1,(2*l)-1,(2*l)-1,2*l,(2*l)-1,(2*l),(2*l), ...
                 2*l, ...
                 2*l,2*l,2*l));

    eval(sprintf(...
["M%d=[[eye(3*(l-1)),zeros(3*(l-1),6),zeros(3*(l-1),Ns+3-6-(3*(l-1)))];...\n", ...
 "    [zeros(5,3*(l-1)),rM%d,zeros(5,Ns+3-6-(3*(l-1)))]; ...\n", ...
 "    [zeros(Ns+3-(3*(l-1))-5,(3*(l-1))+5),eye(Ns+3-(3*(l-1))-5)]];"],l,l));
  endfor
  l=(ceil(N/2)-1); % For N=1,2

  % Final module
  if rem(N,2)
    eval(sprintf(["rM%d=[[0, -k%d,0, 1+E%d*k%d];...\n", ...
 "     [1,     0,0, c%d];...\n", ...
 "     [0,1-E%d*k%d,0, k%d]];"], l+1,N,N,N,N,N,N,N));

    eval(sprintf(["M%d=[[eye(3*l),zeros(3*l,4)];...\n", ...
 "     [zeros(3,3*l),rM%d]];"],l+1,l+1))
  else
    eval(sprintf...
(["rM%d=[[0, -k%d,0,0,-(1+E%d*k%d)*k%d,(1+E%d*k%d)*(1+E%d*k%d)];...\n", ...
 "     [1,        0,0,0,       -c%d*k%d,c%d*(1+E%d*k%d)];...\n", ...
 "     [0,1-E%d*k%d,0,0,       -k%d*k%d,k%d*(1+E%d*k%d)];...\n", ...
 "     [0,        0,0,1,              0,c%d];...\n", ...
 "     [0,        0,0,0,      1-E%d*k%d,k%d]];"],
                 l+1,N-1,N-1,N-1,N,N-1,N-1,N,N, ...
                 N-1,N,N-1,N,N, ...
                 N-1,N-1,N-1,N,N-1,N,N, ...
                 N, ...
                 N,N,N));

    eval(sprintf(["M%d=[[eye(3*l),zeros(3*l,6)];...\n", ...
 "     [zeros(5,(3*l)),rM%d]];"],l+1,l+1))
  endif

  Abcd=M0;
  for l=1:ceil(N/2)
    eval(sprintf("Abcd=M%d*Abcd;",l));
  endfor

  % Extract all-pass only states
  i_apAbcd=[];
  for l=1:(ceil(N/2)-1),
    i_apAbcd=[i_apAbcd,((l-1)*3)+1,((l-1)*3)+3];
  endfor
  if rem(N,2),
    r_apAbcd=[i_apAbcd,rows(Abcd)-2,rows(Abcd)];
    c_apAbcd=[i_apAbcd,columns(Abcd)-1,columns(Abcd)];
  else
    r_apAbcd=[i_apAbcd,rows(Abcd)-4,rows(Abcd)-2,rows(Abcd)];
    c_apAbcd=[i_apAbcd,columns(Abcd)-3,columns(Abcd)-1,columns(Abcd)];
  endif
  apAbcd=Abcd(r_apAbcd,c_apAbcd);

  % Output
  fhandle=fopen(sprintf("%s_N_%d.latex",strf,N),"wt");
  fprintf(fhandle,"Abcd=%s\n\n",latex(Abcd));
  fprintf(fhandle,"apAbcd=%s\n",latex(apAbcd));
  fclose(fhandle);
  
  % Check successive determinants
  for l=1:N,
    eval(sprintf("E%d=vpa(epsilon(l));",l)); 
  endfor
  ev_apAbcd=eval(apAbcd);
  for l=1:N,
    if eval(sprintf("det(ev_apAbcd(1:l,1:l)) ~= ((-1)^l)*k%d",l))
      error("det ev_apAbcd failed at l=%d",l);
    endif
  endfor

  %
  % KYP matrix
  %
  
  % Define lowpass filter
  syms cp Esq
  Phi=[-1,0;0,1];
  Psi=[[0,1];[1,-cp]];

  % State variable representation
  AapBap=[apAbcd(1:N,1:(N+1));[eye(N),zeros(N,1)]];
  CapDap=apAbcd(N+1,1:(N+1));

  % Check successive determinants
  ev_AapBap=eval(AapBap);
  for l=1:N,
    if eval(sprintf("det(ev_AapBap(1:l,1:l)) ~= ((-1)^l)*k%d",l))
      error("det ev_AapBap failed at l=%d",l);
    endif
  endfor
  
  % Define KYP P,Q matrix elements as symbols
  Nvars=((N+1)*N)/2;
  P=cell(1,Nvars);
  Q=cell(1,Nvars);
  g=0;
  for l=1:N,
    for m=1:l,
      eval(sprintf("p%d%d=sym(\"p%d%d\",\"real\");",l,m,l,m));
      eval(sprintf("q%d%d=sym(\"q%d%d\",\"real\");",l,m,l,m));
      M=zeros(N,N);
      M(l,m)=1;
      M(m,l)=1;
      g=g+1;
      eval(sprintf("P{1,g}=p%d%d*M;",l,m));
      eval(sprintf("Q{1,g}=q%d%d*M;",l,m));
    endfor
  endfor
  if g~=Nvars
    error("g~=Nvars");
  endif
  
  % Define KYP apG matrix
  apGl=cell(1,Nvars+1);
  for l=1:Nvars,
    apGl{l}=ev_AapBap'*(kron(Phi,P{1,l})+kron(Psi,Q{1,l}))*ev_AapBap;
  endfor
  apGl{Nvars+1}=diag([zeros(1,N),-Esq]);
  apG=zeros(N+1);
  for l=1:(Nvars+1),
    apG=apG+apGl{l};
  endfor
  
  % Output. Remove epsilon from the all-pass matrix
  fhandle=fopen(sprintf("%s_KYP_apG_N_%d.latex",strf,N),"wt");
  fprintf(fhandle,"apG=%s\n",latex(apG));
  fclose(fhandle);

  clear cp Esq
  for l=1:N,
    for m=1:l,
      eval(sprintf("clear p%d%d q%d%d;",l,m,l,m));
    endfor
  endfor
  
  %
  % Sanity checks.
  %
  
  % Conversion of original transfer functions. 
  [rA,rB,rC,rD,rCap,rDap] = ...
    schurOneMlatticePipelined2Abcd(k,epsilon,c);
  rABCDCapDap=[rA,rB;rC,rD;rCap,rDap];
  [rn,rd]=Abcd2tf(rA,rB,rC,rD);
  if max(abs(rn(1:length(n))-n))>tol_eps*eps,
    error("N=%d,max(abs(rn-n))(%g*eps)>tol_eps*eps",
          N,max(abs(rn(1:length(n))-n))/eps);
  endif
  if max(abs(rd(1:length(d))-d))>tol_eps*eps,
    error("N=%d,max(abs(rd-d))(%g*eps)>tol_eps*eps",
          N,max(abs(rd(1:length(d))-d))/eps);
  endif
  [rapn,rapd]=Abcd2tf(rA,rB,rCap,rDap);
  rapn=rapn(1:(N+1));
  rapd=rapd(1:(N+1));
  if max(abs(rapn-fliplr(d)))>tol_eps*eps,
    error("N=%d,max(abs-fliplr(d)))(%g*eps)>tol_eps*eps",
          N,max(abs(rapn-fliplr(d)))/eps);
  endif
  if max(abs(rapd-d))>tol_eps*eps,
    error("N=%d,max(abs(rapd-d))(%g*eps)>tol_eps*eps",
          N,max(abs(rapd-d))/eps);
  endif

  % Evaluate symbolic version
  c0=vpa(c(1));
  for l=1:N,
    eval(sprintf("e%1d=vpa(epsilon(l));",l)); 
    eval(sprintf("k%1d=vpa(k(l));",l)); 
    eval(sprintf("c%1d=vpa(c(l+1));",l));
  endfor

  vAbcd=double(eval(Abcd));
  if max(max(abs(vAbcd-rABCDCapDap)))>eps
    error("N=%d,max(max(abs(vAbcd-rABCDCapDap)(%g*eps)>eps))",
          N,max(max(abs(vAbcd-rABCDCapDap)))/eps);
  endif

  vA=vAbcd(1:Ns,1:Ns);
  vB=vAbcd(1:Ns,Ns+1);
  vC=vAbcd(Ns+1,1:Ns);
  vD=vAbcd(Ns+1,Ns+1);
  [vn,vd]=Abcd2tf(vA,vB,vC,vD);
   if max(abs(vn(1:length(n))-n))>tol_eps*eps,
    warning("N=%d,max(abs(vn-n))(%g*eps)>tol_eps*eps",
            N,max(abs(vn(1:length(n))-n))/eps);
  endif
  if max(abs(vd(1:length(d))-d))>tol_eps*eps,
    error("N=%d,max(abs(vd-d))(%g*eps)>tol_eps*eps",
          N,max(abs(vd(1:length(d))-d))/eps);
  endif
  
  vapAbcd=double(eval(apAbcd));
  apABCDr=rABCDCapDap(r_apAbcd,c_apAbcd);
  if max(max(abs(vapAbcd-apABCDr)))>tol_eps*eps
    error("N=%d,max(max(abs(vapAbcd-apABCDr)))(%g*eps)>tol_eps*eps",
          N,max(max(abs(vAbcd-rABCDCapDap)))/eps);
  endif
  
  % Check successive determinants
  for l=1:N,
    if abs(det(vapAbcd(1:l,1:l)) - (((-1)^l)*k(l)))>tol_eps*eps
      error("det apAbcd failed at l=%d",l);
    endif
  endfor
 
  vapA = vapAbcd(1:(end-1),1:(end-1));
  vapB = vapAbcd(1:(end-1),end);
  vapC = vapAbcd(end,1:(end-1));
  vapD = vapAbcd(end,end);
  [apn,apd]=Abcd2tf(vapA,vapB,vapC,vapD);
  if max(abs(fliplr(apn)-d))>tol_eps*eps,
    error("N=%d,max(abs(fliplr(apn)-d))(%g*eps)>tol_eps*eps",
          N,max(abs(fliplr(apn)-d))/eps);
  endif
  if max(abs(apd-d))>tol_eps*eps,
    error("N=%d,max(abs(apd-d))(%g*eps)>tol_eps*eps",
          N,max(abs(apd-d))/eps);
  endif

  eval(sprintf("clear %s",str_syms));
endfor

%
% Done
%
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
