% iir_sqp_slb_lowpass_differentiator_alternate_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

strf="iir_sqp_slb_lowpass_differentiator_alternate_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol=1e-4
ctol=tol/10
maxiter=20000
verbose=false

% Polynomials from tarczynski_lowpass_differentiator_alternate_test.m
% (without z-1)
tarczynski_lowpass_differentiator_alternate_test_N0_coef;
tarczynski_lowpass_differentiator_alternate_test_D0_coef;
[x0,U,V,M,Q]=tf2x(N0,D0,tol);
x0(1)=abs(x0(1));
R=1;
print_pole_zero(x0,U,V,M,Q,R,"x0");

% Correction filter order
nN=length(N0)-1;

% Coefficient constraints
dmax=0.05;
[xl,xu]=xConstraints(U,V,M,Q);

  % Low-pass differentiator filter specification
fap=0.2;fas=0.3;
Arp=0.04;Art=0.1;Ars=0.04;Wap=1;Wat_mmse=0.01;Wat_pcls=0.0001;Was=2;
td=nN-2;tdr=0.2;Wtp=0.2;pr=0.001;Wpp=0.2;

% Frequency points
n=1000;
w=pi*(1:(n-1))'/n;
nap=ceil(fap*n/0.5);
nas=ceil(fas*n/0.5);

% Pass and transition band amplitudes
wa=w(1:(nas-1));
Azm1=2*sin(wa/2);
Ad=[wa(1:nap); zeros(nas-nap-1,1)];
Adu=(wa+[(Arp/2)*ones(nap,1); (Art/2)*ones((nas-nap-1),1)]);
Adl=[(wa(1:nap)-(Arp/2));zeros(nas-nap-1,1)];
Wa_mmse=[Wap*ones(nap,1); Wat_mmse*ones(nas-nap-1,1)];
Wa_pcls=[Wap*ones(nap,1); Wat_pcls*ones(nas-nap-1,1)];

% Stop-band amplitude 
ws=w(nas:end);
Szm1=2*sin(ws/2);
Sd=zeros(n-nas,1);
Sdu=(Ars/2)*ones(n-nas,1);
Sdl=zeros(n-nas,1);
Ws=Was*ones(n-nas,1);

% Group delay
wt=w(1:nap);
Tzm1=0.5;
Td=td*ones(size(wt));
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(size(wt));

% Phase response with z-1 removed
wp=w(1:nap);
Pzm1=(pi/2)+(wp/2);
Pconst=pi;
Pd=(pi/2)-(wp*td);
Pdu=Pd+(pr*pi/2);
Pdl=Pd-(pr*pi/2);
Wp=Wpp*ones(size(wp));

nachk=[1,nap-1,nap,nap+1,nas-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa_mmse(nachk)=[");printf("%g ",Wa_mmse(nachk));printf(" ]\n");
printf("Wa_pcls(nachk)=[");printf("%g ",Wa_pcls(nachk));printf(" ]\n");

% Calculate initial response
Ax0=iirA(wa,x0,U,V,M,Q,R);
Sx0=iirA(ws,x0,U,V,M,Q,R);
Tx0=iirT(wt,x0,U,V,M,Q,R);
Px0=iirP(wp,x0,U,V,M,Q,R);

% Plot initial response
subplot(311);
[ax,ha,hs]=plotyy(wa*0.5/pi,[Ax0,[Adl,Adu]./Azm1], ...
                  ws*0.5/pi,[Sx0,[Sdl,Sdu]./Szm1]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 0 1.4]);
axis(ax(2),[0 0.5 0 0.035]);
strI=sprintf("Differentiator initial response (without z-1) : \
fap=%g,fas=%g,td=%g",fap,fas,td);
title(strI);
ylabel("Amplitude");
grid("on");
subplot(312);
plot(wp*0.5/pi,([(Px0-Pzm1),Pd,Pdl,Pdu]-Pd)/pi);
axis([0 0.5 -2*pr 2*pr]);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[Tx0,([Td,Tdl,Tdu]-Tzm1)]);
axis([0 0.5 [td-Tzm1-tdr,td-Tzm1+tdr]]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_initial_x0_response"),"-dpdflatex");
close
showZPplot(x0,U,V,M,Q,R,strI);
print(strcat(strf,"_initial_x0_pz"),"-dpdflatex");
close

%
% MMSE pass
%
printf("\nMMSE pass:\n");
feasible=false;
[x1,E,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad./Azm1,Adu./Azm1,Adl./Azm1,Wa_mmse, ...
               ws,Sd./Szm1,Sdu./Szm1,Sdl./Szm1,Ws, ...
               wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
               wp,Pd+Pzm1,Pdu+Pzm1,Pdl+Pzm1,Wp, ...
               maxiter,tol,verbose);
if feasible == 0 
  error("x1(mmse) infeasible");
endif
Ax1=iirA(wa,x1,U,V,M,Q,R);
Sx1=iirA(ws,x1,U,V,M,Q,R);
Tx1=iirT(wt,x1,U,V,M,Q,R);
Px1=iirP(wp,x1,U,V,M,Q,R);

% Plot MMSE response (without z-1)
subplot(311);
[ax,ha,hs]=plotyy(wa*0.5/pi, [Ax1 [Adl Adu]./Azm1], ...
                  ws*0.5/pi, [Sx1 [Sdl Sdu]./Szm1]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 0 1.4]);
axis(ax(2),[0 0.5 0 0.035]);
strM=sprintf("Differentiator MMSE (without z-1) : fap=%g,fas=%g,td=%g", ...
             fap,fas,td);
title(strM);
ylabel("Amplitude");
grid("on");
subplot(312);
plot(wp*0.5/pi,([(Px1-Pzm1) Pdl Pdu]-Pd)/pi);
axis([0 0.5 (pr*[-1 1])]);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[Tx1 ([Tdl Tdu]-Tzm1)])
axis([0 0.5 [td-Tzm1-tdr,td-Tzm1+tdr]]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_mmse_x1_response"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strM);
print(strcat(strf,"_mmse_x1_pz"),"-dpdflatex");
close

%
% PCLS pass
%
printf("\nPCLS pass :\n");
feasible=false;
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad./Azm1,Adu./Azm1,Adl./Azm1,Wa_pcls, ...
          ws,Sd./Szm1,Sdu./Szm1,Sdl./Szm1,Ws,...
          wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
          wp,Pd+Pzm1,Pdu+Pzm1,Pdl+Pzm1,Wp, ...
          maxiter,tol,ctol,verbose)
if feasible == 0
  error("d1 (pcls) infeasible");
endif

% Add back the zero at z=1
d1z=[d1(1);1;d1(2:end)(:)];
Ud1z=U+1;

% Calculate the overall response
Ad1z=iirA(wa,d1z,Ud1z,V,M,Q,R); 
Sd1z=iirA(ws,d1z,Ud1z,V,M,Q,R); 
Td1z=iirT(wt,d1z,Ud1z,V,M,Q,R); 
Pd1z=iirP(wp,d1z,Ud1z,V,M,Q,R); 

% Plot response
subplot(311);
[ax,ha,hs]= ...
  plotyy(wa(1:nap)*0.5/pi,[Ad1z(1:nap) Adl(1:nap) Adu(1:nap)]-Ad(1:nap), ...
         ws*0.5/pi,[Sd1z Sdl Sdu]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 -Arp Arp]);
axis(ax(2),[0 0.5 -Ars Ars]);
strP=sprintf("Differentiator PCLS : \
fap=%g,Arp=%g,fas=%g,Ars=%g,td=%g,tdr=%g,pr=%g",fap,Arp,fas,Ars,td,tdr,pr);
title(strP);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wp*0.5/pi,([Pd1z-Pconst,Pdl,Pdu]-Pd)/pi);
axis([0 0.5 (pr*[-1,1])]);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[Td1z Tdl Tdu]);
axis([0 0.5 (td+([-1,1]*tdr))]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_d1z_response"),"-dpdflatex");
close

% Plot poles and zeros
showZPplot(d1z,Ud1z,V,M,Q,R,strP);
print(strcat(strf,"_pcls_d1z_pz"),"-dpdflatex");
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
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"nN=%d %% Correction filter order\n",nN);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Art=%g %% Amplitude transition band peak-to-peak ripple\n",Art);
fprintf(fid,"Wat_mmse=%g %% Amplitude MMSE transition band weight\n",Wat_mmse);
fprintf(fid,"Wat_pcls=%g %% Amplitude PCLS transition band weight\n",Wat_pcls);
fprintf(fid,"Ars=%g %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"td=%g %% Pass band group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band group delay peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"pr=%g %% Phase pass band peak-to-peak ripple(rad./$\\pi$))\n",pr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

eval(sprintf("save %s.mat U V M Q R d1 Ud1z d1z N1 D1 ...\n\
tol ctol n fap fas Arp Ars td tdr pr Wap Wat_mmse Wat_pcls Was Wtp Wpp",strf))

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
