% iir_sqp_slb_bandpass_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="iir_sqp_slb_bandpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=20000
ftol=1e-3
ctol=1e-4
verbose=false

% Bandpass filter specification (frequencies are normalised to sample rate)
fapl=0.1,fapu=0.2,dBap=0.7,Wap=1
fasl=0.05,fasu=0.25,dBas=34,Wasl=2,Wasu=2
ftpl=0.1,ftpu=0.2,tp=16,tpr=0.08,Wtp=0.5
    
% Strings
strI=sprintf("x0:fapl=%g,fapu=%g,tp=%g,fasl=%g,fasu=%g,Wasl=%g,Wasu=%g", ...
             fapl,fapu,tp,fasl,fasu,Wasl,Wasu);
strM=sprintf("x1:fapl=%g,fapu=%g,tp=%g,fasl=%g,fasu=%g,Wasl=%g,Wasu=%g", ...
             fapl,fapu,tp,fasl,fasu,Wasl,Wasu);
strP=sprintf("d1:fapl=%g,fapu=%g,dBap=%g,tp=%g,tpr=%g,fasl=%g,fasu=%g,\
dBas=%g,Wasl=%g,Wasu=%g",fapl,fapu,dBap,tp,tpr,fasl,fasu,dBas,Wasl,Wasu);

% Frequency points
n=500;

% Initial filter (found by trial-and-error)
U=2,V=0,M=18,Q=10,R=2
x0=[ 0.00005, ...
     1, -1, ...
     0.9*ones(1,6), [1 1 1], (11:16)*pi/20, (7:9)*pi/10, ...
     0.81*ones(1,5), (4:8)*pi/10 ]';

% Plot initial filter
showZPplot(x0,U,V,M,Q,R,strI);
print(strcat(strf,"_initial_x0pz"),"-dpdflatex");
close
showResponse(x0,U,V,M,Q,R,strI);
print(strcat(strf,"_initial_x0"),"-dpdflatex");
close
strMi=sprintf(strM,"x0");
showResponsePassBands(0,0.5,-3,3,x0,U,V,M,Q,R,strI);
print(strcat(strf,"_initial_x0pass"),"-dpdflatex");
close

% Coefficient constraints
dmax=0.05;
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
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
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

% MMSE pass
[x1,Ex1,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,ftol,ctol,verbose)
if feasible == 0 
  error("R=2 bandpass x1 (MMSE) infeasible");
endif

printf("x1=[ ");printf("%14.10f ",x1');printf("]'\n");
showResponse(x1,U,V,M,Q,R,strM);
print(strcat(strf,"_mmse_x1"),"-dpdflatex");
close
showResponsePassBands(fapl,fapu,-0.8,0.4,x1,U,V,M,Q,R,strM);
print(strcat(strf,"_mmse_x1pass"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strM)
print(strcat(strf,"_mmse_x1pz"),"-dpdflatex");
close

% MMSE result amplitude and delay at constraints
vS=iir_slb_update_constraints(x1,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                              ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt,...
                              wp,Pdu,Pdl,Wp,ctol);
waS=unique([wa(vS.al);wa(vS.au);2*pi*[0;0.5;fasl;fapl;fapu;fasu]]);
AS=iirA(waS,x1,U,V,M,Q,R);
printf("x1:faS=[ ");printf("%f ",waS'*0.5/pi);printf(" ] (fs==1)\n");
printf("x1:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");
wtS=unique([wt(vS.tl);wt(vS.tu);2*pi*[ftpl;ftpu]]);
TS=iirT(wtS,x1,U,V,M,Q,R);
printf("x1:ftS=[ ");printf("%f ",wtS'*0.5/pi);printf(" ] (fs==1)\n");
printf("x1:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");

% PCLS pass
printf("\nPCLS pass 1:\n");
start_time=time();
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,ftol,ctol,verbose)
if feasible == 0 
  error("R=2 bandpass d1 (PCLS) infeasible");
endif

printf("R=2 bandpass d1 (pcls) feasible after %d seconds!\n",time()-start_time);
showZPplot(d1,U,V,M,Q,R,strP);
print(strcat(strf,"_pcls_d1pz"),"-dpdflatex");
close
showResponse(d1,U,V,M,Q,R,strP);
print(strcat(strf,"_pcls_d1"),"-dpdflatex");
close
showResponsePassBands(fapl,fapu,-0.8,0.4,d1,U,V,M,Q,R,strP);
print(strcat(strf,"_pcls_d1pass"),"-dpdflatex");
close

% Amplitude and delay at constraints
vS=iir_slb_update_constraints(d1,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                              ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt,...
                              wp,Pdu,Pdl,Wp,ctol);
A=iirA(wa,d1,U,V,M,Q,R);
nA=local_max(A);
waS=unique([wa(vS.al);wa(vS.au);wa(nA);2*pi*[0;0.5;fasl;fapl;fapu;fasu]]);
AS=iirA(waS,d1,U,V,M,Q,R);
printf("d1:faS=[ ");printf("%f ",waS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");
T=iirT(wt,d1,U,V,M,Q,R);
nT=local_max(T);
wtS=unique([wt(vS.tl);wt(vS.tu);wt(nT);2*pi*[ftpl;ftpu]]);
TS=iirT(wtS,d1,U,V,M,Q,R);
printf("d1:ftS=[ ");printf("%f ",wtS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");

%
% Compare with cl2bp
%
wl=fapl*2*pi*0.8;
wu=fapu*2*pi*1.1;
up=10.^([-dBas, 0, -dBas]/20);
lo=[-1,1,-1].*10.^([-dBas, -dBap, -dBas]/20);
N=1+U+V+M+Q;
Ccl=floor(N/2)
ncl=2048;
bcl = cl2bp(Ccl,wl,wu,up,lo,512);
length(bcl)
% Ccl amplitude at constraints
faC=[0 fasl fapl fapu fasu 0.5];
AC=freqz(bcl,1,faC,1);
printf("faC=[ ");printf("%f ",faC');printf(" ] (fs==1)\n");
printf("AC=[ ");printf("%f ",20*log10(abs(AC')));printf(" ] (dB)\n");

%
% Compare with remez
%
% (frequencies are normalised to sample rate)
brz=remez(N-1,2*[0 fasl fapl fapu fasu 0.5],[0 0 1 1 0 0], ...
          [Wasl Wap Wasu],'bandpass');
% brz amplitude at constraints
faR=[0 fasl fapl fapu fasu 0.5];
AR=freqz(brz,1,faR,1);
printf("faR=[ ");printf("%f ",faR');printf(" ] (fs==1)\n");
printf("AR=[ ");printf("%f ",20*log10(abs(AR')));printf(" ] (dB)\n");

%
% Overall comparison
%
[N1,D1]=x2tf(d1,U,V,M,Q,R);
[hpcls,w]=freqz(N1,D1,1024);
hcl=freqz(bcl,1,w);
hrz=freqz(brz,1,w);
plot(w*0.5/pi,20*log10(abs(hpcls)),'linestyle','-',
     w*0.5/pi,20*log10(abs(hcl)),'linestyle','-.', ...
     w*0.5/pi,20*log10(abs(hrz)),'linestyle','--')
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 5]);
title("Comparison of IIR PCLS and FIR cl2bp() and remez() bandpass \
filter amplitude responses");
legend("IIR PCLS","FIR cl2bp","FIR remez");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_compare_magnitude"),"-dpdflatex");
close

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ftol=%g %% Tolerance on relative coefficient update size\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"fasl=%g %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"dBap=%g %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"dBas=%g %% Stop band amplitude peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%g %% Lower stop band weight\n",Wasl);
fprintf(fid,"Wap=%g %% Pass band weight\n",Wap);
fprintf(fid,"Wasu=%g %% Upper stop band weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band group delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group delay response upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fclose(fid);

% Save results
print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

eval(sprintf("save %s.mat U V M Q R ftol ctol fapl fapu dBap Wap \
fasl fasu dBas Wasl Wasu ftpl ftpu tp tpr Wtp x0 x1 d1",strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
