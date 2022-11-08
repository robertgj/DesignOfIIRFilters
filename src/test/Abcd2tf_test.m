% Abcd2tf_test.m
% Copyright (C) 2017-2022 Robert G. Jenssen

test_common;

strf="Abcd2tf_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

ftype=check_octave_file("Abcd2tf");

% Design filter transfer function
tol=1e-11;N=30;dbap=0.1;dbas=40;fc=0.1;
if 1
  [n,d]=cheby2(N,dbas,2*fc);
else 
  [n,d]=butter(N,2*fc);
endif

% Sanity checks
[A,B,C,D]=tf2Abcd(n,d);
try
  x=Abcd2tf(A,B,C,D);
  error("Did not catch nargout == 1");
catch
  printf("%s\n", lasterror().message);
end_try_catch
try
  [w,x,y,z]=Abcd2tf(A,B,C,D);
  error("Did not catch nargout == 4");
catch
  printf("%s\n", lasterror().message);
end_try_catch
try
  [w,x]=Abcd2tf(A,B,C);
  error("Did not catch nargin != 4");
catch
  printf("%s\n", lasterror().message);
end_try_catch
try
  [w,x,y,z]=Abcd2tf(A,B,C,D);
  error("Did not catch nargout == 4");
catch
  printf("%s\n", lasterror().message);
end_try_catch
try
  [w,x]=Abcd2tf([],B,C,D);
  error("Did not catch A empty");
catch
  printf("%s\n", lasterror().message);
end_try_catch
try
  [w,x]=Abcd2tf(rand(N,N+1),B,C,D);
  error("Did not catch A not square");
catch
  printf("%s\n", lasterror().message);
end_try_catch
try
  [w,x]=Abcd2tf(A,[],C,D);
  error("Did not catch B empty");
catch
  printf("%s\n", lasterror().message);
end_try_catch
try
  [w,x]=Abcd2tf(A,rand(N+1,1),C,D);
  error("Did not catch B rows=rows(A)");
catch
  printf("%s\n", lasterror().message);
end_try_catch
try
  [w,x]=Abcd2tf(A,B,[],D);
  error("Did not catch C empty");
catch
  printf("%s\n", lasterror().message);
end_try_catch
try
  [w,x]=Abcd2tf(A,B,rand(1,N+1),D);
  error("Did not catch C columns=columns(A)");
catch
  printf("%s\n", lasterror().message);
end_try_catch

% Convert filter transfer function to [A,b;c,d] and back
if(ftype==3)
  [A,B,C,D]=tf2Abcd(n,d);
  [nn,dd,bb]=Abcd2tf(A,B,C,D);
  if max(abs(n-nn))>500*eps
    error("max(abs(n-nn))(=%g)>500*eps\n",max(abs(n-nn)));
  endif
  if max(abs(d-dd))>eps
    error("max(abs(d-dd))(=%g)>eps\n",max(abs(d-dd)));
  endif
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
if max(abs(d-dp))>20*tol
  error("max(abs(d-dp))(=%g)>20*tol\n",max(abs(d-dp)));
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

% Filter from schur_retimed_test.m
n = [  7.8437e-02   7.1066e-02   6.8570e-03   7.1064e-02   7.8448e-02 ];
d = [  1.0000e+00  -0.0000e+00  -1.1715e+00   0.0000e+00   4.8630e-01 ];
[k,epsilon,p,c] = tf2schurOneMlattice(n,d);
[A,B,C,dd]=schurOneMlattice2Abcd(k,epsilon,ones(size(k)),c);
[N,D]=Abcd2tf(A,B,C,dd);
if max(abs(N-n))>10*eps
  error("max(abs(N-n))>10*eps");
endif
if max(abs(D-d))>10*eps
  error("max(abs(D-d))>10*eps");
endif

% Filter from decimator_R2_test.m
n = [  0.0155218243,   0.0240308959,  -0.0089315143,  -0.0671762676, ... 
      -0.0733321965,   0.0234771012,   0.1767248129,   0.2765539847, ... 
       0.2532118929,   0.1421835206,   0.0405161645  ];
d = [  1.0000000000,   0.0000000000,  -0.4833140369,   0.0000000000, ... 
       0.4649814803,   0.0000000000,  -0.2543332803,   0.0000000000, ... 
       0.1080615273,   0.0000000000,  -0.0379951893,   0.0000000000, ... 
       0.0053801602 ];
[k,epsilon,p,c] = tf2schurOneMlattice(n,d);
[A,B,C,dd]=schurOneMlattice2Abcd(k,epsilon,ones(size(k)),c);
[N,D]=Abcd2tf(A,B,C,dd);
while abs(N(1)) < 10*eps, N = N(2:end); endwhile
if max(abs(N-n))>10*eps
  error("max(abs(N-n))>10*eps");
endif
if max(abs(D-d))>10*eps
  error("max(abs(D-d))>10*eps");
endif

% Filter from schurOneMlattice_sqp_slb_bandpass_test.m
n = [  0.0058051915,   0.0012706269,   0.0118334335,   0.0176878978, ... 
       0.0381312659,   0.0319388656,   0.0251518542,   0.0069289127, ... 
       0.0056626625,  -0.0173425626,  -0.0608005653,  -0.1007087591, ... 
      -0.0769181188,   0.0235594241,   0.1211872739,   0.1432972866, ... 
       0.0605790600,  -0.0337599144,  -0.0851805010,  -0.0611581082, ... 
      -0.0269399170];
d = [  1.0000000000,  -0.0000000000,   1.5714300377,  -0.0000000000, ... 
       1.8072457649,  -0.0000000000,   1.7877578723,  -0.0000000000, ... 
       1.5881253280,  -0.0000000000,   1.1504604633,  -0.0000000000, ... 
       0.7458129561,  -0.0000000000,   0.4015652852,  -0.0000000000, ... 
       0.1861402747,  -0.0000000000,   0.0599184246,  -0.0000000000, ... 
       0.0150432836 ];
[k,epsilon,p,c] = tf2schurOneMlattice(n,d);
[A,B,C,dd]=schurOneMlattice2Abcd(k,epsilon,ones(size(k)),c);
[N,D]=Abcd2tf(A,B,C,dd);
if max(abs(N-n))>10*eps
  error("max(abs(N-n))>10*eps");
endif
if max(abs(D-d))>10*eps
  error("max(abs(D-d))>10*eps");
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
