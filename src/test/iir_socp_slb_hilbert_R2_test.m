% iir_socp_slb_hilbert_R2_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="iir_socp_slb_hilbert_R2_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic

maxiter=2000
ftol=1e-3;
ctol=ftol/10;
verbose=false

%
% Initial filter from tarczynski_hilbert_R2_test.m
%
tarczynski_hilbert_R2_test_N0_coef;
tarczynski_hilbert_R2_test_D0_coef;
[x0,U,V,M,Q]=tf2x(N0,D0);
R=2;

%
% Frequency points
%
% The A and T responses are symmetric in frequency and the P response is
% antisymmetric. Any A and T constraints are duplicated at negative and
% positive frequencies resulting in a reduced rank constraint matrix.
% Avoid this problem by staggering the frequencies.
%
n=1000;
nnrng=-(n-2):2:0;
nprng=1:2:(n-1);
w=pi*([nnrng(:);nprng(:)])/n;
non2=floor(n/2);

% Hilbert filter specification
Ar=0.01;At=Ar;Wap=1;Wat=0.1;
td=(U+M)/2;
ftt=0.08; % Delay transition band at zero
ntt=floor(ftt*n);
tdr=0.15;Wtp=0.01;
Wtt=0;
fpt=0.06; % Phase transition band at zero
npt=floor(fpt*n); 
pp=5;ppr=0.01;Wpp=0.001;Wpt=0;

% Coefficient constraints
dmax=0.05;
[xl,xu]=xConstraints(U,V,M,Q);

% Amplitude constraints
wa=w;
Ad=ones(n,1);
Adu=[(1+(Ar/2))*ones(non2-npt,1); ...
     (1+(At/2))*ones(2*npt,1); ...
     (1+(Ar/2))*ones(non2-npt,1)];
Adl=[(1-(Ar/2))*ones(non2-npt,1); ...
     (1-(At/2))*ones(2*npt,1); ...
     (1-(Ar/2))*ones(non2-npt,1)];
Wa=[Wap*ones(non2-npt,1);Wat*ones((2*npt),1);Wap*ones(non2-npt,1)];

% Amplitude stop-band constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay constraints
wt=w;
Td=td*ones(n,1);
Tdu=[(td+(tdr/2))*ones(non2-ntt,1); ...
     10*td*ones(2*ntt,1); ...
     (td+(tdr/2))*ones(non2-ntt,1)];
Tdl=[(td-(tdr/2))*ones(non2-ntt,1);...
     zeros(2*ntt,1); ...
     (td-(tdr/2))*ones(non2-ntt,1)];
Wt=[Wtp*ones(non2-ntt,1);Wtt*ones(2*ntt,1);Wtp*ones(non2-ntt,1)];

% Phase constraints
wp=w;
Pd=-wp*td-(pp*pi)+([ones(non2-1,1);0;-ones(non2,1)]*pi/2);
Pdu=-wp*td-(pp*pi)+([ones(non2+npt,1);-ones(non2-npt,1)]*pi/2)+(ppr*pi/2);
Pdl=-wp*td-(pp*pi)+([ones(non2-npt,1);-ones(non2+npt,1)]*pi/2)-(ppr*pi/2);
Wp=[Wpp*ones(non2-npt,1);Wpt*ones(2*npt,1);Wpp*ones(non2-npt,1)];

% Initialise strings
strM=sprintf("Hilbert filter %%s:Wap=%g,ftt=%g,td=%g,Wtp=%g,fpt=%g,Wpp=%g", ...
             Wap,ftt,td,Wtp,fpt,Wpp);
strP=sprintf(["Hilbert filter %%s:", ...
 "R=2,Ar=%g,Wap=%g,td=%g,ftt=%g,tdr=%g,Wtp=%g,fpt=%g,ppr=%g,Wpp=%g"], ...
             Ar,Wap,td,ftt,tdr,Wtp,fpt,ppr,Wpp);

% Show initial response and constraints
A0=iirA(w,x0,U,V,M,Q,R);
T0=iirT(w,x0,U,V,M,Q,R);
P0=iirP(w,x0,U,V,M,Q,R);

% Plot the initial response
subplot(311);
plot(w*0.5/pi,A0);
strt=sprintf("Hilbert filter initial response : R=2,td=%g,fpt=%g",td,fpt);
title(strt);
ylabel("Amplitude");
axis([-0.5 0.5 0.6 1.2 ]);
grid("on");
subplot(312);
plot(w*0.5/pi,(P0+(w*td)+(pp*pi))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([-0.5 0.5 -1 1]);
grid("on");
subplot(313);
plot(w*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([-0.5 0.5 0 10*td]);
grid("on");
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

% Plot poles and zeros
showZPplot(x0,U,V,M,Q,R,strt);
print(strcat(strf,"_initial_pz"),"-dpdflatex");
close


%
% SOCP MMSE pass
%
printf("\nMMSE pass 1:\n");
[x1,Ex1,socp_iter,func_iter,feasible] = ...
  iir_socp_mmse([], ...
               x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa, ...
               ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt, ...
               wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,ftol,ctol,verbose)
if feasible == 0
  error("x1(mmse) infeasible");
endif

Ax1=iirA(w,x1,U,V,M,Q,R);
Tx1=iirT(w,x1,U,V,M,Q,R);
Px1=iirP(w,x1,U,V,M,Q,R);

subplot(311);
h311=plot(w*0.5/pi,[Ax1 Adl Adu]);
strt=sprintf(strM,"x1(MMSE)");
title(strt);
ylabel("Amplitude");
axis([-0.5 0.5 0.9 1.1]);
grid("on");
subplot(312);
Px1_plot=[Px1 Pdl Pdu]+(w*td)+(pp*pi);
[ax,h1,h2]=plotyy(w(1:(non2-npt))*0.5/pi,   Px1_plot(1:(non2-npt),:)/pi, ...
                  w((non2+npt):end)*0.5/pi, Px1_plot((non2+npt):end,:)/pi);
% Hack to match colours. Is there an easier way with colormap?
h311c=get(h311,"color");
for k=1:3
  set(h2(k),"color",h311c{k});
endfor
% End of hack
axis(ax(1),[-0.5 0.5  0.5+(4*ppr*[-1,1])]);
axis(ax(2),[-0.5 0.5 -0.5+(4*ppr*[-1,1])]);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
subplot(313);
plot(w*0.5/pi,[Tx1 Tdl Tdu]);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([-0.5 0.5 td+(4*tdr*[-1,1])]);
grid("on");
print(strcat(strf,"_mmse_response"),"-dpdflatex");
close

% Plot poles and zeros
showZPplot(x1,U,V,M,Q,R,strt);
print(strcat(strf,"_mmse_pz"),"-dpdflatex");
close

%
% PCLS pass
%
printf("\nPCLS pass 1:\n");
[d1,E,slb_iter,socp_iter,func_iter,feasible] = ...
  iir_slb(@iir_socp_mmse, ...
          x1,xu,xl,dmax,U,V,M,Q,R, ...
          wa,Ad,Adu,Adl,Wa, ...
          ws,Sd,Sdu,Sdl,Ws, ...
          wt,Td,Tdu,Tdl,Wt, ...
          wp,Pd,Pdu,Pdl,Wp, ...
          maxiter,ftol,ctol,verbose)
if feasible == 0 
  error("d1 (pcls) infeasible");
endif

Ad1=iirA(w,d1,U,V,M,Q,R);
Td1=iirT(w,d1,U,V,M,Q,R);
Pd1=iirP(w,d1,U,V,M,Q,R);
subplot(311);
h311=plot(w*0.5/pi,[Ad1 Adl Adu]);
strt=sprintf(strP,"d1(PCLS)");
title(strt);
ylabel("Amplitude");
grid("on");
axis([-0.5 0.5 0.98 1.02]);
subplot(312);
Pplot=[Pd1 Pdl Pdu]+(w*td)+(pp*pi);
[ax,h1,h2]=plotyy(w(1:(non2-npt))*0.5/pi,   Pplot(1:(non2-npt),:)/pi, ...
                  w((non2+npt):end)*0.5/pi, Pplot((non2+npt):end,:)/pi);
% Hack to match colours. Is there an easier way with colormap?
h311c=get(h311,"color");
for k=1:3
  set(h2(k),"color",h311c{k});
endfor
% End of hack
axis(ax(1),[-0.5 0.5  0.5+(0.02*[-1 1])]);
axis(ax(2),[-0.5 0.5 -0.5+(0.02*[-1 1])]); 
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(w*0.5/pi,[Td1 Tdl Tdu]);
axis([-0.5 0.5 td-0.1 td+0.1]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_response"),"-dpdflatex");
close

% Plot poles and zeros
showZPplot(d1,U,V,M,Q,R,strt);
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Specification file
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ftol=%g %% Tolerance on relative coefficient update size\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"Ar=%g %% Amplitude response peak-to-peak ripple\n",Ar);
fprintf(fid,"At=%g %% Amplitude transition response peak-to-peak ripple\n",At);
fprintf(fid,"Wap=%d %% Amplitude response weight\n",Wap);
fprintf(fid,"fpt=%g %% Phase response transition edge\n",fpt);
fprintf(fid,"pr=%g %% Phase response nominal phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase response peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Phase response weight\n",Wpp);
fprintf(fid,"Wpt=%g %% Phase response transition weight\n",Wpt);
fprintf(fid,"ftt=%g %% Group delay response transition edge\n",ftt);
fprintf(fid,"td=%d %% Nominal filter group delay(samples)\n",td);
fprintf(fid,"tdr=%g %% Group delay peak-to-peak ripple(samples)\n",tdr);
fprintf(fid,"Wtp=%g %% Group delay weight\n",Wtp);
fprintf(fid,"Wtt=%g %% Group delay transition weight\n",Wtt);
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

eval(sprintf(["save %s.mat U V M Q R x0 x1 d1 ftol ctol ", ...
 "n w Ad Ar td ftt tdr Pd fpt pp ppr"],strf));

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
