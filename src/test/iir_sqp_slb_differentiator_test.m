% iir_sqp_slb_differentiator_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="iir_sqp_slb_differentiator_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-4
ctol=ftol/20
maxiter=2000
verbose=false

% From tarczynski_differentiator_test.m
tarczynski_differentiator_test_D0_coef; 
tarczynski_differentiator_test_N0_coef;

% Find pole-zero form of initial filter 
[x0,U,V,M,Q]=tf2x(N0,D0);
R=2;
print_pole_zero(x0,U,V,M,Q,R,"x0");
print_pole_zero(x0,U,V,M,Q,R,"x0",strcat(strf,"_x0_coef.m"));

% Low-pass differentiator filter specification
ft1=0.390;ft2=0.455;
Ar1=0.0040;Ar2=0.0100;Wap=1;
td=5.5;tdr=0.0089;Wtp=0.0135;
pr=0.00067;Wpp=0.0275;

% Frequency points
n=1000;
nt1=ceil(ft1*n/0.5)+1;
nt2=ceil(ft2*n/0.5)+1;
w=pi*(0:(n-1))'/n;

% Show initial response
A0=iirA(w,x0,U,V,M,Q,R);
T0=iirT(w,x0,U,V,M,Q,R);
P0=iirP(w,x0,U,V,M,Q,R);
subplot(311);
plot(w*0.5/pi,A0);
axis([0 0.5 -0.1 1.1]);
strI=sprintf("Differentiator initial response:R=%d,td=%g",R,td);
title(strI);
ylabel("Amplitude");
grid("on");
subplot(312);
plot(w*0.5/pi,(P0+(w*td))/pi);
axis([0 0.5 -0.6 -0.4]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(w*0.5/pi,T0);
axis([0 0.5 4 7]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_initial_x0_response"),"-dpdflatex");
close
showZPplot(x0,U,V,M,Q,R,strI);
print(strcat(strf,"_initial_x0_pz"),"-dpdflatex");
close

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

% Amplitude
wa=w(1:nt2);
Azm1=[1;2*sin(wa(2:end)/2)];
Ad=[1;wa(2:end)]./(pi*Azm1);
Adu=Ad+([Ar1*ones(size(wa(1:nt1)));Ar2*ones(size(wa((nt1+1):end)))]./(2*Azm1));
Adl=Ad-([Ar1*ones(size(wa(1:nt1)));Ar2*ones(size(wa((nt1+1):end)))]./(2*Azm1));
Wa=Wap*ones(size(wa));

% Stop-band Amplitude 
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay 
wt=wa;
Td=(td-0.5)*ones(size(wt));
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(size(wt));

% Phase response 
wp=wa;
Pd=pi-(wp*(td-0.5));
Pdu=Pd+(pr*pi/2);
Pdl=Pd-(pr*pi/2);
Wp=Wpp*ones(size(wp));

% Sanity check
nchk=[1,2,nt1-1,nt1,nt1+1,nt2-1,nt2];
printf("nchk=[");printf("%d ",nchk);printf(" ]\n");
printf("wa(nchk)=[");printf("%g ",wa(nchk)*0.5/pi);printf(" ]\n");
printf("Ad(nchk)=[");printf("%g ",Ad(nchk));printf(" ]\n");
printf("Adu(nchk)=[");printf("%g ",Adu(nchk));printf(" ]\n");
printf("Adl(nchk)=[");printf("%g ",Adl(nchk));printf(" ]\n");
printf("Wa(nchk)=[");printf("%g ",Wa(nchk));printf(" ]\n");

% MMSE pass
printf("\nMMSE pass 1:\n");
[x1,Emmse,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,ftol,ctol,verbose)
if feasible == 0 
  error("x1(mmse) infeasible");
endif

% Plot MMSE response
Ax1=iirA(wa,x1,U,V,M,Q,R);
Tx1=iirT(wt,x1,U,V,M,Q,R);
Px1=iirP(wp,x1,U,V,M,Q,R);
subplot(311);
plot(wa*0.5/pi,[Ax1 Adl Adu]-Ad)
axis([0 0.5 -max(Ar1,Ar2)/2 max(Ar1,Ar2)/2]);
strM=sprintf("Differentiator correction filter MMSE response : \
R=%d,ft1=%g,ft2=%g,td=%g",R,ft1,ft2,(td-0.5));
title(strM);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wp*0.5/pi,([Px1 Pdl Pdu]+(wp*(td-0.5)))/pi);
axis([0 0.5 1-(2*pr) 1+(2*pr)]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[Tx1 Tdl Tdu])
axis([0 0.5 (td-0.5)-tdr (td-0.5)+tdr]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_mmse_x1_error"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strM);
print(strcat(strf,"_mmse_x1_pz"),"-dpdflatex");
close

% PCLS pass
printf("\nPCLS pass :\n");
[d1,Epcls,slb_iter,sqp_iter,func_iter,feasible] = ...
iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
        wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
        wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
        maxiter,ftol,ctol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible\n");
endif

% Restore z-1
d1=d1(:);
d1=[d1(1);1;d1(2:end)];
U=U+1;
Ad=w/pi;
Ar12=[Ar1*ones(size(wa(1:nt1)));Ar2*ones(size(wa((nt1+1):nt2)))];
Adu=[Ad(1:nt2)+(Ar12/2); +10000*ones(n-nt2,1)];
Adl=[Ad(1:nt2)-(Ar12/2); -10000*ones(n-nt2,1)];
Td=td*ones(size(w));
Tdu=[(Td(1:nt2)+(tdr/2)); (Td((nt2+1):end)+10000)];
Tdl=[(Td(1:nt2)-(tdr/2)); (Td((nt2+1):end)-10000)];
Pd=(3*pi/2)-(w*td);
Pdu=[(Pd(1:nt2)+(pr*pi/2)); (Pd((nt2+1):end)+10000)];
Pdl=[(Pd(1:nt2)-(pr*pi/2)); (Pd((nt2+1):end)-10000)];

% Calculate response
Ad1=iirA(w,d1,U,V,M,Q,R);
Td1=iirT(w,d1,U,V,M,Q,R);
Pd1=iirP(w,d1,U,V,M,Q,R);

% Plot error response
subplot(311);
plot(w*0.5/pi,[Ad1 Adl Adu]-Ad);
axis([0 0.5 -(max(Ar1,Ar2)/2)-0.001 +(max(Ar1,Ar2)/2)+0.001]);
grid("on");
strP=sprintf("Differentiator PCLS response:\
R=%d,ft1=%g,ft2=%g,Ar1=%g,Ar2=%g,td=%g,tdr=%g,pr=%g",
             R,ft1,ft2,Ar1,Ar2,td,tdr,pr);
title(strP);
ylabel("Amplitude error");
subplot(312);
plot(w(2:end)*0.5/pi,([Pd1(2:end) Pdl(2:end) Pdu(2:end)]+(w(2:end)*td))/pi);
axis([0 0.5 1.5-pr 1.5+pr]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(w(2:end)*0.5/pi,[Td1(2:end) Tdl(2:end) Tdu(2:end)]);
axis([0 0.5 td-tdr td+tdr]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_d1_error"),"-dpdflatex");
close
showZPplot(d1,U,V,M,Q,R,strP);
print(strcat(strf,"_pcls_d1_pz"),"-dpdflatex");
close

% Coefficients
print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));
[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Multiplicity of real and complex poles\n",R);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ft1=%g %% Amplitude pass band first upper edge\n",ft1);
fprintf(fid,"Ar1=%g %% Amplitude first peak-to-peak ripple\n",Ar1);
fprintf(fid,"ft2=%g %% Amplitude pass band second upper edge\n",ft2);
fprintf(fid,"Ar2=%g %% Amplitude second peak-to-peak ripple\n",Ar2);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"td=%g %% Pass band group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band group delay peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"pr=%g %% Phase pass band peak-to-peak ripple(rad./$\\pi$))\n",pr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

% Done
toc;
eval(sprintf("save %s.mat U V M Q R x0 x1 d1 N1 D1 \
ftol ctol n ft1 ft2 Ar1 Ar2 Wap td tdr Wtp pr Wpp",strf));

diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
