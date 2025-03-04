% Abcd2tf_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="Abcd2tf_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

if exist("Abcd2tf_eigen") == 3
  % Using eigen3 templates and long doubles. See test/05/t0572a.m
  printf("Using Abcd2tf_eigen octfile\n");
  pAbcd2tf=@Abcd2tf_eigen;
  tol_impl=1e-6;
elseif exist("Abcd2tf") == 3
  % Using MPFR and 256 bit floats. See Abcd2tf.cc
  printf("Using Abcd2tf octfile\n");
  pAbcd2tf=@Abcd2tf;
  tol_impl=1e-13;
elseif exist("Abcd2tf") == 2
  % See Abcd2tf.m
  printf("Using Abcd2tf mfile\n");
  pAbcd2tf=@Abcd2tf;
  tol_impl=1e-3;
else
  error("Did not find an implementation of Abcd2tf!");
endif

% Design filter transfer function
tol=1e-11;N=30;dbap=0.1;dbas=40;fc=0.1;
[n,d]=cheby2(N,dbas,2*fc);

% Initial check : convert the filter transfer function to [A,b;c,d] and back
[A,B,C,D]=tf2Abcd(n,d);
[nn,dd,bb]=pAbcd2tf(A,B,C,D);
if max(abs(n-nn))>tol_impl
  error("max(abs(n-nn))(%g*tol_impl)>tol_impl\n",max(abs(n-nn))/tol_impl);
endif
if max(abs(d-dd))>tol_impl
  error("max(abs(d-dd))(%g*tol_impl)>tol_impl\n",max(abs(d-dd))/tol_impl);
endif

% Sanity checks
[A,B,C,D]=tf2Abcd(n,d);
try
  x=pAbcd2tf(A,B,C,D);
  error("Did not catch nargout == 1");
catch
  printf("%s\n", lasterr());
end_try_catch
try
  [w,x,y,z]=pAbcd2tf(A,B,C,D);
  error("Did not catch nargout == 4");
catch
  printf("%s\n", lasterr());
end_try_catch
try
  [w,x]=pAbcd2tf(A,B,C);
  error("Did not catch nargin != 4");
catch
  printf("%s\n", lasterr());
end_try_catch
try
  [w,x,y,z]=pAbcd2tf(A,B,C,D);
  error("Did not catch nargout == 4");
catch
  printf("%s\n", lasterr());
end_try_catch
try
  [w,x]=pAbcd2tf([],B,C,D);
  error("Did not catch A empty");
catch
  printf("%s\n", lasterr());
end_try_catch
try
  [w,x]=pAbcd2tf(rand(N,N+1),B,C,D);
  error("Did not catch A not square");
catch
  printf("%s\n", lasterr());
end_try_catch
try
  [w,x]=pAbcd2tf(A,[],C,D);
  error("Did not catch B empty");
catch
  printf("%s\n", lasterr());
end_try_catch
try
  [w,x]=pAbcd2tf(A,rand(N+1,1),C,D);
  error("Did not catch B rows=rows(A)");
catch
  printf("%s\n", lasterr());
end_try_catch
try
  [w,x]=pAbcd2tf(A,B,[],D);
  error("Did not catch C empty");
catch
  printf("%s\n", lasterr());
end_try_catch
try
  [w,x]=pAbcd2tf(A,B,rand(1,N+1),D);
  error("Did not catch C columns=columns(A)");
catch
  printf("%s\n", lasterr());
end_try_catch

% Convert filter transfer function to lattice form
if 1
  [k,epsilon,p,c] = tf2schurOneMlattice(n,d);
  [A,B,C,D]=schurOneMlattice2Abcd(k,epsilon,p,c);
else
  [s10,s11,s20,s00,s02,s22] = tf2schurNSlattice(n,d);
  [A,B,C,D]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
endif
[nn,dd,bb]=pAbcd2tf(A,B,C,D);
if max(abs(n-nn))>tol
  error("max(abs(n-nn))(%g*tol)>tol\n",max(abs(n-nn))/tol);
endif
if max(abs(d-dd))>2*tol
  error("max(abs(d-dd))(%g*tol)>2*tol\n",max(abs(d-dd))/tol);
endif

% Test similarity
[K,W]=KW(A,B,C,D);
T=optKW(K,W,1);
Ap=inv(T)*A*T;Bp=inv(T)*B;Cp=C*T;Dp=D;
[np,dp]=pAbcd2tf(Ap,Bp,Cp,Dp);
if max(abs(n-np))>tol
  error("max(abs(n-np))(%g*tol)>tol\n",max(abs(n-np))/tol);
endif
if max(abs(d-dp))>20*tol
  error("max(abs(d-dp))(%g*tol)>20*tol\n",max(abs(d-dp))/tol);
endif

% Use Leverrier's method to find the characteristic polynomial
[nn,dd]=pAbcd2tf(A,B,C,D);
% Check the transfer function
if max(abs(n-nn))>tol
  error("max(abs(n-nn))(%g*tol)>tol\n",max(abs(n-nn))/tol);
endif
if max(abs(d-dd))>2*tol
  error("max(abs(d-dd))(%g*tol)>2*tol\n",max(abs(d-dd))/tol);
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
if max(max(abs(Asum)))>20*tol
  error("max(max(abs(Asum)))(%g)>20*tol\n",max(max(abs(Asum))));
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
[nn,dd,BB]=pAbcd2tf(A,B,C,D);
[a,a_std]=cellfun(@Abcd2tf_char_poly_check,BB);
if max(abs(d-a))>10*tol
  error("max(abs(d-a))(%g*tol)>10*tol\n",max(abs(d-a))/tol);
endif
if max(a_std)>10*tol
  error("max(a_std)(%g*tol)>10*tol\n",max(a_std)/tol);
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
[NN,DD,BB]=pAbcd2tf(A,B,C,dd);
if max(abs(n-NN(1:3))) > 2*eps
  error("max(abs(n-NN(1 to 3))) > 2*eps");
endif
if max(abs(d-DD(1:3))) > 3*eps
  error("max(abs(d-DD(1 to 3))) > 3*eps");
endif
Cap =[   0.000000000000000   0.000000000000000   1.641351538057563];
ddap =  0.641351538057563;
[Nap,Dap,BBap]=pAbcd2tf(A,B,Cap,ddap);
if max(abs((fliplr(Nap(1:3))-Dap(1:3)))) > 2*eps
  error("max(abs((fliplr(Nap(1 to 3))-Dap(1 to 3)))) > 2*eps");
endif
if max(abs(d-Dap(1:3))) > 3*eps
  error("max(abs(d-Dap(1 to 3))) > 3*eps");
endif

% FIR
b=remez(20,[0 0.1 0.2 0.5]*2,[1 1 0 0]);
[k,epsilon,p,c] = tf2schurOneMlattice(b,[1;zeros(length(b)-1,1)]);
[A,B,C,dd]=schurOneMlattice2Abcd(k,epsilon,p,c);
[NN,DD]=pAbcd2tf(A,B,C,dd);
if max(abs(NN(:)-b(:)))>eps
  error("max(abs(NN-b))>eps");
endif
if max(abs(DD(:)-[1;zeros(length(b)-1,1)]))>eps
  error("max(abs(DD-[1;zeros(length(b)-1,1)]))>eps");
endif

% Recursive only
dbap=0.1;dbas=40;fc=0.1;
[n,d]=cheby2(20,dbas,2*fc);
[k,epsilon,p,c] = tf2schurOneMlattice([1;zeros(length(d)-1,1)],d);
[A,B,C,dd]=schurOneMlattice2Abcd(k,epsilon,p,c);
[NN,DD]=pAbcd2tf(A,B,C,dd);
if max(abs(NN(:)-[1;zeros(length(DD)-1,1)]))>200*tol
  error("max(abs(NN-[1;zeros(length(DD)-1,1)]))(%g*tol)>200*tol",
        max(abs(NN(:)-[1;zeros(length(DD)-1,1)]))/tol);
endif
if max(abs(DD(:)-d(:)))>tol/10
  error("max(abs(DD-d))(%g*tol)>tol/10",max(abs(DD(:)-d(:)))/tol);
endif

% Filter from schur_retimed_test.m
n = [  7.8437e-02   7.1066e-02   6.8570e-03   7.1064e-02   7.8448e-02 ];
d = [  1.0000e+00  -0.0000e+00  -1.1715e+00   0.0000e+00   4.8630e-01 ];
[k,epsilon,p,c] = tf2schurOneMlattice(n,d);
[A,B,C,dd]=schurOneMlattice2Abcd(k,epsilon,ones(size(k)),c);
[NN,DD]=pAbcd2tf(A,B,C,dd);
if max(abs(NN-n))>10*eps
  error("max(abs(NN-n))>10*eps");
endif
if max(abs(DD-d))>10*eps
  error("max(abs(DD-d))>10*eps");
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
[NN,DD]=pAbcd2tf(A,B,C,dd);
while abs(NN(1)) < 10*eps, NN = NN(2:end); endwhile
if max(abs(NN-n))>10*eps
  error("max(abs(NN-n))>10*eps");
endif
if max(abs(DD-d))>10*eps
  error("max(abs(DD-d))>10*eps");
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
[NN,DD]=pAbcd2tf(A,B,C,dd);
if max(abs(NN-n))>10*eps
  error("max(abs(NN-n))>10*eps");
endif
if max(abs(DD-d))>10*eps
  error("max(abs(DD-d))>10*eps");
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
