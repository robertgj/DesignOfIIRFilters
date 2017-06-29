% parhi_ex12_9_2_test.m

test_common;

unlink("parhi_ex12_9_2_test.diary");
diary parhi_ex12_9_2_test.diary

format compact

% Parhi finds:
R=4;fap=0.15;fas=0.18;
dRp4 =[1 0 0 0 1.7940 0 0 0 1.4404 0 0 0 0.4830 0 0 0 0.0582];
dp4 =[1 1.7940 1.4404 0.4830 0.0582];
nip4=[0.1365 0.0232 0.2879 0.0557 0.3954 0.0443 0.4058 0.0472 0.3867 ...
      0.0532 0.2952 0.0229 0.1717 0.0106 0.0528 0.0056 0.0329];
nfp4=[0.1436 0.4896 0.6923 0.4896 0.1436];
np4=conv(nip4,nfp4);
[xp4,U,V,M,Q]=tf2x(np4,dp4);
strParhi=sprintf("Listed Parhi ex. 12.9.2 : fap=%g,fas=%g,",fap,fas);
strParhi=strcat(strParhi,sprintf("U=%d,V=%d,M=%d,Q=%d,R=%d",U,V,M,Q,R));
showZPplot(xp4,U,V,M,Q,R,strParhi);
print("parhi_ex12_9_2_listed_pz","-dpdflatex");
close
showResponse(xp4,U,V,M,Q,R,strParhi);
print("parhi_ex12_9_2_listed","-dpdflatex");
close
showResponsePassBands(0,fap,-3,3,xp4,U,V,M,Q,R,strParhi);
print("parhi_ex12_9_2_listed_pass","-dpdflatex");
close
% After removing redundant poles and zeros
R=2;
ddp2=[1 0.77938 1.2007 0.31038 0.24125];
nnp2=0.019709*[1.0000 3.5791 8.2867 14.6108 21.2808 26.6001 ...
     28.4669 26.6022 21.2843 14.6144 8.2891 3.5799 1.0001];
[xxp2,U,V,M,Q]=tf2x(nnp2,ddp2);
strParhi=sprintf("Listed Parhi ex. 12.9.2 : ");
strParhi=strcat(strParhi,sprintf("U=%d,V=%d,M=%d,Q=%d,R=%d",U,V,M,Q,R));
showZPplot(xxp2,U,V,M,Q,R,strParhi);
print("parhi_ex12_9_2_listed_pz_no_redundant","-dpdflatex");
close

%
clear all
verbose=false
tol=1e-3
maxiter=500

% Filter specifications (frequencies are normalised to sample rate)
U=0;V=0;M=14;Q=2;R=4;
fap=0.15;fas=0.18;
Wap=1;Was=1;

% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q);

% Amplitude constraints
n=1000;
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

% Initialise strings
strM=sprintf("%%s:fap=%g,fas=%g,Wap=%%g,Was=%%g",fap,fas);
strd=sprintf("parhi_ex12_9_2_%%s_%%s");

% Initial filter
wap=pi*fap/0.5;
was=pi*fas/0.5;
Mon2=M/2;
Qon2=Q/2;
Mphi=(was+((pi-was)*(0:(Mon2-1))/Mon2))';
Qphi=R*(wap*(1:Qon2)/Qon2)';
d0=[0.03;-1*ones(U,1);zeros(V,1);ones(Mon2,1);Mphi;0.6*ones(Qon2,1);Qphi];

% Barrier function optimisation
d1=xInitHd(d0,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,tol);
strI=sprintf("Initial Parhi ex. 12.9.2 : fap=%g,fas=%g,",fap,fas);
strI=strcat(strI,sprintf("U=%d,V=%d,M=%d,Q=%d,R=%d", U,V,M,Q,R));
close
showResponse(d1,U,V,M,Q,R,strI);
print(sprintf(strd,"initial","d1"),"-dpdflatex");
close
showResponsePassBands(0,fap,-3,3,d1,U,V,M,Q,R,strI);
print(sprintf(strd,"initial","d1pass"),"-dpdflatex");
close
showZPplot(d1,U,V,M,Q,R,strI);
print(sprintf(strd,"initial","d1pz"),"-dpdflatex");
close

% SOCP MMSE pass
[d2,E,socp_iter,func_iter,feasible]= ...
  iir_socp_mmse([],d1,xu,xl,inf,U,V,M,Q,R, ...
                wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
                wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                maxiter,tol,verbose)
if feasible == 0 
   error("Parhi ex. 12.9.2 d2 infeasible");
endif
strM2=sprintf(strM,"d2",Wap,Was);
showZPplot(d2,U,V,M,Q,R,strM2);
print(sprintf(strd,"mmse","d2pz"),"-dpdflatex");
close
showResponse(d2,U,V,M,Q,R,strM2);
print(sprintf(strd,"mmse","d2"),"-dpdflatex");
close
showResponsePassBands(0,fap,-3,3,d2,U,V,M,Q,R,strM2);
print(sprintf(strd,"mmse","d2pass"),"-dpdflatex");
close

print_pole_zero(d2,U,V,M,Q,R,"d2");
print_pole_zero(d2,U,V,M,Q,R,"d2","parhi_ex12_9_2_test_d2_coef.m");
[N2,D2]=x2tf(d2,U,V,M,Q,R);
print_polynomial(N2,"N2");
print_polynomial(N2,"N2","parhi_ex12_9_2_test_N2_coef.m");
print_polynomial(D2,"D2");
print_polynomial(D2,"D2","parhi_ex12_9_2_test_D2_coef.m");

% Save
save parhi_ex12_9_2_test.mat U V M Q R fap fas d1 d2 N2 D2

diary off
