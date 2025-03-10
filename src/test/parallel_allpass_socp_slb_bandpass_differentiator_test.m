% parallel_allpass_socp_slb_bandpass_differentiator_test.m
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="parallel_allpass_socp_slb_bandpass_differentiator_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=5000
ftol=1e-4
ctol=ftol/100
verbose=false

% Initial coefficients
tarczynski_parallel_allpass_bandpass_differentiator_test_Da0_coef;
tarczynski_parallel_allpass_bandpass_differentiator_test_Db0_coef;
K=1;
[a0,Va,Qa]=tf2a(Da0);Ra=1;
[b0,Vb,Qb]=tf2a(Db0);Rb=1;
ab0=[a0(:);b0(:)];
ma=length(a0);
mb=length(b0);
printf("Initial ab0=[");printf("%g ",ab0');printf("]'\n");

% Band-pass differentiator filter specification
polyphase=false;
difference=true;
if difference, mm=-1; else, mm=1; endif

fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25
Arsl=0.04;Arp=0.04,Arsu=0.04
Wasl=10,Watl=0.01,Wap=10,Watu=0.05,Wasu=20
fppl=0.1,fppu=0.2,pp=0.5,ppr=0.0008,Wpp=1
ftpl=0.1,ftpu=0.2,tp=10,tpr=0.2,Wtp=0.5
  
%
% Frequency vectors
%
n=1000;
f=0.5*(1:(n-1))'/n;
w=2*pi*f;

% Desired amplitude response
nasl=ceil(n*fasl/0.5);
napl=floor(n*fapl/0.5);
napu=ceil(n*fapu/0.5);
nasu=floor(n*fasu/0.5);
wa=w;
Azsqm1=2*sin(wa);
Ad=[zeros(napl-1,1);w(napl:napu)/2;zeros(n-1-napu,1)];
Adu=[(Arsl/2)*ones(nasl-1,1);(w(nasl:nasu)/2)+(Arp/2);(Arsu/2)*ones(n-1-nasu,1)];
Adl=[zeros(napl-1,1);(w(napl:napu)/2)-(Arp/2);zeros(n-1-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-1-nasu+1,1)];
% Sanity check
nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napl+1,napu-1,napu,napu+1, ...
       nasu-1,nasu,nasu+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Desired pass-band phase response
nppl=floor(n*fppl/0.5);
nppu=ceil(n*fppu/0.5);
wp=w(nppl:nppu);
Pzsqm1=(0.5*pi)-wp;
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% Desired pass-band group delay response
ntpl=floor(n*ftpl/0.5);
ntpu=ceil(n*ftpu/0.5);
wt=w(ntpl:ntpu);
Tzsqm1=1;
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% Linear constraints
rho=0.99;
[al,au]=aConstraints(Va,Qa,rho);
[bl,bu]=aConstraints(Vb,Qb,rho);
abl=[al(:);bl(:)];
abu=[au(:);bu(:)];

% Find initial response
Asqab0=parallel_allpassAsq(wa,ab0,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
A0c=sqrt(Asqab0);
A0=A0c.*Azsqm1;
Pab0c=parallel_allpassP(wp,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
P0=Pab0c+Pzsqm1;
Tab0c=parallel_allpassT(wt,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
T0=Tab0c+Tzsqm1;

% Plot initial response
subplot(311);
plot(wa*0.5/pi,[A0 Ad Adl Adu]);
ylabel("Amplitude");
axis([0 0.5 0 1]);
grid("on");
strt=sprintf("Initial parallel allpass : ma=%d,mb=%d", ma,mb);
title(strt);
subplot(312);
plot(wp*0.5/pi,([P0 Pd Pdl Pdu]+(wp*tp))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 pp+2*ppr*[-1 1]]);
grid("on");
subplot(313);
plot(wt*0.5/pi,[T0 Td Tdl Tdu]);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 tp+2*tpr*[-1,1]]);
grid("on");
print(strcat(strf,"_ab0"),"-dpdflatex");
close

%
% PCLS pass
%
printf("\n PCLS pass \n");
try
  feasible=false;
  [ab1,slb_iter,opt_iter,func_iter,feasible] = parallel_allpass_slb ...
    (@parallel_allpass_socp_mmse,ab0,abu,abl, ...
     K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
     wa,(Ad./Azsqm1).^2,(Adu./Azsqm1).^2,(Adl./Azsqm1).^2,Wa, ...
     wt,Td-Tzsqm1,Tdu-Tzsqm1,Tdl-Tzsqm1,Wt, ...
     wp,Pd-Pzsqm1,Pdu-Pzsqm1,Pdl-Pzsqm1,Wp,maxiter,ftol,ctol,verbose);
catch
  warning("Caught parallel_allpass_slb");
end_try_catch
if ~feasible
  error("ab1(PCLS) infeasible");
endif

a1=ab1(1:ma);
b1=ab1((ma+1):end);

% Find PCLS response
Asqab1=parallel_allpassAsq(wa,ab1,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
A1=sqrt(Asqab1).*Azsqm1;
Pab1=parallel_allpassP(wp,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
P1=Pab1+Pzsqm1;
Tab1=parallel_allpassT(wt,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
T1=Tab1+Tzsqm1;

% Plot response
subplot(311);
plot(wa*0.5/pi,[A1 Adl Adu]);
ylabel("Amplitude");
axis([0 0.5 0 1]);
grid("on");
strt=sprintf(["Parallel allpass : ", ...
 "ma=%d,mb=%d,Arsl=%4.2f,Arp=%4.2f,Arsu=%4.1f,tp=%g,tpr=%g"],
             ma,mb,Arsl,Arp,Arsu,tp,tpr);
title(strt);
subplot(312);
plot(wp*0.5/pi,([P1 Pdl Pdu]+(wp*tp))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 pp+ppr*[-1,1]]);
grid("on");
subplot(313);
plot(wt*0.5/pi,[T1 Tdl Tdu]);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 tp+tpr*[-1,1]]);
grid("on");
print(strcat(strf,"_ab1"),"-dpdflatex");
close

% Plot response error
subplot(311);
rasl=1:nasl;
raplu=napl:napu;
rasu=nasu:(n-1);
plot(wa(rasl)*0.5/pi,[A1(rasl),Adl(rasl),Adu(rasl)]-Ad(rasl), ...
     wa(raplu)*0.5/pi,[A1(raplu),Adl(raplu),Adu(raplu)]-Ad(raplu), ...
     wa(rasu)*0.5/pi,[A1(rasu),Adl(rasu),Adu(rasu)]-Ad(rasu));
axis([0 0.5 max([Arsl,Arsu])*[-1,1]]);
ylabel("Amplitude");
grid("on");
strt=sprintf(["Parallel allpass error : ", ...
 "ma=%d,mb=%d,Arsl=%4.2f,Arp=%4.2f,Arsu=%4.1f,tp=%g,tpr=%g"],
             ma,mb,Arsl,Arp,Arsu,tp,tpr);
title(strt);
subplot(312);
plot(wp*0.5/pi,([P1 Pdl Pdu]-Pd)/pi);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 ppr*[-1,1]]);
grid("on");
subplot(313);
plot(wt*0.5/pi,[T1 Tdl Tdu]-Td);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 tpr*[-1,1]]);
grid("on");
print(strcat(strf,"_ab1error"),"-dpdflatex");
close

% Find overall filter polynomials
[~,Da1]=a2tf(a1,Va,Qa,Ra);
Da1=Da1(:);
[~,Db1]=a2tf(b1,Vb,Qb,Rb);
Db1=Db1(:);
Nab1=(conv(flipud(Da1),Db1)+(mm*conv(flipud(Db1),Da1)))/2;
Dab1=conv(Da1,Db1);

% Plot poles and zeros
subplot(111);
zplane(qroots(flipud(Da1)),qroots(Da1));
title("Allpass filter A");
print(strcat(strf,"_a1pz"),"-dpdflatex");
close
subplot(111);
zplane(qroots(flipud(Db1)),qroots(Db1));
title("Allpass filter B");
print(strcat(strf,"_b1pz"),"-dpdflatex");
close
subplot(111);
zplane(qroots(conv(Nab1(:),[1;0;-1])),qroots(Dab1(:)));
title("Parallel allpass filters with correction");
print(strcat(strf,"_ab1pz"),"-dpdflatex");
close

% Plot phase response of parallel filters
Ha=freqz(flipud(Da1),Da1,w);
Hb=freqz(flipud(Db1),Db1,w);
plot(w*0.5/pi,(unwrap(arg(Ha))+(w*(tp-Tzsqm1)))/pi, ...
     w*0.5/pi,(unwrap(arg(Hb))+(w*(tp-Tzsqm1)))/pi);
strt=sprintf(["Phase responses of correction filters adjusted for linear phase : ", ...
 "ma=%d,mb=%d,tp=%g"],ma,mb,tp);
title(strt);
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
legend("Filter A","Filter B");
legend("location","east");
legend("boxoff");
grid("on");
print(strcat(strf,"_ab1phase"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"polyphase=%d %% Use polyphase combination\n",polyphase);
fprintf(fid,"difference=%d %% Use difference combination\n",difference);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ma=%d %% Allpass correction filter A denominator order\n",ma);
fprintf(fid,"Va=%d %% Allpass correction filter A no. of real poles\n",Va);
fprintf(fid,"Qa=%d %% Allpass correction filter A no. of complex poles\n",Qa);
fprintf(fid,"Ra=%d %% Allpass correction filter A decimation\n",Ra);
fprintf(fid,"mb=%d %% Allpass correction filter B denominator order\n",mb);
fprintf(fid,"Vb=%d %% Allpass correction filter B no. of real poles\n",Vb);
fprintf(fid,"Qb=%d %% Allpass correction filter B no. of complex poles\n",Qb);
fprintf(fid,"Rb=%d %% Allpass correction filter B decimation\n",Rb);
fprintf(fid,"fasl=%g %% Lower stop band amplitude response edge\n",fasl);
fprintf(fid,"Arsl=%f %% Lower stop band amplitude response ripple\n",Arsl);
fprintf(fid,"Wasl=%d %% Lower stop band amplitude response weight\n",Wasl);
fprintf(fid,"Watl=%d %% Lower transition band amplitude response weight\n",Watl);
fprintf(fid,"fapl=%g %% Lower pass band amplitude response edge\n",fapl);
fprintf(fid,"fapu=%g %% Upper pass band amplitude response edge\n",fapu);
fprintf(fid,"Arp=%f %% Pass band amplitude response ripple\n",Arp);
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Watu=%d %% Upper transition band amplitude response weight\n",Watu);
fprintf(fid,"fasu=%g %% Upper stop band amplitude response edge\n",fasu);
fprintf(fid,"Arsu=%f %% Upper stop band amplitude response ripple\n",Arsu);
fprintf(fid,"Wasu=%d %% Upper stop band amplitude response weight\n",Wasu);
fprintf(fid,"tp=%g %% Pass band nominal group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band nominal group delay ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band group delay response weight\n",Wtp);
fprintf(fid,"pp=%g %% Pass band nominal phase\n",pp);
fprintf(fid,"ppr=%g %% Pass band phase peak-to-peak-ripple\n",ppr);
fprintf(fid,"Wpp=%d %% Pass band phase response weight\n",Wpp);
fclose(fid);

% Save results
print_allpass_pole(a1,Va,Qa,Ra,"a1");
print_allpass_pole(a1,Va,Qa,Ra,"a1",strcat(strf,"_a1_coef.m"));
print_allpass_pole(b1,Vb,Qb,Rb,"b1");
print_allpass_pole(b1,Vb,Qb,Rb,"b1",strcat(strf,"_b1_coef.m"));
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));
print_polynomial(Db1,"Db1");
print_polynomial(Db1,"Db1",strcat(strf,"_Db1_coef.m"));
print_polynomial(Nab1,"Nab1");
print_polynomial(Nab1,"Nab1",strcat(strf,"_Nab1_coef.m"));
print_polynomial(Dab1,"Dab1");
print_polynomial(Dab1,"Dab1",strcat(strf,"_Dab1_coef.m"));

eval(sprintf(["save %s.mat ftol ctol  polyphase difference rho n ", ...
 "ma mb Va Qa Ra Vb Qb Rb Da0 Db0 ab0 ", ...
 "fasl Arsl Wasl Watl fapl fapu Arp Wap Watu fasu Arsu Wasu ", ...
 "tp tpr Wtp pp ppr Wpp ab1 Da1 Db1 Nab1 Dab1"],strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
