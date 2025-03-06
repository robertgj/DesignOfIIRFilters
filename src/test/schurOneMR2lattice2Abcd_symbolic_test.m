% schurOneMR2lattice2Abcd_symbolic_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
%
% Create symbolic descriptions of Schur one-multiplier all-pass filters with
% non-zero denominator coefficients only for powers of z^-2.
%
% The symbolic package does not allow:
%{
octave:1> pkg load symbolic
octave:2> sym k2
octave:3> M2=eye(N+1);
octave:4> M2(2:3,2:3)=[[-k2, (1+k2)]; [(1-k2), k2]]
error: operator =: no conversion for assignment of "class" to indexed "matrix"
%}

test_common;

pkg load symbolic

strf="schurOneMR2lattice2Abcd_symbolic_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol_eps=20;

%
% Design prototype lattice filters
%

% Filter from schur_retimed_test.m
f{1}.n = [  7.8437e-02   7.1066e-02   6.8570e-03   7.1064e-02   7.8448e-02 ];
f{1}.d = [  1.0000e+00  -0.0000e+00  -1.1715e+00   0.0000e+00   4.8630e-01 ];

% Alternative filter from schur_retimed_test.m
f{2}.n = [  4.5209e-02   7.3948e-02  -7.4929e-03  -7.7909e-02 ...
           -7.5057e-03   7.3948e-02   4.5215e-02 ];
f{2}.d = [  1.0000e+00  -0.0000e+00  -1.9955e+00   0.0000e+00 ...
            1.5866e+00  -0.0000e+00  -4.4804e-01 ];

% Filter from decimator_R2_test.m
f{3}.n = [  0.0155218243,   0.0240308959,  -0.0089315143,  -0.0671762676, ... 
           -0.0733321965,   0.0234771012,   0.1767248129,   0.2765539847, ... 
            0.2532118929,   0.1421835206,   0.0405161645  ];
f{3}.d = [  1.0000000000,   0.0000000000,  -0.4833140369,   0.0000000000, ... 
            0.4649814803,   0.0000000000,  -0.2543332803,   0.0000000000, ... 
            0.1080615273,   0.0000000000,  -0.0379951893,   0.0000000000, ... 
            0.0053801602 ];

% Filter from schurOneMlattice_sqp_slb_bandpass_test.m
f{4}.n = [  0.0058051915,   0.0012706269,   0.0118334335,   0.0176878978, ... 
            0.0381312659,   0.0319388656,   0.0251518542,   0.0069289127, ... 
            0.0056626625,  -0.0173425626,  -0.0608005653,  -0.1007087591, ... 
           -0.0769181188,   0.0235594241,   0.1211872739,   0.1432972866, ... 
            0.0605790600,  -0.0337599144,  -0.0851805010,  -0.0611581082, ... 
           -0.0269399170];
f{4}.d = [  1.0000000000,  -0.0000000000,   1.5714300377,  -0.0000000000, ... 
            1.8072457649,  -0.0000000000,   1.7877578723,  -0.0000000000, ... 
            1.5881253280,  -0.0000000000,   1.1504604633,  -0.0000000000, ... 
            0.7458129561,  -0.0000000000,   0.4015652852,  -0.0000000000, ... 
            0.1861402747,  -0.0000000000,   0.0599184246,  -0.0000000000, ... 
            0.0150432836 ];

%
% R=2 Schur one-multiplier all-pass (See schurOneMR2lattice2Abcd.m)
%

for u=1:length(f),

  [k,epsilon,p,c]=tf2schurOneMlattice(f{u}.n,f{u}.d);
  N=length(k);
  if rem(N,2)~=0
    error("rem(N,2)~=0");
  endif
  if N<=2
    error("N<=2");
  endif
 
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

  NS=(3*N/2)-1;
  Non2=N/2;

  % Initial module
  eval("rM2=[[0,1,0,0,0]; ...\n\
   [-k2,0,0,0,1+(E2*k2)]; ...\n\
   [1-(E2*k2),0,0,0,k2]; ...\n\
   [c0,c1,0,0,c2]];");
  eval("M2=[rM2,zeros(4,NS+1-5)];");
 
  for l=2:(Non2-1),
    eval(sprintf("rM%d=[[-k%d, 0,0,0,0,1+(E%d*k%d)];...\n\
       [1-(E%d*k%d),0,0,0,0,k%d];...\n\
       [0,1,c%d,0,0,c%d]];",2*l,2*l,2*l,2*l,2*l,2*l,2*l,(2*l)-1,2*l));
    eval(sprintf("M%d=[zeros(3,2+(3*%d)),rM%d,zeros(3,NS+1-6-2-(3*%d))];",
                 2*l,l-2,2*l,l-2));
  endfor

  % Final module
  eval(sprintf("rM%d=[[-k%d,0,0,1+(E%d*k%d)];...\n\
   [0,1,c%d,c%d];...\n\
   [1-(E%d*k%d),0,0,k%d]];", N,N,N,N,N-1,N,N,N,N));
  eval(sprintf("M%d=[zeros(3,NS+1-4),rM%d];",N,N));

  strABCD="ABCD=[M2";
  for l=2:Non2;
    strABCD=strcat(strABCD,sprintf(";M%d",2*l));
  endfor
  strABCD=strcat(strABCD,"];");
  eval(strABCD);
 
  % Extract A,B,C,D
  A=ABCD(1:NS,1:NS);
  B=ABCD(1:NS,NS+1);
  C=ABCD(NS+1,1:NS);
  D=ABCD(NS+1,NS+1);
  
  % Extract all-pass only states
  indexABCap=sort([1,(3*(1:Non2))-1,3*(1:(Non2-1))]);
  Aap=A(indexABCap,indexABCap); 
  Bap=ABCD(indexABCap,NS+1);
  Cap=ABCD(NS+2,indexABCap);
  Dap=ABCD(NS+2,NS+1);
  
  % Output
  fhandle=fopen(sprintf("%s_N_%d.latex",strf,N),"wt");
  fprintf(fhandle,"ABCD=%s\n",latex(ABCD));
  fclose(fhandle);

   % Check successive determinants
  for l=1:N,
    eval(sprintf("E%1d=vpa(epsilon(l));",l)); 
  endfor
  apAbcd=[[Aap,Bap];[Cap,Dap]];
  ev_apAbcd=eval(apAbcd);
  for l=1:2:N,
    if eval(sprintf("det(ev_apAbcd(1:l,1:l)) ~= 0"))
      error("det ev_apAbcd failed at l=%d",l);
    endif
  endfor
  for l=2:2:N,
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
  AapBap=[[Aap,Bap];[eye(N),zeros(N,1)]];
  CapDap=[Cap,Dap];

  % Check successive determinants
  ev_AapBap=eval(AapBap);
  for l=1:2:N,
    if eval(sprintf("det(ev_AapBap(1:l,1:l)) ~= 0"))
      error("det ev_AapBap failed at l=%d",l);
    endif
  endfor
  for l=2:2:N,
    if eval(sprintf("det(ev_AapBap(1:l,1:l)) ~= ((-1)^l)*k%d",l))
      error("det ev_AapBap failed at l=%d",l);
    endif
  endfor
  
  if N<10
    
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

    % Define KYP G matrix
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

    for l=1:N,
      for m=1:l,
        eval(sprintf("clear p%d%d q%d%d;",l,m,l,m));
      endfor
    endfor
    
  endif

  clear cp Esq
  
  %
  % Sanity checks
  %
  
  % Compare the retimed Schur lattice transfer functions to the originals 
  [reA,reB,reC,reD] = schurOneMR2lattice2Abcd(k,ones(size(k)),c);
  [~,red]=Abcd2tf(reA,reB,reC,reD);
  % Cannot compare ren with f{u}.n without epsilon scaling!
  if max(abs(red(1:length(f{u}.d))-f{u}.d))>10*eps,
    error("max(abs(red(1:length(f{%d}.d))-f{%d}.d))(%g*eps)>10*eps",
            u,u,max(abs(red(1:length(f{u}.d))-f{u}.d))/eps);
  endif

  [rA,rB,rC,rD,rAap,rBap,rCap,rDap] = schurOneMR2lattice2Abcd(k,epsilon,c);
  [sn,sd]=Abcd2tf(rA,rB,rC,rD);
  while abs(sn(1)) < 10*eps, sn = sn(2:end); endwhile
  if max(abs(sn(1:length(f{u}.n))-f{u}.n))>10*eps,
    error("max(abs(sn(1:length(f{%d}.n))-f{%d}.n))(%g*eps)>10*eps",
            u,u,max(abs(sn(1:length(f{u}.n))-f{u}.n))/eps);
  endif
  if max(abs(sd(1:length(f{u}.d))-f{u}.d))>10*eps,
    error("max(abs(sd(1:length(f{%d}.d))-f{%d}.d))(%g*eps)>10*eps",
            u,u,max(abs(sd(1:length(f{u}.d))-f{u}.d))/eps);
  endif
  [snap,sdap]=Abcd2tf(rAap,rBap,rCap,rDap);
  if max(abs(snap-fliplr(f{u}.d)))>10*eps
    error("max(abs(snap-fliplr(f{%d}.d)))(%g*eps)>10*eps",
            u,max(abs(snap-fliplr(f{u}.d)))/eps);
  endif
  if max(abs(sdap-f{u}.d))>10*eps
    error("max(abs(sdap-f{%d}.d))(%g*eps)>10*eps",
            u,max(abs(sdap-f{u}.d))/eps);
  endif

  % Evaluate the symbolic version
  c0=vpa(c(1));
  for l=1:N,
    eval(sprintf("E%d=vpa(epsilon(l));",l)); 
    eval(sprintf("k%d=vpa(k(l));",l)); 
    eval(sprintf("c%d=vpa(c(l+1));",l));
  endfor
  vA = double(eval(A));
  vB = double(eval(B));
  vC = double(eval(C));
  vD = double(eval(D));
  [vn,vd]=Abcd2tf(vA,vB,vC,vD);
  while abs(vn(1)) < 10*eps, vn = vn(2:end); endwhile
  if max(abs(vn(1:length(f{u}.n))-f{u}.n))>10*eps,
    error("max(abs(vn(1:length(f{%d}.n))-f{%d}.n))(%g*eps)>10*eps",
            u,u,max(abs(vn(1:length(f{u}.n))-f{u}.n))/eps);
  endif
  if max(abs(vd(1:length(f{u}.d))-f{u}.d))>10*eps,
    error("max(abs(vd(1:length(f{%d}.d))-f{%d}.d))(%g*eps)>10*eps",
            u,u,max(abs(vn(1:length(f{u}.n))-f{u}.n))/eps);
  endif
  
  rABCD=[rA,rB;rC,rD];
  vABCD=[vA,vB;vC,vD];
  if max(max(abs(vABCD-rABCD)))>eps
    error("max(max(abs(vABCD-rABCD)))(%g)>eps",
            max(max(abs(vABCD-rABCD)))/eps);
    vABCD-rABCD
  endif

  AapBapCapDap=[[Aap,Bap];[Cap,Dap]];
  vAapBapCapDap=double(eval(AapBapCapDap));
  rAapBapCapDap=[rAap,rBap;rCap,rDap];
  if max(max(abs(vAapBapCapDap-rAapBapCapDap)))>eps
    error("max(max(abs(vAapBapCapDap-rAapBapCapDap)))(%g*eps)>eps",
            max(max(abs(vAapBapCapDap-rAapBapCapDap)))/eps);
    vAapBapCapDap-rAapBapCapDap
  endif

  % Check successive determinants
  for l=1:N,
    if abs(det(vAapBapCapDap(1:l,1:l)) - (((-1)^l)*k(l)))>tol_eps*eps
      error("det vAapBapCapDap failed at l=%d",l);
    endif
  endfor
  
  vAap = vAapBapCapDap(1:(end-1),1:(end-1));
  vBap = vAapBapCapDap(1:(end-1),end);
  vCap = vAapBapCapDap(end,1:(end-1));
  vDap = vAapBapCapDap(end,end);
  [apn,apd]=Abcd2tf(vAap,vBap,vCap,vDap);
  if max(abs(apd-f{u}.d))>10*eps,
    error("max(abs(apd-f{%d}.d))(%g*eps)>10*eps",
            u,max(abs(apd-f{u}.d))/eps);
  endif
  if max(abs(fliplr(apn)-f{u}.d))>10*eps,
    error("max(abs(fliplr(apn)-f{%d}.d))(%g*eps)>10*eps",
            u,max(abs(fliplr(apn)-f{u}.d))/eps);
  endif

  eval(sprintf("clear %s",str_syms));

endfor

%
% Done
%
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
