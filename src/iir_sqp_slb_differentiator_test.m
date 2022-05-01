% iir_sqp_slb_differentiator_test.m
% Copyright (C) 2017-2022 Robert G. Jenssen

test_common;

delete("iir_sqp_slb_differentiator_test.diary");
delete("iir_sqp_slb_differentiator_test.diary.tmp");
diary iir_sqp_slb_differentiator_test.diary.tmp


tol=2e-4
ctol=tol
maxiter=2000
verbose=false

% From tarczynski_differentiator_test.m
tarczynski_differentiator_test_D0_coef; 
tarczynski_differentiator_test_N0_coef;

% Find pole-zero form of initial filter 
R=2;
D0R=[1;kron(D0(2:end),[zeros(R-1,1);1])];
[x0,U,V,M,Q]=tf2x(N0,D0);
td=5.5;
n=1000;
ft=0.05;
ntl=ft*n;
ntu=n-ntl;
w=(ntl:ntu)'*pi/n;

% Coefficient constraints
dmax=0.05;
[xl,xu]=xConstraints(U,V,M,Q);

% Amplitude
wa=w;
Ad=-wa/pi;
Ar=0.004;
Adu=-wa/pi+(Ar/2);
Adl=-wa/pi-(Ar/2);
Wap=1;
Wa=Wap*ones(size(wa));

% Stop-band Amplitude 
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay
wt=w;
Td=td*ones(size(wt));
tdr=0.2;
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wtp=0.001;
Wt=Wtp*ones(size(wt));

% Phase response
wp=w;
Pd=-(wp*td)+(3*pi/2);
pr=0.01; % Phase peak-to-peak ripple as a proportion of pi
Pdu=Pd+(pr*pi/2);
Pdl=Pd-(pr*pi/2);
Wpp=0.1;
Wp=Wpp*ones(size(wp));

% Common strings
strM=sprintf("Differentiator %%s:R=%d,ft=%g,td=%g,Wap=%g,Wtp=%g,Wpp=%g", ...
             R,ft,td,Wap,Wtp,Wpp);
strP=sprintf("Differentiator %%s:\
R=%d,ft=%g,Ar=%g,Wap=%g,td=%g,tdr=%g,Wtp=%g,pr=%g,Wpp=%g", ...
             R,ft,Ar,Wap,td,tdr,Wtp,pr,Wpp);
strf="iir_sqp_slb_differentiator_test";

% Show initial response and constraints
A0=iirA(wa,x0,U,V,M,Q,R);
T0=iirT(wt,x0,U,V,M,Q,R);
P0=iirP(wp,x0,U,V,M,Q,R);
subplot(311);
plot(wa*0.5/pi,A0-Ad);
axis([0 0.5 -0.01 0.01]);
strt=sprintf("Differentiator initial response:R=%d,ft=%g,td=%g",R,ft,td);
title(strt);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wp*0.5/pi,(P0+(wp*td))/pi);
axis([0 0.5 1.49 1.51]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,T0);
axis([0 0.5 5.4 5.8]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_initial_x0phase"),"-dpdflatex");
close

% MMSE pass
printf("\nMMSE pass 1:\n");
[x1,Emmse,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,tol,verbose)
if feasible == 0 
  error("x1(mmse) infeasible");
endif

Ax1=iirA(wa,x1,U,V,M,Q,R);
Tx1=iirT(wt,x1,U,V,M,Q,R);
Px1=iirP(wp,x1,U,V,M,Q,R);
subplot(311);
plot(wa*0.5/pi,[Ax1 Adl Adu]-Ad)
axis([0 0.5 -Ar Ar]);
strt=sprintf(strM,"x1(mmse)");
title(strt);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wp*0.5/pi,([Px1 Pdl Pdu]+(wp*td))/pi);
axis([0 0.5 1.5-pr 1.5+pr]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[Tx1 Tdl Tdu])
axis([0 0.5 td-tdr td+tdr]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_mmse_x1phase"),"-dpdflatex");
close
showZPplot(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1pz"),"-dpdflatex");
close

% PCLS pass
printf("\nPCLS pass :\n");
[d1,Epcls,slb_iter,sqp_iter,func_iter,feasible] = ...
iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
        wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
        wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
        maxiter,tol,ctol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible\n");
endif

Ad1=iirA(wa,d1,U,V,M,Q,R);
Td1=iirT(wt,d1,U,V,M,Q,R);
Pd1=iirP(wp,d1,U,V,M,Q,R);
subplot(311);
plot(wa*0.5/pi,[Ad1 Adl Adu]-Ad)
axis([0 0.5 -Ar +Ar]);
grid("on");
strt=sprintf(strP,"d1(pcls)");
title(strt);
ylabel("Amplitude error");
subplot(312);
plot(wp*0.5/pi,([Pd1 Pdl Pdu]+(wp*td))/pi);
axis([0 0.5 1.5-pr 1.5+pr]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[Td1 Tdl Tdu])
axis([0 0.5 td-tdr td+tdr]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_d1phase"),"-dpdflatex");
close
plot(w*0.5/pi,abs(Ad1))
ylabel("Amplitude");
xlabel("Frequency");
title(sprintf(strP,"d1"));
grid("on");
print(strcat(strf,"_pcls_d1"),"-dpdflatex");
close
showZPplot(d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1pz"),"-dpdflatex");
close

% Check results
[N1,D1]=x2tf(d1,U,V,M,Q,R);
h=freqz(N1,D1,w);
t=grpdelay(N1,D1,n);
t=t(ntl:ntu);
plot(w*0.5/pi,abs([h Adl Adu])./(w/pi))
axis([0 0.5 1-0.01 1+0.01]);
ylabel("Amplitude\n(Adjusted for frequency)");
xlabel("Frequency");
title(sprintf(strP,"d1"));
grid("on");
print(strcat(strf,"_pcls_d1freqz"),"-dpdflatex");
close

% Coefficients
print_pole_zero(x0,U,V,M,Q,R,"x0",strcat(strf,"_x0_coef.m"));
print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

% Done
save iir_sqp_slb_differentiator_test.mat U V M Q R x0 x1 d1 N1 D1 ...
     tol ctol n ft Ar td tdr pr

diary off
movefile iir_sqp_slb_differentiator_test.diary.tmp ...
         iir_sqp_slb_differentiator_test.diary;
