% Abcd2tf_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("Abcd2tf_test.diary");
delete("Abcd2tf_test.diary.tmp");
diary Abcd2tf_test.diary.tmp

tol=1e-11;

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
if max(abs(n-np))>tol
  error("max(abs(n-np))(=%g)>tol\n",max(abs(n-np)));
endif
if max(abs(d-dp))>15*tol
  error("max(abs(d-dp))(=%g)>15*tol\n",max(abs(d-dp)));
endif

% Use Leverrier's method to find the characteristic polynomial
[nn,dd]=Abcd2tf(A,B,C,D);

% Check the transfer function 
if max(abs(n-nn))>tol
  error("max(abs(n-nn))(=%g)>tol\n",max(abs(n-nn)));
endif
if max(abs(d-dd))>tol
  error("max(abs(d-dd))(=%g)>tol\n",max(abs(d-dd)));
endif

% Check Cayley-Hamilton
function Asum=Abcd2tf_Cayley_Hamilton_check(d,_A)
  persistent A AAsum
  persistent init_done=false
  if nargin==2
    A=_A;
    AAsum=zeros(size(A));
    init_done=true;
    return;
  elseif ~init_done
    error("Not initialised!");
  endif
  AAsum=(AAsum+d)*A;
  Asum=AAsum;
endfunction

Abcd2tf_Cayley_Hamilton_check([],A);
Asum=arrayfun(@Abcd2tf_Cayley_Hamilton_check,d,"UniformOutput",false);
Asum=Asum{end};
if max(max(abs(Asum)))>2.5*tol
  error("max(max(abs(Asum)))(=%g)>2.5*tol\n",max(max(abs(Asum))));
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
if max(abs(d-a))>3*tol
  error("max(abs(d-a))(=%g)>3*tol\n",max(abs(d-a)));
endif
if max(a_std)>2*tol
  error("max(a_std)(=%g)>2*tol\n",max(a_std));
endif

%
% Additional test cases
%

% Extra state in transition matrix
[n,d]=butter(2,0.1);
A = [   0.951056516295154   0.000000000000000  -1.251313097563128; ...
        0.107496250311725   0.000000000000000  -0.127890368738360; ...
        0.048943483704846   0.000000000000000   0.609961559505565];
B = [   0.6997434187320259;   0.0715172277970699;  -0.3410949567895891];
C = [   0   1   0];
dd =  0.0200833655642112;
[N,D,BB]=Abcd2tf(A,B,C,dd);
if max(abs(n-N(1:3))) > 2*eps
  error("max(abs(n-N(1:3))) > 2*eps");
endif
if max(abs(d-D(1:3))) > 3*eps
  error("max(abs(d-D(1:3))) > 3*eps");
endif
Cap =[   0.000000000000000   0.000000000000000   1.641351538057563];
ddap =  0.641351538057563;
[Nap,Dap,BBap]=Abcd2tf(A,B,Cap,ddap);
if max(abs((fliplr(Nap(1:3))-Dap(1:3)))) > 2*eps
  error("max(abs((fliplr(Nap(1:3))-Dap(1:3)))) > 2*eps");
endif
if max(abs(d-Dap(1:3))) > 3*eps
  error("max(abs(d-Dap(1:3))) > 3*eps");
endif

% FIR
b=remez(20,[0 0.1 0.2 0.5]*2,[1 1 0 0]);
[k,epsilon,p,c] = tf2schurOneMlattice(b,[1;zeros(length(b)-1,1)]);
[A,B,C,dd]=schurOneMlattice2Abcd(k,epsilon,p,c);
[N,D]=Abcd2tf(A,B,C,dd);
if max(abs(D(:)-[1;zeros(length(b)-1,1)]))>eps
  error("max(abs(D(:)-[1;zeros(length(b)-1,1)]))>eps");
endif
if max(abs(N(:)-b(:)))>eps
  error("max(abs(N(:)-b(:)))>eps");
endif

% Recursive only
dbap=0.1;dbas=40;fc=0.1;
[n,d]=cheby2(20,dbas,2*fc);
[k,epsilon,p,c] = tf2schurOneMlattice([1;zeros(length(d)-1,1)],d);
[A,B,C,dd]=schurOneMlattice2Abcd(k,epsilon,p,c);
[N,D]=Abcd2tf(A,B,C,dd);
if max(abs(N(:)-[1;zeros(length(d)-1,1)]))>65*tol
  error("max(abs(N(:)-[1;zeros(length(d)-1,1)]))>65*tol");
endif
if max(abs(D(:)-d(:)))>tol/29
  error("max(abs(D(:)-d(:)))>tol/29");
endif

% Done
diary off
movefile Abcd2tf_test.diary.tmp Abcd2tf_test.diary;
