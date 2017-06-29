% Abcd2tf_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("Abcd2tf_test.diary");
unlink("Abcd2tf_test.diary.tmp");
diary Abcd2tf_test.diary.tmp

format short e
tol=2.6e-11;

% Design filter transfer function
N=30;dbap=0.1;dbas=40;fc=0.1;
if 1
  [n,d]=cheby2(N,dbas,2*fc);
elseif 0
  [n,d]=ellip(N,dbap,dbas,2*fc);
else 
  [n,d]=butter(N,2*fc);
endif

% Convert filter transfer function to lattice form
if 1
  [k,epsilon,p,c] = tf2schurOneMlattice(n,d);
  [A,B,C,D]=schurOneMlattice2Abcd(k,epsilon,p,c);
else
  [s10,s11,s20,s00,s02,s22] = tf2schurNSlattice(n,d);
  [A,B,C,D]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
endif

% Test similarity
[K,W]=KW(A,B,C,D);
T=optKW(K,W,1);
Ap=inv(T)*A*T;Bp=inv(T)*B;Cp=C*T;Dp=D;
[np,dp]=Abcd2tf(Ap,Bp,Cp,Dp);
if max(abs(n-np))>tol/4.264
  error("max(abs(n-np))(=%g)>tol/4.264\n",max(abs(n-np)));
endif
if max(abs(d-dp))>tol/0.7146
  error("max(abs(d-dp))(=%g)>tol/0.7146\n",max(abs(d-dp)));
endif

% Use Leverrier's method to find the characteristic polynomial
[nn,dd]=Abcd2tf(A,B,C,D);

% Check the transfer function 
if max(abs(n-nn))>tol/9
  error("max(abs(n-nn))(=%g)>tol/9\n",max(abs(n-nn)));
endif
if max(abs(d-dd))>tol/3
  error("max(abs(d-dd))(=%g)>tol/3\n",max(abs(d-dd)));
endif

% Check Cayley-Hamilton
function Asum=Abcd2tf_Cayley_Hamilton_check(d,_A)
  persistent A Asum
  persistent init_done=false
  if nargin==2
    A=_A;
    Asum=zeros(size(A));
    init_done=true;
    return;
  elseif ~init_done
    error("Not initialised!");
  endif
  Asum=(Asum+d)*A;
endfunction
Abcd2tf_Cayley_Hamilton_check([],A);
Asum=arrayfun(@Abcd2tf_Cayley_Hamilton_check,d,"UniformOutput",false);
Asum=Asum{end};
if max(max(abs(Asum)))>tol
  error("max(max(abs(Asum)))(=%g)>tol\n",max(max(abs(Asum))));
endif

% Check BB by multiplying out
function [ak,ak_std]=Abcd2tf_char_poly_check(BBk,_A)
  persistent A tmp_BBk k
  persistent init_done=false
  if nargin==2
    A=_A;
    k=0;
    init_done=true;
    return;
  elseif nargin~=1
    print_usage("[ak,ak_std]=Abcd2tf_char_poly_check(BBk[,A])");
  elseif ~init_done
    error("Not initialised!");
  endif
  k=k+1;
  if k==1
    tmp_BBk=BBk;
    ak=1;
    ak_std=0;
  elseif k>(rows(A)+1)
    error("number of iterations,k>(rows(A)+1)");
  else
    tmp_BBk=BBk-A*tmp_BBk;
    diag_ak=diag(tmp_BBk);
    ak=mean(diag_ak);
    ak_std=std(diag_ak);
    tmp_BBk=BBk;
  endif
endfunction
Abcd2tf_char_poly_check([],A);
[nn,dd,BB]=Abcd2tf(A,B,C,D);
[a,a_std]=cellfun(@Abcd2tf_char_poly_check,BB);
if max(abs(d-a))>tol
  error("max(abs(d-a))(=%g)>tol\n",max(abs(d-a)));
endif
if max(a_std)>tol
  error("max(a_std)(=%g)>tol\n",max(a_std));
endif

diary off
movefile Abcd2tf_test.diary.tmp Abcd2tf_test.diary;
