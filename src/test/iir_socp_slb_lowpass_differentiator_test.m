% iir_socp_slb_lowpass_differentiator_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="iir_socp_slb_lowpass_differentiator_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=1e-3
ctol=ftol/100
verbose=false

% Initialise with polynomials without z-1
tarczynski_lowpass_differentiator_test_N0_coef;
tarczynski_lowpass_differentiator_test_D0_coef;
[x0,U,V,M,Q]=tf2x(N0,D0,ftol);
R=1;

% Avoid problems with negative A from iirA since 
% tarczynski_lowpass_differentiator_test
% returns the differential of e^(-jwt) as -jw*e^(-jwt)
x0(1)=abs(x0(1));
print_pole_zero(x0,U,V,M,Q,R,"x0");

% Correction filter order
nN=length(N0)-1;

% Low-pass differentiator filter specification
% (ppr=0.002,tpr=0.04 fails under QEMU)
fap=0.3;fas=0.4;
Arp=0.02;Art=0.02;Ars=0.02;Wap=1;Wat=0.001;Was=1;
pp=0.5;ppr=0.0004;Wpp=0.2;
tp=nN-1;tpr=0.08;Wtp=0.1;
      
% Frequency points
n=1000;
w=pi*(1:(n-1))'/n;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);

% Pass and transition band amplitudes
wa=w(1:(nas-1));
Azm1=2*sin(wa/2);
Ad=[(wa(1:nap)/2); zeros(nas-nap-1,1)];
Adu=(wa/2)+[(Arp/2)*ones(nap,1); (Art/2)*ones(nas-nap-1,1)];
Adl=Ad-[(Arp/2)*ones(nap,1);(Art/2)*ones(nas-nap-1,1)];
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1)];

nachk=[1,2,nap-1,nap,nap+1,nas-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Stop-band amplitude 
ws=w(nas:end);
Szm1=2*sin(ws/2);
Sd=zeros(n-nas,1);
Sdu=(Ars/2)*ones(n-nas,1);
Sdl=zeros(n-nas,1);
Ws=Was*ones(n-nas,1);

% Phase response
wp=w(1:nap);
Pzm1=(pi/2)-(wp/2);
Pconst=2*pi;
Pd=(pp*pi)+Pconst-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% Group delay
wt=w(1:nap);
Tzm1=0.5*ones(size(wt));
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% Calculate initial response
Ax0=iirA(wa,x0,U,V,M,Q,R).*Azm1;
Sx0=iirA(ws,x0,U,V,M,Q,R).*Szm1;
Px0=iirP(wp,x0,U,V,M,Q,R)+Pzm1;
Tx0=iirT(wt,x0,U,V,M,Q,R)+Tzm1;

% Plot initial response
subplot(311);
[ax,ha,hs]=plotyy(wa*0.5/pi,[Ax0,Adl,Adu],ws*0.5/pi,[Sx0,Sdl,Sdu]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 0 1.2]);
axis(ax(2),[0 0.5 0 0.06]);
strI=sprintf("Differentiator initial response : fap=%g,fas=%g,tp=%g",fap,fas,tp);
title(strI);
ylabel("Amplitude");
grid("on");
subplot(312);
plot(wp*0.5/pi,([Px0,Pdl,Pdu]-Pconst+(wp*tp))/pi);
axis([0 0.5 pp+(0.001*[-1,1])]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[Tx0,Tdl,Tdu]);
axis([0 0.5 tp+(0.1*[-1,1])]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_initial_response"),"-dpdflatex");
close
showZPplot(x0,U,V,M,Q,R,strI);
print(strcat(strf,"_initial_pz"),"-dpdflatex");
close

%
% MMSE pass
%

% Coefficient constraints
dmax=0.05;
[xl,xu]=xConstraints(U,V,M,Q);
if V==1 
  % A hack to force a single real pole away from 0 and speed up convergence
  x0(1+U+1)=0.5;
endif

printf("\nMMSE pass:\n");
feasible=false;
[x1,E,socp_iter,func_iter,feasible] = ...
  iir_socp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad./Azm1,Adu./Azm1,Adl./Azm1,Wa, ...
               ws,Sd./Szm1,Sdu./Szm1,Sdl./Szm1,Ws, ...
               wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
               wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
               maxiter,ftol,ctol,verbose);
if feasible == 0
  error("x1(MMSE) infeasible");
endif

Ax1=iirA(wa,x1,U,V,M,Q,R).*Azm1;
Sx1=iirA(ws,x1,U,V,M,Q,R).*Szm1;
Px1=iirP(wp,x1,U,V,M,Q,R)+Pzm1;
Tx1=iirT(wt,x1,U,V,M,Q,R)+Tzm1;

% Plot the MMSE error response 
subplot(311);
AmR=1:nap;
[ax,ha,hs]=plotyy(wa(AmR)*0.5/pi,[Ax1(AmR) Adl(AmR) Adu(AmR)]-Ad(AmR), ...
                  ws*0.5/pi,[Sx1 Sdl Sdu]-Sd);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 Arp*[-1,1]]);
axis(ax(2),[0 0.5 Ars*[-1,1]]);
strM=sprintf("Differentiator MMSE error : fap=%g,fas=%g,tp=%g", fap,fas,tp);
title(strM);
ylabel("Amplitude");
grid("on");
subplot(312);
plot(wp*0.5/pi,([Px1 Pdl Pdu]-Pd)/pi);
axis([0 0.5 ppr*[-1,1]]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[Tx1 Tdl Tdu]-Td)
axis([0 0.5 tpr*[-1,1]]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_mmse_error"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strM);
print(strcat(strf,"_mmse_pz"),"-dpdflatex");
close

%
% PCLS pass
%
printf("\nPCLS pass :\n");
feasible=false;
[d1,E,slb_iter,socp_iter,func_iter,feasible] = ...
  iir_slb(@iir_socp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad./Azm1,Adu./Azm1,Adl./Azm1,Wa, ...
          ws,Sd./Szm1,Sdu./Szm1,Sdl./Szm1,Ws, ...
          wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
          wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
          maxiter,ftol,ctol,verbose)
if feasible == false
  error("d1 (PCLS) infeasible");
endif

% Restore 1-z^{-1}
d1z=[d1(1);1;d1(2:end)(:)];
Ud1z=U+1;

% Calculate response
Ad1z=iirA(wa,d1z,Ud1z,V,M,Q,R);
Sd1z=iirA(ws,d1z,Ud1z,V,M,Q,R);
Pd1z=iirP(wp,d1z,Ud1z,V,M,Q,R);
Td1z=iirT(wt,d1z,Ud1z,V,M,Q,R);

% Plot error response
subplot(311);
ApR=1:nap;
[ax,ha,hs]=plotyy(wa(ApR)*0.5/pi,[Ad1z(ApR) Adl(ApR) Adu(ApR)]-Ad(ApR), ...
                  ws*0.5/pi,[Sd1z Sdl Sdu]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 Arp*[-1,1]]);
axis(ax(2),[0 0.5 Ars*[-1,1]]);
strPerror=sprintf("Differentiator PCLS error : \
fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g",fap,Arp,fas,Ars,tp,tpr,ppr);
title(strPerror);
ylabel("Amplitude");
grid("on");
subplot(312);
plot(wp*0.5/pi,([(Pd1z+Pconst) Pdl Pdu]-Pd)/pi);
axis([0 0.5 ppr*[-1,1]]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[Td1z Tdl Tdu]-Td);
axis([0 0.5 tpr*[-1,1]]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_error"),"-dpdflatex");
close

% Plot the overall response
subplot(311);
AtR=1:(nas-3);
[ax,ha,hs]=plotyy(wa(AtR)*0.5/pi,[Ad1z(AtR) Adl(AtR) Adu(AtR)], ...
                  ws*0.5/pi,[Sd1z Sdl Sdu]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 0 1.2]);
axis(ax(2),[0 0.5 0 0.03]);
strP=sprintf("Differentiator PCLS : \
fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g",fap,Arp,fas,Ars,tp,tpr,ppr);
title(strP);
ylabel("Amplitude");
grid("on");
subplot(312);
plot(wp*0.5/pi,([Pd1z Pdl-Pconst Pdu-Pconst]+(wp*tp))/pi);
axis([0 0.5 pp+(ppr*[-1,1])]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[Td1z Tdl Tdu])
axis([0 0.5 tp+(tpr*[-1,1])]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_response"),"-dpdflatex");
close

% Plot poles and zeros
showZPplot(d1z,Ud1z,V,M,Q,R,strP);
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Save coefficients
print_pole_zero(d1z,Ud1z,V,M,Q,R,"d1z");
print_pole_zero(d1z,Ud1z,V,M,Q,R,"d1z",strcat(strf,"_d1z_coef.m"));

[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"dmax=%d %% SQP step-size constraint\n",dmax);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"nN=%d %% Correction filter order\n",nN);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Art=%g %% Amplitude transition band peak-to-peak ripple\n",Art);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"Ars=%g %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"pp=%g %% Phase pass band nominal phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

eval(sprintf("save %s.mat U Ud1z V M Q R d1 d1z N1 D1 ftol ctol n \
fap fas Arp Art Ars tp tpr pp ppr Wap Wat Was Wtp Wpp",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
