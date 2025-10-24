% iir_sqp_slb_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="iir_sqp_slb_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

maxiter=2000;
ftol=1e-3;
ctol=ftol;
verbose=false;
printf("maxiter=%d,ftol=%g,ctol=%g,verbose=%d\n",maxiter,ftol,ctol,verbose);

% Deczky3 Lowpass filter specification

% Filter specifications
U=0;V=0;Q=6;M=10;R=1;
fap=0.15;dBap=1;Wap=1;
fas=0.3;dBas=40;Was=1;
ftp=0.25;tp=6;tpr=0.025;Wtp=0.1;

% Initial coefficients
z=[exp(j*2*pi*0.41),exp(j*2*pi*0.305),1.5*exp(j*2*pi*0.2), ...
   1.5*exp(j*2*pi*0.14),1.5*exp(j*2*pi*0.08)];
p=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12),0.5*exp(j*2*pi*0.05)];
K=0.0096312406;
x0=[K,abs(z),angle(z),abs(p),angle(p)]';

% Frequency vectors
n=1000;
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;

% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q);
dmax=0.05;

% Amplitude constraints
Ad=[ones(nap,1); zeros(n-nap,1)];
Adu=[ones(nas-1,1); (10^(-dBas/20))*ones(n-nas+1,1)];
Adl=[(10^(-dBap/20))*ones(nap,1);zeros(n-nap,1)+ftol/10];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Stop-band amplitude response constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay constraints
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase response constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Check
print_polynomial(wa([nap-1,nap,nap+1,nas-1,nas,nas+1])*0.5/pi,"f");
print_polynomial(Wa([nap-1,nap,nap+1,nas-1,nas,nas+1]),"Wa");
print_polynomial(wt(ntp)*0.5/pi,"ft(ntp)");

% Empty frequency constraint structure
vS=iir_slb_set_empty_constraints();

% Initialise strings
strM=sprintf("%%s:fap=%g,dBap=%g,Wap=%g,",fap,dBap,Wap);
strM=strcat(strM, sprintf("fas=%g,dBas=%g,Was=%g,",fas,dBas,Was));
strM=strcat(strM, sprintf("tp=%g,rtp=%g,Wtp=%g",tp,tpr,Wtp));
printf("%s\n",sprintf(strM,"Test parameters"));
strd=sprintf("%s_%%s",strf);

% First iir_sqp_mmse pass
printf("\nFirst MMSE pass\n");
[x2,E,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,ftol,ctol,verbose);
if feasible == 0 
  error("iir_sqp_slb_test, x2(mmse) infeasible");
endif
print_polynomial(x2,"x2");
printf("E=%g,sqp_iter=%d,func_iter=%d,feasible=%d\n", ...
       E,sqp_iter,func_iter,feasible);
strM2=sprintf(strM,"x2(mmse)");
showZPplot(x2,U,V,M,Q,R,strM2);
zticks([]);
print(sprintf(strd,"x2pz"),"-dpdflatex");
close
showResponse(x2,U,V,M,Q,R,strM2);
zticks([]);
print(sprintf(strd,"x2"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-2*dBap,dBap,x2,U,V,M,Q,R,strM2);
zticks([]);
print(sprintf(strd,"x2pass"),"-dpdflatex");
close

% Second iir_sqp_mmse pass
printf("\nSecond MMSE pass\n");
vS=iir_slb_update_constraints(x2,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                              ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt, ...
                              wp,Pdu,Pdl,Wp,ctol);
printf("S frequency constraints before:\n");
for [v,k]=vS
  print_polynomial(v,k,"%d");
endfor
Ax2=iirA(wa,x2,U,V,M,Q,R);
Sx2=iirA(ws,x2,U,V,M,Q,R);
Tx2=iirT(wt,x2,U,V,M,Q,R);
Px2=iirP(wp,x2,U,V,M,Q,R);
iir_slb_show_constraints(vS,wa,Ax2,ws,Sx2,wt,Tx2,wp,Px2);

[x3,E,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse(vS,x2,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,ftol,ctol,verbose);
if feasible == 0 
  error("iir_sqp_slb_test, x3(mmse) infeasible");
endif
print_polynomial(x3,"x3");
printf("E=%g,sqp_iter=%d,func_iter=%d,feasible=%d\n", ...
       E,sqp_iter,func_iter,feasible);
vS=iir_slb_update_constraints(x3,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                              ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt, ...
                              wp,Pdu,Pdl,Wp,ctol);
printf("S frequency constraints after:\n");
for [v,k]=vS
  print_polynomial(v,k,"%d");
endfor
Ax3=iirA(wa,x3,U,V,M,Q,R);
Sx3=iirA(ws,x3,U,V,M,Q,R);
Tx3=iirT(wt,x3,U,V,M,Q,R);
Px3=iirP(wp,x3,U,V,M,Q,R);
iir_slb_show_constraints(vS,wa,Ax3,ws,Sx3,wt,Tx3,wp,Px3);

strd=sprintf("iir_sqp_slb_test_%%s");
strM3=sprintf(strM,"x3(mmse)");
showZPplot(x3,U,V,M,Q,R,strM3);
zticks([]);
print(sprintf(strd,"x3pz"),"-dpdflatex");
close
showResponse(x3,U,V,M,Q,R,strM3);
zticks([]);
print(sprintf(strd,"x3"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-2*dBap,dBap,x3,U,V,M,Q,R,strM3);
zticks([]);
print(sprintf(strd,"x3pass"),"-dpdflatex");
close

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
