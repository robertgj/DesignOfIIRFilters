% parallel_allpass_socp_slb_lowpass_differentiator_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

% I cannot use the spectral factors of
% iir_sqp_slb_lowpass_differentiator_alternate_test.m
% because the numerator polynomial is not symmetric.
% That filter has five pairs of conjugate poles and zeros,
% one real zero and one real pole. In other words, the direct-form
% imlementation has 23 multipliers. The similar parallel-allpass filter
% has parallel order 11 and 12 allpass filters.

test_common;

strf="parallel_allpass_socp_slb_lowpass_differentiator_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol=1e-5
ctol=tol/10
verbose=false
maxiter=5000

% Initial coefficients
tarczynski_parallel_allpass_lowpass_differentiator_test_Da0_coef;
tarczynski_parallel_allpass_lowpass_differentiator_test_Db0_coef;
[a0,Va,Qa]=tf2a(Da0);Ra=1;
[b0,Vb,Qb]=tf2a(Db0);Rb=1;
ab0=[a0(:);b0(:)];
ma=length(a0);
mb=length(b0);
K=1;
printf("Initial ab0=[");printf("%g ",ab0');printf("]'\n");

% Low-pass differentiator filter specification
polyphase=false;
difference=false;
fap=0.3;fas=0.4;
Arp=0.1;Art=0.1;Ars=0.1;Wap=1;Wat=0.01;Was=2;
tp=((Ra*ma)+(Rb*mb)+1)/2;tpr=0.2;Wtp=0.5;
pp=0.5;ppr=0.002;Wpp=0.05;
rho=0.99;

%
% Frequency vectors
%
n=1000;
w=(1:(n-1))'*pi/n;
nap=ceil(n*fap/0.5);
nas=floor(n*fas/0.5);

% Desired magnitude response
wa=w;
Azm1=(2*sin(wa/2)); % Response of the correction filter (1-z^{-1})
if 1
  Ad=[wa(1:nap)/2;zeros(n-nap-1,1)];
else
  Ad=[w(1:nap)/2; (w(nap)/2)*((nas-nap-1):-1:1)'/(nas-nap-1);zeros(n-nas,1)];
endif
Adu=[wa(1:nap)/2; (wa(nap)/2)*ones(nas-nap-1,1);zeros(n-nas,1)]+ ...
    [(Arp/2)*ones(nap,1); (Art/2)*ones((nas-nap-1),1);zeros(n-nas,1)] + ...
    [zeros(nas-1,1);(Ars/2)*ones(n-nas,1)];
Adl=[((wa(1:nap)/2)-(Arp/2));zeros(n-nap-1,1)];
Adl(find(Adl<=0))=0;
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas,1)];

% Desired pass-band phase response
npp=nap;
wp=w(1:npp);
Pzm1=(pi/2)-(wp/2);
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% Desired pass-band group delay response
ntp=nap;
wt=w(1:ntp);
Tzm1=0.5*ones(ntp,1);
Td=tp*ones(ntp,1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(ntp,1);

% Linear constraints
[al,au]=aConstraints(Va,Qa,rho);
[bl,bu]=aConstraints(Vb,Qb,rho);
abl=[al(:);bl(:)];
abu=[au(:);bu(:)];

% Find initial response
Asqab0=parallel_allpassAsq(wa,ab0,1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
A0c=sqrt(Asqab0);
A0=A0c.*Azm1;
Pab0c=parallel_allpassP(wp,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
P0=Pab0c+Pzm1;
Tab0c=parallel_allpassT(wt,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
T0=Tab0c+Tzm1;

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
     wa,(Ad./Azm1).^2,(Adu./Azm1).^2,(Adl./Azm1).^2,Wa, ...
     wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
     wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp,maxiter,tol,ctol,verbose);
catch
  warning("Caught parallel_allpass_slb");
end_try_catch
if ~feasible
  error("ab1(PCLS) infeasible");
endif

% Find overall filter polynomials
[Na1,Da1]=a2tf(ab1(1:ma),Va,Qa,Ra);
Da1=Da1(:);
[Nb1,Db1]=a2tf(ab1((ma+1):end),Vb,Qb,Rb);
Db1=Db1(:);
Nab1=(conv(flipud(Da1),Db1)+conv(flipud(Db1),Da1))/2;
Dab1=conv(Da1,Db1);

% Find response
Asqab1=parallel_allpassAsq(wa,ab1,1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
A1=sqrt(Asqab1).*Azm1;
Pab1=parallel_allpassP(wp,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
P1=Pab1+Pzm1;
Tab1=parallel_allpassT(wt,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
T1=Tab1+Tzm1;

% Plot correction filter response
subplot(311);
plot(wa*0.5/pi,sqrt(Asqab1));
ylabel("Amplitude");
axis([0 0.5 0 1]);
grid("on");
strt=sprintf("Parallel allpass correction : \
 ma=%d,mb=%d,Arp=%4.2f,Ars=%4.1f,tp=%g,tpr=%g",
             ma,mb,Arp,Ars,tp,tpr);
title(strt);
subplot(312);
plot(wp*0.5/pi,(Pab1+(wp*(tp-0.5)))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5]);
grid("on");
subplot(313);
plot(wt*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5]);
grid("on");
print(strcat(strf,"_ab1correction"),"-dpdflatex");
close

% Plot response
subplot(311);
plot(wa*0.5/pi,[A1 Adl Adu]);
ylabel("Amplitude");
axis([0 0.5 0 1]);
grid("on");
strt=sprintf("Parallel allpass : ma=%d,mb=%d,Arp=%4.2f,Ars=%4.1f,tp=%g,tpr=%g",
             ma,mb,Arp,Ars,tp,tpr);
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
axis([0 0.5 tp-tpr tp+tpr]);
grid("on");
print(strcat(strf,"_ab1"),"-dpdflatex");
close

% Plot error response
subplot(311);
[ax,ha,hs]=plotyy(wa(1:nap)*0.5/pi, ...
                  ([A1(1:nap) Adl(1:nap) Adu(1:nap)]-Ad(1:nap)), ...
                  wa(nas:end)*0.5/pi, ...
                  ([A1(nas:end) Adl(nas:end) Adu(nas:end)]-Ad(nas:end)));
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 -0.1 0.1]);
axis(ax(2),[0 0.5 -0.1 0.1]);
ylabel("Amplitude");
grid("on");
strt=sprintf("Parallel allpass error : \
ma=%d,mb=%d,Arp=%4.2f,Ars=%4.1f,tp=%g,tpr=%g",
             ma,mb,Arp,Ars,tp,tpr);
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
axis([0 0.5 -tpr tpr]);
grid("on");
print(strcat(strf,"_ab1error"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(qroots(Na1),qroots(Da1));
title("Allpass filter A");
print(strcat(strf,"_a1pz"),"-dpdflatex");
close
subplot(111);
zplane(qroots(Nb1),qroots(Db1));
title("Allpass filter B");
print(strcat(strf,"_b1pz"),"-dpdflatex");
close
subplot(111);
zplane(qroots(conv(Nab1,[1;-1])),qroots(Dab1));
title("Parallel allpass filters");
print(strcat(strf,"_ab1pz"),"-dpdflatex");
close

% Plot phase response of parallel filters
Ha=freqz(conv(Na1,[1;-1]),Da1,w);
Hb=freqz(conv(Nb1,[1;-1]),Db1,w);
plot(w*0.5/pi,(unwrap(arg(Ha))+(w*tp))/pi, ...
     w*0.5/pi,(unwrap(arg(Hb))+(w*tp))/pi);
strt=sprintf("Phase responses of correction filters adjusted for linear phase : \
ma=%d,mb=%d,tp=%g",ma,mb,tp);
title(strt);
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
legend("Filter A and $1-z^{-1}$","Filter B and $1-z^{-1}$");
legend("location","east");
legend("boxoff");
grid("on");
print(strcat(strf,"_ab1phase"),"-dpdflatex");
close

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"polyphase=%d %% Use polyphase combination\n",polyphase);
fprintf(fid,"difference=%d %% Use difference combination\n",difference);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ma=%d %% Allpass correction filter A denominator order\n",ma);
fprintf(fid,"Va=%d %% Allpass correction filter A no. of real poles\n",Va);
fprintf(fid,"Qa=%d %% Allpass correction filter A no. of complex poles\n",Qa);
fprintf(fid,"Ra=%d %% Allpass correction filter A decimation\n",Ra);
fprintf(fid,"mb=%d %% Allpass correction filter B denominator order\n",mb);
fprintf(fid,"Vb=%d %% Allpass correction filter B no. of real poles\n",Vb);
fprintf(fid,"Qb=%d %% Allpass correction filter B no. of complex poles\n",Qb);
fprintf(fid,"Rb=%d %% Allpass correction filter B decimation\n",Rb);
fprintf(fid,"fap=%g %% Pass band amplitude response edge\n",fap);
fprintf(fid,"Arp=%f %% Pass band amplitude response ripple\n",Arp);
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Art=%f %% Transition band amplitude response ripple\n",Art);
fprintf(fid,"Wat=%d %% Transition band amplitude response weight\n",Wat);
fprintf(fid,"fas=%g %% Stop band amplitude response edge\n",fas);
fprintf(fid,"Ars=%f %% Stop band amplitude response ripple\n",Ars);
fprintf(fid,"Was=%d %% Stop band amplitude response weight\n",Was);
fprintf(fid,"tp=%g %% Pass band nominal group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band nominal group delay ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band group delay response weight\n",Wtp);
fprintf(fid,"pp=%g %% Pass band nominal phase\n",pp);
fprintf(fid,"ppr=%g %% Pass band phase peak-to-peak-ripple\n",ppr);
fprintf(fid,"Wpp=%d %% Pass band phase response weight\n",Wpp);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);

% Save results
a1=ab1(1:ma);
print_allpass_pole(a1,Va,Qa,Ra,"a1");
print_allpass_pole(a1,Va,Qa,Ra,"a1",strcat(strf,"_a1_coef.m"));
b1=ab1((ma+1):end);
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

eval(sprintf("save %s.mat ...\n\
     n fap Arp Wap tp tpr Wtp pp ppr Wpp Art Wat fas Ars Was ...\n\
     ma mb Va Qa Ra Vb Qb Rb Da0 Db0 ab0 ab1 Da1 Db1 Nab1 Dab1",strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
