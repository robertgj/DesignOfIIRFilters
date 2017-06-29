% parhi_ex12_9_1_test.m
%

test_common;

unlink("parhi_ex12_9_1_test.diary");
diary parhi_ex12_9_1_test.diary

format compact

verbose=false
tol=1e-4
maxiter=500

% Filter specifications (frequencies are normalised to sample rate)
U=2;V=0;M=4;Q=2;R=4;
fap=0.1;fas=0.15;Wap=1;Was=1;

strM=sprintf("%%s:fap=%g,fas=%g,Wap=%%g,Was=%%g",fap,fas);
strP=strcat(strM, sprintf(",dbap=%%g,dbas=%%g"));
strd=sprintf("parhi_ex12_9_1_%%s_%%s");

% Frequency points
n=1000;

% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q);

% Amplitude pass-band constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*(fap/0.5))+1;
nas=floor(n*(fas/0.5))+1;
Ad=[ones(nap,1);zeros(n-nap,1)];
Adu=[];
Adl=[];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Amplitude stop-band constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay constraints
wt=[];
Td=[];
Tdu=[];
Tdl=[];
Wt=[];

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

%
% Initial filter
%
wap=pi*fap/0.5;
was=pi*fas/0.5;
Mon2=M/2;
Qon2=Q/2;
Mphi=(was+((pi-was)*(0:(Mon2-1))/Mon2))';
Qphi=R*(wap*(1:Qon2)/Qon2)';
d0=[0.03;-1*ones(U,1);zeros(V,1);ones(Mon2,1);Mphi;0.6*ones(Qon2,1);Qphi];

% Barrier function optimisation
d1=xInitHd(d0,U,V,M,Q,R,wa,Ad,Wa,[],[],[],[],[],[],[],[],[],tol);
str1=sprintf("Initial Parhi ex. 12.9.1 : U=%d,V=%d,M=%d,Q=%d,R=%d", U,V,M,Q,R);
close
showResponse(d1,U,V,M,Q,R,str1);
print(sprintf(strd,"initial","d1"),"-dpdflatex");
close
showResponsePassBands(0,fap,-3,3,d1,U,V,M,Q,R,str1);
print(sprintf(strd,"initial","d1pass"),"-dpdflatex");
close
showZPplot(d1,U,V,M,Q,R,str1);
print(sprintf(strd,"initial","d1pz"),"-dpdflatex");
close

%
% SOCP MMSE pass
%
[d2,E,socp_iter,func_iter,feasible] = ...
  iir_socp_mmse([],d1,xu,xl,inf,U,V,M,Q,R, ...
                wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
                wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                maxiter,tol,verbose);
if feasible == 0 
   error("Parhi ex. 12.9.1 d2 infeasible");
endif
strM2=sprintf(strM,"d2",Wap,Was);
close
showResponse(d2,U,V,M,Q,R,strM2);
print(sprintf(strd,"mmse","d2"),"-dpdflatex");
close
showResponsePassBands(0,fap,-3,3,d2,U,V,M,Q,R,strM2);
print(sprintf(strd,"mmse","d2pass"),"-dpdflatex");
close
showZPplot(d2,U,V,M,Q,R,strM2);
print(sprintf(strd,"mmse","d2pz"),"-dpdflatex");

print_pole_zero(d2,U,V,M,Q,R,"d2");
print_pole_zero(d2,U,V,M,Q,R,"d2","parhi_ex12_9_1_test_d2_coef.m");
[N2,D2]=x2tf(d2,U,V,M,Q,R);
print_polynomial(N2,"N2");
print_polynomial(N2,"N2","parhi_ex12_9_1_test_N2_coef.m");
print_polynomial(D2,"D2");
print_polynomial(D2,"D2","parhi_ex12_9_1_test_D2_coef.m");

save parhi_ex12_9_1_test.mat U V M Q R fap fas d1 d2 N2 D2

diary off
