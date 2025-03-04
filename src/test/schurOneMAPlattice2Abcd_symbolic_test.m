% schurOneMAPlattice2Abcd_symbolic_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
%
% Create symbolic descriptions of Schur one-multiplier all-pass filters for
% use when trying to design IIR filters with the KYP lemma. The epsilon
% and p scaling parameters can be calculated when the k coefficients are known.
%
% The symbolic package does not allow:
%{
octave:1> pkg load symbolic
octave:2> sym k2
octave:3> M2=eye(N+1);
octave:4> M2(2:3,2:3)=[[-k2, (1+k2)]; [(1-k2), k2]]
error: operator =: no conversion for assignment of 'class' to indexed 'matrix'
%}

test_common;

pkg load symbolic

strf="schurOneMAPlattice2Abcd_symbolic_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol_eps=10;

%
% Design a prototype lattice filters with no scaling by p or epsilon
%

N=6;dBas=40;fc=0.1;
[n,d]=cheby2(N,dBas,2*fc);
f{1}.n = n;
f{1}.d = d;

N=7;dBas=40;fc=0.1;
[n,d]=cheby2(N,dBas,2*fc);
f{2}.n = n;
f{2}.d = d;

% Filter from decimator_R2_test.m
f{3}.n = [  0.0155218243,   0.0240308959,  -0.0089315143,  -0.0671762676, ... 
           -0.0733321965,   0.0234771012,   0.1767248129,   0.2765539847, ... 
            0.2532118929,   0.1421835206,   0.0405161645    0.0000000000, ...
            0.0000000000  ];
f{3}.d = [  1.0000000000,   0.0000000000,  -0.4833140369,   0.0000000000, ... 
            0.4649814803,   0.0000000000,  -0.2543332803,   0.0000000000, ... 
            0.1080615273,   0.0000000000,  -0.0379951893,   0.0000000000, ... 
            0.0053801602  ];

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

for u=1:length(f),
  
  N=length(f{u}.n)-1;
  n=f{u}.n;
  d=f{u}.d;

  %
  % Design a prototype lattice filter with no scaling by p or epsilon
  %
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  [A,B,C,D]=schurOneMlattice2Abcd(k,epsilon,p,c);
  [Aap,Bap,Cap,Dap]=schurOneMAPlattice2Abcd(k,ones(size(k)),ones(size(k)));
  ABCDap=[Aap,Bap;Cap,Dap];

  % Check successive determinants
  for l=1:N,
    if abs(det(A(1:l,1:l)) - (((-1)^l)*k(l))) > tol_eps*eps
      error("det A failed at l=%d",l);
    endif
    if abs(det(Aap(1:l,1:l)) - (((-1)^l)*k(l))) > tol_eps*eps
      error("det Aap failed at l=%d",l);
    endif
  endfor


  %
  % Schur one-multiplier allpass (See schurOneMlattice2Abcd.m)
  %

  % Define symbols
  str_syms="";
  for l=1:N,
    str_syms=strcat(str_syms,sprintf(" k%d",l));
  endfor
  eval(sprintf("syms %s",str_syms));

  for l=1:N,
    eval(sprintf("M%1d=[[eye(l-1),zeros(l-1,N+2-l)]; ...\n\
     [zeros(2,l-1),[[-k%d, (1+k%d)]; [(1-k%d), k%d]], zeros(2,N-l)]; ...\n\
     [zeros(N-l,l+1), eye(N-l)]];\n",l, l,l,l,l));
  endfor

  Abcd=eye(N+1);
  for l=1:N,
    eval(sprintf("Abcd=M%d*Abcd;",l));
  endfor
  
  % Output
  fhandle=fopen(sprintf("%s_N_%d.latex",strf,N),"wt");
  fprintf(fhandle,"Abcd=%s\n",latex(Abcd));
  fclose(fhandle);

  % Sanity check
  for l=1:N,
    eval(sprintf("k%1d=vpa(k(%d));",l,l));
  endfor
  vAbcd=double(eval(Abcd));
  if any(any(abs(vAbcd-ABCDap)>eps))
    error("any(any(abs(vAbcd-ABCDap)>eps))");
  endif

  vapA = vAbcd(1:(end-1),1:(end-1));
  vapB = vAbcd(1:(end-1),end);
  vapC = vAbcd(end,1:(end-1));
  vapD = vAbcd(end,end);
  [apn,apd]=Abcd2tf(vapA,vapB,vapC,vapD);
  if max(abs(fliplr(apn)-d))>tol_eps*eps,
    error("max(abs(fliplr(apn)-d))>tol_eps*eps");
  endif
  if max(abs(apd-d))>tol_eps*eps,
    error("max(abs(apd-d))>tol_eps*eps");
  endif
  
  eval(sprintf("clear %s",str_syms));
  
endfor

%
% Done
%
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
