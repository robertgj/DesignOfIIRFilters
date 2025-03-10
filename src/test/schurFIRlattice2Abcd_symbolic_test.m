% schurFIRlattice2Abcd_symbolic_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
%
% Create a symbolic state-space representation of the Schur FIR
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

strf="schurFIRlattice2Abcd_symbolic_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

%
% Example Schur polynomial
%
N=10;fc=0.1;dBap=5e-1;dBas=40;
[~,b0]=ellip(N,dBap,dBas,2*fc);

% Find lattice coefficients (b0 is scaled to |H|<=1)
b0=b0(:)'/b0(1);
kb0=schurFIRdecomp(b0);
[b0A,b0B,b0C,b0D]=schurFIRlattice2Abcd(kb0);

%
% State-space representation of the Schur lattice FIR filter
% (See schurFIRlattice2Abcd.m)
%

% Define symbols
str_syms="";
for l=1:N,
  str_syms=strcat(str_syms,sprintf(" k%d khat%d",l,l));
endfor
eval(sprintf("syms %s real",str_syms));

% Calculate each section
eval(sprintf("M0=[[zeros(2,N),[1;1]]; [eye(N),zeros(N,1)]];"));
for l=1:N,
  eval(sprintf(["M%d=[[eye(l-1),zeros(l-1,N+3-l)]; ...\n", ...
 "    [zeros(3,l-1),[[0,1,0];[1,0,k%d];[k%d,0,1]],zeros(3,N-l)]; ...\n", ...
 "    [zeros(N-l,2+l),eye(N-l)]];"],l,l,l));
endfor

% Calculate overall A,B,C,D
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
for l=1:N,
  eval(sprintf("k%1d=vpa(kb0(%d));",l,l));
endfor
vAbcd=double(eval(Abcd));
if any(any(abs(vAbcd(1:(N+1),1:(N+1))-[b0A,b0B;b0C,b0D])>eps))
  error("any(any(abs(vAbcd-[b0A,b0B;b0C,b0D])>eps))");
endif

vA = vAbcd(1:N,1:N);
vB = vAbcd(1:N,N+1);
vC = vAbcd(N+1,1:N);
vD = vAbcd(N+1,N+1);

[nAbcd,dAbcd]=Abcd2tf(vA,vB,vC,vD);
if max(abs(nAbcd(:)-b0(:)))>100*eps,
  error("max(abs(nAbcd-b0))>100*eps");
endif
if max(abs(dAbcd(:)-[1;zeros(N,1)]))>eps
  error("max(abs(dAbcd-[1;zeros(N,1)]))>eps");
endif

eval(sprintf("clear %s",str_syms));

%
% Done
%
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
