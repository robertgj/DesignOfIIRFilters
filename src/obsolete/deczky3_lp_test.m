% deczky3_lp_test.m
%
% Example of low-pass IIR filter design using quasi-Newton optimisation
% with constraints on the coefficients. Deczkys Example 3 or Sullivan
% and Adams IPZS-1

test_common;

unlink("deczky3_lp_test.diary");
diary deczky3_lp_test.diary

global checkNaN fixNaN checkInf
checkNaN=true
fixNaN=true
checkInf=true
tol=1e-3
maxiter=2000
verbose=false

%% Filter specifications
U=0,V=0,Q=6,M=10,R=1,fap=0.15,ftp=0.25,tp=6,fas=0.30

strM=sprintf("%%s:fap=%g,ftp=%g,tp=%g,fas=%g,Wap=%%g,Wtp=%%g,Was=%%g",...
             fap,ftp,tp,fas);
strP=strcat(strM, sprintf(",dbap=%%g,rtp=%%g,dbas=%%g"));
strd=sprintf("deczky3_lp_%%s_%%s");

%% Initial coefficients 
z=[exp(j*2*pi*0.41),exp(j*2*pi*0.305),1.5*exp(j*2*pi*0.2), ...
   1.5*exp(j*2*pi*0.14),1.5*exp(j*2*pi*0.08)];
p=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12),0.5*exp(j*2*pi*0.05)];
K=0.0096312406;
x1=[K,abs(z),angle(z),abs(p),angle(p)]';
strM1=sprintf("Initial Deczky Ex. 3 : U=%d,V=%d,M=%d,Q=%d,R=%d", U,V,M,Q,R);
showResponse(x1,U,V,M,Q,R,strM1);
print(sprintf(strd,"mmse","x1"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strM1)
print(sprintf(strd,"mmse","x1pz"),"-dpdflatex");
close

Wap=1,Wtp=0,Was=1
printf("\nFinding MMSE x2, Wap=%f, Wtp=%f, Was=%f\n", Wap, Wtp, Was);
[x2,E,lm,iter,liter,feasible]=...
    lp_mmse(x1,U,V,M,Q,R,fap,Wap,ftp,Wtp,tp,fas,Was, ...
            "eye",tol,maxiter,verbose);
if feasible == 0 
   error("IPZS-1 x2 infeasible");
endif
printf("x2=[ ");printf("%f ",x2');printf("]'\n");
strM2=sprintf(strM,"x2",Wap,Wtp,Was);
showResponse(x2,U,V,M,Q,R,strM2);
print(sprintf(strd,"mmse","x2"),"-dpdflatex");
close

Wtp=0.01
printf("\nFinding MMSE x3, Wap=%f, Wtp=%f, Was=%f\n", Wap, Wtp, Was);
[x3,E,lm,iter,liter,feasible]=...
    lp_mmse(x2,U,V,M,Q,R,fap,Wap,ftp,Wtp,tp,fas,Was, ...
            "diagonal",tol,maxiter,verbose);
if feasible == 0 
   error("IPZS-1 x3 infeasible");
endif
printf("x3=[ ");printf("%f ",x3');printf("]'\n");
strM3=sprintf(strM,"x3",Wap,Wtp,Was);
showResponse(x3,U,V,M,Q,R,strM3);
print(sprintf(strd,"mmse","x3"),"-dpdflatex");
close

Wtp=0.1,Was=10
printf("\nFinding MMSE x4, Wap=%f, Wtp=%f, Was=%f\n", Wap, Wtp, Was);
[x4,E,lm,iter,liter,feasible]=...
    lp_mmse(x3,U,V,M,Q,R,fap,Wap,ftp,Wtp,tp,fas,Was, ...
            "diagonal",tol,maxiter,verbose);
if feasible == 0 
   error("IPZS-1 x4 infeasible");
endif
printf("x4=[ ");printf("%f ",x4');printf("]'\n");
strM4=sprintf(strM,"x4",Wap,Wtp,Was);
showResponse(x4,U,V,M,Q,R,strM4);
print(sprintf(strd,"mmse","x4"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-3,3,x4,U,V,M,Q,R,strM4);
print(sprintf(strd,"mmse","x4pass"),"-dpdflatex");
close
showZPplot(x4,U,V,M,Q,R,strM4)
print(sprintf(strd,"mmse","x4pz"),"-dpdflatex");
close

Wap=1,Wtp=1,Was=10
printf("\nFinding MMSE x5, Wap=%f, Wtp=%f, Was=%f\n", Wap, Wtp, Was);
[x5,E,lm,iter,fiter,feasible] = ...
    lp_mmse(x4,U,V,M,Q,R,fap,Wap,ftp,Wtp,tp,fas,Was, ...
           "diagonal",tol,maxiter,verbose);
if feasible == 0
   error("x5 infeasible\n")
endif 
printf("x5=[ ");printf("%f ",x5');printf("]'\n");
strM5=sprintf(strM,"x5",Wap,Wtp,Was);
showResponse(x5,U,V,M,Q,R,strM5);
print(sprintf(strd,"mmse","x5"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-3,3,x5,U,V,M,Q,R,strM5);
print(sprintf(strd,"mmse","x5pass"),"-dpdflatex");
close
showZPplot(x5,U,V,M,Q,R,strM5)
print(sprintf(strd,"mmse","x5pz"),"-dpdflatex");
close


% Switch to PCLS
% U=0,V=0,M=10,Q=6,R=1
% fap=0.15,ftp=0.25,tp=6,fas=0.30
Wap=1,Wtp=1,Was=10
dbap=1,rtp=0.03,dbas=30
printf("\nFinding PCLS x6, dbap=%f, rtp=%f, dbas=%f, Wap=%f, Wtp=%f, Was=%f\n", 
       dbap, rtp, dbas, Wap, Wtp, Was);
[x6,E,lm,iter,fiter,feasible] = ...
    lp_slb(x5,U,V,M,Q,R,fap,Wap,dbap,ftp,Wtp,tp,rtp,fas,Was,dbas, ...
           "diagonal",tol,maxiter,verbose);
if feasible == 0
   error("x6 infeasible\n")
endif 
printf("x6=[ ");printf("%f ",x6');printf("]'\n");
strP6=sprintf(strP,"x6",Wap,Wtp,Was,dbap,rtp,dbas);
showResponse(x6,U,V,M,Q,R,strP6);
print(sprintf(strd,"pcls","x6"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-3,3,x6,U,V,M,Q,R,strP6);
print(sprintf(strd,"pcls","x6pass"),"-dpdflatex");
close
showZPplot(x6,U,V,M,Q,R,strP6)
print(sprintf(strd,"pcls","x6pz"),"-dpdflatex");
close

Wap=1,Wtp=1,Was=10
dbap=1,rtp=0.025,dbas=40
printf("\nFinding PCLS x7, dbap=%f, rtp=%f, dbas=%f, Wap=%f, Wtp=%f, Was=%f\n", 
       dbap, rtp, dbas, Wap, Wtp, Was);
[x7,E,lm,iter,fiter,feasible] = ...
    lp_slb(x6,U,V,M,Q,R,fap,Wap,dbap,ftp,Wtp,tp,rtp,fas,Was,dbas, ...
           "exact",tol,maxiter,verbose);
if feasible == 0
   error("x7 infeasible\n")
endif 
printf("x7=[ ");printf("%f ",x7');printf("]'\n");
strP7=sprintf(strP,"x7",Wap,Wtp,Was,dbap,rtp,dbas);
showResponse(x7,U,V,M,Q,R,strP7);
print(sprintf(strd,"pcls","x7"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-3,3,x7,U,V,M,Q,R,strP7);
print(sprintf(strd,"pcls","x7pass"),"-dpdflatex");
close
showZPplot(x7,U,V,M,Q,R,strP7)
print(sprintf(strd,"pcls","x7pz"),"-dpdflatex");
close

[N7,D7]=x2tf(x7,U,V,M,Q,R);
printf("\nx7 = [  ");printf("%f ",x7');printf("]';\n");
printf("\nN7 = [  ");printf("%f ",N7');printf("]';\n");
printf("\nD7 = [  ");printf("%f ",D7');printf("]';\n");

% Remove a pair of conjugate poles close to z=0 from x6, Q=4,
% and changing two complex zero pairs near z=-1 and z=-0.5 to
% single real zeros
U=1,V=0,M=6,Q=4
Wap=1,Wtp=1,Was=10
x8 =[  0.0077902 ...                           % K
      -1.1048469 ...                           % U
       0.9763152  0.9443771  2.3371315 ...     % M
       1.9756912  2.3507382 -0.4056362 ...
       0.6203444  0.4673048 ...                % Q
       1.7779209  1.1550278 ]';
[x9,E,lm,iter,fiter,feasible] = ...
    lp_mmse(x8,U,V,M,Q,R,fap,Wap,ftp,Wtp,tp,fas,Was, ...
           "exact",tol,maxiter,verbose);
if feasible == 0
   error("x9 infeasible\n")
endif 
strM9=sprintf(strM,"x9",Wap,Wtp,Was);
showResponse(x9,U,V,M,Q,R,strM9);
print(sprintf(strd,"mmse","x9"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-3,3,x9,U,V,M,Q,R,strM9);
print(sprintf(strd,"mmse","x9pass"),"-dpdflatex");
close
showZPplot(x9,U,V,M,Q,R,strM9)
print(sprintf(strd,"mmse","x9pz"),"-dpdflatex");
close

% Switch to PCLS
% U=2,V=0,M=10,Q=4,R=1
% fap=0.15,ftp=0.25,tp=6,fas=0.30
Wap=1,Wtp=1,Was=10
dbap=0.65,rtp=0.087375,dbas=30
[x10,E,lm,iter,fiter,feasible] = ...
    lp_slb(x9,U,V,M,Q,R,fap,Wap,dbap,ftp,Wtp,tp,rtp,fas,Was,dbas, ...
           "exact",tol,maxiter,verbose);
if feasible == 0
   error("x10 infeasible\n")
endif 
strP10=sprintf(strP,"x10",Wap,Wtp,Was,dbap,rtp,dbas);
showResponse(x10,U,V,M,Q,R,strP10);
print(sprintf(strd,"pcls","x10"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-3,3,x10,U,V,M,Q,R,strP10);
print(sprintf(strd,"pcls","x10pass"),"-dpdflatex");
close
showZPplot(x10,U,V,M,Q,R,strP10)
print(sprintf(strd,"pcls","x10pz"),"-dpdflatex");
close

%
% Save results
%
save deczky3_lp_test.mat U V M Q R ...
     fap ftp tp fas Wap Wtp Was dbap rtp dbas ...
     x1 x2 x3 x4 x5 x6 x7 x8 x9 x10

diary off
