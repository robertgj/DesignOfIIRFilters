% iir_sqp_slb_lowpass_differentiator_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

delete("iir_sqp_slb_lowpass_differentiator_test.diary");
delete("iir_sqp_slb_lowpass_differentiator_test.diary.tmp");
diary iir_sqp_slb_lowpass_differentiator_test.diary.tmp

tol=2e-4
ctol=tol/100
maxiter=2000
verbose=false

% Polynomials from tarczynski_lowpass_differentiator_test.m
N0 = [  -0.0072168784,   0.0302871910,  -0.0551215403,   0.0568029550, ... 
        -0.0351455881,   0.0216214450,  -0.0195926787,  -0.0230129732, ... 
         0.0118050166,  -0.0074358941,   0.0273673757 ]';
D0 = [   1.0000000000,  -2.6514330998,   4.9421908582,  -6.6460969856, ... 
         6.8996479348,  -5.6375628269,   3.6114046129,  -1.7692129547, ... 
         0.6241163383,  -0.1391538860,   0.0124711737 ]';
[x0,U,V,M,Q]=tf2x(N0,D0,tol);
R=1;
% Coefficient constraints
dmax=0.05;
[xl,xu]=xConstraints(U,V,M,Q);

% Low-pass differentiator filter specification
fapl=0.01;fapu=0.25;fas=0.3;td=9;

% Frequency points
n=1000;
napl=ceil(fapl*n/0.5)+1;
napu=ceil(fapu*n/0.5)+1;
nas=ceil(fas*n/0.5)+1;
w=pi*(0:(n-1))'/n;

% Amplitude
wa=w;
Ad=-[wa(1:napu);zeros(n-napu,1)]/pi;
Arp=0.02;
Ars=0.02;
Adu=-[wa(1:napu); ...
      zeros(n-napu,1); ...
     ]/pi+[Arp*ones(napu,1);Ars*ones(n-napu,1)]/2;
Adl=-[wa(1:napu); ...
      2*wa(napu)*ones(nas-napu-1,1); ...
      zeros(n-nas+1,1); ...
     ]/pi-[Arp*ones(napu,1);Ars*ones(n-napu,1)]/2;;
Wap=1;Wat=0.01;Was=1;
Wa=[zeros(napl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Wat*ones(nas-napu-1,1); ...
    Was*ones(n-nas+1,1)];

% Stop-band Amplitude 
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay
wt=w(napl:napu);
Td=td*ones(size(wt));
tdr=0.1;
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wtp=0.1;
Wt=Wtp*ones(size(wt));

% Phase response
wp=w(napl:napu);
Pd=-(wp*td)+(pi/2);
pr=0.002; % Phase peak-to-peak ripple as a proportion of pi
Pdu=Pd+(pr*pi/2);
Pdl=Pd-(pr*pi/2);
Wpp=0.1;
Wp=Wpp*ones(size(wp));

nchk=[1,napl-1,napl,napl+1,napu-1,napu,napu+1,nas-1,nas,nas+1,n];
printf("nchk=[");printf("%d ",nchk);printf(" ]\n");
printf("wa(nchk)=[");printf("%g ",wa(nchk)*0.5/pi);printf(" ]\n");
printf("Ad(nchk)=[");printf("%g ",Ad(nchk));printf(" ]\n");
printf("Adu(nchk)=[");printf("%g ",Adu(nchk));printf(" ]\n");
printf("Adl(nchk)=[");printf("%g ",Adl(nchk));printf(" ]\n");
printf("Wa(nchk)=[");printf("%g ",Wa(nchk));printf(" ]\n");

% Common strings
strM=sprintf("Differentiator %%s:R=%d,fas=%g,td=%g,Wap=%g,Wtp=%g,Wpp=%g", ...
             R,fas,td,Wap,Wtp,Wpp);
strP=sprintf("Differentiator %%s:\
R=%d,fas=%g,Arp=%g,Wap=%g,td=%g,tdr=%g,Wtp=%g,pr=%g,Wpp=%g", ...
             R,fas,Arp,Wap,td,tdr,Wtp,pr,Wpp);
strf="iir_sqp_slb_lowpass_differentiator_test";

% Show initial response
A0=iirA(wa,x0,U,V,M,Q,R);
T0=iirT(wt,x0,U,V,M,Q,R);
P0=iirP(wp,x0,U,V,M,Q,R);
subplot(311);
plot(wa*0.5/pi,A0-Ad);
strt=sprintf("Differentiator initial response:R=%d,fas=%g,td=%g",R,fas,td);
title(strt);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wt*0.5/pi,T0);
ylabel("Group delay(samples)");
grid("on");
subplot(313);
plot(wp*0.5/pi,(P0+(wp*td))/pi);
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_initial_x0phase"),"-dpdflatex");
close

% MMSE pass 1
printf("\nMMSE pass 1:\n");
[x1,E,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,tol,verbose);
if feasible == 0 
  error("x1(mmse) infeasible");
endif
Ax1=iirA(wa,x1,U,V,M,Q,R);
Tx1=iirT(wt,x1,U,V,M,Q,R);
Px1=iirP(wp,x1,U,V,M,Q,R);
subplot(311);
plot(wa*0.5/pi,[Ax1 Adl Adu]-Ad)
axis([0 0.5 -Ars Ars]);
strt=sprintf(strM,"x1(mmse)");
title(strt);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wt*0.5/pi,[Tx1 Tdl Tdu])
axis([0 0.5 td-tdr td+tdr]);
ylabel("Group delay(samples)");
grid("on");
subplot(313);
plot(wp*0.5/pi,([Px1 Pdl Pdu]+(wp*td))/pi);
axis([0 0.5 0.5-pr 0.5+pr]);
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_mmse_x1phase"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1pz"),"-dpdflatex");
close

% PCLS pass
printf("\nPCLS pass :\n");
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,tol,ctol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible");
endif
Ad1=iirA(wa,d1,U,V,M,Q,R);
Td1=iirT(wt,d1,U,V,M,Q,R);
Pd1=iirP(wp,d1,U,V,M,Q,R);
subplot(311);plot(wa*0.5/pi,[Ad1 Adl Adu]-Ad)
axis([0 0.5 -Ars +Ars]);
grid("on");
strt=sprintf(strP,"d1(pcls)");
title(strt);
ylabel("Amplitude error");
subplot(312);
plot(wt*0.5/pi,[Td1 Tdl Tdu])
axis([0 0.5 td-tdr td+tdr]);
ylabel("Group delay(samples)");
grid("on");
subplot(313);
plot(wp*0.5/pi,([Pd1 Pdl Pdu]+(wp*td))/pi);
axis([0 0.5 0.5-pr 0.5+pr]);
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_d1phase"),"-dpdflatex");
close
plot(wa*0.5/pi,[Ad1 Adl Adu]-Ad)
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_Ad1"),"-dpdflatex");
close
showZPplot(d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1pz"),"-dpdflatex");
close

% Coefficients
print_pole_zero(x0,U,V,M,Q,R,"x0",strcat(strf,"_x0_coef.m"));
print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));

% Done
save iir_sqp_slb_lowpass_differentiator_test.mat U V M Q R x0 x1 d1 ...
     tol ctol n fapl fapu fas Arp Ars td tdr pr Wap Wat Was Wtp Wpp

diary off
movefile iir_sqp_slb_lowpass_differentiator_test.diary.tmp ...
         iir_sqp_slb_lowpass_differentiator_test.diary;
