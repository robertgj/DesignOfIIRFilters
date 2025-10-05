% schurOneMlattice_socp_slb_bandpass_differentiator_test.m
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="schurOneMlattice_socp_slb_bandpass_differentiator_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-5
ctol=ftol/100
maxiter=20000
verbose=false

% Initial filter 
tarczynski_bandpass_differentiator_test_D0_coef;
tarczynski_bandpass_differentiator_test_N0_coef;

% Correction filter order
nN=length(N0)-1;

% Convert transfer function to tapped one-multiplier Schur lattice
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(N0,D0);
k0=k0(:);epsilon0=epsilon0(:);p0=p0(:);c0=c0(:);
p_ones=ones(size(k0));

% Band-pass differentiator filter specification
fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25,
Arp=0.02,Ars=0.02,Wasl=0.1,Watl=0.001,Wap=0.1,Watu=0.001,Wasu=0.1
fppl=0.1,fppu=0.2,pp=3.5,ppr=0.002,Wpp=0.5
ftpl=0.1,ftpu=0.2,tp=12,tpr=0.2,Wtp=0.02
fdpl=0.1,fdpu=0.2,dpr=0.62,Wdp=0.01

% Frequency points
n=1000;
f=0.5*(1:(n-1))'/n;
w=2*pi*f;
nasl=ceil(n*fasl/0.5);
napl=floor(n*fapl/0.5);
napu=ceil(n*fapu/0.5);
nasu=floor(n*fasu/0.5);
ntpl=floor(n*ftpl/0.5);
ntpu=ceil(n*ftpu/0.5);
nppl=floor(n*fppl/0.5);
nppu=ceil(n*fppu/0.5);
ndpl=floor(n*fdpl/0.5);
ndpu=ceil(n*fdpu/0.5);

% Pass and transition band amplitudes
wa=w;
Azsqm1=2*sin(wa);
Azsqm1sq=Azsqm1.^2;
Ad=[zeros(napl-1,1);w(napl:napu)/2;zeros(n-1-napu,1)];
Asqd=Ad.^2;
Adu=[(Ars/2)*ones(nasl-1,1);(w(nasl:nasu)/2)+(Arp/2);(Ars/2)*ones(n-1-nasu,1)];
Adl=[zeros(napl-1,1);(w(napl:napu)/2)-(Arp/2);zeros(n-1-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-1-nasu+1,1)];
% Sanity check
nchka=[1,nasl-1,nasl,nasl+1,napl-1,napl,napl+1,napu-1,napu,napu+1, ...
       nasu-1,nasu,nasu+1,n-1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g",0.5*wa(nchka)'/pi);printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Phase response
wp=w(nppl:nppu);
Pzsqm1=(pi/2)-wp;
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% Group delay
wt=w(ntpl:ntpu);
Tzsqm1=1;
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% dAsqdw response
wd=w(ndpl:ndpu);
Dd=Ad(ndpl:ndpu);
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);
Wd=Wdp*ones(size(wd));
Cd=(Dd-(2*Asqd(ndpl:ndpu).*cot(wa(ndpl:ndpu))))./Azsqm1sq(ndpl:ndpu);
cpr=dpr./Azsqm1sq(ndpl:ndpu);
Cdu=Cd+(cpr/2);
Cdl=Cd-(cpr/2);

% Coefficient constraints
dmax=0.1; % For compatibility with SQP
rho=127/128;
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(Nk,1);10*ones(Nc,1)];
kc_l=-kc_u;
kc_active=[find((k0)~=0);(Nk+(1:Nc))'];

% Calculate the initial response
Asq0c=schurOneMlatticeAsq(wa,k0,epsilon0,p0,c0);
A0c=sqrt(Asq0c);
A0=A0c.*Azsqm1;
P0c=schurOneMlatticeP(wp,k0,epsilon0,p0,c0);
P0=P0c+Pzsqm1;
T0c=schurOneMlatticeT(wt,k0,epsilon0,p0,c0);
T0=T0c+Tzsqm1;
dAsqdw0c=schurOneMlatticedAsqdw(wa,k0,epsilon0,p0,c0);
dAsqdw0=(dAsqdw0c.*Azsqm1sq) + (((Ad./Azsqm1).^2).*(4*sin(2*wa)));

%
% PCLS pass
%
printf("\nPCLS pass :\n");
feasible=false;
[k2,c2,slb_iter,opt_iter,func_iter,feasible] = schurOneMlattice_slb ...
  (@schurOneMlattice_socp_mmse, ...
   k0,epsilon0,p_ones,c0,kc_u,kc_l,kc_active,dmax, ...
   wa,(Ad./Azsqm1).^2,(Adu./Azsqm1).^2,(Adl./Azsqm1).^2,Wa, ...
   wt,Td-Tzsqm1,Tdu-Tzsqm1,Tdl-Tzsqm1,Wt, ...
   wp,Pd-Pzsqm1,Pdu-Pzsqm1,Pdl-Pzsqm1,Wp, ...
   wd,Cd,Cdu,Cdl,Wd, ...
   maxiter,ftol,ctol,verbose);
if feasible == 0
  error("k2 (PCLS) infeasible");
endif

% Recalculate epsilon, p and c
printf("\nBefore recalculating epsilon and c:\n");
print_polynomial(epsilon0,"epsilon0");
print_polynomial(c2,"c2");
printf("\n");
[N1,D1]=schurOneMlattice2tf(k2,epsilon0,p0,c2);
[k2r,epsilon2,p2,c2]=tf2schurOneMlattice(N1,D1);
k2r=k2r(:);epsilon2=epsilon2(:);p2=p2(:);c2=c2(:);
if max(abs(k2-k2r))>1000*eps
  error("max(abs(k2-k2r))(%g*eps)>1000*eps",max(abs(k2-k2r))/eps);
endif

% Pole-zero plot
zplane(qroots(conv(N1(:),[1;0;-1])),qroots(D1(:)));
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Calculate the overall response
Asq1c=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
A1c=sqrt(Asq1c);
A1=A1c.*Azsqm1;
P1c=schurOneMlatticeP(wp,k2,epsilon2,p2,c2);
P1=P1c+Pzsqm1;
T1c=schurOneMlatticeT(wt,k2,epsilon2,p2,c2);
T1=T1c+Tzsqm1;
dAsqdw1c=schurOneMlatticedAsqdw(wa,k2,epsilon2,p2,c2);
dAsqdw1=(dAsqdw1c.*Azsqm1sq) + (((Ad./Azsqm1).^2).*(4*sin(2*wa)));

% Check amplitude of transfer function
HH=freqz(N1,D1,wa);
if max(abs((abs(HH).^2)-Asq1c)) > 1000*eps
  error("max(abs((abs(HH).^2)-Asq1c))(%g*eps) > 1000*eps", ...
        max(abs((abs(HH).^2)-Asq1c))/eps);
endif

% Plot response
subplot(311);
plot(wa*0.5/pi,[A1,Adl,Adu]);
axis([0 0.5 0 1]);
grid("on");
strP=sprintf(["Bandpass differentiator response : ", ...
 "fasl=%g,fapl=%g,fapu=%g,fasu=%g,Arp=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"], ...
             fasl,fapl,fapu,fasu,Arp,Ars,tp,tpr,ppr);
title(strP);
ylabel("Amplitude");
subplot(312);
plot(wp*0.5/pi,mod((unwrap([P1 Pdl Pdu])+(wp*tp))/pi,2));
axis([0 0.5 mod(pp,2)+ppr*[-1,1]]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
subplot(313);
plot(wt*0.5/pi,[T1 Tdl Tdu]);
axis([0 0.5 tp+tpr*[-1,1]]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot response errors
subplot(311);
rasl=1:nasl;
raplu=napl:napu;
rasu=nasu:(n-1);
ha=plot(wa(rasl)*0.5/pi,A1(rasl)-Ad(rasl), ...
        wa(rasl)*0.5/pi,Adl(rasl)-Ad(rasl), ...
        wa(rasl)*0.5/pi,Adu(rasl)-Ad(rasl), ...
        wa(raplu)*0.5/pi,A1(raplu)-Ad(raplu), ...
        wa(raplu)*0.5/pi,Adl(raplu)-Ad(raplu), ...
        wa(raplu)*0.5/pi,Adu(raplu)-Ad(raplu), ...
        wa(rasu)*0.5/pi,A1(rasu)-Ad(rasu), ...
        wa(rasu)*0.5/pi,Adl(rasu)-Ad(rasu), ...
        wa(rasu)*0.5/pi,Adu(rasu)-Ad(rasu));
% Set line style and copy line colour
hac=cell(3);
hac{1}=get(ha(1),"color");
hac{2}=get(ha(2),"color");
hac{3}=get(ha(3),"color");
for c=1:3
  set(ha(c+3),"color",hac{c});
  set(ha(c+6),"color",hac{c});
endfor
axis([0 0.5 Ars*[-1,1]]);
strP=sprintf("Differentiator PCLS");
title(strP);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wp*0.5/pi,mod((unwrap([P1 Pdl Pdu])+(wp*tp))/pi,2));
axis([0 0.5 mod(pp,2)+(ppr*[-1,1])]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[T1 Tdl Tdu]);
axis([0 0.5 tp+(tpr*[-1,1])]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_error"),"-dpdflatex");
close

% Plot correction filter dAsqdw response
ax=plot(wd*0.5/pi,[dAsqdw1c(ndpl:ndpu),Cdl,Cdu,Cd]);
title("Differentiator PCLS correction filter dAsqdw response");
axis([fdpl fdpu 0.4*[-1,1]])
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
legend("dAsqdwc","Cd","Cdl","Cdu");
legend("location","southeast")
legend("boxoff")
legend("left")
print(strcat(strf,"_correction"),"-dpdflatex");
close

% Plot differentiator filter dAsqdw response
ax=plot(wd*0.5/pi,[dAsqdw1(ndpl:ndpu),Ddl,Ddu,Dd]);
title("Differentiator PCLS filter dAsqdw response");
axis([fdpl fdpu 0 0.8])
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
legend("dAsqdw","Dd","Ddl","Ddu");
legend("location","southeast")
legend("boxoff")
legend("left")
print(strcat(strf,"_dAsqdw"),"-dpdflatex");
close

% Save results
print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(epsilon2,"epsilon2");
print_polynomial(epsilon2,"epsilon2",strcat(strf,"_epsilon2_coef.m"));
print_polynomial(p2,"p2");
print_polynomial(p2,"p2",strcat(strf,"_p2_coef.m"));
print_polynomial(c2,"c2");
print_polynomial(c2,"c2",strcat(strf,"_c2_coef.m"));

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
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapl=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Watl=%g %% Amplitude lower transition band weight\n",Watl);
fprintf(fid,"Watu=%g %% Amplitude upper transition band weight\n",Watu);
fprintf(fid,"Ars=%g %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Wasl=%g %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Amplitude upper stop band weight\n",Wasu);
fprintf(fid,"fppl=%g %% Phase pass band lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Phase pass band upper edge\n",fppu);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"fdpl=%g %% dAsqdw pass band lower edge\n",fdpl);
fprintf(fid,"fdpu=%g %% dAsqdw pass band upper edge\n",fdpu);
fprintf(fid,"dpr=%g %% dAsqdw pass band peak-to-peak ripple\n",dpr);
fprintf(fid,"Wdp=%g %% dAsqdw pass band weight\n",Wdp);
fclose(fid);

eval(strcat(sprintf("save %s.mat ftol ctol n ",strf), ...
            " fasl fapl fapu fasu Arp Ars Wasl Watl Wap Watu Wasu ", ...
            " fppl fppu pp ppr Wpp ftpl ftpu tp tpr Wtp fdpl fdpu dpr Wdp ", ...
            " N0 D0 k0 epsilon0 p0 c0 k2 epsilon2 p2 c2 N1 D1"));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
