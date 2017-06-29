% iir_sqp_slb_bandpass_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("iir_sqp_slb_bandpass_test.diary");
unlink("iir_sqp_slb_bandpass_test.diary.tmp");
diary iir_sqp_slb_bandpass_test.diary.tmp

tic;

format compact;

verbose=false
tol=5e-4
maxiter=5000

% Bandpass filter specification
% (frequencies are normalised to sample rate)
fapl=0.1,fapu=0.2,dBap=1,Wap=1
fasl=0.05,fasu=0.25,dBas=36,Wasl=2,Wasu=4
ftpl=0.09,ftpu=0.21,tp=16,tpr=0.08,Wtp=1

strM=sprintf("%%s:fapl=%g,fapu=%g,dBap=%g,Wap=%%g,fasl=%g,\
fasu=%g,dBas=%g,Wasl=%%g,Wasu=%%g",fapl,fapu,dBap,fasl,fasu,dBas);
strd=sprintf("iir_sqp_slb_bandpass_test_%%s_%%s");

% Frequency points
n=500;

% Initial filter (found by trial-and-error)
U=2,V=0,M=18,Q=10,R=2
x0=[ 0.00005, ...
     1, -1, ...
     0.9*ones(1,6), [1 1 1], (11:16)*pi/20, (7:9)*pi/10, ...
     0.81*ones(1,5), (4:8)*pi/10 ]';
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

% Try Octave sqp MMSE solver
%{
[x1octave,Ex1octave,sqp_iter,func_iter,feasible] = ...
  iir_sqp_octave(x0,U,V,M,Q,R,wa,Ad,Wa,wt,Td,Wt,maxiter,tol,verbose)
if feasible == 0 
  error("bandpass_iir_sqp_test, x1octave infeasible");
endif
printf("x1octave=[ ");printf("%f ",x1octave');printf("]'\n");
strO1=sprintf(strM,"x1",Wap,Wasl,Wasu);
showZPplot(x1octave,U,V,M,Q,R,strO1);
print(sprintf(strd,"octave","x1pz"),"-dpdflatex");
close
showResponse(x1octave,U,V,M,Q,R,strO1);
print(sprintf(strd,"octave","x1"),"-dpdflatex");
close
showResponsePassBands(ftpl,ftpu,x1octave,U,V,M,Q,R,strO1);
print(sprintf(strd,"octave","x1pass"),"-dpdflatex");
close
%}

% MMSE pass
[x1,Ex1,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,tol,verbose)
if feasible == 0 
  error("R=2 bandpass x1 (mmse) infeasible");
endif
printf("x1=[ ");printf("%14.10f ",x1');printf("]'\n");
strM1=sprintf(strM,"x1",Wap,Wasl,Wasu);
showResponse(x1,U,V,M,Q,R,strM1);
print(sprintf(strd,"mmse","x1"),"-dpdflatex");
close
showResponsePassBands(ftpl,ftpu,-2*dBap,dBap,x1,U,V,M,Q,R,strM1);
print(sprintf(strd,"mmse","x1pass"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strM1)
print(sprintf(strd,"mmse","x1pz"),"-dpdflatex");
close

% MMSE result amplitude and delay at constraints
vS=iir_slb_update_constraints(x1,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                              ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt,...
                              wp,Pdu,Pdl,Wp,tol);
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
          maxiter,tol,verbose)
if feasible == 0 
  error("R=2 bandpass d1 (pcls) infeasible");
endif
printf("R=2 bandpass d1 (pcls) feasible after %d seconds!\n",time()-start_time);
strP1=sprintf(strM,"d1",Wap,Wasl,Wasu);
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
[xcl,Ucl,Vcl,Mcl,Qcl]=tf2x(bcl,1,tol);
Rcl=1;
strMcl=sprintf("xcl:length=%d,fapl=%g,fapu=%g,stop band ripple=-30dB", ...
                length(bcl),fapl,fapu);
showResponse(xcl,Ucl,Vcl,Mcl,Qcl,Rcl,strMcl);
print(sprintf(strd,"cl2bp","xcl"),"-dpdflatex");
close
showZPplot(xcl,Ucl,Vcl,Mcl,Qcl,Rcl,strMcl);
print(sprintf(strd,"cl2bp","xclpz"),"-dpdflatex");
close

% Ccl amplitude and delay at constraints
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
[xrz,Urz,Vrz,Mrz,Qrz]=tf2x(brz,1,tol);
Rrz=1;
strMrz=sprintf("xrz:length=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g", ...
               length(brz),fasl,fapl,fapu,fasu);
showResponse(xrz,Urz,Vrz,Mrz,Qrz,Rrz,strMrz);
print(sprintf(strd,"remez","xrz"),"-dpdflatex");
close
showZPplot(xrz,Urz,Vrz,Mrz,Qrz,Rrz,strMrz);
print(sprintf(strd,"remez","xrzpz"),"-dpdflatex");
close

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
filter magnitude responses");
legend("IIR PCLS","FIR cl2bp","FIR remez");
legend("location","northeast");
legend("Boxoff");
legend("left");
grid("on");
print(sprintf(strd,"compare","magnitude"),"-dpdflatex");
close

% Save results
print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1","iir_sqp_slb_bandpass_test_d1_coef.m");
print_polynomial(N1,"N1");
print_polynomial(N1,"N1","iir_sqp_slb_bandpass_test_N1_coef.m");
print_polynomial(D1,"D1");
print_polynomial(D1,"D1","iir_sqp_slb_bandpass_test_D1_coef.m");

% Done 
save iir_sqp_slb_bandpass_test.mat U V M Q R fapl fapu dBap Wap ...
     fasl fasu dBas Wasl Wasu ftpl ftpu tp tpr Wtp x0 x1 d1

toc;
diary off
movefile iir_sqp_slb_bandpass_test.diary.tmp iir_sqp_slb_bandpass_test.diary;
