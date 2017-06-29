% decimator_R2_lp_test.m
%
% Example of low-pass IIR decimator filter design using quasi-Newton
% optimisation with constraints on the coefficients.

test_common;

unlink("decimator_R2_lp_test.diary");
diary decimator_R2_lp_test.diary

global checkNaN fixNaN checkInf
checkNaN=true
fixNaN=true
checkInf=true
verbose=false
tol=1e-3
maxiter=2000

%% Filter specifications (frequencies are normalised to sample rate)
fap=0.10,ftp=0.125,tp=12,fas=0.175,R=2

strM=sprintf("%%s:fap=%g,ftp=%g,tp=%g,fas=%g,Wap=%%g,Wtp=%%g,Was=%%g",...
             fap,ftp,tp,fas);
strP=strcat(strM, sprintf(",dbap=%%g,rtp=%%g,dbas=%%g"));
strd=sprintf("decimator_R2_lp_%%s_%%s");

% Initial coefficients 
n=1024;
w=(0:(n-1))'*pi/n;
bw=round(n*fap/0.5);
tw=round(n*(fas-fap)/0.5);
Hd=[ones(bw,1);(((tw-1):-1:0)'/tw);zeros(n-bw-tw,1)].*exp(-j*tp.*w);
Wd=ones(n,1);
% Initial FIR filter
nN=12
nD=6
N0=remez(nN, 2*[0 fap fas 0.5], [1 1 0 0]);
% Optimise using barrier function
[N1,D1]=xInitTF(N0,[1;zeros(nD,1)],R,w,Hd,Wd);
[d1,U,V,M,Q]=tf2x(N1,D1)
printf("d1=[ ");printf("%f ",d1');printf("]'\n");
str1=sprintf("Initial R=2 decimator : U=%d,V=%d,M=%d,Q=%d,R=%d", U,V,M,Q,R);
showResponse(d1,U,V,M,Q,R,str1);
print(sprintf(strd,"initial","d1"),"-dpdflatex");
close
showZPplot(d1,U,V,M,Q,R,str1);
print(sprintf(strd,"initial","d1pz"),"-dpdflatex");
close

% MMSE passes
Wap=1,Wtp=0.1,Was=1
printf("\nFinding MMSE d2, Wap=%f, Wtp=%f, Was=%f\n", Wap, Wtp, Was);
[d2,E,lm,iter,liter,feasible]=...
    lp_mmse(d1,U,V,M,Q,R,fap,Wap,ftp,Wtp,tp,fas,Was, ...
            "exact",tol,maxiter,verbose)
if feasible == 0 
   error("R=2 decimator d2 infeasible");
endif
printf("d2=[ ");printf("%f ",d2');printf("]'\n");
strM2=sprintf(strM,"d2",Wap,Wtp,Was);
showResponse(d2,U,V,M,Q,R,strM2);
print(sprintf(strd,"mmse","d2"),"-dpdflatex");
close

Wap=1,Wtp=2,Was=1
printf("\nFinding MMSE d3, Wap=%f, Wtp=%f, Was=%f\n", Wap, Wtp, Was);
[d3,E,lm,iter,fiter,feasible] = ...
lp_mmse(d2,U,V,M,Q,R,fap,Wap,ftp,Wtp,tp,fas,Was, ...
       "exact",tol,maxiter,verbose)
if feasible == 0 
   error("R=2 decimator d3 infeasible");
endif
printf("d3=[ ");printf("%f ",d3');printf("]'\n");
strM3=sprintf(strM,"d3",Wap,Wtp,Was);
showResponse(d3,U,V,M,Q,R,strM3);
print(sprintf(strd,"mmse","d3"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-3,3,d3,U,V,M,Q,R,strM3);
print(sprintf(strd,"mmse","d3pass"),"-dpdflatex");
close
showZPplot(d3,U,V,M,Q,R,strM3);
print(sprintf(strd,"mmse","d3pz"),"-dpdflatex");
close

%% Switch to PCLS
Wap=1,Wtp=2,Was=1
dbap=1,rtp=0.125,dbas=20
printf("\nFinding PCLS d4, dbap=%f, rtp=%f, dbas=%f, Wap=%f, Wtp=%f, Was=%f\n", 
       dbap, rtp, dbas, Wap, Wtp, Was);
[d4,E,lm,iter,fiter,feasible] = ...
lp_slb(d3,U,V,M,Q,R,fap,Wap,dbap,ftp,Wtp,tp,rtp,fas,Was,dbas, ...
       "exact",tol,maxiter,verbose)
if feasible == 0 
   error("R=2 decimator d4 infeasible");
endif
printf("d4=[ ");printf("%f ",d4');printf("]'\n");

Wap=1,Wtp=2,Was=2
dbap=1,rtp=0.125,dbas=22
printf("\nFinding PCLS d5, dbap=%f, rtp=%f, dbas=%f, Wap=%f, Wtp=%f, Was=%f\n", 
       dbap, rtp, dbas, Wap, Wtp, Was);
[d5,E,lm,iter,fiter,feasible] = ...
lp_slb(d4,U,V,M,Q,R,fap,Wap,dbap,ftp,Wtp,tp,rtp,fas,Was,dbas, ...
       "exact",tol,maxiter,verbose)
if feasible == 0 
   error("R=2 decimator d5 infeasible");
endif
printf("d5=[ ");printf("%f ",d5');printf("]'\n");

Wap=1,Wtp=2,Was=5
dbap=0.7,rtp=0.08,dbas=24
printf("\nFinding PCLS d6, dbap=%f, rtp=%f, dbas=%f, Wap=%f, Wtp=%f, Was=%f\n", 
       dbap, rtp, dbas, Wap, Wtp, Was);
[d6,E,lm,iter,fiter,feasible] = ...
lp_slb(d5,U,V,M,Q,R,fap,Wap,dbap,ftp,Wtp,tp,rtp,fas,Was,dbas, ...
       "exact",tol,maxiter,verbose)
if feasible == 0 
   error("R=2 decimator d6 infeasible");
endif
printf("d6=[ ");printf("%f ",d6');printf("]'\n");
strP6=sprintf(strP,"d6",Wap,Wtp,Was,dbap,rtp,dbas);
showResponse(d6,U,V,M,Q,R,strP6);
print(sprintf(strd,"pcls","d6"),"-dpdflatex");
close
showResponsePassBands(0,max(fap,ftp),-3,3,d6,U,V,M,Q,R,strP6);
print(sprintf(strd,"pcls","d6pass"),"-dpdflatex");
close
showZPplot(d6,U,V,M,Q,R,strP6);
print(sprintf(strd,"pcls","d6pz"),"-dpdflatex");
close

%
% Save results
%
[N6,D6]=x2tf(d6,U,V,M,Q,R);
printf("\nd6 = [  ");printf("%f ",d6');printf("]';\n");
printf("\nN6 = [  ");printf("%f ",N6');printf("]';\n");
printf("\nD6 = [  ");printf("%f ",D6');printf("]';\n");

save decimator_R2_lp_test.mat U V M Q R fap ftp tp fas d1 d2 d3 d4 d5 d6

diary off
