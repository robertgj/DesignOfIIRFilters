% iir_socp_slb_bandpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("iir_socp_slb_bandpass_test.diary");
unlink("iir_socp_slb_bandpass_test.diary.tmp");
diary iir_socp_slb_bandpass_test.diary.tmp

tic;

format compact;

verbose=false
tol=1e-4
ctol=tol
maxiter=5000

% Bandpass filter specification
% (frequencies are normalised to sample rate)
fapl=0.1,fapu=0.2,dBap=1,Wap=1,Watl=0,Watu=0
fasl=0.05,fasu=0.25,dBas=28,Wasl=2,Wasu=2
ftpl=0.09,ftpu=0.21,tp=16,tpr=0.04,Wtp=0.25

strM=sprintf("%%s:fapl=%g,fapu=%g,dBap=%g,Wap=%%g,fasl=%g,fasu=%g,\
dBas=%g,Wasl=%%g,Wasu=%%g,tp=%d,Wtp=%%g",fapl,fapu,dBap,fasl,fasu,dBas,tp);
strd=sprintf("iir_socp_slb_bandpass_test_%%s_%%s");

% Frequency points
n=500;

% Initial filter (found by tarczynski_bandpass_test.m)
U=2,V=0,M=18,Q=10,R=2
x0 = [  0.0081263205, ...
        2.3263124008,   0.9360872486, ...
        1.2150786180,   0.9557615656,   0.9523385574,   1.0329656389, ... 
        0.9276882096,   1.0566126997,   0.8927884062,   1.0463348944, ... 
        0.8081643539, ...
        0.9451135607,   0.4751778541,   1.4493040642,   1.8697650683, ... 
        1.7978306798,   2.5999774875,   2.6210164650,   2.2280426350, ... 
        2.1501293955, ...
        0.9294465959,   0.7988885665,   0.9212368006,   0.7966776051, ... 
        0.7622282256, ...
        1.1513209786,   1.4420802994,   2.6203193461,   2.3114594136, ... 
        1.8760502775 ]';
% Plot initial filter
strM0=sprintf(strM,"x0",Wap,Wasl,Wasu);
showZPplot(x0,U,V,M,Q,R,strM0);
print(sprintf(strd,"initial","x0pz"),"-dpdflatex");
close
showResponse(x0,U,V,M,Q,R,strM0);
print(sprintf(strd,"initial","x0"),"-dpdflatex");
close
strMi=sprintf(strM,"x0",Wap,Wasl,Wasu);
showResponsePassBands(ftpl,ftpu,-3,3,x0,U,V,M,Q,R,strM0);
print(sprintf(strd,"initial","x0pass"),"-dpdflatex");
close

% Coefficient constraints
dmax=inf;
[xl,xu]=xConstraints(U,V,M,Q);

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(n-napu,1)];
Adu=[(10^(-dBas/20))*ones(nasl,1); ...
     ones(nasu-nasl-1,1); ...
     (10^(-dBas/20))*ones(n-nasu+1,1)];
Adl=[zeros(napl-1,1); ...
     (10^(-dBap/20))*ones(napu-napl+1,1); ...
     zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];
% Sanity check
nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];
printf("nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];\n");
printf("nchk=[ ");printf("%d ",nchk);printf("];\n");
printf("wa(nchk)*0.5/pi=[ ");printf("%6.4g ",wa(nchk)'*0.5/pi);printf("];\n");
printf("Ad(nchk)=[ ");printf("%6.4g ",Ad(nchk)');printf("];\n");
printf("Adu(nchk)=[ ");printf("%6.4g ",Adu(nchk)');printf("];\n");
printf("Adl(nchk)=[ ");printf("%6.4g ",Adl(nchk)');printf("];\n");
printf("Wa(nchk)=[ ");printf("%6.4g ",Wa(nchk)');printf("];\n");

% Stop-band amplitude response constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay constraints
ntpl=floor(n*ftpl/0.5);
ntpu=ceil(n*ftpu/0.5);
wt=(ntpl:ntpu)'*pi/n;
ntp=length(wt);
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

% PCLS pass 
printf("\nPCLS pass:\n");
start_time=time();
[d1,E,slb_iter,socp_iter,func_iter,feasible] = ...
  iir_slb(@iir_socp_mmse,x0,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,tol,ctol,verbose)
if feasible == 0 
  error("R=2 bandpass d1 (pcls) infeasible");
endif
printf("R=2 bandpass d1 (pcls) feasible after %d seconds!\n",time()-start_time);
strP1=sprintf(strM,"d1",Wap,Wasl,Wasu,Wtp);
showZPplot(d1,U,V,M,Q,R,strP1);
print(sprintf(strd,"pcls","d1pz"),"-dpdflatex");
showResponse(d1,U,V,M,Q,R,strP1);
print(sprintf(strd,"pcls","d1"),"-dpdflatex");
showResponsePassBands(ftpl,ftpu,-2*dBap,dBap,d1,U,V,M,Q,R,strP1);
print(sprintf(strd,"pcls","d1pass"),"-dpdflatex");
close

% Amplitude and delay at constraints
vS=iir_slb_update_constraints(d1,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                              ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt,...
                              wp,Pdu,Pdl,Wp,tol);
waS=unique([wa(vS.al);wa(vS.au);2*pi*[0;0.5;fasl;fapl;fapu;fasu]]);
AS=iirA(waS,d1,U,V,M,Q,R);
printf("d1:faS=[ ");printf("%f ",waS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");
wtS=unique([wt(vS.tl);wt(vS.tu);2*pi*[ftpl;ftpu]]);
TS=iirT(wtS,d1,U,V,M,Q,R);
printf("d1:ftS=[ ");printf("%f ",wtS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");

% Save specification
fid=fopen("iir_socp_slb_bandpass_test.spec","wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on relative coefficient update size\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"fasl=%g %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"dBap=%d %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"dBas=%d %% Stop band amplitude peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%d %% Lower stop band weight\n",Wasl);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"Wasu=%d %% Upper stop band weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band group delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group delay response upper edge\n",ftpu);
fprintf(fid,"tp=%d %% Nominal filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band group delay weight\n",Wtp);
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fclose(fid);

% Save results
[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1","iir_socp_slb_bandpass_test_d1_coef.m");
print_polynomial(N1,"N1");
print_polynomial(N1,"N1","iir_socp_slb_bandpass_test_N1_coef.m");
print_polynomial(D1,"D1");
print_polynomial(D1,"D1","iir_socp_slb_bandpass_test_D1_coef.m");

% Done 
save iir_socp_slb_bandpass_test.mat U V M Q R n tol ctol fapl fapu dBap Wap ...
     fasl fasu dBas Wasl Wasu ftpl ftpu tp tpr Wtp x0 d1

toc;
diary off
movefile iir_socp_slb_bandpass_test.diary.tmp iir_socp_slb_bandpass_test.diary;
