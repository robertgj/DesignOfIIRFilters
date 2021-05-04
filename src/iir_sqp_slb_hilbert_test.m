% iir_sqp_slb_hilbert_test.m
% Copyright (C) 2017-2021 Robert G. Jenssen

% Note that with the SOCP solver this test fails to find and satisfy
% phase constraints near w=0 because the phase response has inflexions
% but no peaks in that region.

test_common;

delete("iir_sqp_slb_hilbert_test.diary");
delete("iir_sqp_slb_hilbert_test.diary.tmp");
diary iir_sqp_slb_hilbert_test.diary.tmp


tol=1e-4;
ctol=tol;
maxiter=2000
verbose=false

% Initial filter from tarczynski_hilbert_test.m
N0 = [ -0.0579063991,  -0.0707490525,  -0.0092677810,  -0.0274919718, ... 
       -0.1104277026,  -0.4894105730,   0.8948745630,   1.0527570805, ... 
       -0.8678508170,  -0.4990735123,   0.1861313381,   0.0311088704 ]';
D0 = [  1.0000000000,  -1.4110993644,   0.4589810713,  -0.0092017575, ... 
        0.0011255865,   0.0014507700,  -0.0018420748 ]';
R=2;
[x0,U,V,M,Q]=tf2x(N0,D0);

% Frequency points
n=1000;
w=pi*(-n:(n-1))'/n;

% Hilbert filter specification
fpt=0.1; % Phase transition band at zero
npt=floor(fpt*n); 
td=(U+M)/2;
ftt=0.15; % Delay transition band at zero
ntt=floor(ftt*n); 

% Coefficient constraints
dmax=0.05;
[xl,xu]=xConstraints(U,V,M,Q);

% Amplitude constraints
wa=w;
Ad=-[ones(n,1);0;ones(n-1,1)];
Ar=0.002;
Adl=-[(1+Ar/2)*ones(n-npt,1);(1.01)*ones(2*npt,1);(1+Ar/2)*ones(n-npt,1)];
Adu=-[(1-Ar/2)*ones(n-npt,1);(0.99)*ones(2*npt,1);(1-Ar/2)*ones(n-npt,1)];
Wap=1
Wa=Wap*[ones(n-npt,1);0.1*ones(2*npt,1);ones(n-npt,1)];

% Amplitude stop-band constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay constraints
wt=w;
Td=td*ones(2*n,1);
tdr=0.4;
Tdu=[(td+(tdr/2))*ones(n-ntt,1);10*td*ones(2*ntt,1);(td+(tdr/2))*ones(n-ntt,1)];
Tdl=[(td-(tdr/2))*ones(n-ntt,1);     zeros(2*ntt,1);(td-(tdr/2))*ones(n-ntt,1)];
Wtp=1e-4;
Wt=Wtp*[ones(n-ntt,1);zeros(2*ntt,1);ones(n-ntt,1)];

% Phase constraints
wp=w;
Pd=-wp*td-(5*pi)+[0.5*pi*ones(n,1);0;-0.5*pi*ones(n-1,1)];
pr=0.16;
Pdu=-w*td-(5*pi)+[0.5*pi*ones(n+npt,1);-0.5*pi*ones(n-npt,1)]+(pr*0.5*pi/2);
Pdl=-w*td-(5*pi)+[0.5*pi*ones(n-npt,1);-0.5*pi*ones(n+npt,1)]-(pr*0.5*pi/2);
Wpp=1e-3;
Wp=Wpp*[ones(n-npt,1);zeros(2*npt,1);ones(n-npt,1)];
% The Pd factor of 5*pi matches the behaviour of iirA and iirP.
% Using iirA and iirP the filter has A0 ~ -1 and 
% P0+w*td+4*pi ~ [-0.5*pi;-1.5*pi]
% Using freqz, the N0,D0R filter has abs(H) ~ 1 and 
% unwrap(mod(arg(H)+w*pi,2*pi)) ~ [0.5*pi;-0.5*pi].
%{
 P=iirP(w,x0,U,V,M,Q,R);
 plot(w,mod(Pdl+w*td,2*pi),w,mod(PP+w*td,2*pi),w,mod(Pdu+w*td,2*pi));
 plot(w,Pdl+w*td,w,PP+w*td,w,Pdu+w*td);
 plot(w,Pdl,w,PP,w,Pdu);
%}

% Initialise strings
strM=sprintf("Hilbert filter %%s:Wap=%g,ftt=%g,td=%g,Wtp=%g,fpt=%g,Wpp=%g", ...
             Wap,ftt,td,Wtp,fpt,Wpp);
strP=sprintf("Hilbert filter %%s:\
Ar=%g,Wap=%g,td=%g,ftt=%g,tdr=%g,Wtp=%g,fpt=%g,pr=%g,Wpp=%g", ...
             Ar,Wap,td,ftt,tdr,Wtp,fpt,pr,Wpp);
strf="iir_sqp_slb_hilbert_test";

% Show initial response and constraints
A0=iirA(w,x0,U,V,M,Q,R);
T0=iirT(w,x0,U,V,M,Q,R);
P0=iirP(w,x0,U,V,M,Q,R);
subplot(311);
plot(w*0.5/pi,A0);
strt=sprintf("Hilbert filter initial response : td=%g,fpt=%g",td,fpt);
title(strt);
ylabel("Amplitude");
axis([-0.5 0.5 -1.2 -0.6]);
grid("on");
subplot(312);
plot(w*0.5/pi,(P0+w*td+4*pi)/pi);
ylabel("Phase(rad./$\\pi$)");
axis([-0.5 0.5 -2 0]);
grid("on");
subplot(313);
plot(w*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([-0.5 0.5 0 10*td]);
grid("on");
print(strcat(strf,"_initial_x0phase"),"-dpdflatex");
close

% Try with xInitHd
%{
[x0b,Ex0b]=xInitHd(x0,U,V,M,Q,R, ...
                   wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,maxiter,1e-7);
printf("x0b=[ ");printf("%f ",x0b');printf("]'\n");
% Show initial response and constraints
A0b=iirA(w,x0b,U,V,M,Q,R);
P0b=iirP(w,x0b,U,V,M,Q,R);
subplot(211);
plot(w*0.5/pi,[A0b Adl Adu]);
axis([-0.5 0.5 -1.02 -0.98]);
grid("on");
strt=sprintf("Hilbert filter initial response(b) : td=%g,fpt=%g",td,fpt);
title(strt);
ylabel("Amplitude");
subplot(212);
plot(w*0.5/pi,4+([P0b+w*td Pdl+w*td Pdu+w*td]/pi));
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
axis([-0.5 0.5 -5 -1]);
grid("on");
print(strcat(strf,"_initial_x0bphase"),"-dpdflatex");
close
%}

%
% SQP MMSE pass
%
printf("\nMMSE pass 1:\n");
[x1,Ex1,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,tol,verbose)
if feasible == 0
  error("x1(mmse) infeasible");
endif
strt=sprintf(strM,"x1(mmse)");
showZPplot(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1pz"),"-dpdflatex");
close
showResponse(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_x1"),"-dpdflatex");
close
Ax1=iirA(w,x1,U,V,M,Q,R);
Tx1=iirT(w,x1,U,V,M,Q,R);
Px1=iirP(w,x1,U,V,M,Q,R);
subplot(311);
h311=plot(w*0.5/pi,[Ax1 Adl Adu]);
title(strt);
ylabel("Amplitude");
axis([-0.5 0.5 -1.02 -0.98]);
grid("on");
subplot(312);
Px1_plot=[Px1+w*td Pdl+w*td Pdu+w*td]+4*pi;
[ax,h1,h2]=plotyy(w(1:(n-npt))*0.5/pi,      Px1_plot(1:(n-npt),:)/pi, ...
                  w((n+npt+1):(2*n))*0.5/pi,Px1_plot((n+npt+1):(2*n),:)/pi);
% Hack to match colours. Is there an easier way with colormap?
h311c=get(h311,'color');
for k=1:3
  set(h2(k),'color',h311c{k});
endfor
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
% End of hack
axis(ax(1),[-0.5 0.5 -0.5-(pr/2) -0.5+(pr/2)]);
axis(ax(2),[-0.5 0.5 -1.5-(pr/2) -1.5+(pr/2)]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
h312=plot(w*0.5/pi,[Tx1 Tdl Tdu]);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([-0.5 0.5 td-tdr td+tdr]);
grid("on");
print(strcat(strf,"_mmse_x1phase"),"-dpdflatex");
close

%
% PCLS pass
%
printf("\nPCLS pass 1:\n");
[d1,E,slb_iter,sqp_iter,func_iter,feasible] = ...
  iir_slb(@iir_sqp_mmse,x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,tol,ctol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible");
endif
strt=sprintf(strP,"d1(pcls)");
showZPplot(d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1pz"),"-dpdflatex");
close
showResponse(d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_d1"),"-dpdflatex");
close
Ad1=iirA(w,d1,U,V,M,Q,R);
Td1=iirT(w,d1,U,V,M,Q,R);
Pd1=iirP(w,d1,U,V,M,Q,R);
subplot(311);
h311=plot(w*0.5/pi,[Ad1 Adl Adu]);
title(strt);
ylabel("Amplitude");
grid("on");
axis([-0.5 0.5 -1.002 -0.998]);
subplot(312);
Pplot=[Pd1+w*td Pdl+w*td Pdu+w*td]+4*pi;
[ax,h1,h2]=plotyy(w(1:(n-npt))*0.5/pi,      Pplot(1:(n-npt),:)/pi, ...
                  w((n+npt+1):(2*n))*0.5/pi,Pplot((n+npt+1):(2*n),:)/pi);
% Hack to match colours. Is there an easier way with colormap?
h311c=get(h311,'color');
for k=1:3
  set(h2(k),'color',h311c{k});
endfor
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
% End of hack
axis(ax(1),[-0.5 0.5 -0.5-(pr/2) -0.5+(pr/2)]);
axis(ax(2),[-0.5 0.5 -1.5-(pr/2) -1.5+(pr/2)]); 
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(w*0.5/pi,[Td1 Tdl Tdu]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
axis([-0.5 0.5 td-tdr td+tdr]);
print(strcat(strf,"_pcls_d1phase"),"-dpdflatex");
close

% Specification file
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on relative coefficient update size\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"fpt=%g %% Phase response transition edge\n",fpt);
fprintf(fid,"pr=%g %% Phase response peak-to-peak ripple(relative to π/2)\n",pr);
fprintf(fid,"Wpp=%g %% Phase response weight\n",Wpp);
fprintf(fid,"Ar=%g %% Amplitude response peak-to-peak ripple\n",Ar);
fprintf(fid,"Wap=%d %% Amplitude respnse weight\n",Wap);
fprintf(fid,"ftt=%g %% Group delay response transition edge\n",ftt);
fprintf(fid,"td=%d %% Nominal filter group delay\n",td);
fprintf(fid,"tdr=%g %% Group delay peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%g %% Group delay weight\n",Wtp);
fprintf(fid,"U=%d %% Number of real zeros\n",U);
fprintf(fid,"V=%d %% Number of real poles\n",V);
fprintf(fid,"M=%d %% Number of complex zeros\n",M);
fprintf(fid,"Q=%d %% Number of complex poles\n",Q);
fprintf(fid,"R=%d %% Denominator polynomial decimation factor\n",R);
fclose(fid);
% Coefficients
print_pole_zero(x0,U,V,M,Q,R,"x0",strcat(strf,"_x0_coef.m"));
print_pole_zero(d1,U,V,M,Q,R,"d1");
print_pole_zero(d1,U,V,M,Q,R,"d1",strcat(strf,"_d1_coef.m"));
[N1,D1]=x2tf(d1,U,V,M,Q,R);
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

% Done
save iir_sqp_slb_hilbert_test.mat U V M Q R x0 x1 d1 tol ctol ...
     n w Ad Ar td ftt tdr Pd fpt pr

diary off
movefile iir_sqp_slb_hilbert_test.diary.tmp iir_sqp_slb_hilbert_test.diary;
