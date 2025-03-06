% schurOneMPAlatticeDoublyPipelined2Abcd_kyp_symbolic_test.m
% Copyright (C) 2023-2025 Robert G. Jenssen
%
% Create a symbolic version of the KYP lemma for doubly pipelined Schur
% one-multiplier parallel all-pass filters. 

test_common;

pkg load symbolic

strf="schurOneMPAlatticeDoublyPipelined2Abcd_kyp_symbolic_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

%
% Design a prototype all-pass one-multiplier Schur lattice filter
%
tol_eps=20;dBap=0.1;dBas=40;fap=0.1;fas=0.2;

for N=3:2:7,
  % Lowpass filter
  [n,d]=cheby2(N,dBas,2*fap);
  [a1,a2]=tf2pa(n,d);
  Na1=length(a1)-1;
  Na2=length(a2)-1;
  a1k=schurdecomp(a1);
  a2k=schurdecomp(a2);

  %
  % Define symbols
  %
  str_syms="";
  for l=1:Na1
    str_syms=strcat(str_syms,sprintf(" a1k%d",l));
  endfor
  for l=1:Na2
    str_syms=strcat(str_syms,sprintf(" a2k%d",l));
  endfor
  eval(sprintf("syms %s",str_syms));
  for l=1:Na1,
    assume(sprintf("a1k%d",l),"real");
  endfor
  for l=1:Na2,
    assume(sprintf("a2k%d",l),"real");
  endfor

  %
  % Define state variable all-pass filters
  %

  % For a1, modules 1 to Na1 have Na1s states.
  Na1s=(2*Na1)+2;
  a1apA=sym("a1apA",[Na1s,Na1s]);
  for l=1:Na1s,
    for m=1:Na1s,
      a1apA(l,m)=0;
    endfor
  endfor
  a1apA(1,2)=1;
  for l=1:Na1,
    eval(sprintf("a1apA(%d,%d)= -a1k%d;",(2*l)  ,(2*l)-1,l));
    eval(sprintf("a1apA(%d,%d)=1+a1k%d;",(2*l)  ,(2*l)+2,l));
    eval(sprintf("a1apA(%d,%d)=1-a1k%d;",(2*l)+1,(2*l)-1,l));
    eval(sprintf("a1apA(%d,%d)=  a1k%d;",(2*l)+1,(2*l)+2,l));
  endfor
  a1apB=zeros(Na1s,1);
  a1apB(Na1s,1)=1;
  a1apC=zeros(1,Na1s);
  a1apC(1,Na1s-1)=1;
  a1apD=0;

  % For a2, modules 1 to Na2 have Na2s states.
  Na2s=(2*Na2)+2;
  a2apA=sym("a2apA",[Na2s,Na2s]);
  for l=1:Na2s,
    for m=1:Na2s,
      a2apA(l,m)=0;
    endfor
  endfor
  a2apA(1,2)=1;
  for l=1:Na2,
    eval(sprintf("a2apA(%d,%d)= -a2k%d;",(2*l)  ,(2*l)-1,l));
    eval(sprintf("a2apA(%d,%d)=1+a2k%d;",(2*l)  ,(2*l)+2,l));
    eval(sprintf("a2apA(%d,%d)=1-a2k%d;",(2*l)+1,(2*l)-1,l));
    eval(sprintf("a2apA(%d,%d)=  a2k%d;",(2*l)+1,(2*l)+2,l));
  endfor
  a2apB=zeros(Na2s,1);
  a2apB(Na2s,1)=1;
  a2apC=zeros(1,Na2s);
  a2apC(1,Na2s-1)=1;
  a2apD=0;

  % Construct the filter
  papA=[[a1apA, zeros(Na1s,Na2s)]; ...
        [zeros(Na2s,Na1s), a2apA]];
  papB=[a1apB;a2apB];
  papC=[a1apC,a2apC]/vpa(2);
  papD=(a1apD+a2apD)/vpa(2);
  papABCD=[[papA,papB];[papC,papD]];

  %
  % Sanity checks.
  %

  % Evaluate the symbolic version
  for l=1:Na1,
    eval(sprintf("a1k%d=vpa(a1k(l));",l)); 
  endfor
  for l=1:Na2,
    eval(sprintf("a2k%d=vpa(a2k(l));",l)); 
  endfor
  vpapABCD=double(eval(papABCD));

  % Convert the original transfer functions.
  [ra1apA,ra1apB,ra1apC,ra1apD] = schurOneMAPlatticeDoublyPipelined2Abcd(a1k);
  [ra2apA,ra2apB,ra2apC,ra2apD] = schurOneMAPlatticeDoublyPipelined2Abcd(a2k);
  
  % Construct the filter
  rapA=[[ra1apA, zeros(Na1s,Na2s)]; ...
        [zeros(Na2s,Na1s), ra2apA]];
  rapB=[ra1apB;ra2apB];
  rapC=[ra1apC,ra2apC]/2;
  rapD=(ra1apD+ra2apD)/2;
  rapABCD=[[rapA,rapB];[rapC,rapD]];

  % Check the filter polynomials
  tol = N*N*25*eps;
  [rn,rd]=Abcd2tf(rapA,rapB,rapC,rapD);
  R=1:2:((2*N)+1);
  if max(abs(rn(R+2)-n))>tol
    error("max(abs(rn(R+2)-n))>tol");
  endif
  if max(abs(rd(R)-d))>tol
    error("max(abs(rd(R)-d))>tol");
  endif
  
  % Compare rapABCD with the symbolic version, papABCD
  if max(max(abs(vpapABCD-rapABCD)))>eps
    error("N=%d,max(max(abs(vpapABCD-rapABCD)))>eps))",N);
  endif

  %
  % Construct the KYP lemma LMI
  %
  Ns=Na1s+Na2s;
  AB=[[papA,papB];[eye(Ns,Ns),zeros(Ns,1)]];
  CD=[[papC,papD];[zeros(1,Ns),1]];
  Phi=[[-1,0];[0,1]]; 
  a=sym("a");
  c=sym("c");
  Psi=[[0,a];[1/a,c]];
  % Force P and Q to be symmetric
  for l=1:Ns,
    eval(sprintf("P(%02d,%02d)=sym(\"P%02d%02d\",\"real\");",l,l,l,l));
    eval(sprintf("Q(%02d,%02d)=sym(\"Q%02d%02d\",\"real\");",l,l,l,l));
    for m=(l+1):Ns,
      eval(sprintf("P(%02d,%02d)=sym(\"P%02d%02d\",\"real\");",l,m,l,m));
      eval(sprintf("P(%02d,%02d)=P(%02d,%02d);",m,l,l,m));
      eval(sprintf("Q(%02d,%02d)=sym(\"Q%02d%02d\",\"real\");",l,m,l,m));
      eval(sprintf("Q(%02d,%02d)=Q(%02d,%02d);",m,l,l,m));
    endfor
  endfor
  Esq=sym("Esq","real","positive");
  Theta=(CD')*[[1,0];[0,-Esq]]*CD;
  Gamma=(kron(Phi,P)+kron(Psi,Q));
  K=(AB')*Gamma*AB;
  % Print
  pstr=sympy(K+Theta);
  strcat(pstr,"\n");
  fname=sprintf("%s_K_Theta_N_%d.py",strf,N);
  fhandle=fopen(fname,"w");
  fprintf(fhandle,pstr);
  fclose(fhandle);
  
  %
  % Clear
  % 
  eval(sprintf("clear %s a2apA a2apA a c P Q Esq",str_syms));
  
endfor

%
% Done
%
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
