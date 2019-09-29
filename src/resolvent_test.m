% resolvent_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("resolvent_test.diary");
unlink("resolvent_test.diary.tmp");
diary resolvent_test.diary.tmp

show_profile=false;

% Design filter transfer function
N=20;dbap=0.1;dbas=40;fc=0.1;
if 1
  [n,d]=cheby2(N,dbas,2*fc);
elseif 0
  [n,d]=ellip(N,dbap,dbas,2*fc);
else 
  [n,d]=butter(N,2*fc);
endif
nplot=1024;
[h,wplot]=freqz(n,d,nplot);

% Convert filter transfer function to lattice form
if 1
  [k,epsilon,p,c]=tf2schurOneMlattice(n,d);
  [A,bb,cc,dd]=schurOneMlattice2Abcd(k,epsilon,p,c);
else
  [s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n,d);
  [A,bb,cc,dd]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
endif

%
% Brute force calculation of (zI-A)^(-1)
%
% Brute force calculation of the response
function hk=brute_force_response(resk,_bb,_cc,_dd)
  persistent bb cc dd init_done=false
  if nargin==4
    bb=_bb;
    cc=_cc;
    dd=_dd;
    init_done=true;
    return;
  elseif init_done==false
    error("init_done==false");
  endif
  hk=(cc*resk*bb)+dd;
endfunction
% Use the Octave built-in matrix inverse
% Test nargin==2
res_matrix_nargin_2=cell2mat(resolvent(2*pi*fc,A));
res_matrix_nargin_3=cell2mat(resolvent(2*pi*fc,A,"matrix_inverse"));
if max(max(abs(res_matrix_nargin_2-res_matrix_nargin_3))) ~= 0
  error("max(max(abs(res_matrix_nargin_2-res_matrix_nargin_3))) ~= 0");
endif
% Test matrix_inverse
profile on
res_matrix=resolvent(wplot,A,"matrix_inverse");
profile off
info_matrix=profile("info");
brute_force_response([],bb,cc,dd);
h_matrix=cellfun(@brute_force_response,res_matrix,"UniformOutput",false);
h_matrix=cell2mat(h_matrix);
err_matrix=max(abs(h_matrix-h));
if err_matrix > 9.27e-7
  error("err_matrix > 9.27e-7");
endif
% Use the LAPACK ZGBSV banded matrix inverse function 
profile on
res_hess=resolvent(wplot,A,"hessenberg_inverse");
profile off
info_hess=profile("info");
brute_force_response([],bb,cc,dd);
h_hess=cellfun(@brute_force_response,res_hess,"UniformOutput",false);
h_hess=cell2mat(h_hess);
err_hess=max(abs(h_hess-h));
if err_hess > 9.27e-7
  error("err_hess > 9.27e-7");
endif
% Use Zhongs algorithm with the LAPACK ZTRTRI triangular matrix inverse function 
profile on
res_zhong=resolvent(wplot,A,"complex_zhong_inverse");
profile off
info_zhong=profile("info");
brute_force_response([],bb,cc,dd);
h_zhong=cellfun(@brute_force_response,res_zhong,"UniformOutput",false);
h_zhong=cell2mat(h_zhong);
err_zhong=max(abs(h_zhong-h));
if err_zhong > 9.27e-7
  error("err_zhong > 9.27e-7");
endif
% Use Zhongs algorithm written in Octave (for comparison)
profile on
res_zhong_m=resolvent(wplot,A,"zhong_inverse");
profile off
info_zhong_m=profile("info");
brute_force_response([],bb,cc,dd);
h_zhong_m=cellfun(@brute_force_response,res_zhong_m,"UniformOutput",false);
h_zhong_m=cell2mat(h_zhong_m);
err_zhong_m=max(abs(h_zhong_m-h));
if err_zhong_m > 9.27e-7
  error("err_zhong_m > 9.27e-7");
endif

%
% Calculation of (zI-A)^(-1) with Leverrier's method
%
[n_lev,d_lev,B_lev]=Abcd2tf(A,bb,cc,dd);
% Reshape B_lev to an NxN array of length N+1 polynomials
B_lev_mat=cell2mat(B_lev);
B_lev=reshape(B_lev_mat,[N,N,N+1]);
% Calculate the frequency response of each component of the resolvent
function res_k_l=freqz_resolvent(k,l,_w,_B,d)
  persistent w B hd init_done=false
  if nargin==5
    w=_w(:);
    B=_B;
    hd=freqz(d,1,w);
    init_done=true;
    return;
  elseif init_done==false
    error("init_done==false");
  endif
  b=B(k,l,:);
  res_k_l=freqz([0;b(:)],1,w)./hd;
endfunction
freqz_resolvent([],[],wplot,B_lev,d);
rowsN=kron((1:N)',ones(1,N));
colsN=kron(1:N,ones(N,1));
profile on
res_lev=arrayfun(@freqz_resolvent,rowsN,colsN,"UniformOutput",false);
profile off
info_lev=profile("info");
% res_lev is a NxN cell array of length nplot responses.
% The following reshapes it to a length nplot cell vector of NxN arrays.
% An example of reshaping the output of freqz_resolvent():
%{
u={[111;211;311;411],[112;212;312;412];[121;221;321;421],[122;222;322;422]}
v=cell2mat(u)
x=reshape(v,4,2,2)
y=mat2cell(x,ones(4,1),2)
z=reshape(y{1,1},2,2)
%}
res_lev_mat=cell2mat(res_lev);
res_lev_mat=reshape(res_lev_mat,nplot,N,N);
res_lev=mat2cell(res_lev_mat,ones(nplot,1),N);
% Calculate the overall frequency response
function hk=lev_response(resk,_bb,_cc,_dd)
  persistent bb cc dd init_done=false
  if nargin==4
    bb=_bb;
    cc=_cc;
    dd=_dd;
    init_done=true;
    return;
  elseif init_done==false
    error("init_done==false");
  endif
  reskm=reshape(resk,length(cc),length(bb));
  hk=(cc*reskm*bb)+dd;
endfunction
lev_response([],bb,cc,dd);
h_lev=cellfun(@lev_response,res_lev,"UniformOutput",false);
h_lev=cell2mat(h_lev);
% Check the error in the response with the Leverrier recursion
err_lev=max(abs(h_lev-h));
if err_lev > 1.12e-6 
  error("err_lev > 1.12e-6");
endif

%
% Show profile info
%
if show_profile
  printf("\nProfile for builtin matrix inverse:\n");
  profshow(info_matrix,5);
  printf("\nProfile for Hessenberg inverse using LAPACK ZGBSV:\n");
  profshow(info_hess,5);
  printf("\nProfile for Hessenberg inverse using Zhong's algorithm(octfile):\n");
  profshow(info_zhong,5); 
  printf("\nProfile for Hessenberg inverse using Zhong's algorithm(mfile):\n");
  profshow(info_zhong_m,5); 
  printf("\nProfile for Leverrier's recursion:\n"); 
  profshow(info_lev,10);
endif

% Done
diary off
movefile resolvent_test.diary.tmp resolvent_test.diary;
