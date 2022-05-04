% iir_sqp_slb_lowpass_differentiator_test.m
% Copyright (C) 2020-2022 Robert G. Jenssen

test_common;

delete("iir_sqp_slb_lowpass_differentiator_test.diary");
delete("iir_sqp_slb_lowpass_differentiator_test.diary.tmp");
diary iir_sqp_slb_lowpass_differentiator_test.diary.tmp

tic;

tol=1e-4
ctol=tol/1000
maxiter=10000
verbose=false

% Polynomials from tarczynski_lowpass_differentiator_test.m
tarczynski_lowpass_differentiator_test_N0_coef;
tarczynski_lowpass_differentiator_test_D0_coef;
[x0,U,V,M,Q]=tf2x(N0,D0,tol);
R=1;

% Remove zero at z=1
iz=find(abs(x0(2:(1+U))-1)<1e-2);
if length(iz) ~= 1
  error("Did not find single zero z==1 in x0!");
endif
x0(1+iz)=[];
U=U-1;

% Coefficient constraints
dmax=0.05;
[xl,xu]=xConstraints(U,V,M,Q);

% Low-pass differentiator filter specification
fap=0.19;fas=0.25;
Arp=0.02;Ars=0.01;Wap=1;Wat=0.001;Was=1;
td=length(N0)-3;tdr=0.03;Wtp=0.02;
pr=0.0006;Wpp=0.02;

% Frequency points
n=1000;
nap=ceil(fap*n/0.5)+1;
nas=ceil(fas*n/0.5)+1;
w=pi*(0:(n-1))'/n;

% Amplitude with z-1 removed
wa=w;
Azm1=[1;2*sin(wa(2:end)/2)];
Ad=[1;wa(2:nap)./Azm1(2:nap);zeros(n-nap,1)]*0.5/pi;
Adu=([1;wa(2:(nas-1))./Azm1(2:(nas-1));zeros(n-nas+1,1)]*0.5/pi) + ...
    ([Arp*ones(nas-1,1);Ars*ones(n-nas+1,1)]/(2*Azm1(nas)));
Adl=Ad-([Arp*ones(nap,1);Ars*ones(n-nap,1)]/(2*Azm1(nap)));
Wa=[Wap*ones(nap,1); ...
    Wat*ones(nas-nap-1,1); ...
    Was*ones(n-nas+1,1)];

% Stop-band Amplitude 
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay with z-1 removed
wt=w(1:nap);
Td=(td-0.5)*ones(size(wt));
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(size(wt));

% Phase response with z-1 removed
wp=w(1:nap);
Pd=pi-(wp*(td-0.5));
Pdu=Pd+(pr*pi/2);
Pdl=Pd-(pr*pi/2);
Wp=Wpp*ones(size(wp));

nchk=[1,2,nap-1,nap,nap+1,nas-1,nas,nas+1,n];
printf("nchk=[");printf("%d ",nchk);printf(" ]\n");
printf("wa(nchk)=[");printf("%g ",wa(nchk)*0.5/pi);printf(" ]\n");
printf("Ad(nchk)=[");printf("%g ",Ad(nchk));printf(" ]\n");
printf("Adu(nchk)=[");printf("%g ",Adu(nchk));printf(" ]\n");
printf("Adl(nchk)=[");printf("%g ",Adl(nchk));printf(" ]\n");
printf("Wa(nchk)=[");printf("%g ",Wa(nchk));printf(" ]\n");

% Common strings
strf="iir_sqp_slb_lowpass_differentiator_test";

% Show initial response with z-1 removed
A0=iirA(wa,x0,U,V,M,Q,R);
T0=iirT(wt,x0,U,V,M,Q,R);
P0=iirP(wp,x0,U,V,M,Q,R);
subplot(311);
plot(wa*0.5/pi,[A0,Adl,Adu]);
strI=sprintf("Differentiator initial response (with z-1 removed):fas=%g,td=%g",
             fas,td-0.5);
title(strI);
ylabel("Amplitude");
grid("on");
subplot(312);
plot(wp*0.5/pi,([P0,Pdl,Pdu]-pi+(wp*(td-0.5)))/pi);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[T0,Tdl,Tdu]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_initial_x0_error"),"-dpdflatex");
close
showZPplot(x0,U,V,M,Q,R,strI);
print(strcat(strf,"_initial_x0_pz"),"-dpdflatex");
close

%
% MMSE pass
%
printf("\nMMSE pass:\n");
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
strM=sprintf("Differentiator MMSE (with z-1 removed):fap=%g,fas=%g,td=%g", ...
             fap,fas,td-0.5);
title(strM);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wp*0.5/pi,([Px1 Pdl Pdu]-pi+(wp*(td-0.5)))/pi);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[Tx1 Tdl Tdu])
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_mmse_x1_error"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strM);
print(strcat(strf,"_mmse_x1_pz"),"-dpdflatex");
close

%
% PCLS pass
%
printf("\nPCLS pass :\n");
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,tol,ctol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible");
endif

% Restore z-1
d1=d1(:);
d1=[d1(1);1;d1(2:end)];
U=U+1;
Ad=[wa(1:nap);zeros(n-nap,1)]*0.5/pi;
Adu=([wa(1:nas-1);zeros(n-nas+1,1)]*0.5/pi) + ...
    ([Arp*ones(nas-1,1);Ars*ones(n-nas+1,1)]/2);
Adl=Ad-([Arp*ones(nap,1);Ars*ones(n-nap,1)]/2);
Td=Td+0.5;
Tdu=Tdu+0.5;
Tdl=Tdl+0.5;
Pd=(3*pi/2)-(wp*td);
Pdu=Pd+(pr*pi/2);
Pdl=Pd-(pr*pi/2);

% Calculate response
Ad1=iirA(wa,d1,U,V,M,Q,R);
Td1=iirT(wt,d1,U,V,M,Q,R);
Pd1=iirP(wp,d1,U,V,M,Q,R);

% Plot error response
subplot(311);
plot(wa(2:n)*0.5/pi,[Ad1(2:n) Adl(2:n) Adu(2:n)]-Ad(2:n))
axis([0 0.5 -max(Arp,Ars) max(Arp,Ars)]);
grid("on");
strP=sprintf ...
("Differentiator PCLS:fap=%g,Arp=%g,fas=%g,Ars=%g,td=%g,tdr=%g,pr=%g", ...
 fap,Arp,fas,Ars,td,tdr,pr);
title(strP);
ylabel("Amplitude error");
subplot(312);
plot(wp(2:nap)*0.5/pi, ...
     (([Pd1(2:nap) Pdl(2:nap) Pdu(2:nap)]+(wp(2:nap)*td))/pi)-1.5);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
axis([0 0.5 -0.0005 0.0005]);
subplot(313);
plot(wt(2:nap)*0.5/pi,[Td1(2:nap) Tdl(2:nap) Tdu(2:nap)])
axis([0 0.5 td-tdr td+tdr]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_d1_error"),"-dpdflatex");
close

% Plot poles and zeros
showZPplot(d1,U,V,M,Q,R,strP);
print(strcat(strf,"_pcls_d1_pz"),"-dpdflatex");
close

% Save coefficients
print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));
[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

% Save specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Ars=%g %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"td=%g %% Pass band group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band group delay peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"pr=%6.4f %% Phase pass band peak-to-peak ripple(rad./$\\pi$))\n",pr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

% Done
toc;
save iir_sqp_slb_lowpass_differentiator_test.mat U V M Q R d1 N1 D1 ...
     tol ctol n fap fas Arp Ars td tdr pr Wap Wat Was Wtp Wpp

diary off
movefile iir_sqp_slb_lowpass_differentiator_test.diary.tmp ...
         iir_sqp_slb_lowpass_differentiator_test.diary;
