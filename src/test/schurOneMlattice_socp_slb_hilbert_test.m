% schurOneMlattice_socp_slb_hilbert_test.m
% Schur one-multiplier lattice implementation of a Hilbert filter
% with denominator polynomial having coefficients only for z^2 terms
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurOneMlattice_socp_slb_hilbert_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic

maxiter=5000
ftol=1e-4
ctol=ftol/10
verbose=false

%
% Initial filter from tarczynski_hilbert_test.m
%
tarczynski_hilbert_test_N0_coef;
tarczynski_hilbert_test_D0_coef;
R=2;
D0R=zeros(size([N0;0]));
D0R(1:R:end)=D0;
[k0,epsilon0,p0,c0]=tf2schurOneMlattice([N0;0],D0R);

%
% Frequency points
%
% The A and T responses are symmetric in frequency and the P response is
% antisymmetric. Any A and T constraints are duplicated at negative and
% positive frequencies resulting in a reduced rank constraint matrix.
% Avoid this problem by staggering the frequencies.
%
n=400;
nnrng=-(n-2):2:0;
nprng=1:2:(n-1);
w=pi*([nnrng(:);nprng(:)])/n;
non2=floor(n/2);

%
% Hilbert filter specification
%
dBar=0.067;dBat=dBar;Wap=1;Wat=0.1;
td=(length(N0)-1)/2;;
ftt=0.08; % Delay transition band at zero
ntt=floor(ftt*n);
tdr=0.16;Wtp=0.005;Wtt=0;
fpt=0.06; % Phase transition band at zero
npt=floor(fpt*n); 
pp=5;ppr=0.02;Wpp=1;Wpt=0;

% Amplitude constraints
wa=w;
Asqd=ones(n,1);
Asqr=1-(10^(-dBar/10));
Asqt=1-(10^(-dBat/10));
Asqdu=[(1+(Asqr/2))*ones(non2-npt,1); ...
       (1+(Asqt/2))*ones(2*npt,1); ...
       (1+(Asqr/2))*ones(non2-npt,1)];
Asqdl=[(1-(Asqr/2))*ones(non2-npt,1); ...
       (1-(Asqt/2))*ones(2*npt,1); ...
       (1-(Asqr/2))*ones(non2-npt,1)];
Wa=[Wap*ones(non2-npt,1);Wat*ones((2*npt),1);Wap*ones(non2-npt,1)];

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

% dAsqdw constraints
wd=[];
Dd=[];
Ddu=[];
Ddl=[];
Wd=[];

% Constraints on the coefficients
dmax=inf;
rho=1-ftol;
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(size(k0));10*ones(size(c0))];
kc_l=-kc_u;
kc_active=[find((k0)~=0);(Nk+(1:Nc))'];

% Initialise strings
strM=sprintf("Hilbert filter %%s:Wap=%g,ftt=%g,td=%g,Wtp=%g,fpt=%g,Wpp=%g", ...
             Wap,ftt,td,Wtp,fpt,Wpp);
strP=sprintf(["Hilbert filter %%s:", ...
 "dBar=%g,Wap=%g,td=%g,ftt=%g,tdr=%g,Wtp=%g,fpt=%g,ppr=%g,Wpp=%g"], ...
             dBar,Wap,td,ftt,tdr,Wtp,fpt,ppr,Wpp);

% Calculate the initial response
Asq0=schurOneMlatticeAsq(w,k0,epsilon0,p0,c0);
P0=schurOneMlatticeP(w,k0,epsilon0,p0,c0);
T0=schurOneMlatticeT(w,k0,epsilon0,p0,c0);

% Plot the initial response and constraints
subplot(311);
plot(w*0.5/pi,[Asq0 Asqd Asqdl Asqdu]);
strt=sprintf("Hilbert filter initial response : td=%g,fpt=%g",td,fpt);
title(strt);
ylabel("Amplitude");
axis([-0.5 0.5 0.6 1.2 ]);
grid("on");
subplot(312);
plot(w*0.5/pi,([P0 Pd Pdl Pdu]+(w*td)+(pp*pi))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([-0.5 0.5 -1 1]);
grid("on");
subplot(313);
plot(w*0.5/pi,[T0 Td Tdl Tdu]);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([-0.5 0.5 0 10*td]);
grid("on");
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

%
% SOCP MMSE pass
%
printf("\nMMSE pass 1:\n");
[k1p,c1p,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_socp_mmse([], ...
                            k0,epsilon0,p0,c0, ...
                            kc_u,kc_l,kc_active,dmax, ...
                            wa,Asqd,Asqdu,Asqdl,Wa, ...
                            wt,Td,Tdu,Tdl,Wt, ...
                            wp,Pd,Pdu,Pdl,Wp, ...
                            wd,Dd,Ddu,Ddl,Wd, ...
                            maxiter,ftol,ctol,verbose);
if feasible == 0
  error("x1(mmse) infeasible");
endif

% Recalculate epsilon1, p1 and c1
[N1,D1]=schurOneMlattice2tf(k1p,epsilon0,p0,c1p);
[k1,epsilon1,p1,c1]=tf2schurOneMlattice(N1,D1);
Asq1=schurOneMlatticeAsq(wa,k1,epsilon1,p1,c1);
P1=schurOneMlatticeP(wp,k1,epsilon1,p1,c1);
T1=schurOneMlatticeT(wt,k1,epsilon1,p1,c1);

% Plot poles and zeros
[N1,D1]=schurOneMlattice2tf(k1,epsilon1,p1,c1);
subplot(111);
zplane(qroots(N1),qroots(D1));
title(strt);
print(strcat(strf,"_mmse_pz"),"-dpdflatex");
close

% Plot the MMSE response
subplot(311);
h311=plot(w*0.5/pi,[Asq1 Asqdl Asqdu]);
strt=sprintf(strM,"k1(MMSE)");
title(strt);
ylabel("Amplitude");
axis([-0.5 0.5 0.9 1.1]);
grid("on");
subplot(312);
P1_plot=[P1 Pdl Pdu]+(w*td)+(pp*pi);
[ax,h1,h2]=plotyy(w(1:(non2-npt))*0.5/pi,   P1_plot(1:(non2-npt),:)/pi, ...
                  w((non2+npt):end)*0.5/pi, P1_plot((non2+npt):end,:)/pi);
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
plot(w*0.5/pi,[T1 Tdl Tdu]);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([-0.5 0.5 td+(4*tdr*[-1,1])]);
grid("on");
print(strcat(strf,"_mmse_response"),"-dpdflatex");
close

%
% PCLS pass
%
printf("\nPCLS pass:\n");
[k2p,c2p,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_slb(@schurOneMlattice_socp_mmse, ...
                       k1,epsilon1,p1,c1, ...
                       kc_u,kc_l,kc_active,dmax, ...
                       wa,Asqd,Asqdu,Asqdl,Wa, ...
                       wt,Td,Tdu,Tdl,Wt, ...
                       wp,Pd,Pdu,Pdl,Wp, ...
                       wd,Dd,Ddu,Ddl,Wd, ...
                       maxiter,ftol,ctol,verbose);
if feasible == 0 
  error("k2(pcls) infeasible");
endif

% Recalculate epsilon2, p2 and c2
[N2,D2]=schurOneMlattice2tf(k2p,epsilon1,p1,c2p);
[k2,epsilon2,p2,c2]=tf2schurOneMlattice(N2,D2);
Asq2=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
P2=schurOneMlatticeP(wp,k2,epsilon2,p2,c2);
T2=schurOneMlatticeT(wt,k2,epsilon2,p2,c2);

% Plot poles and zeros
[N2,D2]=schurOneMlattice2tf(k2,epsilon2,p2,c2);
subplot(111);
zplane(qroots(N2),qroots(D2));
title(strt);
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Check transfer function
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Asq2)) > 100*eps
  error("max(abs((abs(HH).^2)-Asq2)) > 100*eps");
endif

% Plot the PCLS response
subplot(311);
h311=plot(w*0.5/pi,[Asq2 Asqdl Asqdu]);
strt=sprintf(strP,"k2(PCLS)");
title(strt);
ylabel("Amplitude");
grid("on");
axis([-0.5 0.5 0.98 1.02]);
subplot(312);
Pplot=[P2 Pdl Pdu]+(w*td)+(pp*pi);
[ax,h1,h2]=plotyy(w(1:(non2-npt))*0.5/pi,   Pplot(1:(non2-npt),:)/pi, ...
                  w((non2+npt):end)*0.5/pi, Pplot((non2+npt):end,:)/pi);
% Hack to match colours. Is there an easier way with colormap?
h311c=get(h311,"color");
for k=1:3
  set(h2(k),"color",h311c{k});
endfor
% End of hack
axis(ax(1),[-0.5 0.5  0.5+(0.02*[-1,1])]);
axis(ax(2),[-0.5 0.5 -0.5+(0.02*[-1,1])]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(w*0.5/pi,[T2 Tdl Tdu]);
axis([-0.5 0.5 td+(tdr*[-1,1])]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_response"),"-dpdflatex");
close

% Specification file
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"dmax=%g %% Constraint on coefficient update size\n",dmax);
fprintf(fid,"ftol=%g %% Tolerance on relative coefficient update size\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"dBar=%g %% Amplitude response peak-to-peak ripple\n",dBar);
fprintf(fid,"dBat=%g %% Amplitude transition peak-to-peak ripple\n",dBat);
fprintf(fid,"Wap=%d %% Amplitude response weight\n",Wap);
fprintf(fid,"Wat=%d %% Amplitude transition weight\n",Wat);
fprintf(fid,"fpt=%g %% Phase response transition edge\n",fpt);
fprintf(fid,"pp=%g %% Phase response nominal phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase response peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Phase response weight\n",Wpp);
fprintf(fid,"Wpt=%g %% Phase response transition weight\n",Wpt);
fprintf(fid,"ftt=%g %% Group delay response transition edge\n",ftt);
fprintf(fid,"td=%g %% Nominal filter group delay(samples)\n",td);
fprintf(fid,"tdr=%g %% Group delay peak-to-peak ripple(samples)\n",tdr);
fprintf(fid,"Wtp=%g %% Group delay weight\n",Wtp);
fprintf(fid,"Wtt=%g %% Group delay transition weight\n",Wtt);
fclose(fid);

% Coefficients
print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(epsilon2,"epsilon2","%2d");
print_polynomial(epsilon2,"epsilon2",strcat(strf,"_epsilon2_coef.m"),"%2d");
print_polynomial(p2,"p2");
print_polynomial(p2,"p2",strcat(strf,"_p2_coef.m"));
print_polynomial(c2,"c2");
print_polynomial(c2,"c2",strcat(strf,"_c2_coef.m"));

print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

eval(sprintf(["save %s.mat n dmax ftol ctol dBar dBat Wap Wat ", ...
 "fpt pp ppr Wpp Wpt ftt td tdr Wtp Wtt k2 epsilon2 p2 c2 N2 D2"], strf));

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
