% complementaryFIRlattice2Abcd_symbolic_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
%
% Create a symbolic state-space representation of the complementary FIR
% lattice filter 
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

strf="complementaryFIRlattice2Abcd_symbolic_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

%
% Example FIR filter
%
N=10;
fp=0.1;
fs=0.25;
b0 = remez(N,2*[0 fp fs 0.5],[1 1 0 0]);
% Find lattice coefficients (b0 is scaled to |H|<=1)
[b0,b0c,kb0,kb0hat]=complementaryFIRlattice(b0(:));
[b0A,b0B,b0C,b0D,b0cC,b0cD]=complementaryFIRlattice2Abcd(kb0,kb0hat);

%
% State-space representation of the complementary FIR lattice filter
% (See complementaryFIRlattice2Abcd.m)
%

% Define symbols
str_syms="";
for l=0:N,
  str_syms=strcat(str_syms,sprintf(" k%d khat%d",l,l));
endfor
eval(sprintf("syms %s real",str_syms));

% Calculate each section
eval(sprintf("M0=[[zeros(2,N),[khat0;k0]]; [eye(N),zeros(N,1)]];"));
for l=1:N,
  eval(sprintf(["M%1d=[[eye(l),zeros(l,N+2-l)]; ...\n", ...
 "       [zeros(2,l),[[khat%d, k%d]; [k%d, -khat%d]], zeros(2,N-l)]; ...\n", ...
 "       [zeros(N-l,l+2), eye(N-l)]];\n"],l,l,l,l,l));
endfor

% Calculate overall A,B,cC,cD,C,D
Abcd=M0;
for l=1:N,
  eval(sprintf("Abcd=M%d*Abcd;",l));
endfor

% Output
fhandle=fopen(sprintf("%s_N_%d.latex",strf,N),"wt");
fprintf(fhandle,"Abcd=%s\n",latex(Abcd));
fclose(fhandle);

%
% Sanity check
%
for l=0:N,
  eval(sprintf("k%1d=vpa(kb0(%d));",l,l+1));
  eval(sprintf("khat%1d=vpa(kb0hat(%d));",l,l+1));
endfor
vAbcd=double(eval(Abcd));
if any(any(abs(vAbcd-[b0A,b0B;b0cC,b0cD;b0C,b0D])>eps))
  error("any(any(abs(vAbcd-[b0A,b0B;b0cC,b0cD;b0C,b0D])>eps))");
endif

vA = vAbcd(1:N,1:N);
vB = vAbcd(1:N,N+1);
vcC = vAbcd(N+1,1:N);
vcD = vAbcd(N+1,N+1);
vC = vAbcd(N+2,1:N);
vD = vAbcd(N+2,N+1);

[nAbcd,dAbcd]=Abcd2tf(vA,vB,vC,vD);
if max(abs(nAbcd(:)-b0(:)))>eps,
  error("max(abs(nAbcd(:)-b0(:)))>eps");
endif
if max(abs(dAbcd(:)-[1;zeros(N,1)]))>eps
  error("max(abs(dAbcd(:)-[1;zeros(N,1)]))>eps");
endif

[ncAbcd,dcAbcd]=Abcd2tf(vA,vB,vcC,vcD);
if max(abs(ncAbcd(:)-b0c(:)))>eps,
  error("max(abs(ncAbcd(:)-b0c(:)))>eps");
endif
if max(abs(dcAbcd(:)-[1;zeros(N,1)]))>eps
  error("max(abs(dcAbcd(:)-[1;zeros(N,1)]))>eps");
endif

eval(sprintf("clear %s",str_syms));

%
% Done
%
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
